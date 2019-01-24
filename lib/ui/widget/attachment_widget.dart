import 'dart:io';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentWidget extends StatefulWidget {
  const AttachmentWidget({this.topic, this.callback, Key key})
      : super(key: key);

  final Topic topic;
  final InputCallback callback;

  @override
  _AttachmentState createState() => _AttachmentState();
}

class _AttachmentState extends State<AttachmentWidget> {
  List<String> _list = [];
  List<File> _imageFileList = [];
  String _authCode;
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
            if (image == null) return;
            setState(() => _imageFileList.add(image));
            try {
              if (_authCode == null) {
                _authCode = await Data()
                    .topicRepository
                    .getAuthCode(widget.topic.fid, widget.topic.tid, "reply");
              }
              String url = await Data()
                  .topicRepository
                  .uploadAttachment(widget.topic.fid, _authCode, image);
              setState(() => _list.add(url));
            } catch (error) {
              setState(() => _imageFileList.remove(image));
            }
          },
          child: Icon(CommunityMaterialIcons.image_plus),
        ),
      );
    }
    widgets.add(_addImageWidget);
    if (_imageFileList.isNotEmpty) {
      debugPrint(
          "list size = ${_list.length}, file size = ${_imageFileList.length}");
      widgets.addAll(_imageFileList.map((image) {
        var index = _imageFileList.indexOf(image);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (widget.callback != null && _list.length > index) {
                widget.callback("[img]./${_list[index]}[/img]", "", false);
              }
            },
            child: Stack(
              children: [
                SizedBox.expand(
                  child: Image.file(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
                Opacity(
                  opacity: _list.length == index ? 1 : 0,
                  child: Center(child: CircularProgressIndicator()),
                )
              ],
            ),
          ),
        );
      }));
    }
    return widgets;
  }
}
