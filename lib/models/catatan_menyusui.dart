/// Model catatan menyusui.
/// Disimpan di Firestore: users/{uid}/catatan_menyusui/{docId}
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class CatatanMenyusui {
  final String? id; // Firestore document ID
  final DateTime waktu;
  final String sisi; // "Kiri" atau "Kanan"
  final int durasiMenit;
  final String catatan;

  CatatanMenyusui({
    this.id,
    required this.waktu,
    required this.sisi,
    this.durasiMenit = 0,
    this.catatan = '',
  });

  /// Dari Firestore
  factory CatatanMenyusui.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawWaktu = data['waktu'];
    DateTime parsedWaktu = DateTime.now();

    if (rawWaktu is Timestamp) {
      parsedWaktu = rawWaktu.toDate();
    } else if (rawWaktu is String) {
      parsedWaktu = DateTime.tryParse(rawWaktu) ?? DateTime.now();
    }

    return CatatanMenyusui(
      id: doc.id,
      waktu: parsedWaktu,
      sisi: data['sisi'] as String? ?? 'Kiri',
      durasiMenit: (data['durasiMenit'] as num?)?.toInt() ?? 0,
      catatan: data['catatan'] as String? ?? '',
    );
  }

  /// Ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'waktu': Timestamp.fromDate(waktu),
      'sisi': sisi,
      'durasiMenit': durasiMenit,
      'catatan': catatan,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Salin objek dengan perubahan
  CatatanMenyusui copyWith({
    String? id,
    DateTime? waktu,
    String? sisi,
    int? durasiMenit,
    String? catatan,
  }) {
    return CatatanMenyusui(
      id: id ?? this.id,
      waktu: waktu ?? this.waktu,
      sisi: sisi ?? this.sisi,
      durasiMenit: durasiMenit ?? this.durasiMenit,
      catatan: catatan ?? this.catatan,
    );
  }
}
