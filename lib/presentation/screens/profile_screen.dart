import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:flutter/services.dart'; 
import 'package:glassmorphism/glassmorphism.dart'; 

import 'package:training_app/presentation/widgets/modals/glassmorphic_modal.dart';
import 'package:training_app/presentation/widgets/modals/edit_name_modal.dart';
import 'package:training_app/presentation/widgets/modals/edit_height_modal.dart';
import 'package:training_app/presentation/widgets/modals/edit_weight_modal.dart';
import 'package:training_app/widgets/custom_buttons.dart';
import 'package:intl/intl.dart';

import 'package:training_app/services/sound_service.dart';
import 'package:training_app/models/user_model.dart';
import 'package:training_app/services/database_service.dart';
import 'package:training_app/presentation/widgets/profile/bmi_card.dart';

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
            final height = user.height ?? 0.0;
            final weight = user.weight ?? 0.0;

            final heightValue = height.toDouble();
            final weightValue = weight.toDouble();
            final age = user.dateOfBirth == null
                ? 0
                : DateTime.now().difference(user.dateOfBirth!).inDays ~/ 365;

            // Логика проверки подписки из Базы Данных
            bool isProActive = user.isPro;
            int daysLeft = 0;
            
            if (isProActive && user.proExpiryDate != null) {
              daysLeft = user.proExpiryDate!.difference(DateTime.now()).inDays;
              // Если дни ушли в минус, подписка истекла (можно дополнительно триггерить обнуление в БД)
              if (daysLeft < 0) {
                isProActive = false;
                daysLeft = 0;
              }
            }

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
                          const SizedBox(height: 8),
                          // БЕЙДЖ ПОДПИСКИ
                          isProActive ? _buildProBadge(daysLeft) : _buildFreeBadge(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: _statCard(
                          "Рост",
                          heightValue.round().toString(),
                          "см",
                          CupertinoIcons.arrow_up_down,
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _statCard(
                          "Вес", 
                          weightValue.round().toString(),
                          "кг",
                          CupertinoIcons.gauge,
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
                    BmiCard(height: heightValue, weight: weightValue),
                    const SizedBox(height: 24),
                    
                    // КАРТОЧКА ПОДПИСКИ
                    _buildSubscriptionCard(context, isProActive, daysLeft, user.proExpiryDate),
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
                          initialValue: heightValue < 100.0 ? 170.0 : heightValue,
                          onSave: (value) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({'высота': value});
                          },
                        ),
                      );
                    }),
                    _settingTile(
                        "Изменить вес", CupertinoIcons.gauge, () {
                      showGlassmorphicModal(
                        context: context,
                        builder: (context) => EditWeightModal(
                          initialValue: weightValue < 30.0 ? 70.0 : weightValue,
                          onSave: (value) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({'вес': value});
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
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(200),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unit.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      unit,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(178),
                      ),
                    ),
                  ),
              ],
            ),
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

  Widget _settingTile(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
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

  // === МЕТОДЫ ПОДПИСКИ ===

  Widget _buildFreeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'BASE План',
        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProBadge(int daysLeft) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.orangeAccent],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.star_fill, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            'PRO ДОСТУП ($daysLeft ДН.)',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, bool isProActive, int daysLeft, DateTime? proExpiryDate) {
    String formattedDate = '';
    if (isProActive && proExpiryDate != null) {
      formattedDate = DateFormat('dd.MM.yyyy').format(proExpiryDate);
    }

    return GlassmorphicContainer(
      width: double.infinity,
      height: 160,
      borderRadius: 24,
      blur: 15,
      alignment: Alignment.center,
      border: 1.5,
      linearGradient: LinearGradient(
        colors: isProActive 
          ? [Colors.purple.shade800.withOpacity(0.6), Colors.indigo.shade900.withOpacity(0.6)]
          : [Colors.grey.shade900.withOpacity(0.7), Colors.black.withOpacity(0.7)],
      ),
      borderGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isProActive ? 'PRO активна ещё $daysLeft дней' : 'Разблокируйте все возможности',
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isProActive 
                          ? 'Все премиум функции разблокированы.\nДействует до $formattedDate.' 
                          : 'ИИ-тренер, аналитика и готовые программы.',
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isProActive) ...[
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    SoundService.playClick();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return _MockPaymentBottomSheet();
                      },
                    );
                  },
                  child: const Text('Активировать PRO за 1 490 ₸', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

// === КЛАСС ДЛЯ ПЛАТЕЖНОЙ ШТОРКИ ===

class _MockPaymentBottomSheet extends StatefulWidget {
  @override
  State<_MockPaymentBottomSheet> createState() => _MockPaymentBottomSheetState();
}

class _MockPaymentBottomSheetState extends State<_MockPaymentBottomSheet> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Оплата подписки',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Gymify PRO — 1 490 ₸ / месяц',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              TextFormField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Номер карты', CupertinoIcons.creditcard),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                validator: (v) => (v != null && v.length < 19) ? 'Неверный номер карты' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('ММ/ГГ', CupertinoIcons.calendar),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _CardDateFormatter(),
                      ],
                      // СТРОГАЯ ВАЛИДАЦИЯ ДАТЫ
                      validator: (v) {
                        if (v == null || v.length < 5) return 'ММ/ГГ';
                        final parts = v.split('/');
                        if (parts.length != 2) return 'Ошибка';
                        
                        final month = int.tryParse(parts[0]);
                        final year = int.tryParse(parts[1]);
                        
                        if (month == null || year == null) return 'Ошибка';
                        if (month < 1 || month > 12) return 'Месяц (1-12)';
                        
                        final now = DateTime.now();
                        final currentYear = now.year % 100; // например, 26 для 2026
                        final currentMonth = now.month;

                        if (year < currentYear) return 'Карта истекла';
                        if (year == currentYear && month < currentMonth) return 'Карта истекла';
                        
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('CVV', CupertinoIcons.lock_fill),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3), 
                      ],
                      validator: (v) => (v != null && v.length < 3) ? 'Ошибка' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoading ? null : _processPayment,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Оплатить безопасно',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Демонстрационный режим оплаты. Средства не списываются.',
                style: TextStyle(fontSize: 11, color: Colors.white38),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.blueAccent)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent)),
    );
  }

  void _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      // Записываем покупку в Firebase Firestore!
      final newExpiry = DateTime.now().add(const Duration(days: 30));
      await DatabaseService().updateUserProfile({
        'isPro': true,
        'proExpiryDate': Timestamp.fromDate(newExpiry),
      });

      if (!mounted) return;
      
      Navigator.pop(context); 

      HapticFeedback.vibrate();
      SoundService.playNotify();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.grey.shade900,
          title: const Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Оплата успешна!'),
            ],
          ),
          content: const Text('Добро пожаловать в Gymify PRO. Все ограничения сняты.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отлично', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        ),
      );
    }
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class _CardDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}