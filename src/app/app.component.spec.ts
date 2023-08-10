import { TestBed } from '@angular/core/testing';
import { RouterTestingModule } from '@angular/router/testing';
import { AppComponent } from './app.component';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';
import { NgIconsModule } from '@ng-icons/core';
import { matVolumeUpOutline } from '@ng-icons/material-icons/outline';
import { PaginationComponent } from './shared/component/pagination/pagination.component';
import { HeaderComponent } from './shared/component/header/header.component';
describe('AppComponent', () => {
  beforeEach(() =>
    TestBed.configureTestingModule({
      imports: [
        RouterTestingModule,
        BrowserModule,
        HttpClientTestingModule,
        FormsModule,
        NgIconsModule.withIcons({ matVolumeUpOutline }),
      ],
      declarations: [AppComponent, HeaderComponent, PaginationComponent],
    })
  );

  it('should create the app', () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });
});
