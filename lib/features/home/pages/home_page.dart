import 'dart:async';
import 'package:budaya_indonesia/features/login/pages/login_pages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budaya_indonesia/src/auth_provider.dart';
import 'package:budaya_indonesia/features/home/models/province.dart';
import 'package:budaya_indonesia/features/home/pages/province_detail_page.dart';
import 'package:budaya_indonesia/features/home/pages/pakaian_detail_page.dart';
import 'package:budaya_indonesia/features/home/providers/pakaian_provider.dart';
import 'package:budaya_indonesia/features/home/widgets/indonesia_map.dart';
import 'package:budaya_indonesia/features/home/utils/province_svg_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _highlightedSvgId;
  final TextEditingController _searchCtrl = TextEditingController();
  List<_SearchResult> _searchResults = [];
  String _searchQuery = '';
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const LoginPages();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Adatverse')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari pakaian adat atau provinsi...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isNotEmpty) _buildSearchResults(context),
          if (_searchQuery.isNotEmpty)
            const SizedBox(height: 12)
          else
            const SizedBox(height: 16),
          Text(
            'Peta Interaktif Indonesia',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          AspectRatio(
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
                    final items = context.read<PakaianProvider>().byProvinsi(
                      displayName,
                    );
                    // Debug prints for selection
                    // ignore: avoid_print
                    print(
                      '[Tap] Provinsi: $displayName, hasil: ${items.length}',
                    );
                    for (final it in items.take(3)) {
                      // ignore: avoid_print
                      print('  → #${it.id} ${it.nama} (${it.asal})');
                    }
                    if (items.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PakaianDetailPage(item: items[0]),
                        ),
                      );
                      return;
                    }
                    // Fallback ke detail lokal bila Supabase kosong
                    final prov = provinces.firstWhere(
                      (p) => p.name.toLowerCase() == displayName.toLowerCase(),
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
                  defaultColor: const Color(0xFFE0E0E0),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Rekomendasi',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 84,
            child: Builder(
              builder: (context) {
                final pakaianItems = context.watch<PakaianProvider>().items;
                if (pakaianItems.isNotEmpty) {
                  // Deduplicate provinces from Supabase items, shuffle for randomness
                  final List<String> provs = [];
                  final Set<String> seen = {};
                  final Map<String, dynamic> firstByProv = {};
                  for (final it in pakaianItems) {
                    final name = normalizeAsalToProvince(it.asal) ?? it.asal;
                    if (!seen.contains(name)) {
                      seen.add(name);
                      provs.add(name);
                      firstByProv[name] = it;
                    }
                  }
                  provs.shuffle();
                  final count = provs.length.clamp(6, 12);
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) {
                      final provName = provs[i % provs.length];
                      final firstItem = firstByProv[provName];
                      return _ProvincePill(
                        text: provName,
                        onTap: () {
                          if (firstItem != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PakaianDetailPage(item: firstItem),
                              ),
                            );
                          }
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: count,
                  );
                }
                // Fallback: use local province list
                final shuffled = List.of(provinces)..shuffle();
                final count = shuffled.length.clamp(6, 12);
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    final p = shuffled[i % shuffled.length];
                    return _ProvincePill(
                      text: p.name,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProvinceDetailPage(province: p),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: count,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      final q = value.trim();
      if (!mounted) return;
      if (q.isEmpty) {
        setState(() {
          _searchQuery = '';
          _searchResults = [];
        });
        return;
      }

      final lower = q.toLowerCase();
      final provider = context.read<PakaianProvider>();

      final List<_SearchResult> results = [];
      final Set<String> seen = {};

      // Search in Supabase pakaian items
      for (final it in provider.items) {
        final nama = it.nama.toLowerCase();
        final asal = (it.asal).toLowerCase();
        final desc = it.deskripsi.toLowerCase();
        if (nama.contains(lower) ||
            asal.contains(lower) ||
            desc.contains(lower)) {
          final key = 'pakaian:${it.id}';
          if (seen.add(key)) {
            results.add(
              _SearchResult(
                title: it.nama,
                subtitle: normalizeAsalToProvince(it.asal) ?? it.asal,
                icon: Icons.style,
                onTap: () {
                  final provName = normalizeAsalToProvince(it.asal) ?? it.asal;
                  final svgId = provinceNameToSvgId[provName];
                  setState(() {
                    _highlightedSvgId = svgId;
                    _searchQuery = '';
                    _searchResults = [];
                  });
                  _searchCtrl.clear();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PakaianDetailPage(item: it),
                    ),
                  );
                },
              ),
            );
          }
        }
        if (results.length >= 8) break; // quick cap to keep list short
      }

      // Also match local provinces
      if (results.length < 8) {
        for (final p in provinces) {
          if (p.name.toLowerCase().contains(lower)) {
            final key = 'prov:${p.name.toLowerCase()}';
            if (seen.add(key)) {
              results.add(
                _SearchResult(
                  title: p.name,
                  subtitle: 'Provinsi',
                  icon: Icons.place,
                  onTap: () {
                    final svgId = provinceNameToSvgId[p.name];
                    setState(() {
                      _highlightedSvgId = svgId;
                      _searchQuery = '';
                      _searchResults = [];
                    });
                    _searchCtrl.clear();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProvinceDetailPage(province: p),
                      ),
                    );
                  },
                ),
              );
            }
            if (results.length >= 8) break;
          }
        }
      }

      setState(() {
        _searchQuery = q;
        _searchResults = results;
      });
    });
  }

  Widget _buildSearchResults(BuildContext context) {
    final theme = Theme.of(context);
    if (_searchResults.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: const [
            Icon(Icons.search_off, size: 16),
            SizedBox(width: 8),
            Text('Tidak ada hasil'),
          ],
        ),
      );
    }
    return Material(
      elevation: 1,
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemBuilder: (_, i) {
            final r = _searchResults[i];
            return ListTile(
              leading: Icon(r.icon, color: Colors.teal),
              title: Text(
                r.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(r.subtitle),
              onTap: r.onTap,
              dense: true,
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: _searchResults.length,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }
}

class _ProvincePill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _ProvincePill({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.place, size: 16, color: Colors.teal),
              const SizedBox(width: 8),
              Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResult {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  _SearchResult({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
