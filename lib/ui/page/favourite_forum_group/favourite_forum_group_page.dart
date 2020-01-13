import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/favourite_forum_list.dart';
import 'package:flutter_nga/ui/page/forum/forum_grid_item_widget.dart';
import 'package:provider/provider.dart';

class FavouriteForumGroupPage extends StatefulWidget {
  @override
  _FavouriteForumGroupState createState() => _FavouriteForumGroupState();
}

class _FavouriteForumGroupState extends State<FavouriteForumGroupPage> {
  FavouriteForumList _store;

  @override
  void initState() {
    super.initState();
    _store.refresh();
  }

  @override
  Widget build(BuildContext context) {
    _store = Provider.of<FavouriteForumList>(context);
    final size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = 96;
    final double itemWidth = size.width / 3;

    return Observer(builder: (_) {
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: itemWidth / itemHeight,
        children:
            _store.list.map((forum) => ForumGridItemWidget(forum)).toList(),
      );
    });
  }

  @override
  void deactivate() {
    _store.refresh();
    super.deactivate();
  }
}
