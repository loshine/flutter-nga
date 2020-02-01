import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/store/photo_min_scale_store.dart';
import 'package:flutter_nga/utils/picture_utils.dart' as pictureUtils;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPreviewPage extends StatefulWidget {
  const PhotoPreviewPage({Key key, this.url, this.screenWidth})
      : super(key: key);

  final String url;
  final double screenWidth;

  @override
  _PhotoPreviewState createState() => _PhotoPreviewState();
}

class _PhotoPreviewState extends State<PhotoPreviewPage> {
  final _store = PhotoMinScaleStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("查看图片"),
        actions: [
          IconButton(
            icon: Icon(
              CommunityMaterialIcons.content_save,
              color: Colors.white,
            ),
            onPressed: () => _save(),
            tooltip: "保存",
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          return _store.minScale == 0
              ? Center(child: CircularProgressIndicator())
              : PhotoView(
                  imageProvider: CachedNetworkImageProvider(
                      pictureUtils.getOriginalUrl(widget.url)),
                  minScale: _store.minScale,
                );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _store.load(widget.url, widget.screenWidth);
  }

  _save() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
      final file = await Data()
          .resourceRepository
          .downloadImage(pictureUtils.getOriginalUrl(widget.url));
      Fluttertoast.showToast(
        msg: "保存成功, 路径位于${file.path}",
        gravity: ToastGravity.CENTER,
      );
    }
  }
}
