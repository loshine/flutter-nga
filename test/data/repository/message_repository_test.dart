import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/repository/message_repository.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;

class _CapturingDio {
  _CapturingDio() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response<dynamic>(requestOptions: options, data: response),
          );
        },
      ),
    );
  }

  final Dio dio = Dio();
  final List<RequestOptions> requests = [];
  dynamic response = {'0': '操作成功'};

  /// 请求体参数按 GBK 编码，用同样的方式解码。
  Map<String, String> get lastBody => {
    for (final pair in (requests.last.data as String).split('&'))
      pair.split('=')[0]: code_utils.urlDecode(pair.split('=')[1]),
  };
}

void main() {
  late _CapturingDio api;
  late MessageDataRepository repository;

  setUp(() {
    api = _CapturingDio();
    repository = MessageDataRepository(api.dio);
  });

  test('新对话：收信人按 GBK 编码，可选隔离', () async {
    await repository.sendMessage(0, ['张三', ' 123 '], '标题', '内容', isolate: true);

    final raw = api.requests.last.data as String;
    expect(raw, contains('act=new'));
    expect(raw, contains('to=${code_utils.urlEncode('张三,123')}'));
    final body = api.lastBody;
    expect(body['to'], '张三,123');
    expect(body['subject'], '标题');
    expect(body['content'], '内容');
    expect(body['isolate'], '1');
  });

  test('回复不带收信人和隔离参数', () async {
    await repository.sendMessage(42, const [], '', '回复', isolate: true);

    final body = api.lastBody;
    expect(body['act'], 'reply');
    expect(body['mid'], '42');
    expect(body.containsKey('to'), isFalse);
    expect(body.containsKey('isolate'), isFalse);
  });

  test('邀请、退出、屏蔽、解除屏蔽对应网页版参数，并返回服务端提示', () async {
    expect(await repository.inviteToConversation(5, ['a', 'b']), '操作成功');
    expect(api.lastBody, containsPair('act', 'add'));
    expect(api.lastBody, containsPair('to', 'a,b'));
    expect(api.lastBody, containsPair('mid', '5'));

    await repository.leaveConversation(5, 9);
    expect(api.lastBody, containsPair('act', 'leave_topic'));
    expect(api.lastBody, containsPair('luid', '9'));

    await repository.addMessageBlock(['x', 'y']);
    expect(api.lastBody, containsPair('act', 'add_block'));
    expect(api.lastBody, containsPair('buids', 'x,y'));

    await repository.removeMessageBlock(7);
    expect(api.lastBody, containsPair('act', 'del_block'));
    expect(api.lastBody, containsPair('buids', '7'));
  });

  test('屏蔽列表跳过分页字段，无屏蔽时返回空列表', () async {
    api.response = {
      '0': {
        '0': {'uid': '7', 'username': 'bob'},
        '1': {'uid': 8},
        'currentPage': 1,
      },
    };
    expect(await repository.getMessageBlockList(), const [
      (uid: 7, username: 'bob'),
      (uid: 8, username: 'UID:8'),
    ]);

    api.response = {'0': '没有屏蔽的用户'};
    expect(await repository.getMessageBlockList(), isEmpty);
  });
}
