# 工具

三个脚本只依赖 FFmpeg／FFprobe 与 Python 3 标准库，在 macOS 自带的 bash 3.2 上测试过。都不删除文件，同名输出会覆盖，每个版本用新的输出目录。

## split-beats.sh｜按 beat 切片＋接缝检查

把一章连续渲染的视频按帧号切成每页一个 mp4，导出每段首帧／末帧 PNG，并检查相邻 beat 的接缝。

```bash
tools/split-beats.sh renders/C01_v01.mp4 src/chapters/C01/beats.json renders/C01_v01_beats [crf]
```

- `beats.json`：`[{"id":"P02","start":0,"end":96}, …]`，帧号从 0 开始，`end` 不包含。也接受 `id,start,end` 格式的 CSV。
- 输出：`<id>.mp4`（H.264 High、yuv420p、limited range、BT.709 标记、faststart、无音轨）、`<id>_first.png`（作封面）、`<id>_last.png`（关键帧／备份版／回翻末帧图）、`summary.txt`。首末帧 PNG 从切好的片段截取，与嵌入的视频同源。
- Remotion 默认输出 full range（yuvj420p），部分 Windows 解码器会按 limited range 显示，造成视频与封面图色差；切片时统一转为 limited range BT.709。
- crf：样章实测 18 时翻页两侧压缩画面最大单点差 51 级（SSIM 0.9984），12 时 SSIM 0.9994、文件约大一倍；样章用 12。
- 接缝：相邻且帧号连续的两段，比较母版上切点两侧的两帧的 SSIM；低于 0.999 报“翻页会跳”，脚本以退出码 1 结束。它只说明切点两侧是否静止一致，不评价动效本身，也不包含分段编码噪声。

## pptx-autoplay.py｜视频进入页面自动播放

```bash
python3 tools/pptx-autoplay.py 05_PPT/D01_v03.pptx -o 05_PPT/D01_v03_auto.pptx [--slides 2,4-9] [--force] [--hold-last]
```

- 给含视频的页写入 PowerPoint 的“开始：自动”时间轴；视频时长由 ffprobe 读取。
- 已有动画的页默认跳过并提示；`--force` 用纯自动播放时间轴替换（该页其他动画会丢失）。
- 只支持嵌入在 pptx 里的视频，不处理外部链接。不修改输入文件。
- `--hold-last`：构建时在视频上方叠一张全页的末帧图（`<id>_last.png`，对象名 `hold-last`），脚本让它在视频播完时出现。往回翻页时 PowerPoint 显示该页动画已完成的状态，画面停在末帧而不是首帧，再往后翻与下一页首帧接上。图片与其他对象 id 冲突时脚本会改成不重复的 id。beat 末尾的停稳帧给视频启动延迟留了余量。已在 PowerPoint for Mac 试放通过；其他版本以试放为准。
- 已验证：pptxgenjs 生成的 deck 经处理后，PowerPoint for Mac 能正常打开，读回 `play on entry = true`，全屏放映自动播放、翻页连续。其他版本以试放为准。

## motion-check.sh｜动态自检

多数 Agent 不能以正常速度观看自己渲染的视频，只能看静帧。这个脚本把一段视频变成少量可看的证据。

```bash
tools/motion-check.sh renders/C01_v01.mp4 _work/motion-check/C01_v01 2.5-4.2 6.5-7.5
```

- 输出：`overview.png`（约 48 格总览）、`strip_NN_<起>-<止>.png`（指定区间每秒 10 帧）、`summary.txt`（静止区间统计，≥2 秒的单独标出）。
- 可选环境变量：`CELLS`、`STILL_MIN`、`NOISE`、`FLAG_SECONDS`、`STRIP_FPS`。
- 本机 ffmpeg 有 `drawtext` 时图上带时间码，没有则省略。
- 何时跑：样章或整章渲染后、交用户前各一次。先看文字统计，再只看标出的区间和关键动作。
- 边界：只定位，不判通过。PPT 的 beat 末尾本来就有停稳，静止区间要对照 beat 帧号判断哪些是落点、哪些是过程中的无用停留。

## samples/接缝测试.pptx

三页视频（1920×1080、30fps，各 2 秒），已设自动播放。在目标放映电脑上全屏放映，三次点击方块应依次右移、右移、上移，翻页处连续不跳，播完停在末帧。用它确认该电脑与 PowerPoint 版本支持本工作流。


