/// Detail Materi — template dipakai ulang oleh semua materi.
/// Peran Ayah: kotak "Anda akan mempelajari" + tombol "Mulai Belajar".
/// Dukungan Emosional: area video.
/// Semua materi: penjelasan, poin tindakan, tombol Referensi.
/// Sesuai desain layar 9 – 14.
library;

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/materi.dart';
import 'referensi_screen.dart';
import 'video_materi_screen.dart';

class DetailMateriScreen extends StatelessWidget {
  final Materi materi;

  const DetailMateriScreen({super.key, required this.materi});

  /// Map nama ikon ke IconData
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPeranAyah = materi.id == 1;
    final hasilVideo = materi.videoUrl != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          materi.judul,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header dengan ilustrasi ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.darkSurface, AppColors.darkBackground]
                      : [AppColors.backgroundLight, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Ikon besar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkPrimary.withAlpha(26)
                          : AppColors.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(materi.ikon),
                      size: 50,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Judul
                  Text(
                    materi.judul,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (materi.kutipan.isNotEmpty) ...[
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
                            : AppColors.accent.withAlpha(77),
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
                  ],
                ],
              ),
            ),

            // ─── Area Video (Dukungan Emosional) ───
            if (hasilVideo) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _VideoSection(
                  videoUrl: materi.videoUrl!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoMateriScreen(
                          videoUrl: materi.videoUrl!,
                          judul: materi.judul,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ─── Kotak "Anda akan mempelajari" (khusus Peran Ayah) ───
            if (isPeranAyah && materi.poinBelajar != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _BelajarSection(poinBelajar: materi.poinBelajar!),
              ),
              const SizedBox(height: 16),
            ],

            // ─── Penjelasan ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penjelasan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    materi.penjelasan,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Poin Tindakan: "Apa yang dapat dilakukan Ayah?" ───
            if (materi.poinTindakan.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apa yang dapat dilakukan Ayah?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...materi.poinTindakan.map(
                      (poin) => _ActionItem(text: poin),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Tombol Referensi ───
            if (materi.referensi.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReferensiScreen(materi: materi),
                        ),
                      );
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('Referensi'),
                  ),
                ),
              ),

            // ─── Tombol "Mulai Belajar" (khusus Peran Ayah) ───
            if (isPeranAyah) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Mulai Belajar'),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Kotak "Pada materi ini Anda akan mempelajari" (Peran Ayah)
class _BelajarSection extends StatelessWidget {
  final List<String> poinBelajar;

  const _BelajarSection({required this.poinBelajar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkPrimary.withAlpha(20)
            : AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.darkPrimary.withAlpha(38)
              : AppColors.primary.withAlpha(38),
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
          ...poinBelajar.map(
            (poin) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(poin, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Area video placeholder (Dukungan Emosional)
class _VideoSection extends StatelessWidget {
  final String videoUrl;
  final VoidCallback onTap;

  const _VideoSection({required this.videoUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: videoUrl.isNotEmpty ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_fill,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                videoUrl.isNotEmpty
                    ? 'Tonton Video'
                    : 'Video akan segera tersedia',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu poin tindakan dengan ikon centang
class _ActionItem extends StatelessWidget {
  final String text;

  const _ActionItem({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 14,
              color: Color(0xFF43A047),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
