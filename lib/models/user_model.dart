import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String name;
  String photo;
  bool isRegistrationComplete;
  DateTime? dateOfBirth;
  String? activityLevel;
  String? experience;
  String? goal;
  double? height;
  double? weight;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photo = '',
    this.isRegistrationComplete = false,
    this.dateOfBirth,
    this.activityLevel,
    this.experience,
    this.goal,
    this.height,
    this.weight,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['электронная почта'],
      name: map['имя'],
      photo: map['фото'] ?? '',
      isRegistrationComplete: map['isRegistrationComplete'] ?? false,
      dateOfBirth: (map['Дата рождения'] as Timestamp?)?.toDate(),
      activityLevel: map['уровень активности'],
      experience: map['опыт'],
      goal: map['цель'],
      height: map['высота']?.toDouble(),
      weight: map['вес']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'электронная почта': email,
      'имя': name,
      'фото': photo,
      'isRegistrationComplete': isRegistrationComplete,
      if (dateOfBirth != null) 'Дата рождения': Timestamp.fromDate(dateOfBirth!),
      if (activityLevel != null) 'уровень активности': activityLevel,
      if (experience != null) 'опыт': experience,
      if (goal != null) 'цель': goal,
      if (height != null) 'высота': height,
      if (weight != null) 'вес': weight,
    };
  }
}
