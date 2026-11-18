/// Model data pengguna (Ayah).
/// Sesuai skema Firestore: users/{uid}
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String nama;
  final String email;
  final DateTime createdAt;
  final String? fotoProfil;

  AppUser({
    required this.uid,
    required this.nama,
    required this.email,
    required this.createdAt,
    this.fotoProfil,
  });

  /// Buat AppUser dari dokumen Firestore
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawCreatedAt = data['createdAt'];
    DateTime parsedCreatedAt = DateTime.now();

    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    }

    return AppUser(
      uid: doc.id,
      nama: data['nama'] as String? ?? '',
      email: data['email'] as String? ?? '',
      createdAt: parsedCreatedAt,
      fotoProfil: data['fotoProfil'] as String?,
    );
  }

  /// Konversi ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'fotoProfil': fotoProfil,
    };
  }

  /// Buat salinan dengan perubahan tertentu
  AppUser copyWith({
    String? uid,
    String? nama,
    String? email,
    DateTime? createdAt,
    String? fotoProfil,
    bool clearFotoProfil = false,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      fotoProfil: clearFotoProfil ? null : (fotoProfil ?? this.fotoProfil),
    );
  }
}
