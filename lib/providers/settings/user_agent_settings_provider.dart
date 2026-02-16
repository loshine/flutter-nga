import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user_agent_config.dart';

/// UserAgent 设置状态
class UserAgentSettingsState {
  const UserAgentSettingsState({
    required this.currentConfig,
    required this.resolvedUserAgent,
    required this.isLoading,
  });

  final UserAgentConfig currentConfig;
  final String resolvedUserAgent;
  final bool isLoading;

  UserAgentSettingsState copyWith({
    UserAgentConfig? currentConfig,
    String? resolvedUserAgent,
    bool? isLoading,
  }) {
    return UserAgentSettingsState(
      currentConfig: currentConfig ?? this.currentConfig,
      resolvedUserAgent: resolvedUserAgent ?? this.resolvedUserAgent,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// UserAgent 设置 Notifier
class UserAgentSettingsNotifier extends Notifier<UserAgentSettingsState> {
  @override
  UserAgentSettingsState build() {
    // 监听 Data 中的 UserAgent 变更
    Data().addUserAgentChangeListener(_onUserAgentChanged);

    return UserAgentSettingsState(
      currentConfig: Data().currentUserAgentConfig,
      resolvedUserAgent: Data().currentUserAgent,
      isLoading: true,
    );
  }

  /// 初始化，从 Data 同步配置
  Future<void> init() async {
    final userAgent = await UserAgentPresets.resolveUserAgent(Data().currentUserAgentConfig);
    state = state.copyWith(
      currentConfig: Data().currentUserAgentConfig,
      resolvedUserAgent: userAgent,
      isLoading: false,
    );
  }

  /// Data 中 UserAgent 变更的回调
  void _onUserAgentChanged(UserAgentConfig config, String resolvedUserAgent) {
    if (state.currentConfig.key != config.key) {
      state = state.copyWith(
        currentConfig: config,
        resolvedUserAgent: resolvedUserAgent,
      );
    }
  }

  /// 切换 UserAgent 配置
  Future<void> setUserAgentConfig(UserAgentConfig config) async {
    if (state.currentConfig.key == config.key) return;

    state = state.copyWith(isLoading: true);

    try {
      // 调用 Data 的方法切换 UserAgent，Data 会处理持久化和通知
      await Data().switchUserAgent(config);

      final resolvedUserAgent = await UserAgentPresets.resolveUserAgent(config);
      state = state.copyWith(
        resolvedUserAgent: resolvedUserAgent,
        isLoading: false,
      );

      debugPrint('UserAgent 已切换至: ${config.name}');
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('切换 UserAgent 失败: $e');
      rethrow;
    }
  }

  /// 获取当前 UserAgent
  String get userAgent => state.resolvedUserAgent;
}

/// UserAgent 设置 Provider
final userAgentSettingsProvider =
    NotifierProvider<UserAgentSettingsNotifier, UserAgentSettingsState>(
  UserAgentSettingsNotifier.new,
);

/// 当前 UserAgent Provider (便于直接监听)
final currentUserAgentProvider = Provider<String>((ref) {
  return ref.watch(userAgentSettingsProvider.notifier).userAgent;
});
