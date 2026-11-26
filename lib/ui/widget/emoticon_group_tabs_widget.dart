import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/emoticon.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';

class EmoticonGroupTabsWidget extends StatefulWidget {
  const EmoticonGroupTabsWidget({this.callback, super.key});
  final InputCallback? callback;

  @override
  State<EmoticonGroupTabsWidget> createState() => _EmoticonGroupTabsState();
}

class _EmoticonGroupTabsState extends State<EmoticonGroupTabsWidget> {
  final List<EmoticonGroup> _groups = [];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_groups.isEmpty) return const SizedBox.shrink();

    final isApple = context.isAppleStyle;
    if (isApple) {
      final colorScheme = Theme.of(context).colorScheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              itemCount: _groups.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final selected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 4,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _groups[index].name,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _EmoticonGroupWidget(
              key: ValueKey(_selectedIndex),
              group: _groups[_selectedIndex],
              callback: widget.callback,
            ),
          ),
        ],
      );
    }

    return DefaultTabController(
      length: _groups.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).textTheme.bodyLarge?.color,
            unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
            tabs: _groups.map((g) => Tab(text: g.name)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: _groups
                  .map(
                    (group) => _EmoticonGroupWidget(
                      group: group,
                      callback: widget.callback,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _groups.addAll(Data().emoticonRepository.getEmoticonGroups());
  }
}

class _EmoticonGroupWidget extends StatelessWidget {
  const _EmoticonGroupWidget({super.key, this.group, this.callback});

  final EmoticonGroup? group;
  final InputCallback? callback;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 6,
      children: group!.expressionList
          .map(
            (expression) => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => callback?.call(expression.content, "", false),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CachedNetworkImage(
                    imageUrl: expression.url,
                    placeholder: (context, url) =>
                        Image.asset('images/default_forum_icon.png'),
                    errorWidget: (context, url, err) =>
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
