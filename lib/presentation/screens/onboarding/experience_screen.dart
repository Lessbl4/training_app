import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:training_app/controllers/onboarding_controller.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';

class ExperienceScreen extends StatelessWidget {
  const ExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final experiences = [
      {'title': 'Новичок', 'icon': CupertinoIcons.tortoise_fill, 'color': AppColors.success, 'desc': 'Только начинаю путь'},
      {'title': 'Средний', 'icon': CupertinoIcons.flame_fill, 'color': AppColors.primary, 'desc': 'Знаю базу, есть опыт'},
      {'title': 'Продвинутый', 'icon': CupertinoIcons.bolt_fill, 'color': AppColors.secondary, 'desc': 'Тренируюсь как машина'},
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
              "Твой опыт в\nтренировках? 💪",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
            ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 40),
            
            ...experiences.asMap().entries.map((entry) {
              int idx = entry.key;
              Map<String, dynamic> expData = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildExperienceCard(context, expData['title'] as String, expData['desc'] as String, expData['icon'] as IconData, expData['color'] as Color, 200 + (idx * 150)),
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context, String title, String desc, IconData icon, Color color, int delay) {
    final controller = context.watch<OnboardingController>();
    final isSelected = controller.userModel.experience == title;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        controller.setExperience(title);
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: isSelected ? color : Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(icon, color: isSelected ? Colors.white : color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(desc, style: TextStyle(fontSize: 14, color: isSelected ? Colors.white70 : Colors.grey[400])),
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