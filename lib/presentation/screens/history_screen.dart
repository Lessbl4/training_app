import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import 'package:training_app/core/ui_constants.dart';
import 'package:training_app/models/workout_session_model.dart';
import 'package:training_app/services/database_service.dart';
import 'package:training_app/presentation/screens/session_details_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История тренировок'),
      ),
      body: StreamBuilder<List<WorkoutSessionModel>>(
        stream: DatabaseService().getWorkoutHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Первый шаг — самый трудный. Начни тренировку!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: UIColors.lightGrey),
              ),
            );
          }

          final sessions = snapshot.data!;
          return AnimationLimiter(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildHistoryCard(context, session),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, WorkoutSessionModel session) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionDetailsScreen(session: session),
          ),
        );
      },
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 120,
        borderRadius: 20,
        blur: 10,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [
            UIColors.secondary.withAlpha((255 * 0.2).round()),
            UIColors.secondary.withAlpha((255 * 0.3).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            UIColors.secondary.withAlpha((255 * 0.5).round()),
            UIColors.white.withAlpha((255 * 0.5).round()),
          ],
        ),
        margin: const EdgeInsets.symmetric(
            horizontal: UIConstants.padding16, vertical: UIConstants.padding8),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd('ru').format(session.startTime),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: UIColors.white),
              ),
              const SizedBox(height: UIConstants.padding8),
              Text(
                session.workoutType,
                style: const TextStyle(fontSize: 16, color: UIColors.lightGrey),
              ),
              const SizedBox(height: UIConstants.padding8),
              Text(
                '${session.exercises.length} упражнений',
                style: const TextStyle(fontSize: 14, color: UIColors.lightGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
