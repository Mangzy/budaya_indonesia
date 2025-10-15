import 'package:budaya_indonesia/common/theme/app_theme.dart';
import 'package:budaya_indonesia/features/music/pages/music_page.dart';
import 'package:budaya_indonesia/features/music/providers/music_list_provider.dart';
import 'package:budaya_indonesia/features/music/providers/music_player_provider.dart';
import 'package:budaya_indonesia/features/navbar/pages/bottom_navbar.dart';
import 'package:budaya_indonesia/features/navbar/providers/navbar_provider.dart';
import 'package:budaya_indonesia/features/home/pages/home_page.dart';
import 'package:budaya_indonesia/features/login/pages/login_pages.dart';
import 'package:budaya_indonesia/features/register/pages/register_page.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:budaya_indonesia/src/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase (dibutuhkan oleh banyak provider/fitur)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://thepsfcpxbarhbelsgjc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZXBzZmNweGJhcmhiZWxzZ2pjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg5NTc0NTgsImV4cCI6MjA3NDUzMzQ1OH0.IrlBfdl5F1ALCrRo9bzywi9rIj9IsoEaItQN06xug7I',
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
        create: (_) => AuthProvider()..listenAuthState(),
        ),
        ChangeNotifierProvider(create: (_) => NavbarProvider()),
        ChangeNotifierProvider(
          create: (_) => MusicListProvider(client: Supabase.instance.client),
        ),
        ChangeNotifierProvider(create: (_) => MusicPlayerProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const MusicPage(),
        routes: {
          '/login': (context) => const LoginPages(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/navbar': (context) => const BottomNavbar(),
          '/music': (context) => const MusicPage(),
        },
      ),
    );
  }
}
