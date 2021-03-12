import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/search/input_deletion_status_store.dart';
import 'package:flutter_nga/store/search/search_options_store.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';

class SearchPage extends StatefulWidget {
  final int? fid;

  const SearchPage({this.fid, Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<SearchPage> {
  final _searchQuery = TextEditingController();
  final _searchOptionsStore = SearchOptionsStore();
  final _inputDeletionStatusStore = InputDeletionStatusStore();

  _SearchState() {
    _searchQuery.addListener(_listenQueryChanged);
  }

  @override
  void initState() {
    super.initState();
    if (widget.fid != null) {
      _searchOptionsStore
          .checkTopicRadio(SearchStoreData.TOPIC_RADIO_CURRENT_FORUM);
    }
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
                        onPressed: () => WidgetsBinding.instance!
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
          final firstWidgets = Row(
            children: <Widget>[
              Padding(
                child: ChoiceChip(
                  label: Text(
                    "主题",
                    style: TextStyle(
                        color: _searchOptionsStore.state.firstRadio ==
                                SearchStoreData.FIRST_RADIO_TOPIC
                            ? Colors.white
                            : Palette.colorTextPrimary),
                  ),
                  selectedColor: Palette.colorPrimary,
                  selected: _searchOptionsStore.state.firstRadio ==
                      SearchStoreData.FIRST_RADIO_TOPIC,
                  onSelected: (selected) => _searchOptionsStore
                      .checkFirstRadio(SearchStoreData.FIRST_RADIO_TOPIC),
                ),
                padding: EdgeInsets.only(left: 16),
              ),
              Padding(
                child: ChoiceChip(
                  label: Text(
                    "版块",
                    style: TextStyle(
                        color: _searchOptionsStore.state.firstRadio ==
                                SearchStoreData.FIRST_RADIO_FORUM
                            ? Colors.white
                            : Palette.colorTextPrimary),
                  ),
                  selectedColor: Palette.colorPrimary,
                  selected: _searchOptionsStore.state.firstRadio ==
                      SearchStoreData.FIRST_RADIO_FORUM,
                  onSelected: (selected) => _searchOptionsStore
                      .checkFirstRadio(SearchStoreData.FIRST_RADIO_FORUM),
                ),
                padding: EdgeInsets.only(left: 16),
              ),
              Padding(
                child: ChoiceChip(
                  label: Text(
                    "用户",
                    style: TextStyle(
                        color: _searchOptionsStore.state.firstRadio ==
                                SearchStoreData.FIRST_RADIO_USER
                            ? Colors.white
                            : Palette.colorTextPrimary),
                  ),
                  selectedColor: Palette.colorPrimary,
                  selected: _searchOptionsStore.state.firstRadio ==
                      SearchStoreData.FIRST_RADIO_USER,
                  onSelected: (selected) => _searchOptionsStore
                      .checkFirstRadio(SearchStoreData.FIRST_RADIO_USER),
                ),
                padding: EdgeInsets.only(left: 16),
              ),
            ],
          );
          widgets.add(firstWidgets);
          if (_searchOptionsStore.state.firstRadio ==
              SearchStoreData.FIRST_RADIO_TOPIC) {
            if (widget.fid != null) {
              widgets.add(Row(
                children: <Widget>[
                  Padding(
                    child: ChoiceChip(
                        label: Text(
                          "当前版块",
                          style: TextStyle(
                              color: _searchOptionsStore.state.topicRadio ==
                                      SearchStoreData.TOPIC_RADIO_CURRENT_FORUM
                                  ? Colors.white
                                  : Palette.colorTextPrimary),
                        ),
                        selectedColor: Palette.colorPrimary,
                        selected: _searchOptionsStore.state.topicRadio ==
                            SearchStoreData.TOPIC_RADIO_CURRENT_FORUM,
                        onSelected: (selected) =>
                            _searchOptionsStore.checkTopicRadio(
                                SearchStoreData.TOPIC_RADIO_CURRENT_FORUM)),
                    padding: EdgeInsets.only(left: 16),
                  ),
                  Padding(
                    child: ChoiceChip(
                      label: Text(
                        "全部版块",
                        style: TextStyle(
                            color: _searchOptionsStore.state.topicRadio ==
                                    SearchStoreData.TOPIC_RADIO_ALL_FORUM
                                ? Colors.white
                                : Palette.colorTextPrimary),
                      ),
                      selectedColor: Palette.colorPrimary,
                      selected: _searchOptionsStore.state.topicRadio ==
                          SearchStoreData.TOPIC_RADIO_ALL_FORUM,
                      onSelected: (selected) =>
                          _searchOptionsStore.checkTopicRadio(
                              SearchStoreData.TOPIC_RADIO_ALL_FORUM),
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
                          color: _searchOptionsStore.state.content
                              ? Colors.white
                              : Palette.colorTextPrimary),
                    ),
                    selectedColor: Palette.colorPrimary,
                    selected: _searchOptionsStore.state.content,
                    onSelected: (selected) =>
                        _searchOptionsStore.checkContent(selected),
                  ),
                  padding: EdgeInsets.only(left: 16),
                ),
              ],
            ));
          }
          if (_searchOptionsStore.state.firstRadio ==
              SearchStoreData.FIRST_RADIO_USER) {
            widgets.add(Row(
              children: <Widget>[
                Padding(
                  child: ChoiceChip(
                    label: Text(
                      "用户名",
                      style: TextStyle(
                          color: _searchOptionsStore.state.userRadio ==
                                  SearchStoreData.USER_RADIO_NAME
                              ? Colors.white
                              : Palette.colorTextPrimary),
                    ),
                    selectedColor: Palette.colorPrimary,
                    selected: _searchOptionsStore.state.userRadio ==
                        SearchStoreData.USER_RADIO_NAME,
                    onSelected: (selected) => _searchOptionsStore
                        .checkUserRadio(SearchStoreData.USER_RADIO_NAME),
                  ),
                  padding: EdgeInsets.only(left: 16),
                ),
                Padding(
                  child: ChoiceChip(
                    label: Text(
                      "用户ID",
                      style: TextStyle(
                          color: _searchOptionsStore.state.userRadio ==
                                  SearchStoreData.USER_RADIO_UID
                              ? Colors.white
                              : Palette.colorTextPrimary),
                    ),
                    selectedColor: Palette.colorPrimary,
                    selected: _searchOptionsStore.state.userRadio ==
                        SearchStoreData.USER_RADIO_UID,
                    onSelected: (selected) => _searchOptionsStore
                        .checkUserRadio(SearchStoreData.USER_RADIO_UID),
                  ),
                  padding: EdgeInsets.only(left: 16),
                ),
              ],
            ));
          }
          return ListView(
            children: widgets,
            physics: BouncingScrollPhysics(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchQuery.removeListener(_listenQueryChanged);
    super.dispose();
  }

  _listenQueryChanged() {
    _inputDeletionStatusStore.setVisible(_searchQuery.text.isNotEmpty);
  }

  _onSearch(text) {
    if (_searchOptionsStore.state.firstRadio ==
        SearchStoreData.FIRST_RADIO_TOPIC) {
      if (widget.fid == null) {
        Routes.navigateTo(context,
            "${Routes.SEARCH_TOPIC_LIST}?keyword=${fluroCnParamsEncode(text)}&content=${_searchOptionsStore.state.content ? 1 : 0}");
      } else {
        Routes.navigateTo(context,
            "${Routes.SEARCH_TOPIC_LIST}?keyword=${fluroCnParamsEncode(text)}&fid=${widget.fid}&content=${_searchOptionsStore.state.content ? 1 : 0}");
      }
    } else if (_searchOptionsStore.state.firstRadio ==
        SearchStoreData.FIRST_RADIO_FORUM) {
      Routes.navigateTo(context,
          "${Routes.SEARCH_FORUM}?keyword=${fluroCnParamsEncode(text)}");
    } else if (_searchOptionsStore.state.firstRadio ==
        SearchStoreData.FIRST_RADIO_USER) {
      if (_searchOptionsStore.state.userRadio ==
          SearchStoreData.USER_RADIO_NAME) {
        Routes.navigateTo(
            context, "${Routes.USER}?name=${fluroCnParamsEncode(text)}");
      } else {
        Routes.navigateTo(context, "${Routes.USER}?uid=$text");
      }
    }
  }
}
