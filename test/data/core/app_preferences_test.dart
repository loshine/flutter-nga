import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_nga/data/core/app_preferences.dart';

import '../../test_utils/preferences.dart';

/// main 分支（ee86767）上旧 API 实际会写入的全部设置，覆盖 String / int /
/// double / bool 四种类型。应用从未写过 StringList。
const Map<String, Object> _legacySettings = {
  PrefsKeys.baseUrlConfigKey: 'custom',
  PrefsKeys.customBaseUrlValue: 'https://example.com/',
  PrefsKeys.userAgentConfigKey: 'custom',
  PrefsKeys.customUserAgentValue: 'MyAgent/1.0',
  PrefsKeys.seedColorValue: 0xFF2196F3,
  PrefsKeys.uiContentSizeMultiple: 1.25,
  PrefsKeys.uiTitleSizeMultiple: 0.9,
  PrefsKeys.uiLineHeight: 3,
  PrefsKeys.blocklistClientBlockEnabled: true,
  PrefsKeys.blocklistListBlockEnabled: false,
  PrefsKeys.blocklistDetailsBlockEnabled: false,
  PrefsKeys.blocklistBlockMode: 2,
};

Future<SharedPreferencesWithCache> _restartApp() async {
  // 模拟冷启动：清空进程内缓存，但保留两个存储中的数据。
  SharedPreferences.resetStatic();
  AppPreferences.resetForTesting();
  await AppPreferences.ensureMigrated();
  return AppPreferences.instance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PrefsKeys.all covers every legacy setting', () {
    expect(PrefsKeys.all, containsAll(_legacySettings.keys));
  });

  test('adaptive theme key matches AdaptiveTheme.prefKey', () {
    expect(AppPreferences.adaptiveThemePrefKey, AdaptiveTheme.prefKey);
  });

  test('migrates every legacy setting with its type', () async {
    setUpTestPreferences(legacy: _legacySettings);

    await AppPreferences.ensureMigrated();
    final prefs = await AppPreferences.instance();

    expect(prefs.getString(PrefsKeys.baseUrlConfigKey), 'custom');
    expect(
      prefs.getString(PrefsKeys.customBaseUrlValue),
      'https://example.com/',
    );
    expect(prefs.getString(PrefsKeys.userAgentConfigKey), 'custom');
    expect(prefs.getString(PrefsKeys.customUserAgentValue), 'MyAgent/1.0');
    expect(prefs.getInt(PrefsKeys.seedColorValue), 0xFF2196F3);
    expect(prefs.getDouble(PrefsKeys.uiContentSizeMultiple), 1.25);
    expect(prefs.getDouble(PrefsKeys.uiTitleSizeMultiple), 0.9);
    expect(prefs.getInt(PrefsKeys.uiLineHeight), 3);
    expect(prefs.getBool(PrefsKeys.blocklistClientBlockEnabled), isTrue);
    expect(prefs.getBool(PrefsKeys.blocklistListBlockEnabled), isFalse);
    expect(prefs.getBool(PrefsKeys.blocklistDetailsBlockEnabled), isFalse);
    expect(prefs.getInt(PrefsKeys.blocklistBlockMode), 2);

    final async = SharedPreferencesAsync();
    expect(await async.getBool(AppPreferences.migrationCompletedKey), isTrue);
    // 新存储中的 key 不带 flutter. 前缀。
    expect(
      (await async.getKeys()).where((key) => key.startsWith('flutter.')),
      isEmpty,
    );
  });

  test('migration runs only once and never overwrites newer values', () async {
    setUpTestPreferences(legacy: _legacySettings);
    final first = await _restartApp();
    expect(first.getInt(PrefsKeys.seedColorValue), 0xFF2196F3);

    // 新版本里用户改了设置。
    await first.setInt(PrefsKeys.seedColorValue, 0xFF4CAF50);
    await first.setDouble(PrefsKeys.uiContentSizeMultiple, 1.5);
    // 旧存储里的值依然存在（迁移不删除旧数据）。
    final legacy = await SharedPreferences.getInstance();
    expect(legacy.getInt(PrefsKeys.seedColorValue), 0xFF2196F3);

    final second = await _restartApp();
    expect(second.getInt(PrefsKeys.seedColorValue), 0xFF4CAF50);
    expect(second.getDouble(PrefsKeys.uiContentSizeMultiple), 1.5);
  });

  test('does not migrate unrelated legacy keys', () async {
    setUpTestPreferences(
      legacy: {
        ..._legacySettings,
        'some_plugin_value': 'x',
        'some_plugin_list': <String>['a', 'b'],
      },
    );

    await AppPreferences.ensureMigrated();

    final keys = await SharedPreferencesAsync().getKeys();
    expect(keys, isNot(contains('some_plugin_value')));
    expect(keys, isNot(contains('some_plugin_list')));
    expect(keys, containsAll(_legacySettings.keys));
  });

  test(
    'migrates adaptive theme mode only when the new store lacks it',
    () async {
      const legacyTheme = '{"theme_mode":1,"default_theme_mode":0}';
      setUpTestPreferences(
        legacy: {AppPreferences.adaptiveThemePrefKey: legacyTheme},
      );

      await AppPreferences.ensureMigrated();

      expect(await AdaptiveTheme.getThemeMode(), AdaptiveThemeMode.dark);
    },
  );

  test('keeps the adaptive theme mode already saved by the new API', () async {
    const legacyTheme = '{"theme_mode":1,"default_theme_mode":0}';
    const currentTheme = '{"theme_mode":2,"default_theme_mode":0}';
    setUpTestPreferences(
      legacy: {AppPreferences.adaptiveThemePrefKey: legacyTheme},
      current: {AppPreferences.adaptiveThemePrefKey: currentTheme},
    );

    await AppPreferences.ensureMigrated();

    expect(await AdaptiveTheme.getThemeMode(), AdaptiveThemeMode.system);
  });

  test('fresh install marks migration done without data', () async {
    setUpTestPreferences();

    final prefs = await AppPreferences.instance();

    expect(prefs.keys, isEmpty);
    expect(
      await SharedPreferencesAsync().getBool(
        AppPreferences.migrationCompletedKey,
      ),
      isTrue,
    );
  });

  test('instance() migrates before creating the cache', () async {
    setUpTestPreferences(legacy: {PrefsKeys.uiLineHeight: 4});

    // 不显式调用 ensureMigrated，直接取实例也能读到旧数据。
    final prefs = await AppPreferences.instance();

    expect(prefs.getInt(PrefsKeys.uiLineHeight), 4);
  });
}
