import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nga/utils/picture_utils.dart' as pictureUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoMinScaleNotifier extends StateNotifier<double> {
  PhotoMinScaleNotifier() : super(0);

  void load(String url, double? screenWidth) {
    CachedNetworkImageProvider(pictureUtils.getOriginalUrl(url))
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener(
            (ImageInfo info, _) => state = screenWidth! / info.image.width));
  }
}

final photoMinScaleProvider =
    StateNotifierProvider<PhotoMinScaleNotifier, double>((ref) {
  return PhotoMinScaleNotifier();
});
