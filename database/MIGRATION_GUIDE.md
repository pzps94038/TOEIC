# TOEIC MySQL 資料庫遷移指南
# TOEIC MySQL Database Migration Guide

## 概述 (Overview)

本專案原先使用靜態資料 (wordData array)，現在遷移至 MySQL 資料庫以支援更複雜的功能，包括使用者管理。

This project originally used static data (wordData array) and is now migrating to MySQL database to support more complex features including user management.

## 資料庫結構 (Database Structure)

### 核心資料表 (Core Tables)

1. **users (使用者表格)**
   - 儲存使用者基本資訊
   - 支援登入驗證
   - 追蹤使用者活躍狀態

2. **words (單字表格)**
   - 儲存 TOEIC 單字資料
   - 支援難度分級
   - 按天數組織學習內容

3. **sentences (例句表格)**
   - 儲存單字對應的例句
   - 支援多個例句per單字
   - 中英文對照

## 安裝步驟 (Installation Steps)

### 前置需求 (Prerequisites)
- MySQL 8.0 或更高版本
- 具有 CREATE DATABASE 權限的 MySQL 使用者

### 方法一：使用完整初始化腳本 (Method 1: Complete Initialization)

```bash
# 一次性建立整個資料庫
mysql -u root -p < database/init_database.sql
```

### 方法二：分步驟執行 (Method 2: Step by Step)

```bash
# 1. 建立資料庫
mysql -u root -p < database/01_create_database.sql

# 2. 建立資料表
mysql -u root -p toeic_db < database/02_create_tables.sql

# 3. 插入初始資料
mysql -u root -p toeic_db < database/03_insert_data.sql
```

### 驗證安裝 (Verify Installation)

```bash
# 連接到資料庫並檢查資料表
mysql -u root -p toeic_db

# 在 MySQL 中執行以下查詢：
SHOW TABLES;
SELECT COUNT(*) FROM words;
SELECT COUNT(*) FROM sentences;
SELECT COUNT(*) FROM users;
```

## 資料遷移對照 (Data Migration Mapping)

### 原始 TypeScript 介面 vs MySQL 資料表

#### Word Interface → words table
```typescript
// 原始介面
interface Word {
  engWord: string;        → eng_word VARCHAR(100)
  twWord: string;         → tw_word VARCHAR(200)
  sentences: Sentence[];  → 關聯到 sentences 表格
  day?: number;          → day_number INT
}
```

#### Sentence Interface → sentences table
```typescript
// 原始介面
interface Sentence {
  engSentences: string;   → eng_sentence TEXT
  twSentences: string;    → tw_sentence TEXT
}
```

## 應用程式整合 (Application Integration)

### 建議的資料存取層 (Suggested Data Access Layer)

1. **資料庫連接配置**
   ```typescript
   // 在 nuxt.config.ts 或環境變數中設定
   export default defineNuxtConfig({
     runtimeConfig: {
       mysqlHost: 'localhost',
       mysqlPort: 3306,
       mysqlDatabase: 'toeic_db',
       mysqlUser: 'toeic_user',
       mysqlPassword: 'your_password'
     }
   })
   ```

2. **API 端點更新**
   - 更新 `server/api/word/get-words.ts` 以從資料庫讀取
   - 新增使用者認證 API
   - 新增學習進度追蹤 API

3. **資料庫查詢範例**
   ```sql
   -- 取得單字和例句 (用於替換原始的 wordData)
   SELECT 
       w.id,
       w.eng_word,
       w.tw_word,
       w.day_number,
       JSON_ARRAYAGG(
           JSON_OBJECT(
               'engSentences', s.eng_sentence,
               'twSentences', s.tw_sentence
           )
       ) as sentences
   FROM words w
   LEFT JOIN sentences s ON w.id = s.word_id
   WHERE w.is_active = TRUE
   GROUP BY w.id;
   ```

## 新功能擴展 (New Feature Extensions)

### 使用者功能 (User Features)
- 使用者註冊和登入
- 個人學習進度追蹤
- 自訂學習計畫

### 管理功能 (Admin Features)
- 單字和例句管理
- 使用者管理
- 學習統計報告

## 效能優化 (Performance Optimization)

### 建議的索引策略 (Recommended Indexing Strategy)
- 已包含在 SQL 腳本中的索引
- 根據查詢模式調整索引

### 快取策略 (Caching Strategy)
- 考慮使用 Redis 快取常用查詢
- 靜態資料的記憶體快取

## 備份與維護 (Backup and Maintenance)

### 定期備份 (Regular Backup)
```bash
# 每日備份腳本範例
mysqldump -u root -p toeic_db > backup/toeic_db_$(date +%Y%m%d).sql
```

### 資料清理 (Data Cleanup)
- 定期清理過期的註冊記錄
- 歸檔舊的學習進度資料

## 疑難排解 (Troubleshooting)

### 常見問題 (Common Issues)
1. **字元編碼問題**: 確保使用 utf8mb4
2. **外鍵約束**: 檢查參照完整性
3. **權限問題**: 確認 MySQL 使用者權限

### 測試查詢 (Test Queries)
使用 `database/sample_queries.sql` 中的範例查詢來測試資料庫功能。

## 聯絡資訊 (Contact Information)

如有問題或需要支援，請建立 GitHub Issue 或聯絡專案維護者。

For questions or support, please create a GitHub Issue or contact the project maintainers.