import 'package:flutter/material.dart';

/// Mapping official province names to SVG path ids (ISO 3166-2:ID codes used in most maps)
const Map<String, String> provinceNameToSvgId = {
  'Aceh': 'ID-AC',
  'Sumatera Utara': 'ID-SU',
  'Sumatera Barat': 'ID-SB',
  'Riau': 'ID-RI',
  'Kepulauan Riau': 'ID-KR',
  'Jambi': 'ID-JA',
  'Sumatera Selatan': 'ID-SS',
  'Bengkulu': 'ID-BE',
  'Lampung': 'ID-LA',
  'Kepulauan Bangka Belitung': 'ID-BB',
  'DKI Jakarta': 'ID-JK',
  'Jawa Barat': 'ID-JB',
  'Jawa Tengah': 'ID-JT',
  'DI Yogyakarta': 'ID-YO',
  'Daerah Istimewa Yogyakarta': 'ID-YO',
  'Jawa Timur': 'ID-JI',
  'Banten': 'ID-BT',
  'Bali': 'ID-BA',
  'Nusa Tenggara Barat': 'ID-NB',
  'Nusa Tenggara Timur': 'ID-NT',
  'Kalimantan Barat': 'ID-KB',
  'Kalimantan Tengah': 'ID-KT',
  'Kalimantan Selatan': 'ID-KS',
  'Kalimantan Timur': 'ID-KI',
  'Kalimantan Utara': 'ID-KU',
  'Sulawesi Utara': 'ID-SA',
  'Sulawesi Tengah': 'ID-ST',
  'Sulawesi Selatan': 'ID-SN',
  'Sulawesi Tenggara': 'ID-SG',
  'Gorontalo': 'ID-GO',
  'Sulawesi Barat': 'ID-SR',
  'Maluku': 'ID-MA',
  'Maluku Utara': 'ID-MU',
  'Papua Barat': 'ID-PB',
  'Papua': 'ID-PA',
  // New Papua provinces (may not exist in your SVG asset, safe to include)
  'Papua Barat Daya': 'ID-PD',
  'Papua Tengah': 'ID-PT',
  'Papua Pegunungan': 'ID-PP',
  'Papua Selatan': 'ID-PS',
};

/// Aliases or sub-regions to their parent province names
const Map<String, String> aliasToProvince = {
  // Variants / abbreviations
  'Bangka Belitung': 'Kepulauan Bangka Belitung',
  'Kepri': 'Kepulauan Riau',
  'Jakarta': 'DKI Jakarta',
  'Yogyakarta': 'DI Yogyakarta',
  // Sub-regions mapping
  'Banyuwangi': 'Jawa Timur',
  'Osing': 'Jawa Timur',
  'Osing, Banyuwangi': 'Jawa Timur',
  'Madura': 'Jawa Timur',
};

/// Try to map any "asal" string to a known official province name used by [provinceNameToSvgId].
String? normalizeAsalToProvince(String asalRaw) {
  final asal = asalRaw.trim();
  // Direct match (case-insensitive)
  for (final key in provinceNameToSvgId.keys) {
    if (asal.toLowerCase() == key.toLowerCase()) return key;
  }
  // Alias exact match
  for (final entry in aliasToProvince.entries) {
    if (asal.toLowerCase() == entry.key.toLowerCase()) return entry.value;
  }
  // Substring contains match for alias words
  for (final entry in aliasToProvince.entries) {
    if (asal.toLowerCase().contains(entry.key.toLowerCase())) {
      return entry.value;
    }
  }
  return null; // unknown / non-province
}

/// Generate N distinct colors (soft saturated palette) for map fills
List<Color> generateDistinctColors(int n) {
  if (n <= 0) return const [];
  final List<Color> out = [];
  for (int i = 0; i < n; i++) {
    final hue = (i * 360 / n) % 360.0;
    final hsl = HSLColor.fromAHSL(1, hue, 0.55, 0.55);
    out.add(hsl.toColor());
  }
  return out;
}

/// Return canonical SVG id like `ID-AC` from various incoming forms like `ac`, `ID-ac`, `id-AC`.
String canonicalizeSvgId(String svgId) {
  var id = svgId.trim();
  id = id.toUpperCase();
  if (!id.startsWith('ID-')) {
    // handle short 2~3 length like 'AC', 'SU'
    if (id.length <= 3) {
      id = 'ID-$id';
    }
  }
  return id;
}

/// Resolve province name from SVG id; accepts `ID-XX` or short `xx`.
String? provinceNameFromSvgId(String svgId) {
  final id = canonicalizeSvgId(svgId);
  for (final entry in provinceNameToSvgId.entries) {
    if (entry.value.toUpperCase() == id) return entry.key;
  }
  return null;
}
