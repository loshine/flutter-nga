import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:mmkv/mmkv.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  await FlutterDisplayMode.setHighRefreshRate();

  // must wait for MMKV to finish initialization
  final rootDir = await MMKV.initialize();
  debugPrint('MMKV for flutter with rootDir = $rootDir');

  runApp(RouteObserverProvider(
    child: MyApp(savedThemeMode: savedThemeMode),
  ));
  _syncBlockList();
}

_syncBlockList() {
  Future.delayed(Duration(), () async {
    debugPrint('定时任务');
    if (await Data().userRepository.getDefaultUser() != null) {
      await Data().userRepository.getBlockInfo();
    }
  }).whenComplete(() {
    Future.delayed(Duration(minutes: 5), () => _syncBlockList());
  }).catchError((err) {
    debugPrint(err.toString());
  });
}
