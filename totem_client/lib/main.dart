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
    // Corretto: rimosso l'underscore dalla variabile locale
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MenuScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Totem Hamburgeria',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
