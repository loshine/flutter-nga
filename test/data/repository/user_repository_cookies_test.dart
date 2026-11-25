import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';

void main() {
  late Database db;
  late UserDataRepository repo;

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase(
      'user_repo_cookies_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    repo = UserDataRepository(db, Dio());
  });

  tearDown(() async {
    await db.close();
  });

  test('saveLoginCookies 解析完整凭据并保存默认用户', () async {
    final user = await repo.saveLoginCookies(
      'ngaPassportUid=12345; ngaPassportCid=secret_token_abc; ngaPassportUrlencodedUname=%B2%E2%CA%D4',
    );
    expect(user.uid, '12345');
    expect(user.cid, 'secret_token_abc');
    expect(user.nickname, '测试');
    expect(user.enabled, isTrue);
  });

  test('saveLoginCookies 缺少字段时仅提示缺失字段名且不泄露原始凭据', () async {
    const secretCid = 'super_secret_cid_value_99999';
    await expectLater(
      repo.saveLoginCookies('ngaPassportUid=12345; ngaPassportCid=$secretCid'),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('ngaPassportUrlencodedUname'),
            isNot(contains(secretCid)),
            isNot(contains('12345')),
          ),
        ),
      ),
    );
  });
}
