import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_app/models/workout_session_model.dart';

class WorkoutCompletionOverlay extends StatelessWidget {
  final WorkoutSessionModel session;

  const WorkoutCompletionOverlay({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.yellow, Colors.orange],
              ).createShader(bounds),
              child: const Icon(CupertinoIcons.flame_fill, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'ТРЕНИРОВКА ЗАВЕРШЕНА!',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            _buildStatsRow(theme),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Завершить и выйти на главную',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(theme, 'Время', '${(session.durationInSeconds / 60).floor()}:${(session.durationInSeconds % 60).toString().padLeft(2, '0')}', CupertinoIcons.clock_fill),
        _buildStatCard(theme, 'Общий вес', '${session.totalTonnage.toStringAsFixed(0)} кг', CupertinoIcons.flame_fill),
        _buildStatCard(theme, 'Упражнений', '${session.exercises.length}', CupertinoIcons.check_mark_circled_solid),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 32),
              const SizedBox(height: 8),
              Text(value, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(title, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
