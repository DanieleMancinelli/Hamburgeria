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
  List<Prodotto> carrello = [];

  @override
  void initState() {
    super.initState();
    futureProdotti = apiService.prendiProdotti();
  }

  double calcolaTotale() {
    return carrello.fold(0, (tot, prod) => tot + prod.prezzo);
  }

  // Funzione per mostrare il riepilogo del carrello
  void mostraCarrello() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permette alla tendina di essere più alta
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7, // 70% dello schermo
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Riepilogo Ordine', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: carrello.isEmpty
                        ? const Center(child: Text('Il carrello è vuoto'))
                        : ListView.builder(
                            itemCount: carrello.length,
                            itemBuilder: (context, index) {
                              final voce = carrello[index];
                              return Card(
                                child: ListTile(
                                  title: Text(voce.nome),
                                  subtitle: Text('${voce.prezzo.toStringAsFixed(2)} €'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () {
                                      // Rimuoviamo l'elemento sia dal carrello principale che dalla vista attuale
                                      setState(() {
                                        carrello.removeAt(index);
                                      });
                                      setModalState(() {}); 
                                      if (carrello.isEmpty) Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Totale:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('${calcolaTotale().toStringAsFixed(2)} €', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (carrello.isNotEmpty)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        inviaOrdine();
                      },
                      child: const Text('INVIA ORDINE IN CUCINA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void inviaOrdine() async {
    if (carrello.isEmpty) return;
    String dettagli = carrello.map((p) => p.nome).join(', ');
    try {
      await apiService.inviaOrdine(calcolaTotale(), dettagli);
      if (!mounted) return;
      setState(() => carrello.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ordine inviato! Buon appetito!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍔 Hamburgeria Totem'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: FutureBuilder<List<Prodotto>>(
        future: futureProdotti,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Errore: ${snapshot.error}'));
          final prodotti = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: prodotti.length,
            itemBuilder: (context, index) {
              final prodotto = prodotti[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.fastfood, color: Colors.white)),
                  title: Text(prodotto.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('${prodotto.prezzo.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.green, fontSize: 16)),
                  trailing: ElevatedButton(
                    onPressed: () => setState(() => carrello.add(prodotto)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Aggiungi', style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: carrello.isEmpty 
        ? null 
        : Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Totale provvisorio'),
                      Text('${calcolaTotale().toStringAsFixed(2)} €', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: mostraCarrello,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15)),
                  child: const Text('VEDI CARRELLO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
    );
  }
}
