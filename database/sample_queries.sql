-- 查詢範例 SQL
-- Sample Query Examples

USE toeic_db;

-- =====================================================
-- 基本查詢範例 (Basic Query Examples)
-- =====================================================

-- 1. 查詢所有單字和其例句 (Get all words with their sentences)
SELECT 
    w.id,
    w.eng_word,
    w.tw_word,
    w.day_number,
    w.difficulty_level,
    s.eng_sentence,
    s.tw_sentence
FROM words w
LEFT JOIN sentences s ON w.id = s.word_id
WHERE w.is_active = TRUE
ORDER BY w.day_number, w.eng_word;

-- 2. 查詢特定天數的單字 (Get words for specific day)
SELECT 
    w.eng_word,
    w.tw_word,
    GROUP_CONCAT(s.eng_sentence SEPARATOR ' | ') as all_eng_sentences,
    GROUP_CONCAT(s.tw_sentence SEPARATOR ' | ') as all_tw_sentences
FROM words w
LEFT JOIN sentences s ON w.id = s.word_id
WHERE w.day_number = 1 AND w.is_active = TRUE
GROUP BY w.id, w.eng_word, w.tw_word
ORDER BY w.eng_word;

-- 3. 查詢使用者學習進度 (Get user learning progress)
SELECT 
    u.username,
    w.eng_word,
    w.tw_word,
    up.mastery_level,
    up.review_count,
    up.last_reviewed
FROM user_progress up
JOIN users u ON up.user_id = u.id
JOIN words w ON up.word_id = w.id
WHERE u.username = 'demo_user'
ORDER BY up.last_reviewed DESC;

-- 4. 統計各難度等級的單字數量 (Count words by difficulty level)
SELECT 
    difficulty_level,
    COUNT(*) as word_count
FROM words
WHERE is_active = TRUE
GROUP BY difficulty_level;

-- 5. 查詢未完成註冊的使用者 (Get unverified registrations)
SELECT 
    email,
    username,
    registration_date,
    expires_at,
    CASE 
        WHEN expires_at < NOW() THEN 'Expired'
        ELSE 'Active'
    END as status
FROM registrations
WHERE is_verified = FALSE;

-- =====================================================
-- 進階查詢範例 (Advanced Query Examples)
-- =====================================================

-- 6. 查詢每日學習統計 (Daily learning statistics)
SELECT 
    w.day_number,
    COUNT(w.id) as total_words,
    COUNT(CASE WHEN up.mastery_level = 'mastered' THEN 1 END) as mastered_words,
    COUNT(CASE WHEN up.mastery_level IN ('learning', 'familiar') THEN 1 END) as learning_words,
    ROUND(
        COUNT(CASE WHEN up.mastery_level = 'mastered' THEN 1 END) * 100.0 / COUNT(w.id), 
        2
    ) as mastery_percentage
FROM words w
LEFT JOIN user_progress up ON w.id = up.word_id AND up.user_id = 2
WHERE w.is_active = TRUE
GROUP BY w.day_number
ORDER BY w.day_number;

-- 7. 搜尋功能 - 模糊查詢單字或例句 (Search functionality)
SELECT DISTINCT
    w.id,
    w.eng_word,
    w.tw_word,
    w.day_number,
    CASE 
        WHEN w.eng_word LIKE '%experience%' THEN 'Word Match'
        WHEN w.tw_word LIKE '%經驗%' THEN 'Translation Match'
        WHEN s.eng_sentence LIKE '%experience%' THEN 'Sentence Match'
        WHEN s.tw_sentence LIKE '%經驗%' THEN 'Translation Sentence Match'
    END as match_type
FROM words w
LEFT JOIN sentences s ON w.id = s.word_id
WHERE (
    w.eng_word LIKE '%experience%' OR
    w.tw_word LIKE '%經驗%' OR
    s.eng_sentence LIKE '%experience%' OR
    s.tw_sentence LIKE '%經驗%'
) AND w.is_active = TRUE;

-- 8. 使用者活躍度報告 (User activity report)
SELECT 
    u.username,
    u.full_name,
    u.created_at as registration_date,
    u.last_login,
    COUNT(up.id) as words_studied,
    COUNT(CASE WHEN up.mastery_level = 'mastered' THEN 1 END) as words_mastered,
    DATEDIFF(NOW(), u.last_login) as days_since_last_login
FROM users u
LEFT JOIN user_progress up ON u.id = up.user_id
WHERE u.is_active = TRUE
GROUP BY u.id, u.username, u.full_name, u.created_at, u.last_login
ORDER BY words_studied DESC;

-- =====================================================
-- 資料維護查詢 (Data Maintenance Queries)
-- =====================================================

-- 9. 清理過期的註冊記錄 (Clean up expired registrations)
-- SELECT * FROM registrations WHERE expires_at < NOW() AND is_verified = FALSE;
-- DELETE FROM registrations WHERE expires_at < NOW() AND is_verified = FALSE;

-- 10. 備份重要資料的查詢 (Backup important data)
SELECT 
    'words' as table_name,
    COUNT(*) as record_count,
    MIN(created_at) as earliest_record,
    MAX(updated_at) as latest_update
FROM words
UNION ALL
SELECT 
    'sentences' as table_name,
    COUNT(*) as record_count,
    MIN(created_at) as earliest_record,
    MAX(updated_at) as latest_update
FROM sentences
UNION ALL
SELECT 
    'users' as table_name,
    COUNT(*) as record_count,
    MIN(created_at) as earliest_record,
    MAX(updated_at) as latest_update
FROM users;