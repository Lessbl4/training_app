import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muscle_selector/muscle_selector.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';

class AnatomyScreen extends StatefulWidget {
  const AnatomyScreen({super.key});

  @override
  State<AnatomyScreen> createState() => _AnatomyScreenState();
}

class _AnatomyScreenState extends State<AnatomyScreen> {
  Set<Muscle>? selectedMuscles;
  final GlobalKey<MusclePickerMapState> _mapKey = GlobalKey();

  final Map<String, Map<String, dynamic>> _muscleInfo = {
    'chest': {
      'name': 'Грудные',
      'exercises': ['Жим штанги лёжа', 'Жим гантелей', 'Сведение в кроссовере', 'Отжимания на брусьях'],
    },
    'abs': {
      'name': 'Пресс',
      'exercises': ['Скручивания', 'Планка', 'Подъём ног в висе', 'Ролик для пресса'],
    },
    'glutes': {
      'name': 'Ягодицы',
      'exercises': ['Приседания', 'Ягодичный мост', 'Становая тяга', 'Болгарские выпады'],
    },
    'neck': {
      'name': 'Шея',
      'exercises': ['Наклоны головы', 'Мост борца', 'Шраги'],
    },
    'lower_back': {
      'name': 'Нижняя спина',
      'exercises': ['Гиперэкстензия', 'Становая тяга', 'Доброе утро'],
    },
    'biceps': {
      'name': 'Бицепс',
      'exercises': ['Подъём штанги', 'Молотковые сгибания', 'Подтягивания обратным хватом'],
    },
    'triceps': {
      'name': 'Трицепс',
      'exercises': ['Жим узким хватом', 'Французский жим', 'Разгибания на блоке'],
    },
    'shoulders': {
      'name': 'Плечи',
      'exercises': ['Жим гантелей сидя', 'Махи в стороны', 'Тяга к подбородку'],
    },
    'quadriceps': {
      'name': 'Квадрицепс',
      'exercises': ['Приседания', 'Жим ногами', 'Разгибания в тренажёре'],
    },
    'hamstrings': {
      'name': 'Бицепс бедра',
      'exercises': ['Румынская тяга', 'Сгибания ног', 'Доброе утро'],
    },
    'calves': {
      'name': 'Икры',
      'exercises': ['Подъёмы на носки стоя', 'Подъёмы на носки сидя'],
    },
    'upper_back': {
      'name': 'Верхняя спина',
      'exercises': ['Тяга штанги в наклоне', 'Подтягивания', 'Тяга блока'],
    },
  };

  String? get _selectedMuscleName {
    if (selectedMuscles == null || selectedMuscles!.isEmpty) return null;
    final id = selectedMuscles!.first.id;
    return _muscleInfo[id]?['name'] ?? id;
  }

  List<String> get _selectedExercises {
    if (selectedMuscles == null || selectedMuscles!.isEmpty) return [];
    final id = selectedMuscles!.first.id;
    return List<String>.from(_muscleInfo[id]?['exercises'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "АНАТОМИЯ 💪",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (selectedMuscles != null && selectedMuscles!.isNotEmpty)
            IconButton(
              icon: const Icon(CupertinoIcons.xmark_circle, color: AppColors.textSecondary),
              onPressed: () {
                _mapKey.currentState?.clearSelect();
                setState(() => selectedMuscles = null);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Силуэт тела
          Expanded(
            flex: 3,
            child: InteractiveViewer(
              scaleEnabled: true,
              panEnabled: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MusclePickerMap(
                  key: _mapKey,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.55,
                  map: Maps.BODY,
                  isEditing: false,
                  onChanged: (muscles) => setState(() => selectedMuscles = muscles),
                  actAsToggle: true,
                  dotColor: AppColors.primary,
                  selectedColor: AppColors.primary,
                  strokeColor: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // Нижняя панель
          if (selectedMuscles == null || selectedMuscles!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                "Нажми на мышцу чтобы увидеть упражнения",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            )
          else
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Row(
                            children: [
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _selectedMuscleName ?? '',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: AppColors.glassBorder, height: 1),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: _selectedExercises.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(CupertinoIcons.flame_fill, color: AppColors.primary, size: 16),
                                    const SizedBox(width: 12),
                                    Text(
                                      _selectedExercises[index],
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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