import 'package:flutter/material.dart';

import '../services/unraid_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_slide.dart';
import '../widgets/gradient_button.dart';
import '../widgets/management_list_tile.dart';
import '../widgets/phone_frame.dart';
import '../widgets/server_icon.dart';
import 'album_page.dart';
import 'detail_page.dart';
import 'music_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  static const routeName = '/home';

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;
  ServerIconVariant _serverIcon = ServerIconVariant.defaultIcon;
  UnraidApiClient? _apiClient;
  Future<UnraidDashboard>? _dashboardFuture;

  static const _navItems = [
    BottomNavItem(icon: Icons.home, label: '主页'),
    BottomNavItem(icon: Icons.apps, label: 'Docker'),
    BottomNavItem(icon: Icons.computer, label: '虚拟机'),
    BottomNavItem(icon: Icons.folder_shared, label: '共享'),
  ];

  @override
  void dispose() {
    _apiClient?.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_apiClient != null) {
      return;
    }
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is UnraidApiClient) {
      _apiClient = args;
      _dashboardFuture = args.fetchDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      maxContentWidth: 900,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildContent(),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AppBottomNav(
                    items: _navItems,
                    currentIndex: _currentIndex,
                    onChanged: (value) => setState(() => _currentIndex = value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final dashboardFuture = _dashboardFuture;
    if (_apiClient == null || dashboardFuture == null) {
      return const _StateMessage(
        icon: Icons.link_off,
        title: '未连接服务器',
        message: '请返回登录页重新连接。',
      );
    }

    return FutureBuilder<UnraidDashboard>(
      future: dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StateMessage(
            icon: Icons.cloud_sync,
            title: '正在读取服务器',
            message: '正在请求 Unraid GraphQL API...',
          );
        }

        if (snapshot.hasError) {
          return _StateMessage(
            icon: Icons.error_outline,
            title: '读取失败',
            message: snapshot.error.toString(),
            actionLabel: '重试',
            onAction: _refreshDashboard,
          );
        }

        final dashboard = snapshot.data;
        if (dashboard == null) {
          return const _StateMessage(
            icon: Icons.inbox_outlined,
            title: '暂无数据',
            message: '服务器没有返回可显示的数据。',
          );
        }

        return _buildCurrentPage(dashboard);
      },
    );
  }

  Widget _buildCurrentPage(UnraidDashboard dashboard) {
    switch (_currentIndex) {
      case 1:
        return _ManagementPage(
          key: const ValueKey('docker'),
          type: 'Docker',
          items: dashboard.dockerItems
              .map((item) => ManagementData.fromApi(item, Icons.layers))
              .toList(),
          apiClient: _apiClient,
        );
      case 2:
        return _ManagementPage(
          key: const ValueKey('vm'),
          type: '虚拟机',
          items: dashboard.vmItems
              .map((item) => ManagementData.fromApi(item, Icons.computer))
              .toList(),
          apiClient: _apiClient,
        );
      case 3:
        return _ManagementPage(
          key: const ValueKey('share'),
          type: '共享',
          items: dashboard.shareItems
              .map((item) => ManagementData.fromApi(item, Icons.folder_shared))
              .toList(),
          apiClient: _apiClient,
        );
      default:
        return _ServerInfoPage(
          key: const ValueKey('server'),
          iconVariant: _serverIcon,
          dashboard: dashboard,
          onEditIcon: _showIconPicker,
          onPowerAction: _showPowerDialog,
        );
    }
  }

  void _refreshDashboard() {
    final client = _apiClient;
    if (client == null) {
      return;
    }
    setState(() {
      _dashboardFuture = client.fetchDashboard();
    });
  }

  Future<void> _showIconPicker() async {
    final selected = await showDialog<ServerIconVariant>(
      context: context,
      builder: (context) => _IconPickerDialog(current: _serverIcon),
    );
    if (selected != null) {
      setState(() => _serverIcon = selected);
    }
  }

  Future<void> _showPowerDialog(String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认$action'),
        content: Text('确定要$action服务器吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('服务器正在$action...')),
      );
    }
  }
}

class _ServerInfoPage extends StatelessWidget {
  const _ServerInfoPage({
    super.key,
    required this.iconVariant,
    required this.dashboard,
    required this.onEditIcon,
    required this.onPowerAction,
  });

  final ServerIconVariant iconVariant;
  final UnraidDashboard dashboard;
  final VoidCallback onEditIcon;
  final ValueChanged<String> onPowerAction;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 82),
      child: FadeSlide(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dashboard.serverName,
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        dashboard.serverDescription,
                        style: TextStyle(
                          color: AppTheme.textMedium,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ServerInfoChips(dashboard: dashboard),
                      const SizedBox(height: 16),
                      _DashboardInfoPanel(dashboard: dashboard),
                    ],
                  ),
                ),
                SizedBox(
                  width: 126,
                  child: Column(
                    children: [
                      ServerIconView(variant: iconVariant, size: 120),
                      const SizedBox(height: 14),
                      _OutlineActionButton(
                        label: '编辑',
                        onPressed: onEditIcon,
                      ),
                      const SizedBox(height: 10),
                      _OutlineActionButton(
                        label: '关机',
                        icon: Icons.power_settings_new,
                        color: AppTheme.danger,
                        onPressed: () => onPowerAction('关闭'),
                      ),
                      const SizedBox(height: 10),
                      _OutlineActionButton(
                        label: '重启',
                        icon: Icons.refresh,
                        color: const Color(0xFF3498DB),
                        onPressed: () => onPowerAction('重启'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: '查看完整信息',
              icon: Icons.info_outline,
              onPressed: () => Navigator.of(context).pushNamed(
                DetailPage.routeName,
              ),
            ),
            const SizedBox(height: 28),
            const _HomeAppShortcuts(),
          ],
        ),
      ),
    );
  }
}

class _ServerInfoChips extends StatelessWidget {
  const _ServerInfoChips({required this.dashboard});

  final UnraidDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ServerInfoChip(
          icon: Icons.devices,
          label: '型号',
          value: dashboard.model,
        ),
        _ServerInfoChip(
          icon: Icons.verified_user,
          label: '版本',
          value: dashboard.version,
        ),
        _ServerInfoChip(
          icon: Icons.schedule,
          label: '运行',
          value: dashboard.uptime,
        ),
        _ServerInfoChip(
          icon: Icons.wifi_tethering,
          label: 'LAN',
          value: dashboard.lanIp,
        ),
      ],
    );
  }
}

class _DashboardInfoPanel extends StatelessWidget {
  const _DashboardInfoPanel({required this.dashboard});

  final UnraidDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoLine(
          icon: Icons.power,
          label: '状态',
          value: dashboard.status,
        ),
        const SizedBox(height: 8),
        _InfoLine(
          icon: Icons.memory,
          label: 'CPU',
          value: dashboard.cpuSummary,
        ),
        const SizedBox(height: 8),
        _MetricLine(
          icon: Icons.speed,
          label: 'CPU 使用',
          value: '${(dashboard.cpuPercent * 100).toStringAsFixed(1)}%',
          progress: dashboard.cpuPercent,
        ),
        const SizedBox(height: 8),
        _MetricLine(
          icon: Icons.storage,
          label: '内存',
          value: dashboard.memoryUsage,
          progress: dashboard.memoryPercent,
        ),
        const SizedBox(height: 8),
        _MetricLine(
          icon: Icons.dns,
          label: '阵列 ${dashboard.arrayState}',
          value: dashboard.arrayUsage,
          progress: dashboard.arrayPercent,
        ),
        const SizedBox(height: 8),
        _InfoLine(
          icon: Icons.developer_board,
          label: '主板',
          value: dashboard.baseboardSummary,
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 8),
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textMedium,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
  });

  final IconData icon;
  final String label;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final color = progress > 0.85
        ? AppTheme.danger
        : progress > 0.65
            ? const Color(0xFFFF8A00)
            : AppTheme.primary;
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 8),
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: progress,
              backgroundColor: AppTheme.softLine,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 74, maxWidth: 100),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppTheme.textMedium,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ServerInfoChip extends StatelessWidget {
  const _ServerInfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.softLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary, size: 15),
          const SizedBox(width: 5),
          Text(
            '$label $value',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textMedium,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAppShortcuts extends StatelessWidget {
  const _HomeAppShortcuts();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HomeAppShortcut(
          label: '相册',
          icon: Icons.photo_library,
          colors: const [AppTheme.primary, AppTheme.secondary],
          onTap: () => Navigator.of(context).pushNamed(AlbumPage.routeName),
        ),
        const SizedBox(width: 20),
        _HomeAppShortcut(
          label: '音乐',
          icon: Icons.music_note,
          colors: const [Color(0xFF3498DB), Color(0xFF52C41A)],
          onTap: () => Navigator.of(context).pushNamed(MusicPage.routeName),
        ),
      ],
    );
  }
}

class _HomeAppShortcut extends StatelessWidget {
  const _HomeAppShortcut({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Ink(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colors.first.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppTheme.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: const BorderSide(color: AppTheme.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class ManagementData {
  const ManagementData({
    required this.id,
    required this.icon,
    required this.title,
    required this.status,
    required this.description,
    required this.type,
  });

  factory ManagementData.fromApi(UnraidManagementItem item, IconData icon) {
    return ManagementData(
      id: item.id,
      icon: icon,
      title: item.title,
      status: item.status,
      description: item.description,
      type: item.type,
    );
  }

  final String id;
  final IconData icon;
  final String title;
  final String status;
  final String description;
  final ManagementItemType type;
}

class _ManagementPage extends StatelessWidget {
  const _ManagementPage({
    super.key,
    required this.type,
    required this.items,
    required this.apiClient,
  });

  final String type;
  final List<ManagementData> items;
  final UnraidApiClient? apiClient;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 82),
      child: FadeSlide(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.of(context).pushNamed(
                    ManagementDetailPage.routeName,
                    arguments: ManagementDetailArgs(
                      type: type,
                      data: item,
                      apiClient: apiClient,
                    ),
                  ),
                  child: ManagementListTile(
                    icon: item.icon,
                    title: item.title,
                    status: item.status,
                  ),
                ),
              ),
            if (items.isEmpty)
              _StateMessage(
                icon: Icons.inbox_outlined,
                title: '$type 为空',
                message: '服务器当前没有返回$type项目。',
              ),
          ],
        ),
      ),
    );
  }
}

class ManagementDetailArgs {
  const ManagementDetailArgs({
    required this.type,
    required this.data,
    required this.apiClient,
  });

  final String type;
  final ManagementData data;
  final UnraidApiClient? apiClient;
}

class ManagementDetailPage extends StatefulWidget {
  const ManagementDetailPage({super.key});

  static const routeName = '/management-detail';

  @override
  State<ManagementDetailPage> createState() => _ManagementDetailPageState();
}

class _ManagementDetailPageState extends State<ManagementDetailPage> {
  bool _isSubmitting = false;
  String? _sharePath;
  Future<List<UnraidFileEntry>>? _shareFuture;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final detailArgs = args is ManagementDetailArgs
        ? args
        : ManagementDetailArgs(
            type: '项目',
            data: ManagementData(
              id: '',
              icon: Icons.info,
              title: '未知项目',
              status: '未知',
              description: '暂无信息',
              type: ManagementItemType.share,
            ),
            apiClient: null,
          );

    if (detailArgs.data.type == ManagementItemType.share) {
      _ensureShareBrowser(detailArgs);
      return _buildShareBrowser(detailArgs);
    }

    return PhoneFrame(
      maxContentWidth: 900,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 8, 30, 30),
          child: FadeSlide(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        detailArgs.data.icon,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detailArgs.data.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            detailArgs.type,
                            style: const TextStyle(
                              color: AppTheme.textMedium,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _DetailPanel(
                  children: [
                    _DetailInfoRow(
                      icon: Icons.info_outline,
                      label: '状态',
                      value: detailArgs.data.status,
                    ),
                    _DetailInfoRow(
                      icon: Icons.description_outlined,
                      label: '说明',
                      value: detailArgs.data.description,
                    ),
                    _DetailInfoRow(
                      icon: Icons.storage,
                      label: '位置',
                      value: detailArgs.data.type == ManagementItemType.share
                          ? '/mnt/user/${detailArgs.data.title}'
                          : detailArgs.data.title,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _DetailPanel(
                  children: [
                    _ManagementActionButton(
                      icon: Icons.play_arrow,
                      label: '启动',
                      color: AppTheme.success,
                      onPressed: _isSubmitting
                          ? null
                          : () => _runAction(
                                detailArgs,
                                ManagementAction.start,
                                '启动',
                              ),
                    ),
                    const SizedBox(height: 10),
                    _ManagementActionButton(
                      icon: Icons.stop,
                      label: '停止',
                      color: AppTheme.danger,
                      onPressed: _isSubmitting
                          ? null
                          : () => _runAction(
                                detailArgs,
                                ManagementAction.stop,
                                '停止',
                              ),
                    ),
                    const SizedBox(height: 10),
                    _ManagementActionButton(
                      icon: Icons.refresh,
                      label: '重启',
                      color: const Color(0xFF3498DB),
                      onPressed: _isSubmitting
                          ? null
                          : () => _runAction(
                                detailArgs,
                                ManagementAction.restart,
                                '重启',
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareBrowser(ManagementDetailArgs args) {
    final currentPath = _sharePath ?? _shareRoot(args);
    return PhoneFrame(
      maxContentWidth: 900,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('返回'),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: '刷新',
                    onPressed: () => _openSharePath(currentPath),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.folder_shared,
                          color: AppTheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              args.data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentPath,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textMedium,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<UnraidFileEntry>>(
                future: _shareFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const _StateMessage(
                      icon: Icons.folder_open,
                      title: '正在读取目录',
                      message: '正在加载共享文件...',
                    );
                  }

                  if (snapshot.hasError) {
                    return _StateMessage(
                      icon: Icons.error_outline,
                      title: '读取失败',
                      message: snapshot.error.toString(),
                      actionLabel: '重试',
                      onAction: () => _openSharePath(currentPath),
                    );
                  }

                  final entries = snapshot.data ?? const <UnraidFileEntry>[];
                  if (entries.isEmpty) {
                    return const _StateMessage(
                      icon: Icons.inbox_outlined,
                      title: '目录为空',
                      message: '这里还没有可浏览的文件。',
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                    children: [
                      if (_canGoUp(args))
                        _FileEntryTile(
                          icon: Icons.drive_folder_upload,
                          title: '上一级',
                          subtitle: _parentPath(currentPath),
                          onTap: () => _openSharePath(_parentPath(currentPath)),
                        ),
                      for (final entry in entries)
                        _FileEntryTile(
                          icon: entry.isDirectory
                              ? Icons.folder
                              : entry.isImage
                                  ? Icons.image
                                  : Icons.insert_drive_file,
                          title: entry.name,
                          subtitle:
                              entry.isDirectory ? '文件夹' : _fileSubtitle(entry),
                          onTap: () {
                            if (entry.isDirectory) {
                              _openSharePath(entry.path);
                            } else if (entry.isImage) {
                              _previewImage(args, entry);
                            } else {
                              _showMessage('暂不支持预览该文件类型');
                            }
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runAction(
    ManagementDetailArgs args,
    ManagementAction action,
    String label,
  ) async {
    final client = args.apiClient;
    if (client == null || args.data.id.isEmpty) {
      _showMessage('缺少服务器连接或项目 ID');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await client.runManagementAction(
        type: args.data.type,
        id: args.data.id,
        action: action,
      );
      if (!mounted) {
        return;
      }
      _showMessage('$label 操作已提交');
    } on UnraidApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _ensureShareBrowser(ManagementDetailArgs args) {
    if (_sharePath != null && _shareFuture != null) {
      return;
    }
    final root = _shareRoot(args);
    _sharePath = root;
    _shareFuture = args.apiClient?.fetchDirectory(root) ??
        Future<List<UnraidFileEntry>>.error('缺少服务器连接');
  }

  void _openSharePath(String path) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final detailArgs = args is ManagementDetailArgs ? args : null;
    final client = detailArgs?.apiClient;
    if (client == null) {
      _showMessage('缺少服务器连接');
      return;
    }
    setState(() {
      _sharePath = path;
      _shareFuture = client.fetchDirectory(path);
    });
  }

  bool _canGoUp(ManagementDetailArgs args) {
    final current = _sharePath ?? _shareRoot(args);
    return current != _shareRoot(args);
  }

  String _shareRoot(ManagementDetailArgs args) {
    return '/mnt/user/${args.data.title}';
  }

  String _parentPath(String path) {
    final normalized = path.endsWith('/') && path.length > 1
        ? path.substring(0, path.length - 1)
        : path;
    final index = normalized.lastIndexOf('/');
    if (index <= 0) {
      return normalized;
    }
    return normalized.substring(0, index);
  }

  String _fileSubtitle(UnraidFileEntry entry) {
    final parts = [
      if (entry.size.isNotEmpty) entry.size,
      if (entry.modified.isNotEmpty) entry.modified,
    ];
    return parts.isEmpty ? '文件' : parts.join(' · ');
  }

  Future<void> _previewImage(
    ManagementDetailArgs args,
    UnraidFileEntry entry,
  ) async {
    final client = args.apiClient;
    if (client == null) {
      _showMessage('缺少服务器连接');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        child: _ImagePreview(client: client, entry: entry),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softLine),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementActionButton extends StatelessWidget {
  const _ManagementActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: const BorderSide(color: AppTheme.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _FileEntryTile extends StatelessWidget {
  const _FileEntryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.softLine),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                icon == Icons.image ? Icons.visibility : Icons.chevron_right,
                color: AppTheme.textLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.client,
    required this.entry,
  });

  final UnraidApiClient client;
  final UnraidFileEntry entry;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 860, maxHeight: 720),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '关闭',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Flexible(
            child: FutureBuilder(
              future: client.fetchFileBytes(entry.path),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      snapshot.error?.toString() ?? '图片加载失败',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.danger,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primary, size: 42),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMedium,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconPickerDialog extends StatefulWidget {
  const _IconPickerDialog({required this.current});

  final ServerIconVariant current;

  @override
  State<_IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<_IconPickerDialog> {
  late ServerIconVariant _selected = widget.current;

  @override
  Widget build(BuildContext context) {
    final variants = ServerIconVariant.values;
    return AlertDialog(
      title: const Text('选择服务器图标'),
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final variant in variants)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _selected = variant),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selected == variant
                        ? AppTheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ServerIconView(variant: variant, size: 72),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('确认'),
        ),
      ],
    );
  }
}
