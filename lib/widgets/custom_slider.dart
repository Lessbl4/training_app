import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const CustomSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(CustomSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() {
        _value = widget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliderTheme(
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
        value: _value,
        min: widget.min,
        max: widget.max,
        onChanged: (value) {
          setState(() {
            _value = value;
          });
          widget.onChanged(value);
        },
      ),
    );
  }
}
