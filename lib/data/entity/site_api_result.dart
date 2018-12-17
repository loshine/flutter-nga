class SiteApiResult {
  const SiteApiResult(this.data, this.encode, this.time)
      : assert(data != null),
        assert(encode != null),
        assert(time != null);

  final dynamic data;
  final String encode;
  final int time;
}
