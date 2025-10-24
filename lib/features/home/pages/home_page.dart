import 'package:budaya_indonesia/features/login/pages/login_pages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:budaya_indonesia/common/static/app_color.dart';
import 'package:budaya_indonesia/src/auth_provider.dart';
import 'package:budaya_indonesia/features/home/models/province.dart';
import 'package:budaya_indonesia/features/home/pages/province_detail_page.dart';
import 'package:budaya_indonesia/features/home/pages/pakaian_detail_page.dart';
import 'package:budaya_indonesia/features/home/providers/pakaian_provider.dart';
import 'package:budaya_indonesia/features/home/widgets/indonesia_map.dart';
import 'package:budaya_indonesia/features/home/utils/province_svg_helper.dart';
import 'package:budaya_indonesia/features/home/widgets/banner_slider.dart';
import 'package:budaya_indonesia/features/quiz/providers/quiz_provider.dart';
import 'package:budaya_indonesia/features/quiz/models/quiz_model.dart';
import 'package:budaya_indonesia/features/quiz/pages/quiz_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _highlightedSvgId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const LoginPages();
    }

    final displayName = (user.displayName ?? '').trim();
    final fallbackName = (user.email ?? '').split('@').first;
    final helloName = displayName.isNotEmpty ? displayName : fallbackName;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Halo, $helloName',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner slider at the very top (slightly smaller height)
          const BannerSlider(aspectRatio: 16 / 8.5),
          const SizedBox(height: 16),
          Text(
            'Pilih Provinsi yang ingin kamu ketahui\nPakaian daerah dan lagu daerah',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              // Ocean-like background that adapts to theme
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0B2239)
                  : const Color(0xFFA0CEFF),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: LayoutBuilder(
                  builder: (context, c) {
                    // Build dynamic fill colors from Supabase data
                    final pakaianProv = context.watch<PakaianProvider>();
                    final Map<String, String> svgIdToProvince = {};
                    for (final it in pakaianProv.items) {
                      final normalized = normalizeAsalToProvince(it.asal);
                      if (normalized == null) continue;
                      final svgId = provinceNameToSvgId[normalized];
                      if (svgId == null) continue;
                      svgIdToProvince.putIfAbsent(svgId, () => normalized);
                    }
                    final ids = svgIdToProvince.keys.toList()..sort();
                    final palette = generateDistinctColors(ids.length);
                    final Map<String, Color> dynamicFills = {};
                    for (int i = 0; i < ids.length; i++) {
                      dynamicFills[ids[i]] = palette[i];
                    }

                    return IndonesiaMap(
                      highlightedId: _highlightedSvgId,
                      onTap: (svgId) {
                        setState(() => _highlightedSvgId = svgId);
                        // Robustly resolve province display name from SVG id
                        final displayName = provinceNameFromSvgId(svgId);
                        if (displayName == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Wilayah tidak dikenali: $svgId'),
                            ),
                          );
                          return;
                        }
                        // Prefer Supabase data if available
                        final items = context
                            .read<PakaianProvider>()
                            .byProvinsi(displayName);
                        if (items.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PakaianDetailPage(item: items[0]),
                            ),
                          );
                          return;
                        }
                        // Fallback to local province detail
                        final prov = provinces.firstWhere(
                          (p) =>
                              p.name.toLowerCase() == displayName.toLowerCase(),
                          orElse: () => Province(
                            id: displayName.toLowerCase(),
                            name: displayName,
                            attireName: '-',
                            description:
                                'Data detail belum tersedia. Silakan lengkapi data provinces.',
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProvinceDetailPage(province: prov),
                          ),
                        );
                      },
                      // Dynamic colors from Supabase
                      fillColors: dynamicFills,
                      defaultColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF90A4AE)
                          : const Color(0xFFE0E0E0),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quiz Budaya',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuizCard(
                  color: AppColors.primary,
                  icon: Icons.checkroom,
                  title: 'Pakaian Daerah',
                  questions: 10,
                  minutes: 5,
                  onTap: () {
                    _showQuizConfirmationDialog(
                      context,
                      'Quiz Pakaian Daerah',
                      QuizCategory.pakaian,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuizCard(
                  color: AppColors.primary,
                  icon: Icons.music_note,
                  title: 'Lagu Daerah',
                  questions: 10,
                  minutes: 5,
                  onTap: () {
                    _showQuizConfirmationDialog(
                      context,
                      'Quiz Lagu Daerah',
                      QuizCategory.lagu,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuizConfirmationDialog(
    BuildContext context,
    String quizTitle,
    QuizCategory category,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Mulai $quizTitle?',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Kamu akan mengikuti quiz dengan 10 soal dan waktu 5 menit.',
          style: GoogleFonts.montserrat(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Batal', style: GoogleFonts.montserrat(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final quizProv = context.read<QuizProvider>();
              try {
                await quizProv.loadQuestions(category);
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizPage()),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memulai quiz: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Mulai', style: GoogleFonts.montserrat(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // Search removed as requested

  @override
  void dispose() {
    super.dispose();
  }
}

// Banner slider extracted to widgets/banner_slider.dart

class _QuizCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final int questions;
  final int minutes;
  final VoidCallback onTap;
  const _QuizCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.questions,
    required this.minutes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(icon, color: color, size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.help_outline, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$questions pertanyaan',
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$minutes menit',
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// _ProvincePill removed after layout change; re-add if needed

// _SearchResult removed with search feature
