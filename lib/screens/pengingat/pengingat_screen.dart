/// Layar Pengingat Menyusui — sesuai desain.
/// Toggle, dropdown interval/waktu/suara, tabel catatan, tombol tambah.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../models/catatan_menyusui.dart';
import '../../providers/catatan_provider.dart';
import '../../providers/reminder_provider.dart';

class PengingatScreen extends StatefulWidget {
  const PengingatScreen({super.key});

  @override
  State<PengingatScreen> createState() => _PengingatScreenState();
}

class _PengingatScreenState extends State<PengingatScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Muat data saat pertama kali ditampilkan
      final reminderProv = context.read<ReminderProvider>();
      final catatanProv = context.read<CatatanProvider>();
      Future.microtask(() {
        reminderProv.muatPengaturan();
        catatanProv.muatCatatan();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkPrimary.withAlpha(26)
                        : AppColors.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.notifications_active,
                      color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengingat Menyusui',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Atur jadwal pengingat',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Info: on demand 8-12 kali sehari ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkPrimary.withAlpha(15)
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkPrimary.withAlpha(26)
                      : AppColors.secondary.withAlpha(51),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: theme.colorScheme.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bayi baru lahir perlu menyusu on demand, '
                      'sekitar 8 sampai 12 kali dalam sehari.',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Kartu Pengaturan Pengingat ───
            const _PengaturanCard(),
            const SizedBox(height: 24),

            // ─── Catatan Menyusui ───
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Catatan Menyusui',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                // Tombol tambah
                IconButton(
                  onPressed: () => _showTambahCatatanDialog(context),
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ─── Tabel Catatan ───
            const _TabelCatatan(),
            const SizedBox(height: 20),

            // ─── Kotak info untuk Ayah ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.accent.withAlpha(20)
                    : AppColors.accent.withAlpha(64),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tips untuk Ayah: Saat alarm berbunyi, bantu ibu '
                      'bersiap dengan menyediakan air minum dan bantal '
                      'menyusui. Dampingi ibu agar proses menyusui '
                      'lebih nyaman.',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Dialog tambah catatan menyusui
  void _showTambahCatatanDialog(BuildContext context) {
    final theme = Theme.of(context);
    DateTime selectedWaktu = DateTime.now();
    String selectedSisi = 'Kiri';
    final durasiController = TextEditingController(text: '15');
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text('Tambah Catatan',
                  style: theme.textTheme.titleLarge),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Waktu
                    Text('Waktu', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime:
                              TimeOfDay.fromDateTime(selectedWaktu),
                        );
                        if (time != null) {
                          setDialogState(() {
                            selectedWaktu = DateTime(
                              selectedWaktu.year,
                              selectedWaktu.month,
                              selectedWaktu.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${selectedWaktu.hour.toString().padLeft(2, '0')}'
                          ':${selectedWaktu.minute.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sisi
                    Text('Sisi', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSisi,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      items: AppConstants.sisiOptions
                          .map((sisi) => DropdownMenuItem(
                                value: sisi,
                                child: Text(sisi),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedSisi = v!),
                    ),
                    const SizedBox(height: 12),

                    // Durasi
                    Text('Durasi (menit)',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: durasiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 15',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Catatan
                    Text('Catatan', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: catatanController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Catatan tambahan (opsional)',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final catatan = CatatanMenyusui(
                      waktu: selectedWaktu,
                      sisi: selectedSisi,
                      durasiMenit:
                          int.tryParse(durasiController.text) ?? 0,
                      catatan: catatanController.text.trim(),
                    );

                    Navigator.pop(dialogContext);

                    final provider = context.read<CatatanProvider>();
                    final success =
                        await provider.tambahCatatan(catatan);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Catatan berhasil disimpan!'
                              : provider.errorMessage ??
                                  'Gagal menyimpan.'),
                          backgroundColor: success
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════
// Kartu Pengaturan Pengingat
// ═══════════════════════════════════════════
class _PengaturanCard extends StatelessWidget {
  const _PengaturanCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<ReminderProvider>();
    final p = provider.pengaturan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkPrimary.withAlpha(26)
              : AppColors.secondary.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Toggle
          Row(
            children: [
              Icon(Icons.alarm, color: theme.colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pengingat Menyusui',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
                value: p.aktif,
                onChanged: (v) {
                  provider.updatePengaturan(p.copyWith(aktif: v));
                },
              ),
            ],
          ),

          // Pengaturan (hanya tampil jika toggle aktif)
          if (p.aktif) ...[
            const Divider(height: 24),

            // Interval
            _DropdownRow(
              label: 'Interval',
              value: '${p.intervalJam} jam',
              items: const ['1 jam', '2 jam', '3 jam', '4 jam'],
              onChanged: (v) {
                final jam = int.tryParse(v?.split(' ').first ?? '2') ?? 2;
                provider.updatePengaturan(p.copyWith(intervalJam: jam));
              },
            ),
            const SizedBox(height: 12),

            // Waktu Mulai
            _DropdownRow(
              label: 'Waktu Mulai',
              value: p.waktuMulai,
              items: List.generate(
                  24, (i) => '${i.toString().padLeft(2, '0')}:00'),
              onChanged: (v) {
                if (v != null) {
                  provider.updatePengaturan(p.copyWith(waktuMulai: v));
                }
              },
            ),
            const SizedBox(height: 12),

            // Jenis Suara
            _DropdownRow(
              label: 'Suara Pengingat',
              value: _labelSuara(p.jenisSuara),
              items: const ['Notifikasi', 'Getar', 'Notifikasi & Getar'],
              onChanged: (v) {
                String jenis;
                switch (v) {
                  case 'Notifikasi':
                    jenis = 'notifikasi';
                  case 'Getar':
                    jenis = 'getar';
                  default:
                    jenis = 'notifikasi_getar';
                }
                provider.updatePengaturan(p.copyWith(jenisSuara: jenis));
              },
            ),
            const SizedBox(height: 16),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final success = await provider.simpanPengaturan();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Pengaturan berhasil disimpan! '
                                        'Notifikasi dijadwalkan setiap '
                                        '${p.intervalJam} jam mulai ${p.waktuMulai}.'
                                    : provider.errorMessage ??
                                        'Gagal menyimpan.',
                              ),
                              backgroundColor: success
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          );
                        }
                      },
                child: provider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Pengaturan'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _labelSuara(String jenis) {
    switch (jenis) {
      case 'notifikasi':
        return 'Notifikasi';
      case 'getar':
        return 'Getar';
      default:
        return 'Notifikasi & Getar';
    }
  }
}

/// Baris dropdown reusable
class _DropdownRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            initialValue: items.contains(value) ? value : items.first,
            isExpanded: true,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: theme.textTheme.bodySmall),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════
// Tabel Catatan Menyusui
// ═══════════════════════════════════════════
class _TabelCatatan extends StatelessWidget {
  const _TabelCatatan();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<CatatanProvider>();
    final catatan = provider.daftarCatatan;

    if (provider.isLoading && catatan.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (catatan.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.darkPrimary.withAlpha(26)
                : AppColors.secondary.withAlpha(38),
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.event_note, size: 40,
                color: theme.colorScheme.primary.withAlpha(128)),
            const SizedBox(height: 8),
            Text(
              'Belum ada catatan menyusui.\nTekan + untuk menambahkan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkPrimary.withAlpha(26)
              : AppColors.secondary.withAlpha(38),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          columnSpacing: 16,
          horizontalMargin: 12,
          headingRowColor: WidgetStateProperty.all(
            isDark
                ? AppColors.darkPrimary.withAlpha(20)
                : AppColors.primary.withAlpha(15),
          ),
          columns: const [
            DataColumn(label: Text('Waktu')),
            DataColumn(label: Text('Sisi')),
            DataColumn(label: Text('Catatan')),
            DataColumn(label: Text('')),
          ],
          rows: catatan.map((c) {
            return DataRow(cells: [
              DataCell(Text(
                '${c.waktu.hour.toString().padLeft(2, '0')}'
                ':${c.waktu.minute.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              )),
              DataCell(Text(c.sisi, style: theme.textTheme.bodySmall)),
              DataCell(
                Text(
                  c.catatan.isNotEmpty
                      ? c.catatan
                      : '${c.durasiMenit} mnt',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                InkWell(
                  onTap: () async {
                    if (c.id == null) return;
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Catatan'),
                        content: const Text(
                            'Yakin ingin menghapus catatan ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted && c.id != null) {
                      await context
                          .read<CatatanProvider>()
                          .hapusCatatan(c.id!);
                    }
                  },
                  child: Icon(Icons.delete_outline,
                      size: 18, color: Colors.red.shade400),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
