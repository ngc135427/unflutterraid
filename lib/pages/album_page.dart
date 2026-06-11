import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/fade_slide.dart';
import '../widgets/phone_frame.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key});

  static const routeName = '/album';

  static const _sections = [
    _MediaSection(
      title: '今天',
      items: [
        _MediaItem(color: Color(0xFF6E8EFB), icon: Icons.photo),
        _MediaItem(color: Color(0xFFA777E3), icon: Icons.photo),
        _MediaItem(color: Color(0xFF52C41A), icon: Icons.photo),
      ],
    ),
    _MediaSection(
      title: '昨天',
      items: [
        _MediaItem(color: Color(0xFF3498DB), icon: Icons.photo),
        _MediaItem(color: Color(0xFFFF9F43), icon: Icons.photo),
        _MediaItem(color: Color(0xFF8A94A6), icon: Icons.photo),
      ],
    ),
    _MediaSection(
      title: '2026年6月',
      items: [
        _MediaItem(color: Color(0xFF6E8EFB), icon: Icons.photo),
        _MediaItem(color: Color(0xFF52C41A), icon: Icons.photo),
        _MediaItem(color: Color(0xFFA777E3), icon: Icons.photo),
        _MediaItem(color: Color(0xFF3498DB), icon: Icons.photo),
        _MediaItem(color: Color(0xFFFF9F43), icon: Icons.photo),
        _MediaItem(color: Color(0xFF8A94A6), icon: Icons.photo),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _AlbumScaffold(
      title: '相册',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AlbumNavStats(selected: _AlbumNavTarget.photos),
          const SizedBox(height: 16),
          _BackupEntry(
            onTap: () => Navigator.of(context).pushNamed(
              AlbumBackupPage.routeName,
            ),
          ),
          const SizedBox(height: 20),
          for (final section in _sections)
            _TimelineSection(section: section, isVideo: false),
        ],
      ),
    );
  }
}

class AlbumGroupsPage extends StatelessWidget {
  const AlbumGroupsPage({super.key});

  static const routeName = '/album-groups';

  static const _albums = [
    _AlbumGroup('家庭', '24 张', Color(0xFF6E8EFB), Icons.people),
    _AlbumGroup('旅行', '36 张', Color(0xFFA777E3), Icons.landscape),
    _AlbumGroup('截图', '18 张', Color(0xFF52C41A), Icons.screenshot),
    _AlbumGroup('Unraid', '12 张', Color(0xFF3498DB), Icons.dns),
    _AlbumGroup('电影海报', '20 张', Color(0xFFFF9F43), Icons.movie),
    _AlbumGroup('备份', '18 张', Color(0xFF8A94A6), Icons.cloud_done),
  ];

  @override
  Widget build(BuildContext context) {
    return _AlbumScaffold(
      title: '相册',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AlbumNavStats(selected: _AlbumNavTarget.groups),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _albums.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.18,
            ),
            itemBuilder: (context, index) => _AlbumGroupTile(
              group: _albums[index],
            ),
          ),
        ],
      ),
    );
  }
}

class AlbumVideosPage extends StatelessWidget {
  const AlbumVideosPage({super.key});

  static const routeName = '/album-videos';

  static const _sections = [
    _MediaSection(
      title: '今天',
      items: [
        _MediaItem(
            color: Color(0xFF6E8EFB), icon: Icons.movie, duration: '1:24'),
        _MediaItem(
            color: Color(0xFFA777E3), icon: Icons.movie, duration: '0:48'),
        _MediaItem(
            color: Color(0xFF52C41A), icon: Icons.movie, duration: '2:10'),
      ],
    ),
    _MediaSection(
      title: '2026年6月',
      items: [
        _MediaItem(
            color: Color(0xFF3498DB), icon: Icons.movie, duration: '3:42'),
        _MediaItem(
            color: Color(0xFFFF9F43), icon: Icons.movie, duration: '0:35'),
        _MediaItem(
            color: Color(0xFF8A94A6), icon: Icons.movie, duration: '4:08'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _AlbumScaffold(
      title: '视频',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AlbumNavStats(selected: _AlbumNavTarget.videos),
          const SizedBox(height: 20),
          for (final section in _sections)
            _TimelineSection(section: section, isVideo: true),
        ],
      ),
    );
  }
}

class AlbumBackupPage extends StatelessWidget {
  const AlbumBackupPage({super.key});

  static const routeName = '/album-backup';

  @override
  Widget build(BuildContext context) {
    return _AlbumScaffold(
      title: '照片备份',
      showSearchOnScroll: false,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BackupHeaderCard(),
          SizedBox(height: 18),
          _BackupSettingRow(
            icon: Icons.sync,
            title: '自动备份',
            subtitle: '将手机照片同步到 Unraid 共享目录',
            enabled: true,
          ),
          _BackupSettingRow(
            icon: Icons.folder_shared,
            title: '目标目录',
            subtitle: '/mnt/user/photos/mobile',
          ),
          _BackupSettingRow(
            icon: Icons.wifi,
            title: '仅 Wi-Fi 备份',
            subtitle: '避免使用移动网络上传',
            enabled: true,
          ),
          _BackupSettingRow(
            icon: Icons.battery_charging_full,
            title: '充电时备份视频',
            subtitle: '减少后台同步对电量的影响',
            enabled: false,
          ),
          _BackupSettingRow(
            icon: Icons.history,
            title: '上次同步',
            subtitle: '今天 09:42，同步 18 个项目',
          ),
        ],
      ),
    );
  }
}

enum _AlbumNavTarget { photos, groups, videos }

class _AlbumScaffold extends StatefulWidget {
  const _AlbumScaffold({
    required this.title,
    required this.child,
    this.showSearchOnScroll = true,
  });

  final String title;
  final Widget child;
  final bool showSearchOnScroll;

  @override
  State<_AlbumScaffold> createState() => _AlbumScaffoldState();
}

class _AlbumScaffoldState extends State<_AlbumScaffold> {
  late final ScrollController _scrollController;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!widget.showSearchOnScroll) {
      return;
    }
    final shouldShowSearch = _scrollController.offset > 24;
    if (shouldShowSearch != _showSearch) {
      setState(() => _showSearch = shouldShowSearch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      maxContentWidth: 900,
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      '返回',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 112),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _showSearch
                          ? const _AlbumHeaderSearch(key: ValueKey('search'))
                          : Text(
                              widget.title,
                              key: const ValueKey('title'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(30, 12, 30, 30),
                child: FadeSlide(
                  child: _FramedAlbumBody(child: widget.child),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumHeaderSearch extends StatelessWidget {
  const _AlbumHeaderSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.primary, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '搜索照片、视频',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textLight.withValues(alpha: 0.92),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FramedAlbumBody extends StatelessWidget {
  const _FramedAlbumBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.softLine),
      ),
      child: child,
    );
  }
}

class _AlbumNavStats extends StatelessWidget {
  const _AlbumNavStats({required this.selected});

  final _AlbumNavTarget selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _AlbumNavItem(
            label: '全部照片',
            value: '128',
            selected: selected == _AlbumNavTarget.photos,
            onTap: selected == _AlbumNavTarget.photos
                ? null
                : () => Navigator.of(context).pushReplacementNamed(
                      AlbumPage.routeName,
                    ),
          ),
          _AlbumNavItem(
            label: '相册',
            value: '6',
            selected: selected == _AlbumNavTarget.groups,
            onTap: selected == _AlbumNavTarget.groups
                ? null
                : () => Navigator.of(context).pushReplacementNamed(
                      AlbumGroupsPage.routeName,
                    ),
          ),
          _AlbumNavItem(
            label: '视频',
            value: '12',
            selected: selected == _AlbumNavTarget.videos,
            onTap: selected == _AlbumNavTarget.videos
                ? null
                : () => Navigator.of(context).pushReplacementNamed(
                      AlbumVideosPage.routeName,
                    ),
          ),
        ],
      ),
    );
  }
}

class _AlbumNavItem extends StatelessWidget {
  const _AlbumNavItem({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppTheme.primary : AppTheme.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppTheme.primary : AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackupEntry extends StatelessWidget {
  const _BackupEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.softLine),
          ),
          child: const Row(
            children: [
              Icon(Icons.cloud_done, color: AppTheme.primary),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '照片备份',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '已开启 / 今天 09:42',
                      style: TextStyle(
                        color: AppTheme.textMedium,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaSection {
  const _MediaSection({required this.title, required this.items});

  final String title;
  final List<_MediaItem> items;
}

class _MediaItem {
  const _MediaItem({
    required this.color,
    required this.icon,
    this.duration,
  });

  final Color color;
  final IconData icon;
  final String? duration;
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({
    required this.section,
    required this.isVideo,
  });

  final _MediaSection section;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: section.items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) {
              return _MediaTile(item: section.items[index], isVideo: isVideo);
            },
          ),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.item, required this.isVideo});

  final _MediaItem item;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              item.color.withValues(alpha: 0.90),
              item.color.withValues(alpha: 0.52),
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                isVideo ? Icons.play_circle_fill : item.icon,
                color: Colors.white.withValues(alpha: 0.82),
                size: isVideo ? 34 : 26,
              ),
            ),
            if (item.duration != null)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.duration!,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AlbumGroup {
  const _AlbumGroup(this.title, this.count, this.color, this.icon);

  final String title;
  final String count;
  final Color color;
  final IconData icon;
}

class _AlbumGroupTile extends StatelessWidget {
  const _AlbumGroupTile({required this.group});

  final _AlbumGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    group.color.withValues(alpha: 0.88),
                    group.color.withValues(alpha: 0.48),
                  ],
                ),
              ),
              child: Icon(
                group.icon,
                color: Colors.white.withValues(alpha: 0.82),
                size: 30,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  group.count,
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
        ],
      ),
    );
  }
}

class _BackupHeaderCard extends StatelessWidget {
  const _BackupHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_upload, color: Colors.white, size: 28),
          SizedBox(height: 14),
          Text(
            '照片备份已开启',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '128 张照片和 12 个视频将同步到 Unraid',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BackupSettingRow extends StatelessWidget {
  const _BackupSettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.enabled,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (enabled != null) ...[
            const SizedBox(width: 8),
            Switch(value: enabled!, onChanged: null),
          ],
        ],
      ),
    );
  }
}
