import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prodotto.dart';

class ApiService {
  // Se sei su Codespaces, useremo l'URL che Flask ti fornisce, 
  // per ora mettiamo localhost, poi lo cambieremo se serve.
  static const String baseUrl = 'http://127.0.0.1:5000';

  Future<List<Prodotto>> prendiProdotti() async {
    final response = await http.get(Uri.parse('$baseUrl/prodotti'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Prodotto.fromJson(item)).toList();
    } else {
      throw Exception('Errore nel caricamento dei prodotti');
    }
  }

  Future<void> inviaOrdine(double totale, String dettagli) async {
    await http.post(
      Uri.parse('$baseUrl/ordini'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'totale': totale,
        'dettagli': dettagli,
      }),
    );
  }
}
