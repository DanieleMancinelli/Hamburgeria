import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../services/api.service';

@Component({
  selector: 'app-dashboard-ordini',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard-ordini.component.html',
  styleUrl: './dashboard-ordini.component.css'
})
export class DashboardOrdiniComponent implements OnInit {
  ordini: any[] = [];

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.caricaOrdini();
    // Aggiorna gli ordini ogni 10 secondi automaticamente
    setInterval(() => this.caricaOrdini(), 10000);
  }

  caricaOrdini() {
    this.api.ottieniOrdini().subscribe(data => {
      this.ordini = data;
    });
  }

  cambiaStato(id: number, nuovoStato: string) {
    this.api.aggiornaStatoOrdine(id, nuovoStato).subscribe(() => {
      this.caricaOrdini(); // Ricarica la lista dopo la modifica
    });
  }
}
