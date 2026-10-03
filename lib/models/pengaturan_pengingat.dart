/// Model pengaturan pengingat menyusui.
/// Disimpan di Firestore: users/{uid}/pengaturan/pengingat
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class PengaturanPengingat {
  final bool aktif;
  final int intervalJam; // 1, 2, 3, atau 4
  final String waktuMulai; // Format "HH:mm" (misal "08:00")
  final String jenisSuara; // "notifikasi", "getar", "notifikasi_getar"

  PengaturanPengingat({
    this.aktif = false,
    this.intervalJam = 2,
    this.waktuMulai = '08:00',
    this.jenisSuara = 'notifikasi_getar',
  });

  /// Dari Firestore
  factory PengaturanPengingat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PengaturanPengingat(
      aktif: data['aktif'] as bool? ?? false,
      intervalJam: (data['intervalJam'] as num?)?.toInt() ?? 2,
      waktuMulai: data['waktuMulai'] as String? ?? '08:00',
      jenisSuara: data['jenisSuara'] as String? ?? 'notifikasi_getar',
    );
  }

  /// Ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'aktif': aktif,
      'intervalJam': intervalJam,
      'waktuMulai': waktuMulai,
      'jenisSuara': jenisSuara,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Buat salinan dengan perubahan
  PengaturanPengingat copyWith({
    bool? aktif,
    int? intervalJam,
    String? waktuMulai,
    String? jenisSuara,
  }) {
    return PengaturanPengingat(
      aktif: aktif ?? this.aktif,
      intervalJam: intervalJam ?? this.intervalJam,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      jenisSuara: jenisSuara ?? this.jenisSuara,
    );
  }
}
