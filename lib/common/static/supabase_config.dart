/// Supabase Configuration
///
/// IMPORTANT: Ganti dengan credentials Supabase Anda!
///
/// Cara mendapatkan:
/// 1. Login ke https://supabase.com/dashboard
/// 2. Pilih project Anda
/// 3. Settings → API
/// 4. Copy Project URL dan anon public key

class SupabaseConfig {
  // TODO: Ganti dengan Project URL Anda
  static const String supabaseUrl = 'https://thepsfcpxbarhbelsgjc.supabase.co';

  // TODO: Ganti dengan anon public key Anda
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZXBzZmNweGJhcmhiZWxzZ2pjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg5NTc0NTgsImV4cCI6MjA3NDUzMzQ1OH0.IrlBfdl5F1ALCrRo9bzywi9rIj9IsoEaItQN06xug7I';

  // Database table name (sudah benar, tidak perlu diubah)
  static const String quizTableName = 'soal_kuis';
}
