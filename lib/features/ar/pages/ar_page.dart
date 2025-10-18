import 'package:budaya_indonesia/features/ar/providers/ar_provider.dart';
import 'package:budaya_indonesia/features/ar/providers/ar_assets_provider.dart';
import 'package:budaya_indonesia/features/ar/widgets/ar_button_widget.dart';
import 'package:budaya_indonesia/features/ar/widgets/ar_guide_bottom_sheet.dart';
import 'package:budaya_indonesia/features/ar/widgets/ar_overlay_widget.dart';
import 'package:budaya_indonesia/features/ar/pages/ar_model_viewer_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArPage extends StatefulWidget {
  const ArPage({super.key});

  @override
  State<ArPage> createState() => _ArPageState();
}

class _ArPageState extends State<ArPage> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  String? _selectedModelName;

  @override
  void initState() {
    super.initState();
    _initializeCamera(isFront: true);
  }

  Future<void> _initializeCamera({required bool isFront}) async {
    final provider = context.read<ArProvider>();
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final backCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final selectedCamera = isFront ? frontCamera : backCamera;

    _controller = CameraController(selectedCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller!.initialize();
    await _initializeControllerFuture;
    provider.setFrontCamera(isFront);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArProvider>();
    final assets = context.watch<ArAssetsProvider>();

    // Set default selected model when list becomes available
    if ((_selectedModelName == null ||
            !assets.items.any((e) => e.name == _selectedModelName)) &&
        assets.items.isNotEmpty) {
      // avoid calling setState in build multiple times
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedModelName = assets.items.first.name);
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_controller != null)
            FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller!);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          else
            const Center(child: CircularProgressIndicator()),
          const ArOverlayWidget(),

          // Model selector overlay (top)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedModelName,
                          iconEnabledColor: Colors.white,
                          dropdownColor: Colors.black87,
                          style: const TextStyle(color: Colors.white),
                          hint: const Text(
                            'Pilih model 3D',
                            style: TextStyle(color: Colors.white70),
                          ),
                          items: assets.items
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e.name,
                                  child: Text(
                                    e.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() => _selectedModelName = val);
                            if (val != null) {
                              final item = assets.items.firstWhere(
                                (e) => e.name == val,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Model dipilih: ${item.name}'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (assets.loading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: () async {
                            await context.read<ArAssetsProvider>().refresh();
                            if (!mounted) return;
                            if (assets.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal memuat aset: ${assets.error}',
                                  ),
                                ),
                              );
                            } else if (assets.items.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Bucket kosong atau tidak ditemukan',
                                  ),
                                ),
                              );
                            } else if (_selectedModelName == null ||
                                !assets.items.any(
                                  (e) => e.name == _selectedModelName,
                                )) {
                              setState(() {
                                _selectedModelName = assets.items.first.name;
                              });
                            }
                          },
                        ),
                      const SizedBox(width: 4),
                      Text(
                        assets.items.isEmpty
                            ? '0 item'
                            : '${assets.items.length} item',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // bucket status / error indicator
          Positioned(
            right: 8,
            top: 8 + MediaQuery.of(context).padding.top,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                assets.loading
                    ? 'Memuat…'
                    : (assets.error != null
                          ? 'Error aset'
                          : (assets.bucketUsed ?? 'Bucket?')),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),

          if (!assets.loading && assets.error == null && assets.items.isEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Tidak ada model .glb di bucket',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

          // Tombol bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ArButtonWidget(
                  onCapture: () async {
                    try {
                      await _initializeControllerFuture;
                      final image = await _controller!.takePicture();
                      debugPrint('Foto diambil: ${image.path}');
                    } catch (e) {
                      debugPrint('Error ambil foto: $e');
                    }
                  },
                  onSwitchCamera: () async {
                    final newFront = !provider.isFrontCamera;
                    await _initializeCamera(isFront: newFront);
                  },
                  onHelp: () {
                    ArGuideBottomSheet.show(context);
                  },
                ),
              ),
            ),
          ),

          // Open AR viewer button (right-bottom) when a model is selected
          if (_selectedModelName != null &&
              assets.items.any((e) => e.name == _selectedModelName))
            Positioned(
              right: 16,
              bottom: 32,
              child: SafeArea(
                child: FloatingActionButton.extended(
                  onPressed: () {
                    final item = assets.items.firstWhere(
                      (e) => e.name == _selectedModelName,
                      orElse: () => assets.items.first,
                    );
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
                  icon: const Icon(Icons.view_in_ar),
                  label: const Text('Lihat AR'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
