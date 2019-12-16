import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/page/photo_preview/photo_preview_event.dart';
import 'package:flutter_nga/ui/page/photo_preview/photo_preview_state.dart';
import 'package:flutter_nga/utils/picture_utils.dart' as pictureUtils;

class PhotoPreviewBloc extends Bloc<PhotoPreviewEvent, PhotoPreviewState> {
  @override
  PhotoPreviewState get initialState => PhotoPreviewState.loading();

  void onLoad(String url, double screenWidth) {
    onEvent(PhotoPreviewEvent.load(url, screenWidth));
  }

  @override
  Stream<PhotoPreviewState> mapEventToState(PhotoPreviewEvent event) async* {
    if (event is PhotoPreviewLoadEvent) {
      final completer = Completer<double>();
      CachedNetworkImageProvider(pictureUtils.getOriginalUrl(event.url))
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, _) =>
              completer.complete(event.screenWidth / info.image.width)));
      yield PhotoPreviewState.loadComplete(await completer.future);
    }
  }
}
