class ArModelItem {
  final String name;
  final String url; // GLB for Android/web viewer
  final String? iosUrl; // USDZ for iOS Quick Look (optional)

  ArModelItem({required this.name, required this.url, this.iosUrl});
}
