class LaguDaerah {
  final int id;
  final String judul;
  final String asal;
  final String audioUrl;
  final Duration? durasi;

  const LaguDaerah({
    required this.id,
    required this.judul,
    required this.asal,
    required this.audioUrl,
    this.durasi,
  });

  factory LaguDaerah.fromMap(Map<String, dynamic> map) {
    Duration? parsedDuration;

    final durationData = map['durasi'];
    if (durationData != null) {
      if (durationData is int) {
        parsedDuration = Duration(seconds: durationData);
      } else if (durationData is String) {
        final parts = durationData.split(':');
        if (parts.length == 2) {
          final minutes = int.tryParse(parts[0]) ?? 0;
          final seconds = int.tryParse(parts[1]) ?? 0;
          parsedDuration = Duration(minutes: minutes, seconds: seconds);
        }
      }
    }

    return LaguDaerah(
      id: map['id'] as int,
      judul: (map['judul'] as String?)?.trim() ?? '-',
      asal: (map['asal'] as String?)?.trim() ?? '-',
      audioUrl: (map['audio_url'] as String?)?.trim() ?? '',
      durasi: parsedDuration,
    );
  }

  String get formattedDuration {
    if (durasi == null) return '--:--';
    final minutes = durasi!.inMinutes;
    final seconds = durasi!.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get hasValidAudioUrl {
    return audioUrl.isNotEmpty &&
        (audioUrl.startsWith('http://') || audioUrl.startsWith('https://'));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'asal': asal,
      'audio_url': audioUrl,
      'durasi': durasi?.inSeconds,
    };
  }

  LaguDaerah copyWith({
    int? id,
    String? judul,
    String? asal,
    String? audioUrl,
    Duration? durasi,
  }) {
    return LaguDaerah(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      asal: asal ?? this.asal,
      audioUrl: audioUrl ?? this.audioUrl,
      durasi: durasi ?? this.durasi,
    );
  }

  @override
  String toString() {
    return 'LaguDaerah(id: $id, judul: $judul, asal: $asal, duration: $formattedDuration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LaguDaerah &&
        other.id == id &&
        other.judul == judul &&
        other.asal == asal &&
        other.audioUrl == audioUrl &&
        other.durasi == durasi;
  }

  @override
  int get hashCode {
    return Object.hash(id, judul, asal, audioUrl, durasi);
  }
}
