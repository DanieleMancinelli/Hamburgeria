from flask import Flask, jsonify, request
from flask_cors import CORS
from database_wrapper import DatabaseWrapper

app = Flask(__name__)
CORS(app)  # Permette a Flutter e Angular di comunicare con il backend

db = DatabaseWrapper()

# --- ENDPOINT PER I PRODOTTI (Menu) ---

@app.route('/prodotti', methods=['GET'])
def ottieni_prodotti():
    prodotti = db.ottieni_prodotti()
    return jsonify(prodotti), 200

@app.route('/prodotti', methods=['POST'])
def aggiungi_prodotto():
    dati = request.json
    db.aggiungi_prodotto(dati['nome'], dati['prezzo'], dati['categoria'], dati.get('immagine_url', ''))
    return jsonify({"messaggio": "Prodotto aggiunto con successo"}), 201

@app.route('/prodotti/<int:id>', methods=['PUT'])
def modifica_prodotto(id):
    dati = request.json
    db.modifica_prodotto(id, dati['nome'], dati['prezzo'], dati['categoria'], dati.get('immagine_url', ''))
    return jsonify({"messaggio": "Prodotto modificato"}), 200

@app.route('/prodotti/<int:id>', methods=['DELETE'])
def elimina_prodotto(id):
    db.elimina_prodotto(id)
    return jsonify({"messaggio": "Prodotto eliminato"}), 200


# --- ENDPOINT PER GLI ORDINI ---

@app.route('/ordini', methods=['POST'])
def crea_ordine():
    dati = request.json
    # I dettagli dell'ordine vengono salvati come stringa (JSON)
    db.crea_ordine(dati['totale'], dati['dettagli'])
    return jsonify({"messaggio": "Ordine inviato in cucina!"}), 201

@app.route('/ordini', methods=['GET'])
def ottieni_ordini():
    ordini = db.ottieni_ordini()
    return jsonify(ordini), 200

@app.route('/ordini/<int:id>/stato', methods=['PUT'])
def aggiorna_stato(id):
    dati = request.json
    db.aggiorna_stato_ordine(id, dati['stato'])
    return jsonify({"messaggio": "Stato ordine aggiornato"}), 200

if __name__ == '__main__':
    # Usiamo la porta 5000 di default
    app.run(host='0.0.0.0', port=5000, debug=True)
