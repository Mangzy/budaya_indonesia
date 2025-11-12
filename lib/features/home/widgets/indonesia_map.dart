import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_drawing/path_drawing.dart';

typedef ProvinceTap = void Function(String provinceId);

/// Render Indonesia SVG map with per-province colors.
///
/// Provide [fillColors] with SVG path ids (e.g., 'ID-JB', 'ID-JT', 'ID-JI', 'ID-JK', etc.)
/// to color specific provinces. Others will use [defaultColor].
class IndonesiaMap extends StatefulWidget {
  final ProvinceTap onTap;
  final String? highlightedId;
  final Map<String, Color> fillColors;
  final Color defaultColor;
  final Color? strokeColor;
  final double strokeWidth;
  // Optional markers overlay
  final bool showMarkers;
  final double markerSize;
  final Widget Function(String id, bool isHighlighted)? markerBuilder;

  const IndonesiaMap({
    super.key,
    required this.onTap,
    this.highlightedId,
    this.fillColors = const {},
    this.defaultColor = const Color(0xFFBDBDBD), // grey 400
    this.strokeColor,
    this.strokeWidth = 0.6,
    this.showMarkers = false,
    this.markerSize = 18,
    this.markerBuilder,
  });

  @override
  State<IndonesiaMap> createState() => _IndonesiaMapState();
}

class _IndonesiaMapState extends State<IndonesiaMap> {
  String? _svg;
  // Parsed province shapes (viewport coordinates) keyed by SVG id
  final Map<String, Path> _provincePaths = {};
  Rect? _svgViewBox; // original SVG viewBox for scaling taps
  final TransformationController _controller = TransformationController();

  @override
  void initState() {
    super.initState();
    _loadAndColorize();
  }

  @override
  void didUpdateWidget(covariant IndonesiaMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fillColors != widget.fillColors ||
        oldWidget.defaultColor != widget.defaultColor ||
        oldWidget.highlightedId != widget.highlightedId ||
        oldWidget.strokeColor != widget.strokeColor ||
        oldWidget.strokeWidth != widget.strokeWidth) {
      _loadAndColorize();
    }
  }

  Future<void> _loadAndColorize() async {
    final raw = await rootBundle.loadString('assets/images/indonesiaHigh.svg');
    String svg = raw;

    // Ensure every province path with class="land" has a default inline fill
    // Inline fill overrides CSS class, and flutter_svg handles it reliably.
    final defaultHex = _toHex(widget.defaultColor);
    final landPathRegex = RegExp(
      r'<path([^>]*class="land"[^>/]*)(/?)>',
      multiLine: true,
      dotAll: true,
    );
    svg = svg.replaceAllMapped(landPathRegex, (m) {
      final attrs = m.group(1)!;
      final selfClose = m.group(2) == '/' ? '/>' : '>';
      // If already has style or fill, leave it; else, inject style fill.
      if (RegExp(r'(\s|^)fill\s*=').hasMatch(attrs) ||
          RegExp(r'(\s|^)style\s*=').hasMatch(attrs)) {
        return '<path$attrs$selfClose';
      }
      return '<path$attrs style="fill:$defaultHex"$selfClose';
    });

    // Apply per-id fill overrides.
    widget.fillColors.forEach((id, color) {
      final hex = _toHex(color);
      final idRegex = RegExp(
        '<path(?:(?!>).)*id="${RegExp.escape(id)}"[^>]*>',
        multiLine: true,
        dotAll: true,
      );
      svg = svg.replaceAllMapped(idRegex, (m) {
        final tag = m.group(0)!;
        // Replace existing style fill if present, else append style.
        if (tag.contains('style=')) {
          final styleRegex = RegExp(r'style\s*=\s*"([^"]*)"');
          return tag.replaceAllMapped(styleRegex, (sm) {
            final style = sm.group(1)!;
            // remove any existing fill: ...; then add our fill at start
            final cleaned = style
                .split(';')
                .where(
                  (e) => e.trim().isNotEmpty && !e.trim().startsWith('fill:'),
                )
                .join(';');
            final newStyle =
                'fill:$hex;${cleaned.isNotEmpty ? '$cleaned;' : ''}';
            return 'style="$newStyle"';
          });
        } else if (tag.endsWith('/>')) {
          return tag.replaceFirst('/>', ' style="fill:$hex"/>');
        } else {
          return tag.replaceFirst('>', ' style="fill:$hex">');
        }
      });
    });

    // Optionally apply stroke to highlighted province
    if (widget.highlightedId != null) {
      final hid = widget.highlightedId!;
      final strokeHex = _toHex(
        widget.strokeColor ?? Colors.black.withOpacity(0.6),
      );
      final idRegex = RegExp(
        '<path(?:(?!>).)*id="${RegExp.escape(hid)}"[^>]*>',
        multiLine: true,
        dotAll: true,
      );
      svg = svg.replaceAllMapped(idRegex, (m) {
        final tag = m.group(0)!;
        if (tag.contains('style=')) {
          final styleRegex = RegExp(r'style\s*=\s*"([^"]*)"');
          return tag.replaceAllMapped(styleRegex, (sm) {
            final style = sm.group(1)!;
            final cleaned = style
                .split(';')
                .where(
                  (e) =>
                      e.trim().isNotEmpty &&
                      !e.trim().startsWith('stroke:') &&
                      !e.trim().startsWith('stroke-width'),
                )
                .join(';');
            final newStyle =
                '${cleaned.isNotEmpty ? '$cleaned;' : ''}stroke:$strokeHex;stroke-width:${widget.strokeWidth}';
            return 'style="$newStyle"';
          });
        } else if (tag.endsWith('/>')) {
          return tag.replaceFirst(
            '/>',
            ' style="stroke:$strokeHex;stroke-width:${widget.strokeWidth}"/>',
          );
        } else {
          return tag.replaceFirst(
            '>',
            ' style="stroke:$strokeHex;stroke-width:${widget.strokeWidth}">',
          );
        }
      });
    }

    // Capture viewBox for coordinate transform
    _svgViewBox = _extractViewBox(svg);

    // Build path map for precise hit-testing
    _provincePaths
      ..clear()
      ..addAll(_extractProvincePaths(svg));

    if (mounted) setState(() => _svg = svg);
  }

  String _toHex(Color c) {
    return '#${c.red.toRadixString(16).padLeft(2, '0')}${c.green.toRadixString(16).padLeft(2, '0')}${c.blue.toRadixString(16).padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: 1.0,
      maxScale: 10.0,
      boundaryMargin: const EdgeInsets.all(150),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (_svg == null) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          final width = constraints.maxWidth;
          // Keep aspect ratio from viewBox if available

          final vb = _svgViewBox ?? const Rect.fromLTWH(0, 0, 700, 300);
          final aspect = vb.width / vb.height;
          final height = width / aspect;

          final scaleX = width / vb.width;
          final scaleY = height / vb.height;
          return SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                // Base SVG with gesture hit-testing on path shapes
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (details) {
                    final local = _controller.toScene(details.localPosition);
                    // Normalize to viewBox coordinates
                    final x = local.dx / scaleX + vb.left;
                    final y = local.dy / scaleY + vb.top;
                    final tapPoint = Offset(x, y);

                    for (final entry in _provincePaths.entries) {
                      if (entry.value.contains(tapPoint)) {
                        widget.onTap(entry.key);
                        return;
                      }
                    }
                  },
                  child: SvgPicture.string(
                    _svg!,
                    width: width,
                    height: height,
                    fit: BoxFit.fill,
                  ),
                ),

                // Optional location markers overlay
                if (widget.showMarkers)
                  ..._buildMarkers(width, height, vb, scaleX, scaleY),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildMarkers(
    double width,
    double height,
    Rect vb,
    double scaleX,
    double scaleY,
  ) {
    final List<Widget> markers = [];
    _provincePaths.forEach((id, path) {
      final b = path.getBounds();
      final cx = (b.left + b.right) / 2;
      final cy = (b.top + b.bottom) / 2;
      final px = (cx - vb.left) * scaleX;
      final py = (cy - vb.top) * scaleY;
      // Skip if outside
      if (px.isNaN || py.isNaN) return;
      if (px < 0 || py < 0 || px > width || py > height) return;

      final isHighlighted =
          widget.highlightedId?.toUpperCase() == id.toUpperCase();
      final icon =
          widget.markerBuilder?.call(id, isHighlighted) ??
          Icon(
            Icons.location_on,
            size: widget.markerSize,
            color: isHighlighted ? Colors.redAccent : Colors.teal,
          );

      markers.add(
        Positioned(
          left: px - widget.markerSize / 2,
          top: py - widget.markerSize / 2,
          child: GestureDetector(onTap: () => widget.onTap(id), child: icon),
        ),
      );
    });
    return markers;
  }

  // Extract SVG viewBox as Rect
  Rect? _extractViewBox(String svg) {
    final vbRe = RegExp(
      r'viewBox\s*=\s*"([\d\.-]+)\s+([\d\.-]+)\s+([\d\.-]+)\s+([\d\.-]+)"',
    );
    final m = vbRe.firstMatch(svg);
    if (m == null) return null;
    return Rect.fromLTWH(
      double.parse(m.group(1)!),
      double.parse(m.group(2)!),
      double.parse(m.group(3)!),
      double.parse(m.group(4)!),
    );
  }

  // Parse <path id="..." d="..." [transform] ...> into Flutter Path, keyed by id
  Map<String, Path> _extractProvincePaths(String svg) {
    final Map<String, Path> out = {};
    // Capture id, d, and optional transform
    final re = RegExp(
      r'<path[^>]*\bid="([^"]+)"[^>]*\bd="([^"]+)"[^>]*>',
      multiLine: true,
      caseSensitive: false,
    );
    for (final m in re.allMatches(svg)) {
      final id = m.group(1)!;
      final d = m.group(2)!;
      // extract transform attribute (optional) from the matched tag string
      final tag = m.group(0)!;
      Float64List? mat4;
      final tfmMatch = RegExp(r'transform\s*=\s*"([^"]+)"').firstMatch(tag);
      if (tfmMatch != null) {
        mat4 = _parseSvgTransform(tfmMatch.group(1)!);
      }
      try {
        Path path = parseSvgPathData(d);
        if (mat4 != null) {
          path = path.transform(mat4);
        }
        out[id] = path;
      } catch (_) {
        // ignore malformed path
      }
    }
    return out;
  }

  // Very small subset of SVG transform parsing: translate(x[,y]), scale(s[,sy]), matrix(a,b,c,d,e,f)
  Float64List _identity4() => Float64List.fromList(<double>[
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1,
  ]);

  Float64List _parseSvgTransform(String input) {
    var m = _identity4();
    final ops = RegExp(
      r'(translate|scale|matrix)\s*\(([^\)]*)\)',
    ).allMatches(input);
    for (final op in ops) {
      final name = op.group(1)!.toLowerCase();
      final params = op
          .group(2)!
          .split(RegExp(r'[\s,]+'))
          .where((e) => e.trim().isNotEmpty)
          .map((e) => double.tryParse(e) ?? 0)
          .toList();
      Float64List t = _identity4();
      if (name == 'translate') {
        final tx = params.isNotEmpty ? params[0] : 0.0;
        final ty = params.length > 1 ? params[1] : 0.0;
        t[12] = tx; // x translation in matrix4
        t[13] = ty; // y translation
      } else if (name == 'scale') {
        final sx = params.isNotEmpty ? params[0] : 1.0;
        final sy = params.length > 1 ? params[1] : sx;
        t[0] = sx; // scale x
        t[5] = sy; // scale y
      } else if (name == 'matrix' && params.length >= 6) {
        final a = params[0],
            b = params[1],
            c = params[2],
            d = params[3],
            e = params[4],
            f = params[5];
        // SVG 2D matrix maps to 4x4 as:
        // [ a c 0 e ]
        // [ b d 0 f ]
        // [ 0 0 1 0 ]
        // [ 0 0 0 1 ]
        t[0] = a;
        t[4] = c;
        t[12] = e;
        t[1] = b;
        t[5] = d;
        t[13] = f;
      }
      m = _mul4(m, t);
    }
    return m;
  }

  // Multiply 4x4 matrices (column-major per Flutter)
  Float64List _mul4(Float64List a, Float64List b) {
    final r = Float64List(16);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        double sum = 0;
        for (int k = 0; k < 4; k++) {
          sum += a[row + k * 4] * b[k + col * 4];
        }
        r[row + col * 4] = sum;
      }
    }
    return r;
  }
}
