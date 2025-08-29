-- 建立資料表結構
-- Create Table Structures

USE toeic_db;

-- 1. 使用者表格 (Users Table)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '使用者名稱',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '電子郵件',
    password_hash VARCHAR(255) NOT NULL COMMENT '密碼雜湊值',
    full_name VARCHAR(100) COMMENT '全名',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否啟用',
    last_login TIMESTAMP NULL COMMENT '最後登入時間'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='使用者資料表';

-- 2. 註冊表格 (Registration Table)
CREATE TABLE registrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL COMMENT '註冊電子郵件',
    username VARCHAR(50) NOT NULL COMMENT '註冊使用者名稱',
    verification_token VARCHAR(255) NOT NULL COMMENT '驗證令牌',
    is_verified BOOLEAN DEFAULT FALSE COMMENT '是否已驗證',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '註冊日期',
    verified_date TIMESTAMP NULL COMMENT '驗證日期',
    expires_at TIMESTAMP NOT NULL COMMENT '令牌過期時間',
    user_id INT NULL COMMENT '關聯的使用者ID',
    INDEX idx_email (email),
    INDEX idx_token (verification_token),
    INDEX idx_expires (expires_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='使用者註冊驗證表';

-- 3. 單字表格 (Words Table)
CREATE TABLE words (
    id INT AUTO_INCREMENT PRIMARY KEY,
    eng_word VARCHAR(100) NOT NULL COMMENT '英文單字',
    tw_word VARCHAR(200) NOT NULL COMMENT '中文釋義',
    day_number INT DEFAULT 1 COMMENT '學習天數',
    difficulty_level ENUM('easy', 'medium', 'hard') DEFAULT 'medium' COMMENT '難度等級',
    word_type VARCHAR(50) COMMENT '詞性 (名詞、動詞等)',
    pronunciation VARCHAR(100) COMMENT '音標',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間',
    created_by INT COMMENT '建立者ID',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否啟用',
    INDEX idx_eng_word (eng_word),
    INDEX idx_day (day_number),
    INDEX idx_difficulty (difficulty_level),
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY unique_eng_word (eng_word)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='TOEIC單字表';

-- 4. 例句表格 (Sentences Table)
CREATE TABLE sentences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    word_id INT NOT NULL COMMENT '關聯的單字ID',
    eng_sentence TEXT NOT NULL COMMENT '英文例句',
    tw_sentence TEXT NOT NULL COMMENT '中文例句',
    sentence_order INT DEFAULT 1 COMMENT '例句順序',
    audio_url VARCHAR(255) COMMENT '音頻檔案URL',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間',
    created_by INT COMMENT '建立者ID',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否啟用',
    INDEX idx_word_id (word_id),
    INDEX idx_order (sentence_order),
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='單字例句表';

-- 5. 使用者學習進度表格 (User Learning Progress Table) - 額外功能
CREATE TABLE user_progress (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL COMMENT '使用者ID',
    word_id INT NOT NULL COMMENT '單字ID',
    learned_date DATE DEFAULT (CURRENT_DATE) COMMENT '學習日期',
    mastery_level ENUM('not_learned', 'learning', 'familiar', 'mastered') DEFAULT 'not_learned' COMMENT '掌握程度',
    review_count INT DEFAULT 0 COMMENT '複習次數',
    last_reviewed TIMESTAMP NULL COMMENT '最後複習時間',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間',
    INDEX idx_user_word (user_id, word_id),
    INDEX idx_mastery (mastery_level),
    INDEX idx_learned_date (learned_date),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_word (user_id, word_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='使用者學習進度表';

-- 建立索引優化查詢效能
-- Create indexes for query optimization
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_active ON users(is_active);
CREATE INDEX idx_words_active ON words(is_active);
CREATE INDEX idx_sentences_active ON sentences(is_active);

SELECT 'All tables created successfully!' AS Result;