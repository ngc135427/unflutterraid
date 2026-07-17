# Docker 日志 / 共享复制 / 多服务器档案

## Goal

1. Docker 详情可查看容器日志并打开 WebUI（交互 shell 诚实说明走 WebGUI/SSH）。
2. 共享多选支持复制到其他目录。
3. 多服务器档案：本地管理多台 Unraid 连接并一键切换。

## Acceptance

- [x] `fetchDockerLogs` + DockerLogsPage
- [x] `fileManager.copy` + 多选复制
- [x] ServerProfilesStore + 登录/设置入口
- [x] analyze + test green
