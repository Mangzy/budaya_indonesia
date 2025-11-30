# Budaya Indonesia 🇮🇩

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-success?style=for-the-badge)

> **Singkatnya:** Aplikasi mobile untuk mengeksplorasi dan melestarikan kekayaan budaya Indonesia yang dibangun menggunakan Flutter dengan integrasi Firebase dan Supabase.

---

## 📖 Deskripsi Proyek

Budaya Indonesia adalah aplikasi mobile yang dirancang untuk memperkenalkan, melestarikan, dan mengeksplorasi kekayaan budaya Indonesia. Aplikasi ini memungkinkan pengguna untuk mempelajari berbagai aspek budaya Indonesia dengan cara yang modern dan interaktif melalui multimedia dan teknologi AR.

---

### 📲 Download Aplikasi

[**Download APK (Latest Version)**](https://drive.google.com/file/d/1PqW7WJllz9HsGhTYB71XEzzltqwxkXBm/view?usp=drive_link)  

**Platform yang Didukung:**
- ✅ Android
- ✅ iOS

---

### 📖 Dokumentasi Penggunaan Aplikasi

[**Screenshot Aplikasi**](https://drive.google.com/drive/folders/1eFFsME_U-tgx_jPeczgKRTv7T2aS8A6D?usp=sharing)  
[**Vidio Penggunaan Aplikasi**](https://drive.google.com/file/d/1HRX0BPI0cbx2bXQtVJ_8RAkW5ebPt6uz/view?usp=drive_link)  

---

### 👥 Tim Development

- **Ikhsan Fillah Hidayat** - [@IkhsanFillah](https://github.com/IkhsanFillah) - 17 contributions
- **Mangzy** - [@Mangzy](https://github.com/Mangzy) - 13 contributions  
- **Zulfa Fifah** - [@zulfafifahh](https://github.com/zulfafifahh) - 7 contributions
- **Hafidz** - [@hafidz111](https://github.com/hafidz111) - 1 contribution

---

## ✨ Fitur Utama

* ✅ **Otentikasi Pengguna** - Login/Register dengan Firebase Authentication dan Google Sign-In
* ✅ **Eksplorasi Budaya** - Jelajahi berbagai aspek budaya Indonesia
* ✅ **Multimedia Content** - Audio dan visual untuk pengalaman belajar yang lebih interaktif
* ✅ **AR Experience** - Augmented Reality untuk visualisasi 3D objek budaya (ARKit)
* ✅ **3D Model Viewer** - Lihat model 3D objek budaya Indonesia
* ✅ **Camera Integration** - Ambil foto dan dokumentasi budaya
* ✅ **Animated Interface** - Animasi Rive untuk UI yang menarik dan interaktif
* ✅ **Offline Support** - Penyimpanan lokal dengan Shared Preferences
* ✅ **Custom Fonts** - Google Fonts untuk tampilan yang lebih menarik

---

## 🛠️ Tech Stack & Tools

Aplikasi ini dibuat dengan teknologi dan *best practice* berikut:

* **Framework:** Flutter SDK 3.8.1+ (Dart)
* **State Management:** Provider
* **Backend & Database:** 
  - Firebase (Authentication, Firestore)
  - Supabase
* **Local Storage:** Shared Preferences & Path Provider
* **Authentication:** Firebase Auth + Google Sign In
* **Media & AR:** 
  - Just Audio (Audio playback)
  - Camera & Image Picker
  - ARKit Plugin (iOS AR)
  - Model Viewer Plus (3D models)
* **UI Components:** 
  - Rive Animations
  - Rive Animated Icon
  - Flutter SVG
  - Google Fonts
* **Other Tools:** 
  - HTTP (API calls)
  - Path Drawing (SVG rendering)

---

## 🚀 Cara Menjalankan (Installation)

### Prerequisites

Pastikan Anda telah menginstal:
- Flutter SDK (versi 3.8.1 atau lebih tinggi)
- Dart SDK
- Android Studio / VS Code / Xcode (untuk iOS)
- Git
- Firebase CLI (optional, untuk konfigurasi Firebase)

### Langkah Instalasi

1.  **Clone repository ini:**
   ```bash
   git clone https://github.com/Mangzy/budaya_indonesia. git
   cd budaya_indonesia
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase:**
   
   - Pastikan file konfigurasi Firebase sudah tersedia
   - Jika belum, jalankan Firebase CLI untuk setup:
   ```bash
   flutterfire configure
   ```

4. **Setup Supabase:**
   
   - Konfigurasi Supabase credentials di aplikasi
   - Pastikan URL dan Anon Key sudah benar

5. **Run aplikasi:**
   ```bash
   flutter run
   ```

   Atau untuk platform spesifik:
   ```bash
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   ```

---

## 📁 Struktur Proyek

```
lib/
├── models/           # Data models
├── providers/        # State management (Provider)
├── screens/          # UI screens
├── services/         # Services (Firebase, Supabase, API)
├── widgets/          # Reusable widgets
└── main.dart         # Entry point aplikasi

assets/
├── images/           # Image assets
├── banner/           # Banner images
└── logo/             # Logo assets
```

---

## 🎨 Screenshots & Fitur Detail

### Fitur Utama:

1. **Splash Screen** - Tampilan awal aplikasi dengan branding Budaya Indonesia
2.  **Authentication** - Login & Register dengan email/password atau Google Sign-In
3. **Home/Dashboard** - Menampilkan berbagai kategori budaya Indonesia
4.  **Detail Content** - Informasi lengkap tentang budaya dengan multimedia
5. **Audio Player** - Pemutaran audio guide untuk setiap konten
6.  **AR Viewer** - Pengalaman Augmented Reality (iOS)
7. **3D Model Viewer** - Visualisasi 3D objek budaya
8. **Camera** - Ambil foto dan dokumentasi budaya

*Screenshots akan ditambahkan segera*

---

## 📚 Panduan Singkat Penggunaan

### 1. **Memulai Aplikasi**

#### Login / Register
- Buka aplikasi dan Anda akan disambut dengan halaman login
- **Opsi 1:** Login menggunakan email dan password yang sudah terdaftar
- **Opsi 2:** Login menggunakan akun Google untuk proses yang lebih cepat
- Jika belum memiliki akun, klik tombol "Register" untuk membuat akun baru

#### Navigasi Utama
- Setelah login, Anda akan masuk ke halaman utama aplikasi
- Jelajahi berbagai konten budaya Indonesia yang tersedia

---

### 2. **Fitur-Fitur Utama**

#### 🎭 Eksplorasi Budaya
- Browse berbagai kategori budaya Indonesia
- Lihat detail informasi setiap konten budaya
- Akses konten multimedia (gambar, audio, video)

#### 🎵 Audio Guide
- Klik tombol play untuk mendengarkan audio guide
- Kontrol pemutaran: play, pause, stop
- Audio guide memberikan penjelasan detail tentang budaya yang dipilih

#### 📸 Camera & Photo
- Gunakan fitur kamera untuk mendokumentasikan budaya
- Ambil foto dari galeri atau langsung menggunakan kamera
- Simpan dokumentasi Anda

#### 🕶️ AR Experience (iOS)
- Aktifkan fitur AR untuk melihat objek budaya dalam Augmented Reality
- Arahkan kamera ke permukaan datar
- Lihat objek 3D budaya Indonesia di dunia nyata

#### 🎨 3D Model Viewer
- Lihat model 3D berbagai objek budaya
- Rotate, zoom, dan eksplorasi model dari berbagai sudut
- Pengalaman interaktif untuk memahami detail objek budaya

---

### 3. **Tips Penggunaan**

✅ **Koneksi Internet:** Beberapa fitur memerlukan koneksi internet untuk mengakses konten terbaru  
✅ **Permission:** Pastikan memberikan izin akses kamera untuk fitur AR dan foto  
✅ **Audio:** Gunakan earphone untuk pengalaman audio guide yang lebih baik  
✅ **AR Mode:** Untuk pengalaman AR terbaik, gunakan di ruangan dengan pencahayaan yang cukup  
✅ **Offline Mode:** Beberapa konten dapat diakses secara offline setelah di-download

---

### 4. **Troubleshooting**

**Q: Aplikasi tidak bisa login? **  
A: Pastikan koneksi internet stabil dan kredensial yang dimasukkan benar

**Q: Fitur AR tidak berfungsi?**  
A: Fitur AR saat ini hanya tersedia untuk iOS.  Pastikan sudah memberikan izin akses kamera

**Q: Audio tidak bisa diputar?**  
A: Periksa koneksi internet dan pastikan volume device tidak dalam mode silent

**Q: Model 3D tidak muncul?**  
A: Pastikan koneksi internet stabil untuk loading model 3D

📖 **Untuk dokumentasi lengkap, silakan download PDF dokumentasi di bagian atas.**

---

## 🔑 Fitur Keamanan

- ✅ Firebase Authentication untuk keamanan user
- ✅ Supabase untuk database yang aman
- ✅ Permission handling untuk akses kamera
- ✅ Secure local storage dengan Shared Preferences

---

## 📦 Dependencies Utama

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6. 1.5+1
  
  # Firebase
  firebase_core: ^4. 1.1
  firebase_auth: ^6.1.0
  
  # Supabase
  supabase_flutter: ^2.10.1
  
  # Authentication
  google_sign_in: ^7.2.0
  
  # Media & Camera
  just_audio: ^0.9.40
  camera: ^0.11.2
  image_picker: ^1.1.2
  
  # AR & 3D
  arkit_plugin: ^1. 0.8
  model_viewer_plus: ^1.9. 1
  
  # UI & Animation
  rive: ^0.13.20
  rive_animated_icon: ^2. 0.5
  flutter_svg: ^2.2.1
  google_fonts: ^6. 3.2
  
  # Storage & Network
  shared_preferences: ^2.3.2
  path_provider: ^2. 1.4
  http: ^1.2.1
```

---

## 🎯 Roadmap & Future Features

- [ ] Konten budaya lebih lengkap (tari, musik, pakaian adat, dll)
- [ ] Quiz dan games edukatif
- [ ] Bookmark konten favorit
- [ ] Share ke social media
- [ ] Multi-language support (Indonesia & English)
- [ ] Dark mode support
- [ ] AR support untuk Android (ARCore)
- [ ] Community features (komentar & diskusi)
- [ ] Offline mode untuk konten
- [ ] Virtual tour lokasi budaya

---

## 🤝 Contributing

Kontribusi selalu diterima dengan tangan terbuka! Berikut cara berkontribusi:

1. Fork repository ini
2. Buat feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

---

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 🙏 Acknowledgments

- Flutter Team untuk framework yang luar biasa
- Firebase & Supabase untuk backend services
- Provider untuk state management
- Semua open source contributors
- Komunitas pelestari budaya Indonesia

---

<div align="center">
  <p>Made with ❤️ by Budaya Indonesia Team</p>
  <p>🇮🇩 Lestarikan Budaya Indonesia!  🇮🇩</p>
</div>
