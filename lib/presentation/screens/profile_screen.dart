import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';

import 'package:flutter/services.dart'; 
import 'package:glassmorphism/glassmorphism.dart'; 
import 'package:flutter_animate/flutter_animate.dart';

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
      return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Мой Профиль 🦾", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.square_arrow_right, color: AppColors.error),
            onPressed: () {
              SoundService.playNotify();
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData || snap.data == null || !snap.data!.exists) {
            return const Center(child: CupertinoActivityIndicator(color: AppColors.primary));
          }

          try {
            final data = snap.data!.data() as Map<String, dynamic>? ?? {};
            
            final name = data['имя'] ?? "Атлет";
            final photoURL = data['фото'] ?? "";
            final heightValue = (data['высота'] ?? 0.0).toDouble();
            final weightValue = (data['вес'] ?? 0.0).toDouble();
            
            int age = 0;
            if (data['Дата рождения'] != null) {
              DateTime dob = (data['Дата рождения'] as Timestamp).toDate();
              age = DateTime.now().difference(dob).inDays ~/ 365;
            }

            bool isProActive = data['isPro'] ?? false;
            int daysLeft = 0;
            if (isProActive && data['proExpiryDate'] != null) {
              DateTime expiry = (data['proExpiryDate'] as Timestamp).toDate();
              daysLeft = expiry.difference(DateTime.now()).inDays;
              if (daysLeft < 0) {
                isProActive = false;
                daysLeft = 0;
              }
            }

            // Получаем результат ЦНС из базы (если его еще нет, будет 0)
            final cnsScore = (data['cnsScore'] ?? 0.0).toDouble();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.horizontal, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- АВАТАР И ИМЯ ---
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
                                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: AppColors.surface,
                                    backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
                                    child: photoURL.isEmpty ? const Icon(CupertinoIcons.person_fill, size: 50, color: AppColors.primary) : null,
                                  ),
                                ),
                                if (_isUploading) const CircularProgressIndicator(color: AppColors.accent),
                                Positioned(
                                  bottom: 0,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 3)),
                                    child: const Icon(CupertinoIcons.camera_fill, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                          const SizedBox(height: 8),
                          isProActive ? _buildProBadge(daysLeft) : _buildFreeBadge(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- СПИДОМЕТР ЦНС ---
                    if (cnsScore > 0) ...[
                      const Text("СОСТОЯНИЕ ЦНС", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.5)),
                      const SizedBox(height: 16),
                      _buildCNSGauge(cnsScore),
                      const SizedBox(height: 32),
                    ],

                    // --- БАЗОВАЯ СТАТИСТИКА ---
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
                    _buildSubscriptionCard(context, isProActive, daysLeft, data['proExpiryDate'] != null ? (data['proExpiryDate'] as Timestamp).toDate() : null),
                    const SizedBox(height: 40),

                    // --- НАСТРОЙКИ ---
                    const Text("НАСТРОЙКИ ⚙️", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    
                    _premiumSettingTile("Обновить показатели", CupertinoIcons.graph_circle, AppColors.accent, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProgressUpdateScreen(currentWeight: weightValue)));
                    }),
                    _premiumSettingTile("Изменить имя", CupertinoIcons.person, Colors.white, () {
                      showGlassmorphicModal(
                        context: context,
                        builder: (context) => EditNameModal(initialValue: name, onSave: (val) => FirebaseFirestore.instance.collection('users').doc(uid).update({'имя': val})),
                      );
                    }),
                    _premiumSettingTile("Изменить дату рождения", CupertinoIcons.calendar, Colors.white, () {
                      _showDatePicker(context, data['Дата рождения'] != null ? (data['Дата рождения'] as Timestamp).toDate() : null, (date) {
                        FirebaseFirestore.instance.collection('users').doc(uid).update({'Дата рождения': date});
                      });
                    }),
                    _premiumSettingTile("Изменить рост", CupertinoIcons.arrow_up_down, Colors.white, () {
                      showGlassmorphicModal(
                        context: context,
                        builder: (context) => EditHeightModal(initialValue: heightValue < 100.0 ? 170.0 : heightValue, onSave: (val) => FirebaseFirestore.instance.collection('users').doc(uid).update({'высота': val})),
                      );
                    }),
                    _premiumSettingTile("Изменить вес", CupertinoIcons.gauge, Colors.white, () {
                      showGlassmorphicModal(
                        context: context,
                        builder: (context) => EditWeightModal(initialValue: weightValue < 30.0 ? 70.0 : weightValue, onSave: (val) => FirebaseFirestore.instance.collection('users').doc(uid).update({'вес': val})),
                      );
                    }),
                    const SizedBox(height: 120), // Отступ для парящей панели навигации
                  ],
                ),
              ),
            );
          } catch (e, stackTrace) {
            debugPrint("Error building profile: $e\n$stackTrace");
            return const Center(child: Text("Ошибка загрузки профиля.", style: TextStyle(color: Colors.red)));
          }
        },
      ),
    );
  }

  // --- КАСТОМНЫЙ ВИДЖЕТ СПИДОМЕТРА ЦНС ---
  Widget _buildCNSGauge(double score) {
    Color getStatusColor() {
      if (score < 40) return AppColors.error;
      if (score < 75) return const Color(0xFFF59E0B);
      return AppColors.success;
    }

    String getStatusText() {
      if (score < 40) return "Истощение / Перетрен";
      if (score < 75) return "Нормальная нагрузка";
      return "Оптимальная готовность";
    }

    return ClipRRect(
      borderRadius: AppBorderRadius.circularMedium,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: AppBorderRadius.circularMedium,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 120, // Высота полукруга
                width: 240,
                child: CustomPaint(
                  painter: CNSGaugePainter(score: score),
                ),
              ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 16),
              Text(
                "${score.toInt()}% - ${getStatusText()}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: getStatusColor()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassStatCard(String label, String value, String unit, IconData icon) {
    return ClipRRect(
      borderRadius: AppBorderRadius.circularMedium,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.glassBackground, borderRadius: AppBorderRadius.circularMedium, border: Border.all(color: AppColors.glassBorder)),
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
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.glassBorder)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        onTap: () { SoundService.playClick(); onTap(); },
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 22)),
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
        gradient: isProActive ? AppColors.primaryGradient : const LinearGradient(colors: [Color(0xFF27272A), Color(0xFF18181B)]),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: isProActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(isProActive ? CupertinoIcons.bolt_fill : CupertinoIcons.lock_fill, color: Colors.white, size: 24)),
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
    showGlassmorphicModal(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final int currentAge = DateTime.now().year - selectedDate.year;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(DateFormat("dd MMMM yyyy", "ru").format(selectedDate), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text("Ваш возраст: $currentAge лет", style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 20))),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: selectedDate,
                      minimumYear: 1950,
                      maximumYear: DateTime.now().year,
                      onDateTimeChanged: (date) => setState(() => selectedDate = date),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: CustomElevatedButton(text: "Отмена", isPrimary: false, onPressed: () => Navigator.pop(context))),
                    const SizedBox(width: 16),
                    Expanded(child: CustomElevatedButton(text: "Сохранить", onPressed: () { onSave(selectedDate); Navigator.pop(context); })),
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

// --- РЕНДЕРЕР СПИДОМЕТРА ---
class CNSGaugePainter extends CustomPainter {
  final double score;

  CNSGaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Фоновая серая дуга
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, pi, false, bgPaint);

    // Цветной градиент
    final gradientPaint = Paint()
  ..shader = ui.Gradient.sweep(
    center, // Первый аргумент — центр градиента (Offset)
    [AppColors.error, const Color(0xFFF59E0B), AppColors.success], // Цвета
    [0.0, 0.5, 1.0], // Стопы
    TileMode.clamp, // Режим заполнения (обязательный параметр)
    pi, // startAngle
    pi * 2, // endAngle
  ) // Метод .createShader(rect) здесь НЕ НУЖЕН, ui.Gradient.sweep уже возвращает Shader!
  ..style = PaintingStyle.stroke
  ..strokeWidth = 20
  ..strokeCap = StrokeCap.round;


    // Вычисляем длину дуги в зависимости от процента
    final sweepAngle = (score / 100) * pi;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, sweepAngle, false, gradientPaint);

    // Точка-индикатор на конце
    final dotAngle = pi + sweepAngle;
    final dotX = center.dx + radius * cos(dotAngle);
    final dotY = center.dy + radius * sin(dotAngle);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(dotX, dotY), 14, dotPaint);
    
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);
    canvas.drawCircle(Offset(dotX, dotY), 20, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CNSGaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}

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
              const SizedBox(height: 24),
              CustomElevatedButton(
                text: 'Оплатить безопасно 🔒',
                isLoading: _isLoading,
                onPressed: () async {
                  setState(() => _isLoading = true);
                  await Future.delayed(const Duration(seconds: 2));
                  await DatabaseService().updateUserProfile({'isPro': true, 'proExpiryDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30)))});
                  if (!context.mounted) return;
                  Navigator.pop(context); 
                  HapticFeedback.vibrate(); SoundService.playNotify();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}