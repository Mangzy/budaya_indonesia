import 'package:flutter/material.dart';

/// Simple interactive 2D overlay viewer using [InteractiveViewer].
/// Provide an [image] to display above the camera preview and allow
/// pan/zoom/rotate gestures with a quick reset action.
class Ar2dViewer extends StatefulWidget {
  final ImageProvider image;
  final double minScale;
  final double maxScale;
  final double overlayOpacity;
  final bool flipHorizontally;
  final Color? handleColor; // visual cue button color
  final bool showFrame;

  const Ar2dViewer({
    super.key,
    required this.image,
    this.minScale = 0.5,
    this.maxScale = 5,
    this.overlayOpacity = 1.0,
    this.flipHorizontally = false,
    this.showFrame = false,
    this.handleColor,
  });

  @override
  State<Ar2dViewer> createState() => _Ar2dViewerState();
}

class _Ar2dViewerState extends State<Ar2dViewer> {
  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reset() {
    _controller.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gesture-based pan and zoom
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _controller,
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            boundaryMargin: const EdgeInsets.all(200),
            panEnabled: true,
            scaleEnabled: true,
            child: Center(
              child: Opacity(
                opacity: widget.overlayOpacity.clamp(0.0, 1.0),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(widget.flipHorizontally ? -1.0 : 1.0, 1.0, 1.0),
                  child: Image(image: widget.image, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ),

        // Optional decorative frame
        if (widget.showFrame)
          IgnorePointer(
            ignoring: true,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        // Reset button (small, non-intrusive)
        Positioned(
          right: 12,
          top: 12 + MediaQuery.of(context).padding.top,
          child: Material(
            color: widget.handleColor ?? Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _reset,
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(
                  Icons.center_focus_strong,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
