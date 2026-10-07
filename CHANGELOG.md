# Changelog

格式参考 [Keep a Changelog](https://keepachangelog.com/)，版本号遵循语义化版本。

## [0.1.0] - 2026-10-07

首次公开。

### Added
- 工作流文档（`docs/`）、阶段提示词（`prompts/`）、模板（`templates/`）。
- 脚本：`split-beats.sh`（按 beat 切片与接缝检查）、`pptx-autoplay.py`（自动播放与末帧图）、`motion-check.sh`（动态自检）。
- `tools/samples/接缝测试.pptx` 试放样例。
- `examples/DESIGN-apple-style.md` 通用 DESIGN 示例；`templates/DESIGN.template.md` 为主入口模板。
- Apache-2.0 许可证、`NOTICE`、`CONTRIBUTING.md`、第三方说明。

### Known limits
- 只在 macOS 与 PowerPoint for Mac 上验证；Windows、Keynote、WPS 未验证。
