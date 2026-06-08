import 'package:training_app/models/user_model.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/data/workout_data.dart';

class AITrainerService {
  static Map<String, dynamic>? _cachedPlan;
  static double _strengthBoost = 1.0;
  static List<bool> completedWorkouts = [false, false, false];

  static bool get hasActivePlan => _cachedPlan != null && completedWorkouts.contains(false);

  static void markWorkoutCompleted(int index) {
    if (index >= 0 && index < completedWorkouts.length) {
      completedWorkouts[index] = true;
    }
  }

  static void resetAndBoostPlan(double boostMultiplier) {
    _cachedPlan = null;
    _strengthBoost *= boostMultiplier;
    completedWorkouts = [false, false, false];
  }

  static List<ExerciseModel> _getEx(String muscle, int count, {String exclude = '', String include = ''}) {
    var all = aiExerciseDatabase.where((e) => e.targetMuscle.toLowerCase() == muscle.toLowerCase()).toList();
    if (exclude.isNotEmpty) all = all.where((e) => !e.name.toLowerCase().contains(exclude)).toList();
    if (include.isNotEmpty) all = all.where((e) => e.name.toLowerCase().contains(include)).toList();
    all.shuffle();
    return all.take(count).toList();
  }

  static Map<String, dynamic> generatePlan(UserModel user) {
    if (_cachedPlan != null && completedWorkouts.contains(false)) {
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
    
    int sets = (isWeightLoss ? 3 : 4) + (_strengthBoost > 1.1 ? 1 : 0);
    String reps = isWeightLoss ? "15-20" : "8-12";
    int restSeconds = isWeightLoss ? 60 : 90;

    List<List<ExerciseModel>> rawDays = [];

    if (isBeginner) {
       rawDays.add([
         ..._getEx('Грудь', 1), ..._getEx('Спина', 1), ..._getEx('Ноги', 2), ..._getEx('Плечи', 1), ..._getEx('Пресс', 1)
       ]);
       rawDays.add([
         ..._getEx('Спина', 2), ..._getEx('Грудь', 1), ..._getEx('Ноги', 1), ..._getEx('Руки', 2), ..._getEx('Пресс', 1)
       ]);
       rawDays.add([
         ..._getEx('Ноги', 2), ..._getEx('Ягодицы', 1), ..._getEx('Грудь', 1), ..._getEx('Спина', 1), ..._getEx('Плечи', 1)
       ]);
    } else {
       rawDays.add([
         ..._getEx('Грудь', 3), ..._getEx('Плечи', 2), ..._getEx('Руки', 2, include: 'трицепс', exclude: 'бицепс'), ..._getEx('Пресс', 1)
       ]);
       rawDays.add([
         ..._getEx('Спина', 3), ..._getEx('Руки', 2, include: 'бицепс', exclude: 'трицепс'), ..._getEx('Спина', 1, include: 'шраги'), ..._getEx('Пресс', 1)
       ]);
       rawDays.add([
         ..._getEx('Ноги', 3), ..._getEx('Ягодицы', 1), ..._getEx('Икры', 1), ..._getEx('Плечи', 2)
       ]);
    }

    List<List<ExerciseModel>> customizedDays = [];
    
    for (var day in rawDays) {
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
         } else if (exName.contains("пресс") || exName.contains("скручивания") || exName.contains("планка") || exName.contains("гиперэкстензия") || exName.contains("свой вес") || ex.equipment.toLowerCase().contains("свой вес")) {
            calcWeight = 0; 
         }

         calcWeight = calcWeight * _strengthBoost;
         calcWeight = (calcWeight / 2.5).round() * 2.5; 
         if (calcWeight < 2.5 && calcWeight > 0) calcWeight = 2.5; 

         String weightStr = calcWeight > 0 ? "${calcWeight.toStringAsFixed(1).replaceAll('.0', '')} кг" : "Свой вес";

         customizedExercises.add(ex.copyWith(
            recommendedWeight: weightStr,
            recommendedReps: "$sets x $reps",
            recommendedRest: "$restSeconds сек",
         ));
      }
      customizedDays.add(customizedExercises);
    }

    _cachedPlan = {
      "title": isBeginner ? "Адаптационный Full-Body 🟢" : "Прогрессивный Сплит 🔥",
      "subtitle": isWeightLoss ? "Фокус: Рельеф и сжигание жира 💧" : "Фокус: Гипертрофия и сила 🦍",
      "days": customizedDays,
    };

    completedWorkouts = [false, false, false];
    return _cachedPlan!;
  }
}