import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:training_app/controllers/onboarding_controller.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';

class GoalSelectionStep extends StatelessWidget {
  const GoalSelectionStep({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = [
      {'title': 'Похудеть', 'icon': CupertinoIcons.flame_fill, 'color': const Color(0xFFFF512F)},
      {'title': 'Набрать массу', 'icon': Icons.fitness_center, 'color': AppColors.primary},
      {'title': 'Поддерживать форму', 'icon': CupertinoIcons.heart_solid, 'color': AppColors.success},
      {'title': 'Стать сильнее', 'icon': CupertinoIcons.bolt_fill, 'color': AppColors.secondary},
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
              "Какая твоя\nглавная цель? 🎯",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
            ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 40),
            
            ...goals.asMap().entries.map((entry) {
              int idx = entry.key;
              Map<String, dynamic> goalData = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GoalCard(
                  goal: goalData['title'] as String,
                  icon: goalData['icon'] as IconData,
                  color: goalData['color'] as Color,
                  delay: 200 + (idx * 150),
                ),
              );
            }),
            const SizedBox(height: 40), // Защитный отступ снизу
          ],
        ),
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final String goal;
  final IconData icon;
  final Color color;
  final int delay;

  const GoalCard({super.key, required this.goal, required this.icon, required this.color, required this.delay});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();
    final isSelected = controller.userModel.goal == goal;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        controller.setGoal(goal);
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
                      child: Text(goal, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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