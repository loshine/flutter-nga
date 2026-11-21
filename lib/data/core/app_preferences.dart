import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

/// 应用写入 SharedPreferences 的全部 key。
///
/// 新增 key 时必须加入 [all]：[SharedPreferencesWithCache] 只缓存 allowList
/// 中的 key，读写未列出的 key 会抛 [ArgumentError]；旧数据迁移也只迁移 [all]。
abstract final class PrefsKeys {
  // DataConfigService
  static const baseUrlConfigKey = 'base_url_config_key';
  static const customBaseUrlValue = 'custom_base_url_value';
  static const userAgentConfigKey = 'user_agent_config_key';
  static const customUserAgentValue = 'custom_user_agent_value';

  // ThemeNotifier
  static const seedColorValue = 'seed_color_value';
  static const useDynamicColor = 'use_dynamic_color';

  // InterfaceSettingsNotifier
  static const uiContentSizeMultiple = 'ui_contentSizeMultiple';
  static const uiTitleSizeMultiple = 'ui_titleSizeMultiple';
  static const uiLineHeight = 'ui_lineHeight';

  // BlocklistSettingsNotifier
  static const blocklistClientBlockEnabled = 'blocklist_clientBlockEnabled';
  static const blocklistListBlockEnabled = 'blocklist_listBlockEnabled';
  static const blocklistDetailsBlockEnabled = 'blocklist_detailsBlockEnabled';
  static const blocklistBlockMode = 'blocklist_blockMode';

  static const Set<String> all = {
    baseUrlConfigKey,
    customBaseUrlValue,
    userAgentConfigKey,
    customUserAgentValue,
    seedColorValue,
    useDynamicColor,
    uiContentSizeMultiple,
    uiTitleSizeMultiple,
    uiLineHeight,
    blocklistClientBlockEnabled,
    blocklistListBlockEnabled,
    blocklistDetailsBlockEnabled,
    blocklistBlockMode,
  };
}

/// 应用级 SharedPreferences 入口。
///
/// 旧版使用已弃用的 `SharedPreferences.getInstance()`（key 带 `flutter.` 前缀，
/// Android 存在 `FlutterSharedPreferences.xml`）；现在统一用
/// [SharedPreferencesWithCache]（Android 默认 DataStore 后端，key 无前缀），
/// 两者数据互不可见。首次获取实例前会执行一次性迁移，保证老用户设置不丢失。
abstract final class AppPreferences {
  /// 迁移完成标记，写在新存储中。不要修改此值，否则会重复迁移并覆盖新数据。
  @visibleForTesting
  static const migrationCompletedKey = 'flutter_nga_legacy_prefs_migrated';

  /// `adaptive_theme` 保存亮/暗模式的 key（`AdaptiveTheme.prefKey`）。
  ///
  /// adaptive_theme 3.7.2 起改用 SharedPreferencesAsync 且未迁移旧数据，
  /// 因此 v0.0.46（adaptive_theme 2.3.1）的用户该值仍在旧存储里。仅在新存储
  /// 还没有该 key 时才从旧存储迁移，避免用旧值覆盖用户在新版本里的选择。
  @visibleForTesting
  static const adaptiveThemePrefKey = 'adaptive_theme_preferences';

  static const _legacyPrefix = 'flutter.';

  static Future<void>? _migration;
  static Future<SharedPreferencesWithCache>? _instance;

  /// 在启动时（读取任何设置之前）调用，确保旧数据已迁移。可重复调用。
  static Future<void> ensureMigrated() => _migration ??= _migrateLegacy();

  /// 应用共享的 [SharedPreferencesWithCache] 实例。
  static Future<SharedPreferencesWithCache> instance() =>
      _instance ??= _create();

  static Future<SharedPreferencesWithCache> _create() async {
    try {
      await ensureMigrated();
      return await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: PrefsKeys.all,
        ),
      );
    } catch (_) {
      _instance = null;
      rethrow;
    }
  }

  static Future<void> _migrateLegacy() async {
    try {
      final asyncPrefs = SharedPreferencesAsync();
      // 已迁移过就不再碰旧 API，避免每次启动都加载旧存储。
      if (await asyncPrefs.containsKey(migrationCompletedKey)) return;

      final keys = {...PrefsKeys.all};
      if (!await asyncPrefs.containsKey(adaptiveThemePrefKey)) {
        keys.add(adaptiveThemePrefKey);
      }
      // 只迁移应用自己的 key。启用 allowList 时 key 需要带前缀。
      SharedPreferences.setPrefix(
        _legacyPrefix,
        allowList: {for (final key in keys) '$_legacyPrefix$key'},
      );
      final legacyPrefs = await SharedPreferences.getInstance();
      await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
        legacySharedPreferencesInstance: legacyPrefs,
        sharedPreferencesAsyncOptions: const SharedPreferencesOptions(),
        migrationCompletedKey: migrationCompletedKey,
      );
      debugPrint('AppPreferences: 旧版设置迁移完成');
    } catch (e, s) {
      // 迁移失败不阻塞启动；未写入完成标记，下次启动会重试。
      debugPrint('AppPreferences: 旧版设置迁移失败: $e\n$s');
    }
  }

  /// 测试用：清空缓存的迁移结果与实例。测试还需自行调用
  /// `SharedPreferences.resetStatic()` 重置旧 API 的前缀与单例。
  @visibleForTesting
  static void resetForTesting() {
    _migration = null;
    _instance = null;
  }
}
