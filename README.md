README.md

# TOEIC 單字學習 - Nuxt 4.0 版本

這是一個 TOEIC 單字學習應用，從 Angular 轉換至 Nuxt 4.0。

## 功能特色

- 🔍 單字搜尋功能
- 📚 依天數篩選單字
- 🔊 語音朗讀功能（英文/中文）
- 📄 分頁瀏覽
- 📱 響應式設計
- 🎨 使用 DaisyUI 美化界面

## 技術棧

- **Nuxt 4.0** - Vue.js 框架
- **Vue 3** - 前端框架
- **TypeScript** - 類型支援
- **Tailwind CSS** - CSS 框架
- **DaisyUI** - UI 組件庫
- **@nuxt/ui** - Nuxt UI 組件

## 開發環境設置

### 安裝依賴

```bash
npm install
```

### 啟動開發服務器

```bash
npm run dev
```

### 建置生產版本

```bash
npm run build
```

### 預覽生產版本

```bash
npm run preview
```

## 專案結構

```
├── components/          # Vue組件
│   ├── Header.vue      # 頁首組件
│   └── Pagination.vue  # 分頁組件
├── types/              # TypeScript類型定義
│   └── index.ts        # 主要類型定義
├── public/             # 靜態資源
│   └── word.json       # 單字資料
├── assets/             # 資源文件
│   └── css/
│       └── main.css    # 主要樣式
├── app.vue             # 主要應用組件
├── nuxt.config.ts      # Nuxt配置
└── package.json        # 依賴管理
```

## 主要變更（從 Angular 轉換）

1. **框架替換**: Angular → Nuxt/Vue
2. **組件語法**: Angular 組件 → Vue SFC
3. **狀態管理**: Angular Signals → Vue Composition API
4. **路由**: Angular Router → Nuxt Pages
5. **HTTP 請求**: Angular HttpClient → Nuxt $fetch
6. **生命週期**: Angular OnInit → Vue setup()

## 使用說明

1. 在搜尋欄輸入關鍵字來搜尋單字
2. 使用天數選擇器篩選特定天數的單字
3. 點擊 🔊 按鈕聽取單字或句子的發音
4. 使用下方分頁導航瀏覽更多單字
5. 調整速率控制語音播放速度

## 貢獻

歡迎提交 Issue 和 Pull Request 來改善這個專案。

## 授權

本專案採用 MIT 授權。
