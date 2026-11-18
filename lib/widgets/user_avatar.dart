/// Widget avatar pengguna LactaDel.
/// Mendukung:
/// - Base64 image data URL ('data:image/...;base64,...')
/// - Network URL ('http://...' / 'https://...')
/// - Asset image ('assets/...')
/// - Fallback huruf inisial dengan gradient modern
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? fotoProfil;
  final String nama;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditBadge;

  const UserAvatar({
    super.key,
    this.fotoProfil,
    required this.nama,
    this.radius = 38,
    this.onTap,
    this.showEditBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = nama.trim().isNotEmpty ? nama.trim()[0].toUpperCase() : 'A';
    final diameter = radius * 2;

    Widget avatarImage;

    if (fotoProfil != null && fotoProfil!.isNotEmpty) {
      final foto = fotoProfil!;
      if (foto.startsWith('data:image') || foto.length > 200) {
        // Format Base64
        try {
          final cleanBase64 = foto.contains(',') ? foto.split(',')[1] : foto;
          final bytes = base64Decode(cleanBase64);
          avatarImage = Image.memory(
            bytes,
            width: diameter,
            height: diameter,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackInitial(theme, initial),
          );
        } catch (_) {
          avatarImage = _buildFallbackInitial(theme, initial);
        }
      } else if (foto.startsWith('http')) {
        // Format URL Web
        avatarImage = Image.network(
          foto,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallbackInitial(theme, initial),
        );
      } else if (foto.startsWith('assets/')) {
        // Format Asset lokal
        avatarImage = Image.asset(
          foto,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallbackInitial(theme, initial),
        );
      } else {
        avatarImage = _buildFallbackInitial(theme, initial);
      }
    } else {
      avatarImage = _buildFallbackInitial(theme, initial);
    }

    Widget avatar = Container(
      width: diameter,
      height: diameter,
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
      child: ClipOval(child: avatarImage),
    );

    if (!showEditBadge) {
      if (onTap != null) {
        return GestureDetector(onTap: onTap, child: avatar);
      }
      return avatar;
    }

    // Dengan badge kamera / edit di sudut kanan bawah
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackInitial(ThemeData theme, String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.85,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
