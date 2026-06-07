import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';

import 'package:training_app/presentation/screens/home_screen.dart';
import 'package:training_app/presentation/screens/cns_test_screen.dart';
import 'package:training_app/presentation/screens/history_screen.dart';
import 'package:training_app/presentation/screens/profile_screen.dart';
import 'package:training_app/presentation/screens/anatomy_screen.dart';
// // ЗАГЛУШКА ДЛЯ ЭКРАНА АНАТОМИИ (КОТОРЫЙ МЫ СДЕЛАЕМ НА 2 ЭТАПЕ)
// class AnatomyPlaceholderScreen extends StatelessWidget {
//   const AnatomyPlaceholderScreen({super.key});
//   @override
//   Widget build(BuildContext context) => const Scaffold(backgroundColor: AppColors.background, body: Center(child: Text("Экран Анатомии (В разработке) 🧬", style: TextStyle(color: Colors.white))));
// }

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // 5 Экранов по твоему плану
  final List<Widget> _screens = [
    const HomeScreen(),
    const AnatomyScreen(), // 2. Упражнения (Анатомия)
    const CNSTestScreen(),            // 3. Тест ЦНС (ИСПРАВЛЕНО НА CNSTestScreen)
    const HistoryScreen(),            // 4. История
    const ProfileScreen(),            // 5. Профиль
  ];

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact(); // Вибрация при переключении
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Основной экран
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          // Плавающая стеклянная навигация
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(0, CupertinoIcons.house_fill, "Главная"),
                      _buildNavItem(1, CupertinoIcons.person_crop_circle_fill, "Мышцы"),
                      _buildNavItem(2, CupertinoIcons.waveform_path, "ЦНС"),
                      _buildNavItem(3, CupertinoIcons.chart_bar_alt_fill, "История"),
                      _buildNavItem(4, CupertinoIcons.gear_alt_fill, "Профиль"),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: isSelected ? 26 : 24),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ]
          ],
        ),
      ),
    );
  }
}