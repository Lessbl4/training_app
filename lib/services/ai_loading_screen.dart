import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
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
  double _progress = 0.0;
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
    for (int i = 0; i < _loadingSteps.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentStep = i;
        _progress = (i + 1) / _loadingSteps.length;
      });
      await Future.delayed(const Duration(milliseconds: 600));
    }
    
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
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
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.waveform_circle_fill, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 30),
              Text(_loadingSteps[_currentStep], style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: _progress, backgroundColor: Colors.white10),
            ],
          ),
        ),
      ),
    );
  }
}