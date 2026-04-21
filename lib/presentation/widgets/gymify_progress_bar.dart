import 'package:flutter/material.dart';

class GymifyProgressBar extends StatelessWidget {
  final int current; 
  final int total;

  const GymifyProgressBar({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: current / total,
      minHeight: 10,
    );
  }
}
