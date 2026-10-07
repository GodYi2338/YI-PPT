---
{
  "version": "alpha",
  "name": "Apple style (example)",
  "description": "Example series style for talks projected to a room audience. Apple-like light canvas, one blue accent, white cards; video pages told as one continuous camera take.",
  "colors": {
    "primary": "#1D1D1F",
    "secondary": "#6E6E73",
    "accent": "#0071E3",
    "canvas": "#F5F5F7",
    "surface": "#FFFFFF",
    "line": "#D2D2D7",
    "success": null,
    "accentSoft": "#E8F1FC",
    "error": "#FF3B30",
    "errorSoft": "#FFECEB"
  },
  "typography": {
    "h1": { "fontFamily": "Arial", "fontSize": "112px", "fontWeight": 700, "lineHeight": 1.05, "letterSpacing": "-3px" },
    "h2": { "fontFamily": "Arial", "fontSize": "48px", "fontWeight": 700, "lineHeight": 1.15, "letterSpacing": "-1px" },
    "body": { "fontFamily": "Arial", "fontSize": "32px", "fontWeight": 400, "lineHeight": 1.4, "letterSpacing": "0px" },
    "label": { "fontFamily": "Arial", "fontSize": "26px", "fontWeight": 700, "lineHeight": 1.2, "letterSpacing": "0px" },
    "metadata": { "fontFamily": "Arial", "fontSize": "24px", "fontWeight": 400, "lineHeight": 1.3, "letterSpacing": "0px" },
    "stat": { "fontFamily": "Arial", "fontSize": "168px", "fontWeight": 700, "lineHeight": 1.05, "letterSpacing": "-6px" },
    "chip": { "fontFamily": "Arial", "fontSize": "15px", "fontWeight": 700, "lineHeight": 1.2, "letterSpacing": "0px" }
  },
  "rounded": { "small": null, "card": "36px", "container": null, "pill": "17px" },
  "spacing": { "xs": "8px", "sm": "20px", "md": "40px", "lg": "48px", "xl": "100px", "section": null },
  "components": {
    "card": {
      "backgroundColor": "{colors.surface}",
      "textColor": "{colors.primary}",
      "typography": "{typography.h2}",
      "rounded": "{rounded.card}",
      "padding": "{spacing.md}"
    },
    "badge": {
      "backgroundColor": "{colors.accentSoft}",
      "textColor": "{colors.accent}",
      "typography": "{typography.label}",
      "size": "56px"
    },
    "chip": {
      "backgroundColor": "{colors.accent}",
      "textColor": "#FFFFFF",
      "typography": "{typography.chip}",
      "rounded": "{rounded.pill}",
      "height": "34px",
      "paddingX": "14px"
    },
    "connector": { "color": "{colors.accent}", "width": "4px" },
    "returnTrail": { "color": "{colors.line}", "width": "3px", "dash": "8 10" }
  },
  "x-deck": {
    "profileVersion": "1.0",
    "status": "example",
    "revision": "0.1.2",
    "canvas": {
      "width": 1920,
      "height": 1080,
      "fps": 30,
      "safeInsets": { "top": 112, "right": 128, "bottom": 96, "left": 128 },
      "minReadableFontSize": null
    },
    "ppt": {
      "headFont": "{typography.h1.fontFamily}",
      "bodyFont": "{typography.body.fontFamily}",
      "fontFallback": "Arial ships with Windows, macOS and Office; no embedding. Mono, if used: Consolas (Office). CJK, if ever needed: Microsoft YaHei.",
      "pxPerInch": 144,
      "ptPerPx": 0.5,
      "pptSingleLineHeight": 1.15,
      "layouts": [
        {
          "id": "title-cards-3",
          "use": "native summary page with three parallel items",
          "eyebrow": { "x": 128, "y": 112, "w": 900, "h": 40, "type": "label", "color": "accent" },
          "title": { "x": 128, "y": 168, "w": 1664, "h": 150, "type": "h1", "color": "primary" },
          "cards": { "y": 420, "h": 420, "count": 3, "gap": 48, "padding": 48 }
        }
      ],
      "nativeTransition": { "videoPages": "none", "videoToNative": "hard cut", "nativeToNative": null }
    },
    "beat": {
      "holdFramesMin": 12,
      "motionStartDelayFrames": 2
    },
    "layers": {
      "mg": { "background": "{colors.canvas}, flat", "material": "white cards with soft shadow; blue chips for the moving object" },
      "recording": { "fit": "contain", "chrome": null }
    },
    "surfaces": { "borderWidth": "0px", "cardShadow": "0 20px 60px rgba(0,0,0,0.08)", "containerShadow": null, "inputInset": "1.5px {colors.line}" },
    "motion": {
      "curves": {
        "reveal": "cubic-bezier(0.4, 0, 0.2, 1)",
        "anticipation": null,
        "travel": "cubic-bezier(0.35, 0, 0.25, 1)",
        "settle": null,
        "process": "cubic-bezier(0.4, 0, 0.2, 1)",
        "camera": "cubic-bezier(0.35, 0, 0.25, 1)"
      },
      "camera": {
        "model": "world point at screen centre + scale; zoom interpolated in log space",
        "scales": { "closeUp": [2.2, 2.6], "pair": 2.0, "wide": 1.0 },
        "breath": "during a truck between two close-ups subtract bump·sin(πt) from scale; reference sample used 0.45 (close→close) and 0.2 (close→pair)",
        "lagFrames": 2,
        "settle": "camera lands together with the last action of the beat, not after it"
      },
      "textSwap": "same position: old text out over the first 40% of the change, new text in over the last 60%; never both visible at full strength",
      "contactPulse": { "amplitude": 0.025, "frames": [14, 18] },
      "calibration": {
        "sample": null,
        "fps": 30,
        "phasesFrames": {
          "beatExamples": [67, 85, 77, 115],
          "typingShortText": 24,
          "shapeMorph": 18,
          "dock": 14,
          "valueResolve": 14,
          "lift": 13,
          "travelOneHop": [42, 48],
          "travelOneHopFollowCamera": [54, 58],
          "returnTripWithPullOut": 88,
          "pullOutToWide": 92,
          "hudToStat": 50,
          "titleIn": 32,
          "captionIn": 28,
          "overlapIntoNextAction": "dock starts at ~90% of travel; resolve starts as dock ends"
        },
        "distancesPx": {
          "oneHopWorld": 440,
          "oneHopScreenAt2.6": 1144,
          "returnTripWorld": 1100
        },
        "scope": "Reference rhythm for one-take MG on this visual system at 1920×1080@30. Values come from an earlier sample chapter; recalibrate on your own first chapter. Not yet verified on a projector."
      }
    },
    "evidence": {
      "static": null,
      "motion": null,
      "projection": null,
      "confirmation": null
    },
    "fixed": [
      "Light canvas, one accent color (error red only for rejected requests); no gradients, glows or accent stripes",
      "Video pages in a chapter are one continuous camera take; no per-page clear-and-rebuild",
      "One shared object carries the story across beats and changes state every click",
      "Every beat ends fully still for at least holdFramesMin frames; seams checked by split-beats.sh",
      "Native pages use only fonts present on Windows and macOS Office"
    ],
    "variables": [
      "Camera scales, routes and breath per chapter",
      "Beat lengths per chapter, calibrated against the `calibration` phases",
      "Card count and layout per scene"
    ],
    "exceptions": [
      "error / errorSoft are for rejected or failed steps only; check them on the target projector before relying on them"
    ]
  }
}
---

# 系列视觉与运动规范 · Apple style

参数以 front matter 为准，正文只说明用途，不再抄第二份数值。值为空表示待定，没验证过的项不补默认值。Remotion 的 `design.ts` 和 PPT 主题的取值都以这里为准。

## Overview

- **受众与场景**：面向现场听众、在会议室或教室投影的演讲。放映电脑的系统和 PowerPoint 版本通常未知，所以原生页只用 Windows 和 macOS 都有的字体，并且必须准备静态备份版。
- **观感**：接近 Apple 的浅色画布、单一蓝色重点色、白卡片配淡阴影。拒绝"AI 味"、文字堆砌和没有运镜的页面。
- **叙事**：视频页按章写成一镜到底。同一个对象在每次点击时改变状态，镜头跟随、推拉，最后拉开揭示全局。
- **样本**：本文件是示例风格，还没有绑定具体样章。用于自己的 deck 时，先在 `00_系列测试/` 做静态样页和动态样章，把确认记录写进 `x-deck.evidence`。投影和放映电脑**未验证**。

| 内容层 | 应用哪些规则 | 不继承哪些规则 |
| --- | --- | --- |
| 视频页 MG | 全部颜色角色、字阶、卡片、chip、连线、镜头语法、停稳 | — |
| 原生页 | 画布色、字阶（按 1px = 0.5pt 换算）、卡片样式、`title-cards-3` 版式 | 不模仿镜头运动、chip 形变与计时数字；不用渐变和阴影以外的效果 |
| 录屏 | 未使用，暂无规则 | 不为装饰改动真实画面 |

## Colors

- `canvas`：唯一的背景色。全片保持平涂，不加渐变和光晕。
- `surface`：卡片表面。卡片和画布之间只靠淡阴影区分，不加描边。
- `primary`：标题和卡片名称。`secondary`：说明、注释和统计标签，不得抢标题层级。
- `accent`：**只用于正在讲的那个东西**：移动中的对象（chip）、已走过的连线、编号、落点统计数字。同一画面里大面积的蓝只能有一处。
- `accentSoft`：编号底色，以及已经完成、退到背景的记录（例如已完成的记录行）。
- `line`：输入框描边、回程虚线等次级结构。
- `error` / `errorSoft`：只用于被拒绝或失败的步骤（错误码、被弹回的消息），表示“这一步没通过”；同一画面不与 `accent` 争主角，状态同时用描边或错误码文字表达，不只靠颜色。
- `success`：本系列还没用过，保持待定。状态不能只靠颜色区分，要同时配合文字或形状变化。
- 投影会降低对比度。`secondary` 灰字和 `line` 虚线最容易被投淡，需要在目标投影上复核。

## Typography

- 英文字体统一用 Arial。视频页和原生页使用同一字体，相邻翻页时字形不变。
- `h1` 是页面标题，`h2` 是卡片名称，`body` 是说明句，`label` 是编号和小标题，`metadata` 是注释。`stat` 是落点的大数字。`chip` 是 chip 内的文字：它只在特写镜头（约 2.2～2.6 倍）下供人阅读，屏幕上的实际字号约 33～39px。拉到全景后 chip 只作为运动对象，不承担阅读。
- `minReadableFontSize` 待目标投影测试确定。目前全景落点上最小的文字是 `metadata`（24px，原生页 12pt）。
- 画面文字只写给观众，不放版本号或制作说明。

## Layout

- 安全区按 `x-deck.canvas.safeInsets`。标题区左上对齐 (128, 112)。
- 间距阶梯：`xs` 8 用于名称和注释之间；`sm` 20 用于眉标和标题之间；`md` 40 是视频页卡片内边距；`lg` 48 是原生页卡片内边距和卡片间距；`xl` 100 是视频页卡片间距，中间留给连线和 chip 行进。
- 世界坐标：视频章的全景落点就是镜头 1.0 倍时的画面。特写只是这同一个世界的放大，不另外重新排版。
- 纯 MG 直接放在画布上，没有窗口框。

## PPT 原生页

- `x-deck.ppt.layouts` 目前只有 `title-cards-3` 一种，坐标单位是 1920 画布上的 px，换算规则是 1px = 1/144 in = 0.5pt。CSS 行高换算成 PPT 倍数时要除以 `pptSingleLineHeight`。
- 视频页之间不加转场；视频页 → 原生页直接硬切。原生页之间要不要用平滑切换（Morph）还没试过，先保持待定。
- 原生页的卡片带阴影，内边距和卡片间距都是 48，这和视频页的 40 / 100 不同：原生页没有连线，卡片排成网格。

## Elevation & Shapes

- 卡片：圆角 36，阴影 `0 20px 60px rgba(0,0,0,0.08)`，无描边。
- chip：胶囊形，高 34，圆角取高度的一半。
- 编号：直径 56 的 `accentSoft` 圆。
- 连线：4px 宽，`accent` 色，只在对象走过后才长出来。回程路线用 3px 的 `line` 色虚线，从卡片下方绕行。
- 镜头缩放是二维近似，不冒充三维纵深。

## Components

| 组件 | 静态接口 | 状态与运动 | 验证重点 |
| --- | --- | --- | --- |
| 卡片 | `components.card`、编号、名称、注释行 | 静止为主；被接触时以 `contactPulse` 轻微放大再回落 | 注释和 chip 不要同时出现在同一行 |
| chip（被讲述的对象） | `components.chip` | 输入 → 提交 → 记录（`accentSoft`）→ 再次提交 → 返回结果；形变、停靠、浮起、行进 | 每次点击至少变一次状态；文字替换遵循 `textSwap` |
| 连线 / 回程虚线 | `connector`、`returnTrail` | 跟着对象生长；去程走卡片中部，回程从卡片下方绕行 | 线不能先跑完而对象还没出发 |
| 计时 HUD → 统计数字 | `stat`、`metadata` | 特写阶段固定在屏幕右上角累加；拉到全景时飞到落点、放大成 `stat` | 飞行起止要和镜头拉开同步 |

## Motion

- **组织方式**：先规划整章的镜头路线：特写 → 跟随横移（途中轻微拉开再推近，即"呼吸"）→ 两者同框的中景 → 拉开到全景揭示。景别逐步变宽，不无理由重复同一个景别。
- **曲线**：变形和出现用 `reveal` / `process`，对象行进用 `travel`，镜头用 `camera`。缩放在对数空间插值，避免拉开时越到后面越快。镜头比对象晚约 `lagFrames` 帧起步，形成跟随感。
- **起步与收尾**：点击后 `motionStartDelayFrames` 帧内就开始动；镜头与本 beat 最后一个动作一起落定，不在动作结束后继续慢慢蹭。相邻的小动作略有重叠（停靠在行进约 90% 时开始），中途不降到零速再起步。要的是“稍微利落”，不是“啪地完成”。
- **停稳**：每个 beat 末尾至少静止 `holdFramesMin`（12 帧，0.4 秒），下一个 beat 从首帧起至少等 `motionStartDelayFrames`（4 帧）才开始运动。切点处不能有循环动效。
- **校准**：`calibration` 是本系列的节奏参考值，来自早期样章；用自己的首章重新校准后再作为基准。新章按变化的大小对照各阶段的帧数分配时长，不按距离成比例放大；需要调整时先改时长，再改曲线。
- **待定**：`anticipation` 和 `settle` 没有单独设计；60fps 和 4K 没有试过。

## Exceptions & Evidence

- 证据：`x-deck.evidence`。静态确认和动态确认分开记录。投影和放映电脑都未验证，本机能正常打开不代表放映电脑也正常。
- 目前没有例外。单章出现的特殊路线和参数写进该章的动线剧本，不自动升级为系列规则。
