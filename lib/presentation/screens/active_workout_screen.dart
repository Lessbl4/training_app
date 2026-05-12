import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:training_app/core/ui_constants.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/presentation/widgets/gradient_card_button.dart';
import 'package:training_app/presentation/widgets/gymify_progress_bar.dart';
import 'package:training_app/presentation/widgets/rest_timer.dart';
import 'package:training_app/presentation/widgets/workout_completion_overlay.dart';
import 'package:training_app/services/database_service.dart';
import 'package:training_app/models/workout_session_model.dart';


import 'package:training_app/services/sound_service.dart';
import 'package:training_app/core/localization_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SetEntry {
  final TextEditingController weightController;
  final TextEditingController repsController;

  SetEntry() : weightController = TextEditingController(), repsController = TextEditingController();
}

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
  late List<List<SetEntry>> sets;
  late List<List<bool>> checkedSets;

@override
  void initState() {
    super.initState();
    _pageController = PageController();
    sets = List.generate(widget.exercises.length, (index) => [SetEntry()]);
    checkedSets = List.generate(
        widget.exercises.length, (index) => List.generate(1, (i) => false));
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
          onSkip: () {
            Navigator.of(context).pop();
            SoundService.playNotify();
          },
        );
      },
    ));
  }

  void _finishWorkout() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    List<ExerciseModel> exercises = [];
    for (int i = 0; i < widget.exercises.length; i++) {
      List<Map<String, double>> setsList = [];
      for (int j = 0; j < sets[i].length; j++) {
        final weight = double.tryParse(sets[i][j].weightController.text) ?? 0;
        final reps = double.tryParse(sets[i][j].repsController.text) ?? 0;
        setsList.add({"weight": weight, "reps": reps});
      }
      exercises.add(widget.exercises[i].copyWith(sets: setsList));
    }

    final session = WorkoutSessionModel(
      startTime: DateTime.now(),
      workoutType: widget.workoutType,
      exercises: exercises,
    );

    try {
      await DatabaseService().saveWorkoutSession(uid, session);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
            return const WorkoutCompletionOverlay();
          },
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save workout session: $e"),
        ),
      );
    }
  }

  @override
  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Прервать тренировку?'),
        content: const Text('Если вы выйдете сейчас, прогресс текущей сессии не будет сохранен.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Продолжить тренировку'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Активная тренировка'),
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
    ),); // Closing PopScope and Scaffold
  }

  Widget _buildExercisePage(ExerciseModel exercise) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name ?? 'Упражнение',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(CupertinoIcons.flame_fill, color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          exercise.targetMuscle ?? 'Целевая мышца',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ..._buildSetTrackers(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  List<Widget> _buildSetTrackers() {
    final theme = Theme.of(context);
    return sets[_currentPage].asMap().entries.map((entry) {
      int setIndex = entry.key;
      SetEntry setEntry = entry.value;
      bool isChecked = checkedSets[_currentPage][setIndex];

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isChecked ? theme.colorScheme.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isChecked ? theme.colorScheme.primary : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Сет ${setIndex + 1}",
              style: theme.textTheme.titleLarge?.copyWith(
                color: isChecked ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 80,
              child: TextField(
                controller: setEntry.weightController,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Вес (кг)",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                controller: setEntry.repsController,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Повторы",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                SoundService.playClick();
                setState(() {
                  checkedSets[_currentPage][setIndex] = !isChecked;
                  if (checkedSets[_currentPage][setIndex]) {
                    // Add a new set if the last one was checked
                    if (setIndex == sets[_currentPage].length - 1) {
                      sets[_currentPage].add(SetEntry());
                      checkedSets[_currentPage].add(false);
                    }
                    _showRestTimer(context);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isChecked ? theme.colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isChecked ? theme.colorScheme.primary : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isChecked
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final isLastExercise = _currentPage == widget.exercises.length - 1;

    return GradientCardButton(
      title: isLastExercise ? "Завершить тренировку" : "Следующее упражнение",
      icon: isLastExercise
          ? CupertinoIcons.square_arrow_down_on_square_fill
          : CupertinoIcons.arrow_right_circle_fill,
      gradient: LinearGradient(
        colors: isLastExercise
            ? [theme.colorScheme.error, theme.colorScheme.error.withOpacity(0.7)]
            : [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onPressed: () {
        if (isLastExercise) {
          _finishWorkout();
        } else {
          _pageController.nextPage(
              duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
          setState(() {
            _workoutState = WorkoutState.waiting;
          });
        }
      },
    );
  }
}
