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

-- 3. 統計各難度等級的單字數量 (Count words by difficulty level)
SELECT 
    difficulty_level,
    COUNT(*) as word_count
FROM words
WHERE is_active = TRUE
GROUP BY difficulty_level;



-- =====================================================
-- 進階查詢範例 (Advanced Query Examples)
-- =====================================================

-- 4. 搜尋功能 - 模糊查詢單字或例句 (Search functionality)
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

-- 5. 備份重要資料的查詢 (Backup important data)
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