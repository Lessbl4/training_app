import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/models/user_model.dart';
import 'package:training_app/models/workout_session_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    // print("LOG: Начинаю обновление данных пользователя...");
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        throw Exception("User not logged in");
      }
      await _db.collection("users").doc(firebaseUser.uid).update(data);
      // print("LOG: Данные успешно обновлены!");
    } catch (e) {
      // print("CRITICAL ERROR: $e");
      rethrow;
    }
  }

  Future<void> createUserInDatabase(UserModel user, String uid) async {
    try {
      await _db.collection("users").doc(uid).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forceImportExercises() async {
    // TODO: Добавить поле description в импорт
    // print('LOG: Начинаю импорт...');
    final String response =
        await rootBundle.loadString('assets/gym_exercises.json');
    final data = await json.decode(response) as Map<String, dynamic>;
    final exercises = data["exercises"] as List;

    final WriteBatch batch = _db.batch();

    for (var e in exercises) {
      final exercise = ExerciseModel.fromMap(e);
      final docId = (exercise.name ?? '').toLowerCase().replaceAll(' ', '_');
      final docRef = _db.collection('exercises').doc(docId);
      batch.set(docRef, exercise.toMap());
    }

    await batch.commit();
    // print('LOG: Импорт завершен успешно!');
  }

  Future<List<ExerciseModel>> getExercisesForWorkout(String workoutType) async {
    List<ExerciseModel> exercises = [];

    switch (workoutType) {
      case 'split_day_1':
        // 2-3 упражнения из 'Chest', 2 из 'Shoulders', 1 из 'Arms'
        exercises.addAll(await _getExercisesByMuscleGroup('Chest', 3));
        exercises.addAll(await _getExercisesByMuscleGroup('Shoulders', 2));
        exercises.addAll(await _getExercisesByMuscleGroup('Arms', 1));
        break;
      case 'split_day_2':
        // 3 упражнения из 'Back', 2 из 'Biceps'
        exercises.addAll(await _getExercisesByMuscleGroup('Back', 3));
        exercises.addAll(await _getExercisesByMuscleGroup('Biceps', 2));
        break;
      case 'split_day_3':
        // 3 упражнения из 'Legs'
        exercises.addAll(await _getExercisesByMuscleGroup('Legs', 3));
        exercises.addAll(await _getExercisesByMuscleGroup('Abs', 2));
        break;
      case 'full_body_light':
        exercises.addAll(await _getFullBodyWorkout('1'));
        break;
      case 'full_body_heavy':
        exercises.addAll(await _getFullBodyWorkout('3'));
        break;
    }

    exercises.shuffle();
    return exercises;
  }

  Future<List<ExerciseModel>> _getExercisesByMuscleGroup(
      String muscleGroup, int limit) async {
    QuerySnapshot snapshot = await _db
        .collection('exercises')
        .where('targetMuscle', isEqualTo: muscleGroup)
        .get();

    var exercises = snapshot.docs
        .map((doc) => ExerciseModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    exercises.shuffle();
    return exercises.take(limit).toList();
  }

  Future<List<ExerciseModel>> _getFullBodyWorkout(String difficulty) async {
    List<String> muscleGroups = [
      'Chest',
      'Back',
      'Legs',
      'Shoulders',
      'Biceps',
      'Triceps',
      'Abs'
    ];
    List<ExerciseModel> workout = [];

    for (String muscle in muscleGroups) {
      QuerySnapshot snapshot = await _db
          .collection('exercises')
          .where('targetMuscle', isEqualTo: muscle)
          .where('difficulty', isEqualTo: difficulty)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        workout.add(ExerciseModel.fromMap(
            snapshot.docs.first.data() as Map<String, dynamic>));
      }
    }
    return workout;
  }

  Future<void> saveWorkoutSession(
      String uid, WorkoutSessionModel session) async {
    final workoutData = {
      'startTime': session.startTime,
      'workoutType': session.workoutType,
      'exercises': session.exercises.map((e) => e.toMap()).toList(),
    };

    await _db
        .collection('users')
        .doc(uid)
        .collection('workout_history')
        .add(workoutData);

    await updateUserXp(100);
  }

  Stream<List<WorkoutSessionModel>> getUserWorkoutHistory(String uid) {
    return _db
        .collection("users")
        .doc(uid)
        .collection("workout_history")
        .orderBy("startTime", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutSessionModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> updateUserXp(int xp) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final userRef = _db.collection("users").doc(user.uid);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final newXp = (snapshot.data()!["xp"] ?? 0) + xp;
      final newLevel = (newXp / 500).floor() + 1;
      transaction.update(userRef, {"xp": newXp, "level": newLevel});
    });
  }

  Stream<UserModel> getUserStream() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return _db
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .map((snap) => UserModel.fromMap(snap.data()!));
  }
}
