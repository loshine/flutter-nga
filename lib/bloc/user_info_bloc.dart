import 'package:flutter_nga/bloc/bloc_provider.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:rxdart/rxdart.dart';

class UserInfoBloc implements BlocBase {
  PublishSubject<UserInfo> _userInfoController = PublishSubject<UserInfo>();

  Stream<UserInfo> get outUserInfo => _userInfoController.stream;

  PublishSubject<String> _userInfoGetController = PublishSubject<String>();

  PublishSubject<String> _errorMessageController = PublishSubject<String>();

  Stream<String> get outErrorMessage => _errorMessageController.stream;

  UserInfoBloc(String username) {
    _userInfoGetController.stream.listen(_handleUserInfoGet);
    _userInfoGetController.sink.add(username);
  }

  @override
  void dispose() {
    _userInfoGetController.close();
    _userInfoController.close();
    _errorMessageController.close();
  }

  void _handleUserInfoGet(String username) {
    Data()
        .userRepository
        .getUserInfo(username)
        .then(_userInfoController.sink.add)
        .catchError((err) => _errorMessageController.sink.add(err.message));
  }
}
