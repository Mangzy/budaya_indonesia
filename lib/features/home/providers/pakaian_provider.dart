import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pakaian_daerah.dart';

enum LoadState { idle, loading, loaded, error }

class PakaianProvider extends ChangeNotifier {
  final SupabaseClient client;
  PakaianProvider({required this.client});

  LoadState _state = LoadState.idle;
  String? _error;
  List<PakaianDaerah> _items = [];

  LoadState get state => _state;
  String? get error => _error;
  List<PakaianDaerah> get items => _items;

  Future<void> refresh() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();
    try {
      final res = await client.from('pakaian_daerah').select();
      final list = (res as List)
          .cast<Map<String, dynamic>>()
          .map(PakaianDaerah.fromMap)
          .toList();
      _items = list;
      // Debug prints
      // ignore: avoid_print
      print('[Supabase] pakaian_daerah count: ${_items.length}');
      for (final it in _items.take(5)) {
        // ignore: avoid_print
        print('[Supabase] → #${it.id} ${it.nama} (${it.asal})');
      }
      _state = LoadState.loaded;
    } catch (e) {
      _error = e.toString();
      // ignore: avoid_print
      print('[Supabase] pakaian_daerah error: $_error');
      _state = LoadState.error;
    }
    notifyListeners();
  }

  List<PakaianDaerah> byProvinsi(String provinsiName) {
    final p = provinsiName.toLowerCase();
    return _items
        .where((e) => e.asal.toLowerCase() == p)
        .toList(growable: false);
  }
}
