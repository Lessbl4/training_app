import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:training_app/controllers/onboarding_controller.dart';
import 'package:training_app/presentation/widgets/modals/glassmorphic_modal.dart';
import 'package:training_app/widgets/custom_buttons.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';

class DOBScreen extends StatelessWidget {
  const DOBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.horizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Когда ты\nродился? 🎂",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
          ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          const Text(
            "Возраст нужен для расчета нагрузки и отдыха.",
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
          
          const Spacer(),
          Center(
            child: GestureDetector(
              onTap: () => _showDatePicker(context, controller),
              child: ClipRRect(
                borderRadius: AppBorderRadius.circularMedium,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: AppBorderRadius.circularMedium,
                      border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.calendar, color: AppColors.primary, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          controller.userModel.dateOfBirth == null
                              ? 'ВЫБРАТЬ ДАТУ'
                              : DateFormat('dd MMMM yyyy', 'ru').format(controller.userModel.dateOfBirth!),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fade(delay: 400.ms).scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOutBack),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context, OnboardingController controller) {
    DateTime selectedDate = controller.userModel.dateOfBirth ?? DateTime(DateTime.now().year - 13, DateTime.now().month, DateTime.now().day);
    const int minYear = 1950;
    final int maxYear = DateTime.now().year;

    if (selectedDate.year < minYear) selectedDate = DateTime(minYear);
    if (selectedDate.year > maxYear) selectedDate = DateTime(maxYear);
    if (selectedDate.isAfter(DateTime.now())) selectedDate = DateTime.now();

    showGlassmorphicModal(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final int currentAge = _calculateAge(selectedDate);
            final bool isOldEnough = currentAge >= 13;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat("dd MMMM yyyy", "ru").format(selectedDate),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isOldEnough ? Colors.white : Colors.red),
                ),
                const SizedBox(height: 8),
                Text("Ваш возраст: $currentAge лет", style: TextStyle(fontSize: 16, color: isOldEnough ? AppColors.textSecondary : Colors.red)),
                if (!isOldEnough)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text("Регистрация доступна только с 13 лет 🚫", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: 20),
                
                // ИСПРАВЛЕННЫЙ БАРАБАН (Размер шрифта 20, чтобы буквы не наезжали)
                SizedBox(
                  height: 200,
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 20), // ВАЖНО: 20px, а не 24!
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: selectedDate,
                      minimumYear: minYear,
                      maximumYear: maxYear,
                      maximumDate: DateTime.now(),
                      onDateTimeChanged: (newDate) {
                        DateTime clampedDate = newDate;
                        if (clampedDate.isAfter(DateTime.now())) clampedDate = DateTime.now();
                        if (clampedDate.year < minYear) clampedDate = DateTime(minYear, clampedDate.month, clampedDate.day);
                        setState(() => selectedDate = clampedDate);
                      },
                      dateOrder: DatePickerDateOrder.dmy,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomElevatedButton(
                  text: "✅ ПОДТВЕРДИТЬ",
                  onPressed: isOldEnough ? () {
                    controller.setDateOfBirth(selectedDate);
                    Navigator.pop(context);
                  } : null,
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
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) age--;
    return age < 0 ? 0 : age;
  }
}