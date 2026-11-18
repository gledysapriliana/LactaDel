/// Menu Edukasi — daftar 6 materi dengan ikon dan panah.
/// Flow: Pertama kali user masuk → otomatis tampil materi "Peran Suami" (id=1),
/// setelah membaca dan menekan "Mulai Belajar" → kembali ke daftar 4 dukungan.
/// Sesuai revisi: peran suami dulu, baru mulai belajar 4 dukungan.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../data/materi_data.dart';
import '../../models/materi.dart';
import '../../widgets/logo_header.dart';
import 'detail_materi_screen.dart';

class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({super.key});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  /// Apakah user sudah membaca materi Peran Suami dalam sesi ini
  bool _sudahBacaPeranSuami = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final sudah = prefs.getBool('edukasi_sudah_baca_peran_suami') ?? false;
    if (mounted) {
      setState(() => _sudahBacaPeranSuami = sudah);
    }
  }

  Future<void> _tandaiSudahBaca() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('edukasi_sudah_baca_peran_suami', true);
    if (mounted) {
      setState(() => _sudahBacaPeranSuami = true);
    }
  }

  /// Navigasi ke detail materi Peran Suami (id=1) secara otomatis
  void _tampilkanPeranSuami() {
    final materiPeranSuami = MateriData.getById(1);
    if (materiPeranSuami == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailMateriScreen(
          materi: materiPeranSuami,
          onMulaiBelajar: _tandaiSudahBaca,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Ambil materi Peran Suami (id=1) dan 4 Dukungan (id 2-5) + Tantangan (id=6)
    final materiPeranSuami = MateriData.getById(1)!;
    // Daftar materi yang tampil setelah user membaca Peran Suami
    final materiDukungan = MateriData.semuaMateri.where((m) => m.id >= 2).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ——— Logo Header ———
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: LogoHeader(height: 30),
          ),

          // ——— Header ———
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkPrimary.withAlpha(26)
                        : AppColors.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.menu_book,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edukasi',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Materi khusus untuk Ayah\ndalam mendukung ASI eksklusif',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ——— Konten ———
          Expanded(
            child: !_sudahBacaPeranSuami
                // Belum baca Peran Suami → tampilkan intro + tombol mulai
                ? _buildIntroPeranSuami(context, materiPeranSuami, isDark)
                // Sudah baca → tampilkan daftar 4 dukungan + tantangan
                : _buildDaftarDukungan(context, materiDukungan, isDark),
          ),
        ],
      ),
    );
  }

  /// Tampilan awal: intro Peran Suami dengan tombol "Mulai Belajar"
  Widget _buildIntroPeranSuami(
    BuildContext context,
    Materi materi,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Kartu Peran Suami
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.darkPrimary.withAlpha(30),
                        AppColors.darkSurface,
                      ]
                    : [
                        AppColors.primary.withAlpha(15),
                        AppColors.backgroundLight,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.darkPrimary.withAlpha(40)
                    : AppColors.primary.withAlpha(30),
              ),
            ),
            child: Column(
              children: [
                // Ikon besar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkPrimary.withAlpha(30)
                        : AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.family_restroom,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Judul
                Text(
                  'Peran Ayah dalam\nASI Eksklusif',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Kutipan
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.accent.withAlpha(20)
                        : AppColors.accent.withAlpha(60),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '"${materi.kutipan}"',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Deskripsi
                Text(
                  materi.deskripsiSingkat,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Info box: "Anda akan mempelajari"
          if (materi.poinBelajar != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkPrimary.withAlpha(20)
                    : AppColors.primary.withAlpha(12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkPrimary.withAlpha(38)
                      : AppColors.primary.withAlpha(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pada materi ini Anda akan mempelajari:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...materi.poinBelajar!.map(
                    (poin) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              poin,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Tombol Mulai Belajar (Pelajari Peran Suami)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _tampilkanPeranSuami,
              icon: const Icon(Icons.school),
              label: const Text('Mulai Belajar (Peran Suami)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tombol Langsung ke 4 Dukungan
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _tandaiSudahBaca,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Lanjut ke 4 Bentuk Dukungan'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Daftar 4 dukungan + tantangan setelah user membaca Peran Suami
  Widget _buildDaftarDukungan(
    BuildContext context,
    List<Materi> materiList,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.success.withAlpha(20)
                  : AppColors.success.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withAlpha(40),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Peran Suami sudah dipelajari! Sekarang pelajari 4 bentuk dukungan.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Tombol kecil untuk membuka kembali Peran Suami
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            onTap: _tampilkanPeranSuami,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkPrimary.withAlpha(15)
                    : AppColors.primary.withAlpha(10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkPrimary.withAlpha(30)
                      : AppColors.primary.withAlpha(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.family_restroom,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Buka kembali: Peran Ayah dalam ASI Eksklusif',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Daftar materi dukungan
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: materiList.length,
            itemBuilder: (context, index) {
              final materi = materiList[index];
              return _MateriListItem(
                materi: materi,
                icon: _getIcon(materi.ikon),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailMateriScreen(materi: materi),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Map nama ikon string ke IconData
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'family_restroom':
        return Icons.family_restroom;
      case 'favorite':
        return Icons.favorite;
      case 'menu_book':
        return Icons.menu_book;
      case 'handshake':
        return Icons.handshake;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'psychology':
        return Icons.psychology;
      default:
        return Icons.article;
    }
  }
}

/// Item satu materi dalam daftar
class _MateriListItem extends StatelessWidget {
  final Materi materi;
  final IconData icon;
  final VoidCallback onTap;

  const _MateriListItem({
    required this.materi,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? AppColors.darkPrimary.withAlpha(26)
                  : AppColors.secondary.withAlpha(64),
            ),
          ),
          child: Row(
            children: [
              // Ikon materi
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimary.withAlpha(26)
                      : AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 14),

              // Judul + deskripsi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materi.judul,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      materi.deskripsiSingkat,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Panah
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
