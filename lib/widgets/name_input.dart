import 'package:flutter/material.dart';

class NameInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onNameChanged; // Add a callback for when the name changes

  const NameInputField({
    Key? key,
    required this.controller,
    required this.onNameChanged, // Add this to the constructor
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
        hintText: 'Your Name',
        border: OutlineInputBorder(),
      ),
      onChanged: (String value) {
        widget.onNameChanged(value); // Call the callback with the new value
      },
      onFieldSubmitted: (_) {
        // Additional logic if needed
      },
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
      },
    );
  }
}
