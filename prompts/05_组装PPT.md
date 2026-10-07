# 组装 PPT

```text
读取 docs/02_目录与工程.md 和 tools/README.md，使用你的 pptx 能力。
本份 deck：[目录路径]；页面表 v[__]；采用的切片目录：[每章 renders/C__v__beats 路径]。

在 05_PPT/build_deck.js 写构建脚本：
- 按页面表页序生成；原生页使用页面表所记 DESIGN 的主题、字体与版式。
- 视频页全幅嵌入对应 mp4，用 _first.png 作封面，上方叠对象名为 hold-last 的 _last.png，页面切换设为无。
- 每页演讲者备注写入讲稿对应段落。
- 同一脚本可输出静态备份版（用 _last.png 替换视频）。

生成后运行 tools/pptx-autoplay.py --hold-last 得到 _auto.pptx，做结构校验，在 PowerPoint 里打开核对页序、备注与文件大小。
交给我：_auto.pptx、备份版、构建命令，以及需要在放映电脑上验证的项目。
```

## 调整已有 PPT

```text
我在 PowerPoint 里改过 [文件路径]：[简述改了什么，或让你自己对比]。
读出与上一版构建输出的差异，写回 build_deck.js，重新生成并设置自动播放；不要直接改生成文件。
只复查受影响的页和相邻衔接。
```

```text
只换动效：[章号] 采用新渲染 [路径]。重新切片，确认接缝通过后重建 deck，复查受影响的页。
```
