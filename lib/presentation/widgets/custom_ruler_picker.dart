import 'package:flutter/material.dart';

class CustomRulerPicker extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  const CustomRulerPicker({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RepaintBoundary(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${value.round()} $unit',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 30),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.0,
            trackShape: const RoundedRectSliderTrackShape(),
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: Colors.grey[700],
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
            thumbColor: Colors.white,
            overlayColor: theme.colorScheme.primary.withAlpha(32),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
    );
  }
}
