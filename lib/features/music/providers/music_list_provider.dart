import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as dev;
import '../models/music_daerah_model.dart';

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
    dev.log('loadAll() mulai', name: 'MusicListProvider');
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
          .map(LaguDaerah.fromMap)
          .toList();

      dev.log(
        'lagu_daerah jumlah: ${_songs.length}',
        name: 'MusicListProvider',
      );
      for (final song in _songs.take(5)) {
        dev.log(
          '→ #${song.id} ${song.judul} (${song.asal}) - ${song.formattedDuration}',
          name: 'MusicListProvider',
        );
      }

      _state = LoadState.loaded;
    } catch (e, st) {
      _error = e.toString();
      dev.log(
        'Error lagu_daerah: $_error',
        name: 'MusicListProvider',
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
    dev.log('cariLagu() - kueri: "${query}"', name: 'MusicListProvider');
    _searchQuery = query.trim();
    notifyListeners();
  }

  void clearSearch() {
    dev.log('bersihkanPencarian()', name: 'MusicListProvider');
    _searchQuery = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    dev.log('muatUlang()', name: 'MusicListProvider');
    await loadAll();
  }

  void reset() {
    dev.log('resetAplikasi()', name: 'MusicListProvider');
    _state = LoadState.idle;
    _songs = [];
    _error = null;
    _searchQuery = null;
    notifyListeners();
  }

  @override
  void dispose() {
    dev.log('dispose()', name: 'MusicListProvider');
    super.dispose();
  }
}
