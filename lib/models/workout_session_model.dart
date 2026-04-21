import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:training_app/models/exercise_model.dart';

class WorkoutSessionModel {
  final DateTime startTime;
  final String workoutType;
  final List<ExerciseModel> exercises;

  WorkoutSessionModel({
    required this.startTime,
    required this.workoutType,
    required this.exercises,
  });

  factory WorkoutSessionModel.fromMap(Map<String, dynamic> map) {
    try {
      return WorkoutSessionModel(
        startTime: (map["startTime"] as Timestamp).toDate(),
        workoutType: map["workoutType"] ?? ".",
        exercises: List<ExerciseModel>.from(
            map["exercises"]?.map((x) => ExerciseModel.fromMap(x)) ?? []),
      );
    } catch (e) {
      // print("Error parsing WorkoutSessionModel: $e");
      return WorkoutSessionModel(
        startTime: DateTime.now(),
        workoutType: ".",
        exercises: [],
      );
    }
  }
}
