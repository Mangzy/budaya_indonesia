import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerControls extends StatefulWidget {
  final AudioPlayer player;
  final String Function(Duration) fmt;
  const PlayerControls({super.key, required this.player, required this.fmt});

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<PlayerState>(
          stream: widget.player.playerStateStream,
          builder: (context, snap) {
            final playing = snap.data?.playing ?? false;
            return Row(
              children: [
                IconButton(
                  icon: Icon(
                    playing ? Icons.pause_circle : Icons.play_circle,
                    size: 48,
                  ),
                  onPressed: () {
                    playing ? widget.player.pause() : widget.player.play();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () => widget.player.stop(),
                ),
              ],
            );
          },
        ),
        StreamBuilder<Duration?>(
          stream: widget.player.durationStream,
          builder: (context, durSnap) {
            final total = durSnap.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: widget.player.positionStream,
              builder: (context, posSnap) {
                final pos = posSnap.data ?? Duration.zero;
                final value = total.inMilliseconds == 0
                    ? 0.0
                    : pos.inMilliseconds / total.inMilliseconds;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: value.clamp(0.0, 1.0),
                      onChanged: (v) {
                        final seekPos = Duration(
                          milliseconds: (total.inMilliseconds * v).toInt(),
                        );
                        widget.player.seek(seekPos);
                      },
                    ),
                    Text('${widget.fmt(pos)} / ${widget.fmt(total)}'),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
