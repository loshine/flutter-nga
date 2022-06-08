import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../utils/constant.dart';
import 'data.dart';

final httpClient = Dio(BaseOptions(
  baseUrl: DOMAIN,
  connectTimeout: 30000,
  receiveTimeout: 30000,
  responseType: ResponseType.bytes,
));

Future setUpHttpClient() async {
  await setUpDeviceInfoHeader();
  await setUpInterceptors();
}

Future setUpDeviceInfoHeader() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  httpClient.options.headers['User-Agent'] =
      "Nga_Official/90306([${androidInfo.brand} ${androidInfo.model}];"
      "Android${androidInfo.version.release})";
}

/// 用户信息请求头拦截器
final _userInfoHeaderInterceptor = InterceptorsWrapper(onRequest:
    (RequestOptions options, RequestInterceptorHandler handler) async {
  final user = await Data().userRepository.getDefaultUser();
  if (user != null && options.headers["Cookie"] == null) {
    options.headers["Cookie"] = "$TAG_UID=${user.uid};$TAG_CID=${user.cid}";
  }
  return handler.next(options);
});

/// GBK 编码响应体拦截器
final _gbk = const GbkCodec(allowMalformed: true);
final _gbkCodecInterceptor = InterceptorsWrapper(
    onResponse: (Response response, ResponseInterceptorHandler handler) {
  // gbk 编码转 utf8
  List<int> bytes = response.data;
  String responseBody = _gbk.decode(bytes);
  response.data = responseBody;
  handler.next(response);
}, onError: (DioError e, ErrorInterceptorHandler handler) {
  // gbk 编码转 utf8
  if (e.response != null) {
    List<int> bytes = e.response!.data;
    String responseBody = _gbk.decode(bytes);
    e.response!.data = responseBody;
  }
  handler.reject(e);
});

/// 使用 js 引擎修复一些不规范的 json 格式
JavascriptRuntime? _jsEngine;

JavascriptRuntime get jsEngine {
  if (_jsEngine == null) {
    _jsEngine = getJavascriptRuntime();
  }
  return _jsEngine!;
}

final _jsFormatJsonInterceptor = InterceptorsWrapper(
    onResponse: (Response response, ResponseInterceptorHandler handler) {
  if (response.requestOptions.path.contains("__lib=noti") &&
      response.requestOptions.path.contains("__act=get_all")) {
    response.data =
        jsEngine.evaluate('JSON.stringify(${response.data})').stringResult;
  }
  handler.next(response);
});

final _serviceErrorInterceptor = InterceptorsWrapper(
    onResponse: (Response response, ResponseInterceptorHandler handler) {
  handler.next(response);
});

Future setUpInterceptors() async {
  httpClient.interceptors.addAll([
    _userInfoHeaderInterceptor,
    _gbkCodecInterceptor,
    _jsFormatJsonInterceptor,
    _serviceErrorInterceptor,
    PrettyDioLogger(),
  ]);
}
