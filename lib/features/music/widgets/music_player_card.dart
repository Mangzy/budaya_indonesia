import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../common/static/app_color.dart';
import '../models/music_daerah_model.dart';
import '../providers/music_player_provider.dart';

class MusicPlayerCard extends StatelessWidget {
  final LaguDaerah song;

  const MusicPlayerCard({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<MusicPlayerProvider>();
    final isCurrentSong = playerProvider.currentSong?.id == song.id;
    final isPlaying = playerProvider.isPlaying && isCurrentSong;
    final hasError = playerProvider.errorMessage != null && isCurrentSong;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: hasError ? Colors.red.shade400 : AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${song.judul} - ${song.asal}',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (hasError) ...[
                    const SizedBox(height: 4),
                    Text(
                      playerProvider.errorMessage!,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: isCurrentSong ? playerProvider.progress : 0.0,
                      onChanged: isCurrentSong
                          ? (value) {
                              final position = Duration(
                                milliseconds:
                                    (playerProvider
                                                .totalDuration
                                                .inMilliseconds *
                                            value)
                                        .toInt(),
                              );
                              playerProvider.seekTo(position);
                            }
                          : null,
                      min: 0.0,
                      max: 1.0,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isCurrentSong
                              ? playerProvider.formattedPosition
                              : '00:00',
                          style: GoogleFonts.montserrat(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          isCurrentSong
                              ? playerProvider.formattedDuration
                              : song.formattedDuration,
                          style: GoogleFonts.montserrat(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () async {
                  if (isCurrentSong) {
                    await playerProvider.togglePlayPause();
                  } else {
                    await playerProvider.play(song);
                  }
                },
                customBorder: const CircleBorder(),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
