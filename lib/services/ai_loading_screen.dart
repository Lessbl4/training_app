import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:training_app/models/user_model.dart';
import 'package:training_app/services/database_service.dart';
import 'package:training_app/services/sound_service.dart';
import 'package:training_app/services/ai_trainer_service.dart';
// import 'package:training_app/presentation/screens/personal_plan_screen.dart'; // Создадим на следующем шаге

class AILoadingScreen extends StatefulWidget {
  const AILoadingScreen({super.key});

  @override
  State<AILoadingScreen> createState() => _AILoadingScreenState();
}

class _AILoadingScreenState extends State<AILoadingScreen> {
  int _currentStep = 0;
  double _progress = 0.0;
  
  final List<String> _loadingSteps = [
    "Синхронизация профиля...",
    "Анализ индекса массы тела (ИМТ)...",
    "Оценка уровня подготовки...",
    "Подбор оптимального сплита...",
    "Расчет количества повторений и отдыха...",
    "Генерация персонального плана...",
    "Готово!"
  ];

  @override
  void initState() {
    super.initState();
    _startAIProcess();
  }

  void _startAIProcess() async {
    SoundService.playClick();
    
    // Симулируем процесс загрузки (шаги меняются каждые 500 мс)
    for (int i = 0; i < _loadingSteps.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentStep = i;
        _progress = (i + 1) / _loadingSteps.length;
      });
      await Future.delayed(const Duration(milliseconds: 600));
    }

    // Когда всё загрузилось, получаем данные юзера из Firebase
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final snapshot = await DatabaseService().getUserStream().first;
      
      // Генерируем план через наш сервис
      final generatedPlan = AITrainerService.generatePlan(snapshot);

      if (!mounted) return;
      SoundService.playNotify();
      
      // Переходим на экран созданного плана (заменив экран загрузки)
      /* Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PersonalPlanScreen(planData: generatedPlan),
        ),
      );
      */
      
      // Пока экрана нет, просто выведем успех:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('План успешно сгенерирован!')),
      );
      Navigator.pop(context); // Временно просто закрываем
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black, // Темный футуристичный фон
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Анимированная иконка ИИ (мозг или процессор)
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.2),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ]
                      ),
                      child: const Icon(CupertinoIcons.waveform_circle_fill, size: 80, color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),
              
              // Меняющийся текст шагов
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _loadingSteps[_currentStep],
                  key: ValueKey<int>(_currentStep),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              
              // Прогресс-бар
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Gymify Neural Engine v1.0",
                style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5),
              )
            ],
          ),
        ),
      ),
    );
  }
}