import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/page/account_management/account_management_page.dart';

void main() {
  final a = CacheUser('1', 'c1', '账号A', true);
  final b = CacheUser('2', 'c2', '账号B', false);

  test('deleting a non-default account only mentions re-login', () {
    final message = deleteAccountMessage([a, b], b);
    expect(message, contains('重新登录'));
    expect(message, isNot(contains('切换')));
    expect(message, isNot(contains('未登录')));
  });

  test('deleting the default account names the next default', () {
    expect(deleteAccountMessage([a, b], a), contains('自动切换到「账号B」'));
  });

  test('deleting the last account warns about logging out', () {
    expect(deleteAccountMessage([a], a), contains('未登录'));
  });
}
