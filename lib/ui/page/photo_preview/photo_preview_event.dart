abstract class PhotoPreviewEvent {
  factory PhotoPreviewEvent.load(String url, double screenWidth) =>
      PhotoPreviewLoadEvent(url: url, screenWidth: screenWidth);
}

class PhotoPreviewLoadEvent implements PhotoPreviewEvent {
  final String url;
  final double screenWidth;

  PhotoPreviewLoadEvent({this.url, this.screenWidth});
}