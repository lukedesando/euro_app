import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/buttons/theme_switch_button.dart';
import 'models/x_count_model.dart';

import 'package:euro_app/pages/home_page.dart';
import 'global.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<XCountModel>(
          create: (context) => Global.xCountModel,
        ),
      ],
      child: MyApp(),
    ),
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