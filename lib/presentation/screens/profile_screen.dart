import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:training_app/presentation/widgets/modals/glassmorphic_modal.dart';
import 'package:training_app/presentation/widgets/modals/edit_name_modal.dart';
import 'package:training_app/presentation/widgets/modals/edit_weight_modal.dart';
import 'package:training_app/presentation/widgets/modals/edit_height_modal.dart';
import 'package:training_app/widgets/custom_buttons.dart';
import 'package:intl/intl.dart';

import 'package:training_app/services/sound_service.dart';
import 'package:training_app/models/user_model.dart';
import 'package:training_app/services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({"photo": img.path});
    } catch (e) {
      debugPrint("Error updating photo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Профиль")),
        body: const Center(
          child: Text("Пожалуйста, войдите, чтобы увидеть профиль."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Профиль"),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.square_arrow_right),
            onPressed: () {
              SoundService.playNotify();
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<UserModel>(
        stream: DatabaseService().getUserStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (!snap.hasData) {
            return const Center(
                child: Text("Не удалось загрузить данные пользователя."));
          }

          try {
            final user = snap.data!;
            final name = user.name ?? "Пользователь";
            final photoURL = user.photoURL ?? "";
            final weight = user.weight ?? 0;
            final height = user.height ?? 0;

            final weightValue = weight.toDouble();
            final heightValue = height.toDouble();
            final bmi = _calculateBmi(weightValue, heightValue);
            final age = user.dateOfBirth == null
                ? 0
                : DateTime.now().difference(user.dateOfBirth!).inDays ~/ 365;

            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: <Widget>[
                          _buildLevelBadge(user.level),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: pickImage,
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 2),
                                  ),
                                  child: Hero(
                                    tag: 'profile_avatar',
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundColor: theme
                                          .colorScheme.surfaceContainerHighest,
                                      child: photoURL.isNotEmpty
                                          ? ClipOval(
                                              child: Image.network(
                                                photoURL,
                                                fit: BoxFit.cover,
                                                width: 110,
                                                height: 110,
                                                loadingBuilder:
                                                    (context, child, progress) {
                                                  return progress == null
                                                      ? child
                                                      : const Center(
                                                          child:
                                                              CupertinoActivityIndicator());
                                                },
                                                errorBuilder:
                                                    (context, error, stackTrace) {
                                                  return Icon(
                                                      CupertinoIcons.person_fill,
                                                      size: 50,
                                                      color: theme
                                                          .colorScheme.primary);
                                                },
                                              ),
                                            )
                                          : Icon(CupertinoIcons.person_fill,
                                              size: 50,
                                              color: theme.colorScheme.primary),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: theme.colorScheme.primary,
                                    child: const Icon(
                                        CupertinoIcons.camera_fill,
                                        size: 16,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(name,
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _bmiCard(bmi),
                    const SizedBox(height: 30),
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: _statCard(
                          "Вес",
                          weight.round().toString(),
                          "кг",
                          CupertinoIcons.gauge,
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _statCard(
                          "Рост",
                          height.round().toString(),
                          "см",
                          CupertinoIcons.arrow_up_down,
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: _statCard(
                          "Возраст",
                          age.toString(),
                          "лет",
                          CupertinoIcons.person_alt_circle,
                        )),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "НАСТРОЙКИ",
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(153),
                            letterSpacing: 1.2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _settingTile("Изменить имя", CupertinoIcons.person, () {
                      showGlassmorphicModal(
                        context: context,
                        builder: (context) => EditNameModal(
                          initialValue: name,
                          onSave: (value) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({'name': value});
                          },
                        ),
                      );
                    }),
                    _settingTile(
                        "Изменить дату рождения", CupertinoIcons.calendar, () {
                      _showDatePicker(context, user.dateOfBirth, (date) {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .update({'dateOfBirth': date});
                      });
                    }),
                    _settingTile("Изменить вес", CupertinoIcons.gauge, () {
                      showGlassmorphicModal(
                        context: context,
                        builder: (context) => EditWeightModal(
                          initialValue: weightValue,
                          onSave: (value) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({'weight': value});
                          },
                        ),
                      );
                    }),
                    _settingTile(
                        "Изменить рост", CupertinoIcons.arrow_up_down, () {
                      showGlassmorphicModal(
                        context: context,
                        builder: (context) => EditHeightModal(
                          initialValue: heightValue,
                          onSave: (value) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({'height': value});
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          } catch (e, stackTrace) {
            debugPrint("Error building profile screen: $e\n$stackTrace");
            return const Center(child: Text("Ошибка загрузки профиля."));
          }
        },
      ),
    );
  }

  double _calculateBmi(double weight, double height) {
    if (height <= 0) return 0.0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  Map<String, dynamic> _getBmiDetails(double bmi) {
    if (bmi < 18.5) {
      return {"status": "Дефицит массы", "color": Colors.yellow.shade600};
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      return {"status": "Норма", "color": Colors.green.shade500};
    } else if (bmi >= 25.0 && bmi <= 29.9) {
      return {"status": "Избыточный вес", "color": Colors.yellow.shade600};
    } else {
      return {"status": "Ожирение", "color": Colors.red.shade500};
    }
  }

  Widget _bmiCard(double bmi) {
    final theme = Theme.of(context);
    final bmiDetails = _getBmiDetails(bmi);
    final status = bmiDetails["status"];
    final color = bmiDetails["color"];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((255 * 0.3).round()),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Индекс массы тела (ИМТ)",
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 5),
              Text(
                status,
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
              ),
            ],
          ),
          Text(
            bmi.toStringAsFixed(1),
            style: theme.textTheme.displaySmall
                ?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, String unit, IconData icon) {
    final theme = Theme.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(178))),
        const SizedBox(height: 2),
        Text(value,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        if (unit.isNotEmpty)
          Text(unit,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(178))),
      ],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 15),
            content,
          ],
        ),
      ),
    );
  }

  void _showDatePicker(
      BuildContext context, DateTime? initialDate, Function(DateTime) onSave) {
    DateTime selectedDate = initialDate ??
        DateTime(DateTime.now().year - 13, DateTime.now().month,
            DateTime.now().day);

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
                clampedDate =
                    DateTime(minYear, clampedDate.month, clampedDate.day);
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
                      style:
                          theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        text: "Отмена",
                        onPressed: () => Navigator.pop(context),
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomElevatedButton(
                        text: "Сохранить",
                        onPressed: isOldEnough
                            ? () {
                                onSave(selectedDate);
                                Navigator.pop(context);
                              }
                            : null,
                      ),
                    ),
                  ],
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
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  Widget _settingTile(String title, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    final theme = Theme.of(context);
    final color =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
          SoundService.playClick();
          onTap();
        },
        leading: Icon(icon, color: color.withAlpha(204)),
        title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(color: color)),
        trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
      ),
    );
  }

  Widget _buildLevelBadge(int level) {
    String badgeName;
    Color badgeColor;
    IconData badgeIcon;

    if (level < 5) {
      badgeName = "Новичок";
      badgeColor = Colors.green;
      badgeIcon = CupertinoIcons.star;
    } else if (level < 10) {
      badgeName = "Атлет";
      badgeColor = Colors.blue;
      badgeIcon = CupertinoIcons.star_fill;
    } else {
      badgeName = "Мастер";
      badgeColor = Colors.purple;
      badgeIcon = CupertinoIcons.shield_fill;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: badgeColor.withAlpha((255 * 0.2).round()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: badgeColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(badgeIcon, color: badgeColor, size: 20),
              const SizedBox(width: 8),
              Text(badgeName,
                  style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text("Уровень $level", style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (level % 5) / 5, // Прогресс до следующего уровня
          backgroundColor: Colors.grey.shade700,
          valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
        ),
      ],
    );
  }
}
