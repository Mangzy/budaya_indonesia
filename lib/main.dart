import 'package:budaya_indonesia/common/theme/app_theme.dart';
import 'package:budaya_indonesia/features/music/pages/music_page.dart';
// legacy music detail (deprecated) imports removed
import 'package:budaya_indonesia/features/music_detail/pages/music_detail_page.dart'
    as detail;
import 'package:budaya_indonesia/features/music_detail/providers/music_provider.dart'
    as detailProv;
import 'package:budaya_indonesia/features/navbar/pages/bottom_navbar.dart';
import 'package:budaya_indonesia/features/navbar/providers/navbar_provider.dart';
import 'package:budaya_indonesia/features/home/pages/home_page.dart';
import 'package:budaya_indonesia/features/login/pages/login_pages.dart';
import 'package:budaya_indonesia/features/login/providers/login_provider.dart';
import 'package:budaya_indonesia/features/register/pages/register_page.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:budaya_indonesia/src/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as dev;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://thepsfcpxbarhbelsgjc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZXBzZmNweGJhcmhiZWxzZ2pjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg5NTc0NTgsImV4cCI6MjA3NDUzMzQ1OH0.IrlBfdl5F1ALCrRo9bzywi9rIj9IsoEaItQN06xug7I',
  );
  // Debug info Supabase connection
  final supaClient = Supabase.instance.client;
  try {
    // Gunakan REST URL yang dapat diakses dari client
    final restUrl = supaClient.rest.url.toString();
    final uri = Uri.parse(restUrl);
    final projectRef = uri.host.split('.').first;
    dev.log('Supabase connected', name: 'Supabase');
    dev.log('Project Ref: $projectRef', name: 'Supabase');
    dev.log('REST URL: $restUrl', name: 'Supabase');
  } catch (e, st) {
    dev.log(
      'Supabase connection parse error: $e',
      name: 'Supabase',
      stackTrace: st,
    );
  }
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
          create: (_) => detailProv.MusicDetailProvider(
            client: Supabase.instance.client,
            isPublicBucket: true,
            allowedExtensions: ['.mp3'],
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return ChangeNotifierProvider(
            create: (_) => LoginProvider(auth: context.read<AuthProvider>()),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ThemeMode.light,
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
              },
            ),
          );
        },
      ),
    );
  }
}
