/// Home Screen — shell utama dengan Bottom Navigation 5 tab.
/// Mempertahankan state tiap tab menggunakan IndexedStack.
/// Sesuai desain layar 7.
library;

import 'package:flutter/material.dart';
import 'beranda_tab.dart';
import '../edukasi/edukasi_screen.dart';
import '../pengingat/pengingat_screen.dart';
import '../monitoring/monitoring_screen.dart';
import '../profil/profil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  /// Ganti tab dari widget anak (misal: kartu menu di Beranda)
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    state?._setTab(index);
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _setTab(int index) {
    setState(() => _currentIndex = index);
  }

  // Daftar tab — state dipertahankan dengan IndexedStack
  final List<Widget> _tabs = const [
    BerandaTab(),
    EdukasiScreen(),
    PengingatScreen(),
    MonitoringScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga state setiap tab tetap hidup
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),

      // ─── Bottom Navigation Bar ───
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _setTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Pengingat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Monitoring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
