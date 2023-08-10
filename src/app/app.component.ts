import { HttpClient } from '@angular/common/http';
import { Component, DestroyRef, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { combineLatest } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
export type WordRes = {
  words: Word[];
};
export type Word = {
  engWord: string;
  twWord: string;
  day?: number;
  sentences: Sentences[];
};
export type Sentences = {
  twSentences: string;
  engSentences: string;
};
export enum Lang {
  ENG = 'en',
  ZH_TW = 'zh-TW',
}

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
})
export class AppComponent implements OnInit {
  route = inject(ActivatedRoute);
  http = inject(HttpClient);
  router = inject(Router);
  keyword: string = '';
  days: number[] = [];
  day: string | number = '';
  rate: number = 1;
  words: Word[] = [];
  filterWords: Word[] = [];
  Lang = Lang;
  page = signal(1);
  size = signal(10);
  total = signal(0);
  private _destroyRef = inject(DestroyRef);

  ngOnInit(): void {
    const queryParamMap$ = this.route.queryParamMap;
    const word$ = this.http.get<WordRes>('assets/word.json');
    combineLatest([queryParamMap$, word$])
      .pipe(takeUntilDestroyed(this._destroyRef))
      .subscribe(([params, { words }]) => {
        const set = new Set<number>();
        for (const { day } of words) {
          if (day) {
            if (!set.has(day)) {
              set.add(day);
            }
          }
        }
        this.words = words;
        const array = Array.from(set);
        this.days = array;
        const page = params.get('page');
        const num = page ? parseInt(page) : 1;
        this.page.set(isNaN(num) ? 1 : num);
        this.search();
      });
  }

  speak(word: string, lang: Lang) {
    window.speechSynthesis.cancel();
    const speech = new SpeechSynthesisUtterance();
    speech.lang = lang;
    speech.text = word;
    speech.rate = this.rate;
    window.speechSynthesis.speak(speech);
  }

  searchKeyword() {
    this.router.navigate(['/'], {
      queryParams: {
        page: 1,
      },
    });
  }

  search() {
    let words = this.words.filter(
      (a) =>
        a.twWord.includes(this.keyword.trim()) ||
        a.engWord.includes(this.keyword.trim())
    );
    if (!!this.day) {
      words = words.filter(({ day }) => {
        if (typeof this.day === 'string') {
          return day === parseInt(this.day);
        } else {
          return day === this.day;
        }
      });
    }
    this.total.set(words.length);
    const startIndex = (this.page() - 1) * this.size();
    const endIndex = startIndex + this.size();
    this.filterWords = words.slice(startIndex, endIndex);
  }

  paginationChange(page: number) {
    this.router.navigate(['/'], {
      queryParams: {
        page,
      },
    });
  }
}
