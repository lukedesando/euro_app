import 'package:flutter/material.dart';
import 'vote_widget.dart';

class VotingSlider extends StatefulWidget {
  final Function(double) onScoreChanged;

  const VotingSlider({Key? key, required this.onScoreChanged}) : super(key: key);

  @override
  _VotingSliderState createState() => _VotingSliderState();
}

class _VotingSliderState extends State<VotingSlider> {
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
