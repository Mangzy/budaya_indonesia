# 🇮🇩 Budaya Indonesia

Aplikasi Flutter untuk melestarikan budaya Indonesia dengan fitur AR, quiz interaktif, katalog pakaian tradisional, dan streaming musik daerah.

## 📱 Fitur Utama

- 🏠 **Pakaian Tradisional** - Katalog lengkap pakaian daerah Indonesia
- 🎵 **Musik Daerah** - Streaming lagu tradisional dengan audio player
- 🎯 **Quiz Interaktif** - Tes pengetahuan budaya (timer 5 menit, 10 soal acak)
- 📸 **Augmented Reality** - AR 2D, 3D preview, dan try-on pakaian (iOS)
- 👤 **Autentikasi** - Login Email/Password dan Google Sign-In
- 🎨 **Dark Mode** - Support tema gelap/terang

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.8.1 + Provider (state management)
- **Backend**: Supabase (PostgreSQL + Storage) + Firebase (Authentication)
- **AR**: ARKit Plugin (iOS), Model Viewer Plus (3D)
- **Audio**: Just Audio (streaming player)
- **UI**: Material Design 3, Google Fonts, Rive animations

## 🚀 Quick Start

### 1. Install Dependencies
```bash
git clone https://github.com/Mangzy/budaya_indonesia.git
cd budaya_indonesia
flutter pub get
```

### 2. Setup Firebase
- Buat project di [Firebase Console](https://console.firebase.google.com/)
- Download `google-services.json` → `android/app/`
- Generate SHA-1: `cd android && ./gradlew signingReport`
- Tambahkan SHA-1 ke Firebase Console
- Enable Email/Password & Google Sign-In di Authentication
- Run: `flutterfire configure`

### 3. Setup Supabase
- Buat project di [Supabase](https://app.supabase.com/)
- Buat tabel dengan SQL:

```sql
-- Pakaian Daerah
CREATE TABLE pakaian_daerah (
  id SERIAL PRIMARY KEY,
  nama TEXT NOT NULL,
  asal TEXT NOT NULL,
  deskripsi TEXT,
  image_url TEXT
);

-- Lagu Daerah
CREATE TABLE lagu_daerah (
  id SERIAL PRIMARY KEY,
  judul TEXT NOT NULL,
  asal TEXT NOT NULL,
  audio_url TEXT NOT NULL,
  duration_seconds INTEGER,
  image_url TEXT
);

-- Soal Quiz
CREATE TABLE soal_kuis (
  id SERIAL PRIMARY KEY,
  kategori TEXT NOT NULL,
  pertanyaan TEXT NOT NULL,
  opsi_a TEXT NOT NULL,
  opsi_b TEXT NOT NULL,
  opsi_c TEXT NOT NULL,
  opsi_d TEXT NOT NULL,
  jawaban_benar INTEGER NOT NULL,
  penjelasan TEXT
);

-- AR Assets
CREATE TABLE ar_assets (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  android_src_url TEXT,
  ios_src_url TEXT,
  poster_url TEXT
);

CREATE TABLE ar_2d_assets (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  target_image_url TEXT NOT NULL,
  overlay_image_url TEXT
);

-- Enable RLS & Public Read
ALTER TABLE pakaian_daerah ENABLE ROW LEVEL SECURITY;
ALTER TABLE lagu_daerah ENABLE ROW LEVEL SECURITY;
ALTER TABLE soal_kuis ENABLE ROW LEVEL SECURITY;
ALTER TABLE ar_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE ar_2d_assets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_read" ON pakaian_daerah FOR SELECT USING (true);
CREATE POLICY "public_read" ON lagu_daerah FOR SELECT USING (true);
CREATE POLICY "public_read" ON soal_kuis FOR SELECT USING (true);
CREATE POLICY "public_read" ON ar_assets FOR SELECT USING (true);
CREATE POLICY "public_read" ON ar_2d_assets FOR SELECT USING (true);
```

- Buat Storage buckets: `audio`, `images`, `ar-models` (set public)
- Update `lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);
```

### 4. Run App
```bash
flutter run
```

## 📂 Struktur Project

```
lib/
├── main.dart                 # Entry point
├── src/
│   └── auth_provider.dart    # Firebase Auth
├── common/
│   ├── theme/               # Dark/Light theme
│   └── widgets/             # Shared components
└── features/
    ├── splash/              # Splash screen
    ├── login/               # Login & Register
    ├── home/                # Pakaian Tradisional
    ├── music/               # Musik Daerah
    ├── quiz/                # Quiz Interaktif
    ├── ar/                  # AR Features
    ├── profile/             # User Profile
    └── navbar/              # Bottom Navigation
```

## 🐛 Troubleshooting

**Google Sign-In Error:**
- Pastikan pakai Web Client ID (bukan Android)
- Update SHA-1 di Firebase Console
- Clean: `flutter clean && flutter pub get`

**Supabase Error:**
- Cek URL & anon key di `main.dart`
- Pastikan RLS policies aktif
- Verifikasi nama tabel benar

**AR iOS:**
- Butuh iOS 11+ & device fisik
- Tambahkan camera permission di `Info.plist`

**Audio:**
- Cek `audio_url` valid di Supabase
- Pastikan bucket public
- Support: MP3, M4A, WAV

**Made with ❤️ for Indonesian Culture** • v0.1.0
