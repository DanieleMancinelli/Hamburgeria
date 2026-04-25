import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hamburgeria - Menu Totem'),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Text('Qui appariranno i panini dal database!'),
      ),
    );
  }
}
