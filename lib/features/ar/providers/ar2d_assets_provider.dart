import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ar2d_item.dart';
import '../models/ar2d_storage_config.dart';

class Ar2dAssetsProvider extends ChangeNotifier {
  final SupabaseClient client;
  Ar2dAssetsProvider({required this.client});

  bool loading = false;
  String? error;
  String? bucketUsed;
  List<Ar2dItem> items = const [];

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final b = Ar2dStorageConfig.bucket.trim();
      if (b.isEmpty) throw Exception('Ar2dStorageConfig.bucket belum diisi');
      final storage = client.storage.from(b);

      // Try access bucket root
      try {
        await storage.list(path: '');
      } catch (e) {
        throw Exception('Tidak bisa mengakses bucket "$b": $e');
      }

      bucketUsed = b;
      var paths = await _collectImagePaths(storage);
      final prefix = Ar2dStorageConfig.pathPrefix.trim();
      if (prefix.isNotEmpty) {
        paths = paths.where((p) => p.startsWith(prefix)).toList();
      }

      final isPublic = Ar2dStorageConfig.isPublicBucket;
      final result = <Ar2dItem>[];
      for (final p in paths) {
        String url;
        if (isPublic) {
          url = storage.getPublicUrl(p);
        } else {
          try {
            url = await storage.createSignedUrl(p, 3600);
          } catch (e) {
            debugPrint('Ar2d: gagal signed url $p => $e');
            continue;
          }
        }
        result.add(Ar2dItem(name: _fileName(p), url: url));
      }

      items = result;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<List<String>> _collectImagePaths(StorageFileApi storage) async {
    const maxDepth = 6;
    const maxResults = 1000;
    final found = <String>[];
    final q = <String>[''];
    int depth = 0;
    while (q.isNotEmpty && found.length < maxResults && depth < maxDepth) {
      final size = q.length;
      for (var i = 0; i < size; i++) {
        final prefix = q.removeAt(0);
        List<FileObject> entries = const [];
        try {
          entries = await storage.list(path: prefix);
        } catch (_) {}
        for (final e in entries) {
          final path = prefix.isEmpty ? e.name : '$prefix/${e.name}';
          final lower = e.name.toLowerCase();
          if (Ar2dStorageConfig.allowedExtensions.any(
            (ext) => lower.endsWith(ext),
          )) {
            found.add(path);
          }
          // Detect folder by attempting to list
          try {
            final children = await storage.list(path: path);
            if (children.isNotEmpty) q.add(path);
          } catch (_) {}
        }
      }
      depth++;
    }
    return found;
  }

  String _fileName(String path) =>
      path.split('/').isNotEmpty ? path.split('/').last : path;
}
