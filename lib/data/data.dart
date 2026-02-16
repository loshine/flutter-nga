import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

import 'package:flutter_nga/data/core/data_config_service.dart';
import 'package:flutter_nga/data/core/data_repositories.dart';
import 'package:flutter_nga/data/core/nga_dio_configurator.dart';
import 'package:flutter_nga/data/entity/base_url_config.dart';
import 'package:flutter_nga/data/entity/user_agent_config.dart';
import 'package:flutter_nga/data/repository/expression_repository.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';
import 'package:flutter_nga/data/repository/message_repository.dart';
import 'package:flutter_nga/data/repository/resource_repository.dart';
import 'package:flutter_nga/data/repository/topic_repository.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';

class Data {
  static final Data _singleton = Data._internal();

  final DataConfigService _configService = DataConfigService();

  Dio? _dio;
  Database? _database;
  DataRepositories? _repositories;
  Future<void>? _initFuture;

  factory Data() {
    return _singleton;
  }

  Data._internal();

  Dio get dio => _requireDio();

  Database get database => _requireDatabase();

  EmoticonRepository get emoticonRepository =>
      _requireRepositories().emoticonRepository;

  ForumRepository get forumRepository => _requireRepositories().forumRepository;

  MessageRepository get messageRepository =>
      _requireRepositories().messageRepository;

  ResourceRepository get resourceRepository =>
      _requireRepositories().resourceRepository;

  TopicRepository get topicRepository => _requireRepositories().topicRepository;

  UserRepository get userRepository => _requireRepositories().userRepository;

  BaseUrlConfig get currentBaseUrlConfig => _configService.currentBaseUrlConfig;

  UserAgentConfig get currentUserAgentConfig =>
      _configService.currentUserAgentConfig;

  String get currentUserAgent => _configService.currentUserAgent;

  String get baseUrl => _configService.baseUrl;

  String get domain => _configService.domain;

  Future<void> init() async {
    _initFuture ??= _initInternal();
    try {
      await _initFuture;
    } catch (_) {
      _initFuture = null;
      rethrow;
    }
  }

  Future<void> _initInternal() async {
    _database = await _openDatabase();
    await _configService.init();

    _dio = Dio();
    _applyBaseUrl(_configService.currentBaseUrlConfig);
    _applyUserAgent(
      _configService.currentUserAgentConfig,
      _configService.currentUserAgent,
    );

    _repositories = DataRepositories(database: database, dio: dio);
    final dioConfigurator = NgaDioConfigurator(
      () => userRepository.getDefaultUser(),
    );
    dioConfigurator.configure(dio);

    _configService.addBaseUrlChangeListener(_applyBaseUrl);
    _configService.addUserAgentChangeListener(_applyUserAgent);
  }

  Future<Database> _openDatabase() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final forumDbPath = [appDocDir.path, 'main.db'].join('/');
    return databaseFactoryIo.openDatabase(forumDbPath);
  }

  Future<void> switchBaseUrl(BaseUrlConfig config) {
    return _configService.switchBaseUrl(config);
  }

  Future<void> switchUserAgent(UserAgentConfig config) {
    return _configService.switchUserAgent(config);
  }

  void addBaseUrlChangeListener(BaseUrlChangeListener listener) {
    _configService.addBaseUrlChangeListener(listener);
  }

  void removeBaseUrlChangeListener(BaseUrlChangeListener listener) {
    _configService.removeBaseUrlChangeListener(listener);
  }

  void addUserAgentChangeListener(UserAgentChangeListener listener) {
    _configService.addUserAgentChangeListener(listener);
  }

  void removeUserAgentChangeListener(UserAgentChangeListener listener) {
    _configService.removeUserAgentChangeListener(listener);
  }

  void close() {
    _configService.removeBaseUrlChangeListener(_applyBaseUrl);
    _configService.removeUserAgentChangeListener(_applyUserAgent);
    _configService.clearListeners();
    _database?.close();

    _database = null;
    _dio = null;
    _repositories = null;
    _initFuture = null;
  }

  void _applyBaseUrl(BaseUrlConfig config) {
    _dio?.options.baseUrl = config.url;
  }

  void _applyUserAgent(UserAgentConfig _, String userAgent) {
    if (userAgent.isEmpty) {
      _dio?.options.headers.remove("User-Agent");
      return;
    }
    _dio?.options.headers["User-Agent"] = userAgent;
  }

  DataRepositories _requireRepositories() {
    final repositories = _repositories;
    if (repositories == null) {
      throw StateError('Data.init() must be called before using repositories.');
    }
    return repositories;
  }

  Dio _requireDio() {
    final instance = _dio;
    if (instance == null) {
      throw StateError('Data.init() must be called before using dio.');
    }
    return instance;
  }

  Database _requireDatabase() {
    final instance = _database;
    if (instance == null) {
      throw StateError('Data.init() must be called before using database.');
    }
    return instance;
  }
}
