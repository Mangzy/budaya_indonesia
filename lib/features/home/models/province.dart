class Province {
  final String id; // unique id matching SVG path id
  final String name;
  final String attireName; // pakaian adat utama
  final String description;
  final String? imageUrl; // optional ilustrasi

  const Province({
    required this.id,
    required this.name,
    required this.attireName,
    required this.description,
    this.imageUrl,
  });
}

// Minimal seed data; extend as needed
const List<Province> provinces = [
  Province(
    id: 'aceh',
    name: 'Aceh',
    attireName: 'Pakaian Adat Ulee Balang',
    description:
        'Ulee Balang merupakan pakaian adat Aceh dengan ciri khas warna mencolok dan hiasan emas, melambangkan keagungan dan kebesaran.',
  ),
  Province(
    id: 'sumut',
    name: 'Sumatera Utara',
    attireName: 'Ulos Batak',
    description:
        'Kain Ulos adalah simbol kehangatan dan restu pada masyarakat Batak, kerap digunakan pada upacara adat.',
  ),
  Province(
    id: 'jakarta',
    name: 'DKI Jakarta',
    attireName: 'Baju Sadariah & Kebaya Encim',
    description:
        'Warisan budaya Betawi, memadukan unsur Tionghoa, Arab, dan Nusantara dengan warna-warna cerah.',
  ),
  Province(
    id: 'jabar',
    name: 'Jawa Barat',
    attireName: 'Beskap Sunda & Kebaya Sunda',
    description:
        'Busana adat Sunda yang anggun, dengan beskap pada pria dan kebaya pada wanita, sering dipakai pada pernikahan adat.',
  ),
];
