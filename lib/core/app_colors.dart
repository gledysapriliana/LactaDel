/// Definisi semua warna aplikasi LactaDel.
/// Semua warna didefinisikan di sini agar konsisten.
/// DILARANG hardcode warna di layar — gunakan Theme.of(context).
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Tidak bisa di-instantiasi

  // ─── Palet Utama ───
  static const Color primary = Color(0xFF2E73B8);
  static const Color secondary = Color(0xFF7BB3F0);
  static const Color backgroundLight = Color(0xFFE6F2FF);
  static const Color accent = Color(0xFFFAD1D1);

  // ─── Light Mode ───
  static const Color lightBackground = Color(0xFFE6F2FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF2E73B8);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF5A6A7A);

  // ─── Dark Mode ───
  static const Color darkBackground = Color(0xFF0F1720);
  static const Color darkSurface = Color(0xFF1A2433);
  static const Color darkPrimary = Color(0xFF7BB3F0);
  static const Color darkTextPrimary = Color(0xFFE8EEF5);
  static const Color darkTextSecondary = Color(0xFF9FB0C3);

  // ─── Warna Umum ───
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
