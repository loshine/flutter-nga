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
                  final bottomPadding = MediaQuery.paddingOf(context).bottom;
                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      16 + bottomPadding,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 420,
                          mainAxisExtent: 76,
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
