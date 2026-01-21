import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/message/send_message_provider.dart';
import 'package:flutter_nga/ui/page/send_message/contact_edit_dialog.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SendMessagePage extends ConsumerStatefulWidget {
  final int? mid;

  const SendMessagePage({Key? key, this.mid}) : super(key: key);

  @override
  ConsumerState<SendMessagePage> createState() => _SendMessageState();
}

class _SendMessageState extends ConsumerState<SendMessagePage> {
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();

  bool get isNew => widget.mid == null || widget.mid == 0;

  @override
  void initState() {
    super.initState();
    // Clear contacts when starting new message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sendMessageProvider.notifier).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendMessageProvider);
    final notifier = ref.read(sendMessageProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? '新建短消息' : '回复消息'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: _buildColumnChildren(state, notifier),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '发送',
        onPressed: () => notifier
            .send(
              widget.mid,
              _subjectController.text,
              _contentController.text,
            )
            .then(
              (value) => Routes.pop(context),
            ),
        child: Icon(Icons.send),
      ),
    );
  }

  void _showDialog(SendMessageNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) {
        return ContactEditDialog(
          callback: (text) => notifier.add(text),
        );
      },
    );
  }

  List<Widget> _buildColumnChildren(
      SendMessageState state, SendMessageNotifier notifier) {
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
                color: Theme.of(context).iconTheme.color,
              ),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  '添加收信人(UID 或 用户名)',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ),
            ],
          ),
        ),
        onTap: () => _showDialog(notifier),
      ));
      if (state.contacts.isNotEmpty) {
        children.add(Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between line
              children: state.contacts.map((content) {
                return ActionChip(
                  label: Text(
                    content,
                    style: TextStyle(color: Colors.white),
                  ),
                  color: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                  onPressed: () => notifier.remove(content),
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
