import 'dart:async';
import 'package:flutter/material.dart';

class BannerSlider extends StatefulWidget {
  final double aspectRatio; // width/height
  final Duration interval;
  const BannerSlider({
    super.key,
    this.aspectRatio = 16 / 9,
    this.interval = const Duration(seconds: 4),
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final _controller = PageController(viewportFraction: 1.0);
  final _images = const [
    'assets/banner/1.png',
    'assets/banner/2.jpeg',
    'assets/banner/3.jpg',
    'assets/banner/4.jpg',
  ];
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      final next = (_index + 1) % _images.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: _images.length,
              itemBuilder: (_, i) => Image.asset(_images[i], fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_images.length, (i) {
            final active = i == _index;
            final scheme = Theme.of(context).colorScheme;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? scheme.primary
                    : scheme.onSurface.withOpacity(.25),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }
}
