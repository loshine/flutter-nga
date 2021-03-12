import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/message/send_message_store.dart';
import 'package:flutter_nga/ui/page/send_message/contact_edit_dialog.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';

class SendMessagePage extends StatefulWidget {
  final int? mid;

  const SendMessagePage({Key? key, this.mid}) : super(key: key);

  @override
  _SendMessageState createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessagePage> {
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();

  final _store = SendMessageStore();

  bool get isNew => widget.mid == null || widget.mid == 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? '新建短消息' : '回复消息'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Observer(
          builder: (context) => Column(
            children: _buildColumnChildren(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '发送',
        onPressed: () => _store
            .send(
              widget.mid,
              _subjectController.text,
              _contentController.text,
            )
            .then(
              (value) => Routes.pop(context),
            ),
        child: Icon(
          Icons.send,
          color: Colors.white,
        ),
      ),
    );
  }

  _showDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return ContactEditDialog(
          callback: (text) => _store.add(text),
        );
      },
    );
  }

  List<Widget> _buildColumnChildren() {
    final children = <Widget>[];
    children.add(TextField(
      maxLines: 1,
      controller: _subjectController,
      decoration: InputDecoration(
        labelText: "标题(可选)",
      ),
      keyboardType: TextInputType.text,
    ));
    if (isNew) {
      children.add(InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.supervisor_account_rounded,
                color: Palette.colorIcon,
              ),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  '添加收信人(UID 或 用户名)',
                  style: TextStyle(color: Palette.colorTextSecondary),
                ),
              ),
            ],
          ),
        ),
        onTap: _showDialog,
      ));
      if (_store.contacts.isNotEmpty) {
        children.add(Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between line
              children: _store.contacts.map((content) {
                return ActionChip(
                  label: Text(
                    content,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Palette.colorPrimary,
                  onPressed: () => _store.remove(content),
                );
              }).toList(),
            ),
          ),
        ));
      }
    }
    children.add(Expanded(
      child: TextField(
        maxLines: null,
        controller: _contentController,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: "消息内容",
        ),
        keyboardType: TextInputType.multiline,
      ),
    ));
    return children;
  }
}
