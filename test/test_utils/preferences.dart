import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:flutter_nga/data/core/app_preferences.dart';

/// 为测试准备一对全新的内存存储：
/// - [legacy]：旧 `SharedPreferences` API 的数据（key 不带 `flutter.` 前缀，
///   `setMockInitialValues` 会自动补上），模拟老版本写入的设置；
/// - [current]：新 `SharedPreferencesAsync` 存储中已有的数据。
///
/// 返回新存储的平台实现，便于直接检查迁移结果。
InMemorySharedPreferencesAsync setUpTestPreferences({
  Map<String, Object> legacy = const {},
  Map<String, Object> current = const {},
}) {
  final previous = SharedPreferencesAsyncPlatform.instance;
  final store = InMemorySharedPreferencesAsync.withData({...current});
  SharedPreferencesAsyncPlatform.instance = store;
  SharedPreferences.resetStatic();
  SharedPreferences.setMockInitialValues(legacy);
  AppPreferences.resetForTesting();
  addTearDown(() {
    SharedPreferencesAsyncPlatform.instance = previous;
    SharedPreferences.resetStatic();
    AppPreferences.resetForTesting();
  });
  return store;
}
