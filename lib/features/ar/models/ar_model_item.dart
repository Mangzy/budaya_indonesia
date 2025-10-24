class ArModelItem {
  final String name;
  final String url; // GLB for Android/web viewer
  final String? iosUrl; // USDZ for iOS Quick Look (optional)
  final String? thumbnailUrl; // Preview image for gallery

  ArModelItem({
    required this.name,
    required this.url,
    this.iosUrl,
    this.thumbnailUrl,
  });
}
