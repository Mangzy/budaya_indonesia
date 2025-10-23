import 'dart:io';
import 'dart:ui' as ui;

import 'package:budaya_indonesia/features/ar/providers/ar2d_assets_provider.dart';
import 'package:budaya_indonesia/features/ar/widgets/ar_2d_viewer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:budaya_indonesia/features/ar/widgets/ar_checkerboard.dart';

class Ar2dCameraPage extends StatefulWidget {
  const Ar2dCameraPage({super.key});

  @override
  State<Ar2dCameraPage> createState() => _Ar2dCameraPageState();
}

class _Ar2dCameraPageState extends State<Ar2dCameraPage> {
  String? _selectedUrl; // selected 2D overlay image URL
  XFile? _bgFile; // chosen background photo (gallery/camera)
  final GlobalKey _captureKey = GlobalKey();
  double _overlayOpacity = 1.0;
  bool _flipX = false;

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (file != null) setState(() => _bgFile = file);
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95,
    );
    if (file != null) setState(() => _bgFile = file);
  }

  Future<File?> _exportCombinedImage() async {
    try {
      final boundary =
          _captureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final out = File(
        '${dir.path}/clothes_ar_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await out.writeAsBytes(bytes, flush: true);
      return out;
    } catch (e) {
      // ignore
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assets2d = context.watch<Ar2dAssetsProvider>();
    // Do NOT auto-select an item on first load; wait for user to pick.

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final pakaianNama = args?['pakaianNama'] as String?;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Editor 2D - ${pakaianNama ?? 'Pakaian'}'),
        actions: [
          IconButton(
            tooltip: 'Galeri',
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: _pickFromGallery,
          ),
          IconButton(
            tooltip: 'Kamera',
            icon: const Icon(Icons.photo_camera_outlined),
            onPressed: _takePhoto,
          ),
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<Ar2dAssetsProvider>().refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Canvas area (boxed) takes remaining height above the bottom panel
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _captureKey,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 48,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Stack(
                      children: [
                        Positioned.fill(child: ArCheckerboard(cellSize: 16)),
                        if (_bgFile == null)
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.88),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Pilih foto dari galeri atau ambil foto dulu',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Positioned.fill(
                            child: Image.file(
                              File(_bgFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (_selectedUrl != null)
                          Positioned.fill(
                            child: Ar2dViewer(
                              image: NetworkImage(_selectedUrl!),
                              overlayOpacity: _overlayOpacity,
                              flipHorizontally: _flipX,
                              handleColor: Colors.black45,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom selector & actions (no overlap with canvas)
          SafeArea(
            top: false,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_bgFile != null && _selectedUrl != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.opacity,
                              color: Colors.white70,
                              size: 18,
                            ),
                            Expanded(
                              child: Slider(
                                value: _overlayOpacity,
                                onChanged: (v) =>
                                    setState(() => _overlayOpacity = v),
                                min: 0,
                                max: 1,
                              ),
                            ),
                            IconButton(
                              tooltip: _flipX ? 'Normal' : 'Mirror',
                              icon: const Icon(Icons.flip, color: Colors.white),
                              onPressed: () => setState(() => _flipX = !_flipX),
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 74,
                        child: assets2d.loading
                            ? const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, i) {
                                  final it = assets2d.items[i];
                                  final selected = _selectedUrl == it.url;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedUrl = it.url),
                                    child: Container(
                                      width: 84,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? Colors.white10
                                            : Colors.black26,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selected
                                              ? Colors.white
                                              : Colors.white24,
                                          width: selected ? 2 : 1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          it.url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => const Icon(
                                            Icons.image,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemCount: assets2d.items.length,
                              ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _bgFile == null || _selectedUrl == null
                              ? null
                              : () async {
                                  final file = await _exportCombinedImage();
                                  if (!mounted) return;
                                  if (file == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Gagal menyimpan hasil'),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Tersimpan ke: ${file.path}',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.save_alt),
                          label: const Text('Simpan Hasil'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
