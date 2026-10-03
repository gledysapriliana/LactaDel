/// Service notifikasi lokal untuk pengingat menyusui.
/// Menggunakan flutter_local_notifications + timezone.
/// Mendukung: notifikasi, getar, atau keduanya.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// ID channel notifikasi
  static const String _channelId = 'lactadel_pengingat';
  static const String _channelName = 'Pengingat Menyusui';
  static const String _channelDesc = 'Notifikasi pengingat jadwal menyusui';

  /// Teks notifikasi
  static const String _notifTitle = 'Pengingat Menyusui 🍼';
  static const String _notifBody =
      'Waktunya menyusui. Ayah, bantu Ibu bersiap dan istirahat ya.';

  // ─── Inisialisasi ───
  Future<void> initialize() async {
    // Setup timezone
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback ke UTC jika gagal
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    // Setup Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Setup iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
  }

  // ─── Minta izin notifikasi (Android 13+) ───
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true; // iOS sudah minta saat init
  }

  // ─── Jadwalkan notifikasi berulang ───
  /// [intervalJam] - interval antar notifikasi (1, 2, 3, atau 4 jam)
  /// [waktuMulai] - waktu mulai format "HH:mm" (misal "08:00")
  /// [jenisSuara] - "notifikasi", "getar", atau "notifikasi_getar"
  Future<void> jadwalkanPengingat({
    required int intervalJam,
    required String waktuMulai,
    required String jenisSuara,
  }) async {
    // Batalkan semua jadwal lama dulu
    await batalkanSemua();

    // Parse waktu mulai
    final parts = waktuMulai.split(':');
    final jamMulai = int.tryParse(parts[0]) ?? 8;
    final menitMulai = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    // Tentukan detail notifikasi berdasarkan jenis suara
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      // Suara & getar berdasarkan pilihan
      playSound: jenisSuara != 'getar',
      enableVibration: jenisSuara != 'notifikasi',
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: jenisSuara != 'getar',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Hitung jadwal-jadwal dalam sehari (dari waktuMulai, interval jam)
    // Contoh: mulai 08:00, interval 2 jam → 08:00, 10:00, 12:00, ..., 22:00
    final now = tz.TZDateTime.now(tz.local);
    int notifId = 0;

    for (int jam = jamMulai; jam < 24; jam += intervalJam) {
      final scheduledTime = _nextScheduleTime(now, jam, menitMulai);

      try {
        await _plugin.zonedSchedule(
          notifId,
          _notifTitle,
          _notifBody,
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time, // Ulangi tiap hari
        );
      } catch (e) {
        debugPrint('Gagal jadwalkan notifikasi id=$notifId: $e');
      }

      notifId++;
    }

    debugPrint(
      'Dijadwalkan $notifId notifikasi: mulai $jamMulai:${menitMulai.toString().padLeft(2, '0')}, '
      'interval ${intervalJam}jam, suara: $jenisSuara',
    );
  }

  /// Hitung waktu jadwal berikutnya untuk jam:menit tertentu
  tz.TZDateTime _nextScheduleTime(tz.TZDateTime now, int jam, int menit) {
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, jam, menit);

    // Jika waktu sudah lewat hari ini, jadwalkan besok
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ─── Batalkan semua notifikasi ───
  Future<void> batalkanSemua() async {
    await _plugin.cancelAll();
    debugPrint('Semua notifikasi dibatalkan.');
  }

  // ─── Tampilkan notifikasi tes (untuk debugging) ───
  Future<void> tampilkanNotifikasiTes() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      999,
      _notifTitle,
      _notifBody,
      details,
    );
  }
}
