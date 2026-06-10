import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class ThemeSwitcherButton extends StatelessWidget {
  const ThemeSwitcherButton({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.showLabel = true,
  });

  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightMode = themeProvider.themeMode == ThemeMode.light;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: showLabel ? null : const CircleBorder(),
        padding: showLabel ? null : const EdgeInsets.all(16),
        minimumSize: showLabel ? null : const Size.square(52),
      ),
      onPressed: themeProvider.toggleTheme,
      child: showLabel
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isLightMode ? Icons.light_mode : Icons.dark_mode),
                const SizedBox(width: 8),
                Text(isLightMode ? 'Dark Mode' : 'Light Mode'),
              ],
            )
          : Icon(isLightMode ? Icons.dark_mode : Icons.light_mode),
    );
  }
}
