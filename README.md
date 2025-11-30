# Budaya Indonesia 🇮🇩

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-success?style=for-the-badge)

> **Singkatnya:** Aplikasi mobile untuk melestarikan budaya Indonesia dengan fitur AR interaktif, quiz edukasi, katalog pakaian tradisional, dan streaming musik daerah yang dibangun menggunakan Flutter dengan Provider state management.

---

## 👥 Tim Development

| No | Nama | GitHub | Kontribusi |
|----|------|--------|------------|
| 1 | IkhsanFillah | [@IkhsanFillah](https://github.com/IkhsanFillah) | 17 contributions |
| 2 | Mangzy | [@Mangzy](https://github.com/Mangzy) | 13 contributions |
| 3 | zulfafifahh | [@zulfafifahh](https://github.com/zulfafifahh) | 7 contributions |
| 4 | hafidz111 | [@hafidz111](https://github.com/hafidz111) | 1 contribution |
| 5 | ikhsan-fillah | [@ikhsan-fillah](https://github.com/ikhsan-fillah) | 1 contribution |

---

## 📸 Demo & Screenshots

### 📱 App Screenshots

| Splash & Login | Home & Katalog | Music Player |
|:--------------:|:--------------:|:------------:|
| ![Splash](https://drive.google.com/uc?id=FILE_ID_SPLASH) | ![Home](https://drive.google.com/uc?id=FILE_ID_HOME) | ![Music](https://drive.google.com/uc?id=FILE_ID_MUSIC) |

| Quiz Interaktif | AR Feature | Profile |
|:---------------:|:----------:|:-------:|
| ![Quiz](https://drive.google.com/uc?id=FILE_ID_QUIZ) | ![AR](https://drive.google.com/uc?id=FILE_ID_AR) | ![Profile](https://drive.google.com/uc?id=FILE_ID_PROFILE) |

### 📥 Download APK

[![Download APK](https://img.shields.io/badge/Download-APK-green?style=for-the-badge&logo=android)](https://drive.google.com/uc?id=FILE_ID_APK)

> **Note:** Ganti `FILE_ID_SPLASH`, `FILE_ID_HOME`, `FILE_ID_MUSIC`, `FILE_ID_QUIZ`, `FILE_ID_AR`, `FILE_ID_PROFILE`, dan `FILE_ID_APK` dengan ID file Google Drive yang sesuai.

---

## 📱 Fitur Utama

### 🏠 Katalog Pakaian Tradisional
- ✅ Katalog lengkap pakaian daerah seluruh Indonesia
- ✅ Detail informasi setiap pakaian tradisional
- ✅ Gambar high-quality dari setiap pakaian

### 🎵 Streaming Musik Daerah
- ✅ Koleksi lagu tradisional dari berbagai daerah
- ✅ Audio player dengan kontrol lengkap
- ✅ Informasi durasi dan asal daerah

### 🎯 Quiz Interaktif
- ✅ Timer 5 menit untuk setiap sesi quiz
- ✅ 10 soal acak dari database
- ✅ Penjelasan jawaban setelah quiz selesai
- ✅ Sistem scoring otomatis

### 📸 Augmented Reality (AR)
- ✅ AR 2D untuk pengalaman interaktif
- ✅ 3D Preview model pakaian tradisional
- ✅ Try-on feature untuk iOS (ARKit)
- ✅ Model Viewer untuk preview 3D

### 🔐 Autentikasi
- ✅ Login dengan Email/Password
- ✅ Google Sign-In integration
- ✅ Firebase Authentication
- ✅ Secure session management

### 🎨 Dark Mode Support
- ✅ Toggle tema gelap/terang
- ✅ Persistent theme preference
- ✅ Material Design 3 theming

---

## 🛠️ Tech Stack & Tools

| Kategori | Teknologi |
|----------|-----------|
| **Framework** | Flutter 3.8.1+ (Dart) |
| **State Management** | Provider |
| **Backend** | Supabase (PostgreSQL + Storage) |
| **Authentication** | Firebase Auth + Google Sign-In |
| **AR** | ARKit Plugin (iOS), Model Viewer Plus |
| **Audio** | Just Audio |
| **UI** | Material Design 3, Google Fonts, Rive animations |
| **Storage** | Supabase Storage |
| **Image** | Image Picker, Flutter SVG |
| **Camera** | Camera Plugin |
| **Preferences** | Shared Preferences |

---

## 🚀 Cara Menjalankan (Installation)

### 📋 Prerequisites

Pastikan Anda sudah menginstall:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi 3.8.1+)
- [Dart SDK](https://dart.dev/get-dart) (sudah include di Flutter)
- [Android Studio](https://developer.android.com/studio) atau [VS Code](https://code.visualstudio.com/)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Git](https://git-scm.com/)
- Xcode (untuk iOS development - Mac only)

### 📥 Step 1: Clone Repository

```bash
git clone https://github.com/Mangzy/budaya_indonesia.git
cd budaya_indonesia
```

### 📦 Step 2: Install Dependencies

```bash
flutter pub get
```

### 🔥 Step 3: Setup Firebase

1. Buat project baru di [Firebase Console](https://console.firebase.google.com/)

2. Download konfigurasi:
   - **Android**: Download `google-services.json` → simpan di `android/app/`
   - **iOS**: Download `GoogleService-Info.plist` → simpan di `ios/Runner/`

3. Generate SHA-1 untuk Android:
   ```bash
   cd android && ./gradlew signingReport
   ```

4. Tambahkan SHA-1 dan SHA-256 ke Firebase Console:
   - Buka Project Settings → Your Apps → Android app
   - Add fingerprint → paste SHA-1 dan SHA-256

5. Enable Authentication methods:
   - Buka Authentication → Sign-in method
   - Enable **Email/Password**
   - Enable **Google** (pilih Web Client ID)

6. Install FlutterFire CLI dan configure:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

### 💚 Step 4: Setup Supabase

1. Buat project baru di [Supabase](https://app.supabase.com/)

2. Buat tabel dengan menjalankan SQL berikut di SQL Editor:

```sql
-- =====================================================
-- TABEL PAKAIAN DAERAH
-- =====================================================
CREATE TABLE pakaian_daerah (
  id SERIAL PRIMARY KEY,
  nama TEXT NOT NULL,
  asal TEXT NOT NULL,
  deskripsi TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABEL LAGU DAERAH
-- =====================================================
CREATE TABLE lagu_daerah (
  id SERIAL PRIMARY KEY,
  judul TEXT NOT NULL,
  asal TEXT NOT NULL,
  audio_url TEXT NOT NULL,
  duration_seconds INTEGER,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABEL SOAL KUIS
-- =====================================================
CREATE TABLE soal_kuis (
  id SERIAL PRIMARY KEY,
  kategori TEXT NOT NULL,
  pertanyaan TEXT NOT NULL,
  opsi_a TEXT NOT NULL,
  opsi_b TEXT NOT NULL,
  opsi_c TEXT NOT NULL,
  opsi_d TEXT NOT NULL,
  jawaban_benar INTEGER NOT NULL CHECK (jawaban_benar BETWEEN 1 AND 4),
  penjelasan TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABEL AR ASSETS (3D Models)
-- =====================================================
CREATE TABLE ar_assets (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  android_src_url TEXT,
  ios_src_url TEXT,
  poster_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABEL AR 2D ASSETS
-- =====================================================
CREATE TABLE ar_2d_assets (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  target_image_url TEXT NOT NULL,
  overlay_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================
ALTER TABLE pakaian_daerah ENABLE ROW LEVEL SECURITY;
ALTER TABLE lagu_daerah ENABLE ROW LEVEL SECURITY;
ALTER TABLE soal_kuis ENABLE ROW LEVEL SECURITY;
ALTER TABLE ar_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE ar_2d_assets ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- PUBLIC READ POLICIES
-- =====================================================
CREATE POLICY "public_read_pakaian" ON pakaian_daerah FOR SELECT USING (true);
CREATE POLICY "public_read_lagu" ON lagu_daerah FOR SELECT USING (true);
CREATE POLICY "public_read_soal" ON soal_kuis FOR SELECT USING (true);
CREATE POLICY "public_read_ar_assets" ON ar_assets FOR SELECT USING (true);
CREATE POLICY "public_read_ar_2d" ON ar_2d_assets FOR SELECT USING (true);
```

3. Setup Storage Buckets:
   - Buka Storage → Create a new bucket
   - Buat bucket: `audio`, `images`, `ar-models`
   - Set semua bucket ke **Public** untuk akses read

4. Update konfigurasi Supabase di `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'https://YOUR_PROJECT_ID.supabase.co',
  anonKey: 'YOUR_ANON_KEY',
);
```

> **Tip:** Dapatkan URL dan Anon Key dari Project Settings → API

### ▶️ Step 5: Run Aplikasi

```bash
# Run di debug mode
flutter run

# Run di release mode
flutter run --release

# Build APK
flutter build apk --release

# Build iOS (Mac only)
flutter build ios --release
```

---

## 📂 Struktur Proyek

```
lib/
├── main.dart                    # Entry point aplikasi
├── firebase_options.dart        # Firebase configuration
├── src/
│   └── auth_provider.dart       # Firebase Auth Provider
├── clothes/
│   ├── pages/                   # Halaman pakaian
│   └── widgets/                 # Widget pakaian
├── common/
│   ├── static/                  # Static assets & constants
│   ├── theme/                   # Dark/Light theme configuration
│   └── widgets/                 # Shared/reusable components
└── features/
    ├── splash/                  # Splash screen
    ├── login/                   # Login page
    ├── register/                # Register page
    ├── home/                    # Home & Katalog Pakaian
    ├── music/                   # List Musik Daerah
    ├── music_detail/            # Detail & Player Musik
    ├── quiz/                    # Quiz Interaktif
    ├── ar/                      # AR Features (2D & 3D)
    ├── profile/                 # User Profile
    └── navbar/                  # Bottom Navigation Bar
```

---

## 🐛 Troubleshooting

### ❌ Google Sign-In Error

**Masalah:** Login dengan Google gagal atau muncul error.

**Solusi:**
1. Pastikan menggunakan **Web Client ID** (bukan Android Client ID)
2. Update SHA-1 dan SHA-256 di Firebase Console
3. Clean project dan rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
4. Pastikan `google-services.json` sudah terupdate

### ❌ Supabase Connection Error

**Masalah:** Tidak bisa konek ke Supabase atau data tidak muncul.

**Solusi:**
1. Cek URL dan Anon Key di `lib/main.dart`
2. Pastikan RLS policies sudah aktif
3. Verifikasi nama tabel sesuai dengan query
4. Cek apakah data sudah ada di database
5. Test koneksi dengan Postman atau curl

### ❌ AR iOS Issues

**Masalah:** AR tidak berfungsi di iOS.

**Solusi:**
1. Pastikan device iOS 11+ (ARKit requirement)
2. Gunakan device fisik (simulator tidak support AR)
3. Tambahkan camera permission di `ios/Runner/Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Camera dibutuhkan untuk fitur AR</string>
   ```
4. Rebuild aplikasi setelah menambahkan permission

### ❌ Audio Playback Issues

**Masalah:** Musik tidak bisa diputar atau error saat streaming.

**Solusi:**
1. Cek `audio_url` valid dan accessible di Supabase Storage
2. Pastikan bucket `audio` sudah di-set **public**
3. Format audio yang didukung: MP3, M4A, WAV, AAC
4. Cek koneksi internet device
5. Verify URL langsung di browser

---

## 🗺️ Roadmap & Future Features

### 🔜 Coming Soon
- [ ] 🔔 **Push Notifications** - Notifikasi untuk quiz baru dan konten terbaru
- [ ] ❤️ **Favorite System** - Simpan pakaian dan lagu favorit
- [ ] 📤 **Social Sharing** - Share ke media sosial

### 📅 Planned
- [ ] 🌐 **Multi-language Support** - Bahasa Inggris dan bahasa daerah
- [ ] 📊 **History Tracking** - Riwayat quiz dan pembelajaran
- [ ] 📴 **Offline Mode** - Akses konten tanpa internet
- [ ] 🏆 **Leaderboard** - Ranking quiz antar pengguna
- [ ] 🎮 **Gamification** - Badge dan achievements

---

## 🤝 Contributing

Kontribusi sangat welcome! Berikut cara berkontribusi:

1. **Fork** repository ini
2. **Clone** fork Anda:
   ```bash
   git clone https://github.com/YOUR_USERNAME/budaya_indonesia.git
   ```
3. **Create branch** untuk fitur baru:
   ```bash
   git checkout -b feature/nama-fitur
   ```
4. **Commit** perubahan Anda:
   ```bash
   git commit -m "feat: tambah fitur baru"
   ```
5. **Push** ke branch:
   ```bash
   git push origin feature/nama-fitur
   ```
6. **Create Pull Request** di GitHub

### 📝 Commit Convention

Gunakan format commit message:
- `feat:` - Fitur baru
- `fix:` - Bug fix
- `docs:` - Dokumentasi
- `style:` - Formatting, styling
- `refactor:` - Refactoring code
- `test:` - Menambah atau memperbaiki test
- `chore:` - Maintenance

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for more information.

```
MIT License

Copyright (c) 2024 Budaya Indonesia Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 📞 Kontak & Support

Jika ada pertanyaan atau membutuhkan bantuan:

- 📧 **Email:** [tim.budayaindonesia@gmail.com](mailto:tim.budayaindonesia@gmail.com)
- 🐛 **Bug Report:** [Create Issue](https://github.com/Mangzy/budaya_indonesia/issues/new)
- 💬 **Diskusi:** [GitHub Discussions](https://github.com/Mangzy/budaya_indonesia/discussions)

---

## 🙏 Acknowledgments

Terima kasih kepada:

- [Flutter Team](https://flutter.dev/) - Framework luar biasa
- [Firebase](https://firebase.google.com/) - Backend authentication
- [Supabase](https://supabase.com/) - Backend database & storage
- [Material Design](https://material.io/) - Design system
- [Google Fonts](https://fonts.google.com/) - Typography
- [Rive](https://rive.app/) - Animasi interaktif
- Seluruh kontributor yang telah membantu pengembangan aplikasi ini

---

<div align="center">

**Made with ❤️ for Indonesian Culture**

![Version](https://img.shields.io/badge/version-0.1.0-blue?style=flat-square)
![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?style=flat-square&logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

⭐ **Star this repo if you find it helpful!** ⭐

</div>
