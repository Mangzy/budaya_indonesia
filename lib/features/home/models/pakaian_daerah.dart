class PakaianDaerah {
  final int id;
  final String nama; // nama pakaian
  final String asal; // nama provinsi
  final String deskripsi;
  final String? funFact;
  final String? imageUrl;

  const PakaianDaerah({
    required this.id,
    required this.nama,
    required this.asal,
    required this.deskripsi,
    this.funFact,
    this.imageUrl,
  });

  factory PakaianDaerah.fromMap(Map<String, dynamic> map) {
    return PakaianDaerah(
      id: map['id'] as int,
      nama: (map['nama'] as String?)?.trim() ?? '-',
      asal: (map['asal'] as String?)?.trim() ?? '-',
      deskripsi: (map['deskripsi'] as String?)?.trim() ?? '-',
      funFact: (map['fun_fact'] as String?)?.trim(),
      imageUrl: (map['image_url'] as String?)?.trim(),
    );
  }
}
