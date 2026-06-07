import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:training_app/presentation/theme/ui_constants.dart';
import 'package:training_app/widgets/custom_buttons.dart';

class CNSTestScreen extends StatefulWidget {
  const CNSTestScreen({super.key});

  @override
  State<CNSTestScreen> createState() => _CNSTestScreenState();
}

class _CNSTestScreenState extends State<CNSTestScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isTestFinished = false;
  double _stabilityScore = 0.0;
  double _timer = 10.0;
  
  Timer? _countdownTimer;
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  
  // Данные для графика и честного расчета
  final List<double> _tremorHistory = List.filled(100, 0.0); // Кольцевой буфер для графика
  double _totalTremor = 0;
  int _sampleCount = 0;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _accelSubscription?.cancel();
    super.dispose();
  }

  void _startTest() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = true;
      _isTestFinished = false;
      _stabilityScore = 0.0;
      _timer = 10.0;
      _totalTremor = 0;
      _sampleCount = 0;
      _tremorHistory.fillRange(0, _tremorHistory.length, 0.0);
    });

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _timer -= 0.1;
        if (_timer <= 0) _stopTest();
      });
    });

    // Читаем датчики без учета гравитации (только чистые движения руки)
    _accelSubscription = userAccelerometerEventStream().listen((event) {
      if (!_isRecording) return;
      
      // Вектор микровибраций
      double tremor = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
      
      _totalTremor += tremor;
      _sampleCount++;

      setState(() {
        _tremorHistory.removeAt(0);
        _tremorHistory.add(tremor);
      });
    });
  }

  Future<void> _stopTest() async {
    _countdownTimer?.cancel();
    _accelSubscription?.cancel();
    HapticFeedback.vibrate();

    // Алгоритм расчета (Tremor обычно от 0.05 до 2.0)
    double avgTremor = _sampleCount > 0 ? _totalTremor / _sampleCount : 0;
    // Если тремор 0.1 -> 100%. Если 1.5 -> 0%
    double score = (100 - ((avgTremor - 0.1) * 70)).clamp(0, 100);

    setState(() {
      _isRecording = false;
      _isTestFinished = true;
      _timer = 0.0;
      _stabilityScore = score;
    });

    // Сохраняем в Firebase для профиля
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'cnsScore': score,
          'cnsLastUpdate': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint("Ошибка сохранения ЦНС: $e");
      }
    }
  }

  Color _getStatusColor(double score) {
    if (score < 40) return AppColors.error;
    if (score < 75) return const Color(0xFFF59E0B); // Amber
    return AppColors.success;
  }

  String _getStatusText(double score) {
    if (score < 40) return "Сильное утомление. Снизь веса или отдохни.";
    if (score < 75) return "ЦНС в норме. Стандартная тренировка.";
    return "Идеально! Время бить рекорды 🚀";
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _isRecording ? AppColors.accent : (_isTestFinished ? _getStatusColor(_stabilityScore) : AppColors.primary);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Анализ ЦНС 🧠", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.horizontal, vertical: 20),
          child: Column(
            children: [
              // Стеклянная плашка с инструкцией
              ClipRRect(
                borderRadius: AppBorderRadius.circularMedium,
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: AppBorderRadius.circularMedium,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(CupertinoIcons.device_phone_portrait, color: Colors.white, size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Вытяни руку вперед и держи телефон максимально неподвижно 10 секунд.",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const Spacer(),

              // Живой график и результаты
              Stack(
                alignment: Alignment.center,
                children: [
                  // Неоновое свечение на фоне
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: currentColor.withOpacity(0.15), blurRadius: 60, spreadRadius: 20),
                      ],
                    ),
                  ),
                  
                  // Сам визуализатор
                  if (_isRecording || !_isTestFinished)
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: TremorWavePainter(history: _tremorHistory, color: currentColor),
                      ),
                    ),

                  // Результат
                  if (_isTestFinished)
                    Column(
                      children: [
                        Text(
                          "${_stabilityScore.toInt()}%",
                          style: TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: currentColor, shadows: [Shadow(color: currentColor.withOpacity(0.5), blurRadius: 20)]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getStatusText(_stabilityScore),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                ],
              ),
              
              const Spacer(),
              
              // Таймер
              if (_isRecording)
                Text(
                  _timer.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, fontFeatures: [ui.FontFeature.tabularFigures()]),
                ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds, color: AppColors.accent),

              const SizedBox(height: 40),

              CustomElevatedButton(
                text: _isRecording ? "Анализируем..." : (_isTestFinished ? "ПОВТОРИТЬ ТЕСТ" : "НАЧАТЬ ТЕСТ"),
                icon: _isRecording ? CupertinoIcons.waveform_path : CupertinoIcons.play_arrow_solid,
                isPrimary: !_isRecording,
                onPressed: _isRecording ? null : _startTest,
              ),
              
              // Защитный отступ для плавающей панели навигации
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// Кастомный рендерер живых волн тремора (SpaceX стиль)
class TremorWavePainter extends CustomPainter {
  final List<double> history;
  final Color color;

  TremorWavePainter({required this.history, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);

    final path = Path();
    final widthStep = size.width / (history.length - 1);
    
    // Базовая линия - центр
    final centerY = size.height / 2;

    for (int i = 0; i < history.length; i++) {
      final x = i * widthStep;
      // Увеличиваем масштаб колебаний для наглядности
      final yOffset = history[i] * 40; 
      // Чередуем вверх/вниз для красивой волны
      final y = centerY + (i % 2 == 0 ? yOffset : -yOffset);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Плавная кривая
        final prevX = (i - 1) * widthStep;
        final prevYOffset = history[i - 1] * 40;
        final prevY = centerY + ((i - 1) % 2 == 0 ? prevYOffset : -prevYOffset);
        
        path.quadraticBezierTo(
          prevX + widthStep / 2, prevY, 
          x, y,
        );
      }
    }

    canvas.drawPath(path, glowPaint); // Рисуем неоновое свечение
    canvas.drawPath(path, paint);     // Рисуем саму линию
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}