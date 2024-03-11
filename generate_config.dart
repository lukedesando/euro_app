// generate_config.dart
import 'dart:io';

void main() {
  File envFile = File('.env');
  File configFile = File('lib/config.dart');

  List<String> lines = envFile.readAsLinesSync();
  List<String> configLines = [
    '// GENERATED FILE - DO NOT EDIT',
    'class Config {',
  ];

  for (String line in lines) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    List<String> parts = line.split('=');
    if (parts.length != 2) continue;

    String key = parts[0].trim();
    String value = parts[1].trim();
    configLines.add('  static const String $key = \'$value\';');
  }

  configLines.add('}');

  configFile.writeAsStringSync(configLines.join('\n'));
  print('Config file generated: lib/config.dart');
}
