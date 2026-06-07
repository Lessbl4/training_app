import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:training_app/presentation/theme/ui_constants.dart';
import 'package:training_app/widgets/custom_buttons.dart';

class CNSTestScreen extends StatefulWidget {
  const CNSTestScreen({super.key});

  @override
  State<CNSTestScreen> createState() => _CNSTestScreenState();
}

class _CNSTestScreenState extends State<CNSTestScreen> {
  bool _isRecording = false;
  bool _isTestFinished = false;
  double _stabilityScore = 0.0;
  double _timer = 10.0;
  
  Timer? _countdownTimer;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  
  final List<double> _tremorHistory = List.filled(100, 0.0, growable: true);
  double _totalTremor = 0;
  int _sampleCount = 0;
  double _currentTremor = 0.0;
  
  double _lastX = 0.0;
  double _lastY = 0.0;
  double _lastZ = 0.0;

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
      _timer = 10.0;
      _totalTremor = 0;
      _sampleCount = 0;
      _currentTremor = 0.0;
      _lastX = 0.0;
      _lastY = 0.0;
      _lastZ = 0.0;
      _tremorHistory.fillRange(0, _tremorHistory.length, 0.0);
    });

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        _timer -= 0.05;
        _tremorHistory.removeAt(0);
        _tremorHistory.add(_currentTremor);
        
        if (_timer <= 0) _stopTest();
      });
    });

    _accelSubscription = accelerometerEventStream().listen((event) {
      if (!_isRecording) return;
      
      if (_lastX == 0.0 && _lastY == 0.0 && _lastZ == 0.0) {
        _lastX = event.x;
        _lastY = event.y;
        _lastZ = event.z;
        return;
      }

      double delta = sqrt(pow(event.x - _lastX, 2) + pow(event.y - _lastY, 2) + pow(event.z - _lastZ, 2));
      
      _lastX = event.x;
      _lastY = event.y;
      _lastZ = event.z;

      _currentTremor = delta.clamp(0.0, 3.0);
      _totalTremor += _currentTremor;
      _sampleCount++;
    });
  }

 Future<void> _stopTest() async {
  _countdownTimer?.cancel();
  _accelSubscription?.cancel();
  HapticFeedback.vibrate();

  double avgTremor = _sampleCount > 0 ? _totalTremor / _sampleCount : 0;
  double score = (100 - (avgTremor * 60)).clamp(0, 100);

  setState(() {
    _isRecording = false;
    _isTestFinished = true;
    _stabilityScore = score;
  });

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    try {
      // Сначала добавляем результат в историю
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'cnsHistory': FieldValue.arrayUnion([score]),
        'cnsLastUpdate': FieldValue.serverTimestamp(),
      });

      // Читаем обновлённый документ и пересчитываем среднее
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final history = List<dynamic>.from(doc.data()?['cnsHistory'] ?? [score]);
      final avgScore = history.map((e) => (e as num).toDouble()).reduce((a, b) => a + b) / history.length;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'cnsScore': avgScore,
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

  Color _getStatusColor(double score) {
    if (score < 40) return AppColors.error;
    if (score < 75) return const Color(0xFFF59E0B);
    return AppColors.success;
  }

  String _getStatusText(double score) {
    if (score < 40) return "Высокое утомление";
    if (score < 75) return "ЦНС в норме";
    return "Идеальная готовность";
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _isRecording ? AppColors.accent : (_isTestFinished ? _getStatusColor(_stabilityScore) : AppColors.primary);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.horizontal, vertical: 20),
          child: Column(
            children: [
              const Text(
                "АНАЛИЗ ЦНС", 
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)
              ),
              const SizedBox(height: 20),
              
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
              
              const SizedBox(height: 40),

              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      boxShadow: [
                        BoxShadow(color: currentColor.withOpacity(0.15), blurRadius: 60, spreadRadius: 20)
                      ]
                    ),
                  ),
                  
                  if (_isRecording || !_isTestFinished)
                    ClipRect(
                      child: SizedBox(
                        height: 150, width: double.infinity,
                        child: CustomPaint(painter: TremorWavePainter(history: _tremorHistory, color: currentColor)),
                      ),
                    ),

                  if (_isTestFinished)
                    Column(
                      children: [
                        Text(
                          "${_stabilityScore.toInt()}%", 
                          style: TextStyle(
                            fontSize: 72, 
                            fontWeight: FontWeight.w900, 
                            color: currentColor, 
                            shadows: [Shadow(color: currentColor.withOpacity(0.5), blurRadius: 20)]
                          )
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getStatusText(_stabilityScore), 
                          textAlign: TextAlign.center, 
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              if (_isRecording)
                Text(
                  _timer.toStringAsFixed(1), 
                  style: const TextStyle(
                    fontSize: 48, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white, 
                    fontFeatures: [ui.FontFeature.tabularFigures()]
                  )
                ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds, color: AppColors.accent),

              const SizedBox(height: 40),

              CustomElevatedButton(
                text: _isRecording ? "Анализируем..." : (_isTestFinished ? "ПОВТОРИТЬ ТЕСТ" : "НАЧАТЬ ТЕСТ"),
                icon: _isRecording ? CupertinoIcons.waveform_path : CupertinoIcons.play_arrow_solid,
                isPrimary: !_isRecording,
                onPressed: _isRecording ? null : _startTest,
              ),
              
              const SizedBox(height: 120), 
            ],
          ),
        ),
      ),
    );
  }
}

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
    final centerY = size.height / 2;

    for (int i = 0; i < history.length; i++) {
      final x = i * widthStep;
      final yOffset = history[i] * 40; 
      final y = centerY + (i % 2 == 0 ? yOffset : -yOffset);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, glowPaint); 
    canvas.drawPath(path, paint);     
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}