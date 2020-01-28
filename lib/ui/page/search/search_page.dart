import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/input_deletion_status_store.dart';
import 'package:flutter_nga/store/search_options_store.dart';
import 'package:flutter_nga/store/search_store.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<SearchPage> {
  final _searchQuery = TextEditingController();
  final _searchOptionsStore = SearchOptionsStore();
  final _searchStore = SearchStore();
  final _inputDeletionStatusStore = InputDeletionStatusStore();

  _SearchState() {
    _searchQuery.addListener(listenQueryChanged);
  }

  listenQueryChanged() {
    _inputDeletionStatusStore.setVisible(_searchQuery.text.isNotEmpty);
  }

  firstOnChanged(int val) {
    _searchOptionsStore.checkFirstRadio(val);
  }

  topicOnChanged(int val) {
    _searchOptionsStore.checkTopicRadio(val);
  }

  userOnChanged(int val) {
    _searchOptionsStore.checkUserRadio(val);
  }

  contentOnChanged(bool val) {
    _searchOptionsStore.checkContent(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchQuery,
          textInputAction: TextInputAction.search,
          onSubmitted: _onSearch,
          style: TextStyle(
            color: Colors.white,
          ),
          maxLines: 1,
          decoration: InputDecoration(
            hintText: "搜索...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Palette.colorTextHintWhite),
            suffixIcon: Observer(
              builder: (_) {
                return _inputDeletionStatusStore.visible
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () => WidgetsBinding.instance
                            .addPostFrameCallback((_) => _searchQuery.clear()),
                      )
                    : Container(width: 0);
              },
            ),
          ),
        ),
      ),
      body: Observer(
        builder: (_) {
          final widgets = <Widget>[];
          widgets.add(RadioListTile(
            value: SearchState.FIRST_RADIO_TOPIC,
            groupValue: _searchOptionsStore.state.firstRadio,
            onChanged: firstOnChanged,
            title: Text("主题"),
          ));
          widgets.add(RadioListTile(
            value: SearchState.FIRST_RADIO_FORUM,
            groupValue: _searchOptionsStore.state.firstRadio,
            onChanged: firstOnChanged,
            title: Text("版块"),
          ));
          widgets.add(RadioListTile(
            value: SearchState.FIRST_RADIO_USER,
            groupValue: _searchOptionsStore.state.firstRadio,
            onChanged: firstOnChanged,
            title: Text("用户"),
          ));
          if (_searchOptionsStore.state.firstRadio ==
              SearchState.FIRST_RADIO_TOPIC) {
            widgets.add(Padding(
              padding: EdgeInsets.only(left: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text(
                      "包括正文",
                      style: TextStyle(
                        fontSize: Dimen.button,
                        color: Palette.colorTextSecondary,
                      ),
                    ),
                    value: _searchOptionsStore.state.content,
                    onChanged: contentOnChanged,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  RadioListTile(
                    value: SearchState.TOPIC_RADIO_ALL_FORUM,
                    groupValue: _searchOptionsStore.state.topicRadio,
                    onChanged: topicOnChanged,
                    title: Text(
                      "全部版块",
                      style: TextStyle(
                        fontSize: Dimen.button,
                        color: Palette.colorTextSecondary,
                      ),
                    ),
                  ),
                  RadioListTile(
                    value: SearchState.TOPIC_RADIO_CURRENT_FORUM,
                    groupValue: _searchOptionsStore.state.topicRadio,
                    onChanged: topicOnChanged,
                    title: Text(
                      "当前版块",
                      style: TextStyle(
                        fontSize: Dimen.button,
                        color: Palette.colorTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ));
          }
          if (_searchOptionsStore.state.firstRadio ==
              SearchState.FIRST_RADIO_USER) {
            widgets.add(Padding(
              padding: EdgeInsets.only(left: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    value: SearchState.USER_RADIO_NAME,
                    groupValue: _searchOptionsStore.state.userRadio,
                    onChanged: userOnChanged,
                    title: Text(
                      "用户名",
                      style: TextStyle(
                        fontSize: Dimen.button,
                        color: Palette.colorTextSecondary,
                      ),
                    ),
                  ),
                  RadioListTile(
                    value: SearchState.USER_RADIO_UID,
                    groupValue: _searchOptionsStore.state.userRadio,
                    onChanged: userOnChanged,
                    title: Text(
                      "用户ID",
                      style: TextStyle(
                        fontSize: Dimen.button,
                        color: Palette.colorTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ));
          }
          return ListView(children: widgets);
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchQuery.removeListener(listenQueryChanged);
    super.dispose();
  }

  void _onSearch(text) {
    if (_searchOptionsStore.state.firstRadio == SearchState.FIRST_RADIO_TOPIC) {
    } else if (_searchOptionsStore.state.firstRadio ==
        SearchState.FIRST_RADIO_FORUM) {
    } else if (_searchOptionsStore.state.firstRadio ==
        SearchState.FIRST_RADIO_USER) {

    }
  }
}
