import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/providers/common/photo_min_scale_provider.dart';
import 'package:flutter_nga/utils/picture_utils.dart' as picture_utils;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPreviewPage extends HookConsumerWidget {
  const PhotoPreviewPage({super.key, this.url, this.screenWidth});

  final String? url;
  final double? screenWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minScale = ref.watch(photoMinScaleProvider);

    useEffect(() {
      Future.microtask(() {
        ref.read(photoMinScaleProvider.notifier).load(url!, screenWidth);
      });
      return null;
    }, [url]);

    return Scaffold(
      appBar: AppBar(
        title: Text("查看图片"),
        actions: [
          IconButton(
            icon: Icon(
              CommunityMaterialIcons.content_save,
            ),
            onPressed: () => _save(),
            tooltip: "保存",
          ),
        ],
      ),
      body: minScale == 0
          ? Center(child: CircularProgressIndicator())
          : PhotoView(
              imageProvider: CachedNetworkImageProvider(
                  picture_utils.getOriginalUrl(url!)),
              minScale: minScale,
            ),
    );
  }

  Future<void> _save() async {
    final success = await Data()
        .resourceRepository
        .downloadImage(picture_utils.getOriginalUrl(url!));
    Fluttertoast.showToast(msg: success == true ? "保存到相册成功" : "保存到相册失败");
  }
}
