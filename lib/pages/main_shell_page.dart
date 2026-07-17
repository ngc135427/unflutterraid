import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/unraid_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_slide.dart';
import '../widgets/gradient_button.dart';
import '../widgets/phone_frame.dart';
import '../widgets/server_icon.dart';
import 'album_page.dart';
import 'detail_page.dart';
import 'music_page.dart';
import 'settings_page.dart';

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
    final l10n = AppLocalizations.of(context);
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
                  top: 10,
                  right: 12,
                  child: _OpenSettingsButton(l10n: l10n),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AppBottomNav(
                    items: _navItems(l10n),
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

  List<BottomNavItem> _navItems(AppLocalizations l10n) {
    return [
      BottomNavItem(icon: Icons.home, label: l10n.navHome),
      BottomNavItem(icon: Icons.apps, label: l10n.navDocker),
      BottomNavItem(icon: Icons.computer, label: l10n.navVm),
      BottomNavItem(icon: Icons.folder_shared, label: l10n.navShare),
    ];
  }

  Widget _buildContent() {
    final dashboardFuture = _dashboardFuture;
    if (_apiClient == null || dashboardFuture == null) {
      final l10n = AppLocalizations.of(context);
      return _StateMessage(
        icon: Icons.link_off,
        title: l10n.notConnectedTitle,
        message: l10n.notConnectedMessage,
      );
    }

    return FutureBuilder<UnraidDashboard>(
      future: dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          final l10n = AppLocalizations.of(context);
          return _StateMessage(
            icon: Icons.cloud_sync,
            title: l10n.loadingServerTitle,
            message: l10n.loadingServerMessage,
          );
        }

        if (snapshot.hasError) {
          final l10n = AppLocalizations.of(context);
          return _StateMessage(
            icon: Icons.error_outline,
            title: l10n.readFailedTitle,
            message: snapshot.error.toString(),
            actionLabel: l10n.retry,
            onAction: _refreshDashboard,
          );
        }

        final dashboard = snapshot.data;
        if (dashboard == null) {
          final l10n = AppLocalizations.of(context);
          return _StateMessage(
            icon: Icons.inbox_outlined,
            title: l10n.noDataTitle,
            message: l10n.noDataMessage,
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
          type: 'docker',
          dashboard: dashboard,
          items: dashboard.dockerItems
              .map((item) => ManagementData.fromApi(item, Icons.layers))
              .toList(),
          apiClient: _apiClient,
        );
      case 2:
        return _ManagementPage(
          key: const ValueKey('vm'),
          type: 'vm',
          dashboard: dashboard,
          items: dashboard.vmItems
              .map((item) => ManagementData.fromApi(item, Icons.computer))
              .toList(),
          apiClient: _apiClient,
        );
      case 3:
        return _ManagementPage(
          key: const ValueKey('share'),
          type: 'share',
          dashboard: dashboard,
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
          apiClient: _apiClient,
          onEditIcon: _showIconPicker,
          onOpenDetails: () => _openDashboardDetails(dashboard),
          onOpenModule: (module) => _showDashboardModule(module, dashboard),
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

  void _openDashboardDetails(UnraidDashboard dashboard) {
    Navigator.of(context).pushNamed(
      DetailPage.routeName,
      arguments: dashboard,
    );
  }

  Future<void> _showDashboardModule(
    _DashboardModule module,
    UnraidDashboard dashboard,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DashboardModuleSheet(
        module: module,
        dashboard: dashboard,
      ),
    );
  }
}

enum _DashboardModule {
  notifications,
  disks,
  network,
  ups,
  plugins,
  security,
  cloud,
  logs,
}

class _OpenSettingsButton extends StatelessWidget {
  const _OpenSettingsButton({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: l10n.settingsOpenTooltip,
      onPressed: () => Navigator.of(context).pushNamed(SettingsPage.routeName),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        foregroundColor: AppTheme.primary,
        side: const BorderSide(color: AppTheme.softLine),
        shadowColor: Colors.black.withValues(alpha: 0.12),
        elevation: 3,
      ),
      icon: const Icon(Icons.settings),
    );
  }
}

class _ServerInfoPage extends StatelessWidget {
  const _ServerInfoPage({
    super.key,
    required this.iconVariant,
    required this.dashboard,
    required this.apiClient,
    required this.onEditIcon,
    required this.onOpenDetails,
    required this.onOpenModule,
  });

  final ServerIconVariant iconVariant;
  final UnraidDashboard dashboard;
  final UnraidApiClient? apiClient;
  final VoidCallback onEditIcon;
  final VoidCallback onOpenDetails;
  final ValueChanged<_DashboardModule> onOpenModule;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 86),
      child: FadeSlide(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ServerHeroCard(
              dashboard: dashboard,
              iconVariant: iconVariant,
              onEditIcon: onEditIcon,
            ),
            const SizedBox(height: 18),
            _HomeStatsGrid(dashboard: dashboard),
            const SizedBox(height: 18),
            GradientButton(
              label: AppLocalizations.of(context).viewFullInfo,
              icon: Icons.info_outline,
              onPressed: onOpenDetails,
            ),
            const SizedBox(height: 22),
            _SectionHeader(
              title: AppLocalizations.of(context).liveMetrics,
              trailing: 'metrics',
            ),
            const SizedBox(height: 10),
            _MetricPanel(dashboard: dashboard),
            const SizedBox(height: 22),
            _SectionHeader(
              title: AppLocalizations.of(context).arrayAndServices,
              trailing: 'array / services',
            ),
            const SizedBox(height: 10),
            _InfoCard(
              children: [
                _InfoPair(
                    label: AppLocalizations.of(context).arrayState,
                    value: dashboard.arrayState),
                _InfoPair(
                    label: AppLocalizations.of(context).arrayCapacity,
                    value: dashboard.arrayUsage),
                _InfoPair(
                  label: 'Parity',
                  value: dashboard.paritySummary.isEmpty
                      ? AppLocalizations.of(context).noParityTask
                      : dashboard.paritySummary,
                ),
                _InfoPair(
                    label: AppLocalizations.of(context).servicesOnline,
                    value: dashboard.servicesSummary),
              ],
            ),
            const SizedBox(height: 22),
            _SectionHeader(
              title: AppLocalizations.of(context).recentNotifications,
              trailingButton: TextButton(
                onPressed: () => onOpenModule(_DashboardModule.notifications),
                child: Text(AppLocalizations.of(context).all),
              ),
            ),
            const SizedBox(height: 10),
            _NotificationPreviewList(
              notifications: dashboard.notifications,
              warningCount: dashboard.notificationWarning,
              alertCount: dashboard.notificationAlert,
            ),
            const SizedBox(height: 22),
            _SectionHeader(
              title: AppLocalizations.of(context).extendedManagement,
              trailing: AppLocalizations.of(context).interfaceModules,
            ),
            const SizedBox(height: 10),
            _QuickModuleGrid(onOpenModule: onOpenModule),
            const SizedBox(height: 24),
            _HomeAppShortcuts(apiClient: apiClient),
          ],
        ),
      ),
    );
  }
}

class _ServerHeroCard extends StatelessWidget {
  const _ServerHeroCard({
    required this.dashboard,
    required this.iconVariant,
    required this.onEditIcon,
  });

  final UnraidDashboard dashboard;
  final ServerIconVariant iconVariant;
  final VoidCallback onEditIcon;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UNRAID SERVER',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dashboard.serverName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dashboard.serverDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textMedium,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _StatusChip(
                          label: dashboard.status,
                          severity: _severityFromStatus(dashboard.status),
                        ),
                        _StatusChip(label: dashboard.version),
                        if (dashboard.notificationTotal > 0)
                          _StatusChip(
                            label: AppLocalizations.of(context)
                                .notificationCount(dashboard.notificationTotal),
                            severity: dashboard.notificationAlert > 0
                                ? InfoSeverity.danger
                                : InfoSeverity.warning,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ServerIconView(variant: iconVariant, size: 96),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CompactActionButton(
                  icon: Icons.palette,
                  label: AppLocalizations.of(context).edit,
                  onPressed: onEditIcon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeStatsGrid extends StatelessWidget {
  const _HomeStatsGrid({required this.dashboard});

  final UnraidDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.34,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          icon: Icons.speed,
          label: 'CPU',
          value: '${(dashboard.cpuPercent * 100).toStringAsFixed(0)}%',
          subtitle: dashboard.cpuSummary,
          progress: dashboard.cpuPercent,
        ),
        _StatCard(
          icon: Icons.memory,
          label: AppLocalizations.of(context).memory,
          value: dashboard.memoryUsage.split('/').first.trim(),
          subtitle: dashboard.memoryUsage,
          progress: dashboard.memoryPercent,
        ),
        _StatCard(
          icon: Icons.dns,
          label: AppLocalizations.of(context).array,
          value: dashboard.arrayUsage.split('/').first.trim(),
          subtitle: dashboard.arrayUsage,
          progress: dashboard.arrayPercent,
        ),
        _StatCard(
          icon: Icons.campaign,
          label: AppLocalizations.of(context).notifications,
          value: dashboard.notificationTotal.toString(),
          subtitle: AppLocalizations.of(context).warningAlertCount(
              dashboard.notificationWarning, dashboard.notificationAlert),
          progress: dashboard.notificationTotal == 0
              ? 0
              : (dashboard.notificationWarning + dashboard.notificationAlert) /
                  dashboard.notificationTotal,
          severity: dashboard.notificationAlert > 0
              ? InfoSeverity.danger
              : dashboard.notificationWarning > 0
                  ? InfoSeverity.warning
                  : InfoSeverity.normal,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.progress,
    this.severity = InfoSeverity.normal,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final double progress;
  final InfoSeverity severity;

  @override
  Widget build(BuildContext context) {
    final color = severity == InfoSeverity.normal
        ? _progressColor(progress)
        : _severityColor(severity);
    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(icon, color: AppTheme.textLight, size: 19),
            ],
          ),
          Text(
            value.isEmpty ? AppLocalizations.of(context).unknown : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress.clamp(0, 1).toDouble(),
              backgroundColor: AppTheme.softLine,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 11,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailing,
    this.trailingButton,
  });

  final String title;
  final String? trailing;
  final Widget? trailingButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailingButton != null)
          trailingButton!
        else if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
          ),
      ],
    );
  }
}

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({required this.dashboard});

  final UnraidDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: [
          _MetricLine(
            icon: Icons.speed,
            label: AppLocalizations.of(context).cpuUsage,
            value: '${(dashboard.cpuPercent * 100).toStringAsFixed(1)}%',
            progress: dashboard.cpuPercent,
          ),
          const SizedBox(height: 10),
          _MetricLine(
            icon: Icons.storage,
            label: AppLocalizations.of(context).memory,
            value: dashboard.memoryUsage,
            progress: dashboard.memoryPercent,
          ),
          const SizedBox(height: 10),
          _MetricLine(
            icon: Icons.dns,
            label: AppLocalizations.of(context).array,
            value: dashboard.arrayUsage,
            progress: dashboard.arrayPercent,
          ),
          const SizedBox(height: 10),
          _InfoLine(
            icon: Icons.developer_board,
            label: AppLocalizations.of(context).motherboard,
            value: dashboard.baseboardSummary,
          ),
        ],
      ),
    );
  }
}

class _NotificationPreviewList extends StatelessWidget {
  const _NotificationPreviewList({
    required this.notifications,
    required this.warningCount,
    required this.alertCount,
  });

  final List<UnraidNotification> notifications;
  final int warningCount;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    final preview = notifications.take(3).toList();
    if (preview.isEmpty) {
      return _SurfaceCard(
        child: Row(
          children: [
            _IconBadge(
                icon: Icons.check_circle, severity: InfoSeverity.success),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context).noWarningAlerts,
                style: TextStyle(color: AppTheme.textMedium, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (final notification in preview)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _NoticeTile(notification: notification),
          ),
      ],
    );
  }
}

class _QuickModuleGrid extends StatelessWidget {
  const _QuickModuleGrid({required this.onOpenModule});

  final ValueChanged<_DashboardModule> onOpenModule;

  @override
  Widget build(BuildContext context) {
    const modules = [
      _DashboardModule.disks,
      _DashboardModule.network,
      _DashboardModule.ups,
      _DashboardModule.plugins,
      _DashboardModule.security,
      _DashboardModule.cloud,
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final module in modules)
          _QuickModuleCard(
            module: module,
            onTap: () => onOpenModule(module),
          ),
      ],
    );
  }
}

class _QuickModuleCard extends StatelessWidget {
  const _QuickModuleCard({
    required this.module,
    required this.onTap,
  });

  final _DashboardModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final severity = _moduleSeverity(module);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: _SurfaceCard(
          padding: const EdgeInsets.all(11),
          child: Row(
            children: [
              _IconBadge(icon: _moduleIcon(module), severity: severity),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _moduleTitle(module, AppLocalizations.of(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _moduleSubtitle(module, AppLocalizations.of(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardModuleSheet extends StatelessWidget {
  const _DashboardModuleSheet({
    required this.module,
    required this.dashboard,
  });

  final _DashboardModule module;
  final UnraidDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final items = _moduleItems(module, dashboard);
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _IconBadge(
                    icon: _moduleIcon(module),
                    severity: _moduleSeverity(module),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _moduleTitle(module, AppLocalizations.of(context)),
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _moduleSubtitle(module, AppLocalizations.of(context)),
                          style: const TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (module == _DashboardModule.notifications)
                if (dashboard.notifications.isEmpty)
                  _StateMessage(
                    icon: _moduleIcon(module),
                    title:
                        AppLocalizations.of(context).noNotificationDetailsTitle,
                    message: AppLocalizations.of(context)
                        .noNotificationDetailsMessage,
                  )
                else
                  for (final notification in dashboard.notifications)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _NoticeTile(notification: notification),
                    )
              else if (items.isEmpty)
                _StateMessage(
                  icon: _moduleIcon(module),
                  title: AppLocalizations.of(context).noDataTitle,
                  message: AppLocalizations.of(context).moduleNoDataMessage(
                      _moduleTitle(module, AppLocalizations.of(context))),
                )
              else
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _InfoItemTile(item: item),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.softLine),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(children: children),
    );
  }
}

class _InfoPair extends StatelessWidget {
  const _InfoPair({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? AppLocalizations.of(context).unknown : value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color = AppTheme.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: const BorderSide(color: AppTheme.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    this.severity = InfoSeverity.normal,
  });

  final String label;
  final InfoSeverity severity;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label.isEmpty ? AppLocalizations.of(context).unknown : label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: severity == InfoSeverity.normal ? AppTheme.textMedium : color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({required this.notification});

  final UnraidNotification notification;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(
            icon: notification.severity == InfoSeverity.danger
                ? Icons.error_outline
                : Icons.warning_amber,
            severity: notification.severity,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  notification.description.isEmpty
                      ? notification.subject
                      : notification.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                if (notification.timestamp.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notification.timestamp,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItemTile extends StatelessWidget {
  const _InfoItemTile({required this.item});

  final UnraidInfoItem item;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _IconBadge(icon: Icons.info_outline, severity: item.severity),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 96),
            child: Text(
              item.value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.textMedium,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    this.severity = InfoSeverity.normal,
  });

  final IconData icon;
  final InfoSeverity severity;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(severity);
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

List<UnraidInfoItem> _moduleItems(
  _DashboardModule module,
  UnraidDashboard dashboard,
) {
  return switch (module) {
    _DashboardModule.notifications => const [],
    _DashboardModule.disks => dashboard.diskItems,
    _DashboardModule.network => dashboard.networkItems,
    _DashboardModule.ups => dashboard.upsItems,
    _DashboardModule.plugins => dashboard.pluginItems,
    _DashboardModule.security => dashboard.securityItems,
    _DashboardModule.cloud => dashboard.cloudItems,
    _DashboardModule.logs => dashboard.logItems,
  };
}

String _moduleTitle(_DashboardModule module, AppLocalizations l10n) {
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
}

IconData _moduleIcon(_DashboardModule module) {
  return switch (module) {
    _DashboardModule.notifications => Icons.notifications,
    _DashboardModule.disks => Icons.storage,
    _DashboardModule.network => Icons.settings_ethernet,
    _DashboardModule.ups => Icons.battery_charging_full,
    _DashboardModule.plugins => Icons.extension,
    _DashboardModule.security => Icons.vpn_key,
    _DashboardModule.cloud => Icons.cloud_done,
    _DashboardModule.logs => Icons.receipt_long,
  };
}

InfoSeverity _moduleSeverity(_DashboardModule module) {
  return switch (module) {
    _DashboardModule.ups => InfoSeverity.warning,
    _DashboardModule.security => InfoSeverity.danger,
    _DashboardModule.cloud => InfoSeverity.success,
    _ => InfoSeverity.normal,
  };
}

Color _severityColor(InfoSeverity severity) {
  return switch (severity) {
    InfoSeverity.normal => AppTheme.primary,
    InfoSeverity.success => AppTheme.success,
    InfoSeverity.warning => const Color(0xFFFF8A00),
    InfoSeverity.danger => AppTheme.danger,
  };
}

IconData _iconForInfoSeverity(InfoSeverity severity) {
  return switch (severity) {
    InfoSeverity.normal => Icons.info_outline,
    InfoSeverity.success => Icons.check_circle_outline,
    InfoSeverity.warning => Icons.warning_amber,
    InfoSeverity.danger => Icons.error_outline,
  };
}

InfoSeverity _severityFromStatus(String value) {
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
}

Color _progressColor(double progress) {
  if (progress >= 0.85) {
    return AppTheme.danger;
  }
  if (progress >= 0.65) {
    return const Color(0xFFFF8A00);
  }
  return AppTheme.primary;
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

class _HomeAppShortcuts extends StatelessWidget {
  const _HomeAppShortcuts({required this.apiClient});

  final UnraidApiClient? apiClient;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HomeAppShortcut(
          label: AppLocalizations.of(context).album,
          icon: Icons.photo_library,
          colors: const [AppTheme.primary, AppTheme.secondary],
          onTap: () {
            final client = apiClient;
            if (client == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(AppLocalizations.of(context).connectServerFirst)),
              );
              return;
            }
            Navigator.of(context).pushNamed(
              AlbumPage.routeName,
              arguments: AlbumPageArgs(
                apiClient: client,
                rootPath: '/mnt/user/photos',
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        _HomeAppShortcut(
          label: AppLocalizations.of(context).music,
          icon: Icons.music_note,
          colors: const [Color(0xFF3498DB), Color(0xFF52C41A)],
          onTap: () {
            final client = apiClient;
            if (client == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(AppLocalizations.of(context).connectServerFirst),
                ),
              );
              return;
            }
            Navigator.of(context).pushNamed(
              MusicPage.routeName,
              arguments: MusicPageArgs(apiClient: client),
            );
          },
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

class ManagementData {
  const ManagementData({
    required this.id,
    required this.icon,
    required this.title,
    required this.status,
    required this.description,
    required this.type,
    required this.progress,
    required this.tags,
    required this.details,
  });

  factory ManagementData.fromApi(UnraidManagementItem item, IconData icon) {
    return ManagementData(
      id: item.id,
      icon: icon,
      title: item.title,
      status: item.status,
      description: item.description,
      type: item.type,
      progress: item.progress,
      tags: item.tags,
      details: item.details,
    );
  }

  final String id;
  final IconData icon;
  final String title;
  final String status;
  final String description;
  final ManagementItemType type;
  final double progress;
  final List<String> tags;
  final List<UnraidInfoItem> details;
}

class _ManagementPage extends StatefulWidget {
  const _ManagementPage({
    super.key,
    required this.type,
    required this.dashboard,
    required this.items,
    required this.apiClient,
  });

  final String type;
  final UnraidDashboard dashboard;
  final List<ManagementData> items;
  final UnraidApiClient? apiClient;

  @override
  State<_ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<_ManagementPage> {
  final _searchController = TextEditingController();
  final Set<String> _submittingIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeLabel = switch (widget.type) {
      'docker' => l10n.navDocker,
      'vm' => l10n.navVm,
      _ => l10n.navShare,
    };
    final query = _searchController.text.trim().toLowerCase();
    final filteredItems = widget.items.where((item) {
      if (query.isEmpty) {
        return true;
      }
      return [
        item.title,
        item.status,
        item.description,
        ...item.tags,
      ].join(' ').toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 86),
      child: FadeSlide(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ManagementStats(type: widget.type, dashboard: widget.dashboard),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: l10n.searchTypeItems(typeLabel),
                      prefixIcon: const Icon(Icons.search),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _CompactActionButton(
                  icon: Icons.sync,
                  label: AppLocalizations.of(context).refresh,
                  onPressed: () =>
                      _showMessage(l10n.typeRefreshSubmitted(typeLabel)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final item in filteredItems)
              _ManagementCard(
                item: item,
                isSubmitting: _submittingIds.contains(item.id),
                onTap: () => _openDetail(item),
                onAction: item.type == ManagementItemType.share
                    ? null
                    : (action) => _runAction(item, action),
              ),
            if (widget.items.isEmpty)
              _StateMessage(
                icon: Icons.inbox_outlined,
                title: l10n.typeEmptyTitle(typeLabel),
                message: l10n.typeEmptyMessage(typeLabel),
              ),
            if (widget.items.isNotEmpty && filteredItems.isEmpty)
              _StateMessage(
                icon: Icons.search_off,
                title: AppLocalizations.of(context).noMatchesTitle,
                message: AppLocalizations.of(context).noMatchesMessage,
              ),
          ],
        ),
      ),
    );
  }

  void _openDetail(ManagementData item) {
    Navigator.of(context).pushNamed(
      ManagementDetailPage.routeName,
      arguments: ManagementDetailArgs(
        type: widget.type,
        data: item,
        apiClient: widget.apiClient,
      ),
    );
  }

  Future<void> _runAction(
    ManagementData item,
    ManagementAction action,
  ) async {
    final client = widget.apiClient;
    if (client == null || item.id.isEmpty) {
      _showMessage(AppLocalizations.of(context).missingConnectionOrId);
      return;
    }

    setState(() => _submittingIds.add(item.id));
    try {
      await client.runManagementAction(
        type: item.type,
        id: item.id,
        action: action,
      );
      if (!mounted) {
        return;
      }
      _showMessage(AppLocalizations.of(context)
          .actionSubmitted(item.title, _actionLabel(context, action)));
    } on UnraidApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _submittingIds.remove(item.id));
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

class _ManagementStats extends StatelessWidget {
  const _ManagementStats({
    required this.type,
    required this.dashboard,
  });

  final String type;
  final UnraidDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeLabel = switch (type) {
      'docker' => l10n.navDocker,
      'vm' => l10n.navVm,
      _ => l10n.navShare,
    };
    final items = switch (type) {
      'docker' => dashboard.dockerItems,
      'vm' => dashboard.vmItems,
      _ => dashboard.shareItems,
    };
    final running = items.where((item) => _isRunningStatus(item.status)).length;
    final secondary = switch (type) {
      'docker' => dashboard.dockerNetworkSummary,
      'vm' => l10n.runningAndStopped(running, items.length - running),
      _ => l10n.arrayUsageLabel(dashboard.arrayUsage),
    };
    final icon = switch (type) {
      'docker' => Icons.layers,
      'vm' => Icons.computer,
      _ => Icons.folder_shared,
    };
    final secondIcon = switch (type) {
      'docker' => Icons.hub,
      'vm' => Icons.memory,
      _ => Icons.move_down,
    };
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.72,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          icon: icon,
          label: typeLabel,
          value: items.length.toString(),
          subtitle: l10n.runningCount(running),
          progress: items.isEmpty ? 0 : running / items.length,
          severity: running == 0 && items.isNotEmpty
              ? InfoSeverity.warning
              : InfoSeverity.normal,
        ),
        _StatCard(
          icon: secondIcon,
          label: type == 'share' ? 'Mover' : l10n.overview,
          value: type == 'share' ? '02:00' : running.toString(),
          subtitle: secondary,
          progress: dashboard.arrayPercent,
        ),
      ],
    );
  }
}

class _ManagementCard extends StatelessWidget {
  const _ManagementCard({
    required this.item,
    required this.isSubmitting,
    required this.onTap,
    required this.onAction,
  });

  final ManagementData item;
  final bool isSubmitting;
  final VoidCallback onTap;
  final ValueChanged<ManagementAction>? onAction;

  @override
  Widget build(BuildContext context) {
    final running = _isRunningStatus(item.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: _SurfaceCard(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _IconBadge(
                      icon: item.icon,
                      severity:
                          running ? InfoSeverity.success : InfoSeverity.warning,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: item.status,
                      severity:
                          running ? InfoSeverity.success : InfoSeverity.warning,
                    ),
                  ],
                ),
                if (item.progress > 0) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      value: item.progress.clamp(0, 1).toDouble(),
                      backgroundColor: AppTheme.softLine,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progressColor(item.progress),
                      ),
                    ),
                  ),
                ],
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final tag in item.tags.take(4))
                        _StatusChip(label: tag),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                if (onAction == null)
                  Row(
                    children: [
                      Expanded(
                        child: _CompactActionButton(
                          icon: Icons.folder_open,
                          label: AppLocalizations.of(context).browse,
                          onPressed: onTap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CompactActionButton(
                          icon: Icons.tune,
                          label: AppLocalizations.of(context).settings,
                          onPressed: onTap,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _CompactActionButton(
                          icon: running ? Icons.restart_alt : Icons.play_arrow,
                          label: running
                              ? AppLocalizations.of(context).restart
                              : AppLocalizations.of(context).start,
                          onPressed: isSubmitting
                              ? null
                              : () => onAction!(
                                    running
                                        ? ManagementAction.restart
                                        : ManagementAction.start,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CompactActionButton(
                          icon: Icons.stop,
                          label: AppLocalizations.of(context).stop,
                          color: AppTheme.danger,
                          onPressed: isSubmitting
                              ? null
                              : () => onAction!(ManagementAction.stop),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CompactActionButton(
                          icon: Icons.visibility,
                          label: AppLocalizations.of(context).details,
                          onPressed: onTap,
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
}

bool _isRunningStatus(String value) {
  final lower = value.toLowerCase();
  return value.contains('运行') ||
      value.contains('在线') ||
      lower.contains('running') ||
      lower.contains('online') ||
      lower.contains('started');
}

String _actionLabel(BuildContext context, ManagementAction action) {
  final l10n = AppLocalizations.of(context);
  return switch (action) {
    ManagementAction.start => l10n.start,
    ManagementAction.stop => l10n.stop,
    ManagementAction.restart => l10n.restart,
  };
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
  bool _selecting = false;
  final Set<String> _selectedPaths = <String>{};
  bool _batchBusy = false;
  List<UnraidFileEntry> _lastShareEntries = const [];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final detailArgs = args is ManagementDetailArgs
        ? args
        : ManagementDetailArgs(
            type: 'share',
            data: ManagementData(
              id: '',
              icon: Icons.info,
              title: AppLocalizations.of(context).unknownProject,
              status: AppLocalizations.of(context).unknown,
              description: AppLocalizations.of(context).noInfo,
              type: ManagementItemType.share,
              progress: 0,
              tags: const [],
              details: const [],
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
                  label: Text(AppLocalizations.of(context).back),
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
                      label: AppLocalizations.of(context).status,
                      value: detailArgs.data.status,
                    ),
                    _DetailInfoRow(
                      icon: Icons.description_outlined,
                      label: AppLocalizations.of(context).description,
                      value: detailArgs.data.description,
                    ),
                    _DetailInfoRow(
                      icon: Icons.storage,
                      label: AppLocalizations.of(context).location,
                      value: detailArgs.data.type == ManagementItemType.share
                          ? '/mnt/user/${detailArgs.data.title}'
                          : detailArgs.data.title,
                    ),
                    for (final detail in detailArgs.data.details)
                      _DetailInfoRow(
                        icon: _iconForInfoSeverity(detail.severity),
                        label: detail.title,
                        value: detail.value.isEmpty
                            ? detail.description
                            : '${detail.value} · ${detail.description}',
                      ),
                  ],
                ),
                if (detailArgs.data.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final tag in detailArgs.data.tags)
                        _StatusChip(label: tag),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                _DetailPanel(
                  children: [
                    _ManagementActionButton(
                      icon: Icons.play_arrow,
                      label: AppLocalizations.of(context).start,
                      color: AppTheme.success,
                      onPressed: _isSubmitting
                          ? null
                          : () => _runAction(
                                detailArgs,
                                ManagementAction.start,
                                AppLocalizations.of(context).start,
                              ),
                    ),
                    const SizedBox(height: 10),
                    _ManagementActionButton(
                      icon: Icons.stop,
                      label: AppLocalizations.of(context).stop,
                      color: AppTheme.danger,
                      onPressed: _isSubmitting
                          ? null
                          : () => _runAction(
                                detailArgs,
                                ManagementAction.stop,
                                AppLocalizations.of(context).stop,
                              ),
                    ),
                    const SizedBox(height: 10),
                    _ManagementActionButton(
                      icon: Icons.refresh,
                      label: AppLocalizations.of(context).restart,
                      color: const Color(0xFF3498DB),
                      onPressed: _isSubmitting
                          ? null
                          : () => _runAction(
                                detailArgs,
                                ManagementAction.restart,
                                AppLocalizations.of(context).restart,
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
    final l10n = AppLocalizations.of(context);
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
                    onPressed: _batchBusy
                        ? null
                        : () {
                            if (_selecting) {
                              _exitSelection();
                            } else {
                              Navigator.of(context).maybePop();
                            }
                          },
                    icon: Icon(_selecting ? Icons.close : Icons.arrow_back),
                    label: Text(_selecting ? l10n.cancelSelection : l10n.back),
                  ),
                  const Spacer(),
                  if (_selecting) ...[
                    Text(
                      l10n.selectedCount(_selectedPaths.length),
                      style: const TextStyle(
                        color: AppTheme.textMedium,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.selectAll,
                      onPressed: _batchBusy
                          ? null
                          : () => _selectAllVisible(_lastShareEntries),
                      icon: const Icon(Icons.select_all),
                    ),
                    IconButton(
                      tooltip: l10n.batchMove,
                      onPressed: _batchBusy || _selectedPaths.isEmpty
                          ? null
                          : () => unawaited(_batchMove(args)),
                      icon: const Icon(Icons.drive_file_move_outline),
                    ),
                    IconButton(
                      tooltip: l10n.batchDelete,
                      onPressed: _batchBusy || _selectedPaths.isEmpty
                          ? null
                          : () => unawaited(_batchDelete(args)),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ] else ...[
                    IconButton(
                      tooltip: l10n.selectMode,
                      onPressed: _batchBusy
                          ? null
                          : () => setState(() => _selecting = true),
                      icon: const Icon(Icons.checklist),
                    ),
                    IconButton(
                      tooltip: l10n.refresh,
                      onPressed:
                          _batchBusy ? null : () => _openSharePath(currentPath),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ],
              ),
            ),
            if (_batchBusy)
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.batchBusy,
                      style: const TextStyle(
                        color: AppTheme.textMedium,
                        fontSize: 13,
                      ),
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
                    return _StateMessage(
                      icon: Icons.folder_open,
                      title: l10n.readingDirectoryTitle,
                      message: l10n.readingDirectoryMessage,
                    );
                  }

                  if (snapshot.hasError) {
                    return _StateMessage(
                      icon: Icons.error_outline,
                      title: l10n.readFailedTitle,
                      message: snapshot.error.toString(),
                      actionLabel: l10n.retry,
                      onAction: () => _openSharePath(currentPath),
                    );
                  }

                  final entries = snapshot.data ?? const <UnraidFileEntry>[];
                  _lastShareEntries = entries;
                  if (entries.isEmpty) {
                    return _StateMessage(
                      icon: Icons.inbox_outlined,
                      title: l10n.noShareDirectoryTitle,
                      message: l10n.noShareDirectoryMessage,
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                    children: [
                      if (_canGoUp(args))
                        _FileEntryTile(
                          icon: Icons.drive_folder_upload,
                          title: l10n.parentDirectory,
                          subtitle: _parentPath(currentPath),
                          onTap: _batchBusy
                              ? () {}
                              : () {
                                  _exitSelection();
                                  _openSharePath(_parentPath(currentPath));
                                },
                        ),
                      for (final entry in entries)
                        _FileEntryTile(
                          icon: entry.isDirectory
                              ? Icons.folder
                              : entry.isImage
                                  ? Icons.image
                                  : entry.isAudio
                                      ? Icons.music_note
                                      : Icons.insert_drive_file,
                          title: entry.name,
                          subtitle: entry.isDirectory
                              ? l10n.shareRootSize(entry.size)
                              : _fileSubtitle(entry),
                          selected: _selectedPaths.contains(entry.path),
                          selecting: _selecting,
                          onLongPress: _batchBusy
                              ? null
                              : () => _beginSelect(entry.path),
                          onTap: () {
                            if (_batchBusy) {
                              return;
                            }
                            if (_selecting) {
                              _toggleSelected(entry.path);
                              return;
                            }
                            if (entry.isDirectory) {
                              _openSharePath(entry.path);
                            } else if (entry.isImage) {
                              _previewImage(args, entry);
                            } else {
                              _showMessage(l10n.previewUnsupported);
                            }
                          },
                          onRename: _selecting || _batchBusy
                              ? null
                              : () => _renameEntry(args, entry),
                          onDelete: _selecting || _batchBusy
                              ? null
                              : () => _deleteEntry(args, entry),
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

  void _exitSelection() {
    setState(() {
      _selecting = false;
      _selectedPaths.clear();
    });
  }

  void _beginSelect(String path) {
    setState(() {
      _selecting = true;
      _selectedPaths.add(path);
    });
  }

  void _toggleSelected(String path) {
    setState(() {
      if (_selectedPaths.contains(path)) {
        _selectedPaths.remove(path);
      } else {
        _selectedPaths.add(path);
      }
    });
  }

  void _selectAllVisible(List<UnraidFileEntry> entries) {
    setState(() {
      _selecting = true;
      _selectedPaths
        ..clear()
        ..addAll(entries.map((entry) => entry.path));
    });
  }

  Future<void> _batchDelete(ManagementDetailArgs args) async {
    final client = args.apiClient;
    final l10n = AppLocalizations.of(context);
    if (client == null) {
      _showMessage(l10n.missingConnection);
      return;
    }
    final paths = _selectedPaths.toList(growable: false);
    if (paths.isEmpty) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.batchDeleteConfirmTitle),
        content: Text(l10n.batchDeleteConfirmMessage(paths.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _batchBusy = true);
    var success = 0;
    var failed = 0;
    for (final path in paths) {
      try {
        await client.fileManager.delete(path);
        success += 1;
      } catch (_) {
        failed += 1;
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _batchBusy = false;
      _selectedPaths.clear();
      _selecting = false;
    });
    _showMessage(l10n.batchResultSummary(success, 0, failed));
    _openSharePath(_sharePath ?? _shareRoot(args));
  }

  Future<void> _batchMove(ManagementDetailArgs args) async {
    final client = args.apiClient;
    final l10n = AppLocalizations.of(context);
    if (client == null) {
      _showMessage(l10n.missingConnection);
      return;
    }
    final paths = _selectedPaths.toList(growable: false);
    if (paths.isEmpty) {
      return;
    }

    final destination = await showDialog<String>(
      context: context,
      builder: (context) => _MoveDestinationDialog(
        apiClient: client,
        initialPath: _shareRoot(args),
      ),
    );
    if (destination == null || !mounted) {
      return;
    }

    setState(() => _batchBusy = true);
    var success = 0;
    var skipped = 0;
    var failed = 0;
    for (final path in paths) {
      final parent = _parentPath(path);
      if (parent == destination) {
        skipped += 1;
        continue;
      }
      if (UnraidFileManager.isInvalidMoveTarget(path, destination)) {
        skipped += 1;
        continue;
      }
      try {
        await client.fileManager.move(path, destination);
        success += 1;
      } catch (_) {
        failed += 1;
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _batchBusy = false;
      _selectedPaths.clear();
      _selecting = false;
    });
    _showMessage(l10n.batchResultSummary(success, skipped, failed));
    _openSharePath(_sharePath ?? _shareRoot(args));
  }

  Future<void> _runAction(
    ManagementDetailArgs args,
    ManagementAction action,
    String label,
  ) async {
    final client = args.apiClient;
    if (client == null || args.data.id.isEmpty) {
      _showMessage(AppLocalizations.of(context).missingConnectionOrId);
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
      _showMessage(AppLocalizations.of(context).labelActionSubmitted(label));
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
    _shareFuture = args.apiClient?.fileManager.listDirectory(root) ??
        Future<List<UnraidFileEntry>>.error(
            AppLocalizations.of(context).missingConnection);
  }

  void _openSharePath(String path) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final detailArgs = args is ManagementDetailArgs ? args : null;
    final client = detailArgs?.apiClient;
    if (client == null) {
      _showMessage(AppLocalizations.of(context).missingConnection);
      return;
    }
    setState(() {
      _sharePath = path;
      _shareFuture = client.fileManager.listDirectory(path);
      if (_selecting) {
        _selectedPaths.clear();
        _selecting = false;
      }
    });
  }

  bool _canGoUp(ManagementDetailArgs args) {
    final current = _sharePath ?? _shareRoot(args);
    return current != _shareRoot(args);
  }

  String _shareRoot(ManagementDetailArgs args) {
    return '/mnt/user';
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
    return parts.isEmpty
        ? AppLocalizations.of(context).file
        : parts.join(' · ');
  }

  Future<void> _previewImage(
    ManagementDetailArgs args,
    UnraidFileEntry entry,
  ) async {
    final client = args.apiClient;
    if (client == null) {
      _showMessage(AppLocalizations.of(context).missingConnection);
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

  Future<void> _renameEntry(
    ManagementDetailArgs args,
    UnraidFileEntry entry,
  ) async {
    final client = args.apiClient;
    final l10n = AppLocalizations.of(context);
    if (client == null) {
      _showMessage(l10n.missingConnection);
      return;
    }
    final controller = TextEditingController(text: entry.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.renameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || !mounted) {
      return;
    }
    if (newName.isEmpty) {
      _showMessage(l10n.renameEmptyError);
      return;
    }
    if (newName == entry.name) {
      return;
    }
    try {
      await client.fileManager.rename(entry.path, newName);
      if (!mounted) {
        return;
      }
      _showMessage(l10n.fileRenamed(newName));
      _openSharePath(_sharePath ?? _shareRoot(args));
    } on UnraidApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message);
    }
  }

  Future<void> _deleteEntry(
    ManagementDetailArgs args,
    UnraidFileEntry entry,
  ) async {
    final client = args.apiClient;
    final l10n = AppLocalizations.of(context);
    if (client == null) {
      _showMessage(l10n.missingConnection);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage(entry.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await client.fileManager.delete(entry.path);
      if (!mounted) {
        return;
      }
      _showMessage(l10n.fileDeleted(entry.name));
      _openSharePath(_sharePath ?? _shareRoot(args));
    } on UnraidApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message);
    }
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
    this.onLongPress,
    this.onRename,
    this.onDelete,
    this.selecting = false,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final bool selecting;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.08)
                : AppTheme.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.softLine,
            ),
          ),
          child: Row(
            children: [
              if (selecting) ...[
                Icon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 10),
              ],
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
              if (!selecting && (onRename != null || onDelete != null))
                PopupMenuButton<String>(
                  tooltip: l10n.moreActions,
                  onSelected: (value) {
                    if (value == 'rename') {
                      onRename?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onRename != null)
                      PopupMenuItem(
                        value: 'rename',
                        child: Text(l10n.rename),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.delete),
                      ),
                  ],
                )
              else if (!selecting) ...[
                const SizedBox(width: 10),
                Icon(
                  icon == Icons.image ? Icons.visibility : Icons.chevron_right,
                  color: AppTheme.textLight,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MoveDestinationDialog extends StatefulWidget {
  const _MoveDestinationDialog({
    required this.apiClient,
    required this.initialPath,
  });

  final UnraidApiClient apiClient;
  final String initialPath;

  @override
  State<_MoveDestinationDialog> createState() => _MoveDestinationDialogState();
}

class _MoveDestinationDialogState extends State<_MoveDestinationDialog> {
  late String _path;
  bool _loading = true;
  String? _error;
  List<UnraidFileEntry> _dirs = const [];

  @override
  void initState() {
    super.initState();
    _path = widget.initialPath;
    unawaited(_load(_path));
  }

  Future<void> _load(String path) async {
    setState(() {
      _loading = true;
      _error = null;
      _path = path;
    });
    try {
      final entries = await widget.apiClient.fileManager.listDirectory(path);
      if (!mounted) {
        return;
      }
      setState(() {
        _dirs = entries.where((entry) => entry.isDirectory).toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _goUp() {
    if (_path == '/mnt/user') {
      return;
    }
    final normalized = _path.endsWith('/') && _path.length > 1
        ? _path.substring(0, _path.length - 1)
        : _path;
    final index = normalized.lastIndexOf('/');
    final parent = index <= 0 ? '/mnt/user' : normalized.substring(0, index);
    unawaited(_load(parent.isEmpty ? '/mnt/user' : parent));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.selectMoveDestination),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _path,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textMedium,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            if (_path != '/mnt/user')
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.arrow_upward, color: AppTheme.primary),
                title: Text(l10n.goUp),
                onTap: _loading ? null : _goUp,
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.textMedium),
                          ),
                        )
                      : _dirs.isEmpty
                          ? Center(
                              child: Text(
                                l10n.noSubfolders,
                                style:
                                    const TextStyle(color: AppTheme.textMedium),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _dirs.length,
                              itemBuilder: (context, index) {
                                final entry = _dirs[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.folder,
                                    color: Color(0xFFFFD54F),
                                  ),
                                  title: Text(entry.name),
                                  onTap: () => unawaited(_load(entry.path)),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(_path),
          child: Text(l10n.moveHere),
        ),
      ],
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
                  tooltip: AppLocalizations.of(context).close,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Flexible(
            child: FutureBuilder(
              future: client.fileManager.readFileBytes(entry.path),
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
                      snapshot.error?.toString() ??
                          AppLocalizations.of(context).imageLoadFailed,
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
      title: Text(AppLocalizations.of(context).chooseServerIcon),
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
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: Text(AppLocalizations.of(context).confirm),
        ),
      ],
    );
  }
}
