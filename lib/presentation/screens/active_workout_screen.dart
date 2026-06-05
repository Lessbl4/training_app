import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/services/sound_service.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final String title;
  final List<ExerciseModel> exercises;

  const ActiveWorkoutScreen({super.key, required this.title, required this.exercises});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  
  // Хранит состояние чекбоксов: список упражнений -> список подходов
  late List<List<bool>> checkedSets;
  
  // Добавляем таймер отдыха
  int _restSeconds = 0;
  Timer? _restTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    checkedSets = List.generate(
      widget.exercises.length,
      (index) {
        int setsCount = 4;
        if (widget.exercises[index].recommendedReps != null) {
          final parts = widget.exercises[index].recommendedReps!.split(' ');
          if (parts.isNotEmpty) {
            setsCount = int.tryParse(parts[0]) ?? 4;
          }
        }
        return List.generate(setsCount, (_) => false);
      },
    );
  }

  void _startRestTimer() {
    setState(() => _restSeconds = 60);
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds > 0) {
        setState(() => _restSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _restTimer?.cancel();
    super.dispose();
  }

  void _finishWorkout() {
    SoundService.playNotify();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Тренировка успешно завершена! Вы молодец!')),
    );
    Navigator.pop(context);
  }

  bool allSetsCompleted() {
    if (checkedSets.isEmpty || _currentPage >= checkedSets.length) return false;
    final currentExerciseSets = checkedSets[_currentPage];
    for (int i = 0; i < currentExerciseSets.length; i++) {
      if (!currentExerciseSets[i]) return false;
    }
    return currentExerciseSets.isNotEmpty;
  }

  Widget _buildAIChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  // Диалог для подтверждения выхода
  Future<bool> _showExitConfirmation() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Завершить тренировку?'),
        content: const Text('Весь прогресс текущей тренировки будет потерян.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Нет')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Да')),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _showExitConfirmation()) {
          if (!context.mounted) return;
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            if (_restSeconds > 0)
              Container(
                color: Colors.blueAccent,
                padding: const EdgeInsets.all(8),
                child: Center(child: Text("Отдых: $_restSeconds сек", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Упражнение ${_currentPage + 1} из ${widget.exercises.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("${((_currentPage + 1) / widget.exercises.length * 100).toInt()}%", style: TextStyle(color: theme.colorScheme.primary)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / widget.exercises.length,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: widget.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = widget.exercises[index];
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text("Цель: ${exercise.targetMuscle} • Снаряд: ${exercise.equipment}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 20),

                        if (exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty)
                          Container(
                            height: 200,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: NetworkImage(exercise.gifUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        
                        if (exercise.recommendedWeight != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildAIChip(CupertinoIcons.flame_fill, "Вес: ${exercise.recommendedWeight}", Colors.orange),
                                _buildAIChip(CupertinoIcons.repeat, "Сеты: ${exercise.recommendedReps}", Colors.blue),
                                _buildAIChip(CupertinoIcons.timer, "Отдых: ${exercise.recommendedRest}", Colors.green),
                              ],
                            ),
                          ),

                        const Text("Техника выполнения", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(exercise.description, style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                        
                        const SizedBox(height: 30),
                        const Text("Подходы", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),

                        ...List.generate(checkedSets[index].length, (setIndex) {
                          return CheckboxListTile(
                            title: Text("Подход ${setIndex + 1}", style: const TextStyle(color: Colors.white)),
                            subtitle: Text(exercise.recommendedReps != null ? "Фокус на технику" : "Выполните на максимум", style: const TextStyle(color: Colors.white54)),
                            value: checkedSets[index][setIndex],
                            activeColor: theme.colorScheme.primary,
                            checkColor: Colors.white,
                            onChanged: (bool? value) {
                              setState(() {
                                checkedSets[index][setIndex] = value ?? false;
                                if (value == true) _startRestTimer();
                              });
                            },
                            secondary: const Icon(CupertinoIcons.checkmark_alt_circle, color: Colors.white30),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final isLastExercise = _currentPage == widget.exercises.length - 1;
    final isButtonEnabled = allSetsCompleted();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).clearSnackBars(); // ЗАЩИТА ОТ СПАМА
            if (!isButtonEnabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Отметьте все подходы для прогресса!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              if (isLastExercise) {
                _finishWorkout();
              } else {
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                setState(() {
                  _currentPage++;
                  _restSeconds = 0; // Сброс таймера при переходе
                });
              }
            }
          },
          child: Opacity(
            opacity: isButtonEnabled ? 1.0 : 0.5, 
            child: Container(
              height: 56, 
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLastExercise
                      ? [theme.colorScheme.error, theme.colorScheme.error.withOpacity(0.7)]
                      : [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastExercise ? "Завершить тренировку" : "Следующее упражнение",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastExercise ? CupertinoIcons.square_arrow_down_on_square_fill : CupertinoIcons.arrow_right_circle_fill,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}