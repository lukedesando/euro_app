. "$PSScriptRoot\common.ps1"

Enter-RepoRoot
Assert-FileExists ".env" "Local .env file"
Assert-FileExists $DartExe "Dart executable"

& $DartExe --disable-dart-dev generate_config.dart
