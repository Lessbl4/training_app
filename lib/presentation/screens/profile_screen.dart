import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:ui';

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
import 'package:training_app/presentation/screens/progress_update_screen.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final picker = ImagePicker();
  bool _isUploading = false;

  Future<void> pickImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 512, maxHeight: 512);
    if (img == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isUploading = true);

    try {
      final ref = FirebaseStorage.instance.ref().child('avatars/$uid.jpg');
      await ref.putFile(File(img.path));
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("users").doc(uid).update({"фото": downloadUrl});
    } catch (e) {
      debugPrint("Error uploading photo: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text("Профиль"), backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text("Пожалуйста, войдите, чтобы увидеть профиль.", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Мой Профиль 🦾", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.square_arrow_right, color: Colors.white),
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
            return const Center(child: CupertinoActivityIndicator(color: AppColors.primary));
          }
          if (!snap.hasData) {
            return const Center(child: Text("Не удалось загрузить данные.", style: TextStyle(color: Colors.white54)));
          }

          try {
            final user = snap.data!;
            final name = user.name ?? "Пользователь";
            final photoURL = user.photo ?? "";
            final heightValue = (user.height ?? 0.0).toDouble();
            final weightValue = (user.weight ?? 0.0).toDouble();
            final age = user.dateOfBirth == null ? 0 : DateTime.now().difference(user.dateOfBirth!).inDays ~/ 365;

            bool isProActive = user.isPro;
            int daysLeft = 0;
            if (isProActive && user.proExpiryDate != null) {
              daysLeft = user.proExpiryDate!.difference(DateTime.now()).inDays;
              if (daysLeft < 0) {
                isProActive = false;
                daysLeft = 0;
              }
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.horizontal, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- ВЕРХНЯЯ ЧАСТЬ: Аватар и Имя ---
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: pickImage,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      )
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: AppColors.surface,
                                    backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
                                    child: photoURL.isEmpty
                                        ? const Icon(CupertinoIcons.person_fill, size: 50, color: AppColors.primary)
                                        : null,
                                  ),
                                ),
                                if (_isUploading) const CircularProgressIndicator(color: AppColors.accent),
                                Positioned(
                                  bottom: 0,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.background, width: 3),
                                    ),
                                    child: const Icon(CupertinoIcons.camera_fill, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          isProActive ? _buildProBadge(daysLeft) : _buildFreeBadge(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- СТАТИСТИКА (Glassmorphism Карточки) ---
                    Row(
                      children: [
                        Expanded(child: _glassStatCard("Рост", heightValue.round().toString(), "см", CupertinoIcons.arrow_up_down)),
                        const SizedBox(width: 12),
                        Expanded(child: _glassStatCard("Вес", weightValue.round().toString(), "кг", CupertinoIcons.gauge)),
                        const SizedBox(width: 12),
                        Expanded(child: _glassStatCard("Возраст", age.toString(), "лет", CupertinoIcons.person_alt_circle)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BmiCard(height: heightValue, weight: weightValue), 
                    const SizedBox(height: 32),

                    // --- ПОДПИСКА PRO ---
                    _buildSubscriptionCard(context, isProActive, daysLeft, user.proExpiryDate),
                    const SizedBox(height: 40),

                    // --- НАСТРОЙКИ ---
                    const Text("НАСТРОЙКИ ⚙️", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    
                    _premiumSettingTile("Обновить показатели (Прогресс)", CupertinoIcons.graph_circle, AppColors.accent, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProgressUpdateScreen(currentWeight: weightValue)));
                    }),
                    _premiumSettingTile("Изменить имя", CupertinoIcons.person, Colors.white, () {
                      showGlassmorphicModal(
                        context: context,
                        builder: (context) => EditNameModal(
                          initialValue: name,
                          onSave: (val) => FirebaseFirestore.instance.collection('users').doc(uid).update({'имя': val}),
                        ),
                      );
                    }),
                    _premiumSettingTile("Изменить дату рождения", CupertinoIcons.calendar, Colors.white, () {
                      _showDatePicker(context, user.dateOfBirth, (date) {
                        FirebaseFirestore.instance.collection('users').doc(uid).update({'Дата рождения': date});
                      });
                    }),
                    _premiumSettingTile("Изменить рост", CupertinoIcons.arrow_up_down, Colors.white, () {
                      showGlassmorphicModal(
                        context: context,
                        builder: (context) => EditHeightModal(
                          initialValue: heightValue < 100.0 ? 170.0 : heightValue,
                          onSave: (val) => FirebaseFirestore.instance.collection('users').doc(uid).update({'высота': val}),
                        ),
                      );
                    }),
                    _premiumSettingTile("Изменить вес", CupertinoIcons.gauge, Colors.white, () {
                      showGlassmorphicModal(
                        context: context,
                        builder: (context) => EditWeightModal(
                          initialValue: weightValue < 30.0 ? 70.0 : weightValue,
                          onSave: (val) => FirebaseFirestore.instance.collection('users').doc(uid).update({'вес': val}),
                        ),
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          } catch (e, stackTrace) {
            debugPrint("Error building profile screen: $e\n$stackTrace");
            return const Center(child: Text("Ошибка загрузки профиля.", style: TextStyle(color: Colors.red)));
          }
        },
      ),
    );
  }

  Widget _glassStatCard(String label, String value, String unit, IconData icon) {
    return ClipRRect(
      borderRadius: AppBorderRadius.circularMedium,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: AppBorderRadius.circularMedium,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 4),
                  Text(unit, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumSettingTile(String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        onTap: () {
          SoundService.playClick();
          onTap();
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(CupertinoIcons.chevron_right, size: 18, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildFreeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(20)),
      child: const Text('BASE План', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildProBadge(int daysLeft) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFF97316)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.star_fill, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text('PRO ДОСТУП ($daysLeft ДН.)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, bool isProActive, int daysLeft, DateTime? proExpiryDate) {
    String formattedDate = isProActive && proExpiryDate != null ? DateFormat('dd.MM.yyyy').format(proExpiryDate) : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isProActive
            ? AppColors.primaryGradient
            : const LinearGradient(colors: [Color(0xFF27272A), Color(0xFF18181B)]),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: isProActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(isProActive ? CupertinoIcons.bolt_fill : CupertinoIcons.lock_fill, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isProActive ? 'PRO активна ещё $daysLeft дней' : 'Разблокируй Gymify PRO 🔥', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(isProActive ? 'Действует до $formattedDate.' : 'ИИ-тренер, аналитика и программы.', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              ),
            ],
          ),
          if (!isProActive) ...[
            const SizedBox(height: 24),
            CustomElevatedButton(
              text: 'Активировать за 1 490 ₸',
              onPressed: () {
                SoundService.playClick();
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (c) => _MockPaymentBottomSheet());
              },
            ),
          ]
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context, DateTime? initialDate, Function(DateTime) onSave) {
    DateTime selectedDate = initialDate ?? DateTime(DateTime.now().year - 13, DateTime.now().month, DateTime.now().day);
    const int minYear = 1950;
    final int maxYear = DateTime.now().year;

    showGlassmorphicModal(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final int currentAge = DateTime.now().year - selectedDate.year;
            final bool isOldEnough = currentAge >= 13;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(DateFormat("dd MMMM yyyy", "ru").format(selectedDate), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isOldEnough ? Colors.white : Colors.red)),
                const SizedBox(height: 8),
                Text("Ваш возраст: $currentAge лет", style: TextStyle(fontSize: 16, color: isOldEnough ? AppColors.textSecondary : Colors.red)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        // ИСПРАВЛЕНИЕ ТУТ: Размер шрифта 20, чтобы буквы не слипались
                        dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: selectedDate,
                      minimumYear: minYear,
                      maximumYear: maxYear,
                      onDateTimeChanged: (date) => setState(() => selectedDate = date),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: CustomElevatedButton(text: "Отмена", isPrimary: false, onPressed: () => Navigator.pop(context))),
                    const SizedBox(width: 16),
                    Expanded(child: CustomElevatedButton(text: "Сохранить", onPressed: isOldEnough ? () { onSave(selectedDate); Navigator.pop(context); } : null)),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// МОДАЛКА ОПЛАТЫ (ОСТАЛАСЬ БЕЗ ИЗМЕНЕНИЙ ЛОГИКИ, НО СТИЛИЗОВАНА ПОД НОВЫЙ ДИЗАЙН)
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
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), border: Border.all(color: AppColors.glassBorder)),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text('Оплата подписки 💳', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              const Text('Gymify PRO — 1 490 ₸ / месяц', style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextFormField(
                keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Номер карты', CupertinoIcons.creditcard),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), _CardNumberFormatter()],
                validator: (v) => (v != null && v.length < 19) ? 'Неверный номер' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _inputDeco('ММ/ГГ', CupertinoIcons.calendar), inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4), _CardDateFormatter()], validator: (v) => (v == null || v.length < 5) ? 'ММ/ГГ' : null)),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(keyboardType: TextInputType.number, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _inputDeco('CVV', CupertinoIcons.lock_fill), inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)], validator: (v) => (v != null && v.length < 3) ? 'Ошибка' : null)),
                ],
              ),
              const SizedBox(height: 32),
              CustomElevatedButton(
                text: 'Оплатить безопасно 🔒',
                isLoading: _isLoading,
                onPressed: _processPayment,
              ),
              const SizedBox(height: 12),
              const Text('Демонстрационный режим. Средства не списываются.', style: TextStyle(fontSize: 11, color: Colors.white38), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14), prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20), filled: true, fillColor: AppColors.background, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.glassBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error)), focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error)));

  void _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      await DatabaseService().updateUserProfile({'isPro': true, 'proExpiryDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30)))});
      if (!mounted) return;
      Navigator.pop(context); 
      HapticFeedback.vibrate(); SoundService.playNotify();
    }
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    if (newV.selection.baseOffset == 0) return newV;
    var b = StringBuffer();
    for (int i = 0; i < newV.text.length; i++) { b.write(newV.text[i]); if ((i + 1) % 4 == 0 && i + 1 != newV.text.length) b.write(' '); }
    return newV.copyWith(text: b.toString(), selection: TextSelection.collapsed(offset: b.length));
  }
}

class _CardDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    if (newV.selection.baseOffset == 0) return newV;
    var b = StringBuffer();
    for (int i = 0; i < newV.text.length; i++) { b.write(newV.text[i]); if ((i + 1) % 2 == 0 && i + 1 != newV.text.length) b.write('/'); }
    return newV.copyWith(text: b.toString(), selection: TextSelection.collapsed(offset: b.length));
  }
}                                   