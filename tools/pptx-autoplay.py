#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""把 .pptx 里的视频设为“进入该页自动播放”（PowerPoint 的“开始：自动”）。

用法：
  python3 tools/pptx-autoplay.py deck.pptx -o deck_auto.pptx [--slides 2,4-9] [--force] [--hold-last]

- 只处理含视频的页；未指定 --slides 时处理全部页。
- 页面已有动画时间轴（<p:timing>）默认跳过并提示，--force 会用纯自动播放时间轴替换它
  （该页原有的其他动画会丢失）。
- --hold-last：页面上名为 hold-last 的图片（视频末帧，叠在视频上方）在视频播完时出现。
  往回翻页时 PowerPoint 显示该页“动画已完成”的状态，画面因此停在末帧而不是首帧，
  再往后翻能与下一页首帧接上。
- 视频时长由 ffprobe 读取。只依赖 Python 标准库和 ffprobe；不修改输入文件。
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile

PIC_RE = re.compile(r"<p:pic>.*?</p:pic>", re.S)
SLIDE_RE = re.compile(r"^ppt/slides/slide(\d+)\.xml$")


def parse_slides(spec):
    out = set()
    for part in spec.split(","):
        part = part.strip()
        if not part:
            continue
        if "-" in part:
            a, b = part.split("-", 1)
            out.update(range(int(a), int(b) + 1))
        else:
            out.add(int(part))
    return out


def rels_map(zf, rels_name):
    if rels_name not in zf.namelist():
        return {}
    xml = zf.read(rels_name).decode("utf-8")
    m = {}
    for rel in re.finditer(r"<Relationship\b[^>]*>", xml):
        tag = rel.group(0)
        rid = re.search(r'\bId="([^"]+)"', tag)
        tgt = re.search(r'\bTarget="([^"]+)"', tag)
        if rid and tgt:
            m[rid.group(1)] = tgt.group(1)
    return m


def slide_rels_name(slide_name):
    return slide_name.replace("ppt/slides/", "ppt/slides/_rels/") + ".rels"


def slide_order(zf):
    """slideN 的文件编号不一定等于放映顺序，按 presentation.xml 的页序换算。"""
    pres = zf.read("ppt/presentation.xml").decode("utf-8")
    rels = rels_map(zf, "ppt/_rels/presentation.xml.rels")
    order = {}
    for i, m in enumerate(re.finditer(r'<p:sldId\b[^>]*r:id="([^"]+)"', pres), start=1):
        tgt = rels.get(m.group(1))
        if tgt:
            order["ppt/" + tgt.lstrip("/").removeprefix("ppt/")] = i
    return order


def media_duration_ms(zf, target, tmpdir):
    name = os.path.normpath(os.path.join("ppt/slides", target)).replace(os.sep, "/")
    if name not in zf.namelist():
        raise RuntimeError(f"找不到嵌入视频 {name}（外部链接的视频不支持）")
    path = os.path.join(tmpdir, os.path.basename(name))
    with open(path, "wb") as f:
        f.write(zf.read(name))
    sec = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "default=nw=1:nk=1", path],
        capture_output=True, text=True, check=True,
    ).stdout.strip()
    return max(1, round(float(sec) * 1000))


HOLD_NAME = "hold-last"


def timing_xml(videos, holds=()):
    """videos: [(spid, dur_ms)]。第一个视频随页面开始，其余与它同时开始。
    holds: [(spid, delay_ms)]，图片在 delay 时“出现”（与第一个视频同组开始计时）。"""
    nid = 5  # 1 根节点，2 主序列，3 点击组，4 本组内的并行组
    effects = []
    for i, (spid, dur) in enumerate(videos):
        node = "afterEffect" if i == 0 else "withEffect"
        effects.append(
            f'<p:par><p:cTn id="{nid}" presetID="1" presetClass="mediacall" presetSubtype="0" '
            f'fill="hold" nodeType="{node}"><p:stCondLst><p:cond delay="0"/></p:stCondLst>'
            f'<p:childTnLst><p:cmd type="call" cmd="playFrom(0.0)"><p:cBhvr>'
            f'<p:cTn id="{nid + 1}" dur="{dur}" fill="hold"/>'
            f'<p:tgtEl><p:spTgt spid="{spid}"/></p:tgtEl></p:cBhvr></p:cmd></p:childTnLst></p:cTn></p:par>'
        )
        nid += 2
    for spid, delay in holds:
        effects.append(
            f'<p:par><p:cTn id="{nid}" presetID="1" presetClass="entr" presetSubtype="0" '
            f'fill="hold" grpId="0" nodeType="withEffect"><p:stCondLst><p:cond delay="{delay}"/></p:stCondLst>'
            f'<p:childTnLst><p:set><p:cBhvr><p:cTn id="{nid + 1}" dur="1" fill="hold">'
            f'<p:stCondLst><p:cond delay="0"/></p:stCondLst></p:cTn>'
            f'<p:tgtEl><p:spTgt spid="{spid}"/></p:tgtEl>'
            f'<p:attrNameLst><p:attrName>style.visibility</p:attrName></p:attrNameLst></p:cBhvr>'
            f'<p:to><p:strVal val="visible"/></p:to></p:set></p:childTnLst></p:cTn></p:par>'
        )
        nid += 2
    media_nodes = []
    for spid, _ in videos:
        media_nodes.append(
            f'<p:video><p:cMediaNode vol="80000"><p:cTn id="{nid}" fill="hold" display="0">'
            f'<p:stCondLst><p:cond delay="indefinite"/></p:stCondLst></p:cTn>'
            f'<p:tgtEl><p:spTgt spid="{spid}"/></p:tgtEl></p:cMediaNode></p:video>'
        )
        nid += 1
    return (
        '<p:timing><p:tnLst><p:par><p:cTn id="1" dur="indefinite" restart="never" nodeType="tmRoot">'
        '<p:childTnLst><p:seq concurrent="1" nextAc="seek"><p:cTn id="2" dur="indefinite" nodeType="mainSeq">'
        '<p:childTnLst><p:par><p:cTn id="3" fill="hold"><p:stCondLst><p:cond delay="indefinite"/>'
        '<p:cond evt="onBegin" delay="0"><p:tn val="2"/></p:cond></p:stCondLst>'
        '<p:childTnLst><p:par><p:cTn id="4" fill="hold"><p:stCondLst><p:cond delay="0"/></p:stCondLst>'
        f'<p:childTnLst>{"".join(effects)}</p:childTnLst></p:cTn></p:par>'
        '</p:childTnLst></p:cTn></p:par></p:childTnLst></p:cTn>'
        '<p:prevCondLst><p:cond evt="onPrev" delay="0"><p:tgtEl><p:sldTgt/></p:tgtEl></p:cond></p:prevCondLst>'
        '<p:nextCondLst><p:cond evt="onNext" delay="0"><p:tgtEl><p:sldTgt/></p:tgtEl></p:cond></p:nextCondLst>'
        f'</p:seq>{"".join(media_nodes)}</p:childTnLst></p:cTn></p:par></p:tnLst></p:timing>'
    )


def insert_timing(xml, timing):
    cut = xml.find("</p:cSld>")
    if cut < 0:
        raise RuntimeError("页面 XML 缺少 </p:cSld>")
    cut += len("</p:cSld>")
    head, tail = xml[:cut], xml[cut:]
    pos = tail.find("<p:extLst")
    if pos < 0:
        pos = tail.rfind("</p:sld>")
    return head + tail[:pos] + timing + tail[pos:]


def main():
    ap = argparse.ArgumentParser(description="把 pptx 中的视频设为进入页面自动播放")
    ap.add_argument("pptx")
    ap.add_argument("-o", "--output", required=True)
    ap.add_argument("--slides", help="只处理这些页，如 2,4-9（从 1 开始，按文件里的页序号）")
    ap.add_argument("--force", action="store_true", help="替换已有动画时间轴")
    ap.add_argument("--hold-last", action="store_true",
                    help=f"名为 {HOLD_NAME} 的图片在视频播完时出现，回翻时停在末帧")
    args = ap.parse_args()

    if shutil.which("ffprobe") is None:
        sys.exit("缺少 ffprobe")
    if os.path.abspath(args.pptx) == os.path.abspath(args.output):
        sys.exit("输出不能覆盖输入文件")
    only = parse_slides(args.slides) if args.slides else None

    changed = {}
    report = []
    with zipfile.ZipFile(args.pptx) as zf, tempfile.TemporaryDirectory() as tmp:
        order = slide_order(zf)
        for name in zf.namelist():
            m = SLIDE_RE.match(name)
            if not m:
                continue
            idx = order.get(name)
            if only is not None and idx not in only:
                continue
            xml = zf.read(name).decode("utf-8")
            rels = rels_map(zf, slide_rels_name(name))
            videos = []
            for pic in PIC_RE.findall(xml):
                if "<a:videoFile" not in pic:
                    continue
                spid = re.search(r'<p:cNvPr\b[^>]*\bid="(\d+)"', pic).group(1)
                rid = re.search(r'<p14:media\b[^>]*r:embed="([^"]+)"', pic) or re.search(
                    r'<a:videoFile\b[^>]*r:(?:link|embed)="([^"]+)"', pic)
                target = rels.get(rid.group(1)) if rid else None
                if not target:
                    raise RuntimeError(f"{name}：找不到视频 {spid} 的文件关系")
                videos.append((spid, media_duration_ms(zf, target, tmp)))
            if not videos:
                continue
            holds = []
            if args.hold_last:
                for pic in PIC_RE.findall(xml):
                    nv = re.search(r'<p:cNvPr\b[^>]*>', pic).group(0)
                    if "<a:videoFile" in pic or f'name="{HOLD_NAME}"' not in nv:
                        continue
                    hid = re.search(r'\bid="(\d+)"', nv).group(1)
                    ids = re.findall(r'<p:cNvPr\b[^>]*\bid="(\d+)"', xml)
                    if ids.count(hid) > 1:  # pptxgenjs 可能给视频和图片同一个 id；改成不重复的新 id
                        new_id = str(max(int(i) for i in ids) + 1)
                        xml = xml.replace(pic, pic.replace(nv, nv.replace(f'id="{hid}"', f'id="{new_id}"', 1), 1), 1)
                        hid = new_id
                    holds.append((hid, videos[0][1]))
            label = f"第{idx}页" if idx else name
            if "<p:timing" in xml:
                if not args.force:
                    report.append((idx or 0, f"{label}：已有动画时间轴，跳过（需要替换时加 --force）"))
                    continue
                xml = re.sub(r"<p:timing>.*?</p:timing>", "", xml, flags=re.S)
            changed[name] = insert_timing(xml, timing_xml(videos, holds)).encode("utf-8")
            secs = "、".join(f"{d / 1000:.2f}s" for _, d in videos)
            hold = f"；末帧图 {len(holds)} 张" if args.hold_last else ""
            report.append((idx or 0, f"{label}：{len(videos)} 个视频设为自动播放（{secs}）{hold}"))
            if args.hold_last and not holds:
                report.append((idx or 0, f"{label}：没有名为 {HOLD_NAME} 的图片，回翻会停在首帧"))

        with zipfile.ZipFile(args.output, "w") as out:
            for info in zf.infolist():
                data = changed.get(info.filename, zf.read(info.filename))
                out.writestr(info, data, compress_type=info.compress_type)

    for _, line in sorted(report):
        print(line)
    print(f"已写入 {args.output}；共修改 {len(changed)} 页。请在目标电脑上放映确认。")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError, zipfile.BadZipFile) as e:
        sys.exit(f"错误：{e}")
