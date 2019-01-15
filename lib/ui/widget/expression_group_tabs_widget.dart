import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/expression.dart';
import 'package:flutter_nga/utils/palette.dart';

class ExpressionGroupTabsWidget extends StatefulWidget {
  @override
  _ExpressionGroupTabsState createState() => _ExpressionGroupTabsState();
}

class _ExpressionGroupTabsState extends State<ExpressionGroupTabsWidget> {
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
    var list = Data().expressionRepository.getExpressionGroups();
    debugPrint(list.toString());
    _tabs.addAll(list.map((group) => Tab(text: group.name)));
    _tabBarViews
        .addAll(list.map((group) => _ExpressionGroupWidget(group: group)));
  }
}

class _ExpressionGroupWidget extends StatelessWidget {
  _ExpressionGroupWidget({Key key, this.group}) : super(key: key);

  final ExpressionGroup group;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
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
