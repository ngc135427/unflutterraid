import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

class LocalPhotoItem {
  const LocalPhotoItem({
    required this.id,
    required this.fileName,
    required this.readBytes,
  });

  final String id;
  final String fileName;
  final Future<Uint8List?> Function() readBytes;
}

class LocalPhotoSource {
  /// Max photos per Backup now run (newest first).
  static const defaultBatchLimit = 50;

  /// Gallery enumeration is implemented for mobile OS via photo_manager.
  static bool get isSupported {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static Future<bool> ensurePermission() async {
    if (!isSupported) {
      return false;
    }
    final permission = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    return permission.isAuth || permission.hasAccess;
  }

  static Future<bool> hasPermission() async {
    if (!isSupported) {
      return false;
    }
    final permission = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    return permission.isAuth || permission.hasAccess;
  }

  /// Newest [limit] images from the device gallery.
  static Future<List<LocalPhotoItem>> listRecentPhotos({
    int limit = defaultBatchLimit,
  }) async {
    if (!isSupported) {
      return const [];
    }
    final permitted = await ensurePermission();
    if (!permitted) {
      return const [];
    }

    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );
    if (paths.isEmpty) {
      return const [];
    }

    final album = paths.first;
    final assets = await album.getAssetListPaged(page: 0, size: limit);
    return assets.map((asset) {
      final name = asset.title?.trim();
      final fileName = (name != null && name.isNotEmpty)
          ? name
          : 'IMG_${asset.id.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}.jpg';
      return LocalPhotoItem(
        id: asset.id,
        fileName: fileName,
        readBytes: () async {
          final file = await asset.originFile;
          if (file == null) {
            final data = await asset.originBytes;
            return data;
          }
          return file.readAsBytes();
        },
      );
    }).toList(growable: false);
  }
}
