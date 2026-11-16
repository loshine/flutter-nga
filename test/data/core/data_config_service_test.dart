import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/core/app_preferences.dart';
import 'package:flutter_nga/data/core/data_config_service.dart';
import 'package:flutter_nga/data/entity/base_url_config.dart';
import 'package:flutter_nga/data/entity/user_agent_config.dart';

import '../../test_utils/preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('official NGA domain is the default and the legacy host is hidden', () {
    expect(BaseUrlPresets.defaultConfig, BaseUrlPresets.ngaOfficial);
    expect(
      BaseUrlPresets.all.map((config) => config.key),
      isNot(contains(BaseUrlPresets.legacyNga178Key)),
    );
  });

  test('legacy NGA 178 preference migrates to the official domain', () async {
    // 旧版本通过旧 SharedPreferences API 写入的设置，会先迁移到新存储。
    setUpTestPreferences(
      legacy: {
        PrefsKeys.baseUrlConfigKey: BaseUrlPresets.legacyNga178Key,
        PrefsKeys.userAgentConfigKey: UserAgentPresets.desktop.key,
      },
    );
    final service = DataConfigService();

    await service.init();

    expect(service.currentBaseUrlConfig, BaseUrlPresets.ngaOfficial);
    expect(service.baseUrl, 'https://bbs.nga.cn/');
    expect(service.currentUserAgentConfig, UserAgentPresets.desktop);
    final preferences = await AppPreferences.instance();
    expect(
      preferences.getString(PrefsKeys.baseUrlConfigKey),
      BaseUrlPresets.ngaOfficial.key,
    );
  });
}
