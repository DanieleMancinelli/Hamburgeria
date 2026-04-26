import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../services/api.service';

@Component({
  selector: 'app-gestione-menu',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './gestione-menu.component.html',
  styleUrl: './gestione-menu.component.css'
})
export class GestioneMenuComponent implements OnInit {
  prodotti: any[] = [];
  nuovoProdotto = { nome: '', prezzo: 0, categoria: 'panini', immagine_url: '' };

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.caricaProdotti();
  }

  caricaProdotti() {
    this.api.ottieniProdotti().subscribe(data => {
      this.prodotti = data;
    });
  }

  aggiungi() {
    if (this.nuovoProdotto.nome && this.nuovoProdotto.prezzo > 0) {
      this.api.aggiungiProdotto(this.nuovoProdotto).subscribe(() => {
        this.caricaProdotti();
        this.nuovoProdotto = { nome: '', prezzo: 0, categoria: 'panini', immagine_url: '' };
      });
    }
  }

  elimina(id: number) {
    if (confirm('Sei sicuro di voler eliminare questo prodotto?')) {
      this.api.eliminaProdotto(id).subscribe(() => {
        this.caricaProdotti();
      });
    }
  }
}
