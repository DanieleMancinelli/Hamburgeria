import pymysql
import os
from dotenv import load_dotenv

load_dotenv()

class DatabaseWrapper:
    def __init__(self):
        self.db_config = {
            'host': os.getenv("DB_HOST"),
            'user': os.getenv("DB_USER"),
            'password': os.getenv("DB_PASSWORD"),
            'database': os.getenv("DB_NAME"),
            'port': int(os.getenv("DB_PORT") or 3306),
            'cursorclass': pymysql.cursors.DictCursor
        }
        self.crea_tabelle()

    def _get_connessione(self):
        return pymysql.connect(**self.db_config)

    def crea_tabelle(self):
        connessione = self._get_connessione()
        try:
            with connessione.cursor() as cursor:
                # Tabella Prodotti
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS prodotti (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        nome VARCHAR(255) NOT NULL,
                        prezzo DECIMAL(10, 2) NOT NULL,
                        categoria VARCHAR(100) NOT NULL,
                        immagine_url TEXT
                    )
                """)
                # Tabella Ordini
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS ordini (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        stato VARCHAR(50) DEFAULT 'in attesa',
                        totale DECIMAL(10, 2) NOT NULL,
                        dettagli TEXT,
                        data_ordine TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                """)
            connessione.commit()
        finally:
            connessione.close()

    # --- METODI PER I PRODOTTI ---
    def ottieni_prodotti(self):
        connessione = self._get_connessione()
        try:
            with connessione.cursor() as cursor:
                cursor.execute("SELECT * FROM prodotti")
                return cursor.fetchall()
        finally:
            connessione.close()

    def aggiungi_prodotto(self, nome, prezzo, categoria, immagine_url):
        connessione = self._get_connessione()
        try:
            with connessione.cursor() as cursor:
                sql = "INSERT INTO prodotti (nome, prezzo, categoria, immagine_url) VALUES (%s, %s, %s, %s)"
                cursor.execute(sql, (nome, prezzo, categoria, immagine_url))
            connessione.commit()
        finally:
            connessione.close()

    def modifica_prodotto(self, id, nome, prezzo, categoria, immagine_url):
        connessione = self._get_connessione()
        try:
            with connessione.cursor() as cursor:
                sql = "UPDATE prodotti SET nome=%s, prezzo=%s, categoria=%s, immagine_url=%s WHERE id=%s"
                cursor.execute(sql, (nome, prezzo, categoria, immagine_url, id))
            connessione.commit()
        finally:
            connessione.close()

    def elimina_prodotto(self, id):
        connessione = self._get_connessione()
        try:
            with connessione.cursor() as cursor:
                cursor.execute("DELETE FROM prodotti WHERE id=%s", (id,))
            connessione.commit()
        finally:
            connessione.close()

    # --- METODI PER GLI ORDINI ---
    def crea_ordine(self, totale, dettagli):
        connessione = self._get_connessione()
        try:
            with connessione.cursor() as cursor:
                sql = "INSERT INTO ordini (totale, dettagli) VALUES (%s, %s)"
                cursor.execute(sql, (totale, dettagli))
            connessione.commit()
        finally:
            connessione.close()

    def ottieni_ordini(self):
        connessione = self._get_connessione()
        try:
            with connessione.cursor() as cursor:
                cursor.execute("SELECT * FROM ordini ORDER BY data_ordine DESC")
                return cursor.fetchall()
        finally:
            connessione.close()

    def aggiorna_stato_ordine(self, id, nuovo_stato):
        connessione = self._get_connessione()
        try:
            with connessione.cursor() as cursor:
                cursor.execute("UPDATE ordini SET stato=%s WHERE id=%s", (nuovo_stato, id))
            connessione.commit()
        finally:
            connessione.close()
