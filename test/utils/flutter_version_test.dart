import 'dart:io';

import 'package:flutter/services.dart' show FlutterVersion;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FlutterVersion matches the Flutter SDK pinned in .tool-versions', () {
    final pinnedVersion = File('.tool-versions')
        .readAsLinesSync()
        .map((line) => line.trim().split(RegExp(r'\s+')))
        .singleWhere((fields) => fields.first == 'flutter')[1];
    expect(FlutterVersion.version, pinnedVersion);
  });
}
