import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_app/presentation/widgets/gradient_card_button.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/presentation/screens/active_workout_screen.dart';
import 'package:training_app/services/ai_trainer_service.dart';

class PersonalPlanScreen extends StatefulWidget {
  final Map<String, dynamic> planData;

  const PersonalPlanScreen({super.key, required this.planData});

  @override
  State<PersonalPlanScreen> createState() => _PersonalPlanScreenState();
}

class _PersonalPlanScreenState extends State<PersonalPlanScreen> {
  late Map<String, dynamic> currentPlan;

  @override
  void initState() {
    super.initState();
    currentPlan = widget.planData;
  }

  void _refreshPlan() {
    AITrainerService.resetAndBoostPlan(1.05);
    ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('План усложнен! Нажмите "Создать план" для получения новой программы.'), backgroundColor: Colors.green)
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final List<List<ExerciseModel>> days = currentPlan['days'];
    final bool allCompleted = AITrainerService.completedWorkouts.every((e) => e == true);

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
                Text(currentPlan['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(currentPlan['subtitle'], style: const TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          if (allCompleted)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _refreshPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Обновить план (Увеличить нагрузку) 🚀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          else
            const Text("План на неделю", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            
          const SizedBox(height: 16),
          
          ...List.generate(days.length, (index) {
            bool isCompleted = AITrainerService.completedWorkouts[index];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Opacity(
                opacity: isCompleted ? 0.5 : 1.0,
                child: GradientCardButton(
                  title: isCompleted ? "Тренировка ${index + 1} (Выполнено)" : "Тренировка ${index + 1}",
                  subtitle: "${days[index].length} упражнений",
                  icon: isCompleted ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.flame_fill,
                  gradient: isCompleted 
                      ? LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade800])
                      : LinearGradient(colors: [Colors.orange.shade600, Colors.red.shade700]),
                  onPressed: isCompleted ? () {} : () async {
                     await Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => ActiveWorkoutScreen(
                           title: "Тренировка ${index + 1}", 
                           exercises: days[index],
                           workoutIndex: index,
                         ),
                       ),
                     );
                     setState((){});
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}