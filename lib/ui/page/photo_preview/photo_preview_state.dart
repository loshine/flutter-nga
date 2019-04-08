class PhotoPreviewState {
  final bool loading;
  final double minScale;

  const PhotoPreviewState({
    this.loading,
    this.minScale,
  });

  factory PhotoPreviewState.loading() => PhotoPreviewState(loading: true);

  factory PhotoPreviewState.loadComplete(double minScale) =>
      PhotoPreviewState(loading: false, minScale: minScale);
}
