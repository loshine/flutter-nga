import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/providers/message/send_message_provider.dart';
import 'package:flutter_nga/ui/page/send_message/contact_edit_dialog.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SendMessagePage extends HookConsumerWidget {
  final int? mid;

  const SendMessagePage({super.key, this.mid});

  bool get isNew => mid == null || mid == 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectController = useTextEditingController();
    final contentController = useTextEditingController();
    final state = ref.watch(sendMessageProvider);
    final notifier = ref.read(sendMessageProvider.notifier);

    usePostFrameEffect(() {
      notifier.clear();
    }, [mid]);

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? '新建短消息' : '回复消息'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: _buildColumnChildren(
            context,
            state,
            notifier,
            subjectController,
            contentController,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '发送',
        onPressed: () => notifier
            .send(
              mid,
              subjectController.text,
              contentController.text,
            )
            .then(
              (value) => Routes.pop(context),
            ),
        child: Icon(Icons.send),
      ),
    );
  }

  void _showDialog(BuildContext context, SendMessageNotifier notifier) {
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
    BuildContext context,
    SendMessageState state,
    SendMessageNotifier notifier,
    TextEditingController subjectController,
    TextEditingController contentController,
  ) {
    final children = <Widget>[];
    children.add(TextField(
      maxLines: 1,
      controller: subjectController,
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
        onTap: () => _showDialog(context, notifier),
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
        controller: contentController,
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
