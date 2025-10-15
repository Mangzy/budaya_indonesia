import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/music_list_provider.dart';
import '../providers/music_player_provider.dart';
import '../widgets/music_player_card.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load lagu saat pertama kali masuk halaman
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MusicListProvider>();
      if (provider.state == LoadState.idle) {
        provider.loadAll();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Stop player saat keluar dari halaman musik
    context.read<MusicPlayerProvider>().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light green background
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF4DB6AC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back atau handle sesuai kebutuhan
            // Karena ini di dalam bottom navbar, biasanya tidak perlu back
            // Tapi sesuai mockup ada back button, jadi saya tambahkan
          },
        ),
        title: Text(
          'Lagu Daerah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
            fontFamily: GoogleFonts.roboto().fontFamily,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFE8F5E9),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<MusicListProvider>().searchSongs(value);
              },
              decoration: InputDecoration(
                hintText: 'Cari nama lagu atau provinsi',
                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade600),
                        onPressed: () {
                          _searchController.clear();
                          context.read<MusicListProvider>().clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // List lagu
          Expanded(
            child: Consumer<MusicListProvider>(
              builder: (context, provider, _) {
                // Loading state
                if (provider.state == LoadState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4DB6AC)),
                  );
                }

                // Error state
                if (provider.state == LoadState.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat lagu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error ?? 'Terjadi kesalahan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => provider.refresh(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DB6AC),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Empty state
                final songs = provider.filteredSongs;
                if (songs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.searchQuery != null &&
                                  provider.searchQuery!.isNotEmpty
                              ? 'Tidak ada lagu ditemukan'
                              : 'Belum ada lagu tersedia',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // List lagu dengan MusicPlayerCard
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return MusicPlayerCard(song: song);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
