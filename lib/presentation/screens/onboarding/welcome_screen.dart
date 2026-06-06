import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';
import 'package:training_app/widgets/custom_buttons.dart';
import 'package:training_app/presentation/screens/onboarding/name_screen.dart';
import 'dart:ui';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Фоновая картинка (Эпичный атлет)
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop',
              fit: BoxFit.cover,
            ).animate().fade(duration: 1.seconds),
          ),
          
          // 2. Темный градиент поверх фото, чтобы текст читался идеально
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withOpacity(0.1),
                    AppColors.background.withOpacity(0.6),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 3. Контент снизу
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.horizontal, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Блюр-плашка с логотипом
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "GYMIFY AI",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().slideY(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutBack).fade(),
                  
                  const SizedBox(height: 24),
                  
                  // Главный заголовок
                  const Text(
                    "Создай свою\nидеальную форму.",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ).animate().slideY(begin: 0.3, end: 0, duration: 700.ms, delay: 200.ms, curve: Curves.easeOutBack).fade(),
                  
                  const SizedBox(height: 16),
                  
                  // Описание
                  Text(
                    "Персональные тренировки на базе ИИ. Адаптируются под твои цели, уровень и возможности.",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().slideY(begin: 0.3, end: 0, duration: 700.ms, delay: 400.ms, curve: Curves.easeOutBack).fade(),
                  
                  const SizedBox(height: 40),
                  
                  // Кнопка входа
                  CustomElevatedButton(
                    text: "НАЧАТЬ ТРАНСФОРМАЦИЮ",
                    icon: Icons.bolt,
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const NameScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    },
                  ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 600.ms, delay: 600.ms, curve: Curves.easeOutBack).fade(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}