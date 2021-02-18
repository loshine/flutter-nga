import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/store/conversation_list_store.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ConversationListPage extends StatefulWidget {
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationListPage> {
  final _store = ConversationListStore();
  RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return SmartRefresher(
          onLoading: _onLoading,
          controller: _refreshController,
          enablePullUp: _store.state.enablePullUp,
          onRefresh: _onRefresh,
          child: ListView.builder(
            itemCount: _store.state.list.length,
            itemBuilder: (context, index) =>
                ConversationItemWidget(conversation: _store.state.list[index]),
          ),
        );
      },
    );
  }

  _onRefresh() {
    _store.refresh().catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(
        msg: err.toString(),
        gravity: ToastGravity.CENTER,
      );
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  _onLoading() async {
    _store.loadMore().then((state) {
      if (state.enablePullUp) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }).catchError((_) => _refreshController.loadFailed());
  }
}

class ConversationItemWidget extends StatelessWidget {
  final Conversation conversation;

  const ConversationItemWidget({Key key, this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.subject,
                  style: TextStyle(
                    fontSize: Dimen.subheading,
                    color: Palette.colorTextPrimary,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          CommunityMaterialIcons.account,
                          color: Palette.colorIcon,
                          size: Dimen.icon,
                        ),
                      ),
                      Text(
                        conversation.realFromUsername,
                        style: TextStyle(
                          color: Palette.colorTextSecondary,
                          fontSize: Dimen.caption,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Opacity(
                          opacity: conversation.lastFromUsername == '' ? 0 : 1,
                          child: Icon(
                            CommunityMaterialIcons.account,
                            color: Palette.colorIcon,
                            size: Dimen.icon,
                          ),
                        ),
                      ),
                      Text(
                        conversation.lastFromUsername,
                        style: TextStyle(
                          color: Palette.colorTextSecondary,
                          fontSize: Dimen.caption,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        CommunityMaterialIcons.message,
                        color: Palette.colorIcon,
                        size: Dimen.icon,
                      ),
                    ),
                    Text(
                      "${conversation.posts}",
                      style: TextStyle(
                        color: Palette.colorTextSecondary,
                        fontSize: Dimen.caption,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: Icon(
                        CommunityMaterialIcons.clock,
                        size: Dimen.icon,
                        color: Palette.colorIcon,
                      ),
                    ),
                    Text(
                      "${codeUtils.formatPostDate(conversation.lastModify * 1000)}",
                      style: TextStyle(
                        fontSize: Dimen.caption,
                        color: Palette.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }
}
