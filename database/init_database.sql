-- 完整資料庫初始化腳本
-- Complete Database Initialization Script
-- 這個檔案包含所有必要的SQL指令來建立完整的TOEIC資料庫

-- =====================================================
-- 第一部分：建立資料庫
-- Part 1: Create Database
-- =====================================================

-- 刪除資料庫如果存在 (Drop database if exists)
DROP DATABASE IF EXISTS toeic_db;

-- 建立新資料庫 (Create new database)
CREATE DATABASE toeic_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 使用資料庫 (Use database)
USE toeic_db;

-- =====================================================
-- 第二部分：建立資料表結構
-- Part 2: Create Table Structures
-- =====================================================

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

-- 5. 使用者學習進度表格 (User Learning Progress Table)
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

-- 建立額外索引優化查詢效能
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_active ON users(is_active);
CREATE INDEX idx_words_active ON words(is_active);
CREATE INDEX idx_sentences_active ON sentences(is_active);

-- =====================================================
-- 第三部分：插入初始資料
-- Part 3: Insert Initial Data
-- =====================================================

-- 1. 插入系統管理員使用者
INSERT INTO users (username, email, password_hash, full_name, is_active) VALUES 
('admin', 'admin@toeic.com', SHA2('admin123', 256), '系統管理員', TRUE),
('demo_user', 'demo@toeic.com', SHA2('demo123', 256), '示範使用者', TRUE);

-- 2. 插入單字資料
INSERT INTO words (eng_word, tw_word, day_number, difficulty_level, word_type, created_by) VALUES 
('resume', '履歷表', 1, 'medium', 'noun', 1),
('opening', '空缺、職缺、開張、開始', 1, 'medium', 'noun', 1),
('application', '申請、應用程式', 1, 'medium', 'noun', 1),
('interview', '面試', 2, 'medium', 'noun', 1),
('experience', '經驗', 2, 'medium', 'noun', 1),
('qualification', '資格', 2, 'medium', 'noun', 1),
('schedule', '時間表、排程', 3, 'medium', 'noun', 1),
('appointment', '約會、預約', 3, 'medium', 'noun', 1),
('deadline', '截止日期', 3, 'medium', 'noun', 1),
('meeting', '會議', 4, 'medium', 'noun', 1),
('presentation', '簡報、展示', 4, 'medium', 'noun', 1),
('conference', '會議、研討會', 4, 'medium', 'noun', 1);

-- 3. 插入例句資料
INSERT INTO sentences (word_id, eng_sentence, tw_sentence, sentence_order, created_by) VALUES 
(1, 'Fax Your resume and cover letter to the above number.', '請把你的履歷表和求職信傳真到上面的號碼。', 1, 1),
(2, 'There are several job openings at the restaurant right now.', '這間餐廳目前有好幾個職缺。', 1, 1),
(3, 'Please submit your application by the end of this month.', '請在本月底前提交您的申請。', 1, 1),
(4, 'I have a job interview tomorrow morning.', '我明天早上有工作面試。', 1, 1),
(5, 'She has five years of experience in marketing.', '她在行銷方面有五年的經驗。', 1, 1),
(6, 'Do you have the necessary qualifications for this position?', '你具備這個職位所需的資格嗎？', 1, 1),
(7, 'Please check your schedule for next week.', '請檢查你下週的時間表。', 1, 1),
(8, 'I need to make an appointment with the doctor.', '我需要和醫生預約。', 1, 1),
(9, 'The deadline for this project is next Friday.', '這個專案的截止日期是下週五。', 1, 1),
(10, 'We have a team meeting at 2 PM today.', '我們今天下午2點有團隊會議。', 1, 1),
(11, 'The presentation will begin in ten minutes.', '簡報將在十分鐘後開始。', 1, 1),
(12, 'The annual conference will be held in Tokyo.', '年度研討會將在東京舉行。', 1, 1);

-- 4. 插入示範學習進度
INSERT INTO user_progress (user_id, word_id, mastery_level, review_count, last_reviewed) VALUES 
(2, 1, 'learning', 2, NOW()),
(2, 2, 'familiar', 3, NOW()),
(2, 3, 'mastered', 5, NOW()),
(2, 4, 'learning', 1, NOW());

-- 5. 插入示範註冊資料
INSERT INTO registrations (email, username, verification_token, is_verified, verified_date, expires_at, user_id) VALUES 
('demo@toeic.com', 'demo_user', 'verified_token_123', TRUE, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), 2),
('pending@toeic.com', 'pending_user', 'pending_token_456', FALSE, NULL, DATE_ADD(NOW(), INTERVAL 1 DAY), NULL);

-- =====================================================
-- 完成訊息與統計
-- Completion Message and Statistics
-- =====================================================

SELECT 
    'TOEIC Database initialization completed successfully!' AS Status,
    (SELECT COUNT(*) FROM users) AS Users_Count,
    (SELECT COUNT(*) FROM words) AS Words_Count,
    (SELECT COUNT(*) FROM sentences) AS Sentences_Count,
    (SELECT COUNT(*) FROM user_progress) AS Progress_Count,
    (SELECT COUNT(*) FROM registrations) AS Registrations_Count;

-- 顯示所有資料表
SHOW TABLES;