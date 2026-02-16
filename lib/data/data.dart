import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_nga/data/entity/base_url_config.dart';
import 'package:flutter_nga/data/entity/user_agent_config.dart';
import 'package:flutter_nga/data/repository/expression_repository.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';
import 'package:flutter_nga/data/repository/message_repository.dart';
import 'package:flutter_nga/data/repository/resource_repository.dart';
import 'package:flutter_nga/data/repository/topic_repository.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data {
  static final Data _singleton = Data._internal();

  Dio? _dio;

  Database? _database;

  Dio get dio => _dio!;

  Database get database => _database!;

  EmoticonRepository get emoticonRepository => EmoticonDataRepository();

  ForumRepository get forumRepository => ForumDataRepository(database);

  MessageRepository get messageRepository => MessageDataRepository();

  ResourceRepository get resourceRepository => ResourceDataRepository();

  TopicRepository get topicRepository => TopicDataRepository(database);

  UserRepository get userRepository => UserDataRepository(database);

  final _gbk = const GbkCodec(allowMalformed: true);

  /// 当前使用的 baseUrl 配置
  BaseUrlConfig _currentBaseUrlConfig = BaseUrlPresets.defaultConfig;

  BaseUrlConfig get currentBaseUrlConfig => _currentBaseUrlConfig;

  /// baseUrl 变更监听器
  final List<void Function(BaseUrlConfig)> _baseUrlChangeListeners = [];

  /// 当前使用的 UserAgent 配置
  UserAgentConfig _currentUserAgentConfig = UserAgentPresets.defaultConfig;

  UserAgentConfig get currentUserAgentConfig => _currentUserAgentConfig;

  /// 当前解析后的 UserAgent 字符串
  String _currentUserAgent = '';

  String get currentUserAgent => _currentUserAgent;

  /// UserAgent 变更监听器
  final List<void Function(UserAgentConfig, String)> _userAgentChangeListeners = [];

  factory Data() {
    return _singleton;
  }

  Data._internal();

  Future init() async {
    // 创建并初始化
    Directory appDocDir = await getApplicationDocumentsDirectory();
    DatabaseFactory dbFactory = databaseFactoryIo;

    String forumDbPath = [appDocDir.path, 'main.db'].join('/');
    _database = await dbFactory.openDatabase(forumDbPath);

    // 加载保存的 baseUrl 配置
    await _loadBaseUrlConfig();

    // 加载保存的 UserAgent 配置
    await _loadUserAgentConfig();

    _dio = Dio();

    // 配置dio实例
    _updateDioBaseUrl();
    dio.options.connectTimeout = const Duration(milliseconds: 10000); // 10s
    dio.options.receiveTimeout = const Duration(milliseconds: 10000); // 10s
//    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
//        (HttpClient client) {
//      client.findProxy = (uri) {
//        return "PROXY 192.168.50.88:8899";
//      };
//    };
    // 因为需要 gbk -> utf-8, 所以需要流的形式
    dio.options.responseType = ResponseType.bytes;

    // 设置 User-Agent
    _currentUserAgent = await UserAgentPresets.resolveUserAgent(_currentUserAgentConfig);
    _updateDioUserAgent();

    dio.options.headers["Accept-Encoding"] = "gzip";
    dio.options.headers["Cache-Control"] = "max-age=0";
    dio.options.headers["Connection"] = "Keep-Alive";

    dio.interceptors.add(InterceptorsWrapper(
      onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
        // 在请求被发送之前做一些事情
        // 如果你想完成请求并返回一些自定义数据，可以返回一个`Response`对象或返回`dio.resolve(data)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义数据data.
        //
        // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象，或返回`dio.reject(errMsg)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
        final user = await userRepository.getDefaultUser();
        if (user != null && options.headers["Cookie"] == null) {
          options.headers["Cookie"] =
              "$TAG_UID=${user.uid};$TAG_CID=${user.cid}";
        }
        return handler.next(options); //continue
      },
      onResponse: (
        Response response,
        ResponseInterceptorHandler handler,
      ) async {
        response.headers.set('Content-Type', "application/json; charset=GBK");
        String responseBody = _formatResponseBody(response);
        Map<String, dynamic>? map;
        try {
          map = json.decode(responseBody);
        } catch (err) {
          debugPrint(err.toString());
          response.data = responseBody;
          return handler.next(response);
        }
        DioException? dioError = _preHandleServerError(response, map!);
        if (dioError != null) {
          handler.reject(dioError);
        }
        // 上传附件的时候没有 data
        if (map.containsKey("data")) {
          response.data = map["data"];
        } else {
          response.data = map;
        }
        return handler.next(response);
      },
      onError: (
        DioException e,
        ErrorInterceptorHandler handler,
      ) async {
        debugPrint(e.toString());
        if (e.error is IOException) {
          return handler.next(DioException(
            requestOptions: e.requestOptions,
            error: "网络错误，请稍候重试。",
            type: DioExceptionType.unknown,
          ));
        }
        if (e.response != null && e.response!.data != null) {
          String responseBody = _formatResponseBody(e.response!);
          Map<String, dynamic>? map;
          try {
            map = json.decode(responseBody);
          } catch (err) {
            debugPrint(err.toString());
            return handler.next(e);
          }
          DioException? dioError = _preHandleServerError(e.response, map!);
          if (dioError != null) {
            return handler.next(dioError);
          }
        }
        return handler.next(e);
      },
    ));
    dio.interceptors.add(PrettyDioLogger());
  }

  /// 格式化响应,处理一些不兼容问题
  String _formatResponseBody(Response response) {
    // 在返回响应数据之前做一些预处理
    // gbk 编码 json 转 utf8
    List<int> bytes = response.data;
    String responseBody = _gbk.decode(bytes);
    // 处理一些可能导致错误的字符串
    // 去除 control characters
    responseBody = code_utils.stripLow(responseBody);
    // 直接制表符替换为 \t, \x 替换为 \\x
    responseBody = responseBody
        .replaceAll("\t", "\\t")
        .replaceAll("\\x", "\\\\x")
        .replaceAll(
            "<html><head><meta http-equiv='Content-Type' content='text/html; charset=GBK'></head><body><script>",
            "")
        .replaceAll("</script></body></html>", "")
        .replaceAll("window.script_muti_get_var_store=", "");
    if (response.requestOptions.path.contains("__lib=noti") &&
        response.requestOptions.path.contains("__act=get_all")) {
      // 使用 Dart 正则修复非标准 JSON 键名
      responseBody = code_utils.fixUnquotedJsonKeys(responseBody);
    }
    return responseBody;
  }

  /// 预处理服务器业务错误
  DioException? _preHandleServerError(
      Response? response, Map<String, dynamic> map) {
    if (response == null) return null;
    // 如果是 api 错误，抛出错误内容
    if (map["data"] is Map<String, dynamic> &&
        map["data"].containsKey("__MESSAGE")) {
      String? errorMessage = map["data"]["__MESSAGE"]["1"];
      return DioException(
        requestOptions: response.requestOptions,
        error: errorMessage,
        type: DioExceptionType.unknown,
      );
    }
    // 点赞时的错误
    if (map["error"] is Map) {
      Map<String, dynamic> err = map["error"];
      if (err["0"] is String) {
        return DioException(
          requestOptions: response.requestOptions,
          error: err["0"],
          type: DioExceptionType.unknown,
        );
      }
    }
    // 上传附件时的错误
    if (map["error"] is String) {
      String? errorMessage = map["error"];
      return DioException(
        requestOptions: response.requestOptions,
        error: errorMessage,
        type: DioExceptionType.unknown,
      );
    }
    return null;
  }

  /// 加载保存的 baseUrl 配置
  Future<void> _loadBaseUrlConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_baseUrlPrefsKey);

      if (savedKey != null) {
        final config = BaseUrlPresets.getByKey(savedKey);
        if (config != null) {
          _currentBaseUrlConfig = config;
          debugPrint('Data: 加载 baseUrl 配置: ${config.url}');
          return;
        }
      }
    } catch (e) {
      debugPrint('加载 baseUrl 配置失败: $e');
    }
    _currentBaseUrlConfig = BaseUrlPresets.defaultConfig;
  }

  static const String _baseUrlPrefsKey = 'base_url_config_key';

  /// 更新 Dio 的 baseUrl
  void _updateDioBaseUrl() {
    if (_dio != null) {
      _dio!.options.baseUrl = _currentBaseUrlConfig.url;
    }
  }

  /// 切换 baseUrl 配置
  Future<void> switchBaseUrl(BaseUrlConfig config) async {
    if (_currentBaseUrlConfig.key == config.key) return;

    _currentBaseUrlConfig = config;
    _updateDioBaseUrl();

    // 保存到本地存储
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_baseUrlPrefsKey, config.key);
    } catch (e) {
      debugPrint('保存 baseUrl 配置失败: $e');
    }

    // 通知监听器
    for (final listener in _baseUrlChangeListeners) {
      listener(config);
    }

    debugPrint('Data: BaseUrl 已切换至: ${config.url}');
  }

  /// 添加 baseUrl 变更监听器
  void addBaseUrlChangeListener(void Function(BaseUrlConfig) listener) {
    _baseUrlChangeListeners.add(listener);
  }

  /// 移除 baseUrl 变更监听器
  void removeBaseUrlChangeListener(void Function(BaseUrlConfig) listener) {
    _baseUrlChangeListeners.remove(listener);
  }

  /// 获取当前 baseUrl
  String get baseUrl => _currentBaseUrlConfig.url;

  /// 获取当前域名 (不含 https:// 和末尾斜杠)
  String get domain => _currentBaseUrlConfig.url
      .replaceAll(RegExp(r'^https?://'), '')
      .replaceAll(RegExp(r'/$'), '');

  static const String _userAgentPrefsKey = 'user_agent_config_key';

  /// 加载保存的 UserAgent 配置
  Future<void> _loadUserAgentConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_userAgentPrefsKey);

      if (savedKey != null) {
        final config = UserAgentPresets.getByKey(savedKey);
        if (config != null) {
          _currentUserAgentConfig = config;
          debugPrint('Data: 加载 UserAgent 配置: ${config.name}');
          return;
        }
      }
    } catch (e) {
      debugPrint('加载 UserAgent 配置失败: $e');
    }
    _currentUserAgentConfig = UserAgentPresets.defaultConfig;
  }

  /// 更新 Dio 的 UserAgent
  void _updateDioUserAgent() {
    if (_dio != null && _currentUserAgent.isNotEmpty) {
      _dio!.options.headers["User-Agent"] = _currentUserAgent;
    }
  }

  /// 切换 UserAgent 配置
  Future<void> switchUserAgent(UserAgentConfig config) async {
    if (_currentUserAgentConfig.key == config.key) return;

    _currentUserAgentConfig = config;
    _currentUserAgent = await UserAgentPresets.resolveUserAgent(config);
    _updateDioUserAgent();

    // 保存到本地存储
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userAgentPrefsKey, config.key);
    } catch (e) {
      debugPrint('保存 UserAgent 配置失败: $e');
    }

    // 通知监听器
    for (final listener in _userAgentChangeListeners) {
      listener(config, _currentUserAgent);
    }

    debugPrint('Data: UserAgent 已切换至: ${config.name}');
  }

  /// 添加 UserAgent 变更监听器
  void addUserAgentChangeListener(void Function(UserAgentConfig, String) listener) {
    _userAgentChangeListeners.add(listener);
  }

  /// 移除 UserAgent 变更监听器
  void removeUserAgentChangeListener(void Function(UserAgentConfig, String) listener) {
    _userAgentChangeListeners.remove(listener);
  }

  void close() async {
    // 关闭数据库
    _database?.close();
  }
}
