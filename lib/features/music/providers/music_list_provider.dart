import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/music_daerah_model.dart';
import 'dart:developer' as dev;

enum LoadState { idle, loading, loaded, error }

class MusicListProvider extends ChangeNotifier {
  final SupabaseClient client;

  MusicListProvider({required this.client});

  LoadState _state = LoadState.idle;
  String? _error;
  List<LaguDaerah> _songs = [];
  String? _searchQuery;

  LoadState get state => _state;
  String? get error => _error;
  List<LaguDaerah> get songs => _songs;
  String? get searchQuery => _searchQuery;

  List<LaguDaerah> get filteredSongs {
    if (_searchQuery == null || _searchQuery!.trim().isEmpty) {
      return _songs;
    }

    final query = _searchQuery!.toLowerCase().trim();
    return _songs
        .where((song) {
          return song.judul.toLowerCase().contains(query) ||
              song.asal.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  Future<void> loadAll() async {
    dev.log('=== loadAll MULAI ===', name: 'MusicListProvider');
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      final res = await client
          .from('lagu_daerah')
          .select()
          .order('judul', ascending: true);

      dev.log(
        'Respons Supabase: ${(res as List).length} lagu',
        name: 'MusicListProvider',
      );

      if ((res as List).isEmpty) {
        dev.log(
          'Tidak ada lagu ditemukan di database',
          name: 'MusicListProvider',
        );
        _songs = [];
        _state = LoadState.loaded;
        notifyListeners();
        return;
      }

      _songs = (res as List)
          .cast<Map<String, dynamic>>()
          .map((json) => LaguDaerah.fromMap(json))
          .toList();

      dev.log(
        'Berhasil memuat ${_songs.length} lagu',
        name: 'MusicListProvider',
      );

      for (var i = 0; i < (_songs.length < 3 ? _songs.length : 3); i++) {
        final song = _songs[i];
        dev.log(
          'Lagu $i: ${song.judul} - ${song.asal}',
          name: 'MusicListProvider',
        );
        dev.log('  URL: ${song.audioUrl}', name: 'MusicListProvider');
        dev.log(
          '  Durasi: ${song.formattedDuration}',
          name: 'MusicListProvider',
        );
      }

      _state = LoadState.loaded;
    } catch (e, st) {
      _error = e.toString();
      dev.log(
        'ERROR loadAll: $_error',
        name: 'MusicListProvider',
        error: e,
        stackTrace: st,
      );
      _state = LoadState.error;
      _songs = [];
    }
    notifyListeners();
  }

  List<LaguDaerah> byRegion(String regionName) {
    final region = regionName.toLowerCase().trim();
    return _songs
        .where((song) => song.asal.toLowerCase() == region)
        .toList(growable: false);
  }

  void searchSongs(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadAll();
  }

  void reset() {
    _state = LoadState.idle;
    _songs = [];
    _error = null;
    _searchQuery = null;
    notifyListeners();
  }
}
