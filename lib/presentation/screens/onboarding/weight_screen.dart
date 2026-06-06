import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:training_app/controllers/onboarding_controller.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';
import 'package:training_app/presentation/widgets/custom_ruler_picker.dart';

class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.horizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Какой у тебя\nвес? ⚖️",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
          ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 60),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.1), blurRadius: 30)],
                ),
                // ИСПРАВЛЕНИЕ: Жестко задаем высоту!
                child: SizedBox(
                  height: 150,
                  child: CustomRulerPicker(
                    min: 30,
                    max: 150,
                    unit: 'кг',
                    value: controller.userModel.weight ?? 70,
                    onChanged: (value) => controller.setWeight(value),
                  ),
                ),
              ),
            ),
          ).animate().fade(delay: 300.ms).scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOutBack),
        ],
      ),
    );
  }
}