import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:training_app/controllers/onboarding_controller.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';

class ActivityLevelScreen extends StatelessWidget {
  const ActivityLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {'level': 'beginner', 'title': 'Низкая', 'desc': 'Офисная работа, мало хожу', 'icon': CupertinoIcons.bed_double_fill, 'color': const Color(0xFF6366F1)},
      {'level': 'intermediate', 'title': 'Средняя', 'desc': 'Часто гуляю, умеренный труд', 'icon': CupertinoIcons.hare_fill, 'color': AppColors.primary},
      {'level': 'advanced', 'title': 'Высокая', 'desc': 'Физическая работа весь день', 'icon': CupertinoIcons.rocket_fill, 'color': AppColors.success},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.horizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Вне тренировок\nты активен? 🔋",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
            ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 40),
            
            ...activities.asMap().entries.map((entry) {
              int idx = entry.key;
              Map<String, dynamic> data = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ActivityCard(
                  level: data['level'] as String,
                  title: data['title'] as String,
                  description: data['desc'] as String,
                  icon: data['icon'] as IconData,
                  color: data['color'] as Color,
                  delay: 200 + (idx * 150),
                ),
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String level;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int delay;

  const ActivityCard({super.key, required this.level, required this.title, required this.description, required this.icon, required this.color, required this.delay});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();
    final isSelected = controller.userModel.activityLevel == level;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        controller.setActivityLevel(level);
      },
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : Colors.white.withOpacity(0.1), width: isSelected ? 2 : 1),
            boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))] : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: isSelected ? color : Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(icon, color: isSelected ? Colors.white : color, size: 28),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(description, style: TextStyle(fontSize: 14, color: isSelected ? Colors.white70 : Colors.grey[400])),
                        ],
                      ),
                    ),
                    if (isSelected) const Icon(CupertinoIcons.check_mark_circled_solid, color: Colors.white, size: 28).animate().scale(curve: Curves.easeOutBack),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fade(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }
}