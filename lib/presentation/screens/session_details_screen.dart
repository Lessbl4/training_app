import 'package:flutter/material.dart';
import 'package:training_app/models/workout_session_model.dart';

class SessionDetailsScreen extends StatelessWidget {
  final WorkoutSessionModel session;

  const SessionDetailsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(session.workoutType),
      ),
      body: ListView.builder(
        itemCount: session.exercises.length,
        itemBuilder: (context, index) {
          final exercise = session.exercises[index];
          return ListTile(
            title: Text(exercise.name ?? ''),
            subtitle: Text(exercise.targetMuscle ?? ''),
          );
        },
      ),
    );
  }
}
