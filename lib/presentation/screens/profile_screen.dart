import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:training_app/presentation/widgets/modals/glassmorphic_modal.dart';
import 'package:training_app/presentation/widgets/modals/edit_name_modal.dart';
import 'package:training_app/presentation/widgets/modals/edit_height_modal.dart';
import 'package:training_app/widgets/custom_buttons.dart';
import 'package:intl/intl.dart';

import 'package:training_app/services/sound_service.dart';
import 'package:training_app/models/user_model.dart';
import 'package:training_app/services/database_service.dart';
import 'package:training_app/presentation/widgets/profile/cns_card.dart';

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
  bool _isUploading = false;

  Future<void> pickImage() async {
    final img = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70, maxWidth: 512, maxHeight: 512);
    if (img == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final ref = FirebaseStorage.instance.ref().child('avatars/$uid.jpg');
      await ref.putFile(File(img.path));
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({"фото": downloadUrl});
    } catch (e) {
      debugPrint("Error uploading photo: $e");
    } finally {
      setState(() {
        _isUploading = false;
      });
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
            final photoURL = user.photo ?? "";
            final height = user.height ?? 0;

            final heightValue = height.toDouble();
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
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: pickImage,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 55,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  backgroundImage: photoURL.isNotEmpty
                                      ? NetworkImage(photoURL)
                                      : null,
                                  child: photoURL.isEmpty
                                      ? Icon(CupertinoIcons.person_fill,
                                          size: 50,
                                          color: theme.colorScheme.primary)
                                      : null,
                                ),
                                if (_isUploading)
                                  const CircularProgressIndicator(),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: theme.colorScheme.primary,
                                    child: const Icon(CupertinoIcons.camera_fill,
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
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: _statCard(
                          "Рост",
                          height.round().toString(),
                          "см",
                          CupertinoIcons.arrow_up_down,
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _statCard(
                          "Возраст",
                          age.toString(),
                          "лет",
                          CupertinoIcons.person_alt_circle,
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const CnsCard(),
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
                                .update({'имя': value});
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
                            .update({'Дата рождения': date});
                      });
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
                                .update({'высота': value});
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

}