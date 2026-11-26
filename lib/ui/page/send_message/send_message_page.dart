import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/message/send_message_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/page/send_message/contact_edit_dialog.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';

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

  /// 是否以桌面居中模态弹窗形态呈现（取消多余顶部安全区并在导航栏左侧显示关闭按钮）。
  final bool asDialog;

  const SendMessagePage({super.key, this.mid, this.asDialog = false});

  bool get isNew => mid == null || mid == 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectController = useTextEditingController();
    final contentController = useTextEditingController();
    useListenable(subjectController);
    useListenable(contentController);
    final sending = useState(false);
    final state = ref.watch(sendMessageProvider);
    final notifier = ref.read(sendMessageProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final isApple = context.isAppleStyle;
    final isMacOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

    final hasEdits =
        subjectController.text.trim().isNotEmpty ||
        contentController.text.trim().isNotEmpty ||
        (isNew && state.contacts.isNotEmpty);

    usePostFrameEffect(() {
      notifier.clear();
    }, [mid]);

    Future<void> send() async {
      if (sending.value) return;
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
      final pageRoute = ModalRoute.of(context);
      sending.value = true;
      try {
        await notifier.send(
          mid,
          subjectController.text.trim(),
          contentController.text.trim(),
        );
        AppToast.success('发送成功');
        if (context.mounted) {
          final navigator = Navigator.of(context);
          if (pageRoute != null) navigator.popUntil((r) => r == pageRoute);
          navigator.pop(true);
        }
      } catch (err) {
        AppToast.error(err);
      } finally {
        if (context.mounted) sending.value = false;
      }
    }

    Future<void> confirmDiscard() async {
      final discard = await showDialog<bool>(
        context: context,
        builder: (_) => const M3ConfirmDialog(
          title: '放弃编辑？',
          content: '已输入的内容不会保存。',
          cancelText: '继续编辑',
          confirmText: '放弃',
          destructive: true,
        ),
      );
      if (discard == true && context.mounted) Navigator.of(context).pop();
    }

    final Widget? leading = asDialog
        ? IconButton(
            tooltip: '关闭',
            icon: Icon(AppIcons.close(context), size: 18),
            onPressed: () => Navigator.of(context).maybePop(),
          )
        : (isApple
              ? TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('取消'),
                )
              : null);

    return PopScope(
      canPop: !sending.value && !hasEdits,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || sending.value) return;
        confirmDiscard();
      },
      child: CallbackShortcuts(
        bindings: {
          SingleActivator(
            LogicalKeyboardKey.enter,
            meta: isMacOS,
            control: !isMacOS,
          ): send,
        },
        child: AppScaffold(
          embedded: asDialog,
          leading: leading,
          title: Text(isNew ? '新建短消息' : '回复消息'),
          actions: [
            if (asDialog && !isApple)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton.icon(
                  onPressed: sending.value ? null : send,
                  icon: sending.value
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, size: 16),
                  label: const Text('发送'),
                ),
              ),
          ],
          // 整页可滚动：小屏打开键盘时内容框不会被挤没，可以滚到输入位置；大屏居中收窄。
          body: ReadableListPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              isApple ? 12 : 8,
              16,
              (isApple || asDialog) ? 24 : 88,
            ),
            builder: (context, padding) => ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: padding,
              children: [
                TextField(
                  maxLines: 1,
                  controller: subjectController,
                  decoration: isApple
                      ? InputDecoration(
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          hintText: isNew ? '标题' : '标题（可选）',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        )
                      : InputDecoration(labelText: isNew ? '标题' : '标题(可选)'),
                  style: isApple
                      ? Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)
                      : null,
                  keyboardType: TextInputType.text,
                ),
                if (isApple)
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: colorScheme.outlineVariant,
                  ),
                if (isNew) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: sending.value
                        ? null
                        : () {
                            showDialog<void>(
                              context: context,
                              builder: (_) =>
                                  ContactEditDialog(callback: notifier.add),
                            );
                          },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isApple ? 12 : 16,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isApple
                                ? AppIcons.person(context)
                                : Icons.supervisor_account_rounded,
                            size: isApple ? 18 : 22,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '添加收信人(UID 或 用户名)',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
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
                                onDeleted: sending.value
                                    ? null
                                    : () => notifier.remove(contact),
                                deleteButtonTooltipMessage: '移除',
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (isApple)
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: colorScheme.outlineVariant,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '对话参与者只能看到自己的回复',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                '每条回复只有发起人和回复者自己可见',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        AppSwitch(
                          value: state.isolate,
                          onChanged: notifier.setIsolate,
                        ),
                      ],
                    ),
                  ),
                  if (isApple)
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: colorScheme.outlineVariant,
                    ),
                ],
                TextField(
                  key: const ValueKey('send_message_content'),
                  minLines: 8,
                  maxLines: null,
                  controller: contentController,
                  decoration: isApple
                      ? InputDecoration(
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          hintText: '输入消息内容…',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.65,
                            ),
                          ),
                        )
                      : const InputDecoration(
                          border: InputBorder.none,
                          labelText: '消息内容',
                          alignLabelWithHint: true,
                        ),
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
          primaryAction: asDialog && !isApple
              ? null
              : AppPrimaryAction(
                  tooltip: '发送',
                  loading: sending.value,
                  onPressed: send,
                  icon: const Icon(Icons.send),
                  appleIcon: Icon(AppIcons.send(context)),
                  appleLabel: '发送',
                ),
        ),
      ),
    );
  }
}
