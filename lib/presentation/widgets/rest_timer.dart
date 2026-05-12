import 'dart:async';

import 'package:flutter/material.dart';
import 'package:training_app/services/sound_service.dart';

class RestTimer extends StatefulWidget {
  final int duration;
  final VoidCallback onTimerEnd;
  final VoidCallback onSkip;

  const RestTimer({
    super.key,
    required this.duration,
    required this.onTimerEnd,
    required this.onSkip,
  });

  @override
  RestTimerState createState() => RestTimerState();
}

class RestTimerState extends State<RestTimer> {
  late Timer _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _current = widget.duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_current > 0) {
          _current--;
        } else {
          _timer.cancel();
          SoundService.playNotify();
          widget.onTimerEnd();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_current ~/ 60).toString().padLeft(2, '0');
    final seconds = (_current % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _current / widget.duration;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'ОТДЫХ',
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 4,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Следующий подход',
              style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 40),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.15),
                    blurRadius: 60,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 14,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  ),
                  Text(
                    _formattedTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: widget.onSkip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Colors.blueAccent.withOpacity(0.2),
                  elevation: 5,
                ),
                child: const Text(
                  'ПРОПУСТИТЬ',
                  style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
