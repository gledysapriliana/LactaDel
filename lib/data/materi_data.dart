/// Data 6 materi edukasi LactaDel — konten lengkap.
/// Disimpan lokal, tidak di Firestore.
library;

import '../models/materi.dart';

class MateriData {
  MateriData._();

  static const List<Materi> semuaMateri = [
    // ══════════════════════════════════════════
    // 1. Peran Ayah dalam ASI Eksklusif
    // ══════════════════════════════════════════
    Materi(
      id: 1,
      judul: 'Peran Ayah dalam ASI Eksklusif',
      deskripsiSingkat:
          'Keterlibatan ayah sangat penting dalam membantu ibu memberikan ASI eksklusif.',
      ikon: 'family_restroom',
      kutipan:
          'Dukungan Ayah hadir ini, maka Ibu pun yang lebih baik untuk Ibu dan Si Kecil.',
      penjelasan:
          'Keterlibatan ayah sangat penting dalam membantu ibu memberikan ASI eksklusif. '
          'Ayah dapat menjadi pendukung, pendengar, dan partner dalam setiap tahap perjalanan menyusui.',
      poinBelajar: [
        'Mengapa peran ayah penting',
        'Apa yang dapat dilakukan ayah',
        'Dampak dukungan ayah bagi ibu dan bayi',
      ],
      poinTindakan: [
        'Mendampingi ibu selama proses menyusui',
        'Memberikan dukungan emosional dan fisik',
        'Mencari informasi tentang ASI eksklusif',
        'Membantu pekerjaan rumah tangga',
        'Memberikan apresiasi kepada ibu',
      ],
      referensi: [
        Referensi(
          judul:
              'World Health Organization. (2023). Breastfeeding.',
          url: 'https://www.who.int/health-topics/breastfeeding',
        ),
        Referensi(
          judul:
              'Kemenkes RI. (2022). Pedoman Pemberian ASI Eksklusif.',
          url: 'https://www.kemkes.go.id',
        ),
        Referensi(
          judul:
              'Rempel, L. A., & Rempel, J. K. (2011). The breastfeeding team: The role of involved fathers in the breastfeeding family. Journal of Human Lactation, 27(2), 115-121.',
          url: 'https://doi.org/10.1177/0890334410390045',
        ),
      ],
    ),

    // ══════════════════════════════════════════
    // 2. Dukungan Emosional
    // ══════════════════════════════════════════
    Materi(
      id: 2,
      judul: 'Dukungan Emosional',
      deskripsiSingkat:
          'Memberikan perhatian, semangat, dan kasih sayang.',
      ikon: 'favorite',
      kutipan: 'Hadiri dengan perhatian, semangat, dan kasih sayang.',
      penjelasan:
          'Dukungan emosional adalah bentuk dukungan yang diberikan Ayah kepada ibu '
          'menyusui berupa perhatian dan empati terhadap perasaan ibu. '
          'Dukungan emosional terhadap ibu menyusui sangat penting untuk '
          'menjaga kesehatan mental ibu dan keberhasilan pemberian ASI eksklusif.',
      poinTindakan: [
        'Mendengarkan keluhan ibu',
        'Memberikan semangat',
        'Menunjukkan empati dan perhatian',
        'Mendampingi ibu saat merasa lelah atau khawatir',
      ],
      referensi: [
        Referensi(
          judul:
              'Puspitasari, D., Mawarni, A., & Arifin, S. (2020). Hubungan dukungan suami dengan keberhasilan ASI eksklusif. Jurnal Keperawatan, 8(2), 45-52.',
          url: '',
        ),
        Referensi(
          judul:
              'Edmond, P., Dark, L., & Falcato, R. (2022). The Relationship of Paternal Support and Exclusive Breastfeeding. International Breastfeeding Journal, 17(1), 1-10.',
          url: '',
        ),
        Referensi(
          judul:
              'Reza, A., Yanti, S., & Sekarsari, L. (2021). The Relationship Between Husband Support and Exclusive Breastfeeding in Developing Countries: A Systematic Review. Journal of Public Health, 5(3), 234-241.',
          url: '',
        ),
      ],
      videoUrl: 'https://drive.google.com/file/d/1viu7b4DhkoyZGd1WmBASiAW-fwLD3ejT/view?usp=sharing',
    ),

    // ══════════════════════════════════════════
    // 3. Dukungan Informasional
    // ══════════════════════════════════════════
    Materi(
      id: 3,
      judul: 'Dukungan Informasional',
      deskripsiSingkat:
          'Mencari dan memahami informasi yang benar tentang ASI eksklusif.',
      ikon: 'menu_book',
      kutipan:
          'Berbagi informasi yang tepat, agar ibu lebih yakin dan percaya diri.',
      penjelasan:
          'Dukungan informasional adalah bentuk dukungan dimana ayah membantu '
          'menyediakan dan memberikan informasi yang dibutuhkan ibu. '
          'Ayah membantu mencari dan menyaring informasi dari sumber terpercaya '
          'agar ibu mendapatkan pengetahuan yang benar tentang ASI eksklusif.',
      poinTindakan: [
        'Mencari informasi dari sumber terpercaya',
        'Belajar bersama ibu',
        'Membantu ibu memahami informasi yang benar tentang menyusui',
        'Menghindari informasi yang tidak tepat/menyesatkan',
      ],
      referensi: [
        Referensi(
          judul:
              'Nasijrah, S., & Rahmawati, U. (2023). Hubungan dukungan informasional suami terhadap keberhasilan ASI eksklusif. Jurnal Kesehatan Masyarakat, 11(2), 89-95.',
          url: '',
        ),
        Referensi(
          judul:
              'Ramliyah, B., & Septiwardi, C. (2021). Peran suami dalam mendukung pemberian ASI eksklusif berdasarkan perspektif informasional. Jurnal Kebidanan, 7(1), 34-42.',
          url: '',
        ),
        Referensi(
          judul:
              'World Health Organization. (2023). Infant and young child feeding: A guide for health workers.',
          url: 'https://www.who.int/publications',
        ),
      ],
      videoUrl: 'https://drive.google.com/file/d/1of93N6r2K1BfNWwS-n7JMJlSUyg5TqDE/view?usp=sharing',
    ),

    // ══════════════════════════════════════════
    // 4. Dukungan Instrumental
    // ══════════════════════════════════════════
    Materi(
      id: 4,
      judul: 'Dukungan Instrumental',
      deskripsiSingkat:
          'Membantu meringankan beban ibu sehingga ibu bisa fokus menyusui.',
      ikon: 'handshake',
      kutipan:
          'Bantu pekerjaan rumah? Itu bisa! Ayah bisa bantu agar ibu fokus menyusui.',
      penjelasan:
          'Dukungan instrumental meliputi bantuan nyata yang diberikan ayah '
          'untuk meringankan beban ibu sehari-hari. Dengan membantu pekerjaan rumah, '
          'menyiapkan makanan, dan mengurus bayi, ayah memberikan kesempatan '
          'ibu untuk beristirahat dan fokus menyusui.',
      poinTindakan: [
        'Membantu pekerjaan rumah tangga',
        'Belanja kebutuhan ibu',
        'Menyiapkan makanan dan minuman',
        'Memberikan kesempatan ibu untuk beristirahat',
        'Mengganti popok bayi',
      ],
      referensi: [
        Referensi(
          judul:
              'Surani, L., & Prahara, S. (2022). Dukungan instrumental suami dan keberhasilan ASI eksklusif. Jurnal Ilmu Keperawatan, 6(2), 78-85.',
          url: '',
        ),
        Referensi(
          judul:
              'Kementerian Kesehatan RI. (2022). Panduan pemberian ASI eksklusif bagi petugas kesehatan.',
          url: 'https://www.kemkes.go.id',
        ),
      ],
      videoUrl: 'https://drive.google.com/file/d/1DaaAs5bShWpZ2vuJGxNjtsxxxA-NW_W4/view?usp=sharing',
    ),

    // ══════════════════════════════════════════
    // 5. Dukungan Penghargaan
    // ══════════════════════════════════════════
    Materi(
      id: 5,
      judul: 'Dukungan Penghargaan',
      deskripsiSingkat:
          'Apresiasi dan motivasi dari ayah dapat meningkatkan kepercayaan diri ibu.',
      ikon: 'emoji_events',
      kutipan:
          'Berikan apresiasi, karena usaha ibu sangat berarti!',
      penjelasan:
          'Dukungan penghargaan adalah bentuk dukungan dimana ayah memberikan '
          'apresiasi, pujian, dan motivasi kepada ibu atas usahanya dalam memberikan '
          'ASI eksklusif. Penghargaan ini dapat meningkatkan kepercayaan diri '
          'dan semangat ibu untuk terus menyusui.',
      poinTindakan: [
        'Memberikan pujian dan apresiasi',
        'Mengucapkan terima kasih',
        'Memberikan motivasi',
        'Menghargai setiap usaha ibu',
        'Membantu ibu merasa percaya diri',
      ],
      referensi: [
        Referensi(
          judul:
              'Bahriyan, A., & Furi, N. (2023). Hubungan dukungan penghargaan suami dan exclusive breastfeeding. Jurnal Kesehatan, 9(1), 56-63.',
          url: '',
        ),
        Referensi(
          judul:
              'Rahayu, S., & Sat, T. (2021). Pengaruh dukungan suami terhadap motivasi ibu dalam pemberian ASI eksklusif. Jurnal Kebidanan Indonesia, 12(2), 112-120.',
          url: '',
        ),
        Referensi(
          judul:
              'BPS & Kemenkes RI. (2023). Survei Demografi dan Kesehatan Indonesia.',
          url: 'https://www.bps.go.id',
        ),
      ],
      videoUrl: 'https://drive.google.com/file/d/1O-nIgwW-Xu_wP1bYkjQ6hVuUSayjJW0z/view?usp=sharing',
    ),

    // ══════════════════════════════════════════
    // 6. Tantangan Ayah dan Cara Mendukung Ibu
    // ══════════════════════════════════════════
    Materi(
      id: 6,
      judul: 'Tantangan Ayah dan Cara Mendukung Ibu',
      deskripsiSingkat:
          'Berbagai tantangan yang mungkin dihadapi ayah dan solusi praktisnya.',
      ikon: 'psychology',
      kutipan:
          'Setiap dukungan kecil yang Anda berikan, berarti besar bagi ibu dan buah hati.',
      penjelasan:
          'Ayah mungkin menghadapi berbagai tantangan dalam mendukung ibu. '
          'Materi ini membahas situasi tersebut dan memberikan contoh tindakan '
          'yang dapat dilakukan.',
      poinTindakan: [
        'Ibu merasa lelah dan stres — dampingi dan bantu pekerjaan rumah',
        'Ibu merasa ASI tidak cukup — berikan semangat dan informasi yang benar',
        'Ibu merasa kurang percaya diri — berikan pujian dan apresiasi',
        'Ayah bingung harus membantu seperti apa — tanyakan apa yang dibutuhkan ibu',
      ],
      referensi: [
        Referensi(
          judul:
              'Rempel, L. A., & Rempel, J. K. (2011). The breastfeeding team: The role of involved fathers. Journal of Human Lactation, 27(2), 115-121.',
          url: 'https://doi.org/10.1177/0890334410390045',
        ),
        Referensi(
          judul:
              'World Health Organization. (2023). Breastfeeding recommendations.',
          url: 'https://www.who.int/health-topics/breastfeeding',
        ),
      ],
    ),
  ];

  /// Cari materi berdasarkan ID
  static Materi? getById(int id) {
    try {
      return semuaMateri.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
