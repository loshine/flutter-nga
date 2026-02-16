import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/base_url_config.dart';

/// BaseUrl 设置状态
class BaseUrlSettingsState {
  const BaseUrlSettingsState({
    required this.currentConfig,
    required this.isLoading,
  });

  final BaseUrlConfig currentConfig;
  final bool isLoading;

  BaseUrlSettingsState copyWith({
    BaseUrlConfig? currentConfig,
    bool? isLoading,
  }) {
    return BaseUrlSettingsState(
      currentConfig: currentConfig ?? this.currentConfig,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// BaseUrl 设置 Notifier
class BaseUrlSettingsNotifier extends Notifier<BaseUrlSettingsState> {
  @override
  BaseUrlSettingsState build() {
    // 监听 Data 中的 baseUrl 变更
    Data().addBaseUrlChangeListener(_onBaseUrlChanged);
    ref.onDispose(() {
      Data().removeBaseUrlChangeListener(_onBaseUrlChanged);
    });

    return BaseUrlSettingsState(
      currentConfig: Data().currentBaseUrlConfig,
      isLoading: true,
    );
  }

  /// 初始化，从 Data 同步配置
  Future<void> init() async {
    state = state.copyWith(
      currentConfig: Data().currentBaseUrlConfig,
      isLoading: false,
    );
  }

  /// Data 中 baseUrl 变更的回调
  void _onBaseUrlChanged(BaseUrlConfig config) {
    if (state.currentConfig.key != config.key ||
        state.currentConfig.url != config.url) {
      state = state.copyWith(currentConfig: config);
    }
  }

  /// 切换 BaseUrl 配置
  Future<void> setBaseUrlConfig(BaseUrlConfig config) async {
    if (state.currentConfig.key == config.key &&
        state.currentConfig.url == config.url) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // 调用 Data 的方法切换 baseUrl，Data 会处理持久化和通知
      await Data().switchBaseUrl(config);

      state = state.copyWith(isLoading: false);

      debugPrint('BaseUrl 已切换至: ${config.url}');
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('切换 BaseUrl 失败: $e');
      rethrow;
    }
  }

  /// 获取当前 baseUrl
  String get baseUrl => state.currentConfig.url;

  /// 获取当前 baseUrl (不含末尾斜杠)
  String get baseUrlWithoutTrailingSlash {
    final url = state.currentConfig.url;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// 获取当前域名 (不含 https://)
  String get domain {
    final url = state.currentConfig.url;
    return url
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');
  }
}

/// BaseUrl 设置 Provider
final baseUrlSettingsProvider =
    NotifierProvider<BaseUrlSettingsNotifier, BaseUrlSettingsState>(
  BaseUrlSettingsNotifier.new,
);

/// 当前 baseUrl Provider (便于直接监听)
final currentBaseUrlProvider = Provider<String>((ref) {
  return ref.watch(baseUrlSettingsProvider.notifier).baseUrl;
});

/// 当前域名 Provider
final currentDomainProvider = Provider<String>((ref) {
  return ref.watch(baseUrlSettingsProvider.notifier).domain;
});
