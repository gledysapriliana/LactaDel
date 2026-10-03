/// Service autentikasi Firebase.
/// Menangani: register email, login email, login Google (Web & Mobile),
/// reset password, logout, dan stream status login.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _webClientId =
      '841416327468-dgfkdbqtft4cgjaj5g13b0e21rgkvttm.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _webClientId : null,
    serverClientId: _webClientId,
  );

  /// User Firebase saat ini (null jika belum login)
  User? get currentUser => _auth.currentUser;

  /// Stream perubahan status login (untuk auto-detect login/logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Register dengan Email & Password ───
  Future<User?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  // ─── Login dengan Email & Password ───
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  // ─── Login dengan Google (Multiplatform: Web & Mobile) ───
  Future<User?> loginWithGoogle() async {
    if (kIsWeb) {
      // ─── FLUTTER WEB: Gunakan Firebase Auth signInWithPopup ───
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      try {
        final userCredential = await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      } on FirebaseAuthException catch (e) {
        debugPrint('Web Google Sign-In FirebaseAuthException: ${e.code} - ${e.message}');
        if (e.code == 'popup-closed-by-user' || e.code == 'user-cancelled') {
          return null; // Pengguna membatalkan login
        }
        if (e.code == 'popup-blocked') {
          // Browser memblokir popup, coba redirect
          await _auth.signInWithRedirect(googleProvider);
          return null;
        }
        rethrow;
      } catch (e) {
        debugPrint('Web Google Sign-In generic error: $e');
        rethrow;
      }
    } else {
      // ─── ANDROID / IOS: Gunakan package google_sign_in ───
      try {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          // User membatalkan dialog
          return null;
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      } on FirebaseAuthException {
        rethrow;
      } catch (e) {
        debugPrint('Mobile Google Sign-In error: $e');
        rethrow;
      }
    }
  }

  // ─── Reset Password ───
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ─── Logout ───
  Future<void> logout() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint('Google SignOut info: $e');
    }
    await _auth.signOut();
  }

  // ─── Update Display Name ───
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name.trim());
  }

  // ─── Terjemahkan kode error Firebase ke Bahasa Indonesia ───
  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      // Register
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan gunakan email lain atau masuk.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'invalid-email':
        return 'Format email tidak valid.';

      // Login
      case 'user-not-found':
        return 'Akun dengan email ini tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah. Silakan coba lagi.';
      case 'invalid-credential':
        return 'Email atau password salah. Silakan coba lagi.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan. Hubungi dukungan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Silakan coba lagi nanti.';

      // Jaringan & Ketersediaan
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      case 'unavailable':
        return 'Layanan server sedang offline atau tidak dapat dijangkau.';

      // Google Sign-In
      case 'account-exists-with-different-credential':
        return 'Email ini sudah terdaftar dengan metode login lain.';
      case 'operation-not-allowed':
        return 'Metode login Google belum diaktifkan di Firebase Console.';
      case 'popup-blocked':
        return 'Jendela popup Google diblokir oleh browser. Izinkan pop-up di browser Anda.';
      case 'popup-closed-by-user':
        return 'Login Google dibatalkan.';

      // Umum
      default:
        return 'Terjadi kesalahan: ${e.message ?? e.code}';
    }
  }
}
