/// Widget logo UNSRI + Rumah Kita yang ditampilkan di sudut kiri atas semua halaman.
/// Logo sejajar horizontal: logo UNSRI dulu, lalu logo Rumah Kita (sesuai contoh).
library;

import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  /// Tinggi setiap logo (default 30)
  final double height;

  /// Jarak antar logo (default 8)
  final double spacing;

  /// Tampilkan latar belakang putih lembut agar kontras di semua kondisi latar
  final bool showBackground;

  const LogoHeader({
    super.key,
    this.height = 30,
    this.spacing = 8,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo UNSRI
        Image.asset(
          'assets/logo/logo_unsri.png',
          height: height,
          fit: BoxFit.contain,
        ),
        SizedBox(width: spacing),
        // Logo Rumah Kita
        Image.asset(
          'assets/logo/logo_rumahkita.png',
          height: height,
          fit: BoxFit.contain,
        ),
      ],
    );

    if (showBackground) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        child: content,
      );
    }

    return content;
  }
}
