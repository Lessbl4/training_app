import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:training_app/models/workout_session_model.dart';
import 'package:training_app/services/database_service.dart';
import 'package:training_app/presentation/screens/session_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:training_app/presentation/widgets/gradient_card_button.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История тренировок'),
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
                    'История пока пуста. Время для первой тренировки!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
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
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, WorkoutSessionModel session) {
    return GradientCardButton(
      title: DateFormat.yMMMMd('ru').format(session.startTime),
      subtitle: '${session.exercises.length} упражнений',
      icon: Icons.history,
      gradient: LinearGradient(
        colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade400],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionDetailsScreen(session: session),
          ),
        );
      },
    );
  }
}
