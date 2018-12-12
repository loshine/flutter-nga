import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/ui/forum/favourite_forum_group.dart';
import 'package:flutter_nga/ui/forum/forum_group.dart';

class ForumGroupTabsPage extends StatefulWidget {
  @override
  _ForumGroupTabsState createState() => _ForumGroupTabsState();
}

class _ForumGroupTabsState extends State<ForumGroupTabsPage> {
  List<ForumGroup> _forumGroupList = [];

  List<Widget> _getTabs() {
    List<Tab> tabs =
        _forumGroupList.map((group) => Tab(text: group.name)).toList();
    tabs.insert(0, Tab(text: "我的收藏"));
    return tabs;
  }

  TabBarView _getTabBarView() {
    List<Widget> views = _forumGroupList
        .map<Widget>((group) => ForumGroupPage(group: group))
        .toList();
    views.insert(0, FavouriteForumGroupPage());
    return TabBarView(children: views);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // 因为有多一个我的收藏，所以需要 +1
      length: _forumGroupList.length + 1,
      child: Scaffold(
        appBar: PreferredSize(
          child: AppBar(
            bottom: TabBar(
              isScrollable: true,
              tabs: _getTabs(),
            ),
          ),
          preferredSize: Size.fromHeight(kToolbarHeight),
        ),
        body: _getTabBarView(),
      ),
    );
  }

  @override
  void initState() {
    _forumGroupList.addAll(Data.forumRepository.getForumList());
    super.initState();
  }
}
