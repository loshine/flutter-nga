import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/providers/message/send_message_provider.dart';
import 'package:flutter_nga/ui/page/send_message/contact_edit_dialog.dart';
import 'package:flutter_nga/utils/app_toast.dart';
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

    Future<void> send() async {
      try {
        await notifier.send(
          mid,
          subjectController.text,
          contentController.text,
        );
        if (context.mounted) Routes.pop(context);
      } catch (err) {
        AppToast.error(err.toString());
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? '新建短消息' : '回复消息'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            TextField(
              maxLines: 1,
              controller: subjectController,
              decoration: InputDecoration(
                labelText: "标题(可选)",
              ),
              keyboardType: TextInputType.text,
            ),
            if (isNew) ...[
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ContactEditDialog(
                      callback: (text) => notifier.add(text),
                    ),
                  );
                },
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
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.contacts.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: state.contacts.map((contact) {
                        return ActionChip(
                          label: Text(
                            contact,
                            style: TextStyle(color: Colors.white),
                          ),
                          color: WidgetStatePropertyAll(
                              Theme.of(context).primaryColor),
                          onPressed: () => notifier.remove(contact),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
            Expanded(
              child: TextField(
                maxLines: null,
                controller: contentController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "消息内容",
                ),
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '发送',
        onPressed: send,
        child: Icon(Icons.send),
      ),
    );
  }
}
