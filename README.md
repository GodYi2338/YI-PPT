# YI-PPT

**不会剪辑、不写代码，也能做出发布会那样的 PPT：按一下翻页笔，镜头推近，画面接着动。**

[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
![Output](https://img.shields.io/badge/output-plain%20.pptx-orange)
![Verified](https://img.shields.io/badge/verified-macOS%20%2B%20PowerPoint%20for%20Mac-lightgrey)

PPT 的翻页，一直是"咔"一下换一张。**YI-PPT 把发布会那种一镜到底的质感，搬进你自己的 PPT。** 你写大纲、定风格，Agent 把整份 deck 做出来：每次点击，画面**接着动**，**停稳**，等你把话讲完；再按一下，同一个画面**继续运动**。观众看不到页与页之间的接缝。

成品是一份普通 `.pptx`，用 PowerPoint 放映，翻页笔照常用。

<!-- 演示素材：把成品截图或 GIF 放进 assets/，再在这里引用，例如 ![demo](assets/demo.gif)。见 assets/README.md -->

## 你是不是也遇到过

- **PowerPoint 的动画和"平滑切换"只能在原生对象之间挪动。** 镜头推近、对象变形、一路走到下一站这类连续动效，做不出来。
- **想要酷炫动效，就得做成视频，然后二选一：**
  - 整片播放：讲到哪，视频跟到哪，节奏被视频牵着走，没法停下来讲。
  - 拆成几段嵌进 PPT：翻页时闪黑、跳帧、画面对不上；往回翻一页，又掉回这一页的第一帧。
- **动效工具和 PPT 是两个世界。** 每改一处，都要重新渲染、重新对帧、重新嵌入，很快就不想再改了。

## YI-PPT 怎么解决

- **一次点击 = 一个 beat = 一页 PPT，节奏回到你手里。** 动效在点击之后发生，停稳的画面才是你讲话的时间，想讲多久讲多久。
- **接缝在出片阶段就被抓出来。** 同一章的所有视频页是一条连续时间轴，渲染一次再按 beat 切开，第 N 页的末帧就是第 N+1 页的首帧。`split-beats.sh` 用 SSIM 逐个检查切点，会跳的接缝直接报错，不用转场去掩盖；样章实测两侧 SSIM 为 0.9984（CRF 18）到 0.9994（CRF 12）。
- **回翻不再掉回首帧。** 每个视频页叠一张末帧图，往回翻页时画面停在落点，再往前翻仍能与下一页接上（已在 PowerPoint for Mac 试放通过）。
- **进入即自动播放，没有播放器、没有"请稍等"。** `pptx-autoplay.py` 把"开始：自动"写进 pptx，视频是嵌入的，不是链接，拷到别的电脑不会丢。
- **从大纲到成片，Agent 按同一套规则走完。** 划 beat、写动线剧本、出落点关键帧、渲染、切片、组装 pptx、自动播放、动态自检。每一步你都能叫停和返修，只动受影响的部分。
- **不用会剪辑，不用写代码，不用手动对帧。** 动效、切片、接缝检查、组装 pptx 都由 Agent 按规则完成；你需要做的是讲清楚想表达什么、在样稿上说"这个对"或"这里太突然"。环境检查和安装由 Agent 提出方案，经你批准后执行。
- **不虚报"通过"。** 检查结论与采用决定分开记录；没在目标电脑放映过的项目，一律写"未验证"。

> **English summary.** **Keynote-style, one-take motion for your own deck, with no editing skills or code required.** PowerPoint animations can't do camera moves or continuous object morphs, and embedding video usually means flashes, jumps and a player that sets your pace. YI-PPT is an agent-driven workflow that renders each chapter as a single Remotion timeline, slices it per click, and assembles a plain `.pptx` where the last frame of slide N is the first frame of slide N+1 (checked with SSIM at every cut). Slides auto-play on entry, hold the final frame when you page back, and work with a normal clicker. The repo holds the workflow docs, prompts, templates and three small scripts (FFmpeg beat slicing, PowerPoint auto-play patching, motion checks). Apache-2.0. Verified on macOS + PowerPoint for Mac only.

你负责内容、风格与采用决定；Agent 负责规划、Remotion 动效、切片、组装 PPT、检查和记录。

## 核心做法

**一次点击 = 一个 beat = 一页 PPT。** 同一章里连续的视频页，在 Remotion 里是**一条连续时间轴**：渲染一次，再按 beat 帧号切成每页一个 mp4。第 N 页的最后一帧就是第 N+1 页的第一帧，翻页时观众看到的是同一个画面继续运动，而不是换了一页。

```text
讲稿/大纲 → 页面表（划 beat）→ 动线剧本 → 落点关键帧 → Remotion 整章渲染
   → split-beats 切片＋接缝检查 → PPT 组装（每页嵌入 mp4）→ pptx-autoplay → 全屏放映验收
```

三条规则贯穿全程：

- **每个 beat 停在可讲的落点。** 动效在点击后发生，停稳的画面才是讲话的时间；视频播完停在最后一帧。
- **先做落点，再做过程。** 关键帧就是每个 beat 的末帧，用 Remotion 直接出静帧确认；确认后再做两个落点之间的运动。
- **原生页和视频页分工。** 文字密集、需要现场改的页用原生 PPT（可配平滑切换）；连续变形、镜头推进、录屏演示用视频页。

## 工具分工

| 工具 | 负责 |
| --- | --- |
| Remotion | 全部动效：镜头推进、状态链、连续 MG、录屏包装 |
| FFmpeg | 按 beat 切片、转码、录屏微剪、动态自检（`tools/` 已封装） |
| Agent＋pptx 能力（如 pptxgenjs） | 生成和调整 PPT：原生页、主题、嵌入视频、演讲者备注 |
| Recordly（按需） | 录制产品操作，导出给 Remotion 二次包装，或直接作为视频页 |
| PowerPoint | 放映与最终验收 |

## 前置条件

| 项目 | 要求 |
| --- | --- |
| 系统 | 目前只在 macOS 上验证过；Windows、Linux 未验证 |
| Node.js ＋ Remotion | 动效渲染。实测版本 Remotion 4.0.532，沿用同一版本为宜 |
| FFmpeg／FFprobe | `tools/` 脚本依赖；`split-beats.sh`、`motion-check.sh` 在 macOS 自带 bash 3.2 上测试过 |
| Python 3 | `pptx-autoplay.py` 只用标准库 |
| PowerPoint | 放映与验收；目前只在 PowerPoint for Mac 上试放通过，Windows、Keynote、WPS 需自行试放 |
| Agent | 能读写本地文件、能执行命令的 Agent |

第三方工具的许可见 [来源与第三方说明](docs/06_来源与致谢.md)。Remotion 对公司使用有商业条款，请自行确认。

## 跟着做

把本仓库作为系列根目录，用能读写本地文件的 Agent 打开。`AGENTS.md` 是通用的入口文件，支持该约定的 Agent 会自动读取；其他宿主请先说一句“读取根目录 AGENTS.md”。每次只发当前一步，看过结果再发下一步。

1. **初始化**：[01_初始化](prompts/01_初始化.md)。检查 Node、Remotion、FFmpeg、PowerPoint，建立本份 deck 目录，并用[接缝测试样例](tools/samples/接缝测试.pptx)在目标电脑上试放一次。
2. **建立 DESIGN**（每种风格一次）：[02_建立DESIGN](prompts/02_建立DESIGN.md)。静态样页 → 动态样章 → 写入 `DESIGN-<风格名>.md`。系列可以有多份 DESIGN，每份 deck 开始前由用户选定一份。可参考 [模板](templates/DESIGN.template.md) 和 [示例](examples/DESIGN-apple-style.md)。
3. **页面表与动线剧本**：[03_页面表与动线剧本](prompts/03_页面表与动线剧本.md)。划页、划 beat、定页型，写每章主角对象怎么变、镜头怎么带人看。
4. **落点关键帧**：[04_关键帧与动效](prompts/04_关键帧与动效.md) 第一段。每个 beat 的末帧出真实静帧，汇成视觉总览给你确认。
5. **动效制作**：同一提示词第二段。整章渲染、切片、接缝检查、动态自检。
6. **组装 PPT**：[05_组装PPT](prompts/05_组装PPT.md)。构建脚本生成 pptx，设置自动播放，结构校验。
7. **放映验收**：[06_放映验收](prompts/06_放映验收.md)。在目标电脑全屏走一遍，记录原话，整理交付。

## 目录

```text
AGENTS.md        Agent 入口与任务路由
docs/            工作流、目录与工程、验收、工具、DESIGN、来源与第三方说明
templates/       页面表、动线剧本、QA 表、DESIGN
examples/        通用的 DESIGN 示例（使用前复制到系列根目录）
prompts/         各阶段可复制提示词
tools/           split-beats.sh、pptx-autoplay.py、motion-check.sh、试放样例
assets/          README 用的截图与 GIF
```

## 许可与贡献

按 [Apache-2.0](LICENSE) 发布，版权声明见 [NOTICE](NOTICE)。参与方式见 [CONTRIBUTING](CONTRIBUTING.md)，版本记录见 [CHANGELOG](CHANGELOG.md)。
