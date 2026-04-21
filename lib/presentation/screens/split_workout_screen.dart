import 'package:flutter/material.dart';
import 'package:training_app/presentation/widgets/gradient_card_button.dart';
import 'package:training_app/core/ui_constants.dart';
import 'package:training_app/data/workout_data.dart';
import 'package:training_app/presentation/screens/active_workout_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplitWorkoutScreen extends StatelessWidget {
  const SplitWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сплит тренировка'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GradientCardButton(
              title: "День 1",
              subtitle: "Грудь, Плечи, Трицепс",
              icon: Icons.fitness_center,
              gradient: LinearGradient(
                colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveWorkoutScreen(exercises: StaticWorkouts.splitDay1, workoutType: 'split_day_1'),
                  ),
                );
              },
            ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOut).slideY(),
            const SizedBox(height: UIConstants.padding24),
            GradientCardButton(
              title: "День 2",
              subtitle: "Спина, Бицепс",
              icon: Icons.fitness_center,
              gradient: LinearGradient(
                colors: [Colors.blueAccent.shade400, Colors.blueAccent.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveWorkoutScreen(exercises: StaticWorkouts.splitDay2, workoutType: 'split_day_2'),
                  ),
                );
              },
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms, curve: Curves.easeOut).slideY(),
            const SizedBox(height: UIConstants.padding24),
            GradientCardButton(
              title: "День 3",
              subtitle: "Ноги, Пресс",
              icon: Icons.fitness_center,
              gradient: LinearGradient(
                colors: [Colors.blueAccent.shade200, Colors.blueAccent.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveWorkoutScreen(exercises: StaticWorkouts.splitDay3, workoutType: 'split_day_3'),
                  ),
                );
              },
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms, curve: Curves.easeOut).slideY(),
          ],
        ),
      ),
    );
  }


}
