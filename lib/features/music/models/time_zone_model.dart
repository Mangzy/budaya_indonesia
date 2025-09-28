class IndonesianTimeZone {
  final String code;
  final String name;
  final String description;
  final Duration utcOffset;

  const IndonesianTimeZone({
    required this.code,
    required this.name,
    required this.description,
    required this.utcOffset,
  });
}

const List<IndonesianTimeZone> indonesianTimeZones = [
  IndonesianTimeZone(
    code: 'WIB',
    name: 'Waktu Indonesia Barat',
    description: 'Sumatra, Jawa, Kalimantan Barat & Tengah',
    utcOffset: Duration(hours: 7),
  ),
  IndonesianTimeZone(
    code: 'WITA',
    name: 'Waktu Indonesia Tengah',
    description: 'Bali, Nusa Tenggara, Kalimantan Timur & Selatan, Sulawesi',
    utcOffset: Duration(hours: 8),
  ),
  IndonesianTimeZone(
    code: 'WIT',
    name: 'Waktu Indonesia Timur',
    description: 'Maluku & Papua',
    utcOffset: Duration(hours: 9),
  ),
];
