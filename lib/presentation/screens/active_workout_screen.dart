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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Инициализируем чекбоксы на основе ИИ (если ИИ сказал 3, будет 3 подхода)
    checkedSets = List.generate(
      widget.exercises.length,
      (index) {
        int setsCount = 4; // по умолчанию
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishWorkout() {
    SoundService.playNotify();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Тренировка успешно завершена! Вы молодец!')),
    );
    Navigator.pop(context); // Возвращает обратно к плану
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
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

                      // ИИ: ВИДЕО
                      if (exercise.gifUrl != null)
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
                      
                      // ИИ: ВЕС И ПОДХОДЫ
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
            if (!isButtonEnabled) {
              ScaffoldMessenger.of(context).clearSnackBars();
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
                boxShadow: [
                  if (isButtonEnabled) 
                    BoxShadow(
                      color: (isLastExercise ? theme.colorScheme.error : theme.colorScheme.primary).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
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