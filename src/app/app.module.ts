import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { FormsModule } from '@angular/forms';
import { HeaderComponent } from './shared/component/header/header.component';
import { NgIconsModule } from '@ng-icons/core';
import { matVolumeUpOutline } from '@ng-icons/material-icons/outline';
import { PaginationComponent } from './shared/component/pagination/pagination.component';
@NgModule({
  declarations: [AppComponent, HeaderComponent, PaginationComponent],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    FormsModule,
    NgIconsModule.withIcons({ matVolumeUpOutline }),
  ],
  providers: [],
  bootstrap: [AppComponent],
})
export class AppModule {}
