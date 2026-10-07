#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# 把一章连续渲染的视频按 beat 帧号切成每页一个 mp4，并导出首帧／尾帧 PNG。
# 同时检查相邻 beat 的接缝：上一段尾帧与下一段首帧应几乎相同（都在静止落点上）。
#
# 用法：tools/split-beats.sh <chapter.mp4> <beats.json|beats.csv> <outdir> [crf]
#   beats.json：[{"id":"P03","start":0,"end":96}, ...]（Remotion 工程可直接 import 同一文件）
#   beats.csv：每行 id,start,end；# 开头和表头行跳过。帧号从 0 开始，end 不包含。
#   crf：H.264 质量，默认 18，越小越清晰、文件越大。
# 输出：<id>.mp4、<id>_first.png、<id>_last.png、summary.txt
# 只依赖 ffmpeg／ffprobe；同名输出会覆盖，不删除其他文件。
set -euo pipefail

if [[ $# -lt 3 ]]; then
  sed -n '2,10p' "$0"; exit 1
fi
VIDEO=$1; CSV=$2; OUT=$3; CRF=${4:-18}
SEAM_MIN=0.999   # SSIM 低于此值视为接缝跳变

for t in ffmpeg ffprobe; do command -v "$t" >/dev/null || { echo "缺少 $t" >&2; exit 1; }; done
[[ -f $VIDEO ]] || { echo "找不到视频：$VIDEO" >&2; exit 1; }
[[ -f $CSV ]] || { echo "找不到 beats 表：$CSV" >&2; exit 1; }
if [[ $CSV == *.json ]]; then
  ROWS=$(python3 -c 'import json,sys
for b in json.load(open(sys.argv[1], encoding="utf-8")): print(b["id"], b["start"], b["end"], sep=",")' "$CSV")
else
  ROWS=$(cat "$CSV")
fi
mkdir -p "$OUT"

FPS=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=nw=1:nk=1 "$VIDEO" | head -1)
TOTAL=$(ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of default=nw=1:nk=1 "$VIDEO" | head -1)
SIZE=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$VIDEO" | head -1 | sed "s/x*$//")

frame_png() { # $1 视频 $2 帧号 $3 输出（从切好的片段取，封面与末帧图和嵌入的视频同源）
  ffmpeg -nostdin -hide_banner -loglevel error -y -i "$1" -vf "select=eq(n\,$2)" -frames:v 1 -update 1 "$3"
}
ssim_of() { # 两张 PNG 的 SSIM All 值
  ffmpeg -nostdin -hide_banner -i "$1" -i "$2" -lavfi ssim -f null - 2>&1 | sed -n 's/.*All:\([0-9.]*\).*/\1/p' | tail -1
}

SUMMARY="$OUT/summary.txt"
{
  echo "video: $VIDEO"
  echo "size: $SIZE  fps: $FPS  total_frames: $TOTAL  crf: $CRF"
  echo "id  start-end(帧)  时长(s)  文件"
} > "$SUMMARY"

SEAM=$(mktemp -d)  # 接缝比较用的临时帧，放系统临时目录
prev_id=""; prev_end=""; n=0; warn=0
while IFS=, read -r id start end _rest || [[ -n ${id:-} ]]; do
  id=$(echo "$id" | tr -d '[:space:]'); start=$(echo "${start:-}" | tr -d '[:space:]'); end=$(echo "${end:-}" | tr -d '[:space:]')
  [[ -z $id || $id == \#* || $id == id ]] && continue
  if ! [[ $start =~ ^[0-9]+$ && $end =~ ^[0-9]+$ ]] || (( end <= start )); then
    echo "跳过格式错误的行：$id,$start,$end" | tee -a "$SUMMARY" >&2; warn=1; continue
  fi
  if (( end > TOTAL )); then
    echo "跳过越界的行：$id 结束帧 $end > 总帧数 $TOTAL" | tee -a "$SUMMARY" >&2; warn=1; continue
  fi
  n=$((n + 1))
  ffmpeg -nostdin -hide_banner -loglevel error -y -i "$VIDEO" \
    -vf "select=between(n\,$start\,$((end - 1))),setpts=N/FRAME_RATE/TB,scale=out_color_matrix=bt709:out_range=tv" -r "$FPS" -an \
    -c:v libx264 -preset slow -crf "$CRF" -pix_fmt yuv420p -profile:v high -movflags +faststart \
    -color_range tv -colorspace bt709 -color_primaries bt709 -color_trc bt709 \
    "$OUT/$id.mp4"
  frame_png "$OUT/$id.mp4" 0 "$OUT/${id}_first.png"
  frame_png "$OUT/$id.mp4" "$((end - start - 1))" "$OUT/${id}_last.png"
  dur=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$OUT/$id.mp4")
  echo "$id  $start-$end  $dur  $OUT/$id.mp4" >> "$SUMMARY"

  if [[ -n $prev_id ]]; then
    if [[ $prev_end == "$start" ]]; then
      # 接缝比较母版上切点两侧的帧（内容是否静止），不受分段编码噪声影响
      frame_png "$VIDEO" "$((start - 1))" "$SEAM/a.png"
      frame_png "$VIDEO" "$start" "$SEAM/b.png"
      s=$(ssim_of "$SEAM/a.png" "$SEAM/b.png")
      if awk -v s="${s:-0}" -v m="$SEAM_MIN" 'BEGIN{exit !(s < m)}'; then
        echo "  接缝 $prev_id→$id：SSIM $s，切点不在静止落点上，翻页会跳" >> "$SUMMARY"; warn=1
      else
        echo "  接缝 $prev_id→$id：SSIM $s" >> "$SUMMARY"
      fi
    else
      echo "  接缝 $prev_id→$id：帧号不连续（$prev_end≠$start），按断开处理，不检查" >> "$SUMMARY"
    fi
  fi
  prev_id=$id; prev_end=$end
done <<< "$ROWS"

echo "beats: $n" >> "$SUMMARY"
echo "note: SSIM 只检查切点两侧是否静止一致，不代表动效本身合格。" >> "$SUMMARY"
cat "$SUMMARY"
exit $warn
