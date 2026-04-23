import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_app/services/sound_service.dart';
import 'package:training_app/presentation/screens/classic_workouts_screen.dart';
import 'package:training_app/presentation/screens/history_screen.dart';
import 'package:training_app/presentation/screens/statistics_screen.dart';
import 'package:training_app/presentation/screens/profile_screen.dart';
import 'package:training_app/presentation/screens/cns_test_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          ClassicWorkoutsScreen(),
          HistoryScreen(),
          CNSTestScreen(),
          StatisticsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white12,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: CupertinoTabBar(
            currentIndex: _currentIndex,
            onTap: (v) {
              SoundService.playClick();
              _pageController.animateToPage(
                v,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuart,
              );
            },
            backgroundColor: Colors.black,
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.flame),
                label: "Тренировка",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.list_bullet),
                label: "История",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.waveform_path_ecg),
                label: "ЦНС Тест",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_bar_alt_fill),
                label: "Статистика",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person),
                label: "Профиль",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
