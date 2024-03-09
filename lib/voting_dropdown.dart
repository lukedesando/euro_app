import 'package:flutter/material.dart';

class VotingDropdown extends StatefulWidget {
  final void Function(double) onScoreSelected;
  final double initialValue;

  VotingDropdown({required this.onScoreSelected, this.initialValue = 0.0});

  @override
  _VotingDropdownState createState() => _VotingDropdownState();
}

class _VotingDropdownState extends State<VotingDropdown> {
  double? _selectedScore;

  @override
  void initState() {
    super.initState();
    _selectedScore = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<double>(
      value: _selectedScore,
      hint: Text('Select Score'),
      onChanged: (value) {
        setState(() {
          _selectedScore = value;
          widget.onScoreSelected(value!);
        });
      },
      items: List.generate(11, (index) => index.toDouble())
          .map<DropdownMenuItem<double>>((double value) {
        return DropdownMenuItem<double>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }
}
