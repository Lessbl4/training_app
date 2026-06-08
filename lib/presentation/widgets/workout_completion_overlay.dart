import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:training_app/models/workout_session_model.dart';
import 'package:training_app/services/history_service.dart';
import 'package:training_app/services/sound_service.dart';

class WorkoutCompletionOverlay extends StatefulWidget {
  final WorkoutSessionModel session;

  const WorkoutCompletionOverlay({super.key, required this.session});

  @override
  State<WorkoutCompletionOverlay> createState() => _WorkoutCompletionOverlayState();
}

class _WorkoutCompletionOverlayState extends State<WorkoutCompletionOverlay> {
  @override
  void initState() {
    super.initState();
    // Сохраняем тренировку в историю при открытии этого экрана
    HistoryService.addSession(widget.session);
    SoundService.playNotify(); // Победный звук
  }

  String _getTonnageHype(double tonnage) {
    if (tonnage < 500) return "Неплохая разминка! Дальше — больше! 💪";
    if (tonnage < 2000) return "Отличная работа! Ты перетягал вес легкового авто! 🚗💨";
    if (tonnage < 4000) return "Нифига себе! Ты поднял в сумме вес целого внедорожника! 🚙🔥";
    if (tonnage < 7000) return "ЖЕСТЬ! ${tonnage.toInt()} кг! Это вес взрослого африканского слона! 🐘💥";
    return "ТЫ ПРОСТО МАШИНА! ${tonnage.toInt()} кг — это вес чертового грузовика! 🚛💀";
  }

  String get _formattedTime {
    int m = widget.session.durationInSeconds ~/ 60;
    int s = widget.session.durationInSeconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // Задний фон (свечение)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orangeAccent.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 100, spreadRadius: 50)
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.2, duration: 2.seconds),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Иконка огня
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.red.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 30, spreadRadius: 10)
                      ],
                    ),
                    child: const Icon(CupertinoIcons.flame_fill, color: Colors.white, size: 80),
                  ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 30),
                  
                  const Text(
                    "ТРЕНИРОВКА\nЗАВЕРШЕНА!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: 1.5),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 20),

                  // Дерзкий текст про тоннаж
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      _getTonnageHype(widget.session.totalTonnage),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.orangeAccent, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ).animate().fadeIn(delay: 600.ms).scaleXY(begin: 0.9, end: 1.0),

                  const SizedBox(height: 40),

                  // Карточки со статистикой
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(CupertinoIcons.timer, _formattedTime, "Время", 800),
                      _buildStatCard(CupertinoIcons.chart_bar_alt_fill, "${widget.session.totalTonnage.toInt()} кг", "Объем", 1000),
                      _buildStatCard(CupertinoIcons.checkmark_seal_fill, "${widget.session.exercises.length}", "Упр-й", 1200),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Кнопка
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context), // Возврат на главную
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 10,
                        shadowColor: Colors.white.withOpacity(0.3),
                      ),
                      child: const Text("РАЗРЫВ! НА ГЛАВНУЮ 🔥", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    ),
                  ).animate().fadeIn(delay: 1500.ms).moveY(begin: 20, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, int delay) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.2, end: 0),
    );
  }
}