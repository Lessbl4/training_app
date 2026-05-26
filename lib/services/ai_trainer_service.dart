import 'package:training_app/models/user_model.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/data/workout_data.dart';

class AITrainerService {
  static Map<String, dynamic> generatePlan(UserModel user) {
    String goal = user.goal?.toLowerCase() ?? 'поддержание';
    String exp = user.experience?.toLowerCase() ?? 'новичок';
    double bodyWeight = user.weight ?? 70.0;
    
    bool isBeginner = exp.contains('нович') || exp.contains('beginner');
    bool isWeightLoss = goal.contains('похуд') || goal.contains('сброс');
    bool isMass = goal.contains('набор') || goal.contains('масс');

    double expMultiplier = isBeginner ? 0.35 : 0.65; 
    double goalWeightMultiplier = isWeightLoss ? 0.75 : (isMass ? 1.05 : 0.9); 
    
    int sets = isWeightLoss ? 3 : 4;
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

         calcWeight = (calcWeight / 2.5).round() * 2.5; // Округляем до 2.5 кг (блины в зале)
         if (calcWeight < 2.5 && calcWeight > 0) calcWeight = 2.5; 

         String weightStr = calcWeight > 0 ? "${calcWeight.toStringAsFixed(1).replaceAll('.0', '')} кг" : "Свой вес";

         customizedExercises.add(ExerciseModel(
            name: ex.name,
            equipment: ex.equipment,
            targetMuscle: ex.targetMuscle,
            difficulty: ex.difficulty,
            description: ex.description,
            gifUrl: ex.gifUrl ?? "https://i.pinimg.com/originals/a4/d4/0b/a4d40b106b0d91d9ccafde6181f08e5c.gif",
            recommendedWeight: weightStr,
            recommendedReps: "$sets x $reps",
            recommendedRest: "$restSeconds сек",
         ));
      }
      customizedDays.add(customizedExercises);
    }

    return {
      "title": isBeginner ? "Адаптационный Full-Body" : "Прогрессивный Сплит PRO",
      "subtitle": isWeightLoss ? "Фокус: Сжигание жира" : "Фокус: Гипертрофия мышц",
      "days": customizedDays,
    };
  }
}