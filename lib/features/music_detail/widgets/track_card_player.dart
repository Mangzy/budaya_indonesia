import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:budaya_indonesia/features/music_detail/providers/music_provider.dart';
import 'package:budaya_indonesia/features/music_detail/models/music_model.dart';

/// TrackCardPlayer
/// Reusable card-style audio item widget.
/// Fitur:
///  - Tampilkan judul
///  - Slider progress hanya aktif pada track yang sedang diputar
///  - Tombol Play/Pause (ubah otomatis saat status berubah)
///  - Opsional tampilkan waktu posisi/total
class TrackCardPlayer extends StatelessWidget {
  final MusicTrackDetail track;
  final bool showTime;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final double playButtonSize;
  final double sliderThumbRadius;

  const TrackCardPlayer({
    super.key,
    required this.track,
    this.showTime = false,
    this.backgroundColor,
    this.padding = const EdgeInsets.fromLTRB(12, 10, 12, 14),
    this.playButtonSize = 54,
    this.sliderThumbRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MusicDetailProvider>();
    final theme = Theme.of(context);
    final isActive = track.id == prov.current?.id;
    final player = prov.player; // single shared player

    return Card(
      color: (backgroundColor ?? theme.colorScheme.primary.withOpacity(0.35)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track.title.isEmpty ? 'Judul' : track.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _ProgressBar(
              isActive: isActive,
              player: player,
              enabled: isActive,
              sliderThumbRadius: sliderThumbRadius,
              showTime: showTime,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _PlayButton(
                isActive: isActive,
                track: track,
                size: playButtonSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isActive;
  final MusicTrackDetail track;
  final double size;
  const _PlayButton({
    required this.isActive,
    required this.track,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MusicDetailProvider>();
    final playing = prov.isPlaying && isActive;
    return InkWell(
      onTap: () => prov.togglePlay(track),
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE0E0E0),
        ),
        child: Icon(
          playing ? Icons.pause : Icons.play_arrow,
          size: size * 0.55,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final bool isActive;
  final AudioPlayer player;
  final bool enabled;
  final bool showTime;
  final double sliderThumbRadius;
  const _ProgressBar({
    required this.isActive,
    required this.player,
    required this.enabled,
    required this.sliderThumbRadius,
    this.showTime = false,
  });

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, durSnap) {
        final total = (isActive ? durSnap.data : null) ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, posSnap) {
            final pos = (isActive ? posSnap.data : null) ?? Duration.zero;
            final value = total.inMilliseconds == 0
                ? 0.0
                : pos.inMilliseconds / total.inMilliseconds;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.5,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: enabled ? sliderThumbRadius : 0,
                    ),
                  ),
                  child: Slider(
                    value: value.clamp(0.0, 1.0),
                    onChanged: enabled && total.inMilliseconds > 0
                        ? (v) {
                            final seekPos = Duration(
                              milliseconds: (total.inMilliseconds * v).toInt(),
                            );
                            player.seek(seekPos);
                          }
                        : null,
                    onChangeStart: enabled ? (_) {} : null,
                    onChangeEnd: enabled
                        ? (v) {
                            // Pastikan seek final untuk posisi akhir drag
                            final seekPos = Duration(
                              milliseconds: (total.inMilliseconds * v).toInt(),
                            );
                            player.seek(seekPos);
                          }
                        : null,
                  ),
                ),
                if (showTime)
                  Text(
                    '${_fmt(pos)} / ${_fmt(total)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
