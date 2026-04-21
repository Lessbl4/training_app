import 'package:flutter/material.dart';

class WorkoutCompletionOverlay extends StatelessWidget {
  const WorkoutCompletionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Text('Тренировка завершена!', style: TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }
}
