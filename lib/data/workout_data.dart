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
final List<ExerciseModel> aiExerciseDatabase = [
  ExerciseModel(
    name: 'Жим штанги лежа',
    equipment: 'Штанга',
    targetMuscle: 'Грудь',
    difficulty: '2',
    description: 'Классическое упражнение для развития грудных мышц.',
    gifUrl: 'assets/videos/bench_press.mp4',
    tips: [
      'Лопатки сведены и прижаты к скамье на протяжении всего подхода',
      'Хват чуть шире плеч, предплечья в нижней точке вертикальны',
      'Контролируй опускание штанги, не бросай её на грудь'
    ],
  ),
  ExerciseModel(
    name: 'Жим гантелей на наклонной скамье',
    equipment: 'Гантели',
    targetMuscle: 'Грудь',
    difficulty: '2',
    description: 'Акцент на верхнюю часть грудных мышц.',
    gifUrl: 'assets/videos/incline_dumbbell_press.mp4',
    tips: [
      'Угол наклона скамьи 30-45 градусов',
      'Гантели в верхней точке не должны стучаться друг о друга',
      'Растягивай грудные в нижней точке, не разводи локти слишком широко'
    ],
  ),
  ExerciseModel(
    name: 'Сведение рук в кроссовере',
    equipment: 'Тренажер',
    targetMuscle: 'Грудь',
    difficulty: '2',
    description: 'Изолирующее упражнение для проработки формы груди.',
    gifUrl: 'assets/videos/cable_crossover.mp4',
    tips: [
      'Держи локти слегка согнутыми и неподвижными',
      'В точке сведения максимально прожми грудные мышцы',
      'Возвращай руки плавно, чувствуя растяжение, не дергай весом'
    ],
  ),
  ExerciseModel(
    name: 'Отжимания от пола',
    equipment: 'Свой вес',
    targetMuscle: 'Грудь',
    difficulty: '1',
    description: 'Классическое упражнение для верха тела.',
    gifUrl: 'assets/videos/pushup.mp4',
    tips: [
      'Держи тело ровно, как струну, не проваливай поясницу',
      'Не разводи локти слишком широко — 45 градусов к корпусу',
      'Касайся грудью пола, не провисай тазом'
    ],
  ),
  ExerciseModel(
    name: 'Армейский жим стоя',
    equipment: 'Штанга',
    targetMuscle: 'Плечи',
    difficulty: '3',
    description: 'Базовое движение для развития силы дельтовидных мышц.',
    gifUrl: 'assets/videos/military_press.mp4',
    tips: [
      'Напряги пресс и ягодицы, чтобы спина оставалась прямой',
      'Не прогибайся в пояснице, чтобы избежать травм',
      'Выталкивай штангу вверх, голова проходит чуть вперед после прохождения грифа'
    ],
  ),
  ExerciseModel(
    name: 'Махи гантелями в стороны',
    equipment: 'Гантели',
    targetMuscle: 'Плечи',
    difficulty: '1',
    description: 'Упражнение для формирования ширины плеч.',
    gifUrl: 'assets/videos/lateral_raises.mp4',
    tips: [
      'Мизинец должен быть чуть выше большого пальца в верхней точке',
      'Локти чуть согнуты, не поднимай гантели за счет трапеций',
      'Контролируй опускание, не раскачивайся корпусом'
    ],
  ),
  ExerciseModel(
    name: 'Жим гантелей сидя',
    equipment: 'Гантели',
    targetMuscle: 'Плечи',
    difficulty: '2',
    description: 'Проработка плеч с поддержкой спины.',
    gifUrl: 'assets/videos/seated_dumbbell_press.mp4',
    tips: [
      'Плотно прижми спину к скамье',
      'Не стучи гантелями в верхней точке',
      'Опускай гантели до уровня ушей, не ниже, чтобы не травмировать плечи'
    ],
  ),
  ExerciseModel(
    name: 'Французский жим',
    equipment: 'Штанга',
    targetMuscle: 'Руки',
    difficulty: '2',
    description: 'Целенаправленная нагрузка на трицепс.',
    gifUrl: 'assets/videos/french_press.mp4',
    tips: [
      'Локти должны быть зафиксированы, двигаются только предплечья',
      'Опускай гриф ко лбу или за голову, не разводя локти в стороны',
      'Не выпрямляй локти до щелчка в верхней точке'
    ],
  ),
  ExerciseModel(
    name: 'Разгибание рук на верхнем блоке',
    equipment: 'Тренажер',
    targetMuscle: 'Руки',
    difficulty: '1',
    description: 'Изоляция трицепса с постоянным напряжением.',
    gifUrl: 'assets/videos/triceps_extension.mp4',
    tips: [
      'Локти прижаты к корпусу, не гуляют',
      'Работай только предплечьями',
      'В нижней точке максимально прожми трицепс'
    ],
  ),
  ExerciseModel(
    name: 'Отжимания на брусьях',
    equipment: 'Свой вес',
    targetMuscle: 'Руки',
    difficulty: '3',
    description: 'Отличное упражнение для груди и трицепса.',
    gifUrl: 'assets/videos/dips.mp4',
    tips: [
      'Наклони корпус вперед для акцента на грудь, держи вертикально для трицепса',
      'Локти вдоль корпуса, не разводи их в стороны',
      'Не опускайся слишком низко, если чувствуешь дискомфорт в плечах'
    ],
  ),
  ExerciseModel(
    name: 'Подъем штанги на бицепс',
    equipment: 'Штанга',
    targetMuscle: 'Руки',
    difficulty: '1',
    description: 'Классика для роста объема бицепса.',
    gifUrl: 'assets/videos/barbell_biceps_curl.mp4',
    tips: [
      'Локти прижаты к бокам, не "гуляют" вперед-назад',
      'Не раскачивай корпус, чтобы закинуть вес',
      'Опускай штангу медленно, подконтрольно'
    ],
  ),
  ExerciseModel(
    name: 'Молотки с гантелями',
    equipment: 'Гантели',
    targetMuscle: 'Руки',
    difficulty: '1',
    description: 'Акцент на брахиалис и внешний пучок бицепса.',
    gifUrl: 'assets/videos/hammer_curls.mp4',
    tips: [
      'Ладони смотрят друг на друга весь подход, не прокручивай кисть',
      'Локти не уходят вперед',
      'Концентрируйся на подъеме веса за счет усилия предплечий'
    ],
  ),
  ExerciseModel(
    name: 'Концентрированный подъем на бицепс',
    equipment: 'Гантели',
    targetMuscle: 'Руки',
    difficulty: '1',
    description: 'Изоляция бицепса.',
    gifUrl: 'assets/videos/concentration_curl.mp4',
    tips: [
      'Локоть упри во внутреннюю часть бедра',
      'Изолируй движение, работает только бицепс',
      'Задержись на секунду в пиковой точке сокращения'
    ],
  ),
  ExerciseModel(
    name: 'Подтягивания на турнике',
    equipment: 'Свой вес',
    targetMuscle: 'Спина',
    difficulty: '3',
    description: 'Фундаментальное упражнение для ширины спины.',
    gifUrl: 'assets/videos/pullup.mp4',
    tips: [
      'Тянись грудью к перекладине, а не просто подбородком',
      'Представь, что тянешь локти вниз',
      'Не используй инерцию, работай только мышцами спины'
    ],
  ),
  ExerciseModel(
    name: 'Тяга штанги в наклоне',
    equipment: 'Штанга',
    targetMuscle: 'Спина',
    difficulty: '3',
    description: 'Базовое упражнение для толщины мышц спины.',
    gifUrl: 'assets/videos/barbell_row.mp4',
    tips: [
      'Спина строго параллельна полу',
      'Тяни штангу к поясу, лопатки своди вместе',
      'Держи поясницу в естественном прогибе, не горбись'
    ],
  ),
  ExerciseModel(
    name: 'Тяга верхнего блока к груди',
    equipment: 'Тренажер',
    targetMuscle: 'Спина',
    difficulty: '1',
    description: 'Безопасная альтернатива подтягиваниям.',
    gifUrl: 'assets/videos/lat_pulldown.mp4',
    tips: [
      'Не отклоняйся слишком сильно назад',
      'Тяни локти вниз, а не просто дергай руками',
      'Не отпускай вес резко, верни его в исходное положение плавно'
    ],
  ),
  ExerciseModel(
    name: 'Тяга гантели одной рукой',
    equipment: 'Гантели',
    targetMuscle: 'Спина',
    difficulty: '2',
    description: 'Позволяет проработать широчайшие изолированно.',
    gifUrl: 'assets/videos/dumbbell_row.mp4',
    tips: [
      'Спина параллельна полу, опора на скамью',
      'Тяни гантель к тазу, а не к плечу',
      'Не разворачивай корпус при подъеме веса'
    ],
  ),
  ExerciseModel(
    name: 'Становая тяга',
    equipment: 'Штанга',
    targetMuscle: 'Спина',
    difficulty: '3',
    description: 'Король упражнений для всей задней цепи.',
    gifUrl: 'assets/videos/deadlift.mp4',
    tips: [
      'Спина как струна, прогиб в пояснице строго запрещен',
      'Штанга скользит максимально близко к голеням',
      'Подъем идет за счет ног, спина лишь держит груз'
    ],
  ),
  ExerciseModel(
    name: 'Приседания со штангой',
    equipment: 'Штанга',
    targetMuscle: 'Ноги',
    difficulty: '3',
    description: 'Главное упражнение для развития силы ног.',
    gifUrl: 'assets/videos/squat.mp4',
    tips: [
      'Вес распределяй на всю стопу, дави пятками',
      'Колени должны идти в сторону носков',
      'Держи спину прямой, не заваливайся вперед'
    ],
  ),
  ExerciseModel(
    name: 'Жим ногами в тренажере',
    equipment: 'Тренажер',
    targetMuscle: 'Ноги',
    difficulty: '1',
    description: 'Работа на квадрицепсы с минимальной нагрузкой на спину.',
    gifUrl: 'assets/videos/leg_press.mp4',
    tips: [
      'Не отрывай таз от спинки тренажера в нижней точке',
      'Не выпрямляй колени до конца (лок-аут)',
      'Стопы ставь на ширине плеч, не сжимай колени вместе'
    ],
  ),
  ExerciseModel(
    name: 'Выпады с гантелями',
    equipment: 'Гантели',
    targetMuscle: 'Ноги',
    difficulty: '2',
    description: 'Упражнение на развитие баланса и проработку ягодиц.',
    gifUrl: 'assets/videos/lunges.mp4',
    tips: [
      'Шагай достаточно широко, чтобы колено не уходило за носок',
      'Держи спину вертикально, не наклоняйся',
      'Возвращайся в исходную за счет передней ноги'
    ],
  ),
  ExerciseModel(
    name: 'Сгибание ног лежа',
    equipment: 'Тренажер',
    targetMuscle: 'Ноги',
    difficulty: '1',
    description: 'Изоляция задней поверхности бедра.',
    gifUrl: 'assets/videos/leg_curl.mp4',
    tips: [
      'Не отрывай таз от скамьи при сгибании',
      'Держи темп, не бросай вес вниз',
      'Сфокусируйся на сокращении задней поверхности бедра'
    ],
  ),
  ExerciseModel(
    name: 'Разгибание ног в тренажере',
    equipment: 'Тренажер',
    targetMuscle: 'Ноги',
    difficulty: '1',
    description: 'Изолированная работа квадрицепса.',
    gifUrl: 'assets/videos/leg_extension.mp4',
    tips: [
      'Спина плотно прижата к спинке',
      'Поднимай вес за счет силы квадрицепсов',
      'Не бей суставами в верхней точке, плавно опускай обратно'
    ],
  ),
  ExerciseModel(
    name: 'Подъем ног в висе',
    equipment: 'Свой вес',
    targetMuscle: 'Пресс',
    difficulty: '3',
    description: 'Эффективно нагружает нижнюю часть пресса.',
    gifUrl: 'assets/videos/hanging_leg_raise.mp4',
    tips: [
      'Не раскачивайся, контролируй движение',
      'Скручивай таз в верхней точке, чтобы лучше прожать пресс',
      'Опускай ноги медленно, не бросай их'
    ],
  ),
  ExerciseModel(
    name: 'Скручивания на полу',
    equipment: 'Свой вес',
    targetMuscle: 'Пресс',
    difficulty: '1',
    description: 'Базовое упражнение для мышц живота.',
    gifUrl: 'assets/videos/crunches.mp4',
    tips: [
      'Не тяни голову руками, руки держи у висков',
      'Скручивай спину, а не просто поднимай корпус',
      'На выдохе максимально сжимай пресс'
    ],
  ),
  ExerciseModel(
    name: 'Планка',
    equipment: 'Свой вес',
    targetMuscle: 'Пресс',
    difficulty: '1',
    description: 'Статическая нагрузка на мышцы кора.',
    gifUrl: 'assets/videos/plank.mp4',
    tips: [
      'Ягодицы сжаты, пресс напряжен',
      'Тело — ровная линия',
      'Дыши ровно, не задерживай дыхание'
    ],
  ),
  ExerciseModel(
    name: 'Планка боком',
    equipment: 'Тренажер',
    targetMuscle: 'Пресс',
    difficulty: '3',
    description: 'Интенсивная нагрузка на бока пресса.',
    gifUrl: 'assets/videos/hand_side_plank.mp4',
    tips: [
      'Держи таз высоко, не провисай к полу',
      'Локоть строго под плечом',
      'Ровная линия от головы до пяток'
    ],
  ),
  ////НОВЫЕ ДОБАВИТЬЬ ВИДОСИКИ НАДА
  ExerciseModel(
  name: 'Жим штанги с обратным хватом',
  equipment: 'Штанга',
  targetMuscle: 'Грудь',
  difficulty: '3',
  description: 'Акцент на верхнюю часть груди.',
  gifUrl: 'assets/videos/reverse_grip_bench.mp4',
  tips: ['Хват на ширине плеч', 'Локти ближе к корпусу', 'Контролируй гриф'],
),

// Плечи
ExerciseModel(
  name: 'Разведение гантелей в наклоне',
  equipment: 'Гантели',
  targetMuscle: 'Плечи',
  difficulty: '2',
  description: 'Проработка заднего пучка дельт.',
  gifUrl: 'assets/videos/rear_delt_fly.mp4',
  tips: ['Спина параллельна полу', 'Веди локти вверх', 'Не используй трапеции'],
),

// Руки
ExerciseModel(
  name: 'Сгибание рук на скамье Скотта',
  equipment: 'Тренажер',
  targetMuscle: 'Руки',
  difficulty: '2',
  description: 'Максимальная изоляция бицепса.',
  gifUrl: 'assets/videos/preacher_curl.mp4',
  tips: ['Локти плотно на подставке', 'Полная амплитуда', 'Не отрывай плечи'],
),

// Спина
ExerciseModel(
  name: 'Гиперэкстензия',
  equipment: 'Тренажер',
  targetMuscle: 'Спина',
  difficulty: '1',
  description: 'Укрепление разгибателей спины.',
  gifUrl: 'assets/videos/hyperextension.mp4',
  tips: ['Не переразгибайся вверху', 'Плавно опускайся', 'Руки у груди или за головой'],
),

// Ноги
ExerciseModel(
  name: 'Гакк-приседания',
  equipment: 'Тренажер',
  targetMuscle: 'Ноги',
  difficulty: '2',
  description: 'Изолированная работа квадрицепса.',
  gifUrl: 'assets/videos/hack_squat.mp4',
  tips: ['Спина плотно к платформе', 'Не отрывай пятки', 'Плавный контроль'],
),

// Пресс
ExerciseModel(
  name: 'Русские скручивания',
  equipment: 'Свой вес',
  targetMuscle: 'Пресс',
  difficulty: '2',
  description: 'Проработка косых мышц живота.',
  gifUrl: 'assets/videos/russian_twist.mp4',
  tips: ['Поворачивай корпус, а не руки', 'Ноги на весу для сложности', 'Держи спину прямой'],
),

// Трапеции (НОВЫЕ)
ExerciseModel(
  name: 'Шраги со штангой',
  equipment: 'Штанга',
  targetMuscle: 'Спина', 
  difficulty: '2',
  description: 'Базовое упражнение для трапеций.',
  gifUrl: 'assets/videos/barbell_shrugs.mp4',
  tips: ['Не вращай плечами', 'Тяни плечи строго вверх к ушам', 'Держи руки прямыми'],
),
ExerciseModel(
  name: 'Шраги с гантелями',
  equipment: 'Гантели',
  targetMuscle: 'Спина',
  difficulty: '2',
  description: 'Развитие верхней части спины.',
  gifUrl: 'assets/videos/dumbbell_shrugs.mp4',
  tips: ['Взгляд вперед', 'Максимальное сокращение вверху', 'Медленное опускание'],
),

// Предплечья 
ExerciseModel(
  name: 'Сгибания кистей со штангой',
  equipment: 'Штанга',
  targetMuscle: 'Руки', 
  difficulty: '1',
  description: 'Изоляция мышц предплечья.',
  gifUrl: 'assets/videos/wrist_curls.mp4',
  tips: ['Предплечья на опоре', 'Движение только кистью', 'Растягивай внизу'],
),
ExerciseModel(
  name: 'Обратные сгибания кистей',
  equipment: 'Штанга',
  targetMuscle: 'Руки',
  difficulty: '1',
  description: 'Развитие внешней части предплечья.',
  gifUrl: 'assets/videos/reverse_wrist_curls.mp4',
  tips: ['Хват сверху', 'Фиксируй локти', 'Полная амплитуда'],
),
ExerciseModel(
    name: 'Подъем на носки в тренажере для жима ногами',
    equipment: 'Тренажер',
    targetMuscle: 'Ноги',
    difficulty: '2',
    description: 'Позволяет использовать большой вес для проработки икр.',
    gifUrl: 'assets/videos/leg_press_calf_raise.mp4',
    tips: ['Носки на краю платформы', 'Полная амплитуда внизу', 'Не сгибай колени'],
  ),
  ExerciseModel(
    name: 'Ослиные подъемы на носки',
    equipment: 'Свой вес',
    targetMuscle: 'Ноги',
    difficulty: '2',
    description: 'Изолирует камбаловидную и икроножную мышцы.',
    gifUrl: 'assets/videos/donkey_calf_raise.mp4',
    tips: ['Корпус в наклоне', 'Используй отягощение на пояснице', 'Плавный темп'],
  ),
  ExerciseModel(
    name: 'Прыжки на скакалке',
    equipment: 'Свой вес',
    targetMuscle: 'Ноги',
    difficulty: '1',
    description: 'Развивает выносливость и взрывную силу икр.',
    gifUrl: 'assets/videos/jump_rope.mp4',
    tips: ['Прыгай только на носках', 'Минимальная высота прыжка', 'Держи ритм'],
  ),
];