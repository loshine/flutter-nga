import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/forum/forum_tag_list_provider.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef TagSelectedCallback = void Function(String tag);
typedef TagLoadCompleteCallback = void Function(List<TopicTag> tagList);

class ForumTagDialog extends HookConsumerWidget {
  const ForumTagDialog({
    required this.fid,
    super.key,
    this.tagList = const [],
    this.onSelected,
    this.onLoadComplete,
  });
  final int fid;
  final List<TopicTag> tagList;
  final TagSelectedCallback? onSelected;
  final TagLoadCompleteCallback? onLoadComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    usePostFrameEffect(() {
      final notifier = ref.read(forumTagListProvider.notifier);
      notifier.setList(tagList);

      if (tagList.isEmpty) {
        notifier.load(fid).then((value) {
          onLoadComplete?.call(value);
        }).catchError((err) {
          AppToast.error(err.message);
        });
      }
    }, [fid]);

    final tags = ref.watch(forumTagListProvider);

    return AlertDialog(
      title: Text("主题分类"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: tags.length,
          itemBuilder: (context, position) {
            final tag = tags[position].content;
            return InkWell(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "$tag",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: Dimen.titleMedium,
                  ),
                ),
              ),
              onTap: () {
                if (onSelected != null) {
                  onSelected!(tag);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
