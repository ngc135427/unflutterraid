#!/usr/bin/env python3
"""Apply AppLocalizations lookups across page files."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PAGES = ROOT / "lib" / "pages"


def ensure_import(text: str) -> str:
    needle = "import '../l10n/generated/app_localizations.dart';\n"
    if needle in text:
        return text
    # After first package:flutter import block, before relative imports if possible
    if "import 'package:flutter/material.dart';\n" in text:
        return text.replace(
            "import 'package:flutter/material.dart';\n",
            "import 'package:flutter/material.dart';\n\n"
            "import '../l10n/generated/app_localizations.dart';\n",
            1,
        )
    return needle + text


def patch_register(text: str) -> str:
    text = ensure_import(text)
    replacements = [
        (
            """  Widget build(BuildContext context) {
    return PhoneFrame(
      maxContentWidth: 520,
      child: Column(
        children: [
          const _RegisterHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(30, 38, 30, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: FadeSlide(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: '用户名 / 手机号',
                        controller: _usernameController,
                        hint: '请输入用户名或手机号',
                        icon: Icons.person,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return '请输入有效的用户名或手机号';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 21),
                      AppTextField(
                        label: '密码',
                        controller: _passwordController,
                        hint: '请输入密码（至少 6 位）',
                        obscureText: true,
                        icon: Icons.lock,
                        validator: (value) {
                          if ((value ?? '').length < 6) {
                            return '密码不能少于 6 位';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 21),
                      AppTextField(
                        label: '确认密码',
                        controller: _confirmPasswordController,
                        hint: '请再次输入密码',
                        obscureText: true,
                        icon: Icons.lock,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return '两次输入的密码不一致';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      GradientButton(
                        label: _registered ? '注册成功' : '注册',
                        icon: _registered ? Icons.check : null,
                        isSuccess: _registered,
                        onPressed: _registered ? null : _submit,
                      ),
                      const SizedBox(height: 22),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('已有账号？'),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('返回登录'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }""",
            """  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PhoneFrame(
      maxContentWidth: 520,
      child: Column(
        children: [
          const _RegisterHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(30, 38, 30, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: FadeSlide(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: l10n.registerUsernameLabel,
                        controller: _usernameController,
                        hint: l10n.registerUsernameHint,
                        icon: Icons.person,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return l10n.registerUsernameError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 21),
                      AppTextField(
                        label: l10n.registerPasswordLabel,
                        controller: _passwordController,
                        hint: l10n.registerPasswordHint,
                        obscureText: true,
                        icon: Icons.lock,
                        validator: (value) {
                          if ((value ?? '').length < 6) {
                            return l10n.registerPasswordError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 21),
                      AppTextField(
                        label: l10n.registerConfirmPasswordLabel,
                        controller: _confirmPasswordController,
                        hint: l10n.registerConfirmPasswordHint,
                        obscureText: true,
                        icon: Icons.lock,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return l10n.registerConfirmPasswordError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      GradientButton(
                        label: _registered
                            ? l10n.registerSuccess
                            : l10n.registerButton,
                        icon: _registered ? Icons.check : null,
                        isSuccess: _registered,
                        onPressed: _registered ? null : _submit,
                      ),
                      const SizedBox(height: 22),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(l10n.alreadyHaveAccount),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(l10n.backToLogin),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }""",
        ),
        (
            """  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '创建账号',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '请填写以下信息完成注册',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.80),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }""",
            """  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.createAccount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.registerSubtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.80),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }""",
        ),
    ]
    for old, new in replacements:
        if old not in text:
            print("register WARN missing block")
        else:
            text = text.replace(old, new)
    return text


def patch_music(text: str) -> str:
    text = ensure_import(text)
    simple = [
        ("title: '音乐'", "title: AppLocalizations.of(context).music"),
        ("title: '歌曲'", "title: AppLocalizations.of(context).songs"),
        (
            """          const Text(
            '音乐库',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),""",
            """          Text(
            AppLocalizations.of(context).musicLibrary,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),""",
        ),
        (
            """          const Text(
            '全部歌曲',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),""",
            """          Text(
            AppLocalizations.of(context).allSongs,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),""",
        ),
        (
            """                    label: const Text(
                      '收起',
                      style: TextStyle(color: Colors.white),
                    ),""",
            """                    label: Text(
                      AppLocalizations.of(context).collapse,
                      style: const TextStyle(color: Colors.white),
                    ),""",
        ),
        (
            """                    label: const Text(
                      '返回',
                      style: TextStyle(color: Colors.white),
                    ),""",
            """                    label: Text(
                      AppLocalizations.of(context).back,
                      style: const TextStyle(color: Colors.white),
                    ),""",
        ),
        (
            """          _MusicStat(label: '歌曲', value: '286', onTap: onSongsTap),
          const _MusicStat(label: '专辑', value: '42'),
          const _MusicStat(label: '无损', value: '96'),""",
            """          _MusicStat(
            label: AppLocalizations.of(context).songs,
            value: '286',
            onTap: onSongsTap,
          ),
          _MusicStat(label: AppLocalizations.of(context).albums, value: '42'),
          _MusicStat(label: AppLocalizations.of(context).lossless, value: '96'),""",
        ),
        (
            """      child: const Row(
        children: [
          Icon(Icons.search, color: AppTheme.primary, size: 20),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              '搜索歌曲、专辑',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppTheme.textLight, fontSize: 14),
            ),
          ),
        ],
      ),""",
            """      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.primary, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              AppLocalizations.of(context).searchSongsAlbums,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
            ),
          ),
        ],
      ),""",
        ),
        (
            """          child: const Row(
            children: [
              Icon(Icons.play_circle_fill, color: Colors.white, size: 42),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '正在播放',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),""",
            """          child: Row(
            children: [
              const Icon(Icons.play_circle_fill, color: Colors.white, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).nowPlaying,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),""",
        ),
    ]
    for old, new in simple:
        if old not in text:
            print(f"music WARN: {old[:50]!r}")
        else:
            text = text.replace(old, new)
    return text


def patch_detail(text: str) -> str:
    text = ensure_import(text)
    # For detail page, many const constructors need non-const after l10n.
    mapping = {
        "'返回'": "l10n.back",
        "'产品详情'": "l10n.productDetails",
        "'查看完整信息'": "l10n.viewFullInfo",
        "'基本信息'": "l10n.basicInfo",
        "'这是一个详情页面示例，展示如何按照登录页面的设计风格创建移动端详情页。页面保持相同的紫蓝渐变、圆角设计和柔和动效，确保视觉一致性。'": "l10n.detailSampleBody",
        "'功能列表'": "l10n.featureList",
        "'支持响应式设计'": "l10n.featureResponsive",
        "'保持视觉一致性'": "l10n.featureVisualConsistency",
        "'优雅的动画效果'": "l10n.featureAnimations",
        "'清晰的信息层次'": "l10n.featureClearHierarchy",
        "'详细说明'": "l10n.detailedDescription",
        "'设计理念'": "l10n.designPhilosophy",
        "'延续登录页面的现代简约风格，以紫蓝渐变作为主视觉元素，创建统一且专业的用户体验。'": "l10n.designPhilosophyText",
        "'交互设计'": "l10n.interactionDesign",
        "'页面元素采用顺序淡入动画，增强层次感和用户体验，按钮包含清晰的点击反馈。'": "l10n.interactionDesignText",
        "'UI 元素'": "l10n.uiElements",
        "'采用大圆角设计增强现代感和友好度，适当的阴影提供层次感，合理的间距确保阅读舒适。'": "l10n.uiElementsText",
        "'确认操作'": "l10n.confirmAction",
        "'操作已确认'": "l10n.actionConfirmedTitle",
        "'这里可以接入实际业务逻辑。'": "l10n.actionConfirmedBody",
        "'知道了'": "l10n.gotIt",
        "'服务器资料'": "l10n.serverProfile",
        "'授权'": "l10n.authorization",
        "'状态'": "l10n.status",
        "'硬件与系统'": "l10n.hardwareAndSystem",
        "'型号'": "l10n.model",
        "'主板'": "l10n.motherboard",
        "'系统'": "l10n.system",
        "'包版本'": "l10n.packageVersion",
        "'阵列与存储'": "l10n.arrayAndStorage",
        "'阵列'": "l10n.array",
        "'暂无校验任务'": "l10n.noParityTask",
        "'磁盘'": "l10n.disk",
        "'共享'": "l10n.navShare",
        "'网络与连接'": "l10n.networkAndConnection",
        "'本地 URL'": "l10n.localUrl",
        "'远程 URL'": "l10n.remoteUrl",
        "'Docker 网络'": "l10n.dockerNetwork",
        "'端口冲突'": "l10n.portConflicts",
        "'Cloud / 插件 / 权限'": "l10n.cloudPluginsPermissions",
        "'插件'": "l10n.plugins",
        "'权限'": "l10n.permissions",
        "'日志'": "l10n.logs",
        "'返回主页'": "l10n.returnHome",
        "'未知'": "l10n.unknown",
    }

    # Inject l10n in both build methods
    if "final l10n = AppLocalizations.of(context);" not in text:
        text = text.replace(
            "  Widget build(BuildContext context) {\n    final args = ModalRoute.of(context)?.settings.arguments;",
            "  Widget build(BuildContext context) {\n    final l10n = AppLocalizations.of(context);\n    final args = ModalRoute.of(context)?.settings.arguments;",
            1,
        )
        text = text.replace(
            "  Widget build(BuildContext context) {\n    return PhoneFrame(\n      maxContentWidth: 900,\n      child: Column(\n        children: [\n          SizedBox(\n            height: 120,",
            "  Widget build(BuildContext context) {\n    final l10n = AppLocalizations.of(context);\n    return PhoneFrame(\n      maxContentWidth: 900,\n      child: Column(\n        children: [\n          SizedBox(\n            height: 120,",
            1,
        )

    for old, new in mapping.items():
        text = text.replace(old, new)

    # Fix count templates that may remain
    text = text.replace(
        "value: '${dashboard.diskItems.length} 个'",
        "value: l10n.countItems(dashboard.diskItems.length)",
    )
    text = text.replace(
        "value: '${dashboard.shareItems.length} 个'",
        "value: l10n.countItems(dashboard.shareItems.length)",
    )
    text = text.replace(
        "value: '${dashboard.pluginItems.length} 条记录'",
        "value: l10n.countRecords(dashboard.pluginItems.length)",
    )
    text = text.replace(
        "value: '${dashboard.logItems.length} 个文件'",
        "value: l10n.countFiles(dashboard.logItems.length)",
    )

    # Remove invalid const on widgets that now use l10n
    # Broad but useful: const Text(l10n. -> Text(l10n.
    text = text.replace("const Text(\n                      l10n.", "Text(\n                      l10n.")
    text = text.replace("const Text(\n                        l10n.", "Text(\n                        l10n.")
    text = text.replace("const Text(l10n.", "Text(l10n.")
    text = text.replace("child: const Text(l10n.", "child: Text(l10n.")
    text = text.replace("title: const Text(l10n.", "title: Text(l10n.")
    text = text.replace("content: const Text(l10n.", "content: Text(l10n.")
    text = text.replace("label: const Text(\n                      l10n.", "label: Text(\n                      l10n.")
    text = text.replace("const _DetailSection(", "_DetailSection(")
    text = text.replace("const _FeatureRow(label: l10n.", "_FeatureRow(label: l10n.")
    text = text.replace("const _InfoCard(", "_InfoCard(")
    text = text.replace("const _DataRow(", "_DataRow(")

    return text


def patch_main_shell(text: str) -> str:
    text = ensure_import(text)
    # Build content states
    reps = [
        (
            """      return const _StateMessage(
        icon: Icons.link_off,
        title: '未连接服务器',
        message: '请返回登录页重新连接。',
      );""",
            """      final l10n = AppLocalizations.of(context);
      return _StateMessage(
        icon: Icons.link_off,
        title: l10n.notConnectedTitle,
        message: l10n.notConnectedMessage,
      );""",
        ),
        (
            """          return const _StateMessage(
            icon: Icons.cloud_sync,
            title: '正在读取服务器',
            message: '正在请求 Unraid GraphQL API...',
          );""",
            """          final l10n = AppLocalizations.of(context);
          return _StateMessage(
            icon: Icons.cloud_sync,
            title: l10n.loadingServerTitle,
            message: l10n.loadingServerMessage,
          );""",
        ),
        (
            """          return _StateMessage(
            icon: Icons.error_outline,
            title: '读取失败',
            message: snapshot.error.toString(),
            actionLabel: '重试',
            onAction: _refreshDashboard,
          );""",
            """          final l10n = AppLocalizations.of(context);
          return _StateMessage(
            icon: Icons.error_outline,
            title: l10n.readFailedTitle,
            message: snapshot.error.toString(),
            actionLabel: l10n.retry,
            onAction: _refreshDashboard,
          );""",
        ),
        (
            """          return const _StateMessage(
            icon: Icons.inbox_outlined,
            title: '暂无数据',
            message: '服务器没有返回可显示的数据。',
          );""",
            """          final l10n = AppLocalizations.of(context);
          return _StateMessage(
            icon: Icons.inbox_outlined,
            title: l10n.noDataTitle,
            message: l10n.noDataMessage,
          );""",
        ),
        ("type: '虚拟机'", "type: AppLocalizations.of(context).navVm"),
        ("type: '共享'", "type: AppLocalizations.of(context).navShare"),
    ]
    for old, new in reps:
        if old not in text:
            print("main_shell WARN block", old[:40])
        else:
            text = text.replace(old, new)

    # Simple string replacements for remaining UI labels.
    # For methods that already have context, inject l10n usage via AppLocalizations.of(context)
    simple = {
        "'查看完整信息'": "AppLocalizations.of(context).viewFullInfo",
        "'实时指标'": "AppLocalizations.of(context).liveMetrics",
        "'阵列与服务'": "AppLocalizations.of(context).arrayAndServices",
        "'阵列状态'": "AppLocalizations.of(context).arrayState",
        "'阵列容量'": "AppLocalizations.of(context).arrayCapacity",
        "'暂无校验任务'": "AppLocalizations.of(context).noParityTask",
        "'服务在线'": "AppLocalizations.of(context).servicesOnline",
        "'最近通知'": "AppLocalizations.of(context).recentNotifications",
        "child: const Text('全部')": "child: Text(AppLocalizations.of(context).all)",
        "'扩展管理'": "AppLocalizations.of(context).extendedManagement",
        "'接口模块'": "AppLocalizations.of(context).interfaceModules",
        "'编辑'": "AppLocalizations.of(context).edit",
        "'内存'": "AppLocalizations.of(context).memory",
        "'阵列'": "AppLocalizations.of(context).array",
        "'通知'": "AppLocalizations.of(context).notifications",
        "'CPU 使用'": "AppLocalizations.of(context).cpuUsage",
        "'主板'": "AppLocalizations.of(context).motherboard",
        "'暂无警告或严重通知'": "AppLocalizations.of(context).noWarningAlerts",
        "'暂无通知详情'": "AppLocalizations.of(context).noNotificationDetailsTitle",
        "'服务器仅返回了通知数量，未返回警告或严重通知列表。'": "AppLocalizations.of(context).noNotificationDetailsMessage",
        "'通知中心'": "AppLocalizations.of(context).notificationCenter",
        "'磁盘'": "AppLocalizations.of(context).disk",
        "'网络'": "AppLocalizations.of(context).network",
        "'插件'": "AppLocalizations.of(context).plugins",
        "'权限'": "AppLocalizations.of(context).permissions",
        "'连接'": "AppLocalizations.of(context).connection",
        "'日志'": "AppLocalizations.of(context).logs",
        "'SMART / 分区 / 温度'": "AppLocalizations.of(context).moduleDisksSubtitle",
        "'接口 / 访问地址'": "AppLocalizations.of(context).moduleNetworkSubtitle",
        "'电量 / 负载 / 策略'": "AppLocalizations.of(context).moduleUpsSubtitle",
        "'安装任务 / 模块'": "AppLocalizations.of(context).modulePluginsSubtitle",
        "'远程访问 / Cloud'": "AppLocalizations.of(context).moduleCloudSubtitle",
        "'相册'": "AppLocalizations.of(context).album",
        "'请先连接服务器'": "AppLocalizations.of(context).connectServerFirst",
        "'音乐'": "AppLocalizations.of(context).music",
        "'刷新'": "AppLocalizations.of(context).refresh",
        "'没有匹配项'": "AppLocalizations.of(context).noMatchesTitle",
        "'换一个关键词试试。'": "AppLocalizations.of(context).noMatchesMessage",
        "'缺少服务器连接或项目 ID'": "AppLocalizations.of(context).missingConnectionOrId",
        "'概览'": "AppLocalizations.of(context).overview",
        "'浏览'": "AppLocalizations.of(context).browse",
        "'设置'": "AppLocalizations.of(context).settings",
        "'重启'": "AppLocalizations.of(context).restart",
        "'启动'": "AppLocalizations.of(context).start",
        "'停止'": "AppLocalizations.of(context).stop",
        "'详情'": "AppLocalizations.of(context).details",
        "'项目'": "AppLocalizations.of(context).project",
        "'未知项目'": "AppLocalizations.of(context).unknownProject",
        "'未知'": "AppLocalizations.of(context).unknown",
        "'暂无信息'": "AppLocalizations.of(context).noInfo",
        "'返回'": "AppLocalizations.of(context).back",
        "'状态'": "AppLocalizations.of(context).status",
        "'说明'": "AppLocalizations.of(context).description",
        "'位置'": "AppLocalizations.of(context).location",
        "'正在读取目录'": "AppLocalizations.of(context).readingDirectoryTitle",
        "'正在通过 GraphQL 读取共享根目录...'": "AppLocalizations.of(context).readingDirectoryMessage",
        "'暂无共享目录'": "AppLocalizations.of(context).noShareDirectoryTitle",
        "'GraphQL 没有返回共享根目录数据。'": "AppLocalizations.of(context).noShareDirectoryMessage",
        "'上一级'": "AppLocalizations.of(context).parentDirectory",
        "'子目录浏览将作为 File Manager 独立功能实现'": "AppLocalizations.of(context).subdirBrowseFuture",
        "'暂不支持预览该文件类型'": "AppLocalizations.of(context).previewUnsupported",
        "'缺少服务器连接'": "AppLocalizations.of(context).missingConnection",
        "'文件'": "AppLocalizations.of(context).file",
        "'关闭'": "AppLocalizations.of(context).close",
        "'图片加载失败'": "AppLocalizations.of(context).imageLoadFailed",
        "'选择服务器图标'": "AppLocalizations.of(context).chooseServerIcon",
        "'取消'": "AppLocalizations.of(context).cancel",
        "'确认'": "AppLocalizations.of(context).confirm",
    }
    for old, new in simple.items():
        text = text.replace(old, new)

    # Interpolated strings
    text = text.replace(
        "label: '${dashboard.notificationTotal} 条提醒'",
        "label: AppLocalizations.of(context).notificationCount(dashboard.notificationTotal)",
    )
    text = text.replace(
        "'${dashboard.notificationWarning} 警告 · ${dashboard.notificationAlert} 严重'",
        "AppLocalizations.of(context).warningAlertCount(dashboard.notificationWarning, dashboard.notificationAlert)",
    )
    text = text.replace(
        "value.isEmpty ? AppLocalizations.of(context).unknown : value",
        "value.isEmpty ? AppLocalizations.of(context).unknown : value",
    )
    text = text.replace(
        "message: '服务器没有返回${_moduleTitle(module)}相关信息。'",
        "message: AppLocalizations.of(context).moduleNoDataMessage(_moduleTitle(module, AppLocalizations.of(context)))",
    )
    text = text.replace(
        "hintText: '搜索${widget.type}项目'",
        "hintText: AppLocalizations.of(context).searchTypeItems(widget.type)",
    )
    text = text.replace(
        "_showMessage('${widget.type}刷新已提交')",
        "_showMessage(AppLocalizations.of(context).typeRefreshSubmitted(widget.type))",
    )
    text = text.replace(
        "title: '${widget.type}为空'",
        "title: AppLocalizations.of(context).typeEmptyTitle(widget.type)",
    )
    text = text.replace(
        "message: '服务器当前没有返回${widget.type}项目。'",
        "message: AppLocalizations.of(context).typeEmptyMessage(widget.type)",
    )
    text = text.replace(
        "_showMessage('${item.title} ${_actionLabel(action)}操作已提交')",
        "_showMessage(AppLocalizations.of(context).actionSubmitted(item.title, _actionLabel(context, action)))",
    )
    text = text.replace(
        "'虚拟机' => dashboard.vmItems",
        "AppLocalizations.of(context).navVm => dashboard.vmItems",
    )
    text = text.replace(
        "'虚拟机' => '$running 运行中 · ${items.length - running} 未运行'",
        "AppLocalizations.of(context).navVm => AppLocalizations.of(context).runningAndStopped(running, items.length - running)",
    )
    text = text.replace(
        "_ => '阵列 ${dashboard.arrayUsage}'",
        "_ => AppLocalizations.of(context).arrayUsageLabel(dashboard.arrayUsage)",
    )
    text = text.replace(
        "'虚拟机' => Icons.computer",
        "AppLocalizations.of(context).navVm => Icons.computer",
    )
    text = text.replace(
        "'虚拟机' => Icons.memory",
        "AppLocalizations.of(context).navVm => Icons.memory",
    )
    text = text.replace(
        "subtitle: '$running 运行中'",
        "subtitle: AppLocalizations.of(context).runningCount(running)",
    )
    text = text.replace(
        "label: type == '共享' ? 'Mover' : AppLocalizations.of(context).overview",
        "label: type == AppLocalizations.of(context).navShare ? 'Mover' : AppLocalizations.of(context).overview",
    )
    text = text.replace(
        "value: type == '共享' ? '02:00' : running.toString()",
        "value: type == AppLocalizations.of(context).navShare ? '02:00' : running.toString()",
    )
    text = text.replace(
        "label: running ? AppLocalizations.of(context).restart : AppLocalizations.of(context).start",
        "label: running ? AppLocalizations.of(context).restart : AppLocalizations.of(context).start",
    )
    # action labels helper
    text = text.replace(
        """String _actionLabel(ManagementAction action) {
  return switch (action) {
    ManagementAction.start => AppLocalizations.of(context).start,
    ManagementAction.stop => AppLocalizations.of(context).stop,
    ManagementAction.restart => AppLocalizations.of(context).restart,
  };
}""",
        """String _actionLabel(BuildContext context, ManagementAction action) {
  final l10n = AppLocalizations.of(context);
  return switch (action) {
    ManagementAction.start => l10n.start,
    ManagementAction.stop => l10n.stop,
    ManagementAction.restart => l10n.restart,
  };
}""",
    )
    # module title/subtitle need l10n param
    text = text.replace(
        """String _moduleTitle(_DashboardModule module) {
  return switch (module) {
    _DashboardModule.notifications => AppLocalizations.of(context).notificationCenter,
    _DashboardModule.disks => AppLocalizations.of(context).disk,
    _DashboardModule.network => AppLocalizations.of(context).network,
    _DashboardModule.ups => 'UPS',
    _DashboardModule.plugins => AppLocalizations.of(context).plugins,
    _DashboardModule.security => AppLocalizations.of(context).permissions,
    _DashboardModule.cloud => AppLocalizations.of(context).connection,
    _DashboardModule.logs => AppLocalizations.of(context).logs,
  };
}

String _moduleSubtitle(_DashboardModule module) {
  return switch (module) {
    _DashboardModule.notifications => 'overview',
    _DashboardModule.disks => AppLocalizations.of(context).moduleDisksSubtitle,
    _DashboardModule.network => AppLocalizations.of(context).moduleNetworkSubtitle,
    _DashboardModule.ups => AppLocalizations.of(context).moduleUpsSubtitle,
    _DashboardModule.plugins => AppLocalizations.of(context).modulePluginsSubtitle,
    _DashboardModule.security => 'API Key / OIDC',
    _DashboardModule.cloud => AppLocalizations.of(context).moduleCloudSubtitle,
    _DashboardModule.logs => 'logFiles',
  };
}""",
        """String _moduleTitle(_DashboardModule module, AppLocalizations l10n) {
  return switch (module) {
    _DashboardModule.notifications => l10n.notificationCenter,
    _DashboardModule.disks => l10n.disk,
    _DashboardModule.network => l10n.network,
    _DashboardModule.ups => 'UPS',
    _DashboardModule.plugins => l10n.plugins,
    _DashboardModule.security => l10n.permissions,
    _DashboardModule.cloud => l10n.connection,
    _DashboardModule.logs => l10n.logs,
  };
}

String _moduleSubtitle(_DashboardModule module, AppLocalizations l10n) {
  return switch (module) {
    _DashboardModule.notifications => 'overview',
    _DashboardModule.disks => l10n.moduleDisksSubtitle,
    _DashboardModule.network => l10n.moduleNetworkSubtitle,
    _DashboardModule.ups => l10n.moduleUpsSubtitle,
    _DashboardModule.plugins => l10n.modulePluginsSubtitle,
    _DashboardModule.security => 'API Key / OIDC',
    _DashboardModule.cloud => l10n.moduleCloudSubtitle,
    _DashboardModule.logs => 'logFiles',
  };
}""",
    )

    # Fix _isRunningStatus to also check English
    text = text.replace(
        """bool _isRunningStatus(String value) {
  return value.contains('运行') ||
      value.contains('在线') ||
      value.toLowerCase().contains('running') ||
      value.toLowerCase().contains('online') ||
      value.toLowerCase().contains('started');
}""",
        """bool _isRunningStatus(String value) {
  final lower = value.toLowerCase();
  return value.contains('运行') ||
      value.contains('在线') ||
      lower.contains('running') ||
      lower.contains('online') ||
      lower.contains('started');
}""",
    )

    # severity status Chinese words remain for matching formatted Chinese status; also English
    text = text.replace(
        """InfoSeverity _severityFromStatus(String value) {
  final lower = value.toLowerCase();
  if (lower.contains('在线') ||
      lower.contains('运行') ||
      lower.contains('started') ||
      lower.contains('online')) {
    return InfoSeverity.success;
  }
  if (lower.contains('警告') ||
      lower.contains('停止') ||
      lower.contains('paused')) {
    return InfoSeverity.warning;
  }
  if (lower.contains('错误') || lower.contains('离线') || lower.contains('异常')) {
    return InfoSeverity.danger;
  }
  return InfoSeverity.normal;
}""",
        """InfoSeverity _severityFromStatus(String value) {
  final lower = value.toLowerCase();
  if (lower.contains('在线') ||
      lower.contains('运行') ||
      lower.contains('online') ||
      lower.contains('running') ||
      lower.contains('started')) {
    return InfoSeverity.success;
  }
  if (lower.contains('警告') ||
      lower.contains('停止') ||
      lower.contains('warning') ||
      lower.contains('stopped') ||
      lower.contains('paused')) {
    return InfoSeverity.warning;
  }
  if (lower.contains('错误') ||
      lower.contains('离线') ||
      lower.contains('异常') ||
      lower.contains('error') ||
      lower.contains('offline') ||
      lower.contains('crash')) {
    return InfoSeverity.danger;
  }
  return InfoSeverity.normal;
}""",
    )

    # shareRootSize and labelActionSubmitted
    text = text.replace(
        "'共享根目录 · ${entry.size}'",
        "AppLocalizations.of(context).shareRootSize(entry.size)",
    )
    text = text.replace(
        "'$label 操作已提交'",
        "AppLocalizations.of(context).labelActionSubmitted(label)",
    )

    # Fix calls to _moduleTitle/_moduleSubtitle that need l10n
    # Common pattern: _moduleTitle(module) and _moduleSubtitle(module)
    text = text.replace(
        "_moduleTitle(module)",
        "_moduleTitle(module, AppLocalizations.of(context))",
    )
    text = text.replace(
        "_moduleSubtitle(module)",
        "_moduleSubtitle(module, AppLocalizations.of(context))",
    )
    # Avoid double wrap if already done in moduleNoDataMessage
    text = text.replace(
        "_moduleTitle(module, AppLocalizations.of(context), AppLocalizations.of(context))",
        "_moduleTitle(module, AppLocalizations.of(context))",
    )
    text = text.replace(
        "AppLocalizations.of(context).moduleNoDataMessage(_moduleTitle(module, AppLocalizations.of(context)))",
        "AppLocalizations.of(context).moduleNoDataMessage(_moduleTitle(module, AppLocalizations.of(context)))",
    )

    # const widgets broken by l10n
    text = text.replace(
        "const Expanded(\n              child: Text(\n                AppLocalizations.of(context).noWarningAlerts",
        "Expanded(\n              child: Text(\n                AppLocalizations.of(context).noWarningAlerts",
    )
    text = text.replace(
        "const SnackBar(content: Text(AppLocalizations.of(context).connectServerFirst))",
        "SnackBar(content: Text(AppLocalizations.of(context).connectServerFirst))",
    )
    text = text.replace("const Text(AppLocalizations.of(context).", "Text(AppLocalizations.of(context).")
    text = text.replace("label: const Text(AppLocalizations.of(context).", "label: Text(AppLocalizations.of(context).")
    text = text.replace("child: const Text(AppLocalizations.of(context).", "child: Text(AppLocalizations.of(context).")

    return text


def patch_album(text: str) -> str:
    text = ensure_import(text)
    # Keep section date format locale-aware using stable keys
    # Replace user-facing strings
    simple = {
        "'_error = '缺少连接参数'": "_error = AppLocalizations.of(context).missingConnectionArgs",
        "'_error = '加载失败：$e'": "_error = AppLocalizations.of(context).loadFailed(e.toString())",
        "title: '相册'": "title: AppLocalizations.of(context).album",
        "title: '视频'": "title: AppLocalizations.of(context).videos",
        "title: '照片备份'": "title: AppLocalizations.of(context).photoBackup",
        "child: const Text('重试')": "child: Text(AppLocalizations.of(context).retry)",
        "Text('没有找到照片'": "Text(AppLocalizations.of(context).noPhotosFound",
        "Text('没有找到相册目录'": "Text(AppLocalizations.of(context).noAlbumDirsFound",
        "Text('没有找到视频'": "Text(AppLocalizations.of(context).noVideosFound",
        "const SnackBar(content: Text('需要照片和视频权限才能进行备份'))": "SnackBar(content: Text(AppLocalizations.of(context).mediaPermissionRequiredBackup))",
        "const SnackBar(content: Text('请先连接服务器'))": "SnackBar(content: Text(AppLocalizations.of(context).connectServerFirst))",
        "'_browseError = '加载失败：$e'": "_browseError = AppLocalizations.of(context).loadFailed(e.toString())",
        "'取消'": "AppLocalizations.of(context).cancel",
        "'选择备份目录'": "AppLocalizations.of(context).selectBackupDirectory",
        "label: Text('选择此目录')": "label: Text(AppLocalizations.of(context).selectThisDirectory)",
        "'返回上级'": "AppLocalizations.of(context).goUp",
        "'此目录下没有子文件夹'": "AppLocalizations.of(context).noSubfolders",
        "title: '权限检查中...'": "title: AppLocalizations.of(context).permissionChecking",
        "subtitle: '正在检查照片和视频访问权限'": "subtitle: AppLocalizations.of(context).permissionCheckingSubtitle",
        "title: '需要媒体权限'": "title: AppLocalizations.of(context).needMediaPermission",
        "actionLabel: '授予权限'": "actionLabel: AppLocalizations.of(context).grantPermission",
        "title: '媒体权限'": "title: AppLocalizations.of(context).mediaPermission",
        "subtitle: '照片和视频访问权限已授予'": "subtitle: AppLocalizations.of(context).mediaPermissionGranted",
        "title: '自动备份'": "title: AppLocalizations.of(context).autoBackup",
        "subtitle: _permissionsOk ? '将手机照片同步到 Unraid 共享目录' : '请先授予媒体权限'": "subtitle: _permissionsOk ? AppLocalizations.of(context).autoBackupSubtitle : AppLocalizations.of(context).grantMediaFirst",
        "title: '目标目录'": "title: AppLocalizations.of(context).targetDirectory",
        "title: '仅 Wi-Fi 备份'": "title: AppLocalizations.of(context).wifiOnlyBackup",
        "subtitle: '避免使用移动网络上传'": "subtitle: AppLocalizations.of(context).wifiOnlyBackupSubtitle",
        "title: '充电时备份视频'": "title: AppLocalizations.of(context).chargeWhenBackupVideo",
        "subtitle: '减少后台同步对电量的影响'": "subtitle: AppLocalizations.of(context).chargeWhenBackupVideoSubtitle",
        "title: '上次同步'": "title: AppLocalizations.of(context).lastSync",
        "subtitle: '暂无同步记录'": "subtitle: AppLocalizations.of(context).noSyncRecord",
        "allGranted ? '照片备份已就绪' : '需要授权才能备份'": "allGranted ? AppLocalizations.of(context).photoBackupReady : AppLocalizations.of(context).needAuthToBackup",
        "allGranted ? '照片和视频将同步到 Unraid' : '请授予照片和视频访问权限以启用备份功能'": "allGranted ? AppLocalizations.of(context).photosVideosSyncToUnraid : AppLocalizations.of(context).grantPhotosVideosToEnable",
        "'返回'": "AppLocalizations.of(context).back",
        "'搜索照片、视频'": "AppLocalizations.of(context).searchPhotosVideos",
        "label: '全部照片'": "label: AppLocalizations.of(context).allPhotos",
        "label: '相册'": "label: AppLocalizations.of(context).album",
        "label: '视频'": "label: AppLocalizations.of(context).videos",
        "'照片备份'": "AppLocalizations.of(context).photoBackup",
        "'已开启 / 今天 09:42'": "AppLocalizations.of(context).backupEnabledSample",
        "'${group.count} 张'": "AppLocalizations.of(context).photoCount(group.count)",
    }
    for old, new in simple.items():
        # fix accidental leading quote typos in keys above
        old = old.lstrip("'") if old.startswith("'_") else old
        text = text.replace(old, new)

    # Fix error assignments more carefully
    text = text.replace(
        "_error = '缺少连接参数'",
        "_error = AppLocalizations.of(context).missingConnectionArgs",
    )
    text = text.replace(
        "_error = '加载失败：$e'",
        "_error = AppLocalizations.of(context).loadFailed(e.toString())",
    )
    text = text.replace(
        "_browseError = '加载失败：$e'",
        "_browseError = AppLocalizations.of(context).loadFailed(e.toString())",
    )

    # Date grouping: use stable English keys for sort, display localized
    # Replace grouping titles to use markers then display map
    text = text.replace("title = '未知日期'", "title = '__unknown__'")
    text = text.replace("title = '今天'", "title = '__today__'")
    text = text.replace("title = '昨天'", "title = '__yesterday__'")
    text = text.replace(
        "title = '${date.year}年${date.month}月'",
        "title = '__ym__${date.year}_${date.month}'",
    )
    text = text.replace("final sectionOrder = ['今天', '昨天']", "final sectionOrder = ['__today__', '__yesterday__']")
    text = text.replace(
        r"final match = RegExp(r'(\d{4})年(\d{1,2})月').firstMatch(title);",
        r"final match = RegExp(r'__ym__(\d+)_(\d+)').firstMatch(title);",
    )

    # missing permissions helper
    text = text.replace(
        """    if (!_photosGranted) missing.add('照片');
    if (!_videosGranted) missing.add('视频');
    return '缺少${missing.join('和')}访问权限';""",
        """    final l10n = AppLocalizations.of(context);
    if (!_photosGranted) missing.add(l10n.photos);
    if (!_videosGranted) missing.add(l10n.videos);
    return l10n.missingPermissionAccess(missing.join(l10n.andJoin));""",
    )

    # When rendering section title, map keys. Look for Text(section.title or section.title usage.
    # Add helper function if not present
    if "String _localizedSectionTitle" not in text:
        helper = '''
String _localizedSectionTitle(BuildContext context, String title) {
  final l10n = AppLocalizations.of(context);
  if (title == '__unknown__') return l10n.unknownDate;
  if (title == '__today__') return l10n.today;
  if (title == '__yesterday__') return l10n.yesterday;
  final match = RegExp(r'__ym__(\\d+)_(\\d+)').firstMatch(title);
  if (match != null) {
    return l10n.yearMonth(int.parse(match.group(1)!), int.parse(match.group(2)!));
  }
  return title;
}
'''
        text += "\n" + helper

    # Replace display of section titles - common patterns
    text = text.replace(
        "Text(\n                      section.title",
        "Text(\n                      _localizedSectionTitle(context, section.title)",
    )
    text = text.replace(
        "Text(section.title",
        "Text(_localizedSectionTitle(context, section.title)",
    )
    # title field in scaffold may still use Chinese already replaced

    # path name heuristics for backup/screenshot stay bilingual - fine

    text = text.replace("const Text(AppLocalizations.of(context).", "Text(AppLocalizations.of(context).")
    text = text.replace("child: const Text(AppLocalizations.of(context).", "child: Text(AppLocalizations.of(context).")
    text = text.replace("const SnackBar(content: Text(AppLocalizations.of(context).", "SnackBar(content: Text(AppLocalizations.of(context).")

    return text


def main() -> None:
    files = {
        "register_page.dart": patch_register,
        "music_page.dart": patch_music,
        "detail_page.dart": patch_detail,
        "main_shell_page.dart": patch_main_shell,
        "album_page.dart": patch_album,
    }
    for name, fn in files.items():
        path = PAGES / name
        original = path.read_text(encoding="utf-8")
        updated = fn(original)
        path.write_text(updated, encoding="utf-8")
        import re

        remaining = re.findall(r"'([^']*[\u4e00-\u9fff][^']*)'", updated)
        remaining += re.findall(r'"([^"]*[\u4e00-\u9fff][^"]*)"', updated)
        # allow bilingual match helpers
        remaining = [
            s
            for s in remaining
            if s
            not in {
                "运行",
                "在线",
                "警告",
                "停止",
                "错误",
                "离线",
                "异常",
                "照片",
                "视频",
                "备份",
                "截图",
            }
            and "contains(" not in s
        ]
        uniq = []
        for s in remaining:
            if s not in uniq:
                uniq.append(s)
        print(f"{name}: remaining {len(uniq)}")
        for s in uniq[:30]:
            print("  ", s)


if __name__ == "__main__":
    main()
