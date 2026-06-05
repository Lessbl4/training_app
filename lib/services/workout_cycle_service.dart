import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutCycleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveWorkoutProgress(int dayIndex, bool isCompleted) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).update({
      'current_day_index': dayIndex,
      'last_workout_date': DateTime.now(),
    });
  }
}