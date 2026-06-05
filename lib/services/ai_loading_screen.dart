import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Добавили анимации
import 'package:training_app/services/database_service.dart';
import 'package:training_app/services/sound_service.dart';
import 'package:training_app/services/ai_trainer_service.dart';
import 'package:training_app/presentation/screens/personal_plan_screen.dart';

class AILoadingScreen extends StatefulWidget {
  const AILoadingScreen({super.key});

  @override
  State<AILoadingScreen> createState() => _AILoadingScreenState();
}

class _AILoadingScreenState extends State<AILoadingScreen> {
  int _currentStep = 0;
  
  // Твой список шагов (оставили как есть)
  final List<String> _loadingSteps = [
    "Синхронизация профиля...",
    "Анализ веса и ИМТ...",
    "Расчет рабочих весов...",
    "Оптимизация подходов и отдыха...",
    "Генерация персонального плана...",
    "План готов!"
  ];

  @override
  void initState() {
    super.initState();
    _startAIProcess();
  }

  void _startAIProcess() async {
    SoundService.playClick();
    
    // Запускаем переключение текста шагов
    Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentStep < _loadingSteps.length - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        timer.cancel();
      }
    });

    // Параллельно загружаем данные из базы и генерируем план
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      // Искусственная задержка в 3.5 секунды, чтобы юзер успел посмотреть красивую анимацию
      await Future.delayed(const Duration(milliseconds: 3500));
      
      final snapshot = await DatabaseService().getUserStream().first;
      final generatedPlan = AITrainerService.generatePlan(snapshot);

      if (!mounted) return;
      SoundService.playNotify();
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PersonalPlanScreen(planData: generatedPlan),
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Пульсирующий фон
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent.withOpacity(0.2),
                  ),
                ).animate(onPlay: (controller) => controller.repeat()).scale(
                      duration: 1500.ms,
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.5, 1.5),
                    ).fade(begin: 1, end: 0),
                
                // Иконка ИИ со свечением
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade500],
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
                    ],
                  ),
                  child: const Icon(CupertinoIcons.sparkles, color: Colors.white, size: 50),
                ).animate().shimmer(duration: 2.seconds, color: Colors.white54),
              ],
            ),
            const SizedBox(height: 40),
            
            // Твой текст шагов, который теперь плавно появляется
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _loadingSteps[_currentStep],
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ).animate(key: ValueKey(_currentStep)).fade(duration: 300.ms).slideY(begin: 0.2, end: 0),
            ),
            
            const SizedBox(height: 16),
            const Text(
              "🤖 Подбираем идеальные упражнения\n🔥 Считаем рабочие веса",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 16, height: 1.5),
            ).animate(delay: 500.ms).fade(duration: 500.ms),
          ],
        ),
      ),
    );
  }
}