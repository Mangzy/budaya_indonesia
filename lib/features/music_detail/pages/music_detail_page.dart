import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:budaya_indonesia/features/music_detail/providers/music_provider.dart';
import 'package:budaya_indonesia/features/music_detail/models/music_model.dart';
import 'package:budaya_indonesia/features/music_detail/widgets/track_card_player.dart';

class MusicDetailPage extends StatefulWidget {
  final String? trackId; // optional, kalau null tampilkan list saja
  final String? zone; // WIB / WITA / WIT (optional)
  const MusicDetailPage({super.key, this.trackId, this.zone});

  @override
  State<MusicDetailPage> createState() => _MusicDetailPageState();
}

class _MusicDetailPageState extends State<MusicDetailPage> {
  @override
  void initState() {
    super.initState();
    // Tunda sampai frame pertama selesai dibangun agar tidak memicu
    // "setState() or markNeedsBuild() called during build" dari provider.notifyListeners.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = context.read<MusicDetailProvider>();
      final incomingZone = widget.zone?.toUpperCase();
      if (incomingZone != null) {
        // Selalu fetch khusus zona agar data benar-benar ter-refresh
        await prov.fetchForZone(incomingZone);
      } else if (prov.state.isNone) {
        await prov.fetchAll();
      }
      if (widget.trackId != null) {
        final t = prov.tracks.firstWhere(
          (e) => e.id == widget.trackId,
          orElse: () => prov.tracks.isNotEmpty
              ? prov.tracks.first
              : const MusicTrackDetail(
                  id: '',
                  title: 'Tidak ada',
                  region: '-',
                  timeZoneCode: '-',
                  fileName: '-',
                  publicUrl: '',
                ),
        );
        if (t.id.isNotEmpty) prov.play(t);
      }
    });
  }

  @override
  void dispose() {
    try {
      final prov = context.read<MusicDetailProvider>();
      prov.resetPlayback();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          final prov = context.read<MusicDetailProvider>();
          await prov.resetPlayback();
        } catch (_) {}
        return true; // izinkan pop setelah stop
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Musik Daerah',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: GoogleFonts.roboto().fontFamily,
            ),
          ),
        ),
        body: Consumer<MusicDetailProvider>(
          builder: (context, prov, _) {
            if (prov.state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (prov.state.isError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Gagal memuat: ${prov.state.message}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => prov.fetchAll(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }
            if (prov.tracks.isEmpty) {
              return const Center(child: Text('Belum ada data lagu.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
              itemCount: prov.tracks.length,
              itemBuilder: (context, index) {
                final track = prov.tracks[index];
                return TrackCardPlayer(track: track, showTime: false);
              },
            );
          },
        ),
      ),
    );
  }
}
