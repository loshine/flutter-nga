const _THUMB_SUFFIX = ".thumb.jpg";
const _THUMB_S_SUFFIX = ".thumb_s.jpg";
const _THUMB_SS_SUFFIX = ".thumb_ss.jpg";
const _MEDIUM_SUFFIX = ".medium.jpg";

/// 是否是原图模式
bool isOriginalUrl(String url) {
  bool originalMode = true;
  if (url.endsWith(_THUMB_SUFFIX) ||
      url.endsWith(_THUMB_S_SUFFIX) ||
      url.endsWith(_THUMB_SS_SUFFIX) ||
      url.endsWith(_MEDIUM_SUFFIX)) {
    originalMode = false;
  }
  return originalMode;
}

String getOriginalUrl(String url) {
  if (url.endsWith(_THUMB_SUFFIX)) {
    return url.substring(0, url.length - _THUMB_SUFFIX.length);
  } else if (url.endsWith(_THUMB_S_SUFFIX)) {
    return url.substring(0, url.length - _THUMB_S_SUFFIX.length);
  } else if (url.endsWith(_THUMB_SS_SUFFIX)) {
    return url.substring(0, url.length - _THUMB_SS_SUFFIX.length);
  } else if (url.endsWith(_MEDIUM_SUFFIX)) {
    return url.substring(0, url.length - _MEDIUM_SUFFIX.length);
  } else {
    return url;
  }
}
