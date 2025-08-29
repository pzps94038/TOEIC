-- 建立 TOEIC 資料庫
-- Create TOEIC Database

-- 刪除資料庫如果存在 (Drop database if exists)
DROP DATABASE IF EXISTS toeic_db;

-- 建立新資料庫 (Create new database)
CREATE DATABASE toeic_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 使用資料庫 (Use database)
USE toeic_db;

-- 建立 MySQL 使用者 (Create MySQL user - optional)
-- CREATE USER 'toeic_user'@'localhost' IDENTIFIED BY 'toeic_password';
-- GRANT ALL PRIVILEGES ON toeic_db.* TO 'toeic_user'@'localhost';
-- FLUSH PRIVILEGES;

SELECT 'Database toeic_db created successfully!' AS Result;