import 'package:bloc/bloc.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/page/settings/account_management/account_management_event.dart';
import 'package:flutter_nga/ui/page/settings/account_management/account_management_state.dart';

class AccountManagementBloc
    extends Bloc<AccountManagementEvent, AccountManagementState> {
  @override
  AccountManagementState get initialState => AccountManagementState.initial();

  @override
  Stream<AccountManagementState> mapEventToState(
      AccountManagementEvent event) async* {
    if (event is AccountLoadEvent) {
      await Data().userRepository.getAllLoginUser();
    }
  }
}
