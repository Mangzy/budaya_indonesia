import 'package:budaya_indonesia/features/home/pages/home_page.dart';
import 'package:budaya_indonesia/features/login/pages/login_pages.dart';
import 'package:budaya_indonesia/features/login/providers/login_provider.dart';
import 'package:budaya_indonesia/features/register/pages/register_page.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:budaya_indonesia/src/auth_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..listenAuthState(),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Create LoginProvider now that AuthProvider is available in this context
          return ChangeNotifierProvider(
            create: (_) => LoginProvider(auth: context.read<AuthProvider>()),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.indigo,
              ),
              home: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return auth.user == null
                      ? const LoginPages()
                      : const HomeScreen();
                },
              ),
              routes: {
                '/login': (context) => const LoginPages(),
                '/register': (context) => const RegisterPage(),
                '/home': (context) => const HomeScreen(),
              },
            ),
          );
        },
      ),
    );
  }
}
