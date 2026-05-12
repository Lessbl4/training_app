import 'package:flutter/material.dart';

class BmiCard extends StatelessWidget {
  final double height;
  final double weight;

  const BmiCard({super.key, required this.height, required this.weight});

  String get bmiStatus {
    if (height == 0 || weight == 0) return "Неизвестно";
    double bmi = weight / ((height / 100) * (height / 100));
    if (bmi < 18.5) return "Дефицит";
    if (bmi >= 18.5 && bmi < 25) return "Норма";
    if (bmi >= 25 && bmi < 30) return "Избыток";
    return "Ожирение";
  }

  List<Color> get gradientColors {
    switch (bmiStatus) {
      case "Ожирение":
        return [Colors.redAccent, Colors.red];
      case "Избыток":
        return [Colors.amberAccent, Colors.orange];
      case "Норма":
        return [Colors.greenAccent, Colors.green];
      case "Дефицит":
        return [Colors.lightBlueAccent, Colors.blue];
      default:
        return [Colors.grey, Colors.blueGrey];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2), // Толщина обводки
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: theme.cardColor, // Фон карточки
          borderRadius: BorderRadius.circular(14), // Скругление внутреннего контейнера
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(colors: colors),
                boxShadow: [
                  BoxShadow(
                    color: colors.last.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.speed, color: Colors.white, size: 24), // Заменил иконку
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Расчет ИМТ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(bmiStatus, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
