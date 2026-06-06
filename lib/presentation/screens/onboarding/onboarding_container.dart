import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:training_app/controllers/onboarding_controller.dart';
import 'package:training_app/models/user_model.dart';
import 'package:training_app/presentation/widgets/gymify_progress_bar.dart';
import 'package:training_app/presentation/screens/onboarding/activity_level_screen.dart';
import 'package:training_app/presentation/screens/onboarding/goal_selection_step.dart';
import 'package:training_app/presentation/screens/onboarding/height_screen.dart';
import 'package:training_app/presentation/screens/onboarding/weight_screen.dart';
import 'package:training_app/presentation/screens/onboarding/experience_screen.dart';
import 'package:training_app/presentation/screens/onboarding/dob_screen.dart';
import 'package:training_app/presentation/screens/onboarding/name_screen.dart';
import 'package:training_app/presentation/widgets/dialogs/custom_error_dialog.dart';
import 'package:training_app/presentation/screens/main_navigation.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';
import 'package:training_app/widgets/custom_buttons.dart';

class OnboardingContainer extends StatelessWidget {
  final UserModel? userModel;
  final int initialPage;
  final bool isEditing;

  const OnboardingContainer({super.key, this.userModel, this.initialPage = 0, this.isEditing = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingController(userModel: userModel, isEditing: isEditing)..pageController = PageController(initialPage: initialPage),
      child: const _OnboardingContent(),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. АБСТРАКТНЫЙ ПРЕМИУМ-ФОН 🔥
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=1470&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          // 2. ЗАТЕМНЕНИЕ И БЛЮР (ЧТОБЫ ТЕКСТ ЧИТАЛСЯ ИДЕАЛЬНО) 🌌
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withOpacity(0.7),
                      AppColors.background.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // 3. ОСНОВНОЙ КОНТЕНТ (Шаги + Кнопка)
          SafeArea(
            child: Column(
              children: [
                // Кастомный AppBar поверх всего
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: Row(
                    children: [
                      if (controller.pageIndex > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                          onPressed: controller.previousPage,
                        )
                      else
                        const SizedBox(width: 48), // Заглушка для центровки прогресс-бара
                      
                      Expanded(
                        child: GymifyProgressBar(
                          current: controller.pageIndex + 1,
                          total: 7,
                        ),
                      ),
                      const SizedBox(width: 48), // Заглушка для центровки
                    ],
                  ),
                ),

                // Сами экраны онбординга
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(), // Блокируем свайп руками
                    children: const [
                      NameScreen(),
                      DOBScreen(),
                      GoalSelectionStep(),
                      HeightScreen(),
                      WeightScreen(),
                      ExperienceScreen(),
                      ActivityLevelScreen(),
                    ],
                  ),
                ),

                // Кнопка навигации внизу
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppPadding.horizontal, 10, AppPadding.horizontal, 20),
                  child: CustomElevatedButton(
                    text: controller.isEditing ? "💾 СОХРАНИТЬ" : (controller.pageIndex == 6 ? "🚀 ЗАВЕРШИТЬ" : "ДАЛЕЕ ➡️"),
                    onPressed: controller.isNextButtonEnabled ? () async {
                      if (controller.pageIndex == 6) {
                        try {
                          await controller.finishOnboarding();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const MainNavigation()),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            builder: (context) => CustomErrorDialog(
                              title: 'Ошибка',
                              content: e.toString().replaceFirst('Exception: ', ''),
                            ),
                          );
                        }
                      } else {
                        controller.nextPage();
                      }
                    } : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}