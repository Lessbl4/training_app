import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:fl_chart/fl_chart.dart';

class CNSTestScreen extends StatefulWidget {
  const CNSTestScreen({super.key});

  @override
  State<CNSTestScreen> createState() => _CNSTestScreenState();
}

class _CNSTestScreenState extends State<CNSTestScreen> {
  List<FlSpot> _spots = [];
  bool _isRecording = false;
  double _stabilityScore = 0.0;
  double _timer = 10.0;
  Timer? _countdownTimer;
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  double _totalTremor = 0;
  int _sampleCount = 0;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _accelSubscription?.cancel();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _spots.clear();
      _isRecording = true;
      _stabilityScore = 0.0;
      _timer = 10.0;
      _totalTremor = 0;
      _sampleCount = 0;
    });

    final startTime = DateTime.now();

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _timer -= 0.1;
        if (_timer <= 0) {
          _stopTest();
        }
      });
    });

    _accelSubscription = userAccelerometerEventStream().listen((event) {
      if (!_isRecording || !mounted) return;
      
      double tremor = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
      _totalTremor += tremor;
      _sampleCount++;
      
      // Вычисляем реальное прошедшее время в секундах для точной оси X
      double elapsedSeconds = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
      
      // Защита от краша fl_chart: X должен строго возрастать
      if (_spots.isNotEmpty && elapsedSeconds <= _spots.last.x) return;

      setState(() {
        _spots.add(FlSpot(elapsedSeconds, tremor));
      });
    });
  }

  void _stopTest() {
    _countdownTimer?.cancel();
    _accelSubscription?.cancel();

    double avgTremor = _sampleCount > 0 ? _totalTremor / _sampleCount : 0;
    // Формула перевода: средний тремор 0 = 100%, тремор 3.0 и выше = 0%
    double score = 100 - (avgTremor * 33);
    if (score < 0) score = 0;
    if (score > 100) score = 100;

    setState(() {
      _isRecording = false;
      _timer = 0.0;
      _stabilityScore = score;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Анализ ЦНС",
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "Вытяните руку и держите телефон параллельно полу максимально ровно.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 10,
                  minY: 0,
                  maxY: 15, // Фиксируем высоту графика, чтобы не было диких прыжков
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      // Защита от mostLeftSpot: если точек < 2, отдаем невидимую прямую
                      spots: _spots.length < 2 ? const [FlSpot(0, 0), FlSpot(10, 0)] : _spots,
                      isCurved: true,
                      color: Colors.cyanAccent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.cyanAccent.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (!_isRecording && _stabilityScore > 0)
              Column(
                children: [
                  Text(
                    "${_stabilityScore.toStringAsFixed(1)}%",
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                  ),
                  Text(
                    _stabilityScore > 85 ? "Отличная стабильность. Готов к рекордам!" : "Высокий тремор. Снизь рабочие веса.",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            if (_isRecording)
              Text(
                _timer.toStringAsFixed(1),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.cyan]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!_isRecording)
                    BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isRecording ? null : _startTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _isRecording ? "Анализ..." : "Начать тест (10 сек)",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}