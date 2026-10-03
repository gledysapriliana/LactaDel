/// Layar Profil Pengguna.
/// Menampilkan:
/// 1. Nama dan email pengguna
/// 2. Fitur ubah nama dengan dialog & validasi
/// 3. Pilihan tema (Terang / Gelap / Ikuti Sistem) terhubung ke ThemeProvider
/// 4. Tombol Keluar dengan dialog konfirmasi
/// 5. Informasi aplikasi LactaDel
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catatan_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/theme_provider.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  // ─── Dialog Ubah Nama ───
  void _showEditNamaDialog(BuildContext context, String currentNama) {
    final controller = TextEditingController(text: currentNama);
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor:
                  isDark ? AppColors.darkSurface : AppColors.lightSurface,
              title: Row(
                children: [
                  Icon(
                    Icons.edit_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ubah Nama Panggilan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama ini akan ditampilkan pada sapaan beranda dan profil Ayah.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      enabled: !isSubmitting,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap / Panggilan',
                        hintText: 'Contoh: Ayah Budi',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        if (value.trim().length < 2) {
                          return 'Nama minimal 2 karakter';
                        }
                        if (value.trim().length > 50) {
                          return 'Nama maksimal 50 karakter';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => isSubmitting = true);
                          final authProv = dialogCtx.read<AuthProvider>();
                          final success =
                              await authProv.updateNama(controller.text);

                          if (dialogCtx.mounted) {
                            Navigator.of(dialogCtx).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Nama berhasil diperbarui!'
                                      : (authProv.errorMessage ??
                                          'Gagal memperbarui nama.'),
                                ),
                                backgroundColor: success
                                    ? AppColors.success
                                    : AppColors.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── Dialog Konfirmasi Logout ───
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
          title: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Keluar Akun',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Ayah yakin ingin keluar dari aplikasi LactaDel? Data Anda tetap tersimpan aman di cloud.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogCtx).pop();

                final authProvider = context.read<AuthProvider>();
                final catatanProvider = context.read<CatatanProvider>();
                final reminderProvider = context.read<ReminderProvider>();

                // Bersihkan subscription dan data lokal
                catatanProvider.bersihkan();
                reminderProvider.bersihkan();
                await authProvider.logout();

                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final nama = authProvider.appUser?.nama ?? 'Ayah';
    final email = authProvider.appUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header Profil (Avatar + Nama + Email) ───
              _buildProfileHeader(context, nama, email, isDark),
              const SizedBox(height: 24),

              // ─── Bagian: Pengaturan Akun ───
              _buildSectionTitle(context, 'Pengaturan Akun'),
              const SizedBox(height: 10),
              _buildAccountCard(context, nama, email, isDark),
              const SizedBox(height: 24),

              // ─── Bagian: Pilihan Tema ───
              _buildSectionTitle(context, 'Pilihan Tema Aplikasi'),
              const SizedBox(height: 10),
              _buildThemeCard(context, themeProvider, isDark),
              const SizedBox(height: 24),

              // ─── Bagian: Tentang Aplikasi ───
              _buildSectionTitle(context, 'Tentang Aplikasi'),
              const SizedBox(height: 10),
              _buildAboutCard(context, isDark),
              const SizedBox(height: 32),

              // ─── Tombol Keluar ───
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text(
                    'Keluar Akun',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    );
  }

  // ─── Widget: Header Profil ───
  Widget _buildProfileHeader(
    BuildContext context,
    String nama,
    String email,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'A';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkTextSecondary.withAlpha(25)
              : AppColors.secondary.withAlpha(45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  AppColors.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(60),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Nama
          Text(
            nama,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            email.isNotEmpty ? email : 'Pengguna LactaDel',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Badge Peran
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(60),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ayah ASI Siaga',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widget: Kartu Akun ───
  Widget _buildAccountCard(
    BuildContext context,
    String nama,
    String email,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkTextSecondary.withAlpha(25)
              : AppColors.secondary.withAlpha(45),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(isDark ? 35 : 20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            title: const Text('Nama Lengkap / Panggilan'),
            subtitle: Text(
              nama,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Ubah nama',
              onPressed: () => _showEditNamaDialog(context, nama),
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? AppColors.darkTextSecondary.withAlpha(25)
                : AppColors.secondary.withAlpha(40),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withAlpha(isDark ? 35 : 20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.email_outlined,
                color: Colors.teal,
                size: 20,
              ),
            ),
            title: const Text('Email Terdaftar'),
            subtitle: Text(
              email.isNotEmpty ? email : '-',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widget: Kartu Pilihan Tema ───
  Widget _buildThemeCard(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final currentMode = themeProvider.themeMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkTextSecondary.withAlpha(25)
              : AppColors.secondary.withAlpha(45),
        ),
      ),
      child: Column(
        children: [
          // 1. Tema Terang
          _buildThemeTile(
            context: context,
            title: 'Terang',
            subtitle: 'Tampilan cerah, segar & bersih',
            icon: Icons.light_mode_rounded,
            iconColor: Colors.amber.shade700,
            isSelected: currentMode == ThemeMode.light,
            onTap: () => themeProvider.setThemeMode(ThemeMode.light),
            isDark: isDark,
          ),
          Divider(
            height: 1,
            color: isDark
                ? AppColors.darkTextSecondary.withAlpha(25)
                : AppColors.secondary.withAlpha(40),
          ),
          // 2. Tema Gelap
          _buildThemeTile(
            context: context,
            title: 'Gelap',
            subtitle: 'Nyaman di mata untuk malam hari',
            icon: Icons.dark_mode_rounded,
            iconColor: Colors.indigo.shade300,
            isSelected: currentMode == ThemeMode.dark,
            onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
            isDark: isDark,
          ),
          Divider(
            height: 1,
            color: isDark
                ? AppColors.darkTextSecondary.withAlpha(25)
                : AppColors.secondary.withAlpha(40),
          ),
          // 3. Ikuti Sistem
          _buildThemeTile(
            context: context,
            title: 'Ikuti Sistem',
            subtitle: 'Menyesuaikan mode perangkat secara otomatis',
            icon: Icons.brightness_auto_rounded,
            iconColor: theme.colorScheme.primary,
            isSelected: currentMode == ThemeMode.system,
            onTap: () => themeProvider.setThemeMode(ThemeMode.system),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(isDark ? 35 : 20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark
                          ? AppColors.darkTextSecondary.withAlpha(120)
                          : AppColors.lightTextSecondary.withAlpha(120)),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Widget: Kartu Tentang Aplikasi ───
  Widget _buildAboutCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkTextSecondary.withAlpha(25)
              : AppColors.secondary.withAlpha(45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LactaDel',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Versi 1.0.0 (Tahap 6)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'LactaDel adalah aplikasi pendamping edukasi, pengingat, dan pemantauan ASI yang dirancang khusus untuk memberdayakan peran aktif Ayah dalam mendukung Ibu dan menyukseskan pemberian ASI Eksklusif.',
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
