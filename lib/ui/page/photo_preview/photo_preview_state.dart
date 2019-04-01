class PhotoPreviewState {
  final bool loading;
  final double minScale;
  final bool originalMode;

  const PhotoPreviewState({this.loading, this.minScale, this.originalMode});

  factory PhotoPreviewState.loading() =>
      PhotoPreviewState(loading: true, originalMode: false);

  factory PhotoPreviewState.loadComplete(double minScale, bool originalMode) =>
      PhotoPreviewState(
          loading: false, minScale: minScale, originalMode: originalMode);

  factory PhotoPreviewState.originalMode(double minScale) =>
      PhotoPreviewState(loading: false, minScale: minScale, originalMode: true);
}
