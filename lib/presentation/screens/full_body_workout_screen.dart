import 'package:flutter/material.dart';
import 'package:training_app/presentation/widgets/gradient_card_button.dart';
import 'package:training_app/core/ui_constants.dart';
import 'package:training_app/data/workout_data.dart';
import 'package:training_app/presentation/screens/active_workout_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FullBodyWorkoutScreen extends StatelessWidget {
  const FullBodyWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Body тренировка'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GradientCardButton(
              title: "Легкая",
              subtitle: "Для начинающих и восстановления",
              icon: Icons.wb_sunny,
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveWorkoutScreen(exercises: StaticWorkouts.fullBodyLight, workoutType: 'full_body_light'),
                  ),
                );
              },
            ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOut).slideY(),
            const SizedBox(height: UIConstants.padding24),
            GradientCardButton(
              title: "Тяжелая",
              subtitle: "Для опытных атлетов",
              icon: Icons.whatshot,
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.red.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveWorkoutScreen(exercises: StaticWorkouts.fullBodyHeavy, workoutType: 'full_body_heavy'),
                  ),
                );
              },
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms, curve: Curves.easeOut).slideY(),
          ],
        ),
      ),
    );
  }


}
