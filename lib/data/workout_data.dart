import '../models/exercise_model.dart';

class StaticWorkouts {
  // ДЕНЬ 1: Грудь, Плечи, Трицепс
  static final List<ExerciseModel> splitDay1 = [
    ExerciseModel(name: 'Жим штанги лежа', equipment: 'Штанга', targetMuscle: 'Грудь', difficulty: '2'),
    ExerciseModel(name: 'Жим гантелей на наклонной скамье', equipment: 'Гантели', targetMuscle: 'Грудь', difficulty: '2'),
    ExerciseModel(name: 'Сведение рук в кроссовере', equipment: 'Тренажер', targetMuscle: 'Грудь', difficulty: '2'),
    ExerciseModel(name: 'Армейский жим стоя', equipment: 'Штанга', targetMuscle: 'Плечи', difficulty: '3'),
    ExerciseModel(name: 'Махи гантелями в стороны', equipment: 'Гантели', targetMuscle: 'Плечи', difficulty: '1'),
    ExerciseModel(name: 'Французский жим', equipment: 'Штанга', targetMuscle: 'Руки', difficulty: '2'),
    ExerciseModel(name: 'Разгибание рук на верхнем блоке', equipment: 'Тренажер', targetMuscle: 'Руки', difficulty: '1'),
  ];

  // ДЕНЬ 2: Спина, Бицепс
  static final List<ExerciseModel> splitDay2 = [
    ExerciseModel(name: 'Подтягивания на турнике', equipment: 'Свой вес', targetMuscle: 'Спина', difficulty: '3'),
    ExerciseModel(name: 'Тяга штанги в наклоне', equipment: 'Штанга', targetMuscle: 'Спина', difficulty: '3'),
    ExerciseModel(name: 'Тяга верхнего блока к груди', equipment: 'Тренажер', targetMuscle: 'Спина', difficulty: '1'),
    ExerciseModel(name: 'Тяга гантели одной рукой', equipment: 'Гантели', targetMuscle: 'Спина', difficulty: '2'),
    ExerciseModel(name: 'Подъем штанги на бицепс', equipment: 'Штанга', targetMuscle: 'Руки', difficulty: '1'),
    ExerciseModel(name: 'Молотки с гантелями', equipment: 'Гантели', targetMuscle: 'Руки', difficulty: '1'),
  ];

  // ДЕНЬ 3: Ноги, Пресс
  static final List<ExerciseModel> splitDay3 = [
    ExerciseModel(name: 'Приседания со штангой', equipment: 'Штанга', targetMuscle: 'Ноги', difficulty: '3'),
    ExerciseModel(name: 'Жим ногами в тренажере', equipment: 'Тренажер', targetMuscle: 'Ноги', difficulty: '1'),
    ExerciseModel(name: 'Выпады с гантелями', equipment: 'Гантели', targetMuscle: 'Ноги', difficulty: '2'),
    ExerciseModel(name: 'Сгибание ног лежа', equipment: 'Тренажер', targetMuscle: 'Ноги', difficulty: '1'),
    ExerciseModel(name: 'Подъем ног в висе', equipment: 'Свой вес', targetMuscle: 'Пресс', difficulty: '3'),
    ExerciseModel(name: 'Скручивания на полу', equipment: 'Свой вес', targetMuscle: 'Пресс', difficulty: '1'),
  ];

  // FULL BODY: Легкая
  static final List<ExerciseModel> fullBodyLight = [
    ExerciseModel(name: 'Отжимания от пола', equipment: 'Свой вес', targetMuscle: 'Грудь', difficulty: '1'),
    ExerciseModel(name: 'Тяга верхнего блока к груди', equipment: 'Тренажер', targetMuscle: 'Спина', difficulty: '1'),
    ExerciseModel(name: 'Жим гантелей сидя', equipment: 'Гантели', targetMuscle: 'Плечи', difficulty: '2'),
    ExerciseModel(name: 'Разгибание ног в тренажере', equipment: 'Тренажер', targetMuscle: 'Ноги', difficulty: '1'),
    ExerciseModel(name: 'Концентрированный подъем на бицепс', equipment: 'Гантели', targetMuscle: 'Руки', difficulty: '1'),
    ExerciseModel(name: 'Планка', equipment: 'Свой вес', targetMuscle: 'Пресс', difficulty: '1'),
  ];

  // FULL BODY: Тяжелая
  static final List<ExerciseModel> fullBodyHeavy = [
    ExerciseModel(name: 'Жим штанги лежа', equipment: 'Штанга', targetMuscle: 'Грудь', difficulty: '2'),
    ExerciseModel(name: 'Становая тяга', equipment: 'Штанга', targetMuscle: 'Спина', difficulty: '3'),
    ExerciseModel(name: 'Приседания со штангой', equipment: 'Штанга', targetMuscle: 'Ноги', difficulty: '3'),
    ExerciseModel(name: 'Армейский жим стоя', equipment: 'Штанга', targetMuscle: 'Плечи', difficulty: '3'),
    ExerciseModel(name: 'Отжимания на брусьях', equipment: 'Свой вес', targetMuscle: 'Руки', difficulty: '3'),
    ExerciseModel(name: 'Ролик для пресса', equipment: 'Тренажер', targetMuscle: 'Пресс', difficulty: '3'),
  ];
}
