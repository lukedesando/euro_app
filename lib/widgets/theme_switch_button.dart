import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Theme Switcher'),
        ),
        body: Center(
          child: ThemeSwitcherButton(),
        ),
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class ThemeSwitcherButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return ElevatedButton(
      onPressed: themeProvider.toggleTheme,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(themeProvider.themeMode == ThemeMode.light ? Icons.light_mode : Icons.dark_mode),
          SizedBox(width: 8),
          Text(themeProvider.themeMode == ThemeMode.light ? 'Switch to Dark Mode' : 'Switch to Light Mode'),
        ],
      ),
    );
  }
}
