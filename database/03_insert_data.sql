-- 插入初始資料
-- Insert Initial Data

USE toeic_db;

-- 1. 插入系統管理員使用者 (Insert system admin user)
INSERT INTO users (username, email, password_hash, full_name, is_active) VALUES 
('admin', 'admin@toeic.com', SHA2('admin123', 256), '系統管理員', TRUE),
('demo_user', 'demo@toeic.com', SHA2('demo123', 256), '示範使用者', TRUE);

-- 2. 插入單字資料 (Insert word data from existing wordData)
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

-- 3. 插入例句資料 (Insert sentence data)
INSERT INTO sentences (word_id, eng_sentence, tw_sentence, sentence_order, created_by) VALUES 
-- resume (id: 1)
(1, 'Fax Your resume and cover letter to the above number.', '請把你的履歷表和求職信傳真到上面的號碼。', 1, 1),

-- opening (id: 2)
(2, 'There are several job openings at the restaurant right now.', '這間餐廳目前有好幾個職缺。', 1, 1),

-- application (id: 3)
(3, 'Please submit your application by the end of this month.', '請在本月底前提交您的申請。', 1, 1),

-- interview (id: 4)
(4, 'I have a job interview tomorrow morning.', '我明天早上有工作面試。', 1, 1),

-- experience (id: 5)
(5, 'She has five years of experience in marketing.', '她在行銷方面有五年的經驗。', 1, 1),

-- qualification (id: 6)
(6, 'Do you have the necessary qualifications for this position?', '你具備這個職位所需的資格嗎？', 1, 1),

-- schedule (id: 7)
(7, 'Please check your schedule for next week.', '請檢查你下週的時間表。', 1, 1),

-- appointment (id: 8)
(8, 'I need to make an appointment with the doctor.', '我需要和醫生預約。', 1, 1),

-- deadline (id: 9)
(9, 'The deadline for this project is next Friday.', '這個專案的截止日期是下週五。', 1, 1),

-- meeting (id: 10)
(10, 'We have a team meeting at 2 PM today.', '我們今天下午2點有團隊會議。', 1, 1),

-- presentation (id: 11)
(11, 'The presentation will begin in ten minutes.', '簡報將在十分鐘後開始。', 1, 1),

-- conference (id: 12)
(12, 'The annual conference will be held in Tokyo.', '年度研討會將在東京舉行。', 1, 1);





-- 顯示插入的資料統計
SELECT 
    'Data insertion completed!' AS Status,
    (SELECT COUNT(*) FROM users) AS Users_Count,
    (SELECT COUNT(*) FROM words) AS Words_Count,
    (SELECT COUNT(*) FROM sentences) AS Sentences_Count;