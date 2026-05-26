import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_app/presentation/widgets/gradient_card_button.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/presentation/screens/active_workout_screen.dart';

class PersonalPlanScreen extends StatelessWidget {
  final Map<String, dynamic> planData;

  const PersonalPlanScreen({super.key, required this.planData});

  @override
  Widget build(BuildContext context) {
    final List<List<ExerciseModel>> days = planData['days'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваш ИИ-План'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(CupertinoIcons.sparkles, color: Colors.amber),
                    SizedBox(width: 8),
                    Text("Сгенерировано нейросетью", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(planData['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(planData['subtitle'], style: const TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text("План на неделю", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          ...List.generate(days.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GradientCardButton(
                title: "Тренировка ${index + 1}",
                subtitle: "${days[index].length} упражнений",
                icon: CupertinoIcons.flame_fill,
                gradient: LinearGradient(colors: [Colors.orange.shade600, Colors.red.shade700]),
                onPressed: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => ActiveWorkoutScreen(
                         title: "Тренировка ${index + 1}", 
                         exercises: days[index],
                       ),
                     ),
                   );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}