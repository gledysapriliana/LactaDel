/// Layar placeholder untuk route yang belum diimplementasi.
/// Menampilkan nama layar agar tahu navigasi berhasil.
/// Akan diganti dengan implementasi asli di tahap selanjutnya.
library;

import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String namaLayar;
  final IconData ikon;

  const PlaceholderScreen({
    super.key,
    required this.namaLayar,
    this.ikon = Icons.construction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(namaLayar),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon layar
            Icon(
              ikon,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),

            // Nama layar
            Text(
              namaLayar,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Keterangan
            Text(
              'Layar ini akan diimplementasi\ndi tahap berikutnya.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
