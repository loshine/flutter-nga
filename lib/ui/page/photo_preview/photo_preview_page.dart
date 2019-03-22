import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nga/ui/page/photo_preview/photo_preview_bloc.dart';
import 'package:flutter_nga/ui/page/photo_preview/photo_preview_state.dart';
import 'package:flutter_nga/utils/download_utils.dart';
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
  final _bloc = PhotoPreviewBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("查看图片"),
        actions: [
          IconButton(
            icon: Icon(CommunityMaterialIcons.content_save),
            onPressed: _save,
          ),
        ],
      ),
      body: BlocBuilder(
        bloc: _bloc,
        builder: (context, PhotoPreviewState state) {
          if (state.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return PhotoView(
              imageProvider: CachedNetworkImageProvider(widget.url),
              minScale: state.minScale,
            );
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _bloc.onLoad(widget.url, widget.screenWidth);
  }

  _save() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
      final file = await DownloadUtils.saveImage(widget.url);
      Fluttertoast.showToast(
        msg: "保存成功, 路径位于${file.path}",
        gravity: ToastGravity.CENTER,
      );
    }
  }
}
