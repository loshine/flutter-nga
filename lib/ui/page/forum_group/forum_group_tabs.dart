import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/page/forum_group/favourite_forum_group_page.dart';

import 'forum_group_page.dart';

class ForumGroupTabsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Tab> _tabs = [Tab(text: "我的收藏")];
    List<Widget> _tabBarViews = [FavouriteForumGroupPage()];

    final list = Data().forumRepository.getForumGroups();

    _tabs.addAll(list.map((group) => Tab(text: group.name)));
    _tabBarViews.addAll(list.map((group) => ForumGroupPage(group: group)));

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
}
