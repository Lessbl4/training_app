import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? name;
  String? gender;
  DateTime? dateOfBirth;
  double? weight;
  double? height;
  String? goal;
  String? activityLevel;
  String? photoURL; // Added photoURL
  int xp;
  int level;

  UserModel({
    this.name,
    this.gender,
    this.dateOfBirth,
    this.weight,
    this.height,
    this.goal,
    this.activityLevel,
    this.photoURL, // Added photoURL
    this.xp = 0,
    this.level = 1,
  });

  // fromMap method
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map["name"],
      gender: map["gender"],
      dateOfBirth: (map["dateOfBirth"] as Timestamp?)?.toDate(),
      weight: map["weight"]?.toDouble(),
      height: map["height"]?.toDouble(),
      goal: map["goal"],
      activityLevel: map["activityLevel"],
      photoURL: map["photoURL"], // Added photoURL
      xp: map["xp"] ?? 0,
      level: map["level"] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) "name": name,
      if (gender != null) "gender": gender,
      if (dateOfBirth != null) "dateOfBirth": Timestamp.fromDate(dateOfBirth!),
      if (weight != null) "weight": weight,
      if (height != null) "height": height,
      if (goal != null) "goal": goal,
      if (activityLevel != null) "activityLevel": activityLevel,
      if (photoURL != null) "photoURL": photoURL, // Added photoURL
      "xp": xp,
      "level": level,
    };
  }
}
