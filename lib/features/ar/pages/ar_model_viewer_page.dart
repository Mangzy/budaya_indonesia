import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ArModelViewerPage extends StatelessWidget {
  final String srcUrl; // GLB
  final String title;
  final String? iosSrcUrl; // USDZ for iOS (optional)
  const ArModelViewerPage({
    super.key,
    required this.srcUrl,
    required this.title,
    this.iosSrcUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: ModelViewer(
              src: srcUrl,
              iosSrc: iosSrcUrl, // Quick Look will be used on iOS when set
              ar: true,
              arModes: const ['scene-viewer', 'quick-look'],
              autoRotate: true,
              cameraControls: true,
            ),
          ),
          if (Platform.isIOS && iosSrcUrl == null)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Tip: Untuk AR di iOS, sediakan file .usdz dengan nama yang sama. Saat ini akan tampil sebagai 3D viewer tanpa AR.',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
