import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/ui/forum/forum_group.dart';

class ForumGroupTabsPage extends StatefulWidget {
  @override
  ForumGroupTabsState createState() => ForumGroupTabsState();
}

class ForumGroupTabsState extends State<ForumGroupTabsPage> {
  List<ForumGroup> _forumGroupList = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _forumGroupList.length,
      child: Scaffold(
        appBar: PreferredSize(
          child: AppBar(
            bottom: TabBar(
              isScrollable: true,
              tabs: _forumGroupList
                  .map((group) => Tab(text: group.name))
                  .toList(),
            ),
          ),
          preferredSize: Size.fromHeight(kToolbarHeight),
        ),
        body: TabBarView(
            children: _forumGroupList
                .map((group) => ForumGroupPage(group: group))
                .toList()),
      ),
    );
  }

  @override
  void initState() {
    _forumGroupList.addAll(Data.forumRepository.getForumList());
    super.initState();
  }
}
