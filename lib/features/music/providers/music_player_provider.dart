import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/music_daerah_model.dart';
import 'dart:developer' as dev;

class MusicPlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  LaguDaerah? _currentSong;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _errorMessage;

  AudioPlayer get player => _player;
  LaguDaerah? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String? get errorMessage => _errorMessage;

  MusicPlayerProvider() {
    _initializeAudioPlayer();
    _initializeListeners();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _player.setVolume(1.0);
      dev.log(
        'Audio player diinisialisasi dengan volume: 1.0',
        name: 'MusicPlayerProvider',
      );
    } catch (e) {
      dev.log('Error inisialisasi audio: $e', name: 'MusicPlayerProvider');
    }
  }

  void _initializeListeners() {
    _player.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;

      dev.log(
        'Status Player: ${playerState.processingState}, Playing: ${playerState.playing}',
        name: 'MusicPlayerProvider',
      );

      if (playerState.processingState == ProcessingState.completed) {
        dev.log('Lagu selesai, mereset...', name: 'MusicPlayerProvider');
        _player.seek(Duration.zero);
        _player.stop();
        _isPlaying = false;
      }
      notifyListeners();
    });

    _player.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        dev.log(
          'Durasi dimuat: ${duration.inSeconds}s',
          name: 'MusicPlayerProvider',
        );
        if (_currentSong != null && _currentSong!.durasi == null) {
          _currentSong = _currentSong!.copyWith(durasi: duration);
        }
        notifyListeners();
      }
    });
  }

  String get formattedPosition {
    final minutes = _currentPosition.inMinutes;
    final seconds = _currentPosition.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDuration {
    if (_totalDuration == Duration.zero && _currentSong?.durasi != null) {
      return _currentSong!.formattedDuration;
    }

    final minutes = _totalDuration.inMinutes;
    final seconds = _totalDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  Future<void> setCurrentSong(LaguDaerah song) async {
    dev.log('=== setCurrentSong MULAI ===', name: 'MusicPlayerProvider');
    dev.log('Lagu: ${song.judul}', name: 'MusicPlayerProvider');
    dev.log('URL Audio: ${song.audioUrl}', name: 'MusicPlayerProvider');
    dev.log('URL Valid: ${song.hasValidAudioUrl}', name: 'MusicPlayerProvider');

    try {
      if (!song.hasValidAudioUrl) {
        throw Exception('URL audio tidak valid atau kosong');
      }

      _currentSong = song;
      _errorMessage = null;
      _currentPosition = Duration.zero;
      _totalDuration = song.durasi ?? Duration.zero;

      dev.log('Mengatur sumber audio...', name: 'MusicPlayerProvider');
      await _player.setUrl(song.audioUrl);
      dev.log('Sumber audio berhasil diatur!', name: 'MusicPlayerProvider');

      notifyListeners();
    } catch (e, st) {
      _errorMessage = 'Gagal memuat audio: $e';
      dev.log(
        'ERROR setCurrentSong: $e',
        name: 'MusicPlayerProvider',
        error: e,
        stackTrace: st,
      );
      notifyListeners();
      rethrow;
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) {
      dev.log('Tidak ada lagu yang dipilih', name: 'MusicPlayerProvider');
      return;
    }

    dev.log(
      'togglePlayPause - sedang diputar: $_isPlaying',
      name: 'MusicPlayerProvider',
    );

    try {
      if (_isPlaying) {
        dev.log('Menjeda...', name: 'MusicPlayerProvider');
        await _player.pause();
      } else {
        if (_player.audioSource == null) {
          dev.log(
            'Tidak ada sumber audio, memuat...',
            name: 'MusicPlayerProvider',
          );
          await _player.setUrl(_currentSong!.audioUrl);
        }

        final currentVolume = _player.volume;
        dev.log(
          'Volume saat ini sebelum play: $currentVolume',
          name: 'MusicPlayerProvider',
        );

        await _player.setVolume(1.0);
        dev.log('Volume diatur ke 1.0', name: 'MusicPlayerProvider');

        dev.log('Memutar...', name: 'MusicPlayerProvider');
        await _player.play();

        dev.log(
          'Perintah play terkirim, mengecek status...',
          name: 'MusicPlayerProvider',
        );
        dev.log(
          'Player sedang memutar: ${_player.playing}',
          name: 'MusicPlayerProvider',
        );
        dev.log(
          'Posisi player: ${_player.position.inSeconds}s',
          name: 'MusicPlayerProvider',
        );
      }
    } catch (e, st) {
      _errorMessage = 'Error playback: $e';
      dev.log(
        'ERROR togglePlayPause: $e',
        name: 'MusicPlayerProvider',
        error: e,
        stackTrace: st,
      );
      notifyListeners();
    }
  }

  Future<void> play(LaguDaerah song) async {
    await setCurrentSong(song);
    await togglePlayPause();
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _player.seek(position);
      _currentPosition = position;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      await _player.seek(Duration.zero);
      _isPlaying = false;
      _currentPosition = Duration.zero;
      _currentSong = null;
      notifyListeners();
    } catch (e) {}
  }

  void reset() {
    _player.stop();
    _currentSong = null;
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
