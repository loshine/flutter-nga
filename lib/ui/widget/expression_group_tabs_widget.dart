import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/emoticon.dart';
import 'package:flutter_nga/utils/palette.dart';

class EmoticonGroupTabsWidget extends StatefulWidget {
  @override
  _EmoticonGroupTabsState createState() => _EmoticonGroupTabsState();
}

class _EmoticonGroupTabsState extends State<EmoticonGroupTabsWidget> {
  List<Tab> _tabs = [];
  List<Widget> _tabBarViews = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TabBarView(children: _tabBarViews),
          ),
          TabBar(
            isScrollable: true,
            labelColor: Palette.colorTextPrimary,
            unselectedLabelColor: Palette.colorTextSecondary,
            tabs: _tabs,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    var list = Data().emoticonRepository.getEmoticonGroups();
    debugPrint(list.toString());
    _tabs.addAll(list.map((group) => Tab(text: group.name)));
    _tabBarViews
        .addAll(list.map((group) => _EmoticonGroupWidget(group: group)));
  }
}

class _EmoticonGroupWidget extends StatelessWidget {
  _EmoticonGroupWidget({Key key, this.group}) : super(key: key);

  final EmoticonGroup group;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 6,
      children: group.expressionList
          .map(
            (expression) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => debugPrint(expression.content),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CachedNetworkImage(
                        imageUrl: expression.url,
                        placeholder:
                            Image.asset('images/default_forum_icon.png'),
                        errorWidget:
                            Image.asset('images/default_forum_icon.png'),
                      ),
                    ),
                  ),
                ),
          )
          .toList(),
    );
  }
}
