import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show FlutterVersion;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FlutterVersion is injected by flutter_tools and matches .fvmrc', () {
    final fvmrc = jsonDecode(File('.fvmrc').readAsStringSync()) as Map;
    // About 页直接显示 FlutterVersion.version；用 fvm flutter 运行时应与 .fvmrc 一致。
    expect(FlutterVersion.version, fvmrc['flutter']);
  });
}
