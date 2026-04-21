import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:training_app/services/sound_service.dart';
import 'package:training_app/core/ui_constants.dart';

class RestTimer extends StatefulWidget {
  final int duration;
  final VoidCallback onTimerEnd;

  const RestTimer({super.key, required this.duration, required this.onTimerEnd});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 10.0,
              percent: _current / widget.duration,
              center: Text(
                "$_current",
                style: const TextStyle(fontSize: 48, color: UIColors.white),
              ),
              progressColor: UIColors.primary,
            ),
            const SizedBox(height: UIConstants.padding24),
            TextButton(
              onPressed: () {
                _timer.cancel();
                widget.onTimerEnd();
              },
              child: const Text("Пропустить отдых", style: TextStyle(color: UIColors.white)),
            )
          ],
        ),
      ),
    );
  }
}
