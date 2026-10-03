/// Provider autentikasi — mengelola state login/logout/loading/error.
/// Menggunakan AuthService dan FirestoreService.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // ─── State ───
  AppUser? _appUser;
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Getters ───
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _authService.currentUser != null;

  /// Bersihkan pesan error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ─── Cek status login saat app dimulai ───
  /// Dipanggil dari SplashScreen untuk menentukan halaman awal.
  Future<bool> checkAuthStatus() async {
    final user = _authService.currentUser;
    if (user == null) return false;

    final namaFallback = (user.displayName != null && user.displayName!.isNotEmpty)
        ? user.displayName!
        : 'Ayah';

    // Inisialisasi fallback langsung dari sesi FirebaseAuth
    _appUser = AppUser(
      uid: user.uid,
      nama: namaFallback,
      email: user.email ?? '',
      createdAt: DateTime.now(),
    );

    // Coba perbarui data dari Firestore secara non-blocking / offline tolerant
    try {
      final firestoreUser = await _firestoreService.getUser(user.uid);
      if (firestoreUser != null) {
        _appUser = firestoreUser;
      } else {
        // Buat dokumen user di background jika belum ada
        _firestoreService.createUser(_appUser!).catchError((_) {});
      }
    } catch (e) {
      debugPrint('Catatan: Firestore getUser offline saat checkAuthStatus: $e');
    }

    notifyListeners();
    return true;
  }

  // ─── Register Email (Cepat & Responsif) ───
  Future<bool> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // 1. Buat akun di Firebase Auth
      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        final cleanNama = nama.trim();
        final cleanEmail = email.trim();

        // 2. Update display name di Firebase Auth
        user.updateDisplayName(cleanNama).catchError((_) {});

        // 3. Simpan data user ke state aplikasi segera
        _appUser = AppUser(
          uid: user.uid,
          nama: cleanNama,
          email: cleanEmail,
          createdAt: DateTime.now(),
        );

        // 4. Sinkronkan dokumen Firestore di background (tidak menahan UI)
        _firestoreService.createUser(_appUser!).catchError((e) {
          debugPrint('Peringatan: Gagal sinkronisasi Firestore registrasi: $e');
        });

        _setLoading(false);
        return true;
      }

      _errorMessage = 'Gagal membuat akun. Silakan coba lagi.';
      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('Error registrasi: $e');
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      _setLoading(false);
      return false;
    }
  }

  // ─── Login Email ───
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.loginWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        final namaFallback = (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : 'Ayah';

        _appUser = AppUser(
          uid: user.uid,
          nama: namaFallback,
          email: user.email ?? email.trim(),
          createdAt: DateTime.now(),
        );

        // Coba sinkronisasi profil dari Firestore
        try {
          final firestoreUser = await _firestoreService.getUser(user.uid);
          if (firestoreUser != null) {
            _appUser = firestoreUser;
          } else {
            _firestoreService.createUser(_appUser!).catchError((_) {});
          }
        } catch (e) {
          debugPrint('Info: Firestore getUser offline saat login: $e');
        }

        _setLoading(false);
        return true;
      }

      _errorMessage = 'Gagal masuk. Silakan coba lagi.';
      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('Error login: $e');
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      _setLoading(false);
      return false;
    }
  }

  // ─── Login Google (Web & Mobile) ───
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.loginWithGoogle();

      if (user == null) {
        // Pengguna membatalkan login
        _setLoading(false);
        return false;
      }

      final namaUser = (user.displayName != null && user.displayName!.isNotEmpty)
          ? user.displayName!
          : 'Ayah';

      _appUser = AppUser(
        uid: user.uid,
        nama: namaUser,
        email: user.email ?? '',
        createdAt: DateTime.now(),
      );

      // Cek dokumen di Firestore secara offline-tolerant
      try {
        final firestoreUser = await _firestoreService.getUser(user.uid);
        if (firestoreUser != null) {
          _appUser = firestoreUser;
        } else {
          _firestoreService.createUser(_appUser!).catchError((_) {});
        }
      } catch (e) {
        debugPrint('Info: Firestore getUser saat login Google offline: $e');
        _firestoreService.createUser(_appUser!).catchError((_) {});
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('Error login Google: $e');
      _errorMessage = 'Gagal masuk dengan Google: $e';
      _setLoading(false);
      return false;
    }
  }

  // ─── Reset Password ───
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Gagal mengirim email reset password.';
      _setLoading(false);
      return false;
    }
  }

  // ─── Logout ───
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _appUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal keluar. Silakan coba lagi.';
    }
    _setLoading(false);
  }

  // ─── Ubah Nama Pengguna ───
  Future<bool> updateNama(String newNama) async {
    final user = _authService.currentUser;
    if (user == null) {
      _errorMessage = 'Pengguna belum masuk.';
      notifyListeners();
      return false;
    }

    final trimmed = newNama.trim();
    if (trimmed.isEmpty) {
      _errorMessage = 'Nama tidak boleh kosong.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.updateDisplayName(trimmed);
      _appUser = _appUser?.copyWith(nama: trimmed);
      _firestoreService.updateUser(user.uid, {'nama': trimmed}).catchError((e) {
        debugPrint('Peringatan: Gagal update nama di Firestore: $e');
      });
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Error update nama: $e');
      _errorMessage = 'Gagal memperbarui nama. Silakan coba lagi.';
      _setLoading(false);
      return false;
    }
  }
}
