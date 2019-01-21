import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';

typedef TagSelectedCallback = void Function(String tag);

class ForumTagDialog extends StatelessWidget {
  const ForumTagDialog({this.fid, this.onSelected, Key key})
      : assert(fid != null),
        super(key: key);
  final int fid;
  final TagSelectedCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text("主题分类"),
          Text(
            " (下滑有更多标签)",
            style: TextStyle(
                fontSize: Dimen.caption, color: Palette.colorTextSecondary),
          )
        ],
      ),
      content: FutureBuilder(
        future: Data().topicRepository.getTopicTagList(fid),
        builder:
            (BuildContext context, AsyncSnapshot<List<TopicTag>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Press button to start.');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Text('Awaiting result...');
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return SizedBox(
                  width: 0,
                  height: 240,
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, position) {
                      final tag = snapshot.data[position].content;
                      return InkWell(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                          child: Text("$tag"),
                        ),
                        onTap: () {
                          if (onSelected != null) {
                            onSelected(tag);
                          }
                        },
                      );
                    },
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
