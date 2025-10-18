import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ar_model_item.dart';
import '../models/ar_storage_config.dart';

class ArAssetsProvider extends ChangeNotifier {
  final SupabaseClient client;
  ArAssetsProvider({required this.client});

  bool loading = false;
  String? error;
  List<ArModelItem> items = [];
  String? bucketUsed;

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      // Only use the configured bucket (requested behavior)
      final b = ArStorageConfig.bucket.trim();
      if (b.isEmpty) {
        throw Exception('ArStorageConfig.bucket belum diisi.');
      }

      final storage = client.storage.from(b);
      // Probe access to bucket root (will throw if bucket not exists or no policy)
      try {
        final root = await storage.list(path: '');
        debugPrint(
          'ArAssetsProvider: bucket "$b" root => ${root.map((e) => e.name).toList()}',
        );
      } catch (e) {
        throw Exception(
          'Tidak dapat mengakses bucket "$b".\nKemungkinan: (1) bucket tidak ada, (2) bucket private tanpa policy SELECT untuk anon, atau (3) project Supabase/anon key berbeda.\nJika bucket private, set ArStorageConfig.isPublicBucket=false dan tambahkan policy SELECT pada storage.objects untuk bucket ini. Error asli: $e',
        );
      }

      // Collect all .glb files recursively
      var glbPaths = await _collectGlbPaths(storage);
      bucketUsed = b;

      // Apply optional path prefix filter from config.
      final prefix = ArStorageConfig.pathPrefix.trim();
      if (prefix.isNotEmpty) {
        final filtered = glbPaths.where((p) => p.startsWith(prefix)).toList();
        debugPrint(
          'ArAssetsProvider: pathPrefix="$prefix" kept ${filtered.length}/${glbPaths.length}',
        );
        glbPaths = filtered;
      }

      // Build URLs depending on bucket visibility
      final isPublic = ArStorageConfig.isPublicBucket;
      final result = <ArModelItem>[];
      for (final p in glbPaths) {
        String url;
        if (isPublic) {
          url = storage.getPublicUrl(p);
        } else {
          // 1-hour signed URL for private buckets
          try {
            url = await storage.createSignedUrl(p, 3600);
          } catch (e) {
            debugPrint('ArAssetsProvider: failed to sign "$p": $e');
            // Skip files that cannot be signed
            continue;
          }
        }
        // Try to compute iOS USDZ sibling path
        final iosPath = _siblingUsdzPath(p);
        String? iosUrl;
        if (iosPath != null) {
          // Probe existence by trying to list its directory and finding the file
          final dir = iosPath.contains('/')
              ? iosPath.substring(0, iosPath.lastIndexOf('/'))
              : '';
          final base = iosPath.split('/').last;
          try {
            final entries = await storage.list(path: dir);
            final hasUsdZ = entries.any(
              (e) => e.name.toLowerCase() == base.toLowerCase(),
            );
            if (hasUsdZ) {
              if (isPublic) {
                iosUrl = storage.getPublicUrl(iosPath);
              } else {
                try {
                  iosUrl = await storage.createSignedUrl(iosPath, 3600);
                } catch (e) {
                  debugPrint(
                    'ArAssetsProvider: failed to sign iOS "$iosPath": $e',
                  );
                }
              }
            }
          } catch (_) {
            // ignore
          }
        }

        result.add(ArModelItem(name: _fileName(p), url: url, iosUrl: iosUrl));
      }

      items = result;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Recursively list all .glb files under a bucket (max depth and item caps for safety)
  Future<List<String>> _collectGlbPaths(StorageFileApi storage) async {
    const maxDepth = 8;
    const maxResults = 800;
    final found = <String>[];
    final queue = <String>[''];

    int depth = 0;
    while (queue.isNotEmpty && found.length < maxResults && depth < maxDepth) {
      final levelSize = queue.length;
      for (var i = 0; i < levelSize; i++) {
        final prefix = queue.removeAt(0);
        List<FileObject> entries = const [];
        try {
          entries = await storage.list(path: prefix);
        } catch (e) {
          debugPrint('ArAssetsProvider: list failed for "$prefix": $e');
          continue;
        }
        for (final e in entries) {
          final fullPath = prefix.isEmpty ? e.name : '$prefix/${e.name}';
          // Add if file endswith .glb
          if (e.name.toLowerCase().endsWith('.glb')) {
            found.add(fullPath);
          }
          // Probe as folder by trying to list it; if it has children, enqueue it
          try {
            final children = await storage.list(path: fullPath);
            if (children.isNotEmpty) {
              queue.add(fullPath);
            }
          } catch (_) {
            // Not a folder or not listable; ignore
          }
        }
      }
      depth++;
    }
    debugPrint('ArAssetsProvider: discovered ${found.length} .glb paths');
    if (found.isEmpty) {
      debugPrint(
        'ArAssetsProvider: no .glb files found. Verify bucket files and extensions.',
      );
    } else {
      final preview = found.take(10).join(', ');
      debugPrint('ArAssetsProvider: sample paths => $preview');
    }
    return found;
  }

  String _fileName(String path) =>
      path.split('/').isNotEmpty ? path.split('/').last : path;

  String? _siblingUsdzPath(String glbPath) {
    if (!glbPath.toLowerCase().endsWith('.glb')) return null;
    return glbPath.substring(0, glbPath.length - 4) + '.usdz';
  }
}
