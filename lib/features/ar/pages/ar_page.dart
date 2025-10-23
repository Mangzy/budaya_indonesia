import 'package:budaya_indonesia/features/ar/providers/ar_assets_provider.dart';
import 'package:budaya_indonesia/features/ar/pages/ar_model_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArPage extends StatefulWidget {
  const ArPage({super.key});

  @override
  State<ArPage> createState() => _ArPageState();
}

class _ArPageState extends State<ArPage> {
  String? _selectedModelName;

  @override
  Widget build(BuildContext context) {
    final assets3d = context.watch<ArAssetsProvider>();

    // Set default selected model when list becomes available
    if ((_selectedModelName == null ||
            !assets3d.items.any((e) => e.name == _selectedModelName)) &&
        assets3d.items.isNotEmpty) {
      // avoid calling setState in build multiple times
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedModelName = assets3d.items.first.name);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AR 3D'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ArAssetsProvider>().refresh(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (assets3d.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (assets3d.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Gagal memuat aset 3D\n${assets3d.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (assets3d.items.isEmpty) {
            return const Center(
              child: Text('Tidak ada model 3D (.glb) di bucket.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: assets3d.items.length,
            itemBuilder: (context, i) {
              final item = assets3d.items[i];
              return _ModelCard(
                name: item.name,
                thumbnailUrl: item.thumbnailUrl,
                onOpen: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArModelViewerPage(
                        srcUrl: item.url,
                        title: item.name,
                        iosSrcUrl: item.iosUrl,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final String name;
  final String? thumbnailUrl;
  final VoidCallback onOpen;
  const _ModelCard({
    required this.name,
    required this.onOpen,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: thumbnailUrl != null
                    ? Image.network(
                        thumbnailUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (c, child, progress) => progress == null
                            ? child
                            : Container(
                                alignment: Alignment.center,
                                color: Colors.grey.shade200,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.view_in_ar,
                            size: 40,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.view_in_ar,
                          size: 40,
                          color: Colors.black54,
                        ),
                      ),
              ),
              // Label gradient
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
