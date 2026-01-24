import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/providers/search/input_deletion_status_provider.dart';
import 'package:flutter_nga/providers/search/search_options_provider.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchPage extends HookConsumerWidget {
  final int? fid;

  const SearchPage({this.fid, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useTextEditingController();
    final inputVisible = ref.watch(inputDeletionStatusProvider);
    final searchOptions = ref.watch(searchOptionsProvider(fid));
    final searchOptionsNotifier = ref.read(searchOptionsProvider(fid).notifier);

    useEffect(() {
      void listener() {
        ref
            .read(inputDeletionStatusProvider.notifier)
            .setVisible(searchQuery.text.isNotEmpty);
      }

      searchQuery.addListener(listener);
      return () => searchQuery.removeListener(listener);
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchQuery,
          textInputAction: TextInputAction.search,
          onSubmitted: (text) => _onSearch(context, text, searchOptions, fid),
          maxLines: 1,
          decoration: InputDecoration(
            hintText: "搜索...",
            border: InputBorder.none,
            suffixIcon: inputVisible
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                    ),
                    onPressed: () => WidgetsBinding.instance
                        .addPostFrameCallback((_) => searchQuery.clear()),
                  )
                : Container(width: 0),
          ),
        ),
      ),
      body: _buildBody(context, ref, searchOptions, searchOptionsNotifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    SearchOptionsState state,
    SearchOptionsNotifier notifier,
  ) {
    final widgets = <Widget>[];
    final firstWidgets = Row(
      children: <Widget>[
        Padding(
          child: ChoiceChip(
            label: Text(
              "主题",
              style: TextStyle(
                color: state.firstRadio == FIRST_RADIO_TOPIC
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            selectedColor: Theme.of(context).primaryColor,
            selected: state.firstRadio == FIRST_RADIO_TOPIC,
            onSelected: (selected) =>
                notifier.checkFirstRadio(FIRST_RADIO_TOPIC),
          ),
          padding: EdgeInsets.only(left: 16),
        ),
        Padding(
          child: ChoiceChip(
            label: Text(
              "版块",
              style: TextStyle(
                color: state.firstRadio == FIRST_RADIO_FORUM
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            selectedColor: Theme.of(context).primaryColor,
            selected: state.firstRadio == FIRST_RADIO_FORUM,
            onSelected: (selected) =>
                notifier.checkFirstRadio(FIRST_RADIO_FORUM),
          ),
          padding: EdgeInsets.only(left: 16),
        ),
        Padding(
          child: ChoiceChip(
            label: Text(
              "用户",
              style: TextStyle(
                color: state.firstRadio == FIRST_RADIO_USER
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            selectedColor: Theme.of(context).primaryColor,
            selected: state.firstRadio == FIRST_RADIO_USER,
            onSelected: (selected) =>
                notifier.checkFirstRadio(FIRST_RADIO_USER),
          ),
          padding: EdgeInsets.only(left: 16),
        ),
      ],
    );
    widgets.add(firstWidgets);
    if (state.firstRadio == FIRST_RADIO_TOPIC) {
      if (fid != null) {
        widgets.add(Row(
          children: <Widget>[
            Padding(
              child: ChoiceChip(
                  label: Text(
                    "当前版块",
                    style: TextStyle(
                        color: state.topicRadio == TOPIC_RADIO_CURRENT_FORUM
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  selectedColor: Theme.of(context).primaryColor,
                  selected: state.topicRadio == TOPIC_RADIO_CURRENT_FORUM,
                  onSelected: (selected) =>
                      notifier.checkTopicRadio(TOPIC_RADIO_CURRENT_FORUM)),
              padding: EdgeInsets.only(left: 16),
            ),
            Padding(
              child: ChoiceChip(
                label: Text(
                  "全部版块",
                  style: TextStyle(
                    color: state.topicRadio == TOPIC_RADIO_ALL_FORUM
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                selectedColor: Theme.of(context).primaryColor,
                selected: state.topicRadio == TOPIC_RADIO_ALL_FORUM,
                onSelected: (selected) =>
                    notifier.checkTopicRadio(TOPIC_RADIO_ALL_FORUM),
              ),
              padding: EdgeInsets.only(left: 16),
            ),
          ],
        ));
      }
      widgets.add(Row(
        children: <Widget>[
          Padding(
            child: FilterChip(
              checkmarkColor: Colors.white,
              label: Text(
                "包括正文",
                style: TextStyle(
                  color: state.content
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              selectedColor: Theme.of(context).primaryColor,
              selected: state.content,
              onSelected: (selected) => notifier.checkContent(selected),
            ),
            padding: EdgeInsets.only(left: 16),
          ),
        ],
      ));
    }
    if (state.firstRadio == FIRST_RADIO_USER) {
      widgets.add(Row(
        children: <Widget>[
          Padding(
            child: ChoiceChip(
              label: Text(
                "用户名",
                style: TextStyle(
                  color: state.userRadio == USER_RADIO_NAME
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              selectedColor: Theme.of(context).primaryColor,
              selected: state.userRadio == USER_RADIO_NAME,
              onSelected: (selected) =>
                  notifier.checkUserRadio(USER_RADIO_NAME),
            ),
            padding: EdgeInsets.only(left: 16),
          ),
          Padding(
            child: ChoiceChip(
              label: Text(
                "用户ID",
                style: TextStyle(
                  color: state.userRadio == USER_RADIO_UID
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              selectedColor: Theme.of(context).primaryColor,
              selected: state.userRadio == USER_RADIO_UID,
              onSelected: (selected) => notifier.checkUserRadio(USER_RADIO_UID),
            ),
            padding: EdgeInsets.only(left: 16),
          ),
        ],
      ));
    }
    return ListView(
      children: widgets,
    );
  }

  void _onSearch(
      BuildContext context, String text, SearchOptionsState state, int? fid) {
    if (state.firstRadio == FIRST_RADIO_TOPIC) {
      if (fid == null) {
        Routes.navigateTo(
          context,
          "${Routes.SEARCH_TOPIC_LIST}?keyword=${code_utils.encodeParam(text)}&content=${state.content ? 1 : 0}",
        );
      } else {
        Routes.navigateTo(
          context,
          "${Routes.SEARCH_TOPIC_LIST}?keyword=${code_utils.encodeParam(text)}&fid=$fid&content=${state.content ? 1 : 0}",
        );
      }
    } else if (state.firstRadio == FIRST_RADIO_FORUM) {
      Routes.navigateTo(
        context,
        "${Routes.SEARCH_FORUM}?keyword=${code_utils.encodeParam(text)}",
      );
    } else if (state.firstRadio == FIRST_RADIO_USER) {
      if (state.userRadio == USER_RADIO_NAME) {
        Routes.navigateTo(
          context,
          "${Routes.USER}?name=${code_utils.encodeParam(text)}",
        );
      } else {
        Routes.navigateTo(context, "${Routes.USER}?uid=$text");
      }
    }
  }
}
