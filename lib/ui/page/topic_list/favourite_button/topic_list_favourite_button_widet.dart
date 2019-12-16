import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nga/ui/page/topic_list/favourite_button/topic_list_favourite_button_bloc.dart';
import 'package:flutter_nga/ui/page/topic_list/favourite_button/topic_list_favourite_button_state.dart';

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
  final _bloc = TopicListFavouriteButtonBloc();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (context, TopicListFavouriteButtonState state) {
        return IconButton(
          icon: Icon(
            state.isFavourite ? Icons.star : Icons.star_border,
            color: Colors.white,
          ),
          onPressed: () => _bloc.onFavouriteChanged(
            !state.isFavourite,
            widget.fid,
            widget.name,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _bloc.onLoadFavourite(widget.fid, widget.name);
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }
}
