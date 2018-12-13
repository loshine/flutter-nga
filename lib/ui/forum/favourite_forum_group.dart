import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/ui/forum/forum_grid_item_widget.dart';

class FavouriteForumGroupPage extends StatefulWidget {
  @override
  _FavouriteForumGroupState createState() => _FavouriteForumGroupState();
}

class _FavouriteForumGroupState extends State<FavouriteForumGroupPage> {
  final List<Forum> _forumList = [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = 96;
    final double itemWidth = size.width / 3;

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: itemWidth / itemHeight,
      children: _forumList
          .map((forum) => ForumGridItemWidget(
                forum,
                onFavouriteChanged: (changed) => _favouriteChanged(changed),
              ))
          .toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    Data().forumRepository.getFavouriteList().then((list) {
      setState(() {
        _forumList.clear();
        _forumList.addAll(list);
      });
    });
  }

  void _favouriteChanged(bool changed) {
    if (changed) {
      _refreshData();
    }
  }
}
