import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/forum/favourite_forum_list_store.dart';
import 'package:flutter_nga/ui/widget/forum_grid_item_widget.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:provider/provider.dart';

class FavouriteForumGroupPage extends StatefulWidget {
  @override
  _FavouriteForumGroupState createState() => _FavouriteForumGroupState();
}

class _FavouriteForumGroupState extends State<FavouriteForumGroupPage> {
  late FavouriteForumListStore _store;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration()).then((_) {
      _store.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    _store = Provider.of<FavouriteForumListStore>(context);
    final size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = 96;
    final double itemWidth = size.width / 3;

    return Observer(builder: (_) {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: itemWidth / itemHeight,
        ),
        itemCount: _store.list.length,
        itemBuilder: (_, index) => ForumGridItemWidget(
          _store.list[index],
          onLongPress: () => _showDeleteDialog(_store.list[index].fid),
        ),
      );
    });
  }

  @override
  void deactivate() {
    _store.refresh();
    super.deactivate();
  }

  void _showDeleteDialog(int fid) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("是否删除该版面"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Routes.pop(context),
                child: Text("取消"),
              ),
              TextButton(
                onPressed: () {
                  _store.delete(fid).whenComplete(() => Routes.pop(context));
                },
                child: Text("确认"),
              ),
            ],
          );
        });
  }
}
