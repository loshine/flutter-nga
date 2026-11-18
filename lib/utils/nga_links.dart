import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/base_url_config.dart';

/// 网页版站点根地址（无结尾 `/`），跟随设置里选择的 baseUrl。
///
/// [baseUrl] 仅供测试注入；自定义地址为空时回落到默认站点。
String ngaSiteOrigin({String? baseUrl}) {
  var url = (baseUrl ?? Data().baseUrl).trim();
  if (url.isEmpty) url = BaseUrlPresets.defaultConfig.url;
  return url.replaceAll(RegExp(r'/+$'), '');
}

/// 帖子网页链接：`read.php?tid=`。
String topicWebUrl(int tid, {String? baseUrl}) {
  return '${ngaSiteOrigin(baseUrl: baseUrl)}/read.php?tid=$tid';
}

/// 楼层网页链接：主楼（pid 为 0 / 缺失）用帖子链接，其余用 `read.php?pid=` 定位到该楼。
String replyWebUrl({required int? tid, required int? pid, String? baseUrl}) {
  if (pid == null || pid <= 0) return topicWebUrl(tid ?? 0, baseUrl: baseUrl);
  return '${ngaSiteOrigin(baseUrl: baseUrl)}/read.php?pid=$pid';
}
