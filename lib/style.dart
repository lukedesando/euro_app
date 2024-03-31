import 'package:flutter/material.dart';

class appbar_euro extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const appbar_euro({Key? key,
  required this.title
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;


    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
        children: [
          logoBlackandWhite(),
          SizedBox(width: 10), // Add some space between the logo and the text
          Text(this.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class logoBlackandWhite extends StatelessWidget{
  const logoBlackandWhite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
            isDarkTheme ? 'assets/images/logo_white_txt.png' : 'assets/images/logo_black_txt.png',
            height: 40,
          );
  }
}