import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:training_app/models/workout_session_model.dart';
import 'package:training_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!authSnapshot.hasData) {
            return const Center(child: Text('Please log in.'));
          }
          final uid = authSnapshot.data!.uid;
          return StreamBuilder<List<WorkoutSessionModel>>(
            stream: DatabaseService().getUserWorkoutHistory(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Нет данных для статистики.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              final sessions = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      color: Colors.blueAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Всего тренировок',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${sessions.length}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.orange,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Последняя тренировка',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat.yMMMMd('ru').format(sessions.first.startTime),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
