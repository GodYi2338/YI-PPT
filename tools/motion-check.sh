#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# 动态自检：把一段渲染结果变成少量可看的证据，交用户前先发现明显问题。
# 只定位可疑区间，不判通过。只依赖 ffmpeg／ffprobe，不删除任何文件。
#
# 用法：tools/motion-check.sh <video.mp4> <outdir> [起-止 ...]
#   例：tools/motion-check.sh renders/C02.mp4 _work/motion-check/C02_v01 2.5-4.2 6.5-7.5
# 可选环境变量：CELLS=48 STILL_MIN=0.75 NOISE=-55dB FLAG_SECONDS=2 STRIP_FPS=10
# 输出：overview.png（整段总览）、strip_NN_<起>-<止>.png（指定区间密集帧）、summary.txt
set -euo pipefail

if [[ $# -lt 2 ]]; then
  sed -n '2,9p' "$0"; exit 1
fi
VIDEO=$1; OUT=$2; shift 2
CELLS=${CELLS:-48}; STILL_MIN=${STILL_MIN:-0.75}; NOISE=${NOISE:--55dB}
FLAG_SECONDS=${FLAG_SECONDS:-2}; STRIP_FPS=${STRIP_FPS:-10}; STRIP_MAX=50

for t in ffmpeg ffprobe; do command -v "$t" >/dev/null || { echo "缺少 $t" >&2; exit 1; }; done
[[ -f $VIDEO ]] || { echo "找不到视频：$VIDEO" >&2; exit 1; }
mkdir -p "$OUT"

DUR=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$VIDEO" | head -1)
calc() { awk "BEGIN{print $1}"; }
minf() { awk -v a="$1" -v b="$2" 'BEGIN{print (a<b?a:b)}'; }

# 时间码需要 ffmpeg 带 drawtext（libfreetype）；没有就省略。
LABEL=""
FONT=/System/Library/Fonts/Supplemental/Arial.ttf
if ffmpeg -hide_banner -filters 2>/dev/null | grep -q ' drawtext ' && [[ -f $FONT ]]; then
  LABEL=",drawtext=fontfile=$FONT:text='%{pts\\:hms}':x=6:y=6:fontsize=20:fontcolor=white:box=1:boxcolor=black@0.7"
fi

# 1) 总览：约 CELLS 格，6 列
COLS=6; ROWS=$(( (CELLS + COLS - 1) / COLS ))
OV_FPS=$(minf "$(calc "($CELLS-1)/$DUR")" 10)
ffmpeg -hide_banner -loglevel error -y -i "$VIDEO" \
  -vf "fps=$OV_FPS,scale=480:270$LABEL,tile=${COLS}x${ROWS}:padding=4:color=black" -frames:v 1 "$OUT/overview.png"

# 2) 静止区间
LOG=$(ffmpeg -hide_banner -nostats -i "$VIDEO" -vf "scale=480:-2,freezedetect=n=$NOISE:d=$STILL_MIN" -map 0:v -f null - 2>&1 || true)
STILLS=$(echo "$LOG" | awk -v dur="$DUR" '
  /freeze_start:/ { s=$NF; open=1 }
  /freeze_end:/   { e=$NF; if(open){ printf "%.2f %.2f %.2f\n", s, e, e-s; open=0 } }
  END { if(open) printf "%.2f %.2f %.2f\n", s, dur, dur-s }')

# 3) 指定区间密集帧
STRIPS=(); n=0
for r in "$@"; do
  if ! [[ $r =~ ^([0-9.]+)-([0-9.]+)$ ]]; then echo "跳过格式错误的区间：$r" >&2; continue; fi
  a=${BASH_REMATCH[1]}; b=${BASH_REMATCH[2]}
  if awk -v a="$a" -v b="$b" 'BEGIN{exit !(b<=a)}'; then echo "跳过空区间：$r" >&2; continue; fi
  n=$((n + 1))
  fps=$(minf "$(calc "($STRIP_MAX-1)/($b-$a)")" "$STRIP_FPS")
  count=$(calc "int(($b-$a)*$fps+0.999)"); rows=$(( (count + 4) / 5 ))
  png=$(printf '%s/strip_%02d_%s-%s.png' "$OUT" "$n" "$a" "$b")
  ffmpeg -hide_banner -loglevel error -y -i "$VIDEO" \
    -vf "trim=start=$a:end=$b,setpts=PTS-STARTPTS,fps=$fps,scale=640:360$LABEL,tile=5x${rows}:padding=4:color=black" -frames:v 1 "$png"
  STRIPS+=("strip $r @${fps}fps: $png")
done

# 4) 汇总
{
  echo "video: $VIDEO"
  echo "duration_s: $DUR   still_rule: >= ${STILL_MIN}s at $NOISE"
  echo "$STILLS" | awk -v dur="$DUR" -v flag="$FLAG_SECONDS" '
    NF==3 { total+=$3; c++; if($3>max){max=$3; ms=$1; me=$2}; if($3>=flag) f=f sprintf("  %s-%s  (%ss)\n",$1,$2,$3); all=all sprintf("  %s-%s  (%ss)\n",$1,$2,$3) }
    END {
      printf "still_total_s: %.2f   still_percent: %.1f%%   intervals: %d\n", total, (dur>0?100*total/dur:0), c
      if(c) printf "longest_still: %.2fs at %s-%s\n", max, ms, me
      printf "flagged (>= %ss，逐个确认是否为阅读或表达所需):\n", flag
      printf "%s", (f==""?"  none\n":f)
      printf "all still intervals:\n%s", all
    }'
  echo "overview: $OUT/overview.png"
  for s in "${STRIPS[@]+"${STRIPS[@]}"}"; do echo "$s"; done
  [[ -z $LABEL ]] && echo "note: 本机 ffmpeg 没有 drawtext，图中不带时间码；总览按时间顺序从左到右、从上到下排列。"
  echo "note: 只定位，不判通过。静止可能是必要的阅读时间；运动占比高也不代表合格。"
} | tee "$OUT/summary.txt"
