# 主页下拉刷新与 Docker/VM 操作后自动刷新

## Goal

用户可在主页/管理页下拉刷新服务器数据；Docker/VM 启停重启后列表与仪表盘自动更新，不必手动重进。

## Requirements

- R1. Home / Docker / VM / Share 列表页支持下拉刷新（`RefreshIndicator` + re-fetch dashboard）。
- R2. Docker/VM 列表内操作成功后自动刷新 dashboard。
- R3. 管理详情页操作成功后通知刷新（或返回列表时刷新）。
- R4. 管理页「刷新」按钮真正触发 fetch，不再仅 toast。
- R5. analyze + test 通过。

## Out of Scope

- WebSocket 实时推送。
- 共享文件浏览器内容的 dashboard 刷新以外的逻辑（share tab 仍刷新 share 元数据列表）。
