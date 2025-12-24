import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/foundation.dart';
// TODO: flutter_js 已移除，鸿蒙系统不支持，待后续实现
// import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../utils/constant.dart';
import 'data.dart';

final httpClient = Dio(BaseOptions(
  baseUrl: DOMAIN,
  connectTimeout: const Duration(milliseconds: 30000),
  receiveTimeout: const Duration(milliseconds: 30000),
  responseType: ResponseType.bytes,
));

Future setUpHttpClient() async {
  await setUpDeviceInfoHeader();
  await setUpInterceptors();
}

Future setUpDeviceInfoHeader() async {
  httpClient.options.headers['User-Agent'] = await _buildUserAgent();
}

/// 构建 User-Agent 字符串，支持多平台
Future<String> _buildUserAgent() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  try {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      return "Nga_Official/90306([${androidInfo.brand} ${androidInfo.model}];"
          "Android${androidInfo.version.release})";
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return "Nga_Official/90306([Apple ${iosInfo.model}];"
          "iOS${iosInfo.systemVersion})";
    } else {
      // 鸿蒙系统或其他平台
      final deviceInfoData = await deviceInfo.deviceInfo;
      return "Nga_Official/90306([${deviceInfoData.data['brand'] ?? 'Unknown'} "
          "${deviceInfoData.data['model'] ?? 'Device'}];HarmonyOS)";
    }
  } catch (e) {
    debugPrint('Failed to get device info: $e');
    return "Nga_Official/90306([Unknown Device];Unknown)";
  }
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
}, onError: (DioException e, ErrorInterceptorHandler handler) {
  // gbk 编码转 utf8
  if (e.response != null) {
    List<int> bytes = e.response!.data;
    String responseBody = _gbk.decode(bytes);
    e.response!.data = responseBody;
  }
  handler.reject(e);
});

/// 使用 js 引擎修复一些不规范的 json 格式
// TODO: flutter_js 已移除，待后续实现
// JavascriptRuntime? _jsEngine;
//
// JavascriptRuntime get jsEngine {
//   if (_jsEngine == null) {
//     _jsEngine = getJavascriptRuntime();
//   }
//   return _jsEngine!;
// }

final _jsFormatJsonInterceptor = InterceptorsWrapper(
    onResponse: (Response response, ResponseInterceptorHandler handler) {
  if (response.requestOptions.path.contains("__lib=noti") &&
      response.requestOptions.path.contains("__act=get_all")) {
    // TODO: flutter_js 已移除，通知JSON格式化待后续实现
    // response.data =
    //     jsEngine.evaluate('JSON.stringify(${response.data})').stringResult;
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
