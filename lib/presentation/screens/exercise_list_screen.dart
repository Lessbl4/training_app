import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/services/database_service.dart';
import 'package:training_app/core/ui_constants.dart';
import 'package:training_app/presentation/screens/active_workout_screen.dart';
import 'package:training_app/presentation/widgets/gradient_card_button.dart';

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
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // ИСПРАВЛЕНО: передаем только нужные параметры
                          builder: (context) => ActiveWorkoutScreen(
                            title: widget.workoutType, 
                            exercises: exercises,
                          ),
                        ),
                      );
                    },
                    child: const Text("Начать тренировку"),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.padding16, vertical: UIConstants.padding8),
      child: GradientCardButton(
        // ИСПРАВЛЕНО: используем только существующие параметры
        title: exercise.name,
        subtitle: 'Цель: ${exercise.targetMuscle}',
        icon: CupertinoIcons.flame_fill,
        gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900]),
        onPressed: () {
          // Действие при клике на упражнение, если нужно
        },
      ),
    );
  }
}