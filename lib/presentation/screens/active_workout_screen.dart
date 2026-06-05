import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:training_app/models/exercise_model.dart';
import 'package:training_app/services/sound_service.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final String title;
  final List<ExerciseModel> exercises;

  const ActiveWorkoutScreen({super.key, required this.title, required this.exercises});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  
  late List<int> _totalSetsCount;
  late List<int> _completedSetsCount;
  
  // Состояния отдыха и ЦНС
  bool _isResting = false;
  int _restSeconds = 0;
  int _initialRestSeconds = 0;
  Timer? _restTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _completedSetsCount = List.filled(widget.exercises.length, 0);
    _totalSetsCount = widget.exercises.map((ex) {
      if (ex.recommendedReps != null) {
        final parts = ex.recommendedReps!.split(' ');
        if (parts.isNotEmpty) return int.tryParse(parts[0]) ?? 4;
      }
      return 4;
    }).toList();
  }

  // --- ЛОГИКА ТАЙМЕРА И ОТДЫХА ---

  // Форматирование времени в мм:сс
  String get _formattedTime {
    int m = _restSeconds ~/ 60;
    int s = _restSeconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  void _startRestTimer(int defaultSeconds) {
    setState(() {
      _isResting = true;
      _initialRestSeconds = defaultSeconds;
      _restSeconds = defaultSeconds;
    });
    
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds > 0) {
        setState(() => _restSeconds--);
      } else {
        timer.cancel();
        SoundService.playNotify();
      }
    });
  }

  void _stopRestPhase() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSeconds = 0;
    });
  }

  void _addExtraRest(int seconds) {
    setState(() {
      _restSeconds += seconds;
      _initialRestSeconds += seconds; // Чтобы кольцо не сломалось
    });
    // Если таймер стоял, запускаем снова
    if (_restTimer == null || !_restTimer!.isActive) {
      _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_restSeconds > 0) {
          setState(() => _restSeconds--);
        } else {
          timer.cancel();
          SoundService.playNotify();
        }
      });
    }
  }

  void _completeSet(int defaultRest) {
    if (_completedSetsCount[_currentPage] < _totalSetsCount[_currentPage]) {
      setState(() {
        _completedSetsCount[_currentPage]++;
      });
      // Если упражнение закончено, все равно требуем отдых и тест перед следующим
      _startRestTimer(defaultRest);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _restTimer?.cancel();
    super.dispose();
  }

  void _finishWorkout() {
    SoundService.playNotify();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 Тренировка завершена! Отличная работа!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Сдаешься? 🥺', style: TextStyle(color: Colors.white)),
        content: const Text('Весь прогресс текущей тренировки будет потерян.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Нет, продолжить', style: TextStyle(color: Colors.blueAccent))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Да, выйти', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    ) ?? false;
  }

  // --- ЛОГИКА ЦНС ---
  Future<void> _showCNSModal() async {
    double? resultScore = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75, // 75% экрана
        child: const CNSModalContent(),
      ),
    );

    if (resultScore != null) {
      if (resultScore >= 80) {
        // Успех! ЦНС восстановлена
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ ЦНС в норме! Можно продолжать."), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
        );
        _stopRestPhase(); // Убираем таймер, возвращаем кнопку
      } else {
        // Провал! ЦНС перегружена
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Высокий тремор! Добавлено 30 сек отдыха."), backgroundColor: Colors.redAccent, duration: Duration(seconds: 3)),
        );
        _addExtraRest(30);
      }
    }
  }

  // --- UI ЭЛЕМЕНТЫ ---
  Widget _buildAIChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSetsProgress(int total, int completed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        bool isDone = index < completed;
        bool isCurrent = index == completed && !_isResting; // Моргает только когда нужно делать
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isCurrent ? 36 : 30,
          height: isCurrent ? 36 : 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? Colors.blueAccent : (isCurrent ? Colors.blueAccent.withOpacity(0.2) : Colors.white10),
            border: Border.all(color: isDone ? Colors.blueAccent : (isCurrent ? Colors.blueAccent : Colors.white24), width: 2),
            boxShadow: isDone || isCurrent ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 8)] : [],
          ),
          child: Center(
            child: isDone 
                ? const Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 18)
                : Text("${index + 1}", style: TextStyle(color: isCurrent ? Colors.blueAccent : Colors.white54, fontWeight: FontWeight.bold)),
          ),
        ).animate(target: isCurrent ? 1 : 0).scaleXY(end: 1.1, duration: 300.ms);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ВМЕСТО bottomSheet теперь мы используем SafeArea + Column, 
    // чтобы навсегда избавиться от черной полосы снизу.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _showExitConfirmation()) {
          if (!context.mounted) return;
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)), elevation: 0, backgroundColor: Colors.transparent),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / widget.exercises.length,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ),

              // Основной контент (скроллится)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), 
                  itemCount: widget.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = widget.exercises[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Упражнение ${_currentPage + 1} из ${widget.exercises.length}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(exercise.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 6),
                          Text("${exercise.targetMuscle} • ${exercise.equipment}", style: const TextStyle(fontSize: 16, color: Colors.white54)),
                          const SizedBox(height: 24),

                          if (exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty)
                            ExerciseVideoPlayer(videoPath: exercise.gifUrl!),
                          
                          if (exercise.recommendedWeight != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Wrap(
                                spacing: 12, runSpacing: 12,
                                children: [
                                  _buildAIChip(CupertinoIcons.flame_fill, "Вес: ${exercise.recommendedWeight}", Colors.orange),
                                  _buildAIChip(CupertinoIcons.repeat, "Сеты: ${exercise.recommendedReps}", Colors.blueAccent),
                                  _buildAIChip(CupertinoIcons.timer, "Отдых: ${exercise.recommendedRest}", Colors.greenAccent),
                                ],
                              ),
                            ),

                          const Text("Техника выполнения", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 12),
                          Text(exercise.description, style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.6)),
                          
                          const SizedBox(height: 40),
                          const Center(child: Text("Прогресс подходов", style: TextStyle(fontSize: 16, color: Colors.white54))),
                          const SizedBox(height: 16),
                          _buildSetsProgress(_totalSetsCount[index], _completedSetsCount[index]),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Наша панель управления теперь прямо внизу колонки (нет бага с полосой)
              _buildBottomActionPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionPanel() {
    final theme = Theme.of(context);
    final exercise = widget.exercises[_currentPage];
    final isExerciseDone = _completedSetsCount[_currentPage] >= _totalSetsCount[_currentPage];
    final isLastExercise = _currentPage == widget.exercises.length - 1;

    int defaultRest = 60;
    if (exercise.recommendedRest != null) {
      defaultRest = int.tryParse(exercise.recommendedRest!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 60;
    }

    double percent = _initialRestSeconds > 0 ? _restSeconds / _initialRestSeconds : 0;
    if (percent > 1.0) percent = 1.0;
    if (percent < 0.0) percent = 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isResting 
          // --- ИНТЕРФЕЙС ОТДЫХА И ТЕСТА ЦНС ---
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 40), // балансировка
                    CircularPercentIndicator(
                      radius: 40.0,
                      lineWidth: 6.0,
                      percent: percent,
                      center: Text(_formattedTime, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      progressColor: Colors.blueAccent,
                      backgroundColor: Colors.white10,
                      circularStrokeCap: CircularStrokeCap.round,
                    ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 400.ms, curve: Curves.easeOutBack),
                    
                    // Кнопка +15 секунд (сбоку)
                    IconButton(
                      onPressed: () => _addExtraRest(15),
                      icon: const Icon(CupertinoIcons.add_circled_solid, color: Colors.blueAccent, size: 40),
                      tooltip: "+15 секунд",
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // ОБЯЗАТЕЛЬНАЯ КНОПКА ЦНС
                GestureDetector(
                  onTap: _showCNSModal,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.purpleAccent.shade400, Colors.deepPurple.shade600]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.waveform_path, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Проверить ЦНС (Обязательно)", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2.seconds, color: Colors.white24),
                ),
              ],
            )
          // --- ИНТЕРФЕЙС ТРЕНИРОВКИ ---
          : GestureDetector(
              key: const ValueKey("ActionBtn"),
              onTap: () {
                if (!isExerciseDone) {
                  _completeSet(defaultRest);
                } else {
                  if (isLastExercise) {
                    _finishWorkout();
                  } else {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    setState(() => _currentPage++);
                  }
                }
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isExerciseDone
                        ? (isLastExercise ? [Colors.green.shade600, Colors.green.shade400] : [theme.colorScheme.primary, Colors.blue.shade400])
                        : [Colors.orange.shade700, Colors.orange.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isExerciseDone ? theme.colorScheme.primary : Colors.orange).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isExerciseDone ? (isLastExercise ? "🏆 Завершить тренировку" : "Следующее упражнение ➡️") : "🔥 Завершить подход",
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

// =========================================================================
// ВНУТРЕННИЙ МОДАЛЬНЫЙ ЭКРАН ТЕСТА ЦНС (Возвращает результат)
// =========================================================================
class CNSModalContent extends StatefulWidget {
  const CNSModalContent({super.key});

  @override
  State<CNSModalContent> createState() => _CNSModalContentState();
}

class _CNSModalContentState extends State<CNSModalContent> {
  List<FlSpot> _spots = [];
  bool _isRecording = false;
  double _stabilityScore = 0.0;
  double _timer = 10.0;
  Timer? _countdownTimer;
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  double _totalTremor = 0;
  int _sampleCount = 0;
  DateTime? _startTime;

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

    _startTime = DateTime.now();

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
      if (!_isRecording || !mounted || _startTime == null) return;
      
      double tremor = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
      _totalTremor += tremor;
      _sampleCount++;
      
      double elapsedSeconds = DateTime.now().difference(_startTime!).inMilliseconds / 1000.0;
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
    double score = 100 - (avgTremor * 33);
    if (score < 0) score = 0;
    if (score > 100) score = 100;

    setState(() {
      _isRecording = false;
      _timer = 0.0;
      _stabilityScore = score;
    });

    // Автоматически закрываем модалку через 2.5 секунды и передаем результат назад
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pop(context, score);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          const Text("Анализ ЦНС", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          const Text(
            "Вытяните руку и держите телефон параллельно полу максимально ровно.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0, maxX: 10, minY: 0, maxY: 15,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots.length < 2 ? const [FlSpot(0, 0), FlSpot(10, 0)] : _spots,
                    isCurved: true, color: Colors.purpleAccent, barWidth: 3, isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: Colors.purpleAccent.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (!_isRecording && _stabilityScore > 0)
            Column(
              children: [
                Text("${_stabilityScore.toStringAsFixed(1)}%", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: _stabilityScore >= 80 ? Colors.greenAccent : Colors.redAccent)),
                Text(_stabilityScore >= 80 ? "Супер! Вы готовы." : "Тремор! Нужно отдохнуть.", style: const TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          if (_isRecording)
            Text(_timer.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity, height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.deepPurple]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: _isRecording ? null : _startTest,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(_isRecording ? "Анализ..." : "Начать тест (10 сек)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// ВИДЕОПЛЕЕР
// =========================================================================
class ExerciseVideoPlayer extends StatefulWidget {
  final String videoPath;
  const ExerciseVideoPlayer({super.key, required this.videoPath});
  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.setLooping(true);
          _controller.setVolume(0.0);
          _controller.play();
        }
      }).catchError((error) {
        if (mounted) setState(() => _isError = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Container(
        height: 200, width: double.infinity, margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Icon(CupertinoIcons.video_camera, color: Colors.white24, size: 50)),
      );
    }
    return _controller.value.isInitialized
        ? Container(
            height: 220, width: double.infinity, margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
            ),
          )
        : Container(
            height: 220, width: double.infinity, margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(20)),
            child: const Center(child: CircularProgressIndicator(color: Colors.blueAccent)), 
          );
  }
}