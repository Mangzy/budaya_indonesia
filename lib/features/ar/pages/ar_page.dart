import 'package:budaya_indonesia/features/ar/providers/ar_provider.dart';
import 'package:budaya_indonesia/features/ar/widgets/ar_button_widget.dart';
import 'package:budaya_indonesia/features/ar/widgets/ar_guide_bottom_sheet.dart';
import 'package:budaya_indonesia/features/ar/widgets/ar_overlay_widget.dart';
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
        ],
      ),
    );
  }
}
