/// Provider pengaturan pengingat menyusui.
/// Baca/simpan di Firestore: users/{uid}/pengaturan/pengingat
/// Jadwalkan/batalkan notifikasi lokal sesuai pengaturan.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/pengaturan_pengingat.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final NotificationService _notifService = NotificationService.instance;

  ReminderProvider({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  PengaturanPengingat _pengaturan = PengaturanPengingat();
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Getters ───
  PengaturanPengingat get pengaturan => _pengaturan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  // ─── Muat pengaturan dari Firestore ───
  Future<void> muatPengaturan() async {
    final uid = _currentUid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _pengaturan = await _firestoreService.getPengaturanPengingat(uid);

      // Jika pengaturan aktif, jadwalkan ulang notifikasi (tidak didukung di Web)
      if (!kIsWeb && _pengaturan.aktif) {
        await _notifService.jadwalkanPengingat(
          intervalJam: _pengaturan.intervalJam,
          waktuMulai: _pengaturan.waktuMulai,
          jenisSuara: _pengaturan.jenisSuara,
        );
      }

      _errorMessage = null;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' ||
          e.message?.toLowerCase().contains('offline') == true) {
        _errorMessage = null;
      } else {
        debugPrint('Firestore error muat pengaturan: ${e.code} - ${e.message}');
        _errorMessage = 'Gagal memuat pengaturan: ${e.message ?? e.code}';
      }
    } catch (e) {
      debugPrint('Error muat pengaturan: $e');
      _errorMessage = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Update pengaturan lokal (sebelum Simpan) ───
  void updatePengaturan(PengaturanPengingat baru) {
    _pengaturan = baru;
    notifyListeners();
  }

  // ─── Simpan pengaturan ke Firestore & jadwalkan notifikasi ───
  Future<bool> simpanPengaturan() async {
    final uid = _currentUid;
    if (uid == null) {
      _errorMessage = 'User belum login.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simpan ke Firestore
      await _firestoreService.savePengaturanPengingat(uid, _pengaturan);

      // Jadwalkan atau batalkan notifikasi (tidak didukung di Web)
      if (!kIsWeb) {
        if (_pengaturan.aktif) {
          final granted = await _notifService.requestPermission();
          if (!granted) {
            _errorMessage =
                'Izin notifikasi ditolak. Aktifkan di pengaturan HP.';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          await _notifService.jadwalkanPengingat(
            intervalJam: _pengaturan.intervalJam,
            waktuMulai: _pengaturan.waktuMulai,
            jenisSuara: _pengaturan.jenisSuara,
          );
        } else {
          await _notifService.batalkanSemua();
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Firestore error simpan pengaturan: ${e.code} - ${e.message}');
      _errorMessage = 'Gagal menyimpan: ${e.message ?? e.code}';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error simpan pengaturan: $e');
      _errorMessage = 'Gagal menyimpan pengaturan.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Bersihkan State (Logout) ───
  void bersihkan() {
    _pengaturan = PengaturanPengingat();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
