import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_app/presentation/screens/classic_workouts_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренировки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(CupertinoIcons.flame_fill),
              title: const Text('Классические тренировки'),
              subtitle: const Text('Базовые программы для любого уровня'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClassicWorkoutsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
