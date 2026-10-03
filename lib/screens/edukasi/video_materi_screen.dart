/// Layar Video Materi (Dukungan Emosional).
/// Menampilkan video player jika URL tersedia, atau placeholder.
library;

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class VideoMateriScreen extends StatelessWidget {
  final String videoUrl;
  final String judul;

  const VideoMateriScreen({
    super.key,
    required this.videoUrl,
    required this.judul,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Video $judul', style: const TextStyle(fontSize: 16)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─── Area Video Placeholder ───
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkPrimary.withAlpha(38)
                        : AppColors.secondary.withAlpha(77),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_fill,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    // Progress bar placeholder
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        children: [
                          Text(
                            '0:00',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: 0,
                              backgroundColor: isDark
                                  ? AppColors.darkTextSecondary.withAlpha(38)
                                  : Colors.grey.shade300,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '0:45',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Keterangan ───
              Text(
                videoUrl.isEmpty
                    ? 'Video akan segera tersedia.\nSilakan kembali lagi nanti.'
                    : 'Video $judul',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
