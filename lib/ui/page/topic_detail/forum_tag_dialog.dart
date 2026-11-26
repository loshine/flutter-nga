import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoButton;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/providers/forum/forum_tag_list_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';

typedef TagSelectedCallback = void Function(String tag);
typedef TagLoadCompleteCallback = void Function(List<TopicTag> tagList);

class ForumTagDialog extends HookConsumerWidget {
  const ForumTagDialog({
    required this.fid,
    super.key,
    this.tagList = const [],
    this.onSelected,
    this.onLoadComplete,
    this.embedded = false,
  });

  final int fid;
  final List<TopicTag> tagList;
  final TagSelectedCallback? onSelected;
  final TagLoadCompleteCallback? onLoadComplete;
  final bool embedded;

  static Future<void> show(
    BuildContext context, {
    required int fid,
    List<TopicTag> tagList = const [],
    TagSelectedCallback? onSelected,
    TagLoadCompleteCallback? onLoadComplete,
  }) {
    return showM3SelectionSheet<void>(
      context: context,
      builder: (sheetContext) => ForumTagDialog(
        fid: fid,
        tagList: tagList,
        embedded: true,
        onSelected: (tag) {
          onSelected?.call(tag);
          Navigator.of(sheetContext).pop();
        },
        onLoadComplete: onLoadComplete,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    usePostFrameEffect(() {
      final notifier = ref.read(forumTagListProvider.notifier);
      notifier.setList(tagList);

      if (tagList.isEmpty) {
        notifier
            .load(fid)
            .then((value) {
              onLoadComplete?.call(value);
            })
            .catchError((err) {
              AppToast.error(err);
            });
      }
    }, [fid]);

    final tags = ref.watch(forumTagListProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;

    final content = tags.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                '暂无可用主题分类',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags)
                if (isApple)
                  Material(
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 0.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onSelected?.call(tag.content),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          tag.content,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  ActionChip(
                    label: Text(tag.content),
                    onPressed: () => onSelected?.call(tag.content),
                  ),
            ],
          );

    if (embedded) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          isApple ? 20 : 24,
          isApple ? 16 : 4,
          isApple ? 20 : 24,
          16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题分类',
              style: (isApple ? textTheme.titleMedium : textTheme.headlineSmall)
                  ?.copyWith(
                    fontWeight: isApple ? FontWeight.w600 : null,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 14),
            Flexible(child: SingleChildScrollView(child: content)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isApple)
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '关闭',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('关闭'),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return M3Dialog(
      title: '主题分类',
      scrollable: true,
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
