import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// UserAgent 配置实体类
class UserAgentConfig {
  const UserAgentConfig({
    required this.key,
    required this.name,
    required this.userAgent,
    this.isDefault = false,
    this.isDeviceSpecific = false,
  });

  /// 配置唯一标识
  final String key;

  /// 显示名称
  final String name;

  /// User-Agent 字符串
  final String userAgent;

  /// 是否为默认配置
  final bool isDefault;

  /// 是否根据设备自动选择（自动模式）
  final bool isDeviceSpecific;

  UserAgentConfig copyWith({
    String? key,
    String? name,
    String? userAgent,
    bool? isDefault,
    bool? isDeviceSpecific,
  }) {
    return UserAgentConfig(
      key: key ?? this.key,
      name: name ?? this.name,
      userAgent: userAgent ?? this.userAgent,
      isDefault: isDefault ?? this.isDefault,
      isDeviceSpecific: isDeviceSpecific ?? this.isDeviceSpecific,
    );
  }

  factory UserAgentConfig.fromJson(Map<String, dynamic> json) {
    return UserAgentConfig(
      key: json['key'] as String,
      name: json['name'] as String,
      userAgent: json['userAgent'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      isDeviceSpecific: json['isDeviceSpecific'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'userAgent': userAgent,
      'isDefault': isDefault,
      'isDeviceSpecific': isDeviceSpecific,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAgentConfig && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return 'UserAgentConfig(key: $key, name: $name, userAgent: $userAgent)';
  }
}

/// 预定义的 UserAgent 配置列表
class UserAgentPresets {
  UserAgentPresets._();

  /// 自动模式 - 根据当前设备自动选择
  static const UserAgentConfig auto = UserAgentConfig(
    key: 'auto',
    name: '自动（跟随设备）',
    userAgent: '',
    isDefault: true,
    isDeviceSpecific: true,
  );

  /// iOS 客户端
  static const UserAgentConfig apple = UserAgentConfig(
    key: 'apple',
    name: 'iOS 客户端',
    userAgent: 'NGA_skull/7.3.1(iPhone17,1;iOS 26.0)',
  );

  /// Android 客户端
  static const UserAgentConfig android = UserAgentConfig(
    key: 'android',
    name: 'Android 客户端',
    userAgent: 'Nga_Official/80024(Android12)',
  );

  /// 桌面浏览器
  static const UserAgentConfig desktop = UserAgentConfig(
    key: 'desktop',
    name: '桌面浏览器',
    userAgent:
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.64 Safari/537.36',
  );

  /// Windows Phone 客户端
  static const UserAgentConfig windowsPhone = UserAgentConfig(
    key: 'windows_phone',
    name: 'Windows Phone 客户端',
    userAgent: 'NGA_WP_JW/(;WINDOWS)',
  );

  /// 自定义 User-Agent（仅支持单条）
  static const UserAgentConfig custom = UserAgentConfig(
    key: 'custom',
    name: '自定义',
    userAgent: '',
  );

  /// 所有可用配置列表
  static const List<UserAgentConfig> all = [
    auto,
    apple,
    android,
    desktop,
    windowsPhone,
    custom,
  ];

  /// 获取默认配置
  static UserAgentConfig get defaultConfig =>
      all.firstWhere((config) => config.isDefault, orElse: () => auto);

  /// 根据 key 获取配置
  static UserAgentConfig? getByKey(String key) {
    try {
      return all.firstWhere((config) => config.key == key);
    } catch (_) {
      return null;
    }
  }

  /// 根据当前设备获取对应的 User-Agent 字符串
  static Future<String> getDeviceSpecificUserAgent() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return 'Nga_Official/90306([${androidInfo.brand} ${androidInfo.model}];Android${androidInfo.version.release})';
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return 'NGA_skull/7.3.1(${iosInfo.utsname.machine};iOS ${iosInfo.systemVersion})';
    } else {
      return 'Nga_Official/90306';
    }
  }

  /// 获取指定配置的实际 User-Agent 字符串
  static Future<String> resolveUserAgent(UserAgentConfig config) async {
    if (config.isDeviceSpecific) {
      return await getDeviceSpecificUserAgent();
    }
    return config.userAgent;
  }
}
