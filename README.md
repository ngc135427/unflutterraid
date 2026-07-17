# Unflutterraid

Unflutterraid 是一个使用 Flutter 构建的 Unraid 移动端/桌面端管理客户端。项目围绕 Unraid Connect/API 的 GraphQL 能力组织首页、Docker、虚拟机和共享元数据，并通过 File Browser API 承载文件浏览、相册媒体、缩略图和文件内容读取，提供轻量、快速的服务器状态查看与媒体入口体验。

当前项目仍处于功能迭代阶段，核心管理面板已接入真实 API；文件和媒体能力统一走 File Manager 能力层。File Manager 当前直接调用 File Browser API。

## 功能特性

### 服务器连接

- 支持 `http://` / `https://` 协议切换。
- 使用 Unraid API Key 连接 Unraid Connect/API。
- 登录表单保持简洁，仅包含 Unraid 地址、协议和 API Key，并提供基础校验、连接状态反馈和登录成功过渡。
- 支持“记住我”：API Key 写入平台安全存储（`flutter_secure_storage` / Keystore 等）；地址与协议等非敏感项使用本地偏好，并兼容迁移旧版 MethodChannel 存储。

### 服务器主页

- 展示服务器名称、版本、运行状态和通知摘要。
- 展示 CPU、内存、磁盘、网络、UPS、云服务、插件、安全状态等概览信息。
- 支持下拉刷新仪表盘与 Docker / 虚拟机 / 共享列表。
- 支持仪表盘定时自动刷新（默认 30s，可在设置中关闭或改间隔）。
- 支持服务器图标切换。
- 提供通知、磁盘、网络、UPS、插件、安全、云服务、日志等模块化详情面板；通知列表来自 GraphQL（只读）。
- 提供相册、音乐等应用入口。

### Docker 与虚拟机管理

- 通过底部导航切换 Docker、虚拟机、共享目录。
- Docker/虚拟机列表支持搜索、状态展示、资源信息展示。
- 支持 Docker/虚拟机启动、停止、重启操作；操作成功后自动刷新列表。
- 支持进入详情页查看分组信息和执行快捷操作（返回列表时同步刷新）。

### 共享目录

- 共享列表来自 Unraid GraphQL API。
- 共享详情页通过 File Manager 读取 `/mnt/user` 下的目录内容。
- 支持子目录进入、图片预览，以及重命名 / 删除（File Browser 写接口）。
- 支持新建文件夹、本机多文件上传。
- 支持多选批量删除与移动到其他目录（同名冲突跳过；禁止移入自身/子目录）。

### 相册与媒体

- 相册、视频、相册分组和备份目录选择统一通过 File Manager 能力层访问。
- File Manager 通过 File Browser API 获取递归媒体列表、相册缩略图和原始文件内容。
- 相册支持全屏滑动预览（左右翻页、双指缩放）。
- 照片备份（Android/iOS）：手动「立即备份」上传设备最近最多 50 张照片到所选 NAS 目录；同名跳过；支持进度/取消、Wi‑Fi 限制、上次同步记录与完成后的成功/跳过/失败明细。视频备份与后台守护进程仍属后续。

### 音乐页面

- 通过 File Manager `listAudio` 扫描默认路径 `/mnt/user/music` 下的音频文件（与相册视觉媒体扫描分离）。
- 支持歌曲列表、搜索过滤、播放队列（上一首 / 下一首 / 播完自动下一首）。
- 播放器通过 File Browser `raw` 流式 URL + `just_audio` 真实播放；失败时展示本地化错误并可重试。
- 支持跨页面迷你播放条（暂停/关闭；点按回到全屏播放器）。

### 国际化与主题

- 默认跟随系统语言；可在登录页下拉与设置页切换简体中文 / English / 跟随系统。
- 主题支持浅色 / 深色 / 跟随系统，设置页切换并持久化。
- 设置 → 服务器配置：查看当前连接、修改地址/协议/API Key 后保存并重连，或断开返回登录页。
- 设置 → 关于：版本号、AGPL 许可说明、API Key 登录方式与凭据存储说明（无应用内注册账号）。
- UI 文案走 `AppLocalizations`；服务层错误与映射文案走 `DisplayCopy`（由 `MaterialApp.builder` 按当前 locale 激活）。

## 技术栈

- Flutter / Dart
- Material Design 3
- `flutter_localizations` / `intl`：应用内中英文与系统语言
- `http`：访问 Unraid GraphQL API 和 File Browser API
- `shared_preferences`：语言与主题偏好
- `photo_manager` / `connectivity_plus`：相册备份权限、本地照片枚举与网络类型
- Android MethodChannel：登录偏好原生持久化
- Flutter Widget Test / MockClient 单元测试

## 架构概览

```text
lib/
  main.dart                         应用入口、locale/theme、DisplayCopy 激活、路由
  app_language_scope.dart           语言偏好 InheritedWidget
  app_theme_scope.dart              主题偏好 InheritedWidget
  l10n/                             ARB + 生成 AppLocalizations
  pages/
    login_page.dart                 登录、连接配置、登录前语言切换
    main_shell_page.dart            主页、导航、共享目录浏览/重命名/删除
    settings_page.dart              语言、主题等应用设置
    server_config_page.dart         服务器地址 / API Key、重连与断开
    album_page.dart                 相册、视频、备份设置
    music_page.dart                 音乐库（File Browser 音频扫描）
    detail_page.dart                服务器详情展示
    register_page.dart              注册页 UI
  services/
    unraid_api_client.dart          GraphQL + File Manager（读/写）
    display_copy.dart               服务层用户可见文案（随 locale 切换）
    language_preferences.dart       语言持久化
    theme_preferences.dart          主题持久化
    login_preferences.dart          登录偏好（MethodChannel）
  widgets/                          通用 UI 组件
  theme/                            浅色/深色 ThemeData

android/
  app/src/main/kotlin/.../MainActivity.kt
                                    Android MethodChannel 实现

test/
  widget_test.dart                  登录页与语言切换
  unraid_api_client_test.dart       File Browser 读/写与错误提示
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

文件与媒体数据流：

```text
共享详情 / 相册 / 备份目录选择
  -> UnraidApiClient.fileManager
  -> File Browser API
     GET /api/resources/<path>
     GET /api/resources/recursive/<path>
     GET /api/preview/<size>/<path>?inline=true
     GET /api/raw/<path>
  -> UnraidFileEntry / Uint8List
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
- 可访问的 File Browser 服务，默认按 Unraid 地址同主机 `8080` 端口推导
- File Browser 已通过匿名访问或反向代理完成认证，并将根目录映射到 `/mnt/user`

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

## 自构建与安装包发布

发布前建议先统一版本号并通过质量检查：

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

版本号来自 `pubspec.yaml` 的 `version: 0.0.1+1`，也可以在发布命令里显式指定：

```bash
flutter build <platform> --release --build-name 0.0.1 --build-number 1
```

Flutter 官方构建命令默认把产物写入 `build/`，不会自动写入 `dist/`。如果需要 GitHub Release 那样的统一资产列表，可以在构建后手动从 `build/` 复制或压缩到 `dist/`。

### Android 安装包

按架构拆分 APK 适合官网、网盘或 GitHub Release 分发，用户按设备 CPU 下载对应安装包：

```bash
flutter build apk --release --split-per-abi --build-name 0.0.1 --build-number 1
```

| Android 架构 | 适用设备 | 产物 |
|--------------|----------|------|
| `armeabi-v7a` | 32 位 ARM Android 设备 | `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` |
| `arm64-v8a` | 主流 64 位 ARM Android 手机、平板 | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` |
| `x86_64` | Android 模拟器、部分 ChromeOS / x86_64 设备 | `build/app/outputs/flutter-apk/app-x86_64-release.apk` |
| universal | 包含所有 Android ABI 的通用包 | `build/app/outputs/flutter-apk/app-release.apk` |

如果只需要某一个架构，可以使用 `--target-platform`：

```bash
flutter build apk --release --target-platform android-arm64 --build-name 0.0.1 --build-number 1
flutter build apk --release --target-platform android-arm --build-name 0.0.1 --build-number 1
flutter build apk --release --target-platform android-x64 --build-name 0.0.1 --build-number 1
```

发布到 Google Play 或支持 AAB 的渠道时使用 App Bundle，由渠道按用户设备下发对应架构：

```bash
flutter build appbundle --release --target-platform android-arm,android-arm64,android-x64 --build-name 0.0.1 --build-number 1
```

产物位置：

```text
build/app/outputs/bundle/release/app-release.aab
```

### 桌面端安装包

当前仓库已包含 `windows/`、`linux/` 和 `macos/` 平台目录。Windows 可以在当前 Windows 构建机上发布；Linux 和 macOS 需要切换到对应宿主系统或 CI runner 构建。

如果后续需要按 Flutter 官方模板刷新平台工程，可以在项目根目录运行：

```bash
flutter create --platforms=android,ios,web,windows,linux,macos --project-name unflutterraid --no-pub .
```

桌面端发布时要打包整个 release bundle 目录，不能只分发可执行文件；Flutter 运行库、插件 DLL / so / dylib 和资源文件都在 bundle 内。

#### Windows x64 / Arm64

```powershell
flutter build windows --release --build-name 0.0.1 --build-number 1
```

| 桌面架构 | 构建环境 | 产物目录 | 发布包 |
|----------|----------|----------|--------|
| `windows-x64` | Windows + Visual Studio C++ Desktop workload | `build/windows/x64/runner/Release/` | 手动压缩整个 `Release/` 目录 |
| `windows-arm64` | Windows on Arm64 + Visual Studio C++ Desktop workload | `build/windows/arm64/runner/Release/` | 手动压缩整个 `Release/` 目录 |

Flutter Windows 不按 Intel / AMD / Qualcomm 具体 CPU 型号拆包。`x64` 覆盖 Intel / AMD 64 位 Windows；`arm64` 覆盖 Windows on Arm 设备。Flutter 当前支持的 Windows 部署架构是 `x64` 和 `Arm64`，不包含 32 位 `x86`。

#### Linux

```bash
flutter build linux --release --target-platform linux-x64 --build-name 0.0.1 --build-number 1
```

Linux 交叉编译需要目标架构 sysroot；没有 sysroot 时建议在对应架构的 Linux 构建机上打包。

| 桌面架构 | 推荐构建环境 | 构建命令 | 产物目录 | 发布包 |
|----------|--------------|----------|----------|--------|
| `linux-x64` | x64 Linux | `flutter build linux --release --target-platform linux-x64` | `build/linux/x64/release/bundle/` | 手动压缩整个 `bundle/` 目录 |
| `linux-arm64` | arm64 Linux，或带 arm64 sysroot 的 Linux | `flutter build linux --release --target-platform linux-arm64 --target-sysroot <arm64-sysroot>` | `build/linux/arm64/release/bundle/` | 手动压缩整个 `bundle/` 目录 |
| `linux-riscv64` | riscv64 Linux，或带 riscv64 sysroot 的 Linux | `flutter build linux --release --target-platform linux-riscv64 --target-sysroot <riscv64-sysroot>` | `build/linux/riscv64/release/bundle/` | 手动压缩整个 `bundle/` 目录 |

#### macOS

macOS 需要在 macOS 构建机上构建和签名：

```bash
flutter build macos --release --build-name 0.0.1 --build-number 1
```

| 桌面架构 | 推荐构建环境 | 产物 | 发布包 |
|----------|--------------|------|--------|
| `macos-x64` | Intel macOS 构建机，或在 Xcode 中显式配置 x86_64 | `build/macos/Build/Products/Release/unflutterraid.app` | 手动压缩 `.app` |
| `macos-arm64` | Apple Silicon macOS 构建机，或在 Xcode 中显式配置 arm64 | `build/macos/Build/Products/Release/unflutterraid.app` | 手动压缩 `.app` |
| `macos-universal` | macOS + Xcode universal archive/signing 配置 | `build/macos/Build/Products/Release/unflutterraid.app` | 手动压缩 `.app` |

### 发布归档清单

1. 确认 `flutter analyze` 和 `flutter test` 通过。
2. 按目标平台和架构运行 Flutter 官方构建命令，产物默认生成在 `build/` 下。
3. 在真实设备或虚拟机上验证安装包可启动：Android 使用 `adb install`，Windows 运行 `unflutterraid.exe`，Linux 运行 `unflutterraid`，macOS 启动 `.app`。
4. 如果要发布到 GitHub Release 或自有下载页，再把需要上传的产物从 `build/` 复制或压缩到 `dist/`。
5. 为发布包生成 SHA256 校验值。
6. 创建 `v0.0.1` 这类版本标签，并上传发布包和校验文件。

Windows PowerShell 生成校验文件：

```powershell
Get-ChildItem dist -File | Where-Object Name -ne 'SHA256SUMS.txt' | ForEach-Object { "$((Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash)  $($_.Name)" } | Set-Content dist\SHA256SUMS.txt
```

Linux 生成校验文件：

```bash
cd dist
rm -f SHA256SUMS.txt
sha256sum * > SHA256SUMS.txt
```

macOS 生成校验文件：

```bash
cd dist
rm -f SHA256SUMS.txt
shasum -a 256 * > SHA256SUMS.txt
```

### Web

```bash
flutter build web --release
```

产物位置：

```text
build/web/
```

Web 版本与其他平台一样访问 Unraid GraphQL API 和 File Browser API。文件管理、缩略图和文件内容读取不通过 Unraid WebGUI 文件接口绕行。

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

### CI / 发布流水线

- **CI**（`.github/workflows/ci.yml`）：在 `main` 的 push / PR 上自动执行 `flutter pub get`、`gen-l10n`、`analyze`、`test`。
- **Release**（`.github/workflows/release.yml`）：GitHub Actions 手动触发（`workflow_dispatch`），打包 Android split/universal APK 与 Web zip，写入 `dist/` 风格产物并上传 artifact，附带 `SHA256SUMS.txt`。
- **Android 签名（可选）**：
  - 本地：复制 `android/key.properties.example` 为 `android/key.properties`（已 gitignore），填写 keystore 路径与密码后 `flutter build apk --release`。
  - CI：在仓库 Secrets 配置 `ANDROID_KEYSTORE_BASE64`、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`。未配置时 release 构建回退到 debug 签名，便于继续打通流水线。
- Windows 桌面包仍建议在 Windows 构建机本地打包（见上文桌面端章节）。

当前测试覆盖：

- 登录页基础渲染、语言切换到 English、记住登录信息恢复。
- File Browser 基础地址推导、目录列表、递归媒体过滤、原始文件读取、缩略图读取、删除、重命名和认证错误提示。

## API 与权限说明

- Dashboard、Docker、虚拟机、共享列表等管理数据来自 Unraid GraphQL API。
- Docker/虚拟机操作通过 GraphQL mutation 执行。
- File Manager 直接访问 File Browser API，默认从 Unraid URL 推导为同协议、同主机、`8080` 端口。
- File Browser 不在应用内单独登录；项目假设匿名访问已开启，或外部反向代理已经处理认证。
- 读：`GET /api/resources`、`/api/resources/recursive`、`/api/raw`、`/api/preview`。
- 写：`DELETE /api/resources/...`、`PATCH` 重命名；上传接口已预留（`uploadBytes`）。
- 相册与音乐页通过 File Manager 访问媒体；不依赖 Unraid WebGUI 文件接口。
- Android 相册备份页会请求照片/视频权限。
- 登录页只采集服务器地址和 API Key。

## 安全说明

- API Key 属于敏感凭据，请避免提交到仓库或公开日志。
- “记住我”将 API Key 存入 `flutter_secure_storage`（Android 使用加密 SharedPreferences / Keystore 路径）；keystore 与 `key.properties` 不得提交仓库。
- 关机/重启等系统电源入口未在当前主页 UI 暴露。

## 路线图

- 共享浏览写操作：重命名/删除/多选批量删除与移动（已完成 MVP）；拖拽移动后续。
- 音乐：真实音频流播放与播放队列（已完成 MVP）。
- 相册备份：手动「立即备份」照片上传（已完成 MVP）；视频与后台守护后续。
- Android 可选签名与 Release 流水线已支持；商店级 applicationId / Play 上传可继续完善。

## License

本项目使用 AGPL-3.0，见 [LICENSE](LICENSE)。
