import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:training_app/controllers/onboarding_controller.dart';

class ExperienceScreen extends StatelessWidget {
  const ExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<OnboardingController>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Какой у вас опыт в тренировках?',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ...['Новичок', 'Средний', 'Продвинутый'].map((level) {
                return RadioListTile<String>(
                  title: Text(level, style: const TextStyle(color: Colors.white)),
                  value: level,
                  groupValue: controller.userModel.experience,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setExperience(value);
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
