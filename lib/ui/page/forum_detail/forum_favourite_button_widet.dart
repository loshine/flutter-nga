import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/forum/favourite_forum_list_store.dart';
import 'package:flutter_nga/store/forum/favourite_forum_store.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ForumFavouriteButtonWidget extends StatefulWidget {
  const ForumFavouriteButtonWidget(
      {this.name, required this.fid, Key? key, this.type})
      : super(key: key);

  final String? name;
  final int fid;
  final int? type;

  @override
  State<StatefulWidget> createState() => _ForumFavouriteButtonState();
}

class _ForumFavouriteButtonState extends State<ForumFavouriteButtonWidget> {
  final FavouriteForumStore _favouriteForumStore = FavouriteForumStore();

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
            _favouriteForumStore
                .toggle(widget.fid, widget.name, widget.type)
                .then((_) {
              Provider.of<FavouriteForumListStore>(context, listen: false)
                  .refresh();
            }).catchError((err) {
              Fluttertoast.showToast(msg: err.toString());
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _favouriteForumStore.load(widget.fid, widget.name ?? "");
  }
}
