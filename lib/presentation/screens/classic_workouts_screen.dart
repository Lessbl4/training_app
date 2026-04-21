import 'package:flutter/material.dart';
import 'package:training_app/presentation/widgets/gradient_card_button.dart';
import 'package:training_app/core/ui_constants.dart';
import 'package:training_app/presentation/screens/split_workout_screen.dart';
import 'package:training_app/presentation/screens/full_body_workout_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ClassicWorkoutsScreen extends StatelessWidget {
  const ClassicWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Классические тренировки'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GradientCardButton(
              title: "Сплит",
              subtitle: "Раздельные тренировки по группам мышц",
              icon: Icons.flash_on,
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SplitWorkoutScreen()),
                );
              },
            ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOut).slideY(),
            const SizedBox(height: UIConstants.padding24),
            GradientCardButton(
              title: "Full Body",
              subtitle: "Проработка всего тела за одну сессию",
              icon: Icons.bolt,
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FullBodyWorkoutScreen()),
                );
              },
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms, curve: Curves.easeOut).slideY(),
          ],
        ),
      ),
    );
  }


}
