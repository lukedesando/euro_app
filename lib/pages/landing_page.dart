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
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 12),
                child: ThemeSwitcherButton(
                  backgroundColor: _parseColor(colors.controlBackground),
                  foregroundColor: _parseColor(colors.controlForeground),
                  showLabel: false,
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                  );
                },
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
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final imageSize = shortestSide < 360 ? shortestSide * 0.7 : 280.0;
    final imageWidget = image.startsWith('assets/')
        ? Image.asset(image, fit: BoxFit.contain)
        : Image.network(image, fit: BoxFit.contain);

    return SizedBox(
      width: imageSize,
      height: imageSize,
      child: ClipOval(child: imageWidget),
    );
  }
}
