import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/code_utils.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  int _imageCacheSize = 0;

  @override
  void initState() {
    super.initState();
    _imageCacheSize = imageCache.currentSizeBytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("设置")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text("账号管理"),
              subtitle: Text("管理您的账号"),
            ),
            ListTile(
              title: Text("图片缓存"),
              subtitle: Text(CodeUtils.formatSize(_imageCacheSize)),
              onTap: () {
                imageCache.clear();
                setState(() => _imageCacheSize = imageCache.currentSizeBytes);
              },
            ),
          ],
        ),
      ),
    );
  }
}
