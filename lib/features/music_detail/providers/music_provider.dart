import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:budaya_indonesia/common/static/result_state.dart';
import 'package:budaya_indonesia/features/music_detail/models/music_model.dart';

class MusicDetailProvider extends ChangeNotifier {
  final SupabaseClient client;
  final String bucket;
  final bool isPublicBucket; // jika true, tidak perlu generate signed URLs
  final List<String> allowedExtensions; // contoh: ['.mp3', '.jpg']
  MusicDetailProvider({
    required this.client,
    this.bucket = 'audio',
    this.isPublicBucket = false,
    List<String>? allowedExtensions,
  }) : allowedExtensions = (allowedExtensions ?? const ['.mp3'])
           .map((e) => e.toLowerCase())
           .toList() {
    try {
      dev.log(
        'Init MusicDetailProvider bucket=$bucket public=$isPublicBucket allowedExt=$allowedExtensions rest=${client.rest.url}',
        name: 'MusicDetailProvider',
      );
    } catch (_) {}
    // Dengarkan perubahan state player agar ikon play/pause langsung update
    _player.playerStateStream.listen((playerState) {
      // Jika track selesai, reset ke awal & kosongkan current agar ikon kembali ke play
      if (playerState.processingState == ProcessingState.completed) {
        try {
          _player.seek(Duration.zero);
          _player.stop();
        } catch (_) {}
        _current = null; // hilangkan highlight
      }
      notifyListeners();
    });
    // Posisi & durasi untuk refresh progress (hindari terlalu sering: just_audio sudah throttle sendiri)
    _player.positionStream.listen((_) {
      if (_current != null) notifyListeners();
    });
    _player.durationStream.listen((_) {
      if (_current != null) notifyListeners();
    });
  }

  ResultState<List<MusicTrackDetail>> state = ResultState.none();
  List<MusicTrackDetail> _tracks = [];
  MusicTrackDetail? _current;
  final AudioPlayer _player = AudioPlayer();
  String? _selectedZone; // 'WIB' | 'WITA' | 'WIT'

  List<MusicTrackDetail> get tracks => _tracks;
  MusicTrackDetail? get current => _current;
  AudioPlayer get player => _player;
  String? get selectedZone => _selectedZone;
  bool get isPlaying => _player.playing;

  void setZone(String? zone) {
    _selectedZone = zone?.toUpperCase();
    notifyListeners();
  }

  Future<void> fetchForZone(String zone) async {
    setZone(zone);
    await fetchAll();
  }

  Future<void> fetchAll() async {
    dev.log('fetchAll() start', name: 'MusicDetailProvider');
    state = ResultState.loading();
    notifyListeners();
    try {
      final folders = ['wib', 'wita', 'wit'];
      List<String> activeFolders = folders;
      if (_selectedZone != null) {
        final lowerZone = _selectedZone!.toLowerCase();
        activeFolders = folders.where((f) => f == lowerZone).toList();
        dev.log(
          'Filter zone aktif: $_selectedZone -> folder $activeFolders',
          name: 'MusicDetailProvider',
        );
      }
      final storage = client.storage.from(bucket);
      final List<MusicTrackDetail> collected = [];
      final List<String> rawErrors = [];

      // Log current Supabase auth session (kemungkinan masih anonymous)
      try {
        final session = client.auth.currentSession;
        dev.log(
          'Auth session present=${session != null} userId=${session?.user.id} expiresAt=${session?.expiresAt} (UTC seconds)',
          name: 'MusicDetailProvider',
        );
        final accessToken = session?.accessToken;
        if (accessToken != null && accessToken.isNotEmpty) {
          final preview = accessToken.length > 18
              ? '${accessToken.substring(0, 18)}...'
              : accessToken;
          dev.log(
            'Access token preview: $preview (length=${accessToken.length})',
            name: 'MusicDetailProvider',
          );
        }
      } catch (e) {
        dev.log('Failed to read auth session: $e', name: 'MusicDetailProvider');
      }

      for (final folder in activeFolders) {
        dev.log('Listing folder: $folder', name: 'MusicDetailProvider');
        List<FileObject> list = [];
        try {
          list = await storage.list(path: folder);
        } catch (e, st) {
          final msg = 'List error (folder=$folder) type=${e.runtimeType} -> $e';
          rawErrors.add(msg);
          dev.log(msg, name: 'MusicDetailProvider', stackTrace: st);
        }
        if (list.isEmpty) {
          dev.log(
            'Folder $folder empty, retry with trailing slash',
            name: 'MusicDetailProvider',
          );
          try {
            list = await storage.list(path: '$folder/');
          } catch (e, st) {
            final msg =
                'Retry list error (folder=$folder/) type=${e.runtimeType} -> $e';
            rawErrors.add(msg);
            dev.log(msg, name: 'MusicDetailProvider', stackTrace: st);
          }
        }
        dev.log(
          'Folder $folder raw items: ${list.map((e) => e.name).toList()}',
          name: 'MusicDetailProvider',
        );
        for (final f in list) {
          final lower = f.name.toLowerCase();
          final matched = allowedExtensions.any((ext) => lower.endsWith(ext));
          if (matched) {
            final path = '$folder/${f.name}';
            final url = storage.getPublicUrl(path);
            dev.log(
              'Add track path=$path url=$url',
              name: 'MusicDetailProvider',
            );
            collected.add(
              MusicTrackDetail(
                id: path,
                title: _humanize(f.name),
                region: _guessRegion(f.name),
                timeZoneCode: folder.toUpperCase(),
                fileName: f.name,
                publicUrl: url,
              ),
            );
          } else {
            dev.log(
              'Skip item (extension not allowed) ${f.name}',
              name: 'MusicDetailProvider',
            );
          }
        }
      }
      if (collected.isEmpty) {
        dev.log(
          'All folders empty. Attempt root listing as fallback',
          name: 'MusicDetailProvider',
        );
        try {
          final rootList = await storage.list(path: '');
          dev.log(
            'Root items: ${rootList.map((e) => e.name).toList()}',
            name: 'MusicDetailProvider',
          );
          for (final f in rootList) {
            final lower = f.name.toLowerCase();
            final matched = allowedExtensions.any((ext) => lower.endsWith(ext));
            if (matched) {
              // Coba deteksi zona dari path (kalau ada wib/filename.mp3) atau dari prefix nama file
              String inferredZone = 'wib';
              for (final z in folders) {
                if (lower.startsWith('$z-') ||
                    lower.startsWith('${z}_') ||
                    lower.contains('/$z/')) {
                  inferredZone = z;
                  break;
                }
              }
              final hasSlash = f.name.contains('/');
              final fileName = hasSlash ? f.name.split('/').last : f.name;
              final path = hasSlash ? f.name : '$inferredZone/$fileName';
              final url = storage.getPublicUrl(path);
              collected.add(
                MusicTrackDetail(
                  id: path,
                  title: _humanize(fileName),
                  region: _guessRegion(fileName),
                  timeZoneCode: inferredZone.toUpperCase(),
                  fileName: fileName,
                  publicUrl: url,
                ),
              );
              dev.log(
                'Recovered root track path=$path',
                name: 'MusicDetailProvider',
              );
            }
          }
        } catch (e, st) {
          dev.log(
            'Root listing fallback failed: $e',
            name: 'MusicDetailProvider',
            stackTrace: st,
          );
          rawErrors.add('Root list error type=${e.runtimeType} -> $e');
        }
      }
      dev.log(
        'Total collected mp3: ${collected.length}',
        name: 'MusicDetailProvider',
      );
      _tracks = collected;
      if (collected.isEmpty) {
        if (rawErrors.isNotEmpty) {
          state = ResultState.error(
            'Tidak ada file ditemukan. Error mentah: \n${rawErrors.join("\n")}',
          );
        } else {
          // Kemungkinan besar bucket public tapi belum ada policy SELECT sehingga list() tidak mengembalikan apapun.
          state = ResultState.error(
            'List kosong tanpa error. Kemungkinan belum ada policy SELECT untuk bucket "$bucket".\n'
            'Solusi: di SQL Editor Supabase jalankan:\n'
            'create policy "Public list $bucket" on storage.objects for select using ( bucket_id = '
            '$bucket'
            ' );',
          );
        }
      } else {
        state = ResultState.success(_tracks);
      }
      // PRIVATE BUCKET HANDLING: Jika bucket private, publicUrl tidak akan bisa diputar.
      // Kita coba generate signed URLs (1 jam) untuk semua track yang terkumpul.
      if (collected.isNotEmpty && !isPublicBucket) {
        try {
          final paths = collected.map((t) => t.id).toList();
          dev.log(
            'Request signed URLs for ${paths.length} objects',
            name: 'MusicDetailProvider',
          );
          final signedResponses = await storage.createSignedUrls(
            paths,
            60 * 60,
          ); // 1 jam
          final mapSigned = <String, String>{};
          for (final resp in signedResponses) {
            mapSigned[resp.path] = resp.signedUrl;
          }
          // Replace publicUrl field dengan signed url jika tersedia.
          for (var i = 0; i < collected.length; i++) {
            final t = collected[i];
            final signed = mapSigned[t.id];
            if (signed != null) {
              collected[i] = MusicTrackDetail(
                id: t.id,
                title: t.title,
                region: t.region,
                timeZoneCode: t.timeZoneCode,
                fileName: t.fileName,
                publicUrl: signed,
                duration: t.duration,
              );
            }
          }
          dev.log(
            'Signed URL generation complete. Updated tracks.',
            name: 'MusicDetailProvider',
          );
        } catch (e, st) {
          dev.log(
            'Signed URL generation failed: $e',
            name: 'MusicDetailProvider',
            stackTrace: st,
          );
        }
      }
    } catch (e, st) {
      dev.log(
        'fetchAll error: $e',
        name: 'MusicDetailProvider',
        stackTrace: st,
      );
      state = ResultState.error(e.toString());
    }
    notifyListeners();
  }

  // Versi alternatif menggunakan parameter seperti di dokumentasi Supabase
  // https://supabase.com/docs/reference/dart/storage-from-list
  // Mencoba memanfaatkan search dan sortBy. Jika private bucket tetap butuh policy / auth session.
  Future<void> fetchAllDocStyle() async {
    dev.log('fetchAllDocStyle() start', name: 'MusicDetailProvider');
    state = ResultState.loading();
    notifyListeners();
    final folders = ['wib', 'wita', 'wit'];
    final storage = client.storage.from(bucket);
    final List<MusicTrackDetail> collected = [];
    final List<String> rawErrors = [];
    try {
      for (final folder in folders) {
        dev.log('DocStyle list folder=$folder', name: 'MusicDetailProvider');
        try {
          final list = await storage.list(path: folder);
          dev.log(
            'DocStyle list result folder=$folder => ${list.map((e) => e.name).toList()}',
            name: 'MusicDetailProvider',
          );
          for (final f in list) {
            final lower = f.name.toLowerCase();
            final matched = allowedExtensions.any((ext) => lower.endsWith(ext));
            if (matched) {
              final path = '$folder/${f.name}';
              final url = storage.getPublicUrl(path);
              collected.add(
                MusicTrackDetail(
                  id: path,
                  title: _humanize(f.name),
                  region: _guessRegion(f.name),
                  timeZoneCode: folder.toUpperCase(),
                  fileName: f.name,
                  publicUrl: url,
                ),
              );
            }
          }
        } catch (e, st) {
          final msg =
              'DocStyle list error folder=$folder type=${e.runtimeType} -> $e';
          rawErrors.add(msg);
          dev.log(msg, name: 'MusicDetailProvider', stackTrace: st);
        }
      }
      _tracks = collected;
      if (_tracks.isEmpty && rawErrors.isNotEmpty) {
        state = ResultState.error(
          'DocStyle: Tidak ada file. Errors:\n${rawErrors.join('\n')}',
        );
      } else if (_tracks.isEmpty) {
        state = ResultState.error('DocStyle: Tidak ada file ditemukan.');
      } else {
        // Signed URLs lagi jika perlu
        try {
          final signed = await storage.createSignedUrls(
            _tracks.map((t) => t.id).toList(),
            3600,
          );
          final mapSigned = {for (final r in signed) r.path: r.signedUrl};
          for (var i = 0; i < _tracks.length; i++) {
            final t = _tracks[i];
            final s = mapSigned[t.id];
            if (s != null) {
              _tracks[i] = MusicTrackDetail(
                id: t.id,
                title: t.title,
                region: t.region,
                timeZoneCode: t.timeZoneCode,
                fileName: t.fileName,
                publicUrl: s,
                duration: t.duration,
              );
            }
          }
        } catch (e, st) {
          dev.log(
            'DocStyle signed url failed: $e',
            name: 'MusicDetailProvider',
            stackTrace: st,
          );
        }
        state = ResultState.success(_tracks);
      }
    } catch (e, st) {
      dev.log(
        'fetchAllDocStyle fatal: $e',
        name: 'MusicDetailProvider',
        stackTrace: st,
      );
      state = ResultState.error(e.toString());
    }
    notifyListeners();
  }

  // Helper debug manual untuk melihat isi folder arbitrary.
  Future<void> debugListPath(String path, {String? search}) async {
    final storage = client.storage.from(bucket);
    try {
      final list = await storage.list(path: path);
      dev.log(
        'debugListPath path="$path" search="$search" -> ${list.map((e) => e.name).toList()}',
        name: 'MusicDetailProvider',
      );
    } catch (e, st) {
      dev.log(
        'debugListPath error path="$path" type=${e.runtimeType} -> $e',
        name: 'MusicDetailProvider',
        stackTrace: st,
      );
    }
  }

  // NEW: Jika policy tidak mengizinkan LIST (bucket private), tapi kamu sudah tahu nama file persis,
  // gunakan method ini. Berikan daftar full path relatif terhadap bucket (misal:
  // 'wib/Ayam Den Lapeh - Sumatera Barat.mp3'). Method ini akan mencoba createSignedUrl
  // untuk setiap path dan membangun list track tanpa perlu listing folder.
  Future<void> fetchKnownPaths(
    List<String> paths, {
    int expiresInSeconds = 3600,
  }) async {
    dev.log(
      'fetchKnownPaths() count=${paths.length}',
      name: 'MusicDetailProvider',
    );
    state = ResultState.loading();
    notifyListeners();
    final storage = client.storage.from(bucket);
    final List<MusicTrackDetail> collected = [];
    final List<String> errors = [];
    for (final originalPath in paths) {
      final path = originalPath.trim();
      if (path.isEmpty) continue;
      try {
        final signed = await storage.createSignedUrl(path, expiresInSeconds);
        final fileName = path.contains('/') ? path.split('/').last : path;
        final folder = path.contains('/') ? path.split('/').first : 'wib';
        collected.add(
          MusicTrackDetail(
            id: path,
            title: _humanize(fileName),
            region: _guessRegion(fileName),
            timeZoneCode: folder.toUpperCase(),
            fileName: fileName,
            publicUrl: signed, // langsung pakai signed url
          ),
        );
        dev.log('Signed URL OK path=$path', name: 'MusicDetailProvider');
      } catch (e, st) {
        final msg = 'Signed URL gagal path=$path type=${e.runtimeType} -> $e';
        errors.add(msg);
        dev.log(msg, name: 'MusicDetailProvider', stackTrace: st);
      }
    }
    if (collected.isEmpty) {
      if (errors.isNotEmpty) {
        state = ResultState.error(
          'Tidak ada track berhasil. Errors:\n${errors.join('\n')}',
        );
      } else {
        state = ResultState.error('Tidak ada path valid.');
      }
    } else {
      _tracks = collected;
      state = ResultState.success(_tracks);
    }
    notifyListeners();
  }

  // Debug: coba download satu file langsung (melewati listing) untuk cek apakah publicUrl bekerja.
  Future<void> testFileDownload(String relativePath) async {
    final storage = client.storage.from(bucket);
    final path = relativePath.trim();
    if (path.isEmpty) return;
    dev.log('testFileDownload start path=$path', name: 'MusicDetailProvider');
    try {
      // Cek public URL
      final pub = storage.getPublicUrl(path);
      dev.log('Public URL => $pub', name: 'MusicDetailProvider');
      // Coba download (akan gagal jika policy SELECT tidak ada)
      final bytes = await storage.download(path);
      dev.log('Downloaded bytes=${bytes.length}', name: 'MusicDetailProvider');
    } catch (e, st) {
      dev.log(
        'testFileDownload error path=$path type=${e.runtimeType} -> $e',
        name: 'MusicDetailProvider',
        stackTrace: st,
      );
    }
  }

  Future<void> play(MusicTrackDetail track) async {
    try {
      _current = track;
      await _player.setUrl(track.publicUrl);
      // Pastikan volume kembali normal jika sebelumnya dimatikan saat reset
      if (_player.volume == 0) {
        try {
          await _player.setVolume(1.0);
        } catch (_) {}
      }
      await _player.play();
      dev.log('Playing ${track.id}', name: 'MusicDetailProvider');
      notifyListeners();
    } catch (e) {
      // TODO: Bisa set error khusus player
    }
  }

  Future<void> togglePlay(MusicTrackDetail track) async {
    // Jika item yang sama
    if (_current?.id == track.id) {
      if (_player.playing) {
        await pause();
      } else {
        // Jika URL belum diset (misal setelah reset) set ulang
        if (_player.audioSource == null) {
          await _player.setUrl(track.publicUrl);
        }
        if (_player.volume == 0) {
          try {
            await _player.setVolume(1.0);
          } catch (_) {}
        }
        await _player.play();
        notifyListeners();
      }
      return;
    }
    // Track berbeda: mainkan track baru
    await play(track);
  }

  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    notifyListeners();
  }

  // Hentikan audio dan kosongkan current agar UI player menghilang
  Future<void> resetPlayback() async {
    try {
      dev.log('resetPlayback() invoked', name: 'MusicDetailProvider');
      try {
        await _player.stop(); // stop meski status playing=false supaya release
      } catch (e) {
        dev.log('resetPlayback stop error: $e', name: 'MusicDetailProvider');
      }
      try {
        await _player.seek(Duration.zero);
      } catch (_) {}
    } catch (_) {}
    _current = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

String _humanize(String name) => name
    .replaceAll('.mp3', '')
    .replaceAll('_', ' ')
    .replaceAll('-', ' ')
    .split(RegExp(r"\s+"))
    .map(
      (w) => w.isEmpty
          ? w
          : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
    )
    .join(' ');

String _guessRegion(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('sumatera')) return 'Sumatera';
  if (lower.contains('papua')) return 'Papua';
  if (lower.contains('jawa')) return 'Jawa';
  if (lower.contains('kalimantan')) return 'Kalimantan';
  if (lower.contains('sulawesi')) return 'Sulawesi';
  if (lower.contains('banten')) return 'Banten';
  if (lower.contains('riau')) return 'Riau';
  return 'Nusantara';
}
