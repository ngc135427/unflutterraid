import 'dart:async';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

import '../services/backup_preferences.dart';
import '../services/backup_uploader.dart';
import '../services/local_photo_source.dart';
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
        _error = AppLocalizations.of(context).missingConnectionArgs;
        _loading = false;
      });
      return;
    }
    try {
      final files = await args.apiClient.fileManager.listMedia(args.rootPath);
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
        _error = AppLocalizations.of(context).loadFailed(e.toString());
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
        title = '__unknown__';
      } else {
        final d = DateTime(date.year, date.month, date.day);
        if (!d.isBefore(today)) {
          title = '__today__';
        } else if (!d.isBefore(yesterday)) {
          title = '__yesterday__';
        } else {
          title = '__ym__${date.year}_${date.month}';
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
    final sectionOrder = ['__today__', '__yesterday__'];
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
    final match = RegExp(r'__ym__(\d+)_(\d+)').firstMatch(title);
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
      title: AppLocalizations.of(context).album,
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
                        style: TextStyle(
                            color: AppTheme.textMedium, fontSize: 14)),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _loadMedia();
                      },
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              ),
            )
          else if (_sections.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.photo_library_outlined,
                        size: 48, color: AppTheme.textLight),
                    SizedBox(height: 12),
                    Text(AppLocalizations.of(context).noPhotosFound,
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
        _error = AppLocalizations.of(context).missingConnectionArgs;
        _loading = false;
      });
      return;
    }
    try {
      final entries = await args.apiClient.fileManager.listRoot();
      final directories = entries.where((e) => e.isDirectory).toList();

      final allMedia =
          await args.apiClient.fileManager.listMedia(args.rootPath);
      final photoCount = allMedia.where((f) => f.isImage).length;
      final videoCount = allMedia.where((f) => f.isVideo).length;

      final groupData = <_AlbumGroupData>[];
      for (final dir in directories) {
        late List<UnraidFileEntry> dirFiles;
        try {
          dirFiles = await args.apiClient.fileManager.listMedia(dir.path);
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
        _error = AppLocalizations.of(context).loadFailed(e.toString());
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
      title: AppLocalizations.of(context).album,
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
                        style: TextStyle(
                            color: AppTheme.textMedium, fontSize: 14)),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _loadGroups();
                      },
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              ),
            )
          else if (_groups.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.folder_open,
                        size: 48, color: AppTheme.textLight),
                    SizedBox(height: 12),
                    Text(AppLocalizations.of(context).noAlbumDirsFound,
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
        _error = AppLocalizations.of(context).missingConnectionArgs;
        _loading = false;
      });
      return;
    }
    try {
      final files = await args.apiClient.fileManager.listMedia(args.rootPath);
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
        _error = AppLocalizations.of(context).loadFailed(e.toString());
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
        title = '__unknown__';
      } else {
        final d = DateTime(date.year, date.month, date.day);
        if (!d.isBefore(today)) {
          title = '__today__';
        } else if (!d.isBefore(yesterday)) {
          title = '__yesterday__';
        } else {
          title = '__ym__${date.year}_${date.month}';
        }
      }
      groups.putIfAbsent(title, () => []);
      groups[title]!.add(_MediaItem(file: file, apiClient: client));
    }
    final now2 = DateTime.now();
    final sectionOrder = ['__today__', '__yesterday__'];
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
    final match = RegExp(r'__ym__(\d+)_(\d+)').firstMatch(title);
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
      title: AppLocalizations.of(context).videos,
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
                        style: TextStyle(
                            color: AppTheme.textMedium, fontSize: 14)),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _loadVideos();
                      },
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              ),
            )
          else if (_sections.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.videocam_off,
                        size: 48, color: AppTheme.textLight),
                    SizedBox(height: 12),
                    Text(AppLocalizations.of(context).noVideosFound,
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
  bool _autoBackup = false;
  bool _wifiOnly = true;
  String _targetDir = BackupPreferencesState.defaultTargetDir;
  BackupLastSync? _lastSync;

  bool _photosGranted = false;
  bool _checkingPermissions = true;
  final bool _platformSupported = LocalPhotoSource.isSupported;

  bool _browsingDir = false;
  String _browsePath = '';
  List<UnraidFileEntry> _browseEntries = [];
  bool _browseLoading = false;
  String? _browseError;

  bool _running = false;
  bool _cancelRequested = false;
  int _progressDone = 0;
  int _progressTotal = 0;
  String _progressName = '';

  UnraidApiClient? get _apiClient {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is AlbumPageArgs ? args.apiClient : null;
  }

  bool get _permissionsOk => _platformSupported && _photosGranted;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    final prefs = await BackupPreferences.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _autoBackup = prefs.autoBackup;
      _wifiOnly = prefs.wifiOnly;
      _targetDir = prefs.targetDir;
      _lastSync = prefs.lastSync;
    });
    await _checkPermissions();
  }

  Future<void> _persistPrefs() async {
    await BackupPreferences.save(
      BackupPreferencesState(
        autoBackup: _autoBackup,
        wifiOnly: _wifiOnly,
        targetDir: _targetDir,
        lastSync: _lastSync,
      ),
    );
  }

  Future<void> _checkPermissions() async {
    if (!_platformSupported) {
      if (!mounted) {
        return;
      }
      setState(() {
        _photosGranted = false;
        _checkingPermissions = false;
      });
      return;
    }
    final granted = await LocalPhotoSource.hasPermission();
    if (!mounted) {
      return;
    }
    setState(() {
      _photosGranted = granted;
      _checkingPermissions = false;
    });
  }

  Future<void> _requestPermissions() async {
    if (!_platformSupported) {
      return;
    }
    final granted = await LocalPhotoSource.ensurePermission();
    if (!mounted) {
      return;
    }
    setState(() => _photosGranted = granted);
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).mediaPermissionRequiredBackup,
          ),
        ),
      );
    }
  }

  Future<bool> _isOnMobileData() async {
    final results = await Connectivity().checkConnectivity();
    return results.contains(ConnectivityResult.mobile) &&
        !results.contains(ConnectivityResult.wifi) &&
        !results.contains(ConnectivityResult.ethernet);
  }

  Future<void> _startBackup() async {
    final l10n = AppLocalizations.of(context);
    final client = _apiClient;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupNeedConnection)),
      );
      return;
    }
    if (!_platformSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupUnsupportedPlatform)),
      );
      return;
    }
    if (!_photosGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mediaPermissionRequiredBackup)),
      );
      return;
    }
    if (_wifiOnly && await _isOnMobileData()) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupWifiBlocked)),
      );
      return;
    }

    setState(() {
      _running = true;
      _cancelRequested = false;
      _progressDone = 0;
      _progressTotal = 0;
      _progressName = '';
    });

    try {
      final photos = await LocalPhotoSource.listRecentPhotos();
      if (!mounted) {
        return;
      }
      if (photos.isEmpty) {
        setState(() => _running = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupNoPhotos)),
        );
        return;
      }

      setState(() => _progressTotal = photos.length);

      final result = await const BackupUploader().run(
        fileManager: client.fileManager,
        targetDir: _targetDir,
        photos: photos,
        isCancelled: () => _cancelRequested,
        onProgress: (done, total, name) {
          if (!mounted) {
            return;
          }
          setState(() {
            _progressDone = done;
            _progressTotal = total;
            _progressName = name;
          });
        },
      );

      if (!mounted) {
        return;
      }

      final lastSync = BackupLastSync(
        at: DateTime.now(),
        success: result.success,
        failed: result.failed,
        skipped: result.skipped,
      );
      setState(() {
        _running = false;
        _lastSync = lastSync;
      });
      await BackupPreferences.saveLastSync(lastSync);

      final message = result.cancelled
          ? l10n.backupCancelledSummary(
              result.success,
              result.skipped,
              result.failed,
            )
          : l10n.backupDoneSummary(
              result.success,
              result.skipped,
              result.failed,
            );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _running = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loadFailed(error.toString()))),
      );
    }
  }

  void _cancelBackup() {
    setState(() => _cancelRequested = true);
  }

  // --- Directory browser ---

  void _openDirBrowser() {
    final client = _apiClient;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).connectServerFirst)),
      );
      return;
    }
    setState(() {
      _browsingDir = true;
      _browsePath = '/mnt/user';
    });
    _loadBrowseDir('/mnt/user');
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
      final entries = await client.fileManager.listDirectory(path);
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
        _browseError = AppLocalizations.of(context).loadFailed(e.toString());
        _browseLoading = false;
      });
    }
  }

  void _selectEntryDir(UnraidFileEntry entry) {
    setState(() {
      _targetDir = entry.path;
      _browsingDir = false;
    });
    unawaited(_persistPrefs());
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
    unawaited(_persistPrefs());
  }

  String _parentPath(String path) {
    final normalized = path.endsWith('/') && path.length > 1
        ? path.substring(0, path.length - 1)
        : path;
    final index = normalized.lastIndexOf('/');
    if (index <= 0) return '/';
    return normalized.substring(0, index);
  }

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
                    icon: Icon(Icons.close, color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context).cancel,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context).selectBackupDirectory,
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
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed:
                                _browseLoading ? null : _selectCurrentDir,
                            icon: Icon(Icons.check, size: 18),
                            label: Text(AppLocalizations.of(context)
                                .selectThisDirectory),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  // Navigation: go up
                  if (_browsePath != '/mnt/user' && _browsePath.isNotEmpty)
                    ListTile(
                      leading:
                          Icon(Icons.arrow_upward, color: AppTheme.primary),
                      title: Text(
                        AppLocalizations.of(context).goUp,
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
                                        style: TextStyle(
                                            color: AppTheme.textMedium,
                                            fontSize: 13)),
                                    SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () =>
                                          _loadBrowseDir(_browsePath),
                                      child: Text(
                                          AppLocalizations.of(context).retry),
                                    ),
                                  ],
                                ),
                              )
                            : _browseEntries.isEmpty
                                ? Center(
                                    child: Text(
                                      AppLocalizations.of(context).noSubfolders,
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
                                          Icons.check_circle_outline,
                                          color: AppTheme.textLight,
                                        ),
                                        onTap: () => _selectEntryDir(entry),
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
    final l10n = AppLocalizations.of(context);
    return _AlbumScaffold(
      title: l10n.photoBackup,
      showSearchOnScroll: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BackupHeaderCard(
            ready: _permissionsOk,
            platformSupported: _platformSupported,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.backupBatchHint,
            style: const TextStyle(color: AppTheme.textMedium, fontSize: 13),
          ),
          const SizedBox(height: 18),
          if (_checkingPermissions)
            _BackupSettingRow(
              icon: Icons.shield,
              title: l10n.permissionChecking,
              subtitle: l10n.permissionCheckingSubtitle,
            )
          else if (!_platformSupported)
            _BackupSettingRow(
              icon: Icons.devices,
              title: l10n.needMediaPermission,
              subtitle: l10n.backupUnsupportedPlatform,
              iconColor: const Color(0xFFFF9F43),
            )
          else if (!_permissionsOk)
            _BackupActionRow(
              icon: Icons.shield,
              title: l10n.needMediaPermission,
              subtitle: l10n.missingPermissionAccess(l10n.photos),
              actionLabel: l10n.grantPermission,
              onAction: _requestPermissions,
            )
          else
            _BackupSettingRow(
              icon: Icons.shield,
              title: l10n.mediaPermission,
              subtitle: l10n.mediaPermissionGranted,
              iconColor: Colors.green,
            ),
          const SizedBox(height: 10),
          _BackupSettingRow(
            icon: Icons.sync,
            title: l10n.autoBackup,
            subtitle:
                _permissionsOk ? l10n.autoBackupSubtitle : l10n.grantMediaFirst,
            enabled: _autoBackup,
            onToggle: _permissionsOk
                ? (value) {
                    setState(() => _autoBackup = value);
                    unawaited(_persistPrefs());
                  }
                : null,
          ),
          _BackupSettingRow(
            icon: Icons.folder_shared,
            title: l10n.targetDirectory,
            subtitle: _targetDir,
            onTap: _running ? null : _openDirBrowser,
          ),
          _BackupSettingRow(
            icon: Icons.wifi,
            title: l10n.wifiOnlyBackup,
            subtitle: l10n.wifiOnlyBackupSubtitle,
            enabled: _wifiOnly,
            onToggle: (value) {
              setState(() => _wifiOnly = value);
              unawaited(_persistPrefs());
            },
          ),
          _BackupSettingRow(
            icon: Icons.battery_charging_full,
            title: l10n.chargeWhenBackupVideo,
            subtitle: l10n.chargeWhenBackupVideoSubtitle,
          ),
          _BackupSettingRow(
            icon: Icons.history,
            title: l10n.lastSync,
            subtitle: _formatLastSync(l10n),
          ),
          const SizedBox(height: 16),
          if (_running) ...[
            Text(
              l10n.backupRunning(_progressDone, _progressTotal),
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _progressTotal == 0
                  ? null
                  : (_progressDone / _progressTotal).clamp(0.0, 1.0),
            ),
            if (_progressName.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.backupCurrentFile(_progressName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(color: AppTheme.textMedium, fontSize: 13),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _cancelBackup,
                child: Text(l10n.backupCancel),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (_permissionsOk && _apiClient != null)
                    ? () => unawaited(_startBackup())
                    : null,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: Text(l10n.backupNow),
              ),
            ),
        ],
      ),
    );
  }

  String _formatLastSync(AppLocalizations l10n) {
    final last = _lastSync;
    if (last == null) {
      return l10n.noSyncRecord;
    }
    final local = last.at.toLocal();
    final time = '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
    return l10n.lastSyncSummary(
      time,
      last.success,
      last.skipped,
      last.failed,
    );
  }
}

class _BackupHeaderCard extends StatelessWidget {
  const _BackupHeaderCard({
    required this.ready,
    required this.platformSupported,
  });

  final bool ready;
  final bool platformSupported;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allGranted = ready;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: allGranted
            ? AppTheme.brandGradient
            : LinearGradient(
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
            !platformSupported
                ? l10n.backupUnsupportedPlatform
                : allGranted
                    ? l10n.photoBackupReady
                    : l10n.needAuthToBackup,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            !platformSupported
                ? l10n.backupBatchHint
                : allGranted
                    ? l10n.photosVideosSyncToUnraid
                    : l10n.grantPhotosVideosToEnable,
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
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context).back,
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
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppTheme.primary, size: 18),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              AppLocalizations.of(context).searchPhotosVideos,
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
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _AlbumNavItem(
            label: AppLocalizations.of(context).allPhotos,
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
            label: AppLocalizations.of(context).album,
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
            label: AppLocalizations.of(context).videos,
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
          child: Row(
            children: [
              Icon(Icons.cloud_done, color: AppTheme.primary),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).photoBackup,
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      AppLocalizations.of(context).backupEnabledSample,
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
            _localizedSectionTitle(context, section.title),
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
  late final Future<Uint8List> _previewFuture;

  @override
  void initState() {
    super.initState();
    _previewFuture = widget.item.apiClient.fileManager.readPreviewBytes(
      widget.item.file.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppTheme.background,
        ),
        child: FutureBuilder<Uint8List>(
          future: _previewFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                  if (widget.isVideo)
                    const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                ],
              );
            }
            return _buildPlaceholder(
              loading: snapshot.connectionState != ConnectionState.done,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder({required bool loading}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Icon(
            widget.isVideo ? Icons.videocam : Icons.image_outlined,
            color: AppTheme.textLight,
            size: 28,
          ),
        ),
        if (loading)
          const Align(
            alignment: Alignment.bottomCenter,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
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
    if (lower.contains('photo') ||
        lower.contains('照片') ||
        lower.contains('pic')) {
      return Icons.photo;
    }
    if (lower.contains('video') ||
        lower.contains('视频') ||
        lower.contains('movie')) {
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
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  AppLocalizations.of(context).photoCount(group.count),
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
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Text(
              actionLabel,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

String _localizedSectionTitle(BuildContext context, String title) {
  final l10n = AppLocalizations.of(context);
  if (title == '__unknown__') return l10n.unknownDate;
  if (title == '__today__') return l10n.today;
  if (title == '__yesterday__') return l10n.yesterday;
  final match = RegExp(r'__ym__(\d+)_(\d+)').firstMatch(title);
  if (match != null) {
    return l10n.yearMonth(
        int.parse(match.group(1)!), int.parse(match.group(2)!));
  }
  return title;
}
