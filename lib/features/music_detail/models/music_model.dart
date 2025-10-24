class MusicTrackDetail {
  final String id; // path dalam storage
  final String title;
  final String region; // asal daerah
  final String timeZoneCode; // WIB/WITA/WIT
  final String fileName;
  final String publicUrl;
  final Duration? duration; // bisa null sebelum probing

  const MusicTrackDetail({
    required this.id,
    required this.title,
    required this.region,
    required this.timeZoneCode,
    required this.fileName,
    required this.publicUrl,
    this.duration,
  });

  MusicTrackDetail copyWith({Duration? duration}) => MusicTrackDetail(
    id: id,
    title: title,
    region: region,
    timeZoneCode: timeZoneCode,
    fileName: fileName,
    publicUrl: publicUrl,
    duration: duration ?? this.duration,
  );
}
