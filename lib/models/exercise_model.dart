import 'dart:convert';

class ExerciseModel {
  final String? name;
  final String? targetMuscle;
  final String? equipment;
  final String? difficulty;
  final String? type;
  final String? gifUrl;
  final String? description;

  ExerciseModel({
    this.name,
    this.targetMuscle,
    this.equipment,
    this.difficulty,
    this.type,
    this.gifUrl,
    this.description,
  });

  ExerciseModel copyWith({
    String? name,
    String? targetMuscle,
    String? equipment,
    String? difficulty,
    String? type,
    String? gifUrl,
    String? description,
  }) {
    return ExerciseModel(
      name: name ?? this.name,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      gifUrl: gifUrl ?? this.gifUrl,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'target_muscle': targetMuscle,
      'equipment': equipment,
      'difficulty': difficulty,
      'type': type,
      'gif_url': gifUrl,
      'description': description,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      name: map['name'],
      targetMuscle: map['target_muscle'],
      equipment: map['equipment'],
      difficulty: map['difficulty'] is int ? map['difficulty'].toString() : map['difficulty'],
      type: map['type'],
      gifUrl: map['gif_url'],
      description: map['description'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ExerciseModel.fromJson(String source) => ExerciseModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ExerciseModel(name: $name, targetMuscle: $targetMuscle, equipment: $equipment, difficulty: $difficulty, type: $type, gifUrl: $gifUrl, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ExerciseModel &&
      other.name == name &&
      other.targetMuscle == targetMuscle &&
      other.equipment == equipment &&
      other.difficulty == difficulty &&
      other.type == type &&
      other.gifUrl == gifUrl &&
      other.description == description;
  }

  @override
  int get hashCode {
    return name.hashCode ^
      targetMuscle.hashCode ^
      equipment.hashCode ^
      difficulty.hashCode ^
      type.hashCode ^
      gifUrl.hashCode ^
      description.hashCode;
  }
}
