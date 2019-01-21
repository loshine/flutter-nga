import 'dart:io';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentWidget extends StatefulWidget {
  @override
  _AttachmentState createState() => _AttachmentState();
}

class _AttachmentState extends State<AttachmentWidget> {
  List<File> _list = [];

  Widget _addImageWidget;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      children: _getImageWidgetList(),
    );
  }

  List<Widget> _getImageWidgetList() {
    List<Widget> widgets = [];
    if (_addImageWidget == null) {
      _addImageWidget = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            File image =
                await ImagePicker.pickImage(source: ImageSource.gallery);
            setState(() {
              _list.add(image);
            });
          },
          child: Icon(CommunityMaterialIcons.image_plus),
        ),
      );
    }
    widgets.add(_addImageWidget);
    if (_list.isNotEmpty) {
      debugPrint("_list size = ${_list.length}");
      widgets.addAll(_list.map((file) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            child: Image.file(file),
          ),
        );
      }));
      debugPrint("_list size = ${_list.length}");
    }
    return widgets;
  }
}
