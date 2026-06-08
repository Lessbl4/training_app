import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muscle_selector/muscle_selector.dart';
import 'package:training_app/data/workout_data.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';
import 'package:training_app/services/sound_service.dart';
import 'package:video_player/video_player.dart';

const Map<String, String> _muscleEmoji = {
  'Грудь': '💪',
  'Плечи': '🏋️',
  'Бицепс': '🦾',
  'Трицепс': '💥',
  'Предплечья': '✊',
  'Пресс': '🔥',
  'Косые мышцы': '🌪️',
  'Квадрицепсы': '🦵',
  'Широчайшие': '🦇',
  'Трапеции': '🏔️',
  'Поясница': '🛡️',
  'Ягодицы': '🍑',
  'Икры': '👟',
};

const Map<String, String> _muscleDescription = {
  'Грудь': 'Грудные мышцы (pectoralis major) — крупная группа передней части туловища. Отвечают за сведение рук перед собой и жимовые движения. Верхний пучок — наклонные жимы, нижний — жимы вниз головой.',
  'Плечи': 'Три пучка: передний, средний и задний. Передний — жимы и подъёмы вперёд. Средний — махи в стороны. Задний — разведения в наклоне.',
  'Бицепс': 'Двуглавая мышца плеча. Основная функция — сгибание руки в локтевом суставе и супинация предплечья.',
  'Трицепс': 'Трёхглавая мышца плеча — самая большая мышца руки, занимающая около 60% её объёма. Состоит из трёх головок: длинной, медиальной и латеральной. Основная функция — разгибание руки в локтевом суставе.',
  'Предплечья': 'Группа мышц, отвечающая за силу хвата, сгибание и разгибание кистей и пальцев.',
  'Квадрицепсы': 'Четырехглавая мышца бедра. Самая сильная мышца тела, отвечающая за разгибание ноги в коленном суставе.',
  'Широчайшие': 'Крупнейшие мышцы спины, создающие V-образный силуэт. Основная функция — приведение плеча к туловищу.',
  'Трапеции': 'Мышцы верхней части спины и шеи. Отвечают за подъем и опускание плечевого пояса, сведение лопаток.',
  'Поясница': 'Глубокие мышцы-разгибатели позвоночника. Основа мышечного корсета и защита позвоночного столба.',
  'Ягодицы': 'Самые мощные мышцы тела. Отвечают за разгибание бедра и удержание туловища в вертикальном положении.',
  'Икры': 'Икроножная и камбаловидная мышцы. Обеспечивают подъем на носки и стабилизацию при ходьбе.',
  'Пресс': 'Прямая мышца живота. Формирует "кубики", сгибает позвоночник и поддерживает внутрибрюшное давление.',
  'Косые мышцы': 'Наружные и внутренние косые мышцы живота. Формируют талию и обеспечивают повороты корпуса.',
};

const Map<String, List<String>> _muscleTips = {
  'Грудь': [
    'Лопатки сведены и прижаты к скамье — это защищает плечи и увеличивает амплитуду',
    'Хват чуть шире плеч: предплечья в нижней точке должны быть строго вертикальны',
    'Опускай штангу медленно (2-3 сек) — негативная фаза даёт до 40% роста',
    'В кроссовере: зафиксируй локти в слегка согнутом положении и не меняй угол',
    'Для верха груди — угол скамьи 30-45°, выше не нужно',
  ],
  'Плечи': [
    'В махах мизинец должен быть чуть выше большого пальца',
    'При жиме не прогибай поясницу: напряги пресс и ягодицы',
    'Задние дельты отстают у большинства — добавь разведения в наклоне',
    'Не поднимай трапеции к ушам — следи чтобы плечи оставались опущенными',
    'Опускай гантели при жиме сидя только до уровня ушей',
  ],
  'Бицепс': [
    'Не раскачивай корпус — убери читинг, работай в строгой технике',
    'Локти зафиксированы по бокам туловища',
    'В верхней точке делай пиковое сокращение на 1 секунду',
  ],
  'Трицепс': [
    'Держи локти строго зафиксированными — не давай им разъезжаться в стороны',
    'В жиме узким хватом: руки параллельны, не разводи локти — максимально прижимай к телу',
    'Французский жим: опускай медленно, держи локти неподвижными, не позволяй им уходить назад',
    'Разгибания на блоке: не включай плечи в движение — работает только предплечье',
    'Длинная головка трицепса лучше растягивается когда руки подняты над головой',
  ],
  'Предплечья': [
    'Выполняй движения только в кистевом суставе',
    'Используй полную амплитуду для максимального растяжения',
    'Хват сверху развивает внешнюю часть, хват снизу — внутреннюю',
  ],
  'Квадрицепсы': [
    'Приседания: колени строго по линии носков, пятки не отрывать',
    'Спина должна оставаться прямой на протяжении всего движения',
    'В жиме ногами не выпрямляй колени до конца',
  ],
  'Широчайшие': [
    'Тяни локти, а не руки — представь что руки это просто крюки',
    'Не горби спину: естественный прогиб обязателен',
    'Подтягивания: в нижней точке не виси пассивно',
  ],
  'Трапеции': [
    'Не вращай плечами, движение только строго вверх-вниз',
    'В верхней точке обязательно делай паузу',
    'Смотри прямо перед собой, не опускай подбородок',
  ],
  'Поясница': [
    'Движение должно быть плавным, без рывков',
    'Не переразгибай спину в верхней точке гиперэкстензии',
    'Держи мышцы кора в напряжении',
  ],
  'Ягодицы': [
    'Сжимай ягодицы в верхней точке каждого повтора',
    'Глубокий присед включает ягодицы намного сильнее',
    'В выпадах шагай широко, чтобы колено не выходило за носок',
  ],
  'Икры': [
    'Полная амплитуда обязательна — максимальный подъём и полное опускание',
    'Делай паузу в нижней точке, чтобы исключить инерцию',
    'Не пружинь в суставах',
  ],
  'Пресс': [
    'Выдох на усилии, вдох на расслаблении',
    'Не тяни шею руками при скручиваниях — руки у висков',
    'Скручивай именно позвоночник, а не просто поднимай корпус',
  ],
  'Косые мышцы': [
    'Поворачивай весь корпус, а не только руки',
    'Держи таз неподвижным при скручиваниях',
    'Концентрируйся на растяжении боковых мышц',
  ],
};

// ─────────────────────────────────────────────────────────────────────────────
// ИСПРАВЛЕНО: правильный порядок проверок и поддержка трицепса
// ─────────────────────────────────────────────────────────────────────────────
String resolveMuscleGroup(Muscle muscle) {
  String raw = '';
  try { raw = (muscle as dynamic).groupId?.toString() ?? ''; } catch (_) {}
  if (raw.isEmpty) try { raw = (muscle as dynamic).id?.toString() ?? ''; } catch (_) {}
  if (raw.isEmpty) try { raw = (muscle as dynamic).name?.toString() ?? ''; } catch (_) {}
  if (raw.isEmpty) try { raw = (muscle as dynamic).muscleName?.toString() ?? ''; } catch (_) {}

  if (raw.isEmpty) {
    try {
      final groups = (Maps.BODY as dynamic).groups ?? (Maps.BODY as dynamic).muscleGroups;
      if (groups != null) {
        for (var g in groups) {
          final gMuscles = (g as dynamic).muscles;
          if (gMuscles != null) {
            for (var gm in gMuscles) {
              if (gm == muscle) {
                raw = (g as dynamic).id?.toString() ?? (g as dynamic).name?.toString() ?? '';
                break;
              }
            }
          }
          if (raw.isNotEmpty) break;
        }
      }
    } catch (_) {}
  }

  if (raw.isEmpty) {
    try {
      final fullStr = muscle.toString().toLowerCase();
      if (fullStr.contains('chest') || fullStr.contains('pec')) {
        raw = 'chest';
      } else if (fullStr.contains('shoulder') || fullStr.contains('deltoid') || fullStr.contains('delt')) {
        raw = 'shoulder';
      } else if (fullStr.contains('tricep')) {
        // ВАЖНО: трицепс проверяем ДО bicep и arm
        raw = 'tricep';
      } else if (fullStr.contains('forearm')) {
        // ВАЖНО: forearm проверяем ДО arm, иначе 'forearm'.contains('arm') == true
        raw = 'forearm';
      } else if (fullStr.contains('bicep')) {
        raw = 'biceps';
      } else if (fullStr.contains('arm')) {
        raw = 'biceps';
      } else if (fullStr.contains('abs') || fullStr.contains('abdomin')) {
        raw = 'abs';
      } else if (fullStr.contains('oblique')) {
        raw = 'oblique';
      } else if (fullStr.contains('quad')) {
        raw = 'quads';
      } else if (fullStr.contains('lat')) {
        raw = 'lats';
      } else if (fullStr.contains('trap')) {
        raw = 'traps';
      } else if (fullStr.contains('lower_back') || fullStr.contains('lower back')) {
        raw = 'lower_back';
      } else if (fullStr.contains('glute')) {
        raw = 'glutes';
      } else if (fullStr.contains('calf') || fullStr.contains('calves')) {
        raw = 'calves';
      }
    } catch (_) {}
  }

  final lower = raw.toLowerCase();

  // ИСПРАВЛЕННЫЙ ПОРЯДОК МАППИНГА
  if (lower.contains('chest') || lower.contains('pec')) return 'Грудь';
  if (lower.contains('shoulder') || lower.contains('deltoid') || lower.contains('delt')) return 'Плечи';
  // Трицепс — ДО проверки на 'arm' (иначе никогда не сработает)
  if (lower.contains('tricep')) return 'Трицепс';
  // Предплечья — ДО проверки на 'arm' ('forearm'.contains('arm') == true!)
  if (lower.contains('forearm')) return 'Предплечья';
  if (lower.contains('bicep') || lower.contains('arm')) return 'Бицепс';
  if (lower.contains('oblique')) return 'Косые мышцы';
  if (lower.contains('abs') || lower.contains('abdomin') || lower == 'core') return 'Пресс';
  if (lower.contains('quad')) return 'Квадрицепсы';
  if (lower.contains('hamstring') || lower.contains('leg')) return 'Квадрицепсы';
  if (lower.contains('lat')) return 'Широчайшие';
  if (lower.contains('trap') || lower.contains('neck')) return 'Трапеции';
  if (lower.contains('lower_back') || lower.contains('lower back')) return 'Поясница';
  if (lower.contains('upper_back') || lower.contains('back')) return 'Широчайшие';
  if (lower.contains('glute')) return 'Ягодицы';
  if (lower.contains('calf') || lower.contains('calves')) return 'Икры';

  return 'Грудь';
}

class AnatomyScreen extends StatefulWidget {
  const AnatomyScreen({super.key});
  @override
  State<AnatomyScreen> createState() => _AnatomyScreenState();
}

class _AnatomyScreenState extends State<AnatomyScreen> {
  final GlobalKey<MusclePickerMapState> _mapKey = GlobalKey();
  Set<Muscle> _prevMuscles = {};

  void _onMuscleChanged(Set<Muscle> muscles) {
    if (muscles.isEmpty) {
      _prevMuscles = {};
      return;
    }

    final added = muscles.difference(_prevMuscles);
    _prevMuscles = muscles;

    if (added.isEmpty) return;

    final tapped = added.first;
    final group = resolveMuscleGroup(tapped);

    SoundService.playClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MuscleCategorySheet(targetMuscle: group),
    ).then((_) {
      _mapKey.currentState?.clearSelect();
      _prevMuscles = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      // ── Тело уходит ЗА AppBar — полный экран ──────────────────────────────
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Выбери группу мышц',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Иконки статус-бара — белые (на тёмном фоне)
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Слой 2: интерактивная карта — полный экран как фон ──────────
          Positioned.fill(
            child: InteractiveViewer(
              scaleEnabled: true,
              panEnabled: true,
              minScale: 0.7,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(180),
              child: Center(
                child: MusclePickerMap(
                  key: _mapKey,
                  // Полный экран — фигура центрируется внутри всего пространства
                  width: size.width,
                  height: size.height,
                  map: Maps.BODY,
                  selectedColor: AppColors.primary,
                  strokeColor: Colors.white30,
                  dotColor: Colors.transparent,
                  onChanged: _onMuscleChanged,
                ),
              ),
            ),
          ),

          // ── Слой 3: верхний градиент — AppBar «тонет» в фоне плавно ─────
          Positioned(
            top: 0, left: 0, right: 0,
            child: IgnorePointer(
              child: Container(
                height: topPad + kToolbarHeight + 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background,
                      AppColors.background.withOpacity(0.80),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Слой 4: нижний градиент + подсказка ─────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: IgnorePointer(
              child: Container(
                height: 110,
                padding: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.background,
                      AppColors.background.withOpacity(0.6),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.10)),
                    ),
                    child: const Text(
                      '👆 Нажми на мышцу для деталей',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MuscleCategorySheet extends StatelessWidget {
  final String targetMuscle;

  const MuscleCategorySheet({super.key, required this.targetMuscle});

  List<ExerciseModel> _getFilteredExercises() {
    return aiExerciseDatabase.where((ex) {
      final t = ex.targetMuscle.toLowerCase();
      final n = ex.name.toLowerCase();
      final m = targetMuscle.toLowerCase();

      if (t == m) return true;
      if (m == 'трапеции' && (t == 'спина' && n.contains('шраги'))) return true;
      if (m == 'широчайшие' && (t == 'спина' && !n.contains('шраги') && !n.contains('гипер'))) return true;
      if (m == 'поясница' && (t == 'спина' && (n.contains('гипер') || n.contains('станов')))) return true;
      if (m == 'трицепс' && ((t == 'руки' || t == 'трицепс') && (n.contains('трицепс') || n.contains('разгиб') || n.contains('французск') || n.contains('узк') || n.contains('брусь')))) return true;
      if (m == 'бицепс' && ((t == 'руки' || t == 'бицепс') && (n.contains('бицепс') || n.contains('молот') || n.contains('скотт')))) return true;
      if (m == 'предплечья' && ((t == 'руки' || t == 'предплечья') && n.contains('кист'))) return true;
      if (m == 'квадрицепсы' && (t == 'ноги' && !n.contains('икр') && !n.contains('носки') && !n.contains('ягодиц') && !n.contains('сгибан') && !n.contains('румынск'))) return true;
      if (m == 'икры' && ((t == 'ноги' || t == 'икры') && (n.contains('икр') || n.contains('носк') || n.contains('прыж')))) return true;
      if (m == 'косые мышцы' && (t == 'пресс' && (n.contains('кос') || n.contains('боком') || n.contains('русск')))) return true;
      if (m == 'пресс' && (t == 'пресс' && !n.contains('боком') && !n.contains('русск'))) return true;
      if (m == 'ягодицы' && ((t == 'ноги' || t == 'ягодицы') && (n.contains('ягодиц') || n.contains('выпад') || n.contains('мостик')))) return true;

      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _muscleEmoji[targetMuscle] ?? '💪';
    final desc = _muscleDescription[targetMuscle] ?? '';
    final exercises = _getFilteredExercises();

    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.2,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: 40),
            physics: const BouncingScrollPhysics(),
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('$emoji ', style: const TextStyle(fontSize: 32)),
                    Expanded(
                      child: Text(
                        targetMuscle,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              if (desc.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Text(
                      desc,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    const Text(
                      'УПРАЖНЕНИЯ',
                      style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const Spacer(),
                    Text(
                      '${exercises.length}',
                      style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (exercises.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'Упражнения не найдены',
                      style: TextStyle(color: Colors.white38, fontSize: 16),
                    ),
                  ),
                )
              else
                ...exercises.map((ex) => _ExerciseTile(
                      exercise: ex,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (_) => ExerciseDetailSheet(exercise: ex, category: targetMuscle),
                        );
                      },
                    )),
            ],
          ),
        );
      },
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onTap;

  const _ExerciseTile({required this.exercise, required this.onTap});

  String get _diffLabel {
    switch (exercise.difficulty) {
      case '1': return 'Лёгкое';
      case '2': return 'Среднее';
      case '3': return 'Тяжёлое';
      default: return exercise.difficulty;
    }
  }

  Color get _diffColor {
    switch (exercise.difficulty) {
      case '1': return Colors.greenAccent;
      case '2': return Colors.orangeAccent;
      case '3': return Colors.redAccent;
      default: return Colors.white54;
    }
  }

  String get _equipEmoji {
    switch (exercise.equipment) {
      case 'Штанга': return '🏋️';
      case 'Гантели': return '💪';
      case 'Тренажер': return '⚙️';
      case 'Свой вес': return '🤸';
      default: return '🔧';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService.playClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(_equipEmoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _diffColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _diffLabel,
                          style: TextStyle(color: _diffColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        exercise.equipment,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_up_circle_fill, color: AppColors.primary, size: 28),
          ],
        ),
      ),
    );
  }
}

class ExerciseDetailSheet extends StatefulWidget {
  final ExerciseModel exercise;
  final String category;

  const ExerciseDetailSheet({super.key, required this.exercise, required this.category});

  @override
  State<ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<ExerciseDetailSheet> {
  VideoPlayerController? _ctrl;
  bool _ready = false;
  bool _error = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final url = widget.exercise.gifUrl;
    if (url == null || url.isEmpty) return;
    try {
      _ctrl = VideoPlayerController.asset(url);
      await _ctrl!.initialize();
      _ctrl!.setLooping(true);
      await _ctrl!.play();
      if (mounted) setState(() { _ready = true; _playing = true; });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_ctrl == null) return;
    setState(() {
      if (_ctrl!.value.isPlaying) {
        _ctrl!.pause();
        _playing = false;
      } else {
        _ctrl!.play();
        _playing = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            physics: const BouncingScrollPhysics(),
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: double.infinity,
                  height: 220,
                  color: Colors.black,
                  child: _buildPlayer(),
                ),
              ),
              const SizedBox(height: 24),
              Text(ex.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _tag(_diffLabel(ex.difficulty), _diffColor(ex.difficulty)),
                  _tag('🏋️ ${ex.equipment}', AppColors.primary),
                  _tag('🎯 ${widget.category}', Colors.purpleAccent),
                ],
              ),
              const SizedBox(height: 28),
              _sectionTitle('📋 Описание'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  ex.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                ),
              ),
              const SizedBox(height: 28),
              _sectionTitle('💡 Советы по технике'),
              const SizedBox(height: 12),
              ...(ex.tips.isNotEmpty ? ex.tips : _muscleTips[widget.category] ?? _muscleTips['Грудь']!).map(_tipTile),
              const SizedBox(height: 28),
              _sectionTitle('📊 Рекомендации'),
              const SizedBox(height: 12),
              _infoGrid(ex),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayer() {
    if (_error || (widget.exercise.gifUrl?.isEmpty ?? true)) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎬', style: TextStyle(fontSize: 48)),
            SizedBox(height: 8),
            Text('Видео недоступно', style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      );
    }
    if (!_ready) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _ctrl!.value.size.width,
                height: _ctrl!.value.size.height,
                child: VideoPlayer(_ctrl!),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _playing ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  String _diffLabel(String d) {
    switch (d) {
      case '1': return '⭐ Лёгкое';
      case '2': return '⭐⭐ Среднее';
      case '3': return '⭐⭐⭐ Тяжёлое';
      default: return d;
    }
  }

  Color _diffColor(String d) {
    switch (d) {
      case '1': return Colors.greenAccent;
      case '2': return Colors.orangeAccent;
      case '3': return Colors.redAccent;
      default: return Colors.white54;
    }
  }

  Widget _tag(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      );

  Widget _sectionTitle(String t) => Text(
        t,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
      );

  Widget _tipTile(String tip) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✅ ', style: TextStyle(fontSize: 16)),
            Expanded(
              child: Text(
                tip,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      );

  Widget _infoGrid(ExerciseModel ex) {
    final items = _recs(ex.difficulty);
    return Row(
      children: items
          .map((item) => Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    children: [
                      Text(item['emoji']!, style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 8),
                      Text(
                        item['value']!,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label']!,
                        style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  List<Map<String, String>> _recs(String d) {
    switch (d) {
      case '1':
        return [
          {'emoji': '🔁', 'value': '3–4', 'label': 'ПОДХОДЫ'},
          {'emoji': '🔢', 'value': '15–20', 'label': 'ПОВТОРЕНИЯ'},
          {'emoji': '⏱️', 'value': '60 сек', 'label': 'ОТДЫХ'}
        ];
      case '2':
        return [
          {'emoji': '🔁', 'value': '3–4', 'label': 'ПОДХОДЫ'},
          {'emoji': '🔢', 'value': '10–12', 'label': 'ПОВТОРЕНИЯ'},
          {'emoji': '⏱️', 'value': '90 сек', 'label': 'ОТДЫХ'}
        ];
      case '3':
        return [
          {'emoji': '🔁', 'value': '4–5', 'label': 'ПОДХОДЫ'},
          {'emoji': '🔢', 'value': '5–8', 'label': 'ПОВТОРЕНИЯ'},
          {'emoji': '⏱️', 'value': '2–3 мин', 'label': 'ОТДЫХ'}
        ];
      default:
        return [
          {'emoji': '🔁', 'value': '3', 'label': 'ПОДХОДЫ'},
          {'emoji': '🔢', 'value': '12', 'label': 'ПОВТОРЕНИЯ'},
          {'emoji': '⏱️', 'value': '90 сек', 'label': 'ОТДЫХ'}
        ];
    }
  }
}
