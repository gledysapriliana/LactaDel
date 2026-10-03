# LactaDel — Pendamping Ayah ASI Eksklusif

> **"Ayah Terlibat, Ibu Lebih Kuat, Bayi Tumbuh Sehat."**

LactaDel adalah aplikasi mobile berbasis Flutter yang dirancang khusus untuk memberdayakan dan memandu para Ayah dalam mendampingi Ibu primipara memberikan ASI eksklusif. Aplikasi ini dilengkapi dengan modul edukasi komprehensif, pengingat jadwal menyusui lokal berulang, pemantauan (monitoring) statistik real-time dengan grafik mingguan, serta manajemen profil dan dukungan tema gelap/terang.

---

## 📱 Daftar Fitur Utama

1. **Autentikasi & Manajemen Akun**
   - Registrasi & Masuk menggunakan Email & Password.
   - Masuk cepat satu klik via **Google Sign-In**.
   - Lupa & Reset Password via email.
   - Auto-login & penyimpanan sesi aman.
   - Pesan error ramah berbahasa Indonesia untuk semua kondisi kegagalan jaringan atau kredensial.

2. **Beranda & Motivasi Harian**
   - Sapaan personal *"Halo, Ayah [Nama]!"* yang terhubung langsung ke Firestore.
   - Kartu motivasi harian penyemangat peran Ayah.
   - Menu pintasan navigasi cepat ke 4 modul utama.
   - Bottom navigation bar 5 tab yang mempertahankan state menggunakan `IndexedStack`.

3. **Modul Edukasi Lengkap (6 Materi)**
   - Peran Ayah dalam Mendukung ASI Eksklusif (dengan kotak persiapan belajar).
   - Manfaat ASI Eksklusif bagi Ibu dan Bayi.
   - Posisi dan Pelekatan Menyusui yang Benar.
   - Masalah Umum Menyusui dan Solusinya.
   - Nutrisi dan Istirahat untuk Ibu Menyusui.
   - Manajemen ASI Perah (ASIP) untuk Ayah Bekerja.
   - Checklist *"Apa yang dapat dilakukan Ayah?"* pada setiap materi.
   - Halaman daftar sumber referensi ilmiah lengkap dengan tautan aktif.

4. **Fitur Pengingat Menyusui (Satu-satunya Pengingat)**
   - Penjadwalan notifikasi lokal menggunakan `flutter_local_notifications` dan `timezone`.
   - Konfigurasi interval menyusui (1, 2, 3, atau 4 jam) dan waktu mulai.
   - Pilihan jenis alarm: Notifikasi Suara, Getar, atau Notifikasi & Getar.
   - Teks notifikasi ramah: *"Waktunya menyusui. Ayah, bantu Ibu bersiap dan istirahat ya."*
   - Notifikasi tetap aktif saat aplikasi diminimalkan atau setelah perangkat di-restart (`RECEIVE_BOOT_COMPLETED`).
   - Pencatatan cepat sesi menyusui (waktu, sisi payudara kiri/kanan, durasi menit, catatan).

5. **Monitoring & Statistik Real-Time**
   - Terhubung langsung dengan stream real-time Firestore (`catatan_menyusui`).
   - **3 Metrik Utama Hari Ini**:
     - Jumlah sesi menyusui hari ini.
     - Total durasi menyusui hari ini (dalam jam dan menit).
     - Rata-rata jeda/jarak antar sesi menyusui hari ini.
   - **Grafik Batang Interaktif 7 Hari Terakhir**:
     - Visualisasi frekuensi sesi per hari tanpa ketergantungan package eksternal.
     - Penanda khusus hari ini dan fitur ketuk (*tap*) untuk melihat rincian tanggal tertentu.
   - **Riwayat Harian Detail**:
     - Daftar sesi per hari lengkap dengan badge sisi payudara, jam WIB, durasi, dan catatan.
   - *Friendly empty state* dengan tombol pintas langsung ke tab Pengingat bila belum ada data.

6. **Profil & Personalisasi**
   - Tampilan avatar, nama panggilan, email, dan badge peran *"Ayah ASI Siaga"*.
   - Ubah nama panggilan pengguna langsung dengan validasi dan pembaruan real-time.
   - **Pilihan Tema Visual**:
     - Terang (*Light Mode*)
     - Gelap (*Dark Mode*)
     - Ikuti Sistem (*System Default*)
     - Disimpan persisten di `SharedPreferences`.
   - Tombol Keluar dengan dialog konfirmasi keamanan dan pembersihan cache lokal.

---

## 📂 Struktur Folder Project

```text
lib/
├── core/                       # Inti konfigurasi dan styling aplikasi
│   ├── app_colors.dart         # Palet warna resmi LactaDel (Light & Dark)
│   ├── app_theme.dart          # Tema Material 3 lengkap (Light & Dark)
│   ├── constants.dart          # Nama koleksi Firestore, key storage, string
│   └── routes.dart             # Definisi rute navigasi aplikasi
├── data/
│   └── materi_data.dart        # Konten lengkap 6 materi edukasi & referensi
├── models/
│   ├── app_user.dart           # Model data user (users/{uid})
│   ├── catatan_menyusui.dart   # Model catatan sesi menyusui
│   ├── materi.dart             # Model materi edukasi & referensi
│   └── pengaturan_pengingat.dart # Model konfigurasi pengingat
├── providers/
│   ├── auth_provider.dart      # State management autentikasi & profil
│   ├── catatan_provider.dart   # State & Stream real-time catatan & monitoring
│   ├── reminder_provider.dart  # State pengaturan pengingat
│   └── theme_provider.dart     # State manajemen tema aplikasi
├── screens/
│   ├── auth/                   # Layar Login, Register, Lupa Password
│   ├── edukasi/                # Layar Menu Edukasi, Detail, dan Referensi
│   ├── home/                   # Shell utama (IndexedStack) & Tab Beranda
│   ├── monitoring/             # Layar Monitoring & Grafik Batang
│   ├── onboarding/             # Layar Onboarding 3 slide
│   ├── pengingat/              # Layar Pengingat & Input Catatan
│   ├── profil/                 # Layar Profil Pengguna & Ubah Tema
│   └── splash/                 # Splash screen & logika alur awal
├── services/
│   ├── auth_service.dart       # Integrasi Firebase Auth & Google Sign-In
│   ├── firestore_service.dart  # Operasi CRUD dokumen Firestore
│   └── notification_service.dart # Inisialisasi & penjadwalan notifikasi lokal
├── widgets/                    # Widget umum yang dapat digunakan kembali
├── firebase_options.dart       # Konfigurasi Firebase dari FlutterFire CLI
└── main.dart                   # Entry point aplikasi & inisialisasi provider
```

---

## 🗄️ Skema Database Cloud Firestore

Data pengguna disimpan secara terisolasi per akun berbasis `uid`:

```text
users/
└── {uid}/
    ├── (fields):
    │   ├── nama: string
    │   ├── email: string
    │   └── createdAt: timestamp
    │
    ├── pengaturan/
    │   └── pengingat (doc):
    │       ├── aktif: boolean
    │       ├── intervalJam: int (1, 2, 3, atau 4)
    │       ├── waktuMulai: string ("06:00")
    │       ├── jenisSuara: string ("notifikasi", "getar", "notifikasi_getar")
    │       └── updatedAt: timestamp
    │
    └── catatan_menyusui/
        └── {catatanId} (docs):
            ├── waktu: timestamp
            ├── sisi: string ("Kiri", "Kanan", "Keduanya")
            ├── durasiMenit: int
            └── catatan: string
```

---

## 🚀 Cara Menjalankan Project

### 1. Prasyarat
- **Flutter SDK**: versi `>= 3.11.1` (disarankan Flutter 3.22 atau terbaru).
- **Android SDK**: `minSdk = 21`, `targetSdk = 34` atau terbaru.
- **Java/JDK**: JDK 17 atau yang kompatibel.
- File `google-services.json` diletakkan di `android/app/google-services.json` (telah terkonfigurasi).

### 2. Instalasi Dependensi
Jalankan perintah berikut di terminal:
```bash
flutter pub get
```

### 3. Generate Ikon Aplikasi (Opsional / Sudah Dikonfigurasi)
Untuk meregenerasi launcher icons dari `assets/logo/app_icon.png`:
```bash
dart run flutter_launcher_icons
```

### 4. Menjalankan di Mode Debug
Hubungkan perangkat Android fisik atau buka Android Emulator, lalu jalankan:
```bash
flutter run
```

---

## 📦 Build APK Release

Untuk menghasilkan berkas APK siap rilis yang teroptimasi:

```bash
flutter build apk --release
```

Berkas APK akan berada di lokasi:
```text
build/app/outputs/flutter-apk/app-release.apk
```
