import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_nga/data/core/data_config_service.dart';
import 'package:flutter_nga/data/entity/base_url_config.dart';
import 'package:flutter_nga/data/entity/user_agent_config.dart';

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
    SharedPreferences.setMockInitialValues({
      'base_url_config_key': BaseUrlPresets.legacyNga178Key,
      'user_agent_config_key': UserAgentPresets.desktop.key,
    });
    final service = DataConfigService();

    await service.init();

    expect(service.currentBaseUrlConfig, BaseUrlPresets.ngaOfficial);
    expect(service.baseUrl, 'https://bbs.nga.cn/');
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('base_url_config_key'),
      BaseUrlPresets.ngaOfficial.key,
    );
  });
}
