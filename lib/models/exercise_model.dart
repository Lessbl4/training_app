import 'dart:convert';

class ExerciseModel {
  final String name;
  final String equipment;
  final String targetMuscle;
  final String difficulty;
  final String description;
  final List<String> tips;
  
  // Твои оригинальные поля (я их вернул!)
  final String? type;
  final String? gifUrl;
  final List<Map<String, double>>? sets;
  
  // Новые поля для персональных ИИ-тренировок
  final String? recommendedWeight;
  final String? recommendedReps;
  final String? recommendedRest;

  ExerciseModel({
    required this.name,
    required this.equipment,
    required this.targetMuscle,
    required this.difficulty,
    required this.description,
    this.type,
    this.gifUrl,
    this.sets,
    this.recommendedWeight,
    this.recommendedReps,
    this.recommendedRest,
    this.tips = const [],
  });

  ExerciseModel copyWith({
    String? name,
    String? equipment,
    String? targetMuscle,
    String? difficulty,
    String? description,
    String? type,
    String? gifUrl,
    List<Map<String, double>>? sets,
    String? recommendedWeight,
    String? recommendedReps,
    String? recommendedRest,
  }) {
    return ExerciseModel(
      name: name ?? this.name,
      equipment: equipment ?? this.equipment,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      type: type ?? this.type,
      gifUrl: gifUrl ?? this.gifUrl,
      sets: sets ?? this.sets,
      recommendedWeight: recommendedWeight ?? this.recommendedWeight,
      recommendedReps: recommendedReps ?? this.recommendedReps,
      recommendedRest: recommendedRest ?? this.recommendedRest,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'equipment': equipment,
      'target_muscle': targetMuscle,
      'difficulty': difficulty,
      'description': description,
      'type': type,
      'gif_url': gifUrl,
      'sets': sets,
      'recommendedWeight': recommendedWeight,
      'recommendedReps': recommendedReps,
      'recommendedRest': recommendedRest,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      name: map['name'] ?? '',
      equipment: map['equipment'] ?? '',
      targetMuscle: map['target_muscle'] ?? '',
      difficulty: map['difficulty'] is int ? map['difficulty'].toString() : (map['difficulty'] ?? ''),
      description: map['description'] ?? '',
      type: map['type'],
      gifUrl: map['gif_url'],
      sets: map['sets'] != null 
          ? List<Map<String, double>>.from(map['sets'].map((x) => Map<String, double>.from(x))) 
          : null,
      recommendedWeight: map['recommendedWeight'],
      recommendedReps: map['recommendedReps'],
      recommendedRest: map['recommendedRest'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ExerciseModel.fromJson(String source) => ExerciseModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ExerciseModel(name: $name, equipment: $equipment, targetMuscle: $targetMuscle, difficulty: $difficulty, description: $description, type: $type, gifUrl: $gifUrl, sets: $sets, recommendedWeight: $recommendedWeight, recommendedReps: $recommendedReps, recommendedRest: $recommendedRest)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ExerciseModel &&
      other.name == name &&
      other.equipment == equipment &&
      other.targetMuscle == targetMuscle &&
      other.difficulty == difficulty &&
      other.description == description &&
      other.type == type &&
      other.gifUrl == gifUrl &&
      other.recommendedWeight == recommendedWeight &&
      other.recommendedReps == recommendedReps &&
      other.recommendedRest == recommendedRest;
  }

  @override
  int get hashCode {
    return name.hashCode ^
      equipment.hashCode ^
      targetMuscle.hashCode ^
      difficulty.hashCode ^
      description.hashCode ^
      (type?.hashCode ?? 0) ^
      (gifUrl?.hashCode ?? 0) ^
      (recommendedWeight?.hashCode ?? 0) ^
      (recommendedReps?.hashCode ?? 0) ^
      (recommendedRest?.hashCode ?? 0);
  }
}