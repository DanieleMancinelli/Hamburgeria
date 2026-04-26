import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DashboardOrdiniComponent } from './dashboard-ordini.component';

describe('DashboardOrdiniComponent', () => {
  let component: DashboardOrdiniComponent;
  let fixture: ComponentFixture<DashboardOrdiniComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DashboardOrdiniComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(DashboardOrdiniComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
