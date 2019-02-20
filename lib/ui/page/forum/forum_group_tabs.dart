import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/page/forum/favourite_forum_group.dart';
import 'package:flutter_nga/ui/page/forum/forum_group.dart';
class ForumGroupTabsPage extends StatefulWidget {
  @override
  _ForumGroupTabsState createState() => _ForumGroupTabsState();
}

class _ForumGroupTabsState extends State<ForumGroupTabsPage> {
  List<Tab> _tabs = [Tab(text: "我的收藏")];
  List<Widget> _tabBarViews = [FavouriteForumGroupPage()];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: PreferredSize(
          child: AppBar(
            bottom: TabBar(
              isScrollable: true,
              tabs: _tabs,
            ),
          ),
          preferredSize: Size.fromHeight(kToolbarHeight),
        ),
        body: TabBarView(children: _tabBarViews),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    var list = Data().forumRepository.getForumGroups();
    _tabs.addAll(list.map((group) => Tab(text: group.name)));
    _tabBarViews.addAll(list.map((group) => ForumGroupPage(group: group)));
  }
}
