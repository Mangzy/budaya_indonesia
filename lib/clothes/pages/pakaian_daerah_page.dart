import 'package:budaya_indonesia/features/home/providers/pakaian_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/pakaian_card_widget.dart';

class PakaianDaerahPage extends StatefulWidget {
  const PakaianDaerahPage({super.key});

  @override
  State<PakaianDaerahPage> createState() => _PakaianDaerahPageState();
}

class _PakaianDaerahPageState extends State<PakaianDaerahPage> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<PakaianProvider>(context, listen: false).refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PakaianProvider>(context);
    final state = provider.state;
    final items = provider.items.where((p) {
      final query = searchQuery.toLowerCase();
      return p.nama.toLowerCase().contains(query) ||
          p.asal.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Pakaian Daerah',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Cari nama pakaian atau provinsi',
                  hintStyle: GoogleFonts.montserrat(fontSize: 13),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (_) {
                  if (state == LoadState.loading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  } else if (state == LoadState.error) {
                    return Center(
                      child: Text(
                        'Gagal memuat data.\n${provider.error ?? ""}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  } else if (state == LoadState.loaded && items.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada data pakaian ditemukan.',
                        style: GoogleFonts.montserrat(fontSize: 14),
                      ),
                    );
                  }

                  return GridView.builder(
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                    itemBuilder: (context, index) {
                      final pakaian = items[index];
                      return PakaianCardWidget(pakaian: pakaian);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
