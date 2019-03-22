import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/page/photo_preview/photo_preview_event.dart';
import 'package:flutter_nga/ui/page/photo_preview/photo_preview_state.dart';

class PhotoPreviewBloc extends Bloc<PhotoPreviewEvent, PhotoPreviewState> {
  @override
  PhotoPreviewState get initialState => PhotoPreviewState.loading();

  @override
  Stream<PhotoPreviewState> mapEventToState(
      PhotoPreviewState currentState, PhotoPreviewEvent event) async* {
    if (event is PhotoPreviewLoadEvent) {
      final completer = Completer<double>();
      CachedNetworkImageProvider(event.url)
          .resolve(ImageConfiguration())
          .addListener((ImageInfo info, _) =>
              completer.complete(event.screenWidth / info.image.width));
      yield PhotoPreviewState.loadComplete(await completer.future);
    }
  }

  void onLoad(String url, double screenWidth) {
    dispatch(PhotoPreviewEvent.load(url, screenWidth));
  }
}
