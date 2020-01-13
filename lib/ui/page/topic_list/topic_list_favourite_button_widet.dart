import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/favourite_forum.dart';
import 'package:flutter_nga/store/favourite_forum_list.dart';
import 'package:provider/provider.dart';

class TopicListFavouriteButtonWidget extends StatefulWidget {
  const TopicListFavouriteButtonWidget({this.name, this.fid, Key key})
      : assert(fid != null),
        super(key: key);

  final String name;
  final int fid;

  @override
  State<StatefulWidget> createState() => _TopicListFavouriteButtonState();
}

class _TopicListFavouriteButtonState
    extends State<TopicListFavouriteButtonWidget> {
  final FavouriteForum _favouriteForumStore = FavouriteForum();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return IconButton(
          icon: Icon(
            _favouriteForumStore.isFavourite ? Icons.star : Icons.star_border,
            color: Colors.white,
          ),
          onPressed: () {
            _favouriteForumStore.toggle(widget.fid, widget.name).then((_) {
              Provider.of<FavouriteForumList>(context, listen: false).refresh();
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _favouriteForumStore.load(widget.fid, widget.name);
  }
}
