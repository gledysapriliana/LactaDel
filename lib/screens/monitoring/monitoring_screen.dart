/// Layar Monitoring Menyusui.
/// Menampilkan statistik real-time dari Firestore:
/// (a) Jumlah sesi menyusui hari ini
/// (b) Total durasi hari ini
/// (c) Rata-rata jarak antar sesi hari ini
/// (d) Riwayat per hari (7 hari terakhir) dalam grafik batang sederhana & daftar harian
/// (e) Keadaan kosong yang ramah bila belum ada catatan.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/catatan_menyusui.dart';
import '../../providers/catatan_provider.dart';
import '../home/home_screen.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  bool _initialized = false;
  int? _selectedBarIndex; // null = tampilkan semua / hari ini

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Inisialisasi stream real-time Firestore
      final provider = context.read<CatatanProvider>();
      provider.inisialisasiStream();
    }
  }

  // ─── Format Bantuan Bahasa Indonesia ───
  static const List<String> _namaHariSingkat = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min'
  ];

  static const List<String> _namaHariLengkap = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  static const List<String> _namaBulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];

  String _formatHariSingkat(DateTime dt) {
    return _namaHariSingkat[dt.weekday - 1];
  }

  String _formatHariLengkap(DateTime dt) {
    return _namaHariLengkap[dt.weekday - 1];
  }

  String _formatTanggal(DateTime dt) {
    return '${dt.day} ${_namaBulan[dt.month - 1]} ${dt.year}';
  }

  String _formatJam(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  String _formatDurasi(int totalMenit) {
    if (totalMenit <= 0) return '0 mnt';
    if (totalMenit < 60) return '$totalMenit mnt';
    final jam = totalMenit ~/ 60;
    final sisa = totalMenit % 60;
    if (sisa == 0) return '$jam jam';
    return '$jam jam $sisa mnt';
  }

  String _formatJarak(Duration? duration) {
    if (duration == null) return '—';
    final totalMenit = duration.inMinutes;
    if (totalMenit < 60) return '$totalMenit mnt';
    final jam = totalMenit ~/ 60;
    final sisa = totalMenit % 60;
    if (sisa == 0) return '$jam jam';
    return '$jam j $sisa m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catatanProv = context.watch<CatatanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Menyusui'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan data',
            onPressed: () => catatanProv.inisialisasiStream(),
          ),
        ],
      ),
      body: SafeArea(
        child: catatanProv.isLoading && catatanProv.daftarCatatan.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async => catatanProv.inisialisasiStream(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Header Info & Status Real-Time ───
                      _buildHeaderCard(context, isDark),
                      const SizedBox(height: 20),

                      // ─── Tiga Kartu Metrik Hari Ini ───
                      _buildTodayMetrics(context, catatanProv, isDark),
                      const SizedBox(height: 24),

                      // ─── Cek Kondisi Kosong ───
                      if (catatanProv.daftarCatatan.isEmpty)
                        _buildEmptyState(context, isDark)
                      else ...[
                        // ─── Grafik Batang 7 Hari Terakhir ───
                        _buildChartSection(context, catatanProv, isDark),
                        const SizedBox(height: 24),

                        // ─── Riwayat 7 Hari Terakhir ───
                        _buildHistorySection(context, catatanProv, isDark),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ─── Widget: Header Card ───
  Widget _buildHeaderCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkTextSecondary.withAlpha(30)
              : AppColors.secondary.withAlpha(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkPrimary.withAlpha(35)
                  : AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.insights_rounded,
              color: theme.colorScheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pantau Pola Menyusui',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Data terhubung real-time dari riwayat Ayah & Ibu',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widget: 3 Kartu Metrik Hari Ini ───
  Widget _buildTodayMetrics(
    BuildContext context,
    CatatanProvider provider,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final jumlahSesi = provider.jumlahSesiHariIni;
    final totalDurasi = provider.totalDurasiHariIni;
    final jarakSesi = provider.rataRataJarakSesiHariIni;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Statistik Hari Ini',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              _formatTanggal(DateTime.now()),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // (a) Jumlah Sesi
            Expanded(
              child: _buildMetricTile(
                context: context,
                isDark: isDark,
                icon: Icons.repeat_rounded,
                iconColor: AppColors.primary,
                title: 'Jumlah Sesi',
                value: '$jumlahSesi',
                unit: 'kali',
                sublabel: jumlahSesi == 0 ? 'Belum ada sesi' : 'Target: 8-12x',
              ),
            ),
            const SizedBox(width: 10),
            // (b) Total Durasi
            Expanded(
              child: _buildMetricTile(
                context: context,
                isDark: isDark,
                icon: Icons.timer_outlined,
                iconColor: Colors.amber.shade700,
                title: 'Total Durasi',
                value: totalDurasi > 0 ? '$totalDurasi' : '0',
                unit: 'menit',
                sublabel: _formatDurasi(totalDurasi),
              ),
            ),
            const SizedBox(width: 10),
            // (c) Rata-rata Jarak Antar Sesi
            Expanded(
              child: _buildMetricTile(
                context: context,
                isDark: isDark,
                icon: Icons.hourglass_bottom_rounded,
                iconColor: Colors.teal,
                title: 'Jarak Sesi',
                value: _formatJarak(jarakSesi),
                unit: jarakSesi == null ? '' : 'rata-rata',
                sublabel: jarakSesi == null
                    ? (jumlahSesi == 1 ? 'Butuh ≥2 sesi' : 'Belum ada')
                    : 'Jeda per sesi',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
    required String sublabel,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkTextSecondary.withAlpha(25)
              : AppColors.secondary.withAlpha(45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            sublabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextSecondary.withAlpha(180)
                  : AppColors.lightTextSecondary.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widget: Empty State Ramah ───
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkTextSecondary.withAlpha(30)
              : AppColors.secondary.withAlpha(60),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkPrimary.withAlpha(30)
                  : AppColors.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.baby_changing_station_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Belum Ada Catatan Menyusui',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ayah, yuk mulai catat waktu dan durasi menyusui di menu Pengingat. Grafik dan ringkasan 7 hari terakhir akan otomatis tampil di sini!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Beralih ke Tab Pengingat (Tab index 2)
              HomeScreen.switchTab(context, 2);
            },
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Tambah Catatan Sekarang'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widget: Grafik Batang 7 Hari Terakhir ───
  Widget _buildChartSection(
    BuildContext context,
    CatatanProvider provider,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final riwayatList = provider.riwayatTujuhHari; // 7 hari terakhir

    // Cari nilai maksimum sesi untuk scaling tinggi batang
    int maxSesi = 0;
    for (final r in riwayatList) {
      if (r.jumlahSesi > maxSesi) maxSesi = r.jumlahSesi;
    }
    // Baseline minimum skala agar tidak terlalu mepet
    final int chartCeiling = max(maxSesi + 1, 6);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkTextSecondary.withAlpha(25)
              : AppColors.secondary.withAlpha(45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 22,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Aktivitas 7 Hari Terakhir',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Sesi / Hari',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ketuk salah satu batang untuk melihat detail hari tersebut',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 24),

          // ─── 7 Kolom Batang ───
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(riwayatList.length, (index) {
                final r = riwayatList[index];
                final isSelected = _selectedBarIndex == index;
                final bool isToday = r.isHariIni;

                // Proporsi tinggi batang
                final double ratio =
                    r.jumlahSesi > 0 ? (r.jumlahSesi / chartCeiling) : 0.04;
                final double barHeight = max(ratio * 110, 8.0);

                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        if (_selectedBarIndex == index) {
                          _selectedBarIndex = null; // deselect
                        } else {
                          _selectedBarIndex = index;
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Label Jumlah Sesi di atas batang
                          Text(
                            r.jumlahSesi > 0 ? '${r.jumlahSesi}x' : '-',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isToday
                                      ? (isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.lightPrimary)
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary)),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Batang visual
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            height: barHeight,
                            width: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: isSelected
                                  ? LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        theme.colorScheme.primary,
                                        AppColors.secondary,
                                      ],
                                    )
                                  : (isToday
                                      ? LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            theme.colorScheme.primary
                                                .withAlpha(220),
                                            AppColors.secondary.withAlpha(180),
                                          ],
                                        )
                                      : null),
                              color: (!isSelected && !isToday)
                                  ? (r.jumlahSesi > 0
                                      ? (isDark
                                          ? AppColors.darkPrimary.withAlpha(90)
                                          : AppColors.primary.withAlpha(90))
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.secondary)
                                          .withAlpha(40))
                                  : null,
                              border: isSelected
                                  ? Border.all(
                                      color: theme.colorScheme.primary,
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Label Nama Hari
                          Text(
                            isToday ? 'Hari ini' : _formatHariSingkat(r.tanggal),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isToday || isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isToday
                                  ? theme.colorScheme.primary
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary),
                            ),
                          ),

                          // Tanggal
                          Text(
                            '${r.tanggal.day}',
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ─── Banner Detail Hari yang Dipilih ───
          if (_selectedBarIndex != null) ...[
            const SizedBox(height: 16),
            _buildSelectedDayDetail(
              context,
              riwayatList[_selectedBarIndex!],
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetail(
    BuildContext context,
    RiwayatHarian riwayat,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withAlpha(150)
            : AppColors.backgroundLight.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(60),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_formatHariLengkap(riwayat.tanggal)}, ${_formatTanggal(riwayat.tanggal)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${riwayat.jumlahSesi} Sesi • ${_formatDurasi(riwayat.totalDurasiMenit)}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widget: Daftar Riwayat 7 Hari Terakhir ───
  Widget _buildHistorySection(
    BuildContext context,
    CatatanProvider provider,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    // Tampilkan 7 hari terakhir dari hari ini mundur ke belakang
    final riwayatList = provider.riwayatTujuhHari.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Riwayat Sesi Harian',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '7 Hari Terakhir',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: riwayatList.length,
          separatorBuilder: (_, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final r = riwayatList[index];
            return _buildDayCard(context, r, isDark);
          },
        ),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, RiwayatHarian r, bool isDark) {
    final theme = Theme.of(context);
    final hasData = r.daftarCatatan.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: r.isHariIni
              ? theme.colorScheme.primary.withAlpha(isDark ? 90 : 120)
              : (isDark
                  ? AppColors.darkTextSecondary.withAlpha(25)
                  : AppColors.secondary.withAlpha(45)),
          width: r.isHariIni ? 1.5 : 1.0,
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: r.isHariIni && hasData,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: r.isHariIni
                  ? theme.colorScheme.primary.withAlpha(isDark ? 40 : 25)
                  : (isDark
                      ? AppColors.darkBackground
                      : AppColors.backgroundLight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatHariSingkat(r.tanggal),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: r.isHariIni
                        ? theme.colorScheme.primary
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                ),
                Text(
                  '${r.tanggal.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          title: Row(
            children: [
              Text(
                r.isHariIni
                    ? 'Hari Ini'
                    : '${_formatHariLengkap(r.tanggal)}, ${_formatTanggal(r.tanggal)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: r.isHariIni ? theme.colorScheme.primary : null,
                ),
              ),
              if (r.isHariIni) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Hari Ini',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              hasData
                  ? '${r.jumlahSesi} sesi  •  Total durasi ${_formatDurasi(r.totalDurasiMenit)}'
                  : 'Tidak ada sesi menyusui',
              style: TextStyle(
                fontSize: 12,
                color: hasData
                    ? (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)
                    : (isDark
                        ? AppColors.darkTextSecondary.withAlpha(120)
                        : AppColors.lightTextSecondary.withAlpha(150)),
              ),
            ),
          ),
          children: [
            if (!hasData)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Tidak ada catatan menyusui pada tanggal ini.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              )
            else
              Column(
                children: r.daftarCatatan.map((catatan) {
                  return _buildSessionItem(context, catatan, isDark);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(
    BuildContext context,
    CatatanMenyusui catatan,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    // Warna badge sesuai payudara yang digunakan
    Color sideColor;
    if (catatan.sisi == 'Kiri') {
      sideColor = AppColors.primary;
    } else if (catatan.sisi == 'Kanan') {
      sideColor = Colors.orange.shade700;
    } else {
      sideColor = Colors.teal;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withAlpha(180)
            : AppColors.backgroundLight.withAlpha(120),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Badge Sisi Payudara
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: sideColor.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              catatan.sisi,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: sideColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Jam Sesi & Catatan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatJam(catatan.waktu),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (catatan.catatan.isNotEmpty)
                  Text(
                    catatan.catatan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          // Durasi
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${catatan.durasiMenit} mnt',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
