import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'common/static/supabase_config.dart';
import 'features/quiz/providers/quiz_provider.dart';
import 'features/quiz/pages/category_selection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // TODO: Update credentials di lib/common/static/supabase_config.dart
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Quiz Provider
        ChangeNotifierProvider(
          create: (_) => QuizProvider(client: Supabase.instance.client),
        ),
      ],
      child: MaterialApp(
        title: 'Quiz Budaya Indonesia',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4DB6AC), // Green tosca
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF4DB6AC),
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DB6AC),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        // Langsung ke Category Selection untuk test UI
        home: const CategorySelectionPage(),
      ),
    );
  }
}
