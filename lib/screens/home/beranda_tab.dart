/// Tab Beranda — sapaan, kartu motivasi, grid 4 menu.
/// Sesuai desain layar 7.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';

class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final nama = authProvider.appUser?.nama ?? 'Ayah';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: Logo + Notifikasi ───
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    AppConstants.logoPath,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'LactaDel',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => HomeScreen.switchTab(context, 2),
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─── Sapaan ───
            Text(
              'Halo, $nama! 👋',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Peranmu sangat berarti\nuntuk mendukung ibu\ndan Si Kecil.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // ─── Kartu Motivasi ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.darkPrimary.withAlpha(38), AppColors.darkSurface]
                      : [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: isDark ? AppColors.accent : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dukungan Ayah hadir ini,\nmaka ibu pun yang lebih baik\nuntuk Ibu dan Si Kecil.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: isDark ? AppColors.darkTextPrimary : Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(isDark ? 20 : 38),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppConstants.tagline,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.accent : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ─── Grid 4 Menu ───
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _MenuCard(
                  icon: Icons.menu_book,
                  label: 'Edukasi',
                  sublabel: 'Materi untuk Ayah',
                  color: AppColors.primary,
                  onTap: () => HomeScreen.switchTab(context, 1),
                ),
                _MenuCard(
                  icon: Icons.notifications_active,
                  label: 'Pengingat',
                  sublabel: 'Jadwal Menyusui',
                  color: AppColors.secondary,
                  onTap: () => HomeScreen.switchTab(context, 2),
                ),
                _MenuCard(
                  icon: Icons.bar_chart,
                  label: 'Monitoring',
                  sublabel: 'Pantau Menyusui',
                  color: const Color(0xFF43A047),
                  onTap: () => HomeScreen.switchTab(context, 3),
                ),
                _MenuCard(
                  icon: Icons.person,
                  label: 'Profil',
                  sublabel: 'Akun Saya',
                  color: const Color(0xFFE57373),
                  onTap: () => HomeScreen.switchTab(context, 4),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ─── Tips singkat ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.accent.withAlpha(20)
                    : AppColors.accent.withAlpha(64),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tips untuk Ayah: Dampingi ibu saat menyusui, '
                      'berikan air minum, dan tanyakan apa yang bisa dibantu.',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Kartu menu pada grid Beranda
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(isDark ? 51 : 38)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: color.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(isDark ? 38 : 26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(sublabel, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
