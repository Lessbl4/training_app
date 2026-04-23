import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:training_app/controllers/onboarding_controller.dart';
import 'package:training_app/models/user_model.dart';
import 'package:training_app/presentation/widgets/gymify_progress_bar.dart';
import 'package:training_app/presentation/screens/onboarding/activity_level_screen.dart';


import 'package:training_app/presentation/screens/onboarding/goal_selection_step.dart';
import 'package:training_app/presentation/screens/onboarding/height_screen.dart';
import 'package:training_app/presentation/screens/onboarding/experience_screen.dart';
import 'package:training_app/presentation/screens/onboarding/dob_screen.dart';
import 'package:training_app/presentation/screens/onboarding/name_screen.dart';
import 'package:training_app/presentation/widgets/dialogs/custom_error_dialog.dart';
import 'package:training_app/presentation/screens/main_navigation.dart';

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
      appBar: AppBar(
        leading: controller.pageIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.previousPage,
              )
            : null,
        title: GymifyProgressBar(
          current: controller.pageIndex + 1,
          total: 6,
        ),
      ),
       body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          NameScreen(),
          DOBScreen(),
          GoalSelectionStep(),
          HeightScreen(),
          ExperienceScreen(),
          ActivityLevelScreen(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
onPressed: controller.isNextButtonEnabled ? () async {
              if (controller.pageIndex == 5) {
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
          child: Text(controller.isEditing ? "Сохранить" : (controller.pageIndex == 5 ? "Завершить" : "Далее")),
        ),
      ),
    );
  }
}
