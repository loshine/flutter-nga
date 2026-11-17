/// NGA 自有域名（含所有子域），只有这些站点可以收到用户登录 Cookie。
///
/// 覆盖主站（bbs.nga.cn / ngabbs.com / ngabbs.cn / bbs.ngacn.cc）、
/// 图床（img.nga.cn / img4.nga.cn，以及已失效的 img.nga.178.com / img.ngacn.cc）
/// 和附件上传（img8.nga.cn）。
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

/// 图床根地址：附件、头像等在 `img.nga.cn`，表情、勋章、版块图标在 `img4.nga.cn`。
///
/// 旧图床 `img(4).nga.178.com` / `img(4).ngacn.cc` 已无法访问，仍可能出现在
/// 帖子正文或接口返回中，统一经 [normalizeNgaImageUrl] 改写。
const ngaImageOrigin = 'https://img.nga.cn';
const ngaImage4Origin = 'https://img4.nga.cn';
const ngaAttachmentBase = '$ngaImageOrigin/attachments';

final _legacyImageOrigin = RegExp(
  r'^(?:https?:)?//(img4?)\.(?:nga\.178\.com|ngacn\.cc)(?=[/?#:]|$)',
  caseSensitive: false,
);

/// 把失效旧图床的地址改写到 nga.cn 对应子域（路径不变，统一 https），其他 URL 原样返回。
String normalizeNgaImageUrl(String url) {
  return url.replaceFirstMapped(_legacyImageOrigin, (m) {
    return m[1]!.toLowerCase() == 'img4' ? ngaImage4Origin : ngaImageOrigin;
  });
}
