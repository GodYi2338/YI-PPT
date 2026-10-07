---
{
  "version": "alpha",
  "name": "[系列名称]",
  "description": "[视觉目的与适用场景]",
  "colors": {
    "primary": null,
    "secondary": null,
    "accent": null,
    "canvas": null,
    "surface": null,
    "line": null,
    "success": null
  },
  "typography": {
    "h1": { "fontFamily": null, "fontSize": null, "fontWeight": null, "lineHeight": null, "letterSpacing": null },
    "h2": { "fontFamily": null, "fontSize": null, "fontWeight": null, "lineHeight": null, "letterSpacing": null },
    "body": { "fontFamily": null, "fontSize": null, "fontWeight": null, "lineHeight": null, "letterSpacing": null },
    "label": { "fontFamily": null, "fontSize": null, "fontWeight": null, "lineHeight": null, "letterSpacing": null },
    "metadata": { "fontFamily": null, "fontSize": null, "fontWeight": null, "lineHeight": null, "letterSpacing": null }
  },
  "rounded": { "small": null, "card": null, "container": null },
  "spacing": { "xs": null, "sm": null, "md": null, "lg": null, "xl": null, "section": null },
  "components": {
    "card": {
      "backgroundColor": "{colors.surface}",
      "textColor": "{colors.primary}",
      "typography": "{typography.body}",
      "rounded": "{rounded.card}",
      "padding": "{spacing.lg}"
    }
  },
  "x-deck": {
    "profileVersion": "1.0",
    "status": "draft",
    "revision": "0.1.0",
    "canvas": {
      "width": 1920,
      "height": 1080,
      "fps": null,
      "safeInsets": { "top": null, "right": null, "bottom": null, "left": null },
      "minReadableFontSize": null
    },
    "ppt": {
      "headFont": "{typography.h1.fontFamily}",
      "bodyFont": "{typography.body.fontFamily}",
      "fontFallback": null,
      "layouts": [],
      "nativeTransition": null
    },
    "beat": {
      "holdFramesMin": null,
      "motionStartDelayFrames": null
    },
    "layers": {
      "mg": { "background": null, "material": null },
      "recording": { "fit": "contain", "chrome": "[none或组件ID]" }
    },
    "surfaces": { "borderWidth": null, "cardShadow": null, "containerShadow": null },
    "motion": {
      "curves": { "reveal": null, "anticipation": null, "travel": null, "settle": null, "process": null, "camera": null },
      "calibration": {
        "sample": null,
        "fps": null,
        "phasesFrames": {},
        "distancesPx": {},
        "scope": null
      }
    },
    "evidence": { "static": null, "motion": null, "projection": null, "confirmation": null },
    "fixed": [],
    "variables": [],
    "exceptions": []
  }
}
---

# 系列视觉与运动规范

文件名为 `DESIGN-<风格名>.md`，填写说明见 `docs/05_DESIGN建立.md`。JSON front matter 放参数，正文解释用途与例外，不抄第二份数值。空值表示待定；正式采用前填完当前用到的项。Remotion 的 `design.ts` 与 PPT 主题的取值都以这里为准。

## Overview

[观众、场景（投影／会议共享）、内容类型、视觉关键词及其对应的具体做法。记录静态样页、动态样章、放映测试的路径与确认范围。]

| 内容层 | 应用哪些规则 | 不继承哪些规则 |
| --- | --- | --- |
| 视频页 MG | [颜色角色、字体、图形语法、背景、运动] | [写明] |
| 原生页 | [主题色、字体、版式、平滑切换的使用范围] | [不模仿视频页里的复杂运动] |
| 录屏 | [原比例、窗口包装、阅读时间] | [不为装饰改动真实产品画面] |

## Colors

为每个 token 写“表达什么、用在哪里、不得抢什么层级”。区分画布、表面、主文字、次要文字、焦点、状态与连接线。状态不能只靠颜色区分。投影会降低对比度，关键颜色在投影或共享画面上复核。

## Typography

说明五级字体各自用途。字号以 1920×1080 画布为准；`minReadableFontSize` 是在实际投影距离或会议共享画面上仍能读清的最小字号，由放映测试确定。原生页字体需要在放映电脑上可用，记录回退字体与是否嵌入。

画面文字只写给观众，不放版本号或制作说明。主要内容不缩在画面一角，四周大片空白须有构图作用。

## Layout

`spacing` 阶梯的用途：组内、卡片内、卡片间、章节间。安全区以 `x-deck.canvas.safeInsets` 为准（考虑投影裁边和会议软件的遮挡条）。

窗口框只承载界面、截图与录屏，纯 MG 直接放在画布上。镜头运动作用于整个画面：推、拉、横移时窗口框与内容一起变化；只有表现“在软件里放大或滚动”时，才只移动框内内容。

## PPT 原生页

`x-deck.ppt.layouts` 列出实际使用的版式（标题页、章节页、仅标题、图表＋说明等）及其占位符位置。原生页与相邻视频页的背景、字号和主色要对得上。`nativeTransition` 写原生页之间默认用无转场、淡化还是平滑切换，以及适用范围。

## Elevation & Shapes

阴影、边框、圆角、线宽与图形角色（输入、处理主体、结果、路径）。需要景深或视差时写分层与运动关系；二维缩放不能证明存在真实三维视角。

## Components

只写实际采用的组件：token 引用、内部比例、内容上限、状态、进出动作与例外。

| 组件 | 静态接口 | 状态与运动 | 验证重点 |
| --- | --- | --- | --- |
| 卡片 | 背景、字阶、圆角、间距 | 成组进入 → 内部信息 → 停稳 | 行长、图标与标签关系 |
| 路径与节点 | 基础线与行动线的语义 | 绘制、对象传递、节点反馈的先后 | 轨迹不先跑完而对象还没动 |
| 窗口（可选） | 栏高、字号、图标、圆角联动 | 内容与包装分离 | 不裁切证据 |

## Motion

主体运动按意图／预备、主动作、接触或状态改变、跟随、停稳组织。单章的镜头轨迹与参数不自动变成系列默认。

- `curves`：出现、预备、传递、落位、过程（变形、生长等需要被看清的过程）与镜头运动分别记录。出现类曲线前段变化极快，用在变形上会让过程一闪而过。
- `beat.holdFramesMin`：每个 beat 末尾至少静止的帧数，保证切片接缝干净。
- `beat.motionStartDelayFrames`：下一 beat 从首帧之后多少帧开始运动。
- `calibration`：已确认样章的 fps、各阶段帧数、位移与验证范围。未知值保持待测；换 fps 时先换算成时间再换回帧。

## Exceptions & Evidence

固定项、变量和已确认的单章例外写入对应字段，包含版本、范围和确认依据，不自动升级为系列规则。静态确认不扩展为运动确认；本机打开正常不等于放映电脑上正常。
