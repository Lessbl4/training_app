import 'package:flutter/material.dart';


import 'package:training_app/core/ui_constants.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/presentation/widgets/gymify_progress_bar.dart';
import 'package:training_app/presentation/widgets/rest_timer.dart';
import 'package:training_app/presentation/widgets/workout_completion_overlay.dart';
import 'package:training_app/services/database_service.dart';
import 'package:training_app/models/workout_session_model.dart';


import 'package:training_app/services/sound_service.dart';
import 'package:training_app/core/localization_helper.dart';

enum WorkoutState { waiting, inProgress, resting }

class ActiveWorkoutScreen extends StatefulWidget {
  final List<ExerciseModel> exercises;
  final String workoutType;

  const ActiveWorkoutScreen(
      {super.key, required this.exercises, required this.workoutType});

  @override
  ActiveWorkoutScreenState createState() => ActiveWorkoutScreenState();
}

class ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  WorkoutState _workoutState = WorkoutState.waiting;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showRestTimer(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return RestTimer(
          duration: 60,
          onTimerEnd: () {
            Navigator.of(context).pop();
            SoundService.playNotify();
          },
        );
      },
    ));
  }

  void _finishWorkout() async {
    final session = WorkoutSessionModel(
      startTime: DateTime.now(),
      workoutType: widget.workoutType,
      exercises: widget.exercises,
    );
    await DatabaseService().saveWorkoutSession(session);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return const WorkoutCompletionOverlay();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Активная тренировка'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: GymifyProgressBar(
            current: _currentPage + 1,
            total: widget.exercises.length,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.exercises.length,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemBuilder: (context, index) {
          final exercise = widget.exercises[index];
          return _buildExercisePage(exercise);
        },
      ),
    );
  }

  Widget _buildExercisePage(ExerciseModel exercise) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.padding16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(exercise.name ?? '',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: UIConstants.padding8),
          Row(
            children: [
              const Icon(Icons.line_weight, size: 16),
              const SizedBox(width: 8),
              Text(exercise.targetMuscle ?? '',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: UIConstants.padding8),
          Row(
            children: [
              const Icon(Icons.fitness_center, size: 16),
              const SizedBox(width: 8),
              Text(translateEquipment(exercise.equipment),
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: UIConstants.padding16),
          if (exercise.description != null && exercise.description!.isNotEmpty)
            Text(exercise.description!, style: const TextStyle(fontSize: 16))
          else
            const Text(
              "Классическое упражнение для целевой мышечной группы. Соблюдайте правильную технику и дыхание.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          const SizedBox(height: UIConstants.padding16),
          _buildSetTracker(),
          const SizedBox(height: UIConstants.padding24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSetTracker() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 100,
          child: TextField(
            decoration: InputDecoration(labelText: "Вес (кг)"),
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            decoration: InputDecoration(labelText: "Повторения"),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    switch (_workoutState) {
      case WorkoutState.waiting:
        return ElevatedButton(
          onPressed: () {
            setState(() {
              _workoutState = WorkoutState.inProgress;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.0),
            ),
          ),
          child: const SizedBox(
            height: 50,
            child: Center(
              child: Text(
                "Начать упражнение",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        );
      case WorkoutState.inProgress:
        return Column(
          children: [
            // TODO: Add circular timer
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _workoutState = WorkoutState.resting;
                });
                _showRestTimer(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.0),
                ),
              ),
              child: const SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    "Выполнил подход",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),
                  child: const SizedBox(
                    width: 100,
                    height: 50,
                    child: Center(
                      child: Text(
                        "Пауза",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < widget.exercises.length - 1) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                      setState(() {
                        _workoutState = WorkoutState.waiting;
                      });
                    } else {
                      _finishWorkout();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),
                  child: const SizedBox(
                    width: 100,
                    height: 50,
                    child: Center(
                      child: Text(
                        "Завершить",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case WorkoutState.resting:
        return TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the rest timer
            setState(() {
              _workoutState = WorkoutState.inProgress;
            });
          },
          child: const Text("Пропустить отдых"),
        );
    }
  }
}
