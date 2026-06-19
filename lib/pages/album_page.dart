import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/unraid_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide.dart';
import '../widgets/phone_frame.dart';

class AlbumPageArgs {
  const AlbumPageArgs({
    required this.apiClient,
    required this.rootPath,
  });

  final UnraidApiClient apiClient;
  final String rootPath;
}

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  static const routeName = '/album';

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<_MediaSection> _sections = [];
  bool _loading = true;
  String? _error;
  int _photoCount = 0;
  int _videoCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMedia());
  }

  Future<void> _loadMedia() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! AlbumPageArgs) {
      setState(() {
        _error = '缺少连接参数';
        _loading = false;
      });
      return;
    }
    try {
      final files = await args.apiClient.fetchMediaFiles(args.rootPath);
      final photos = files.where((f) => f.isImage).toList();
      final videos = files.where((f) => f.isVideo).toList();
      final sections = _groupByDate(photos, args.apiClient);
      if (!mounted) return;
      setState(() {
        _sections = sections;
        _photoCount = photos.length;
        _videoCount = videos.length;
        _loading = false;
      });
    } on UnraidApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '加载失败：$e';
        _loading = false;
      });
    }
  }

  static List<_MediaSection> _groupByDate(
    List<UnraidFileEntry> files,
    UnraidApiClient client,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<_MediaItem>>{};
    for (final file in files) {
      final date = file.modifiedDate;
      String title;
      if (date == null) {
        title = '未知日期';
      } else {
        final d = DateTime(date.year, date.month, date.day);
        if (!d.isBefore(today)) {
          title = '今天';
        } else if (!d.isBefore(yesterday)) {
          title = '昨天';
        } else {
          title = '${date.year}年${date.month}月';
        }
      }
      groups.putIfAbsent(title, () => []);
      groups[title]!.add(_MediaItem(
        file: file,
        apiClient: client,
      ));
    }
    // Sort sections: 今天 > 昨天 > year-month descending
    final now2 = DateTime.now();
    final sectionOrder = ['今天', '昨天'];
    final entries = groups.entries.toList();
    entries.sort((a, b) {
      final ai = sectionOrder.indexOf(a.key);
      final bi = sectionOrder.indexOf(b.key);
      if (ai >= 0 && bi >= 0) return ai.compareTo(bi);
      if (ai >= 0) return -1;
      if (bi >= 0) return 1;
      // Parse "YYYY年M月" for descending sort
      final aDate = _parseSectionDate(a.key, now2);
      final bDate = _parseSectionDate(b.key, now2);
      if (aDate != null && bDate != null) return bDate.compareTo(aDate);
      return b.key.compareTo(a.key);
    });
    return entries
        .map((e) => _MediaSection(title: e.key, items: e.value))
        .toList();
  }

  static DateTime? _parseSectionDate(String title, DateTime fallback) {
    final match = RegExp(r'(\d{4})年(\d{1,2})月').firstMatch(title);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
    );
  }

  AlbumPageArgs? get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is AlbumPageArgs ? args : null;
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    return _AlbumScaffold(
      title: '相册',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AlbumNavStats(
            selected: _AlbumNavTarget.photos,
            photoCount: _photoCount,
            videoCount: _videoCount,
            args: args,
          ),
          const SizedBox(height: 16),
          if (args != null)
            _BackupEntry(
              onTap: () => Navigator.of(context).pushNamed(
                AlbumBackupPage.routeName,
                arguments: args,
              ),
            ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppTheme.textLight),
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(
                            color: AppTheme.textMedium, fontSize: 14)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _loadMedia();
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            )
          else if (_sections.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.photo_library_outlined,
                        size: 48, color: AppTheme.textLight),
                    SizedBox(height: 12),
                    Text('没有找到照片',
                        style: TextStyle(
                            color: AppTheme.textMedium, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            for (final section in _sections)
              _TimelineSection(section: section, isVideo: false),
        ],
      ),
    );
  }
}

class AlbumGroupsPage extends StatefulWidget {
  const AlbumGroupsPage({super.key});

  static const routeName = '/album-groups';

  @override
  State<AlbumGroupsPage> createState() => _AlbumGroupsPageState();
}

class _AlbumGroupsPageState extends State<AlbumGroupsPage> {
  List<_AlbumGroupData> _groups = [];
  bool _loading = true;
  String? _error;
  int _photoCount = 0;
  int _videoCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadGroups());
  }

  Future<void> _loadGroups() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! AlbumPageArgs) {
      setState(() {
        _error = '缺少连接参数';
        _loading = false;
      });
      return;
    }
    try {
      final entries = await args.apiClient.fetchDirectory(args.rootPath);
      final directories = entries.where((e) => e.isDirectory).toList();

      final allMedia = await args.apiClient.fetchMediaFiles(args.rootPath);
      final photoCount = allMedia.where((f) => f.isImage).length;
      final videoCount = allMedia.where((f) => f.isVideo).length;

      final groupData = <_AlbumGroupData>[];
      for (final dir in directories) {
        late List<UnraidFileEntry> dirFiles;
        try {
          dirFiles = await args.apiClient.fetchDirectory(dir.path);
        } on UnraidApiException {
          continue;
        }
        final mediaCount = dirFiles.where((e) => e.isMedia).length;
        if (mediaCount > 0) {
          groupData.add(_AlbumGroupData(
            name: dir.name,
            path: dir.path,
            count: mediaCount,
          ));
        }
      }

      if (!mounted) return;
      setState(() {
        _groups = groupData;
        _photoCount = photoCount;
        _videoCount = videoCount;
        _loading = false;
      });
    } on UnraidApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '加载失败：$e';
        _loading = false;
      });
    }
  }

  AlbumPageArgs? get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is AlbumPageArgs ? args : null;
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    return _AlbumScaffold(
      title: '相册',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AlbumNavStats(
            selected: _AlbumNavTarget.groups,
            photoCount: _photoCount,
            videoCount: _videoCount,
            args: args,
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppTheme.textLight),
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(
                            color: AppTheme.textMedium, fontSize: 14)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _loadGroups();
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            )
          else if (_groups.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.folder_open,
                        size: 48, color: AppTheme.textLight),
                    SizedBox(height: 12),
                    Text('没有找到相册目录',
                        style: TextStyle(
                            color: AppTheme.textMedium, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _groups.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.18,
              ),
              itemBuilder: (context, index) => _AlbumGroupTile(
                group: _groups[index],
                args: args,
              ),
            ),
        ],
      ),
    );
  }
}

class AlbumVideosPage extends StatefulWidget {
  const AlbumVideosPage({super.key});

  static const routeName = '/album-videos';

  @override
  State<AlbumVideosPage> createState() => _AlbumVideosPageState();
}

class _AlbumVideosPageState extends State<AlbumVideosPage> {
  List<_MediaSection> _sections = [];
  bool _loading = true;
  String? _error;
  int _photoCount = 0;
  int _videoCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVideos());
  }

  Future<void> _loadVideos() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! AlbumPageArgs) {
      setState(() {
        _error = '缺少连接参数';
        _loading = false;
      });
      return;
    }
    try {
      final files = await args.apiClient.fetchMediaFiles(args.rootPath);
      final photos = files.where((f) => f.isImage).toList();
      final videos = files.where((f) => f.isVideo).toList();
      final sections = _groupByDate(videos, args.apiClient);
      if (!mounted) return;
      setState(() {
        _sections = sections;
        _photoCount = photos.length;
        _videoCount = videos.length;
        _loading = false;
      });
    } on UnraidApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '加载失败：$e';
        _loading = false;
      });
    }
  }

  static List<_MediaSection> _groupByDate(
    List<UnraidFileEntry> files,
    UnraidApiClient client,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<_MediaItem>>{};
    for (final file in files) {
      final date = file.modifiedDate;
      String title;
      if (date == null) {
        title = '未知日期';
      } else {
        final d = DateTime(date.year, date.month, date.day);
        if (!d.isBefore(today)) {
          title = '今天';
        } else if (!d.isBefore(yesterday)) {
          title = '昨天';
        } else {
          title = '${date.year}年${date.month}月';
        }
      }
      groups.putIfAbsent(title, () => []);
      groups[title]!.add(_MediaItem(file: file, apiClient: client));
    }
    final now2 = DateTime.now();
    final sectionOrder = ['今天', '昨天'];
    final entries = groups.entries.toList();
    entries.sort((a, b) {
      final ai = sectionOrder.indexOf(a.key);
      final bi = sectionOrder.indexOf(b.key);
      if (ai >= 0 && bi >= 0) return ai.compareTo(bi);
      if (ai >= 0) return -1;
      if (bi >= 0) return 1;
      final aDate = _parseSectionDate(a.key, now2);
      final bDate = _parseSectionDate(b.key, now2);
      if (aDate != null && bDate != null) return bDate.compareTo(aDate);
      return b.key.compareTo(a.key);
    });
    return entries
        .map((e) => _MediaSection(title: e.key, items: e.value))
        .toList();
  }

  static DateTime? _parseSectionDate(String title, DateTime fallback) {
    final match = RegExp(r'(\d{4})年(\d{1,2})月').firstMatch(title);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
    );
  }

  AlbumPageArgs? get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is AlbumPageArgs ? args : null;
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    return _AlbumScaffold(
      title: '视频',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AlbumNavStats(
            selected: _AlbumNavTarget.videos,
            photoCount: _photoCount,
            videoCount: _videoCount,
            args: args,
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppTheme.textLight),
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(
                            color: AppTheme.textMedium, fontSize: 14)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _loadVideos();
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            )
          else if (_sections.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.videocam_off,
                        size: 48, color: AppTheme.textLight),
                    SizedBox(height: 12),
                    Text('没有找到视频',
                        style: TextStyle(
                            color: AppTheme.textMedium, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            for (final section in _sections)
              _TimelineSection(section: section, isVideo: true),
        ],
      ),
    );
  }
}

class AlbumBackupPage extends StatefulWidget {
  const AlbumBackupPage({super.key});

  static const routeName = '/album-backup';

  @override
  State<AlbumBackupPage> createState() => _AlbumBackupPageState();
}

class _AlbumBackupPageState extends State<AlbumBackupPage> {
  bool _autoBackup = true;
  bool _wifiOnly = true;
  bool _chargeVideo = false;
  String _targetDir = '/mnt/user/photos/mobile';

  // Permission states
  bool _photosGranted = false;
  bool _videosGranted = false;
  bool _checkingPermissions = true;

  // Directory browser state
  bool _browsingDir = false;
  String _browsePath = '';
  List<UnraidFileEntry> _browseEntries = [];
  bool _browseLoading = false;
  String? _browseError;

  UnraidApiClient? get _apiClient {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is AlbumPageArgs ? args.apiClient : null;
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // --- Permissions ---

  Future<void> _checkPermissions() async {
    final photos = await Permission.photos.status;
    final videos = await Permission.videos.status;
    if (!mounted) return;
    setState(() {
      _photosGranted = photos.isGranted;
      _videosGranted = videos.isGranted;
      _checkingPermissions = false;
    });
  }

  Future<void> _requestPermissions() async {
    final results = await [
      Permission.photos,
      Permission.videos,
    ].request();
    if (!mounted) return;
    setState(() {
      _photosGranted = results[Permission.photos]?.isGranted ?? false;
      _videosGranted = results[Permission.videos]?.isGranted ?? false;
    });
    if (!_photosGranted || !_videosGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要照片和视频权限才能进行备份')),
        );
      }
    }
  }

  // --- Directory browser ---

  void _openDirBrowser() {
    final client = _apiClient;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先连接服务器')),
      );
      return;
    }
    // Start from parent of current target, or /mnt/user
    final parent = _parentPath(_targetDir);
    setState(() {
      _browsingDir = true;
      _browsePath = parent;
    });
    _loadBrowseDir(parent);
  }

  void _closeDirBrowser() {
    setState(() {
      _browsingDir = false;
    });
  }

  Future<void> _loadBrowseDir(String path) async {
    final client = _apiClient;
    if (client == null) return;
    setState(() {
      _browseLoading = true;
      _browseError = null;
      _browsePath = path;
      _browseEntries = [];
    });
    try {
      final entries = await client.fetchDirectory(path);
      if (!mounted) return;
      setState(() {
        _browseEntries = entries.where((e) => e.isDirectory).toList();
        _browseLoading = false;
      });
    } on UnraidApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _browseError = e.message;
        _browseLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _browseError = '加载失败：$e';
        _browseLoading = false;
      });
    }
  }

  void _navigateInto(UnraidFileEntry entry) {
    _loadBrowseDir(entry.path);
  }

  void _navigateUp() {
    final parent = _parentPath(_browsePath);
    if (parent == _browsePath) return;
    _loadBrowseDir(parent);
  }

  void _selectCurrentDir() {
    setState(() {
      _targetDir = _browsePath;
      _browsingDir = false;
    });
  }

  String _parentPath(String path) {
    final normalized = path.endsWith('/') && path.length > 1
        ? path.substring(0, path.length - 1)
        : path;
    final index = normalized.lastIndexOf('/');
    if (index <= 0) return '/';
    return normalized.substring(0, index);
  }

  bool get _permissionsOk => _photosGranted && _videosGranted;

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    if (_browsingDir) {
      return _buildDirBrowser();
    }
    return _buildSettings();
  }

  Widget _buildDirBrowser() {
    return PhoneFrame(
      maxContentWidth: 900,
      child: Column(
        children: [
          // Header bar
          SizedBox(
            height: 48,
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: TextButton.icon(
                    onPressed: _closeDirBrowser,
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      '取消',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    '选择备份目录',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
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
              child: Column(
                children: [
                  // Current path display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(30, 16, 30, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _browsePath,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _browseLoading ? null : _selectCurrentDir,
                            icon: const Icon(Icons.check, size: 18),
                            label: Text('选择此目录'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Navigation: go up
                  if (_browsePath != '/' && _browsePath.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.arrow_upward,
                          color: AppTheme.primary),
                      title: const Text(
                        '返回上级',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: _navigateUp,
                    ),
                  // Directory list
                  Expanded(
                    child: _browseLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _browseError != null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.error_outline,
                                        size: 40, color: AppTheme.textLight),
                                    const SizedBox(height: 8),
                                    Text(_browseError!,
                                        style: const TextStyle(
                                            color: AppTheme.textMedium,
                                            fontSize: 13)),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () =>
                                          _loadBrowseDir(_browsePath),
                                      child: const Text('重试'),
                                    ),
                                  ],
                                ),
                              )
                            : _browseEntries.isEmpty
                                ? const Center(
                                    child: Text(
                                      '此目录下没有子文件夹',
                                      style: TextStyle(
                                          color: AppTheme.textMedium,
                                          fontSize: 14),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: _browseEntries.length,
                                    itemBuilder: (context, index) {
                                      final entry = _browseEntries[index];
                                      return ListTile(
                                        leading: const Icon(
                                          Icons.folder,
                                          color: Color(0xFFFFD54F),
                                          size: 28,
                                        ),
                                        title: Text(
                                          entry.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppTheme.textDark,
                                            fontSize: 15,
                                          ),
                                        ),
                                        subtitle: Text(
                                          entry.path,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppTheme.textLight,
                                            fontSize: 12,
                                          ),
                                        ),
                                        trailing: const Icon(
                                          Icons.chevron_right,
                                          color: AppTheme.textLight,
                                        ),
                                        onTap: () => _navigateInto(entry),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return _AlbumScaffold(
      title: '照片备份',
      showSearchOnScroll: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BackupHeaderCard(
            photosGranted: _photosGranted,
            videosGranted: _videosGranted,
          ),
          const SizedBox(height: 18),

          // Permission section
          if (_checkingPermissions)
            const _BackupSettingRow(
              icon: Icons.shield,
              title: '权限检查中...',
              subtitle: '正在检查照片和视频访问权限',
            )
          else if (!_permissionsOk)
            _BackupActionRow(
              icon: Icons.shield,
              title: '需要媒体权限',
              subtitle: _permissionDeniedSubtitle(),
              actionLabel: '授予权限',
              onAction: _requestPermissions,
            )
          else
            _BackupSettingRow(
              icon: Icons.shield,
              title: '媒体权限',
              subtitle: '照片和视频访问权限已授予',
              iconColor: Colors.green,
            ),

          const SizedBox(height: 10),

          // Auto backup toggle
          _BackupSettingRow(
            icon: Icons.sync,
            title: '自动备份',
            subtitle: _permissionsOk
                ? '将手机照片同步到 Unraid 共享目录'
                : '请先授予媒体权限',
            enabled: _autoBackup && _permissionsOk,
            onToggle: _permissionsOk
                ? (value) => setState(() => _autoBackup = value)
                : null,
          ),

          // Target directory - click to browse
          _BackupSettingRow(
            icon: Icons.folder_shared,
            title: '目标目录',
            subtitle: _targetDir,
            onTap: _openDirBrowser,
          ),

          // WiFi only
          _BackupSettingRow(
            icon: Icons.wifi,
            title: '仅 Wi-Fi 备份',
            subtitle: '避免使用移动网络上传',
            enabled: _wifiOnly,
            onToggle: (value) => setState(() => _wifiOnly = value),
          ),

          // Charge video
          _BackupSettingRow(
            icon: Icons.battery_charging_full,
            title: '充电时备份视频',
            subtitle: '减少后台同步对电量的影响',
            enabled: _chargeVideo,
            onToggle: (value) => setState(() => _chargeVideo = value),
          ),

          const _BackupSettingRow(
            icon: Icons.history,
            title: '上次同步',
            subtitle: '暂无同步记录',
          ),
        ],
      ),
    );
  }

  String _permissionDeniedSubtitle() {
    final missing = <String>[];
    if (!_photosGranted) missing.add('照片');
    if (!_videosGranted) missing.add('视频');
    return '缺少${missing.join('和')}访问权限';
  }
}

class _BackupHeaderCard extends StatelessWidget {
  const _BackupHeaderCard({
    required this.photosGranted,
    required this.videosGranted,
  });

  final bool photosGranted;
  final bool videosGranted;

  @override
  Widget build(BuildContext context) {
    final allGranted = photosGranted && videosGranted;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: allGranted ? AppTheme.brandGradient : LinearGradient(
          colors: [
            AppTheme.textLight.withValues(alpha: 0.7),
            AppTheme.textLight.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (allGranted ? AppTheme.primary : AppTheme.textLight)
                .withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            allGranted ? Icons.cloud_upload : Icons.warning_amber,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 14),
          Text(
            allGranted ? '照片备份已就绪' : '需要授权才能备份',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            allGranted
                ? '照片和视频将同步到 Unraid'
                : '请授予照片和视频访问权限以启用备份功能',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                  child: widget.child,
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

class _AlbumNavStats extends StatelessWidget {
  const _AlbumNavStats({
    required this.selected,
    required this.photoCount,
    required this.videoCount,
    required this.args,
  });

  final _AlbumNavTarget selected;
  final int photoCount;
  final int videoCount;
  final AlbumPageArgs? args;

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
            value: '$photoCount',
            selected: selected == _AlbumNavTarget.photos,
            onTap: selected == _AlbumNavTarget.photos
                ? null
                : () => Navigator.of(context).pushReplacementNamed(
                      AlbumPage.routeName,
                      arguments: args,
                    ),
          ),
          _AlbumNavItem(
            label: '相册',
            value: '${_albumCount}',
            selected: selected == _AlbumNavTarget.groups,
            onTap: selected == _AlbumNavTarget.groups
                ? null
                : () => Navigator.of(context).pushReplacementNamed(
                      AlbumGroupsPage.routeName,
                      arguments: args,
                    ),
          ),
          _AlbumNavItem(
            label: '视频',
            value: '$videoCount',
            selected: selected == _AlbumNavTarget.videos,
            onTap: selected == _AlbumNavTarget.videos
                ? null
                : () => Navigator.of(context).pushReplacementNamed(
                      AlbumVideosPage.routeName,
                      arguments: args,
                    ),
          ),
        ],
      ),
    );
  }

  int get _albumCount => photoCount > 0 || videoCount > 0 ? 1 : 0;
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
    required this.file,
    required this.apiClient,
  });

  final UnraidFileEntry file;
  final UnraidApiClient apiClient;
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

class _MediaTile extends StatefulWidget {
  const _MediaTile({required this.item, required this.isVideo});

  final _MediaItem item;
  final bool isVideo;

  @override
  State<_MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<_MediaTile> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    try {
      final bytes =
          await widget.item.apiClient.fetchFileBytes(widget.item.file.path);
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.background,
        ),
        child: _bytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    _bytes!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  ),
                  if (widget.isVideo)
                    const Positioned(
                      right: 8,
                      bottom: 8,
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white70,
                        size: 28,
                      ),
                    ),
                ],
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              widget.isVideo ? Icons.videocam_off : Icons.broken_image,
              color: AppTheme.textLight,
              size: 28,
            ),
    );
  }
}

class _AlbumGroupData {
  const _AlbumGroupData({
    required this.name,
    required this.path,
    required this.count,
  });

  final String name;
  final String path;
  final int count;
}

class _AlbumGroupTile extends StatelessWidget {
  const _AlbumGroupTile({required this.group, required this.args});

  final _AlbumGroupData group;
  final AlbumPageArgs? args;

  static const _colors = [
    Color(0xFF6E8EFB),
    Color(0xFFA777E3),
    Color(0xFF52C41A),
    Color(0xFF3498DB),
    Color(0xFFFF9F43),
    Color(0xFF8A94A6),
  ];

  Color get _color {
    final idx = group.name.hashCode.abs() % _colors.length;
    return _colors[idx];
  }

  IconData get _icon {
    final lower = group.name.toLowerCase();
    if (lower.contains('photo') || lower.contains('照片') || lower.contains('pic')) {
      return Icons.photo;
    }
    if (lower.contains('video') || lower.contains('视频') || lower.contains('movie')) {
      return Icons.videocam;
    }
    if (lower.contains('backup') || lower.contains('备份')) {
      return Icons.cloud_done;
    }
    if (lower.contains('screenshot') || lower.contains('截图')) {
      return Icons.screenshot;
    }
    return Icons.folder;
  }

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
                    _color.withValues(alpha: 0.88),
                    _color.withValues(alpha: 0.48),
                  ],
                ),
              ),
              child: Icon(
                _icon,
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
                  group.name,
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
                  '${group.count} 张',
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

class _BackupSettingRow extends StatelessWidget {
  const _BackupSettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.enabled,
    this.onToggle,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool? enabled;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final Color? iconColor;

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? AppTheme.primary),
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
              if (enabled != null && onToggle != null) ...[
                const SizedBox(width: 8),
                Switch(
                  value: enabled!,
                  onChanged: onToggle,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BackupActionRow extends StatelessWidget {
  const _BackupActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9F43)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF9F43)),
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
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
