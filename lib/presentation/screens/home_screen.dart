import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:training_app/presentation/screens/classic_workouts_screen.dart';
import 'package:training_app/services/ai_loading_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      // Используем ListView, чтобы на маленьких экранах ничего не "поплыло"
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildHomeCard(
            context: context,
            title: "Готовый план тренировок",
            subtitle: "Начать прямо сейчас",
            icon: CupertinoIcons.bolt_fill,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClassicWorkoutsScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildHomeCard(
            context: context,
            title: "Персональный план",
            subtitle: "Бесплатная генерация (AI)",
            icon: CupertinoIcons.person_crop_circle_fill,
            colors: [Colors.orange.shade700, Colors.orange.shade900],
            onTap: () {
              // ЗАПУСКАЕМ ЭКРАН ИИ (Дублирование убрано)
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const AILoadingScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildHomeCard(
            context: context,
            title: "Ведение с тренером PRO",
            subtitle: "Индивидуальный подход",
            icon: CupertinoIcons.star_circle_fill,
            colors: [Colors.purple.shade700, Colors.purple.shade900],
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Скоро: Доступ к PRO функциям!')),
              );
            },
          ),
        ],
      ),
    );
  }

  // Вынесли дизайн кнопки в отдельный метод, чтобы не дублировать код. Это ААА-подход.
  Widget _buildHomeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 130, // Оптимальная высота для списка
        borderRadius: 24.0,
        blur: 15,
        alignment: Alignment.center,
        border: 1.5,
        linearGradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withAlpha((255 * 0.6).round()),
            Colors.white.withAlpha((255 * 0.1).round()),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(CupertinoIcons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}