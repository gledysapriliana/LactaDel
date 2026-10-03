/// Splash Screen LactaDel.
/// Alur: cek onboarding → cek login → navigasi ke layar yang sesuai.
/// Sesuai desain layar 1.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// Tentukan halaman berikutnya berdasarkan status onboarding & login
  Future<void> _navigateNext(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone =
        prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

    if (!context.mounted) return;

    // 1. Belum lihat onboarding → ke Onboarding
    if (!onboardingDone) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    // 2. Cek apakah user sudah login
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = await authProvider.checkAuthStatus();

    if (!context.mounted) return;

    if (isLoggedIn) {
      // Sudah login → ke Beranda
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // Belum login → ke Login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradient background biru sesuai desain
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkSurface, AppColors.darkBackground]
                : [AppColors.primary, AppColors.secondary, AppColors.backgroundLight],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ─── Ilustrasi / Logo ───
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 60 : 30),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      AppConstants.logoPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.family_restroom,
                          size: 70,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ─── Nama Aplikasi ───
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),

                // ─── Deskripsi ───
                Text(
                  'Aplikasi Edukasi untuk Ayah\ndalam Mendukung Ibu Primipara\nMemberikan ASI Eksklusif',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : Colors.white.withAlpha(230),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Tagline ───
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(isDark ? 20 : 38),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppConstants.tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.accent : Colors.white,
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ─── Tombol Mulai ───
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateNext(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? AppColors.darkPrimary : Colors.white,
                      foregroundColor:
                          isDark ? AppColors.darkBackground : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Mulai'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
