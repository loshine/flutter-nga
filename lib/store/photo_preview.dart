import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nga/utils/picture_utils.dart' as pictureUtils;
import 'package:mobx/mobx.dart';

part 'photo_preview.g.dart';

class PhotoPreview = _PhotoPreview with _$PhotoPreview;

abstract class _PhotoPreview with Store {
  @observable
  bool loading = true;

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
