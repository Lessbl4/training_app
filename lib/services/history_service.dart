import 'package:training_app/models/workout_session_model.dart';

class HistoryService {
  // Локальное хранилище истории (в будущем можно прикрутить базу данных SQLite/Hive)
  static final List<WorkoutSessionModel> _sessions = [];

  static List<WorkoutSessionModel> get sessions => _sessions;

  static void addSession(WorkoutSessionModel session) {
    _sessions.insert(0, session); // Добавляем новую тренировку в начало списка
  }

  static double get totalAllTimeTonnage {
    return _sessions.fold(0.0, (sum, session) => sum + session.totalTonnage);
  }

  static int get totalAllTimeWorkouts => _sessions.length;
}