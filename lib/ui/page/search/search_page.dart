import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<SearchPage> {
  final _searchQuery = TextEditingController();
  var _hasText = false;
  int _selectedTypeRadioValue = 1;

  _SearchState() {
    _searchQuery.addListener(() {
      setState(() {
        if (_searchQuery.text.isEmpty) {
          _hasText = false;
        } else {
          _hasText = true;
        }
      });
    });
  }

  // Changes the selected value on 'onChanged' click on each radio button
  setSelectedTypeRadio(int val) {
    print("Radio $val");
    setState(() {
      _selectedTypeRadioValue = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchQuery,
          style: TextStyle(
            color: Colors.white,
          ),
          maxLines: 1,
          decoration: InputDecoration(
            hintText: "搜索...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Palette.colorTextHintWhite),
            suffixIcon: _hasText
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () => WidgetsBinding.instance
                        .addPostFrameCallback((_) => _searchQuery.clear()),
                  )
                : null,
          ),
        ),
      ),
      body: ListView(
        children: [
          RadioListTile(
            value: 1,
            groupValue: _selectedTypeRadioValue,
            onChanged: setSelectedTypeRadio,
            title: Text("主题"),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16),
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
                  value: false,
                  onChanged: (bool value) {},
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                RadioListTile(
                  value: 1,
                  groupValue: _selectedTypeRadioValue,
                  onChanged: setSelectedTypeRadio,
                  title: Text(
                    "全部版块",
                    style: TextStyle(
                      fontSize: Dimen.button,
                      color: Palette.colorTextSecondary,
                    ),
                  ),
                ),
                RadioListTile(
                  value: 1,
                  groupValue: _selectedTypeRadioValue,
                  onChanged: setSelectedTypeRadio,
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
          ),
          RadioListTile(
            value: 2,
            groupValue: _selectedTypeRadioValue,
            onChanged: setSelectedTypeRadio,
            title: Text("版块"),
          ),
          RadioListTile(
            value: 3,
            groupValue: _selectedTypeRadioValue,
            onChanged: setSelectedTypeRadio,
            title: Text("用户"),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  value: 1,
                  groupValue: _selectedTypeRadioValue,
                  onChanged: setSelectedTypeRadio,
                  title: Text(
                    "用户名",
                    style: TextStyle(
                      fontSize: Dimen.button,
                      color: Palette.colorTextSecondary,
                    ),
                  ),
                ),
                RadioListTile(
                  value: 1,
                  groupValue: _selectedTypeRadioValue,
                  onChanged: setSelectedTypeRadio,
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
          ),
        ],
      ),
    );
  }
}
