import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class RuntimeConfig {
  static String apiHost = Config.API_HOST;
  static String apiPort = Config.API_PORT;

  static String get apiBaseHTTP => 'http://$apiHost:$apiPort';
  static String get apiBaseWS => 'ws://$apiHost:$apiPort';

  static Future<void> load() async {
    try {
      final uri = Uri.base.resolve(
        'config.json?v=${DateTime.now().millisecondsSinceEpoch}',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) return;

      apiHost = _stringValue(data['API_HOST']) ?? apiHost;
      apiPort = _stringValue(data['API_PORT']) ?? apiPort;
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
}
