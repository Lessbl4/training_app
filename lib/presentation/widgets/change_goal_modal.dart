import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';
import 'package:training_app/services/sound_service.dart';

class ChangeGoalModal extends StatelessWidget {
  final String currentGoal;
  final String uid;

  const ChangeGoalModal({super.key, required this.currentGoal, required this.uid});

  @override
  Widget build(BuildContext context) {
    final goals = [
      {'title': 'Похудеть', 'icon': CupertinoIcons.flame_fill, 'color': const Color(0xFFFF512F)},
      {'title': 'Набрать массу', 'icon': Icons.fitness_center, 'color': AppColors.primary},
      {'title': 'Поддерживать форму', 'icon': CupertinoIcons.heart_solid, 'color': AppColors.success},
      {'title': 'Стать сильнее', 'icon': CupertinoIcons.bolt_fill, 'color': AppColors.secondary},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Изменить цель 🎯",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          "Твой ИИ-тренер адаптирует план под новую задачу.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        ...goals.map((g) {
          final isSelected = currentGoal == g['title'];
          final color = g['color'] as Color;

          return GestureDetector(
            onTap: () async {
              SoundService.playClick();
              await FirebaseFirestore.instance.collection('users').doc(uid).update({'goal': g['title']});
              if (context.mounted) Navigator.pop(context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? color : AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Icon(g['icon'] as IconData, color: isSelected ? Colors.white : color, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      g['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (isSelected) const Icon(CupertinoIcons.check_mark_circled_solid, color: Colors.white),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("ОТМЕНА", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}