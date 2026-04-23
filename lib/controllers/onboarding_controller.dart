import 'package:flutter/material.dart';
import 'package:training_app/models/user_model.dart';
import 'package:training_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingController extends ChangeNotifier {
  late PageController pageController;
  final DatabaseService _db = DatabaseService();
  late UserModel userModel;
  final bool isEditing;

  OnboardingController({UserModel? userModel, this.isEditing = false}) {
    final user = FirebaseAuth.instance.currentUser;
    this.userModel = userModel ?? UserModel(uid: user!.uid, email: user.email!, name: user.displayName ?? 
'');
  }

  int _pageIndex = 0;
int get pageIndex => _pageIndex;

  bool get isNextButtonEnabled {
    switch (_pageIndex) {
      case 0:
        return userModel.name != null && userModel.name!.isNotEmpty;
      case 1:
        return userModel.dateOfBirth != null && _calculateAge(userModel.dateOfBirth!) >= 13;
      case 2:
        return userModel.goal != null && userModel.goal!.isNotEmpty;
      case 3:
        return userModel.height != null;
      case 4:
        return userModel.activityLevel != null && userModel.activityLevel!.isNotEmpty;
      case 5:
        return userModel.experience != null && userModel.experience!.isNotEmpty;
      default:
        return true;
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

Future<void> nextPage() async {
    if (!isNextButtonEnabled) return;

    if (_pageIndex < 5) { // Adjusted for new screens
      _pageIndex++;
      pageController.animateToPage(
        _pageIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      notifyListeners();
    } else {
      await finishOnboarding();
    }
  }

  void previousPage() {
    if (_pageIndex > 0) {
      _pageIndex--;
      pageController.animateToPage(
        _pageIndex,
duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

Future<void> finishOnboarding() async {
    if (userModel.dateOfBirth != null && _calculateAge(userModel.dateOfBirth!) < 13) {
      throw Exception('Регистрация доступна только пользователям от 13 лет');
    }

    userModel.isRegistrationComplete = true;

    if (isEditing) {
      await _db.updateUserProfile(userModel.toMap());
    } else {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _db.createUserInDatabase(userModel, uid);
    }
  }

  void setGoal(String goal) {
    userModel.goal = goal;
    notifyListeners();
  }

  void setDateOfBirth(DateTime date) {
    userModel.dateOfBirth = date;
    notifyListeners();
  }

  void setExperience(String experience) {
    userModel.experience = experience;
    notifyListeners();
  }

  void setHeight(double height) {
    userModel.height = height;
    notifyListeners();
  }

  void setActivityLevel(String level) {
    userModel.activityLevel = level;
    notifyListeners();
  }

  void setName(String name) {
    userModel.name = name;
    notifyListeners();
  }
}
