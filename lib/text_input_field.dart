import 'package:flutter/material.dart';
import 'vote_backend.dart';

class NameInputField extends StatefulWidget {
  final TextEditingController controller;

  const NameInputField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<NameInputField> createState() => _NameInputFieldState();
}

class _NameInputFieldState extends State<NameInputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: const InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(),
      ),
      onFieldSubmitted: (_) {
        // This callback is called when the user submits the form (e.g., pressing a button on the keyboard)
        // You can add any additional logic here if needed.
      },
      onEditingComplete: () {
        // This callback is called when the text field loses focus
        // You can add any additional logic here if needed.
        FocusScope.of(context).unfocus(); // This line ensures the keyboard is dismissed when the user is done editing
      },
    );
  }
}
