/// Simple configuration to point AR to the exact Supabase Storage bucket
/// and optional folder prefix where your .glb files live.
///
/// Set [bucket] to your real bucket id exactly as shown in Supabase.
/// If your files are inside a subfolder (e.g., 'models/glb'), set [pathPrefix]
/// to that folder path without leading slash.
class ArStorageConfig {
  static const String bucket = '3d assets'; // change if different
  static const String pathPrefix = ''; // e.g. 'models' or 'ar/glb'
  static const bool isPublicBucket = true; // for future use
}
