import 'package:dio/dio.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobx/mobx.dart';

part 'send_message_store.g.dart';

class SendMessageStore = _SendMessageStore with _$SendMessageStore;

abstract class _SendMessageStore with Store {
  @observable
  List<String> contacts = [];

  @action
  add(String contact) {
    contacts.add(contact);
    this.contacts = contacts;
  }

  @action
  remove(String contact) {
    contacts.removeWhere((element) => element == contact);
    this.contacts = contacts;
  }

  Future<void> send(int? mid, String subject, String content) async {
    try {
      return await Data()
          .messageRepository
          .sendMessage(mid, contacts, subject, content);
    } catch (err) {
      if (err is DioError) {
        Fluttertoast.showToast(msg: err.message);
      } else {
        Fluttertoast.showToast(msg: err.toString());
      }
    }
  }
}
