import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:developer' as dev;
import '../models/music_daerah_model.dart';

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
    _initializeListeners();
  }

  void _initializeListeners() {
    _player.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;

      if (playerState.processingState == ProcessingState.completed) {
        dev.log('Track selesai, mereset...', name: 'MusicPlayerProvider');
        try {
          _player.seek(Duration.zero);
          _player.stop();
          _isPlaying = false;
        } catch (e) {
          dev.log('Error saat selesai: $e', name: 'MusicPlayerProvider');
        }
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
    dev.log(
      'setCurrentSong() - memuat: ${song.judul}',
      name: 'MusicPlayerProvider',
    );

    try {
      _currentSong = song;
      _errorMessage = null;
      _currentPosition = Duration.zero;
      _totalDuration = song.durasi ?? Duration.zero;

      await _player.setUrl(song.audioUrl);

      notifyListeners();
    } catch (e, st) {
      _errorMessage = 'Gagal memuat audio: $e';
      dev.log(
        'Error setCurrentSong: $e',
        name: 'MusicPlayerProvider',
        stackTrace: st,
      );
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) {
      dev.log(
        'togglePlayPause() - tidak ada lagu yang dipilih',
        name: 'MusicPlayerProvider',
      );
      return;
    }

    dev.log(
      'togglePlayPause() - sedang diputar: $_isPlaying',
      name: 'MusicPlayerProvider',
    );

    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        if (_player.audioSource == null) {
          await _player.setUrl(_currentSong!.audioUrl);
        }
        await _player.play();
      }
    } catch (e, st) {
      _errorMessage = 'Error playback: $e';
      dev.log(
        'Error togglePlayPause: $e',
        name: 'MusicPlayerProvider',
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
    dev.log(
      'seekTo() - posisi: ${position.inSeconds}s',
      name: 'MusicPlayerProvider',
    );
    try {
      await _player.seek(position);
      _currentPosition = position;
      notifyListeners();
    } catch (e, st) {
      dev.log('Error seekTo: $e', name: 'MusicPlayerProvider', stackTrace: st);
    }
  }

  Future<void> stop() async {
    dev.log('stop()', name: 'MusicPlayerProvider');
    try {
      await _player.stop();
      await _player.seek(Duration.zero);
      _isPlaying = false;
      _currentPosition = Duration.zero;
      _currentSong = null;
      notifyListeners();
    } catch (e, st) {
      dev.log('Error stop: $e', name: 'MusicPlayerProvider', stackTrace: st);
    }
  }

  void reset() {
    dev.log('reset()', name: 'MusicPlayerProvider');
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
    dev.log('dispose()', name: 'MusicPlayerProvider');
    _player.dispose();
    super.dispose();
  }
}
