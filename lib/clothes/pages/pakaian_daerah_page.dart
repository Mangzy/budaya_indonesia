import 'package:budaya_indonesia/common/static/app_color.dart';
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
    Future.microtask(() =>
        Provider.of<PakaianProvider>(context, listen: false).refresh());
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
      backgroundColor: AppColors.tertiary,
      appBar: AppBar(
        backgroundColor: AppColors.tertiary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pakaian Daerah',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  hintText: 'Cari nama pakaian atau provinsi',
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (_) {
                  if (state == LoadState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state == LoadState.error) {
                    return Center(
                      child: Text(
                        'Gagal memuat data.\n${provider.error ?? ""}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state == LoadState.loaded && items.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada data pakaian ditemukan.'),
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
      )
    );
  }
}
