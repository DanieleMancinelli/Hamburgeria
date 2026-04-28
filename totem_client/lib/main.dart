import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MenuScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Totem Gourmet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37), // Oro Gourmet
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
          primary: const Color(0xFFD4AF37),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), // Sfondo profondissimo
      ),
      routerConfig: router,
    );
  }
}
