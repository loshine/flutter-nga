import 'package:flutter_nga/data/entity/user.dart';

class AccountManagementState {
  const AccountManagementState(this.accountList);

  final List<User> accountList;

  factory AccountManagementState.initial() => AccountManagementState([]);
}
