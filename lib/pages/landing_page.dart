import 'package:euro_app/config/runtime_config.dart';
import 'package:euro_app/widgets/buttons/theme_switch_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final config = RuntimeConfig.landingPage;
    final colors = themeProvider.themeMode == ThemeMode.dark
        ? config.darkTheme
        : config.lightTheme;
    final backgroundColor = _parseColor(colors.background);
    final textColor = _parseColor(colors.text);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LandingImage(image: config.image),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          config.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: ThemeSwitcherButton(
                backgroundColor: _parseColor(colors.controlBackground),
                foregroundColor: _parseColor(colors.controlForeground),
                showLabel: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '').trim();
    if (cleaned.length == 6) {
      final colorValue = int.tryParse('FF$cleaned', radix: 16);
      if (colorValue != null) return Color(colorValue);
    }
    if (cleaned.length == 8) {
      final colorValue = int.tryParse(cleaned, radix: 16);
      if (colorValue != null) return Color(colorValue);
    }
    return Colors.black;
  }
}

class _LandingImage extends StatelessWidget {
  const _LandingImage({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    final imageWidget = image.startsWith('assets/')
        ? Image.asset(image, fit: BoxFit.contain)
        : Image.network(image, fit: BoxFit.contain);

    return SizedBox(
      width: 280,
      height: 280,
      child: ClipOval(child: imageWidget),
    );
  }
}
