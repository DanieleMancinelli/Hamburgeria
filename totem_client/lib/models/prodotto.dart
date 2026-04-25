class Prodotto {
  final int id;
  final String nome;
  final double prezzo;
  final String categoria;
  final String immagineUrl;

  Prodotto({
    required this.id,
    required this.nome,
    required this.prezzo,
    required this.categoria,
    required this.immagineUrl,
  });

  factory Prodotto.fromJson(Map<String, dynamic> json) {
    return Prodotto(
      id: json['id'],
      nome: json['nome'],
      prezzo: double.parse(json['prezzo'].toString()),
      categoria: json['categoria'],
      immagineUrl: json['immagine_url'] ?? '',
    );
  }
}
