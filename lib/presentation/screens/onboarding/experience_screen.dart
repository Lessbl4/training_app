import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:training_app/controllers/onboarding_controller.dart';

class ExperienceScreen extends StatelessWidget {
  const ExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Какой у вас опыт в\nтренировках?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          _buildExperienceCard(context, 'Новичок'),
          const SizedBox(height: 16),
          _buildExperienceCard(context, 'Средний'),
          const SizedBox(height: 16),
          _buildExperienceCard(context, 'Продвинутый'),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context, String title) {
    final controller = context.watch<OnboardingController>();
    final isSelected = controller.userModel.experience == title;

    return GestureDetector(
      onTap: () => controller.setExperience(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA5B4FC) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[300],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
