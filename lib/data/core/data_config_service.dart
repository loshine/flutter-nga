import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_nga/data/entity/base_url_config.dart';
import 'package:flutter_nga/data/entity/user_agent_config.dart';

typedef BaseUrlChangeListener = void Function(BaseUrlConfig);
typedef UserAgentChangeListener = void Function(UserAgentConfig, String);

class DataConfigService {
  static const String _baseUrlPrefsKey = 'base_url_config_key';
  static const String _customBaseUrlPrefsKey = 'custom_base_url_value';
  static const String _userAgentPrefsKey = 'user_agent_config_key';
  static const String _customUserAgentPrefsKey = 'custom_user_agent_value';

  BaseUrlConfig _currentBaseUrlConfig = BaseUrlPresets.defaultConfig;
  UserAgentConfig _currentUserAgentConfig = UserAgentPresets.defaultConfig;
  String _currentUserAgent = '';

  final List<BaseUrlChangeListener> _baseUrlChangeListeners = [];
  final List<UserAgentChangeListener> _userAgentChangeListeners = [];

  BaseUrlConfig get currentBaseUrlConfig => _currentBaseUrlConfig;

  UserAgentConfig get currentUserAgentConfig => _currentUserAgentConfig;

  String get currentUserAgent => _currentUserAgent;

  String get baseUrl => _currentBaseUrlConfig.url;

  String get domain => _currentBaseUrlConfig.url
      .replaceAll(RegExp(r'^https?://'), '')
      .replaceAll(RegExp(r'/$'), '');

  Future<void> init() async {
    await _loadBaseUrlConfig();
    await _loadUserAgentConfig();
    _currentUserAgent =
        await UserAgentPresets.resolveUserAgent(_currentUserAgentConfig);
  }

  Future<void> switchBaseUrl(BaseUrlConfig config) async {
    var targetConfig = config;
    if (config.key == BaseUrlPresets.custom.key) {
      final normalizedUrl = _normalizeBaseUrl(config.url);
      if (normalizedUrl.isEmpty) return;
      targetConfig = config.copyWith(url: normalizedUrl);
    }
    if (_currentBaseUrlConfig.key == targetConfig.key &&
        _currentBaseUrlConfig.url == targetConfig.url) {
      return;
    }

    _currentBaseUrlConfig = targetConfig;
    await _saveBaseUrlConfig(targetConfig);
    _notifyBaseUrlChanged(targetConfig);
    debugPrint('Data: BaseUrl 已切换至: ${targetConfig.url}');
  }

  Future<void> switchUserAgent(UserAgentConfig config) async {
    var targetConfig = config;
    if (targetConfig.key == UserAgentPresets.custom.key) {
      final customUserAgent = targetConfig.userAgent.trim();
      if (customUserAgent.isEmpty) return;
      targetConfig = targetConfig.copyWith(userAgent: customUserAgent);
    }
    if (_currentUserAgentConfig.key == targetConfig.key &&
        _currentUserAgentConfig.userAgent == targetConfig.userAgent) {
      return;
    }

    _currentUserAgentConfig = targetConfig;
    _currentUserAgent = await UserAgentPresets.resolveUserAgent(targetConfig);
    await _saveUserAgentConfig(targetConfig);
    _notifyUserAgentChanged(targetConfig, _currentUserAgent);
    debugPrint('Data: UserAgent 已切换至: ${targetConfig.name}');
  }

  void addBaseUrlChangeListener(BaseUrlChangeListener listener) {
    _baseUrlChangeListeners.add(listener);
  }

  void removeBaseUrlChangeListener(BaseUrlChangeListener listener) {
    _baseUrlChangeListeners.remove(listener);
  }

  void addUserAgentChangeListener(UserAgentChangeListener listener) {
    _userAgentChangeListeners.add(listener);
  }

  void removeUserAgentChangeListener(UserAgentChangeListener listener) {
    _userAgentChangeListeners.remove(listener);
  }

  void clearListeners() {
    _baseUrlChangeListeners.clear();
    _userAgentChangeListeners.clear();
  }

  Future<void> _loadBaseUrlConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_baseUrlPrefsKey);
      if (savedKey == null) {
        _currentBaseUrlConfig = BaseUrlPresets.defaultConfig;
        return;
      }

      final preset = BaseUrlPresets.getByKey(savedKey);
      if (preset == null) {
        _currentBaseUrlConfig = BaseUrlPresets.defaultConfig;
        return;
      }

      if (preset.key != BaseUrlPresets.custom.key) {
        _currentBaseUrlConfig = preset;
        debugPrint('Data: 加载 baseUrl 配置: ${_currentBaseUrlConfig.url}');
        return;
      }

      final customUrl = prefs.getString(_customBaseUrlPrefsKey) ?? '';
      final normalizedUrl = _normalizeBaseUrl(customUrl);
      _currentBaseUrlConfig = normalizedUrl.isEmpty
          ? BaseUrlPresets.defaultConfig
          : preset.copyWith(url: normalizedUrl);
      debugPrint('Data: 加载 baseUrl 配置: ${_currentBaseUrlConfig.url}');
    } catch (e) {
      debugPrint('加载 baseUrl 配置失败: $e');
      _currentBaseUrlConfig = BaseUrlPresets.defaultConfig;
    }
  }

  Future<void> _loadUserAgentConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_userAgentPrefsKey);
      if (savedKey == null) {
        _currentUserAgentConfig = UserAgentPresets.defaultConfig;
        return;
      }

      final preset = UserAgentPresets.getByKey(savedKey);
      if (preset == null) {
        _currentUserAgentConfig = UserAgentPresets.defaultConfig;
        return;
      }

      if (preset.key != UserAgentPresets.custom.key) {
        _currentUserAgentConfig = preset;
        debugPrint('Data: 加载 UserAgent 配置: ${_currentUserAgentConfig.name}');
        return;
      }

      final customUserAgent =
          (prefs.getString(_customUserAgentPrefsKey) ?? '').trim();
      _currentUserAgentConfig = customUserAgent.isEmpty
          ? UserAgentPresets.defaultConfig
          : preset.copyWith(userAgent: customUserAgent);
      debugPrint('Data: 加载 UserAgent 配置: ${_currentUserAgentConfig.name}');
    } catch (e) {
      debugPrint('加载 UserAgent 配置失败: $e');
      _currentUserAgentConfig = UserAgentPresets.defaultConfig;
    }
  }

  Future<void> _saveBaseUrlConfig(BaseUrlConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_baseUrlPrefsKey, config.key);
      if (config.key == BaseUrlPresets.custom.key) {
        await prefs.setString(_customBaseUrlPrefsKey, config.url);
      }
    } catch (e) {
      debugPrint('保存 baseUrl 配置失败: $e');
    }
  }

  Future<void> _saveUserAgentConfig(UserAgentConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userAgentPrefsKey, config.key);
      if (config.key == UserAgentPresets.custom.key) {
        await prefs.setString(_customUserAgentPrefsKey, config.userAgent);
      }
    } catch (e) {
      debugPrint('保存 UserAgent 配置失败: $e');
    }
  }

  void _notifyBaseUrlChanged(BaseUrlConfig config) {
    for (final listener in _baseUrlChangeListeners) {
      listener(config);
    }
  }

  void _notifyUserAgentChanged(UserAgentConfig config, String userAgent) {
    for (final listener in _userAgentChangeListeners) {
      listener(config, userAgent);
    }
  }

  String _normalizeBaseUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null ||
        !parsed.hasScheme ||
        !(parsed.scheme == 'http' || parsed.scheme == 'https')) {
      return '';
    }
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }
}
