import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/adobe_colors.dart';
import 'dashboard_screen.dart';
import 'sensors_screen.dart';
import 'services_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onTabChange: _onTabTapped),
      const ServicesScreen(),
      const SensorsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AdobeColors.pureBlack,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AdobeColors.pureBlack,
          border: Border(
            top: BorderSide(color: AdobeColors.borderSubtle, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: AdobeColors.pureBlack,
          selectedItemColor: AdobeColors.orangeAccent,
          unselectedItemColor: AdobeColors.textMuted,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined, size: 20),
              activeIcon: Icon(Icons.dashboard, size: 20),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dns_outlined, size: 20),
              activeIcon: Icon(Icons.dns, size: 20),
              label: 'Dienste',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.speed_outlined, size: 20),
              activeIcon: Icon(Icons.speed, size: 20),
              label: 'Sensoren',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_outlined, size: 20),
              activeIcon: Icon(Icons.tune, size: 20),
              label: 'Setup',
            ),
          ],
        ),
      ),
    );
  }
}
