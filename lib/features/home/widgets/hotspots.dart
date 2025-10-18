class Hotspot {
  final String id; // province id
  final double left; // fraction 0..1
  final double top; // fraction 0..1
  final double width; // fraction 0..1
  final double height; // fraction 0..1
  const Hotspot({
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

// NOTE: Koordinat ini perkiraan; sesuaikan dengan aset SVG yang dipakai.
const List<Hotspot> defaultHotspots = [
  Hotspot(id: 'aceh', left: 0.06, top: 0.18, width: 0.12, height: 0.10),
  Hotspot(id: 'sumut', left: 0.10, top: 0.28, width: 0.12, height: 0.12),
  Hotspot(id: 'jakarta', left: 0.36, top: 0.45, width: 0.06, height: 0.06),
  Hotspot(id: 'jabar', left: 0.34, top: 0.50, width: 0.12, height: 0.08),
];
