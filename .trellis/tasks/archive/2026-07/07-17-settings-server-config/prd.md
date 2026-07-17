# 设置页服务器配置中心

## Goal

在设置中集中查看/修改 Unraid 连接（地址、协议、API Key），支持**保存并重连**与**断开连接**，去掉「规划中」占位。

## Requirements

- R1. 设置 → 服务器配置：展示当前 `baseUrl` 与脱敏 API Key（若已连接）。
- R2. 可编辑域名/协议/API Key；可选记住我并写入 `LoginPreferences`。
- R3. 「保存并重连」：`checkConnection` 成功后进入新的 `MainShell`（清栈），失败显示错误。
- R4. 「断开连接」：返回登录页（清栈）。
- R5. 未连接时仍可打开设置（仅语言/主题）；连接区提示先登录或显示已保存凭据编辑。
- R6. zh/en 文案；analyze + test 通过。

## Acceptance Criteria

- [ ] 已登录进入设置可见真实服务器地址，不再是「规划中」toast。
- [ ] 修改 API Key/地址并重连成功后主页可用新连接。
- [ ] 断开后回到登录页。
- [ ] analyze + test green.

## Out of Scope

- File Browser 独立认证。
- 多服务器配置档案。
- 安全存储升级（Keychain）— 仍走现有 LoginPreferences。
