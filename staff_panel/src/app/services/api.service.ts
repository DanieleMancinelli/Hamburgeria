import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ApiService {

  private baseUrl = 'https://super-dollop-v65r9wj99v4hxx7j-5000.app.github.dev';

  constructor(private http: HttpClient) { }

  // --- GESTIONE PRODOTTI ---
  ottieniProdotti(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/prodotti`);
  }

  aggiungiProdotto(prodotto: any): Observable<any> {
    return this.http.post(`${this.baseUrl}/prodotti`, prodotto);
  }

  eliminaProdotto(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/prodotti/${id}`);
  }

  // --- GESTIONE ORDINI ---
  ottieniOrdini(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/ordini`);
  }

  aggiornaStatoOrdine(id: number, nuovoStato: string): Observable<any> {
    return this.http.put(`${this.baseUrl}/ordini/${id}/stato`, { stato: nuovoStato });
  }
}
