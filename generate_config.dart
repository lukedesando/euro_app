// generate_config.dart
import 'dart:convert';
import 'dart:io';

void main() {
  File envFile = File('.env');
  File configFile = File('lib/config.dart');
  File runtimeConfigFile = File('web/config.json');

  Map<String, String> values = {};

  List<String> lines = envFile.readAsLinesSync();
  for (String line in lines) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;

    int separator = line.indexOf('=');
    if (separator == -1) continue;

    String key = line.substring(0, separator).trim();
    String value = line.substring(separator + 1).trim();
    values[key] = value;
  }

  values.putIfAbsent(
      'API_HOST', () => values['APP_HOST'] ?? values['DB_HOST'] ?? 'localhost');
  values.putIfAbsent(
      'API_PORT', () => values['APP_PORT'] ?? values['DB_PORT'] ?? '5000');
  values.putIfAbsent('API_BASE_HTTP',
      () => 'http://${values['API_HOST']}:${values['API_PORT']}');
  values.putIfAbsent(
      'API_BASE_WS', () => 'ws://${values['API_HOST']}:${values['API_PORT']}');

  final publicConfigValues = {
    'API_HOST': values['API_HOST'],
    'API_PORT': values['API_PORT'],
    'API_BASE_HTTP': values['API_BASE_HTTP'],
    'API_BASE_WS': values['API_BASE_WS'],
  };

  List<String> configLines = [
    '// GENERATED FILE - DO NOT EDIT',
    'class Config {',
  ];

  for (MapEntry<String, String?> entry in publicConfigValues.entries) {
    if (entry.value == null) continue;

    String escapedValue =
        entry.value!.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    configLines.add('  static const String ${entry.key} = \'$escapedValue\';');
  }

  configLines.add('}');

  configFile.writeAsStringSync(configLines.join('\n'));
  print('Config file generated: lib/config.dart');

  runtimeConfigFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(publicConfigValues),
  );
  print('Runtime config file generated: web/config.json');
}
