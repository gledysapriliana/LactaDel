/// Service Firestore terpusat untuk CRUD data aplikasi LactaDel:
/// 1. Data Pengguna (users/{uid})
/// 2. Catatan Menyusui (users/{uid}/catatan_menyusui/{docId})
/// 3. Pengaturan Pengingat (users/{uid}/pengaturan/pengingat)
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../models/app_user.dart';
import '../models/catatan_menyusui.dart';
import '../models/pengaturan_pengingat.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════
  // ─── 1. USER MANAGEMENT (users/{uid}) ──────────
  // ═══════════════════════════════════════════════

  /// Simpan / inisialisasi data user baru ke Firestore dengan merge
  Future<void> createUser(AppUser user) async {
    try {
      await _db
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 4));
    } on TimeoutException {
      // Timeout jaringan biasa di browser/emulator; Firestore tetap menyimpan di local cache.
      debugPrint('createUser: tersimpan di cache lokal (timeout sinkronisasi).');
    } catch (e) {
      debugPrint('createUser info/offline: $e');
    }
  }

  /// Ambil data user dari Firestore dengan proteksi offline/cache fallback
  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _db
          .collection(AppConstants.colUsers)
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 4));

      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } on FirebaseException catch (e) {
      debugPrint('getUser FirebaseException (${e.code}): ${e.message}');
      // Jika offline atau unavailable, coba baca dari local cache
      try {
        final cacheDoc = await _db
            .collection(AppConstants.colUsers)
            .doc(uid)
            .get(const GetOptions(source: Source.cache));
        if (cacheDoc.exists) {
          return AppUser.fromFirestore(cacheDoc);
        }
      } catch (_) {}
      return null;
    } on TimeoutException {
      debugPrint('getUser timeout: mencoba membaca dari cache');
      try {
        final cacheDoc = await _db
            .collection(AppConstants.colUsers)
            .doc(uid)
            .get(const GetOptions(source: Source.cache));
        if (cacheDoc.exists) {
          return AppUser.fromFirestore(cacheDoc);
        }
      } catch (_) {}
      return null;
    } catch (e) {
      debugPrint('getUser error: $e');
      return null;
    }
  }

  /// Cek apakah dokumen user sudah ada dengan proteksi offline
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _db
          .collection(AppConstants.colUsers)
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 3));
      return doc.exists;
    } on FirebaseException catch (e) {
      debugPrint('userExists FirebaseException (${e.code})');
      try {
        final cacheDoc = await _db
            .collection(AppConstants.colUsers)
            .doc(uid)
            .get(const GetOptions(source: Source.cache));
        return cacheDoc.exists;
      } catch (_) {}
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Update data user (misal: nama atau profil)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    final updateData = Map<String, dynamic>.from(data);
    updateData['updatedAt'] = FieldValue.serverTimestamp();
    await _db
        .collection(AppConstants.colUsers)
        .doc(uid)
        .update(updateData)
        .timeout(const Duration(seconds: 4));
  }

  // ═══════════════════════════════════════════════════════════
  // ─── 2. CATATAN MENYUSUI (users/{uid}/catatan_menyusui) ───
  // ═══════════════════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> _catatanCollection(String uid) {
    return _db
        .collection(AppConstants.colUsers)
        .doc(uid)
        .collection(AppConstants.colCatatanMenyusui);
  }

  /// Stream real-time daftar catatan menyusui, diurutkan waktu terbaru
  Stream<List<CatatanMenyusui>> streamCatatanMenyusui(String uid,
      {int limit = 100}) {
    return _catatanCollection(uid)
        .orderBy('waktu', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CatatanMenyusui.fromFirestore(doc))
          .toList();
    });
  }

  /// Ambil daftar catatan sekali panggil (one-time fetch) dengan cache fallback
  Future<List<CatatanMenyusui>> getCatatanMenyusui(String uid,
      {int limit = 100}) async {
    try {
      final snapshot = await _catatanCollection(uid)
          .orderBy('waktu', descending: true)
          .limit(limit)
          .get()
          .timeout(const Duration(seconds: 4));
      return snapshot.docs
          .map((doc) => CatatanMenyusui.fromFirestore(doc))
          .toList();
    } catch (_) {
      try {
        final cacheSnapshot = await _catatanCollection(uid)
            .orderBy('waktu', descending: true)
            .limit(limit)
            .get(const GetOptions(source: Source.cache));
        return cacheSnapshot.docs
            .map((doc) => CatatanMenyusui.fromFirestore(doc))
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  /// Tambah catatan baru, mengembalikan document ID yang digenerate Firestore
  Future<String> addCatatanMenyusui(
      String uid, CatatanMenyusui catatan) async {
    final docRef = await _catatanCollection(uid)
        .add(catatan.toFirestore())
        .timeout(const Duration(seconds: 4));
    return docRef.id;
  }

  /// Perbarui catatan menyusui yang sudah ada
  Future<void> updateCatatanMenyusui(
      String uid, String docId, CatatanMenyusui catatan) async {
    await _catatanCollection(uid)
        .doc(docId)
        .update(catatan.toFirestore())
        .timeout(const Duration(seconds: 4));
  }

  /// Hapus catatan menyusui berdasarkan ID dokumen
  Future<void> deleteCatatanMenyusui(String uid, String docId) async {
    await _catatanCollection(uid)
        .doc(docId)
        .delete()
        .timeout(const Duration(seconds: 4));
  }

  // ═══════════════════════════════════════════════════════════════
  // ─── 3. PENGATURAN PENGINGAT (users/{uid}/pengaturan/pengingat)
  // ═══════════════════════════════════════════════════════════════

  DocumentReference<Map<String, dynamic>> _pengingatDoc(String uid) {
    return _db
        .collection(AppConstants.colUsers)
        .doc(uid)
        .collection(AppConstants.colPengaturan)
        .doc(AppConstants.docPengingat);
  }

  /// Ambil pengaturan pengingat user dengan proteksi offline
  Future<PengaturanPengingat> getPengaturanPengingat(String uid) async {
    try {
      final doc = await _pengingatDoc(uid)
          .get()
          .timeout(const Duration(seconds: 4));
      if (doc.exists) {
        return PengaturanPengingat.fromFirestore(doc);
      }
    } on FirebaseException catch (e) {
      debugPrint('getPengaturanPengingat info (${e.code})');
      try {
        final cacheDoc = await _pengingatDoc(uid)
            .get(const GetOptions(source: Source.cache));
        if (cacheDoc.exists) {
          return PengaturanPengingat.fromFirestore(cacheDoc);
        }
      } catch (_) {}
    } catch (_) {
      try {
        final cacheDoc = await _pengingatDoc(uid)
            .get(const GetOptions(source: Source.cache));
        if (cacheDoc.exists) {
          return PengaturanPengingat.fromFirestore(cacheDoc);
        }
      } catch (_) {}
    }
    return PengaturanPengingat();
  }

  /// Simpan atau perbarui pengaturan pengingat dengan merge
  Future<void> savePengaturanPengingat(
      String uid, PengaturanPengingat pengaturan) async {
    try {
      await _pengingatDoc(uid).set(
        pengaturan.toFirestore(),
        SetOptions(merge: true),
      ).timeout(const Duration(seconds: 4));
    } on TimeoutException {
      debugPrint('savePengaturanPengingat: disimpan ke antrian lokal.');
    }
  }
}
