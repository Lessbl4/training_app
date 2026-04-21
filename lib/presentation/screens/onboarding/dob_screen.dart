import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:training_app/controllers/onboarding_controller.dart';
import 'package:training_app/presentation/widgets/modals/glassmorphic_modal.dart';
import 'package:training_app/widgets/custom_buttons.dart';

class DOBScreen extends StatelessWidget {
  const DOBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<OnboardingController>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Когда вы родились?',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            CupertinoButton(
              onPressed: () => _showDatePicker(context, controller),
              child: Text(
                controller.userModel.dateOfBirth == null
                    ? 'Выберите дату'
                    : DateFormat('dd MMMM yyyy', 'ru').format(controller.userModel.dateOfBirth!),
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context, OnboardingController controller) {
    DateTime selectedDate = controller.userModel.dateOfBirth ?? DateTime(DateTime.now().year - 13, DateTime.now().month, DateTime.now().day);

    const int minYear = 1950;
    final int maxYear = DateTime.now().year;

    // Жестко ограничиваем начальную дату, чтобы избежать креша
    if (selectedDate.year < minYear) {
      selectedDate = DateTime(minYear);
    }
    if (selectedDate.year > maxYear) {
      selectedDate = DateTime(maxYear);
    }
    if (selectedDate.isAfter(DateTime.now())) {
      selectedDate = DateTime.now();
    }

    showGlassmorphicModal(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final int currentAge = _calculateAge(selectedDate);
            final bool isOldEnough = currentAge >= 13;

            void onDateChanged(DateTime newDate) {
              // Дополнительная валидация, чтобы избежать выхода за границы при скролле
              DateTime clampedDate = newDate;
              if (clampedDate.isAfter(DateTime.now())) {
                clampedDate = DateTime.now();
              }
              if (clampedDate.year < minYear) {
                clampedDate = DateTime(minYear, clampedDate.month, clampedDate.day);
              }

              setState(() {
                selectedDate = clampedDate;
              });
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat("dd MMMM yyyy", "ru").format(selectedDate),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isOldEnough ? null : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ваш возраст: $currentAge лет",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isOldEnough ? null : Colors.red,
                  ),
                ),
                if (!isOldEnough)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Регистрация доступна только с 13 лет",
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    minimumYear: minYear,
                    maximumYear: maxYear,
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: onDateChanged,
                    dateOrder: DatePickerDateOrder.dmy,
                  ),
                ),
                const SizedBox(height: 20),
                CustomElevatedButton(
                  text: "Подтвердить",
                  onPressed: isOldEnough
                      ? () {
                          controller.setDateOfBirth(selectedDate);
                          Navigator.pop(context);
                        }
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }
}
