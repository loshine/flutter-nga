import 'dart:io';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

typedef AttachmentCallback = void Function(
    String? attachments, String? attachmentsCheck);

class AttachmentWidget extends StatefulWidget {
  const AttachmentWidget(
      {this.tid, this.fid, this.callback, this.attachmentCallback, Key? key})
      : super(key: key);

  final int? tid;
  final int? fid;
  final InputCallback? callback;
  final AttachmentCallback? attachmentCallback;

  @override
  _AttachmentState createState() => _AttachmentState();
}

class _AttachmentState extends State<AttachmentWidget> {
  List<String?> _list = [];
  List<PickedFile> _imageFileList = [];
  String? _authCode;
  Widget? _addImageWidget;

  final _picker = ImagePicker();

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
            final storageStatus = await Permission.storage.status;
            if (storageStatus == PermissionStatus.granted) {
              PickedFile? image =
                  await _picker.getImage(source: ImageSource.gallery);
              if (image == null) return;
              setState(() => _imageFileList.add(image));
              try {
                if (_authCode == null) {
                  _authCode = await Data().topicRepository.getAuthCode(
                      widget.fid,
                      widget.tid,
                      widget.tid == null ? "new" : "reply");
                }
                Map<String, dynamic> data = await Data()
                    .topicRepository
                    .uploadAttachment(widget.fid, _authCode, image.path);
                widget.attachmentCallback!(
                    data["attachments"], data["attachments_check"]);
                setState(() => _list.add(data["url"]));
              } catch (err) {
                debugPrint(err.toString());
                Fluttertoast.showToast(msg: err.toString());
                setState(() => _imageFileList.remove(image));
              }
            } else {
              Fluttertoast.showToast(msg: "请授予存储权限以上传文件");
            }
          },
          child: Icon(CommunityMaterialIcons.image_plus),
        ),
      );
    }
    widgets.add(_addImageWidget!);
    if (_imageFileList.isNotEmpty) {
      widgets.addAll(_imageFileList.map((image) {
        var index = _imageFileList.indexOf(image);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (widget.callback != null) {
                if (_list.length > index) {
                  widget.callback!("[img]./${_list[index]}[/img]", "", false);
                } else {
                  Fluttertoast.showToast(
                    msg: "上传文件中，请稍候",
                  );
                }
              }
            },
            child: Stack(
              children: [
                SizedBox.expand(
                  child: Image.file(
                    File(image.path),
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
