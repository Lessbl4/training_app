import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/services/database_service.dart';
import 'package:training_app/core/ui_constants.dart';
import 'package:training_app/presentation/screens/active_workout_screen.dart';

class ExerciseListScreen extends StatefulWidget {
  final String workoutType;

  const ExerciseListScreen({super.key, required this.workoutType});

  @override
  ExerciseListScreenState createState() => ExerciseListScreenState();
}

class ExerciseListScreenState extends State<ExerciseListScreen> {
  late Future<List<ExerciseModel>> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = DatabaseService().getExercisesForWorkout(widget.workoutType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Упражнения'),
      ),
      body: FutureBuilder<List<ExerciseModel>>(
        future: _exercises,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет доступных упражнений'));
          }

          final exercises = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildExerciseCard(exercise),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(UIConstants.padding16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActiveWorkoutScreen(exercises: exercises, workoutType: widget.workoutType),
                      ),
                    );
                  },
                  child: const Text("Начать тренировку"),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: UIConstants.padding16,
        vertical: UIConstants.padding8,
      ),
      color: UIColors.secondary,
      shape: const RoundedRectangleBorder(borderRadius: UIConstants.borderRadius12),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.padding16),
        child: Row(
          children: [
            // Иконка оборудования
            Image.network(
              exercise.gifUrl ?? '', // Используем gifUrl как иконку
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.fitness_center, size: 40, color: UIColors.white),
            ),
            const SizedBox(width: UIConstants.padding16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name ?? '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: UIColors.white),
                  ),
                  const SizedBox(height: UIConstants.padding4),
                  Text(
                    'Целевая мышца: ${exercise.targetMuscle ?? ''}',
                    style: const TextStyle(fontSize: 14, color: UIColors.lightGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
