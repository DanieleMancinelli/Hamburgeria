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
      title: 'Totem Hamburgeria',
      debugShowCheckedModeBanner: false, // <-- TOGLIE LA SCRITTA DEBUG
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
