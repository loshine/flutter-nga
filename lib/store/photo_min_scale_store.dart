import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nga/utils/picture_utils.dart' as pictureUtils;
import 'package:mobx/mobx.dart';

part 'photo_min_scale_store.g.dart';

class PhotoMinScaleStore = _PhotoMinScaleStore with _$PhotoMinScaleStore;

abstract class _PhotoMinScaleStore with Store {
  @observable
  double minScale = 0;

  @action
  void load(String url, double screenWidth) {
    CachedNetworkImageProvider(pictureUtils.getOriginalUrl(url))
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener(
            (ImageInfo info, _) => minScale = screenWidth / info.image.width));
  }
}
