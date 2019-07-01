abstract class AccountManagementEvent {
  const AccountManagementEvent();

  factory AccountManagementEvent.load() => AccountLoadEvent();

  factory AccountManagementEvent.delete(String uid) => AccountDeleteEvent(uid);

  factory AccountManagementEvent.deleteAll() => AccountDeleteAllEvent();

  factory AccountManagementEvent.activate(String uid) =>
      AccountActivateEvent(uid);
}

class AccountLoadEvent extends AccountManagementEvent {
  const AccountLoadEvent();
}

class AccountDeleteEvent extends AccountManagementEvent {
  final String uid;

  const AccountDeleteEvent(this.uid);
}

class AccountDeleteAllEvent extends AccountManagementEvent {
  const AccountDeleteAllEvent();
}

class AccountActivateEvent extends AccountManagementEvent {
  final String uid;

  const AccountActivateEvent(this.uid);
}
