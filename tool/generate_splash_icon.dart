import 'dart:io';

/// Splash icon is produced together with launcher icons.
/// Prefer: `fvm dart run tool/generate_launcher_icons.dart`
void main() {
  stderr.writeln(
    'Deprecated: run `fvm dart run tool/generate_launcher_icons.dart` instead.',
  );
  exit(1);
}
