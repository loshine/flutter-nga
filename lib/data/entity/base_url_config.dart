/// BaseUrl 配置实体类
class BaseUrlConfig {
  const BaseUrlConfig({
    required this.key,
    required this.name,
    required this.url,
    this.isDefault = false,
  });

  /// 配置唯一标识
  final String key;

  /// 显示名称
  final String name;

  /// 基础 URL
  final String url;

  /// 是否为默认配置
  final bool isDefault;

  BaseUrlConfig copyWith({
    String? key,
    String? name,
    String? url,
    bool? isDefault,
  }) {
    return BaseUrlConfig(
      key: key ?? this.key,
      name: name ?? this.name,
      url: url ?? this.url,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory BaseUrlConfig.fromJson(Map<String, dynamic> json) {
    return BaseUrlConfig(
      key: json['key'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'url': url,
      'isDefault': isDefault,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseUrlConfig && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return 'BaseUrlConfig(key: $key, name: $name, url: $url, isDefault: $isDefault)';
  }
}

/// 预定义的 BaseUrl 配置列表
class BaseUrlPresets {
  BaseUrlPresets._();

  /// NGA 178 域名 (默认)
  static const BaseUrlConfig nga178 = BaseUrlConfig(
    key: 'nga_178',
    name: 'NGA 178 (nga.178.com)',
    url: 'https://nga.178.com/',
    isDefault: true,
  );

  /// NGA 官方主站 (bbs.nga.cn)
  static const BaseUrlConfig ngaOfficial = BaseUrlConfig(
    key: 'nga_official',
    name: 'NGA 官方 (bbs.nga.cn)',
    url: 'https://bbs.nga.cn/',
  );

  /// NGA 新域名 (ngabbs.cn)
  static const BaseUrlConfig ngaBbs = BaseUrlConfig(
    key: 'nga_bbs',
    name: 'NGA 国内 (ngabbs.cn)',
    url: 'https://ngabbs.cn/',
  );

  /// 自定义地址（仅支持单条）
  static const BaseUrlConfig custom = BaseUrlConfig(
    key: 'custom',
    name: '自定义',
    url: '',
  );

  /// 所有可用配置列表
  static const List<BaseUrlConfig> all = [
    nga178,
    ngaOfficial,
    ngaBbs,
    custom,
  ];

  /// 获取默认配置
  static BaseUrlConfig get defaultConfig =>
      all.firstWhere((config) => config.isDefault, orElse: () => nga178);

  /// 根据 key 获取配置
  static BaseUrlConfig? getByKey(String key) {
    try {
      return all.firstWhere((config) => config.key == key);
    } catch (_) {
      return null;
    }
  }
}
