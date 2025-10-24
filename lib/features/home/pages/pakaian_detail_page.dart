import 'package:budaya_indonesia/common/static/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pakaian_daerah.dart';

class PakaianDetailPage extends StatelessWidget {
  final PakaianDaerah item;
  const PakaianDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Detail Pakaian',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          //Gambar pakaian
          Positioned(
            top: 12,
            left: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                item.imageUrl ??
                    'https://via.placeholder.com/400?text=No+Image',
                width: double.infinity,
                height: size.height * 0.35,
                fit: BoxFit.contain, // biar gak kepotong
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: size.height * 0.35,
                    alignment: Alignment.center,
                    color: Theme.of(context).colorScheme.surface,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: size.height * 0.35,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

          //deskripsi
          Positioned(
            top: size.height * 0.45,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama pakaian
                    Text(
                      item.nama,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Asal daerah
                    Text(
                      "Asal ${item.asal}",
                      style: GoogleFonts.montserrat(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Deskripsi
                    Text(
                      "Deskripsi",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.deskripsi,
                      textAlign: TextAlign.justify,
                      style: GoogleFonts.montserrat(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),

                    if (item.funFact != null && item.funFact!.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(
                        "FUN FACT",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.funFact!,
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.montserrat(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
