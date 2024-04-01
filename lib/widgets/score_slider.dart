import 'package:flutter/material.dart';
import '../http_backend.dart';

class ScoreSlider extends StatefulWidget {
  final Function(double) onScoreChanged;

  const ScoreSlider({Key? key, required this.onScoreChanged}) : super(key: key);

  @override
  _ScoreSliderState createState() => _ScoreSliderState();
}

class _ScoreSliderState extends State<ScoreSlider> {
  double _currentScore = 5.0;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentScore,
      min: 0,
      max: 10,
      divisions: 10,
      label: _currentScore.round().toString(),
      onChanged: (double value) {
        setState(() {
          _currentScore = value;
        });
        widget.onScoreChanged(value);
      },
    );
  }
}
