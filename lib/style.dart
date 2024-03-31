import 'package:flutter/material.dart';

class appbar_euro extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const appbar_euro({Key? key,
  required this.title
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
        children: [
        Image.asset('assets/images/logo.png', height: 40),
          SizedBox(width: 10), // Add some space between the logo and the text
          Text(this.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}