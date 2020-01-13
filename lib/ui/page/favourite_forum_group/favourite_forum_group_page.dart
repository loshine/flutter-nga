import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/favourite_forum_list.dart';
import 'package:flutter_nga/ui/page/forum/forum_grid_item_widget.dart';
import 'package:provider/provider.dart';

class FavouriteForumGroupPage extends StatefulWidget {
  @override
  _FavouriteForumGroupState createState() => _FavouriteForumGroupState();
}

class _FavouriteForumGroupState extends State<FavouriteForumGroupPage>
    with AutomaticKeepAliveClientMixin {
  FavouriteForumList _store;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration()).then((_) {
      _store.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _store = Provider.of<FavouriteForumList>(context);
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
          itemBuilder: (_, index) => ForumGridItemWidget(_store.list[index]));
    });
  }

  @override
  void deactivate() {
    _store.refresh();
    super.deactivate();
  }

  @override
  bool get wantKeepAlive => true;
}
