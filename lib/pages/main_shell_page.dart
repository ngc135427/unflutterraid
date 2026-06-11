import 'package:flutter/material.dart';

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

  static const _navItems = [
    BottomNavItem(icon: Icons.home, label: '主页'),
    BottomNavItem(icon: Icons.apps, label: 'Docker'),
    BottomNavItem(icon: Icons.computer, label: '虚拟机'),
    BottomNavItem(icon: Icons.folder_shared, label: '共享'),
  ];

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
                      child: _buildCurrentPage(),
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

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 1:
        return const _ManagementPage(
          key: ValueKey('docker'),
          type: 'Docker',
          items: [
            ManagementData(
              icon: Icons.layers,
              title: 'MediaServer',
              status: '运行中',
              description: '媒体服务容器',
            ),
            ManagementData(
              icon: Icons.layers,
              title: 'FileSync',
              status: '已停止',
              description: '文件同步容器',
            ),
          ],
        );
      case 2:
        return const _ManagementPage(
          key: ValueKey('vm'),
          type: '虚拟机',
          items: [
            ManagementData(
              icon: Icons.computer,
              title: 'Windows 10',
              status: '运行中',
              description: '桌面虚拟机',
            ),
            ManagementData(
              icon: Icons.computer,
              title: 'Ubuntu Server',
              status: '已停止',
              description: '服务器虚拟机',
            ),
          ],
        );
      case 3:
        return const _ManagementPage(
          key: ValueKey('share'),
          type: '共享',
          items: [
            ManagementData(
              icon: Icons.folder_shared,
              title: 'Movies',
              status: '公开',
              description: '媒体共享目录',
            ),
            ManagementData(
              icon: Icons.folder_shared,
              title: 'Backup',
              status: '私有',
              description: '备份共享目录',
            ),
          ],
        );
      default:
        return _ServerInfoPage(
          key: const ValueKey('server'),
          iconVariant: _serverIcon,
          onEditIcon: _showIconPicker,
          onPowerAction: _showPowerDialog,
        );
    }
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
    required this.onEditIcon,
    required this.onPowerAction,
  });

  final ServerIconVariant iconVariant;
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
                      const Text(
                        'SU',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Media server',
                        style: TextStyle(
                          color: AppTheme.textMedium,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _ServerInfoChips(),
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
  const _ServerInfoChips();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ServerInfoChip(icon: Icons.devices, label: '型号', value: 'Custom'),
        _ServerInfoChip(
          icon: Icons.verified_user,
          label: '注册',
          value: 'Pro',
        ),
        _ServerInfoChip(icon: Icons.schedule, label: '运行', value: '4 分钟'),
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
    required this.icon,
    required this.title,
    required this.status,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String status;
  final String description;
}

class _ManagementPage extends StatelessWidget {
  const _ManagementPage({
    super.key,
    required this.type,
    required this.items,
  });

  final String type;
  final List<ManagementData> items;

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
                    arguments: ManagementDetailArgs(type: type, data: item),
                  ),
                  child: ManagementListTile(
                    icon: item.icon,
                    title: item.title,
                    status: item.status,
                  ),
                ),
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
  });

  final String type;
  final ManagementData data;
}

class ManagementDetailPage extends StatelessWidget {
  const ManagementDetailPage({super.key});

  static const routeName = '/management-detail';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final detailArgs = args is ManagementDetailArgs
        ? args
        : const ManagementDetailArgs(
            type: '项目',
            data: ManagementData(
              icon: Icons.info,
              title: '未知项目',
              status: '未知',
              description: '暂无信息',
            ),
          );

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
                      value: detailArgs.type == '共享'
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
                      onPressed: () => _showAction(context, '启动'),
                    ),
                    const SizedBox(height: 10),
                    _ManagementActionButton(
                      icon: Icons.stop,
                      label: '停止',
                      color: AppTheme.danger,
                      onPressed: () => _showAction(context, '停止'),
                    ),
                    const SizedBox(height: 10),
                    _ManagementActionButton(
                      icon: Icons.refresh,
                      label: '重启',
                      color: const Color(0xFF3498DB),
                      onPressed: () => _showAction(context, '重启'),
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

  void _showAction(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action 操作已提交')),
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
  final VoidCallback onPressed;

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
