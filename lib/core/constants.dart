/// Konstanta aplikasi LactaDel.
/// Berisi string, durasi, dan nilai-nilai tetap.
library;

class AppConstants {
  AppConstants._();

  // ─── Informasi Aplikasi ───
  static const String appName = 'LactaDel';
  static const String tagline = 'Ayah Terlibat, Ibu Lebih Kuat, Bayi Tumbuh Sehat.';
  static const String logoPath = 'assets/logo/logo.jpeg';

  // ─── Durasi ───
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // ─── SharedPreferences Keys ───
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyThemeMode = 'theme_mode';

  // ─── Firestore Collections ───
  static const String colUsers = 'users';
  static const String colPengaturan = 'pengaturan';
  static const String docPengingat = 'pengingat';
  static const String colCatatanMenyusui = 'catatan_menyusui';

  // ─── Pilihan Interval Pengingat (jam) ───
  static const List<int> intervalOptions = [1, 2, 3, 4];

  // ─── Pilihan Jenis Suara ───
  static const Map<String, String> jenisSuaraOptions = {
    'notifikasi': 'Notifikasi',
    'getar': 'Getar',
    'notifikasi_getar': 'Notifikasi & Getar',
  };

  // ─── Pilihan Sisi Menyusui ───
  static const List<String> sisiOptions = ['Kiri', 'Kanan'];
}
