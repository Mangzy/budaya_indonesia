import 'package:budaya_indonesia/common/theme/app_theme.dart';
import 'package:budaya_indonesia/features/ar/pages/ar_page.dart';
import 'package:budaya_indonesia/features/ar/providers/ar_provider.dart';
import 'package:budaya_indonesia/features/music/pages/music_page.dart';
// legacy music detail (deprecated) imports removed
import 'package:budaya_indonesia/features/music_detail/pages/music_detail_page.dart'
    as detail;
import 'package:budaya_indonesia/features/music_detail/providers/music_provider.dart'
    // ignore: library_prefixes
    as detailProv;
import 'package:budaya_indonesia/features/navbar/pages/bottom_navbar.dart';
import 'package:budaya_indonesia/features/navbar/providers/navbar_provider.dart';
import 'package:budaya_indonesia/features/home/pages/home_page.dart';
import 'package:budaya_indonesia/features/login/pages/login_pages.dart';
import 'package:budaya_indonesia/features/login/providers/login_provider.dart';
import 'package:budaya_indonesia/features/profile/providers/profile_provider.dart';
import 'package:budaya_indonesia/features/profile/pages/profile_page.dart';
import 'package:budaya_indonesia/features/register/pages/register_page.dart';
import 'package:budaya_indonesia/features/quiz/pages/quiz_page.dart';
import 'package:budaya_indonesia/features/quiz/providers/quiz_provider.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:budaya_indonesia/src/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'features/home/providers/pakaian_provider.dart';
import 'package:budaya_indonesia/features/music/providers/music_list_provider.dart';
import 'package:budaya_indonesia/features/music/providers/music_player_provider.dart';

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
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(
          create: (_) => detailProv.MusicDetailProvider(
            client: Supabase.instance.client,
            isPublicBucket: true,
            allowedExtensions: ['.mp3'],
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MusicListProvider(client: Supabase.instance.client),
        ),
        ChangeNotifierProvider(create: (_) => MusicPlayerProvider()),
        ChangeNotifierProvider(create: (_) => ArProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              PakaianProvider(client: Supabase.instance.client)..refresh(),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(client: Supabase.instance.client),
        ),
      ],
      child: Builder(
        builder: (context) {
          return ChangeNotifierProvider(
            create: (_) => LoginProvider(auth: context.read<AuthProvider>()),
            child: Consumer<ProfileProvider>(
              builder: (context, prof, _) {
                final isDark = prof.profile?.darkMode ?? false;
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                  home: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.user == null) return const LoginPages();
                      return const BottomNavbar();
                    },
                  ),
                  routes: {
                    '/login': (context) => const LoginPages(),
                    '/register': (context) => const RegisterPage(),
                    '/home': (context) => const HomePage(),
                    '/navbar': (context) => const BottomNavbar(),
                    '/music': (context) => const MusicPage(),
                    '/music/detail': (context) {
                      final args =
                          ModalRoute.of(context)!.settings.arguments
                              as Map<String, dynamic>?;
                      final id = args?['trackId'] as String?; // boleh null
                      final zone = args?['zone'] as String?; // WIB/WITA/WIT
                      return detail.MusicDetailPage(trackId: id, zone: zone);
                    },
                    '/profile': (context) => const ProfilePage(),
                    '/profile/edit': (context) => const EditProfilePage(),
                    '/ar': (context) => const ArPage(),
                    '/quiz': (context) => const QuizPage(),
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
