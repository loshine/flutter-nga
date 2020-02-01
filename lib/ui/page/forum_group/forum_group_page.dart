import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/ui/widget/forum_grid_item_widget.dart';

class ForumGroupPage extends StatefulWidget {
  const ForumGroupPage({Key key, this.group}) : super(key: key);

  final ForumGroup group;

  @override
  State<StatefulWidget> createState() => _ForumGroupState();
}

class _ForumGroupState extends State<ForumGroupPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = 96;
    final double itemWidth = size.width / 3;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: itemWidth / itemHeight,
      ),
      itemCount: widget.group.forumList.length,
      itemBuilder: (_, index) =>
          ForumGridItemWidget(widget.group.forumList[index]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
