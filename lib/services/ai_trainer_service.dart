import 'package:training_app/models/user_model.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/data/workout_data.dart'; // Предполагается, что тут лежат StaticWorkouts

class AITrainerService {
  
  // Главная функция генерации
  static Map<String, dynamic> generatePlan(UserModel user) {
    // 1. Извлекаем данные (с защитой от null)
    String goal = user.goal?.toLowerCase() ?? 'поддержание';
    String exp = user.experience?.toLowerCase() ?? 'новичок';
    double weight = user.weight ?? 70.0;
    double height = user.height ?? 175.0;

    // 2. Логика ИИ: Определяем тип тренировки
    bool isBeginner = exp.contains('нович') || exp.contains('beginner');
    bool isWeightLoss = goal.contains('похуд') || goal.contains('сброс') || goal.contains('loss');
    
    String planTitle = "";
    String planSubtitle = "";
    List<List<ExerciseModel>> workoutDays = [];

    // МАТРИЦА РЕШЕНИЙ
    if (isBeginner) {
      planTitle = "Адаптационный Full-Body";
      planSubtitle = isWeightLoss 
          ? "Сжигание жира и тонус всех мышц" 
          : "Базовый набор силы и массы";
      
      // Новичкам даем FullBody (берем из твоих статичных баз или БД)
      // Для демо мы симулируем 3 дня Full Body разной интенсивности
      workoutDays = [
        StaticWorkouts.fullBodyLight,
        StaticWorkouts.fullBodyHeavy,
        StaticWorkouts.fullBodyLight,
      ];
    } else {
      planTitle = "Прогрессивный Сплит PRO";
      planSubtitle = isWeightLoss 
          ? "Интенсивный рельеф и сушка" 
          : "Максимальная гипертрофия (Набор)";
      
      // Опытным даем 3-дневный сплит (Тяни-Толкай-Ноги)
      workoutDays = [
        StaticWorkouts.splitDay1, // Грудь, Плечи, Трицепс
        StaticWorkouts.splitDay2, // Спина, Бицепс
        StaticWorkouts.splitDay3, // Ноги, Пресс
      ];
    }

    // 3. Формируем рекомендации по подходам и отдыху в зависимости от цели
    String repsRecommendation = isWeightLoss ? "3 подхода по 15-20 повторений" : "4 подхода по 8-12 повторений";
    String restRecommendation = isWeightLoss ? "Отдых между подходами: 60 сек" : "Отдых между подходами: 90-120 сек";

    return {
      "title": planTitle,
      "subtitle": planSubtitle,
      "reps": repsRecommendation,
      "rest": restRecommendation,
      "days": workoutDays,
      "isProPlan": true, // Флаг, что это сгенерировано ИИ
    };
  }
}