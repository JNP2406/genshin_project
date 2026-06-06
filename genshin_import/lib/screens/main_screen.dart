import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'history/history_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _homeKey = 0;
  int _historyKey = 0;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    await SharedPreferences.getInstance();
  }

  // Dipanggil saat balik ke tab home/history untuk force refresh
  void _onTabTapped(int index) {
    if (index == 0 && _currentIndex == 0) {
      // Tap home lagi saat sudah di home → refresh
      setState(() => _homeKey++);
    } else if (index == 1 && _currentIndex == 1) {
      setState(() => _historyKey++);
    } else if (_currentIndex == 2 && index != 2) {
      // Balik dari profile → refresh home & history
      setState(() {
        _homeKey++;
        _historyKey++;
      });
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      HomeScreen(key: ValueKey(_homeKey)),
      HistoryScreen(key: ValueKey(_historyKey)),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor:
            isDark ? AppColors.darkHeader : AppColors.lightHeader,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        iconSize: 32,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}