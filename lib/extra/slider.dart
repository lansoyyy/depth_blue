import 'package:flutter/material.dart';

class DiscreteSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int divisions;
  final String label;

  const DiscreteSlider({super.key,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
  });

  @override
  State<DiscreteSlider> createState() => _DiscreteSliderState();
}

class _DiscreteSliderState extends State<DiscreteSlider> {
  double _currentValue = 0.6;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: _currentValue,
          onChanged: (value) {
            setState(() {
              _currentValue = value;
              widget.onChanged(value);
            });
          },
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          label: widget.label,
        ),
        Text(_currentValue.toStringAsFixed(1)),
      ],
    );
  }
}