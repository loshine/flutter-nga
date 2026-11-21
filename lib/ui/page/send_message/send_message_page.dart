import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/message/send_message_provider.dart';
import 'package:flutter_nga/ui/page/send_message/contact_edit_dialog.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';

/// 校验发送内容，规则与网页版 js_message.js 一致；通过时返回 null。
String? validateMessage({
  required bool isNew,
  required String subject,
  required String content,
  required List<String> contacts,
}) {
  final s = subject.trim();
  final c = content.trim();
  if (isNew) {
    if (s.isEmpty) return '标题过短';
    if (s.length > 65) return '标题过长';
    if (contacts.isEmpty) return '未填写收信人';
  }
  if (c.isEmpty) return '内容过短';
  if (c.length > 20000) return '内容过长';
  return null;
}

class SendMessagePage extends HookConsumerWidget {
  final int? mid;

  const SendMessagePage({super.key, this.mid});

  bool get isNew => mid == null || mid == 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectController = useTextEditingController();
    final contentController = useTextEditingController();
    final sending = useState(false);
    final state = ref.watch(sendMessageProvider);
    final notifier = ref.read(sendMessageProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    usePostFrameEffect(() {
      notifier.clear();
    }, [mid]);

    Future<void> send() async {
      final error = validateMessage(
        isNew: isNew,
        subject: subjectController.text,
        content: contentController.text,
        contacts: state.contacts,
      );
      if (error != null) {
        AppToast.warning(error);
        return;
      }
      sending.value = true;
      try {
        await notifier.send(
          mid,
          subjectController.text.trim(),
          contentController.text.trim(),
        );
        AppToast.success('发送成功');
        if (context.mounted) Routes.pop(context, true);
      } catch (err) {
        AppToast.error(err);
      } finally {
        if (context.mounted) sending.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isNew ? '新建短消息' : '回复消息')),
      // 整页可滚动：小屏打开键盘时内容框不会被挤没，可以滚到输入位置；大屏居中收窄。
      body: ReadableListPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        builder: (context, padding) => ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: padding,
          children: [
            TextField(
              maxLines: 1,
              controller: subjectController,
              decoration: InputDecoration(labelText: isNew ? '标题' : '标题(可选)'),
              keyboardType: TextInputType.text,
            ),
            if (isNew) ...[
              InkWell(
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => ContactEditDialog(callback: notifier.add),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.supervisor_account_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '添加收信人(UID 或 用户名)',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.contacts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        for (final contact in state.contacts)
                          InputChip(
                            label: Text(contact),
                            onDeleted: () => notifier.remove(contact),
                            deleteButtonTooltipMessage: '移除',
                          ),
                      ],
                    ),
                  ),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('对话参与者只能看到自己的回复'),
                subtitle: const Text('每条回复只有发起人和回复者自己可见'),
                value: state.isolate,
                onChanged: notifier.setIsolate,
              ),
            ],
            TextField(
              key: const ValueKey('send_message_content'),
              minLines: 8,
              maxLines: null,
              controller: contentController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: '消息内容',
                alignLabelWithHint: true,
              ),
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '发送',
        onPressed: sending.value ? null : send,
        child: sending.value
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send),
      ),
    );
  }
}
