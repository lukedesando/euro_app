import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class RuntimeConfig {
  static String apiBaseHTTP = Config.API_BASE_HTTP;
  static String apiBaseWS = Config.API_BASE_WS;

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
