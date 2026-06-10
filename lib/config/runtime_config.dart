import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class RuntimeConfig {
  static String apiBaseHTTP = Config.API_BASE_HTTP;
  static String apiBaseWS = Config.API_BASE_WS;
  static LandingPageConfig landingPage = LandingPageConfig.defaults();

  static String get apiHost => Config.API_HOST;
  static String get apiPort => Config.API_PORT;

  static Future<void> load() async {
    try {
      final uri = Uri.base.resolve(
        'config.json?v=${DateTime.now().millisecondsSinceEpoch}',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) return;

      final configuredHTTP = _stringValue(data['API_BASE_HTTP']);
      final configuredWS = _stringValue(data['API_BASE_WS']);
      final configuredHost = _stringValue(data['API_HOST']);
      final configuredPort = _stringValue(data['API_PORT']);
      final configuredLandingPage = data['LANDING_PAGE'];

      if (configuredHTTP != null) {
        apiBaseHTTP = configuredHTTP;
      } else if (configuredHost != null || configuredPort != null) {
        apiBaseHTTP = _buildBaseUrl(
          scheme: 'http',
          host: configuredHost ?? apiHost,
          port: configuredPort ?? apiPort,
        );
      }

      if (configuredWS != null) {
        apiBaseWS = configuredWS;
      } else if (configuredHost != null || configuredPort != null) {
        apiBaseWS = _buildBaseUrl(
          scheme: 'ws',
          host: configuredHost ?? apiHost,
          port: configuredPort ?? apiPort,
        );
      }

      if (configuredLandingPage is Map<String, dynamic>) {
        landingPage = LandingPageConfig.fromJson(configuredLandingPage);
      }
    } catch (_) {
      // Keep generated config fallback when runtime config is unavailable.
    }
  }

  static String? _stringValue(dynamic value) {
    if (value == null) return null;

    final stringValue = value.toString().trim();
    if (stringValue.isEmpty) return null;
    return stringValue;
  }

  static String _buildBaseUrl({
    required String scheme,
    required String host,
    required String port,
  }) {
    return '$scheme://$host:$port';
  }
}

class LandingPageConfig {
  LandingPageConfig({
    required this.enabled,
    required this.text,
    required this.image,
    required this.lightTheme,
    required this.darkTheme,
  });

  final bool enabled;
  final String text;
  final String image;
  final LandingThemeConfig lightTheme;
  final LandingThemeConfig darkTheme;

  factory LandingPageConfig.defaults() {
    return LandingPageConfig(
      enabled: false,
      text: 'desando.org',
      image: 'assets/images/logo_black_txt.png',
      lightTheme: const LandingThemeConfig(
        background: '#FFFFFF',
        text: '#000000',
        controlBackground: '#F1F1F1',
        controlForeground: '#111111',
      ),
      darkTheme: const LandingThemeConfig(
        background: '#0E0E0E',
        text: '#FFFFFF',
        controlBackground: '#232323',
        controlForeground: '#FFFFFF',
      ),
    );
  }

  factory LandingPageConfig.fromJson(Map<String, dynamic> json) {
    final defaults = LandingPageConfig.defaults();
    final theme = json['theme'];
    final themeMap = theme is Map<String, dynamic> ? theme : null;

    return LandingPageConfig(
      enabled: _boolValue(json['enabled']) ?? defaults.enabled,
      text: RuntimeConfig._stringValue(json['text']) ?? defaults.text,
      image: RuntimeConfig._stringValue(json['image']) ?? defaults.image,
      lightTheme: LandingThemeConfig.fromJson(
        themeMap?['light'],
        defaults.lightTheme,
      ),
      darkTheme: LandingThemeConfig.fromJson(
        themeMap?['dark'],
        defaults.darkTheme,
      ),
    );
  }

  static bool? _boolValue(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return null;
  }
}

class LandingThemeConfig {
  const LandingThemeConfig({
    required this.background,
    required this.text,
    required this.controlBackground,
    required this.controlForeground,
  });

  final String background;
  final String text;
  final String controlBackground;
  final String controlForeground;

  factory LandingThemeConfig.fromJson(
    dynamic json,
    LandingThemeConfig fallback,
  ) {
    if (json is! Map<String, dynamic>) return fallback;

    return LandingThemeConfig(
      background:
          RuntimeConfig._stringValue(json['background']) ?? fallback.background,
      text: RuntimeConfig._stringValue(json['text']) ?? fallback.text,
      controlBackground: RuntimeConfig._stringValue(json['controlBackground']) ??
          fallback.controlBackground,
      controlForeground: RuntimeConfig._stringValue(json['controlForeground']) ??
          fallback.controlForeground,
    );
  }
}
