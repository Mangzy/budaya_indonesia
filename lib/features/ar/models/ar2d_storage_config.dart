/// Configuration for fetching 2D AR assets from Supabase Storage.
/// Adjust [bucket] and [pathPrefix] to match your project.
class Ar2dStorageConfig {
  static const String bucket = '2d assets';
  static const String pathPrefix = '';
  static const bool isPublicBucket = true; // set to false if using signed URLs
  static const List<String> allowedExtensions = [
    '.png',
    '.jpg',
    '.jpeg',
    '.webp',
  ];
}
