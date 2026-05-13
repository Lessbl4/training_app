import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:training_app/models/exercise_model.dart';

class WorkoutSessionModel {
  final DateTime startTime;
  final String workoutType;
  final List<ExerciseModel> exercises;
  final int durationInSeconds;
  final double totalTonnage;

  WorkoutSessionModel({
    required this.startTime,
    required this.workoutType,
    required this.exercises,
    required this.durationInSeconds,
    required this.totalTonnage,
  });

  factory WorkoutSessionModel.fromMap(Map<String, dynamic> map) {
    try {
      return WorkoutSessionModel(
        startTime: (map["startTime"] as Timestamp).toDate(),
        workoutType: map["workoutType"] ?? ".",
        exercises: List<ExerciseModel>.from(
            map["exercises"]?.map((x) => ExerciseModel.fromMap(x)) ?? []),
        durationInSeconds: map["durationInSeconds"] ?? 0,
        totalTonnage: (map["totalTonnage"] ?? 0).toDouble(),
      );
    } catch (e) {
      // print("Error parsing WorkoutSessionModel: $e");
      return WorkoutSessionModel(
        startTime: DateTime.now(),
        workoutType: ".",
        exercises: [],
        durationInSeconds: 0,
        totalTonnage: 0,
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "startTime": Timestamp.fromDate(startTime),
      "workoutType": workoutType,
      "exercises": exercises.map((e) => e.toMap()).toList(),
      "durationInSeconds": durationInSeconds,
      "totalTonnage": totalTonnage,
    };
  }
}
