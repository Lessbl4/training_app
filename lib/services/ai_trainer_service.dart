import 'package:training_app/models/user_model.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/data/workout_data.dart';

class AITrainerService {
  // Сохраняем сгенерированный план, чтобы не делать это заново каждый раз
  static Map<String, dynamic>? _cachedPlan;
  
  // Коэффициент прогрессии (увеличивается, если пользователь обновил показатели)
  static double _strengthBoost = 1.0;

  // Метод для принудительного сброса (вызовем при обновлении показателей)
  static void resetAndBoostPlan(double boostMultiplier) {
    _cachedPlan = null;
    _strengthBoost = boostMultiplier;
  }

  static Map<String, dynamic> generatePlan(UserModel user) {
    // Если план уже был сгенерирован в этой сессии — отдаем его моментально
    if (_cachedPlan != null) {
      return _cachedPlan!;
    }

    String goal = user.goal?.toLowerCase() ?? 'поддержание';
    String exp = user.experience?.toLowerCase() ?? 'новичок';
    double bodyWeight = user.weight ?? 70.0;
    
    bool isBeginner = exp.contains('нович') || exp.contains('begin');
    bool isWeightLoss = goal.contains('похуд') || goal.contains('сброс');
    bool isMass = goal.contains('набор') || goal.contains('масс');

    double expMultiplier = isBeginner ? 0.35 : 0.65; 
    double goalWeightMultiplier = isWeightLoss ? 0.75 : (isMass ? 1.05 : 0.9); 
    
    // Если пользователь нажал "Стало легко", увеличиваем подходы или вес
    int sets = (isWeightLoss ? 3 : 4) + (_strengthBoost > 1.1 ? 1 : 0);
    String reps = isWeightLoss ? "15-20" : "8-12";
    int restSeconds = isWeightLoss ? 60 : 90;

    List<List<ExerciseModel>> baseDays = isBeginner 
        ? [StaticWorkouts.fullBodyLight, StaticWorkouts.fullBodyHeavy, StaticWorkouts.fullBodyLight]
        : [StaticWorkouts.splitDay1, StaticWorkouts.splitDay2, StaticWorkouts.splitDay3];

    List<List<ExerciseModel>> customizedDays = [];
    
    for (var day in baseDays) {
      List<ExerciseModel> customizedExercises = [];
      for (var ex in day) {
         double calcWeight = 10.0;
         String exName = ex.name.toLowerCase();
         
         if (exName.contains("присед") || exName.contains("стан") || exName.contains("тяга штанги")) {
            calcWeight = bodyWeight * expMultiplier * 1.1 * goalWeightMultiplier; 
         } else if (exName.contains("жим лежа") || exName.contains("bench")) {
            calcWeight = bodyWeight * expMultiplier * 0.8 * goalWeightMultiplier; 
         } else if (exName.contains("жим") || exName.contains("тяга") || exName.contains("подтягивания")) {
            calcWeight = bodyWeight * expMultiplier * 0.5 * goalWeightMultiplier;
         } else if (exName.contains("сгибани") || exName.contains("разгибани") || exName.contains("махи") || exName.contains("подъем")) {
            calcWeight = bodyWeight * expMultiplier * 0.25 * goalWeightMultiplier; 
         } else if (exName.contains("пресс") || exName.contains("скручивания") || exName.contains("планка") || exName.contains("гиперэкстензия")) {
            calcWeight = 0; 
         }

         // ПРИМЕНЯЕМ КОЭФФИЦИЕНТ ПРОГРЕССИИ ЦНС
         calcWeight = calcWeight * _strengthBoost;

         calcWeight = (calcWeight / 2.5).round() * 2.5; 
         if (calcWeight < 2.5 && calcWeight > 0) calcWeight = 2.5; 

         String weightStr = calcWeight > 0 ? "${calcWeight.toStringAsFixed(1).replaceAll('.0', '')} кг" : "Свой вес";

         String currentGif = ""; 
         try {
           final match = aiExerciseDatabase.firstWhere((e) => e.name.toLowerCase() == exName);
           if (match.gifUrl != null) currentGif = match.gifUrl!;
         } catch (_) {}

         customizedExercises.add(ex.copyWith(
            recommendedWeight: weightStr,
            recommendedReps: "$sets x $reps",
            recommendedRest: "$restSeconds сек",
            gifUrl: currentGif,
         ));
      }
      customizedDays.add(customizedExercises);
    }

    _cachedPlan = {
      "title": isBeginner ? "Адаптационный Full-Body 🟢" : "Прогрессивный Сплит 🔥",
      "subtitle": isWeightLoss ? "Фокус: Рельеф и сжигание жира 💧" : "Фокус: Гипертрофия и сила 🦍",
      "days": customizedDays,
    };

    return _cachedPlan!;
  }
}