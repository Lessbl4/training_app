import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:training_app/controllers/onboarding_controller.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';

class NameScreen extends StatelessWidget {
  const NameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<OnboardingController>();

    return Padding(
      padding: const EdgeInsets.all(AppPadding.horizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Как к тебе\nобращаться?",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
          ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          const Text(
            "Это имя будет использовать твой ИИ-тренер.",
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 60),
          
          TextField(
            onChanged: (name) => controller.setName(name),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            cursorColor: AppColors.primary,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Твое имя",
              hintStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.2)),
              // ИСПРАВЛЕНИЕ: Убрали const у UnderlineInputBorder, так как glassBorder это final
              border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.glassBorder, width: 2)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.glassBorder, width: 2)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 3)),
            ),
          ).animate().fade(delay: 400.ms).slideX(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}