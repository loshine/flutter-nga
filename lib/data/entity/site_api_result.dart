class SiteApiResult {
  const SiteApiResult(this.data, this.encode, this.time) : assert(data != null);

  final dynamic data;
  final String encode;
  final int time;
}
