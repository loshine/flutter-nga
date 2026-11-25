import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import 'package:flutter_nga/data/repository/topic_repository.dart';

void main() {
  group('TopicDataRepository.parsePostResultHtml', () {
    test('解析新版成功页的 msginfostart / msginfoend 文案', () {
      const html = '''
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0 Transitional//EN'>
<html>
<head><title>发贴完毕 ...</title></head>
<body><span class='sub'>&gt;</span> <!--msginfostart-->发贴完毕 ...<!--msginfoend--><br/><br/></body>
</html>
''';

      expect(TopicDataRepository.parsePostResultHtml(html), (
        isError: false,
        message: '发贴完毕 ...',
      ));
    });

    test('解析新版报错页的 ERROR / msgcodestart 与错误文案', () {
      const html = '''
<html>
<head><title>你没有登录</title></head>
<body>(ERROR:<!--msgcodestart-->2048<!--msgcodeend-->) <span class='sub'>&gt;</span> <!--msginfostart-->你没有登录<!--msginfoend--><br/><br/></body>
</html>
''';

      expect(TopicDataRepository.parsePostResultHtml(html), (
        isError: true,
        message: '你没有登录',
      ));
    });

    test('兼容旧版 span#aaa 与 title 兜底', () {
      const legacy =
          "<html><body><span style='color:#aaa'>&gt;</span>发贴完毕 ...<br/></body></html>";
      expect(TopicDataRepository.parsePostResultHtml(legacy), (
        isError: false,
        message: '发贴完毕 ...',
      ));

      const titleOnly =
          '<html><head><title>发表成功</title></head><body></body></html>';
      expect(TopicDataRepository.parsePostResultHtml(titleOnly), (
        isError: false,
        message: '发表成功',
      ));
    });

    test('非结果 HTML 页的未知 title 兜底返回错误，避免误报成功', () {
      const redirectHtml =
          '<html><head><title>NGA玩家社区</title></head><body><div>请重新登录</div></body></html>';
      expect(TopicDataRepository.parsePostResultHtml(redirectHtml), (
        isError: true,
        message: 'NGA玩家社区',
      ));

      const loginTitleHtml =
          '<html><head><title>登录</title></head><body></body></html>';
      expect(TopicDataRepository.parsePostResultHtml(loginTitleHtml), (
        isError: true,
        message: '登录',
      ));
    });

    test('空响应或无法识别结构返回错误', () {
      expect(
        TopicDataRepository.parsePostResultHtml('<html><body></body></html>'),
        (isError: true, message: '发帖失败'),
      );
    });
  });

  group('TopicDataRepository.createReply / createTopic', () {
    late Database database;
    late Dio dio;
    late String responseHtml;
    String? capturedData;

    setUp(() async {
      database = await databaseFactoryMemory.openDatabase(
        'topic-repo-test-${DateTime.now().microsecondsSinceEpoch}.db',
      );
      capturedData = null;
      responseHtml = '';
      dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              capturedData = options.data?.toString();
              handler.resolve(
                Response<String>(requestOptions: options, data: responseHtml),
              );
            },
          ),
        );
    });

    tearDown(() async {
      await database.close();
    });

    test('回帖成功返回服务端提示，且匿名参数带 & 分隔', () async {
      responseHtml = "<html><head><title>发贴完毕 ...</title></head><body><span class='sub'>&gt;</span> <!--msginfostart-->发贴完毕 ...<!--msginfoend--><br/></body></html>";
      final repo = TopicDataRepository(database, dio);

      final message = await repo.createReply(
        100,
        -7,
        '',
        '测试回帖内容',
        true,
        '',
        '',
      );

      expect(message, '发贴完毕 ...');
      expect(capturedData, contains('&fid=-7&anony=1'));
    });

    test('服务端返回 ERROR 页时抛出带提示文案的 DioException', () async {
      responseHtml = "<html><head><title>发表过于频繁</title></head><body>(ERROR:<!--msgcodestart-->31<!--msgcodeend-->) <span class='sub'>&gt;</span> <!--msginfostart-->发表过于频繁<!--msginfoend--><br/></body></html>";
      final repo = TopicDataRepository(database, dio);

      await expectLater(
        repo.createTopic(-7, '标题', '正文内容测试', false, '', ''),
        throwsA(isA<DioException>().having((e) => e.error, 'error', '发表过于频繁')),
      );
    });
  });
}
