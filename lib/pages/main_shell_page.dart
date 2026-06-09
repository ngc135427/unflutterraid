import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_slide.dart';
import '../widgets/gradient_button.dart';
import '../widgets/management_list_tile.dart';
import '../widgets/phone_frame.dart';
import '../widgets/server_icon.dart';
import 'detail_page.dart';

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
          _ShellHeader(index: _currentIndex),
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
          title: '容器列表',
          description: '在此查看和管理所有运行中的 Docker 容器。',
          items: [
            ManagementData(
              icon: Icons.layers,
              title: 'MediaServer',
              status: '运行中',
            ),
            ManagementData(
              icon: Icons.layers,
              title: 'FileSync',
              status: '已停止',
            ),
          ],
        );
      case 2:
        return const _ManagementPage(
          key: ValueKey('vm'),
          title: '虚拟机列表',
          description: '在此查看和管理所有虚拟机。',
          items: [
            ManagementData(
              icon: Icons.computer,
              title: 'Windows 10',
              status: '运行中',
            ),
            ManagementData(
              icon: Icons.computer,
              title: 'Ubuntu Server',
              status: '已停止',
            ),
          ],
        );
      case 3:
        return const _ManagementPage(
          key: ValueKey('share'),
          title: '共享列表',
          description: '在此查看和管理所有共享资源。',
          items: [
            ManagementData(
              icon: Icons.folder_shared,
              title: 'Movies',
              status: '公开',
            ),
            ManagementData(
              icon: Icons.folder_shared,
              title: 'Backup',
              status: '私有',
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

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final titles = ['服务器信息', 'Docker 管理', '虚拟机管理', '共享管理'];
    final subtitles = ['Media server', '容器运行状态', '虚拟化资源', '共享资源'];
    return SizedBox(
      height: 118,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              titles[index],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitles[index],
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.80),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SU',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Media server',
                        style: TextStyle(
                          color: AppTheme.textMedium,
                          fontSize: 16,
                        ),
                      ),
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
            const SizedBox(height: 24),
            const _ServerDetailRow(
              icon: Icons.devices,
              label: '型号',
              value: 'Custom',
            ),
            const _ServerDetailRow(
              icon: Icons.verified_user,
              label: '注册',
              value: 'Unraid OS Pro',
              highlight: 'Pro',
            ),
            const _ServerDetailRow(
              icon: Icons.schedule,
              label: '正常运行时间',
              value: '4 分钟',
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: '查看完整信息',
              icon: Icons.info_outline,
              onPressed: () => Navigator.of(context).pushNamed(
                DetailPage.routeName,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerDetailRow extends StatelessWidget {
  const _ServerDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.softLine)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                _DetailValue(value: value, highlight: highlight),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailValue extends StatelessWidget {
  const _DetailValue({required this.value, this.highlight});

  final String value;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    if (highlight == null || !value.contains(highlight!)) {
      return Text(
        value,
        style: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    final parts = value.split(highlight!);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: parts.first),
          TextSpan(
            text: highlight,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts.last),
        ],
      ),
      style: const TextStyle(
        color: AppTheme.textDark,
        fontSize: 16,
        fontWeight: FontWeight.w500,
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
  });

  final IconData icon;
  final String title;
  final String status;
}

class _ManagementPage extends StatelessWidget {
  const _ManagementPage({
    super.key,
    required this.title,
    required this.description,
    required this.items,
  });

  final String title;
  final String description;
  final List<ManagementData> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 82),
      child: FadeSlide(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                color: AppTheme.textMedium,
                fontSize: 16,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            for (final item in items)
              ManagementListTile(
                icon: item.icon,
                title: item.title,
                status: item.status,
              ),
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
