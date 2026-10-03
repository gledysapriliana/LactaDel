/// Model materi edukasi LactaDel.
/// Data disimpan lokal di data/materi_data.dart (bukan Firestore).
library;

/// Satu referensi (sumber) dalam materi
class Referensi {
  final String judul;
  final String url;

  const Referensi({
    required this.judul,
    this.url = '',
  });
}

/// Satu materi edukasi
class Materi {
  final int id;
  final String judul;
  final String deskripsiSingkat; // Tampil di daftar menu edukasi
  final String ikon; // Nama ikon Material
  final String kutipan; // Kutipan motivasi di atas konten
  final String penjelasan; // Paragraf penjelasan utama
  final List<String> poinTindakan; // "Apa yang dapat dilakukan Ayah?"
  final List<String>? poinBelajar; // "Pada materi ini Anda akan mempelajari" (khusus Peran Ayah)
  final List<Referensi> referensi;
  final String? videoUrl; // Hanya untuk Dukungan Emosional

  const Materi({
    required this.id,
    required this.judul,
    required this.deskripsiSingkat,
    required this.ikon,
    this.kutipan = '',
    required this.penjelasan,
    this.poinTindakan = const [],
    this.poinBelajar,
    this.referensi = const [],
    this.videoUrl,
  });
}
