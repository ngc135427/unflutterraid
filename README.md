# Unflutterraid

Unflutterraid 是一个使用 Flutter 构建的 Unraid 移动端/桌面端管理客户端。项目围绕 Unraid Connect/API 的 GraphQL 能力组织首页、Docker、虚拟机、共享目录和媒体入口，并使用一致的移动端视觉语言提供轻量、快速的服务器状态查看体验。

当前项目仍处于功能迭代阶段，核心管理面板已接入真实 API；相册页统一走 File Manager 能力层。当前 File Manager 仅通过 GraphQL 读取共享根目录，通用文件列表、缩略图和文件内容读取等待后续 GraphQL 文件管理能力补齐。

## 功能特性

### 服务器连接

- 支持 `http://` / `https://` 协议切换。
- 使用 Unraid API Key 连接 Unraid Connect/API。
- 登录表单包含基础校验、连接状态反馈和登录成功过渡。
- 支持“记住我”，在 Android 端通过原生 `SharedPreferences` 保存服务器地址、API Key 和协议偏好。

### 服务器主页

- 展示服务器名称、版本、运行状态和通知摘要。
- 展示 CPU、内存、磁盘、网络、UPS、云服务、插件、安全状态等概览信息。
- 支持服务器图标切换。
- 提供通知、磁盘、网络、UPS、插件、安全、云服务、日志等模块化详情面板。
- 提供相册、音乐等应用入口。

### Docker 与虚拟机管理

- 通过底部导航切换 Docker、虚拟机、共享目录。
- Docker/虚拟机列表支持搜索、状态展示、资源信息展示。
- 支持 Docker/虚拟机启动、停止、重启操作。
- 支持进入详情页查看分组信息和执行快捷操作。

### 共享目录

- 共享列表来自 Unraid GraphQL API。
- 共享详情页通过 GraphQL 读取 `/mnt/user` 下的共享根目录。
- 当前不提供子目录浏览、缩略图或文件内容预览；这部分归入 File Manager 后续迭代。

### 相册与媒体

- 相册、视频、相册分组和备份目录选择统一通过 File Manager 能力层访问。
- 当前 File Manager 只接入 GraphQL 共享根目录；递归媒体文件列表、缩略图和文件内容读取等待后续 GraphQL 文件管理能力。
- 提供照片备份设置界面，包括权限检测、Wi-Fi 限制、目标目录选择等 UI。

### 音乐页面

- 提供音乐库、歌曲列表和播放器页面。
- 当前音乐数据为前端静态示例，用于完善媒体应用体验。

## 技术栈

- Flutter / Dart
- Material Design
- `http`：访问 Unraid GraphQL API
- `permission_handler`：媒体权限检测
- Android MethodChannel：登录偏好原生持久化
- Flutter Widget Test：页面行为测试

## 架构概览

```text
lib/
  main.dart                         应用入口、路由注册
  pages/
    login_page.dart                 登录和连接配置
    main_shell_page.dart            主页、底部导航、管理列表、详情入口
    album_page.dart                 相册、视频、备份设置
    music_page.dart                 音乐库和播放器 UI
    detail_page.dart                服务器详情展示
    register_page.dart              注册页 UI
  services/
    unraid_api_client.dart          Unraid GraphQL 访问层和数据模型
                                    File Manager 根目录访问边界
    login_preferences.dart          登录偏好跨平台封装
  widgets/                          通用 UI 组件
  theme/                            主题、颜色和全局样式

android/
  app/src/main/kotlin/.../MainActivity.kt
                                    Android MethodChannel 实现

test/
  widget_test.dart                  登录页 Widget 测试
  unraid_api_client_test.dart       Unraid API 客户端行为测试
```

核心数据流：

```text
LoginPage
  -> UnraidApiClient.checkConnection()
  -> MainShellPage
  -> UnraidApiClient.fetchDashboard()
  -> 页面数据模型 UnraidDashboard / UnraidManagementItem / UnraidFileEntry
  -> 主页、Docker、虚拟机、共享、相册等页面渲染
```

管理操作数据流：

```text
管理列表/详情页
  -> runManagementAction(type, id, action)
  -> Docker / VM GraphQL mutation
  -> 刷新 Dashboard
```

## 运行要求

- Flutter SDK，Dart SDK `>=3.4.0 <4.0.0`
- Android Studio 或 Android SDK，构建 Android 时需要
- Visual Studio C++ Desktop workload，构建 Windows 时需要
- 可访问的 Unraid 服务器
- 已安装并启用 Unraid Connect/API 插件
- Unraid API Key

## 本地开发

```bash
flutter pub get
flutter run
```

指定平台运行：

```bash
flutter run -d windows
flutter run -d chrome
flutter run -d android
```

如果缺少平台目录，可以重新生成 Flutter 平台工程：

```bash
flutter create --platforms=android,ios,web,windows --project-name unflutterraid .
```

## 自构建

### Android APK

```bash
flutter build apk --release
```

产物位置：

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Windows

```bash
flutter build windows --release
```

产物位置：

```text
build/windows/x64/runner/Release/
```

### Web

```bash
flutter build web --release
```

产物位置：

```text
build/web/
```

Web 版本与其他平台一样只访问 Unraid GraphQL API。文件管理、缩略图和文件内容读取等待后续 File Manager GraphQL 能力，不通过 WebGUI 文件接口绕行。

## 测试与质量检查

运行全部测试：

```bash
flutter test
```

运行静态分析：

```bash
flutter analyze
```

格式化代码：

```bash
dart format lib test
```

当前测试覆盖：

- 登录页基础渲染和记住登录信息恢复。
- File Manager GraphQL 共享根目录读取、嵌套路径拒绝和文件内容读取边界。

## API 与权限说明

- Dashboard、Docker、虚拟机、共享列表等管理数据来自 Unraid GraphQL API。
- Docker/虚拟机操作通过 GraphQL mutation 执行。
- File Manager 当前只读取 GraphQL 暴露的 `/mnt/user` 共享根目录。
- 相册页整体通过 File Manager 实现；通用文件管理、递归目录浏览、相册缩略图和文件内容预览不依赖 WebGUI，后续通过 File Manager GraphQL 能力补齐。
- Android 相册备份页会请求照片/视频权限。
- 登录页只采集服务器地址和 API Key。

## 安全说明

- API Key 属于敏感凭据，请避免提交到仓库或公开日志。
- Android 端“记住我”当前使用 `SharedPreferences` 保存偏好，适合本地开发和个人设备使用；如面向生产发布，建议改为平台安全存储。
- 关机/重启等系统电源入口未在当前主页 UI 暴露。

## 路线图

- 完善 File Manager：GraphQL 文件列表、递归目录浏览、缩略图和文件内容读取。
- 将相册备份从 UI 原型推进到真实上传任务。
- 将音乐页面接入真实媒体库。
- 增加桌面端和 Android 端安装包发布流程。
- 扩展 Dashboard、Docker、虚拟机操作的测试覆盖。

## License

见 [LICENSE](LICENSE)。
