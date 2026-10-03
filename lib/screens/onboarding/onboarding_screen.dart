/// Onboarding 3 halaman LactaDel.
/// Memakai PageView dengan indikator titik dan tombol panah.
/// Sesuai desain layar 2, 3, 4.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Data 3 halaman onboarding
  final List<_OnboardingPageData> _pages = const [
    // Halaman 1
    _OnboardingPageData(
      icon: Icons.child_care,
      title: 'ASI Eksklusif\nuntuk Masa Depan Si Kecil',
      description:
          'ASI eksklusif selama 6 bulan pertama memberikan nutrisi terbaik, melindungi dari berbagai penyakit, dan mendukung pertumbuhan optimal.',
    ),
    // Halaman 2
    _OnboardingPageData(
      icon: Icons.family_restroom,
      title: 'Ayah, Kamu\nBerperan Penting',
      description:
          'Kehadiran, perhatian, dan dukungan ayah dapat membantu ibu lebih tenang dan percaya diri dalam memberikan ASI eksklusif.',
    ),
    // Halaman 3 (halaman terakhir, punya menu ikon)
    _OnboardingPageData(
      icon: Icons.rocket_launch,
      title: 'Mulai Perjalanan\nBersama LactaDel',
      description:
          'Dapatkan informasi, tips, dan panduan praktis untuk menjadi ayah yang selalu ada di setiap langkah.',
      isLastPage: true,
    ),
  ];

  /// Simpan flag onboarding selesai dan navigasi ke login
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  /// Pindah ke halaman berikutnya atau selesai
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkSurface, AppColors.darkBackground]
                : [AppColors.backgroundLight, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── PageView (konten utama) ───
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(context, _pages[index]);
                  },
                ),
              ),

              // ─── Indikator Titik ───
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildDot(context, index),
                  ),
                ),
              ),

              // ─── Tombol Navigasi ───
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: _currentPage == _pages.length - 1
                    // Halaman terakhir: tombol "Mulai Menggunakan LactaDel"
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _completeOnboarding,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Mulai Menggunakan LactaDel'),
                        ),
                      )
                    // Halaman 1 & 2: tombol panah bulat
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tombol Skip
                          TextButton(
                            onPressed: _completeOnboarding,
                            child: Text(
                              'Lewati',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          // Tombol panah maju
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _nextPage,
                              icon: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Konten satu halaman onboarding
  Widget _buildPage(BuildContext context, _OnboardingPageData data) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // ─── Ilustrasi / Ikon besar ───
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkPrimary.withAlpha(26)
                  : AppColors.primary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 90,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 40),

          // ─── Judul ───
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // ─── Deskripsi ───
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.6,
            ),
          ),

          // ─── 4 Ikon Menu (hanya di halaman terakhir) ───
          if (data.isLastPage) ...[
            const SizedBox(height: 40),
            _buildMenuIcons(context),
          ],

          const Spacer(),
        ],
      ),
    );
  }

  /// 4 ikon fitur di halaman onboarding terakhir
  Widget _buildMenuIcons(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = [
      _MenuItem(Icons.menu_book, 'Edukasi'),
      _MenuItem(Icons.notifications_active, 'Pengingat'),
      _MenuItem(Icons.bar_chart, 'Monitoring'),
      _MenuItem(Icons.person, 'Profil'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.map((item) {
        return Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkPrimary.withAlpha(38)
                    : AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                item.icon,
                size: 28,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Indikator titik (dot)
  Widget _buildDot(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isActive = index == _currentPage;

    return AnimatedContainer(
      duration: AppConstants.animationDuration,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.primary.withAlpha(64),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Data model untuk satu halaman onboarding
class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final bool isLastPage;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    this.isLastPage = false,
  });
}

/// Data model untuk ikon menu
class _MenuItem {
  final IconData icon;
  final String label;

  const _MenuItem(this.icon, this.label);
}
