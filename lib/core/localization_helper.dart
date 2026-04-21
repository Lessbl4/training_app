String translateEquipment(String? equipment) {
  if (equipment == null) {
    return 'Нет данных';
  }
  switch (equipment.toLowerCase()) {
    case 'bodyweight':
      return 'Свой вес';
    case 'machine':
      return 'Тренажер';
    case 'barbell':
      return 'Штанга';
    case 'dumbbell':
      return 'Гантели';
    case 'cable':
      return 'Трос';
    case 'kettlebell':
      return 'Гиря';
    // Add more translations as needed
    default:
      return equipment;
  }
}
