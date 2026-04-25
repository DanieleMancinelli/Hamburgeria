import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/prodotto.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Prodotto>> futureProdotti;

  @override
  void initState() {
    super.initState();
    // Carichiamo i prodotti all'avvio della pagina
    futureProdotti = apiService.prendiProdotti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hamburgeria - Menu Totem'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Prodotto>>(
        future: futureProdotti,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessun prodotto trovato.'));
          }

          final prodotti = snapshot.data!;

          return ListView.builder(
            itemCount: prodotti.length,
            itemBuilder: (context, index) {
              final prodotto = prodotti[index];
              return ListTile(
                leading: const Icon(Icons.fastfood, color: Colors.orange),
                title: Text(prodotto.nome),
                subtitle: Text(prodotto.categoria),
                trailing: Text('${prodotto.prezzo.toStringAsFixed(2)} €'),
              );
            },
          );
        },
      ),
    );
  }
}
