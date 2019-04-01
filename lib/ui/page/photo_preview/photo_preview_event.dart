abstract class PhotoPreviewEvent {
  factory PhotoPreviewEvent.load(String url, double screenWidth) =>
      PhotoPreviewLoadEvent(url: url, screenWidth: screenWidth);

  factory PhotoPreviewEvent.switch2OriginalMode(
          String url, double screenWidth) =>
      PhotoPreviewSwitch2OriginalMode(url: url, screenWidth: screenWidth);
}

class PhotoPreviewLoadEvent implements PhotoPreviewEvent {
  final String url;
  final double screenWidth;

  PhotoPreviewLoadEvent({this.url, this.screenWidth});
}

class PhotoPreviewSwitch2OriginalMode implements PhotoPreviewEvent {
  final String url;
  final double screenWidth;

  PhotoPreviewSwitch2OriginalMode({this.url, this.screenWidth});
}
