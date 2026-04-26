import { Routes } from '@angular/router';
import { DashboardOrdiniComponent } from './dashboard-ordini/dashboard-ordini.component';
import { GestioneMenuComponent } from './gestione-menu/gestione-menu.component';

export const routes: Routes = [
    { path: '', component: DashboardOrdiniComponent },
    { path: 'gestione-menu', component: GestioneMenuComponent }
];
