import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class WorkoutCompletionOverlay extends StatefulWidget {
  final Duration totalDuration;

  const WorkoutCompletionOverlay({
    super.key,
    required this.totalDuration,
  });

  @override
  WorkoutCompletionOverlayState createState() => WorkoutCompletionOverlayState();
}

class WorkoutCompletionOverlayState extends State<WorkoutCompletionOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Material(
        color: Colors.black.withAlpha(217), // Dark overlay background
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Тренировка завершена!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _formatDuration(widget.totalDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 50),
                CupertinoButton.filled(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the overlay
                  },
                  child: const Text('Завершить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
