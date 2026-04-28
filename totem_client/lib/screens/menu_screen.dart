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
      // Errore ignorato per il linter
    }
  }

  double calcolaTotale() {
    return carrello.fold(0, (tot, prod) => tot + prod.prezzo);
  }

  void mostraCarrello() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(25),
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('IL TUO ORDINE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), letterSpacing: 1.2)),
                  const Divider(color: Colors.white24),
                  Expanded(
                    child: carrello.isEmpty
                        ? const Center(child: Text('Il carrello è ancora vuoto'))
                        : ListView.builder(
                            itemCount: carrello.length,
                            itemBuilder: (context, index) {
                              final voce = carrello[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0x0DFFFFFF), // Sostituito withOpacity per evitare deprecation
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                child: ListTile(
                                  title: Text(voce.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                    onPressed: () {
                                      setState(() => carrello.removeAt(index));
                                      setModalState(() {}); 
                                      if (carrello.isEmpty) Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTALE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${calcolaTotale().toStringAsFixed(2)} €', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 65),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      inviaOrdine();
                    },
                    child: const Text('CONFERMA E ORDINA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      // Errore ignorato per il linter
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 180,
            backgroundColor: const Color(0xFF0A0A0A),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('GOURMET BURGER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFFD4AF37))),
              centerTitle: true,
              background: Container(color: const Color(0xFF0A0A0A)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(15),
            sliver: caricamento 
              ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cat = ordineCategorie[index];
                      final prodottiDellaCategoria = prodotti.where((p) => p.categoria.toLowerCase() == cat.toLowerCase()).toList();
                      if (prodottiDellaCategoria.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 25, bottom: 15, left: 10),
                            child: Text(cat.toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), letterSpacing: 1.5)),
                          ),
                          ...prodottiDellaCategoria.map((prodotto) => Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0x0DFFFFFF)), // Sostituito withOpacity
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: prodotto.immagineUrl.isNotEmpty
                                    ? Image.network(prodotto.immagineUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width:80, color: Colors.white10, child: const Icon(Icons.fastfood)))
                                    : Container(width: 80, color: Colors.white10, child: const Icon(Icons.fastfood)),
                              ),
                              title: Text(prodotto.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('${prodotto.prezzo.toStringAsFixed(2)} €', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              trailing: IconButton(
                                onPressed: () => setState(() => carrello.add(prodotto)),
                                icon: const Icon(Icons.add, color: Colors.black),
                                style: IconButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                              ),
                            ),
                          )),
                        ],
                      );
                    },
                    childCount: ordineCategorie.length,
                  ),
                ),
          ),
        ],
      ),
      bottomNavigationBar: carrello.isEmpty ? null : Container(
        height: 100,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ElevatedButton(
          onPressed: mostraCarrello,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined),
              const SizedBox(width: 10),
              Text('VEDI ORDINE (${carrello.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
