import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/store/forum/forum_tag_list_store.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:fluttertoast/fluttertoast.dart';

typedef TagSelectedCallback = void Function(String tag);
typedef TagLoadCompleteCallback = void Function(List<TopicTag> tagList);

class ForumTagDialog extends StatefulWidget {
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
  _ForumTagDialogState createState() => _ForumTagDialogState();
}

class _ForumTagDialogState extends State<ForumTagDialog> {
  final _store = ForumTagListStore();

  @override
  void initState() {
    _store.setList(widget.tagList);

    if (widget.tagList.isEmpty) {
      _store.load(widget.fid).then((value) {
        widget.onLoadComplete?.call(value);
      }).catchError((err) {
        if (err is DioError) {
          Fluttertoast.showToast(
              msg: err.message, gravity: ToastGravity.CENTER);
        } else {
          Fluttertoast.showToast(
              msg: err.toString(), gravity: ToastGravity.CENTER);
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("主题分类"),
      content: Observer(builder: (context) {
        return SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: _store.tagList.length,
            itemBuilder: (context, position) {
              final tag = _store.tagList[position].content;
              return InkWell(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "$tag",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1?.color,
                      fontSize: Dimen.subheading,
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
        );
      }),
    );
  }
}
