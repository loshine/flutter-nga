import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/forum/forum_tag_list_provider.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef TagSelectedCallback = void Function(String tag);
typedef TagLoadCompleteCallback = void Function(List<TopicTag> tagList);

class ForumTagDialog extends ConsumerStatefulWidget {
  const ForumTagDialog({
    required this.fid,
    this.tagList = const [],
    this.onSelected,
    this.onLoadComplete,
    Key? key,
  }) : super(key: key);
  final int fid;
  final List<TopicTag> tagList;
  final TagSelectedCallback? onSelected;
  final TagLoadCompleteCallback? onLoadComplete;

  @override
  ConsumerState<ForumTagDialog> createState() => _ForumTagDialogState();
}

class _ForumTagDialogState extends ConsumerState<ForumTagDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(forumTagListProvider.notifier);
      notifier.setList(widget.tagList);

      if (widget.tagList.isEmpty) {
        notifier.load(widget.fid).then((value) {
          widget.onLoadComplete?.call(value);
        }).catchError((err) {
          Fluttertoast.showToast(msg: err.message);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tagList = ref.watch(forumTagListProvider);

    return AlertDialog(
      title: Text("主题分类"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: tagList.length,
          itemBuilder: (context, position) {
            final tag = tagList[position].content;
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
                if (widget.onSelected != null) {
                  widget.onSelected!(tag);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
