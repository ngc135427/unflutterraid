import 'local_photo_source.dart';
import 'unraid_api_client.dart';

class BackupRunResult {
  const BackupRunResult({
    required this.success,
    required this.failed,
    required this.skipped,
    required this.failedNames,
    required this.cancelled,
  });

  final int success;
  final int failed;
  final int skipped;
  final List<String> failedNames;
  final bool cancelled;

  int get totalProcessed => success + failed + skipped;
}

typedef BackupProgressCallback = void Function(
  int done,
  int total,
  String currentName,
);

/// Uploads local photos to a File Browser directory.
///
/// Conflict policy: skip when [fileName] already exists in the target listing.
class BackupUploader {
  const BackupUploader();

  Future<BackupRunResult> run({
    required UnraidFileManager fileManager,
    required String targetDir,
    required List<LocalPhotoItem> photos,
    required bool Function() isCancelled,
    BackupProgressCallback? onProgress,
  }) async {
    if (photos.isEmpty) {
      return const BackupRunResult(
        success: 0,
        failed: 0,
        skipped: 0,
        failedNames: [],
        cancelled: false,
      );
    }

    final existing = await _existingNames(fileManager, targetDir);
    var success = 0;
    var failed = 0;
    var skipped = 0;
    final failedNames = <String>[];
    final total = photos.length;

    for (var i = 0; i < photos.length; i++) {
      if (isCancelled()) {
        return BackupRunResult(
          success: success,
          failed: failed,
          skipped: skipped,
          failedNames: failedNames,
          cancelled: true,
        );
      }

      final photo = photos[i];
      final name = _safeFileName(photo.fileName);
      onProgress?.call(i, total, name);

      if (existing.contains(name.toLowerCase())) {
        skipped += 1;
        onProgress?.call(i + 1, total, name);
        continue;
      }

      try {
        final bytes = await photo.readBytes();
        if (bytes == null || bytes.isEmpty) {
          failed += 1;
          failedNames.add(name);
          onProgress?.call(i + 1, total, name);
          continue;
        }
        await fileManager.uploadBytes(
          directoryPath: targetDir,
          fileName: name,
          bytes: bytes,
        );
        existing.add(name.toLowerCase());
        success += 1;
      } catch (_) {
        failed += 1;
        failedNames.add(name);
      }
      onProgress?.call(i + 1, total, name);
    }

    return BackupRunResult(
      success: success,
      failed: failed,
      skipped: skipped,
      failedNames: failedNames,
      cancelled: false,
    );
  }

  Future<Set<String>> _existingNames(
    UnraidFileManager fileManager,
    String targetDir,
  ) async {
    try {
      final entries = await fileManager.listDirectory(targetDir);
      return entries
          .where((entry) => !entry.isDirectory)
          .map((entry) => entry.name.toLowerCase())
          .toSet();
    } on UnraidApiException {
      // Directory may not exist yet; File Browser upload can create the file path.
      return <String>{};
    }
  }

  static String _safeFileName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 'photo.jpg';
    }
    return trimmed.replaceAll(RegExp(r'[\\/]+'), '_');
  }
}
