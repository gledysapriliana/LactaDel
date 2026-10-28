/// Layar Video Materi — membuka video Google Drive via url_launcher.
/// Menampilkan thumbnail dengan tombol putar, lalu buka di browser/app.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';

class VideoMateriScreen extends StatefulWidget {
  final String videoUrl;
  final String judul;

  const VideoMateriScreen({
    super.key,
    required this.videoUrl,
    required this.judul,
  });

  @override
  State<VideoMateriScreen> createState() => _VideoMateriScreenState();
}

class _VideoMateriScreenState extends State<VideoMateriScreen> {
  bool _isLoading = false;

  Future<void> _bukaVideo() async {
    final uri = Uri.parse(widget.videoUrl);
    setState(() => _isLoading = true);

    try {
      final bisa = await canLaunchUrl(uri);
      if (bisa) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka video.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final adaVideo = widget.videoUrl.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Video ${widget.judul}', style: const TextStyle(fontSize: 16)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─── Thumbnail / Area Video ───
              GestureDetector(
                onTap: adaVideo ? _bukaVideo : null,
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.darkSurface, AppColors.darkBackground]
                          : [AppColors.backgroundLight, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkPrimary.withAlpha(60)
                          : AppColors.primary.withAlpha(60),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(30),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 44,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              adaVideo
                                  ? 'Tap untuk memutar video'
                                  : 'Video akan segera tersedia',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 28),

              // ─── Judul ───
              Text(
                widget.judul,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                adaVideo
                    ? 'Video akan dibuka di browser atau aplikasi Google Drive Anda.'
                    : 'Video untuk materi ini belum tersedia.\nSilakan kembali lagi nanti.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // ─── Tombol Putar ───
              if (adaVideo)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _bukaVideo,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.play_circle_outline),
                    label: Text(_isLoading ? 'Membuka...' : 'Tonton Video'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
