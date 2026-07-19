import 'dart:io';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:image_picker/image_picker.dart';

typedef AttachmentCallback = void Function(
    String? attachments, String? attachmentsCheck);

class AttachmentWidget extends StatefulWidget {
  const AttachmentWidget(
      {this.tid, this.fid, this.callback, this.attachmentCallback, super.key});

  final int? tid;
  final int? fid;
  final InputCallback? callback;
  final AttachmentCallback? attachmentCallback;

  @override
  _AttachmentState createState() => _AttachmentState();
}

class _AttachmentState extends State<AttachmentWidget> {
  List<String?> _list = [];
  List<XFile> _imageFileList = [];
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
            final image = await _picker.pickImage(
              source: ImageSource.gallery,
              requestFullMetadata: false,
            );
            if (image == null || !mounted) return;

            setState(() => _imageFileList.add(image));
            try {
              final topicRepository = Data().topicRepository;
              _authCode ??= await topicRepository.getAuthCode(
                widget.fid,
                widget.tid,
                widget.tid == null ? "new" : "reply",
              );
              final data = await topicRepository.uploadAttachment(
                widget.fid,
                _authCode,
                image.path,
              );
              if (!mounted) return;

              widget.attachmentCallback
                  ?.call(data["attachments"], data["attachments_check"]);
              setState(() => _list.add(data["url"]));
            } catch (err) {
              if (!mounted) return;

              debugPrint(err.toString());
              AppToast.error(err.toString());
              setState(() => _imageFileList.remove(image));
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
                  widget.callback
                      ?.call("[img]./${_list[index]}[/img]", "", false);
                } else {
                  AppToast.warning("上传文件中，请稍候");
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
