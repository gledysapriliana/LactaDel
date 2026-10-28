/// Provider catatan menyusui.
/// Mendukung stream real-time Firestore: users/{uid}/catatan_menyusui.
library;

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/catatan_menyusui.dart';
import '../services/firestore_service.dart';

/// Model ringkasan harian untuk visualisasi grafik dan daftar riwayat
class RiwayatHarian {
  final DateTime tanggal;
  final int jumlahSesi;
  final int totalDurasiMenit;
  final List<CatatanMenyusui> daftarCatatan;
  final bool isHariIni;

  const RiwayatHarian({
    required this.tanggal,
    required this.jumlahSesi,
    required this.totalDurasiMenit,
    required this.daftarCatatan,
    required this.isHariIni,
  });
}

class CatatanProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  CatatanProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  List<CatatanMenyusui> _daftarCatatan = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<CatatanMenyusui>>? _catatanSubscription;

  // ─── Getters ───
  List<CatatanMenyusui> get daftarCatatan => _daftarCatatan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  // ─── Inisialisasi Stream Real-Time ───
  /// Mendengarkan perubahan dokumen secara real-time dari Firestore.
  void inisialisasiStream() {
    final uid = _currentUid;
    if (uid == null) {
      _errorMessage = 'User belum login.';
      // Gunakan microtask agar tidak crash saat dipanggil dari didChangeDependencies
      Future.microtask(notifyListeners);
      return;
    }

    // Batalkan langganan lama jika ada
    _catatanSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    // Gunakan microtask agar tidak crash saat dipanggil dari didChangeDependencies
    Future.microtask(notifyListeners);

    _catatanSubscription = _firestoreService.streamCatatanMenyusui(uid).listen(
      (daftar) {
        _daftarCatatan = daftar;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error streaming catatan menyusui: $e');
        if (e is FirebaseException &&
            (e.code == 'unavailable' ||
                e.message?.toLowerCase().contains('offline') == true)) {
          // Sedang offline, biarkan cache lokal tetap tampil tanpa error banner
          _errorMessage = null;
        } else if (e is FirebaseException) {
          _errorMessage =
              'Gagal sinkronisasi (${e.code}): ${e.message ?? 'Periksa aturan Firestore atau koneksi.'}';
        } else {
          _errorMessage = 'Gagal memperbarui catatan real-time.';
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ─── Muat daftar catatan (kompatibel & memicu stream) ───
  Future<void> muatCatatan() async {
    inisialisasiStream();
  }

  // ─── Tambah catatan baru ───
  Future<bool> tambahCatatan(CatatanMenyusui catatan) async {
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
      await _firestoreService.addCatatanMenyusui(uid, catatan);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' ||
          e.message?.toLowerCase().contains('offline') == true) {
        // Catatan tersimpan di cache Firestore dan akan disinkron saat online
        _isLoading = false;
        notifyListeners();
        return true;
      }
      debugPrint('Firebase error tambah catatan: ${e.code} - ${e.message}');
      _errorMessage =
          'Gagal menyimpan (${e.code}): ${e.message ?? 'Cek database'}';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error tambah catatan: $e');
      _errorMessage = 'Gagal menyimpan catatan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Update catatan yang sudah ada ───
  Future<bool> perbaruiCatatan(String docId, CatatanMenyusui catatan) async {
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
      await _firestoreService.updateCatatanMenyusui(uid, docId, catatan);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error update catatan: ${e.code} - ${e.message}');
      _errorMessage = 'Gagal memperbarui: ${e.message ?? e.code}';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error update catatan: $e');
      _errorMessage = 'Gagal memperbarui catatan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Hapus catatan ───
  Future<bool> hapusCatatan(String docId) async {
    final uid = _currentUid;
    if (uid == null) {
      _errorMessage = 'User belum login.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.deleteCatatanMenyusui(uid, docId);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error hapus catatan: ${e.code} - ${e.message}');
      _errorMessage = 'Gagal menghapus: ${e.message ?? e.code}';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error hapus catatan: $e');
      _errorMessage = 'Gagal menghapus catatan.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Bersihkan State (Logout) ───
  void bersihkan() {
    _catatanSubscription?.cancel();
    _catatanSubscription = null;
    _daftarCatatan = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Statistik Hari Ini & Analitik ───

  /// Catatan pada hari ini saja
  List<CatatanMenyusui> get catatanHariIni {
    final now = DateTime.now();
    return _daftarCatatan.where((c) {
      return c.waktu.year == now.year &&
          c.waktu.month == now.month &&
          c.waktu.day == now.day;
    }).toList();
  }

  /// (a) Jumlah sesi menyusui hari ini
  int get jumlahSesiHariIni => catatanHariIni.length;

  /// (b) Total durasi hari ini (dalam menit)
  int get totalDurasiHariIni =>
      catatanHariIni.fold(0, (total, c) => total + c.durasiMenit);

  /// (c) Rata-rata jarak antar sesi bila ada minimal 2 sesi hari ini
  Duration? get rataRataJarakSesiHariIni {
    if (catatanHariIni.length < 2) return null;

    // Urutkan dari yang paling awal hari ini hingga yang paling akhir
    final urut = List<CatatanMenyusui>.from(catatanHariIni)
      ..sort((a, b) => a.waktu.compareTo(b.waktu));

    int totalDiffSeconds = 0;
    for (int i = 0; i < urut.length - 1; i++) {
      totalDiffSeconds += urut[i + 1].waktu.difference(urut[i].waktu).inSeconds;
    }

    final avgSeconds = totalDiffSeconds ~/ (urut.length - 1);
    return Duration(seconds: avgSeconds);
  }

  /// (d) Riwayat per hari (7 hari terakhir, dari 6 hari lalu hingga hari ini)
  List<RiwayatHarian> get riwayatTujuhHari {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<RiwayatHarian> list = [];

    // Indeks 6 = 6 hari lalu, Indeks 0 = hari ini
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final sesiPadaTanggal = _daftarCatatan.where((c) {
        return c.waktu.year == date.year &&
            c.waktu.month == date.month &&
            c.waktu.day == date.day;
      }).toList();

      final totalDurasi =
          sesiPadaTanggal.fold(0, (total, c) => total + c.durasiMenit);

      list.add(RiwayatHarian(
        tanggal: date,
        jumlahSesi: sesiPadaTanggal.length,
        totalDurasiMenit: totalDurasi,
        daftarCatatan: sesiPadaTanggal,
        isHariIni: i == 0,
      ));
    }
    return list;
  }

  @override
  void dispose() {
    _catatanSubscription?.cancel();
    super.dispose();
  }
}
