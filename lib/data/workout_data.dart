import '../models/exercise_model.dart';

class StaticWorkouts {
  // ДЕНЬ 1: Грудь, Плечи, Трицепс
  static final List<ExerciseModel> splitDay1 = [
    ExerciseModel(name: 'Жим штанги лежа', equipment: 'Штанга', targetMuscle: 'Грудь', difficulty: '2', description: 'Классическое упражнение для развития грудных мышц.'),
    ExerciseModel(name: 'Жим гантелей на наклонной скамье', equipment: 'Гантели', targetMuscle: 'Грудь', difficulty: '2', description: 'Акцент на верхнюю часть грудных мышц.'),
    ExerciseModel(name: 'Сведение рук в кроссовере', equipment: 'Тренажер', targetMuscle: 'Грудь', difficulty: '2', description: 'Изолирующее упражнение для проработки формы груди.'),
    ExerciseModel(name: 'Армейский жим стоя', equipment: 'Штанга', targetMuscle: 'Плечи', difficulty: '3', description: 'Базовое движение для развития силы дельтовидных мышц.'),
    ExerciseModel(name: 'Махи гантелями в стороны', equipment: 'Гантели', targetMuscle: 'Плечи', difficulty: '1', description: 'Упражнение для формирования ширины плеч.'),
    ExerciseModel(name: 'Французский жим', equipment: 'Штанга', targetMuscle: 'Руки', difficulty: '2', description: 'Целенаправленная нагрузка на трицепс.'),
    ExerciseModel(name: 'Разгибание рук на верхнем блоке', equipment: 'Тренажер', targetMuscle: 'Руки', difficulty: '1', description: 'Изоляция трицепса с постоянным напряжением.'),
  ];

  // ДЕНЬ 2: Спина, Бицепс
  static final List<ExerciseModel> splitDay2 = [
    ExerciseModel(name: 'Подтягивания на турнике', equipment: 'Свой вес', targetMuscle: 'Спина', difficulty: '3', description: 'Фундаментальное упражнение для ширины спины.'),
    ExerciseModel(name: 'Тяга штанги в наклоне', equipment: 'Штанга', targetMuscle: 'Спина', difficulty: '3', description: 'Базовое упражнение для толщины мышц спины.'),
    ExerciseModel(name: 'Тяга верхнего блока к груди', equipment: 'Тренажер', targetMuscle: 'Спина', difficulty: '1', description: 'Безопасная альтернатива подтягиваниям.'),
    ExerciseModel(name: 'Тяга гантели одной рукой', equipment: 'Гантели', targetMuscle: 'Спина', difficulty: '2', description: 'Позволяет проработать широчайшие изолированно.'),
    ExerciseModel(name: 'Подъем штанги на бицепс', equipment: 'Штанга', targetMuscle: 'Руки', difficulty: '1', description: 'Классика для роста объема бицепса.'),
    ExerciseModel(name: 'Молотки с гантелями', equipment: 'Гантели', targetMuscle: 'Руки', difficulty: '1', description: 'Акцент на брахиалис и внешний пучок бицепса.'),
  ];

  // ДЕНЬ 3: Ноги, Пресс
  static final List<ExerciseModel> splitDay3 = [
    ExerciseModel(name: 'Приседания со штангой', equipment: 'Штанга', targetMuscle: 'Ноги', difficulty: '3', description: 'Главное упражнение для развития силы ног.'),
    ExerciseModel(name: 'Жим ногами в тренажере', equipment: 'Тренажер', targetMuscle: 'Ноги', difficulty: '1', description: 'Работа на квадрицепсы с минимальной нагрузкой на спину.'),
    ExerciseModel(name: 'Выпады с гантелями', equipment: 'Гантели', targetMuscle: 'Ноги', difficulty: '2', description: 'Упражнение на развитие баланса и проработку ягодиц.'),
    ExerciseModel(name: 'Сгибание ног лежа', equipment: 'Тренажер', targetMuscle: 'Ноги', difficulty: '1', description: 'Изоляция задней поверхности бедра.'),
    ExerciseModel(name: 'Подъем ног в висе', equipment: 'Свой вес', targetMuscle: 'Пресс', difficulty: '3', description: 'Эффективно нагружает нижнюю часть пресса.'),
    ExerciseModel(name: 'Скручивания на полу', equipment: 'Свой вес', targetMuscle: 'Пресс', difficulty: '1', description: 'Базовое упражнение для мышц живота.'),
  ];

  // FULL BODY: Легкая
  static final List<ExerciseModel> fullBodyLight = [
    ExerciseModel(name: 'Отжимания от пола', equipment: 'Свой вес', targetMuscle: 'Грудь', difficulty: '1', description: 'Классическое упражнение для верха тела.'),
    ExerciseModel(name: 'Тяга верхнего блока к груди', equipment: 'Тренажер', targetMuscle: 'Спина', difficulty: '1', description: 'Развитие спины без лишней нагрузки.'),
    ExerciseModel(name: 'Жим гантелей сидя', equipment: 'Гантели', targetMuscle: 'Плечи', difficulty: '2', description: 'Проработка плеч с поддержкой спины.'),
    ExerciseModel(name: 'Разгибание ног в тренажере', equipment: 'Тренажер', targetMuscle: 'Ноги', difficulty: '1', description: 'Изолированная работа квадрицепса.'),
    ExerciseModel(name: 'Концентрированный подъем на бицепс', equipment: 'Гантели', targetMuscle: 'Руки', difficulty: '1', description: 'Изоляция бицепса.'),
    ExerciseModel(name: 'Планка', equipment: 'Свой вес', targetMuscle: 'Пресс', difficulty: '1', description: 'Статическая нагрузка на мышцы кора.'),
  ];

  // FULL BODY: Тяжелая
  static final List<ExerciseModel> fullBodyHeavy = [
    ExerciseModel(name: 'Жим штанги лежа', equipment: 'Штанга', targetMuscle: 'Грудь', difficulty: '2', description: 'Силовой жим для грудных мышц.'),
    ExerciseModel(name: 'Становая тяга', equipment: 'Штанга', targetMuscle: 'Спина', difficulty: '3', description: 'Король упражнений для всей задней цепи.'),
    ExerciseModel(name: 'Приседания со штангой', equipment: 'Штанга', targetMuscle: 'Ноги', difficulty: '3', description: 'Максимальная нагрузка на ноги и спину.'),
    ExerciseModel(name: 'Армейский жим стоя', equipment: 'Штанга', targetMuscle: 'Плечи', difficulty: '3', description: 'Силовое упражнение для плечевого пояса.'),
    ExerciseModel(name: 'Отжимания на брусьях', equipment: 'Свой вес', targetMuscle: 'Руки', difficulty: '3', description: 'Отличное упражнение для груди и трицепса.'),
    ExerciseModel(name: 'Ролик для пресса', equipment: 'Тренажер', targetMuscle: 'Пресс', difficulty: '3', description: 'Интенсивная нагрузка на весь пресс.'),
  ];
}