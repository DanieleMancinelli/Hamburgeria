import 'dart:async';
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
  List<Prodotto> prodotti = [];
  List<Prodotto> carrello = [];
  bool caricamento = true;
  Timer? _timer;

  // DEFINIAMO L'ORDINE FISSO DELLE CATEGORIE
  final List<String> ordineCategorie = ['panini', 'contorni', 'bevande'];

  @override
  void initState() {
    super.initState();
    caricaDati();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) => caricaDati());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void caricaDati() async {
    try {
      final nuoviProdotti = await apiService.prendiProdotti();
      if (!mounted) return;
      setState(() {
        prodotti = nuoviProdotti;
        caricamento = false;
      });
    } catch (e) {
      // Errore silenziato
    }
  }

  double calcolaTotale() {
    return carrello.fold(0, (tot, prod) => tot + prod.prezzo);
  }

  void mostraCarrello() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Il tuo Ordine', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: voce.immagineUrl.isNotEmpty 
                                    ? Image.network(voce.immagineUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.fastfood))
                                    : const Icon(Icons.fastfood),
                                ),
                                title: Text(voce.nome),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    setState(() => carrello.removeAt(index));
                                    setModalState(() {}); 
                                    if (carrello.isEmpty) Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 60)),
                    onPressed: () {
                      Navigator.pop(context);
                      inviaOrdine();
                    },
                    child: Text('CONFERMA ORDINE (${calcolaTotale().toStringAsFixed(2)} €)', style: const TextStyle(color: Colors.white, fontSize: 18)),
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
    try {
      await apiService.inviaOrdine(calcolaTotale(), carrello.map((p) => p.nome).join(', '));
      if (!mounted) return;
      setState(() => carrello.clear());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ordine inviato!'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍔 Hamburgeria Totem'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: caricamento 
          ? const Center(child: CircularProgressIndicator())
          : prodotti.isEmpty
              ? const Center(child: Text('Nessun prodotto disponibile'))
              : ListView(
                  padding: const EdgeInsets.all(10),
                  children: ordineCategorie.map((cat) {
                    // Filtriamo i prodotti che appartengono a questa specifica categoria
                    final prodottiDellaCategoria = prodotti.where((p) => p.categoria.toLowerCase() == cat.toLowerCase()).toList();
                    
                    // Se non ci sono prodotti in questa categoria, non mostriamo nemmeno l'header
                    if (prodottiDellaCategoria.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                          child: Text(
                            cat.toUpperCase(),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ),
                        ...prodottiDellaCategoria.map((prodotto) => Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: prodotto.immagineUrl.isNotEmpty
                                  ? Image.network(prodotto.immagineUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.fastfood))
                                  : const Icon(Icons.fastfood),
                            ),
                            title: Text(prodotto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${prodotto.prezzo.toStringAsFixed(2)} €'),
                            trailing: ElevatedButton(
                              onPressed: () => setState(() => carrello.add(prodotto)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              child: const Text('Aggiungi', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        )),
                        const SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                ),
      bottomNavigationBar: carrello.isEmpty ? null : Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: mostraCarrello,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
          child: const Text('VEDI CARRELLO E ORDINA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
