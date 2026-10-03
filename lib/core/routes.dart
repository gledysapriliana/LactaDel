/// Definisi semua named routes aplikasi LactaDel.
/// Setiap layar punya route unik agar navigasi konsisten.
library;

class AppRoutes {
  AppRoutes._();

  // ─── Onboarding & Auth ───
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  // ─── Utama ───
  static const String home = '/home';

  // ─── Edukasi ───
  static const String edukasi = '/edukasi';
  static const String detailMateri = '/edukasi/detail';
  static const String referensiMateri = '/edukasi/referensi';
  static const String videoMateri = '/edukasi/video';

  // ─── Pengingat ───
  static const String pengingat = '/pengingat';

  // ─── Monitoring ───
  static const String monitoring = '/monitoring';

  // ─── Profil ───
  static const String profil = '/profil';
}
