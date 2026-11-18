/// Layar Profil Pengguna.
/// Menampilkan:
/// 1. Nama dan email pengguna
/// 2. Fitur ubah nama dengan dialog & validasi
/// 3. Pilihan tema (Terang / Gelap / Ikuti Sistem) terhubung ke ThemeProvider
/// 4. Tombol Keluar dengan dialog konfirmasi
/// 5. Informasi aplikasi LactaDel
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catatan_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/logo_header.dart';
import '../../widgets/user_avatar.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  // ─── Dialog / Bottom Sheet Ubah Foto Profil ───
  void _showEditFotoDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final hasFoto = authProvider.appUser?.fotoProfil != null &&
        authProvider.appUser!.fotoProfil!.isNotEmpty;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(100),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Foto Profil',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih sumber foto untuk profil Ayah:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Ambil dari Kamera
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  title: const Text('Ambil Foto dari Kamera'),
                  subtitle: const Text('Gunakan kamera ponsel langsung'),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    _pickAndSaveImage(context, ImageSource.camera);
                  },
                ),

                // 2. Pilih dari Galeri
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  title: const Text('Pilih dari Galeri'),
                  subtitle: const Text('Pilih foto yang tersimpan di galeri'),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    _pickAndSaveImage(context, ImageSource.gallery);
                  },
                ),

                // 3. Hapus Foto (hanya jika ada foto)
                if (hasFoto) ...[
                  const Divider(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                    ),
                    title: const Text(
                      'Hapus Foto Profil',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text('Kembali menggunakan inisial nama'),
                    onTap: () async {
                      Navigator.pop(bottomSheetCtx);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Foto Profil'),
                          content: const Text(
                            'Apakah Ayah yakin ingin menghapus foto profil ini?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        final authProv = context.read<AuthProvider>();
                        await authProv.updateFotoProfil(null);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Foto profil berhasil dihapus.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Proses Ambil & Simpan Gambar ───
  Future<void> _pickAndSaveImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile == null || !context.mounted) return;

      final bytes = await pickedFile.readAsBytes();
      if (!context.mounted) return;

      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      final authProv = context.read<AuthProvider>();
      final success = await authProv.updateFotoProfil(base64Image);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Foto profil berhasil diperbarui!'
                  : (authProv.errorMessage ?? 'Gagal memperbarui foto profil.'),
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error memilih gambar: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

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
    final fotoProfil = authProvider.appUser?.fotoProfil;

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
              // ─── Logo UNSRI + Rumah Kita ───
              const LogoHeader(height: 28),
              const SizedBox(height: 16),

              // ─── Header Profil (Avatar + Nama + Email) ───
              _buildProfileHeader(context, nama, email, fotoProfil, isDark),
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
    String? fotoProfil,
    bool isDark,
  ) {
    final theme = Theme.of(context);

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
          // Avatar dengan tombol edit foto langsung
          UserAvatar(
            fotoProfil: fotoProfil,
            nama: nama,
            radius: 40,
            showEditBadge: true,
            onTap: () => _showEditFotoDialog(context),
          ),
          const SizedBox(height: 8),

          // Tombol interaktif untuk ubah/tambah foto
          InkWell(
            onTap: () => _showEditFotoDialog(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 15,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    fotoProfil != null ? 'Ubah Foto Profil' : 'Tambah Foto Profil',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

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
