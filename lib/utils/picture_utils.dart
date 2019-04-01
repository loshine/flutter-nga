/// 是否是原图模式
bool isOriginalUrl(String url) {
  bool originalMode = true;
  if (url.endsWith(".thumb.jpg") ||
      url.endsWith(".thumb_s.jpg") ||
      url.endsWith(".thumb_ss.jpg") ||
      url.endsWith(".medium.jpg")) {
    originalMode = false;
  }
  return originalMode;
}

String getOriginalUrl(String url) {
  if (url.endsWith(".thumb.jpg")) {
    return url.substring(0, url.length - 10);
  } else if (url.endsWith(".thumb_s.jpg")) {
    return url.substring(0, url.length - 12);
  } else if (url.endsWith(".thumb_ss.jpg")) {
    return url.substring(0, url.length - 13);
  } else if (url.endsWith(".medium.jpg")) {
    return url.substring(0, url.length - 11);
  } else {
    return url;
  }
}
