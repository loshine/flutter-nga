import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';

import 'child_forum_item_widget.dart';

class ChildForumListPage extends StatefulWidget {
  final ForumInfo? forumInfo;

  const ChildForumListPage(this.forumInfo, {super.key});

  @override
  State<ChildForumListPage> createState() => _ChildForumListPage();
}

class _ChildForumListPage extends State<ChildForumListPage> {
  @override
  Widget build(BuildContext context) {
    final subForums = widget.forumInfo?.subForums;
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: subForums == null || subForums.isEmpty
          ? const ListStatusView(icon: Icons.forum_outlined, message: '暂无子版块')
          : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= kCompactBreakpoint) {
                  final mediaPadding = MediaQuery.paddingOf(context);
                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      math.max(16.0, mediaPadding.left),
                      12,
                      math.max(16.0, mediaPadding.right),
                      16 + mediaPadding.bottom,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 420,
                          mainAxisExtent: 84,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 4,
                        ),
                    itemCount: subForums.length,
                    itemBuilder: (_, index) =>
                        ChildForumItemWidget(subForums[index]),
                  );
                }
                return ReadableListPadding(
                  builder: (context, padding) => ListView.builder(
                    padding: padding,
                    itemCount: subForums.length,
                    itemBuilder: (_, index) =>
                        ChildForumItemWidget(subForums[index]),
                  ),
                );
              },
            ),
    );
  }
}
