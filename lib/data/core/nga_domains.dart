/// NGA 自有域名（含所有子域），只有这些站点可以收到用户登录 Cookie。
///
/// 覆盖主站（bbs.nga.cn / ngabbs.com / ngabbs.cn / bbs.ngacn.cc）、
/// 图床（img.nga.178.com / img4.nga.178.com / img.ngacn.cc）和附件上传（img8.nga.cn）。
const List<String> ngaDomainSuffixes = [
  'nga.cn',
  'nga.178.com',
  'ngabbs.com',
  'ngabbs.cn',
  'ngacn.cc',
];

/// [host] 是否为 NGA 自有域名或其子域（不区分大小写）。
bool isNgaHost(String host) {
  final normalized = host.toLowerCase();
  if (normalized.isEmpty) return false;
  return ngaDomainSuffixes.any(
    (suffix) => normalized == suffix || normalized.endsWith('.$suffix'),
  );
}
