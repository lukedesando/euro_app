import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/theme_switch_button.dart';

import 'package:euro_app/pages/home_page.dart';

void main() {
  runApp(ChangeNotifierProvider<ThemeProvider>(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  // runApp(MyApp()
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Eurovision Voting App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      home: HomePage(),
    );
  }
}