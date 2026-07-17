# CI 与手动发布流水线

## Goal

在 GitHub Actions 上自动跑 analyze/test；提供手动触发的 Android+Web 打包工作流（产物上传 artifact，附校验和）。

## Requirements

- R1. `ci.yml`：main 的 push/PR → pub get、gen-l10n、analyze、test。
- R2. `release.yml`：workflow_dispatch，输入版本号，打 APK（split+universal）与 web zip，stage 到 dist 命名，SHA256SUMS，upload-artifact。
- R3. README 记录流水线用法与「未配置正式签名」限制。

## Acceptance

- [x] Workflow YAML 已加入仓库
- [x] README 文档
- [ ] 在 GitHub 上首次 push 后可见 Actions（运行时验证）

## Out of Scope

- Play 上传密钥 / 签名 secrets 全量接入
- Windows/macOS/Linux 桌面 CI 交叉编译
