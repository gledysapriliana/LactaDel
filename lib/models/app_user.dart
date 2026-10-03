/// Model data pengguna (Ayah).
/// Sesuai skema Firestore: users/{uid}
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String nama;
  final String email;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.nama,
    required this.email,
    required this.createdAt,
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
    );
  }

  /// Konversi ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Buat salinan dengan perubahan tertentu
  AppUser copyWith({
    String? uid,
    String? nama,
    String? email,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
