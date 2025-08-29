import type { WordWithDay, Sentence } from "~~/server/model/word/word-model";
import { pool } from "~~/server/utils/database";
import type { RowDataPacket, ResultSetHeader } from "mysql2";

/**
 * 單字服務類別
 * 處理單字的建立、查詢、更新、刪除等操作
 */
export class WordService {
  
  /**
   * 建立新單字
   * @param wordData 單字資料
   * @returns 建立的單字物件
   */
  static async createWord(wordData: {
    engWord: string;
    twWord: string;
    day: number;
    sentences: Sentence[];
  }): Promise<WordWithDay> {
    
    // 驗證單字資料
    this.validateWordData(wordData);
    
    const connection = await pool.getConnection();
    
    try {
      // 開始交易
      await connection.beginTransaction();
      
      // 檢查單字是否已存在
      const existsResult = await connection.execute<RowDataPacket[]>(
        'SELECT COUNT(*) as count FROM words WHERE eng_word = ?',
        [wordData.engWord.trim()]
      );
      
      if (existsResult[0][0].count > 0) {
        throw new Error('此英文單字已存在');
      }
      
      // 插入單字資料
      const insertWordResult = await connection.execute<ResultSetHeader>(
        'INSERT INTO words (eng_word, tw_word, day_number, difficulty_level, created_at) VALUES (?, ?, ?, ?, NOW())',
        [wordData.engWord.trim(), wordData.twWord.trim(), wordData.day, 'medium']
      );
      
      const wordId = insertWordResult[0].insertId;
      
      // 插入例句資料
      for (let i = 0; i < wordData.sentences.length; i++) {
        const sentence = wordData.sentences[i];
        await connection.execute(
          'INSERT INTO sentences (word_id, eng_sentence, tw_sentence, sentence_order, created_at) VALUES (?, ?, ?, ?, NOW())',
          [wordId, sentence.engSentences.trim(), sentence.twSentences.trim(), i + 1]
        );
      }
      
      // 提交交易
      await connection.commit();
      
      // 建立返回物件 (遵循 word-model.ts 的結構)
      const newWord: WordWithDay = {
        engWord: wordData.engWord.trim(),
        twWord: wordData.twWord.trim(),
        day: wordData.day,
        sentences: wordData.sentences.map(sentence => ({
          engSentences: sentence.engSentences.trim(),
          twSentences: sentence.twSentences.trim()
        }))
      };
      
      return newWord;
      
    } catch (error) {
      // 回滾交易
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  /**
   * 驗證單字資料格式
   * @param wordData 要驗證的單字資料
   * @throws Error 當資料格式不正確時
   */
  static validateWordData(wordData: any): void {
    if (!wordData.engWord || typeof wordData.engWord !== 'string') {
      throw new Error('英文單字為必要欄位且必須為字串');
    }
    
    if (!wordData.twWord || typeof wordData.twWord !== 'string') {
      throw new Error('中文單字為必要欄位且必須為字串');
    }
    
    if (!wordData.day || typeof wordData.day !== 'number' || wordData.day < 1) {
      throw new Error('學習日期必須為大於0的數字');
    }
    
    if (!Array.isArray(wordData.sentences) || wordData.sentences.length === 0) {
      throw new Error('必須提供至少一個例句');
    }
    
    // 驗證每個例句
    wordData.sentences.forEach((sentence: any, index: number) => {
      if (!sentence.engSentences || typeof sentence.engSentences !== 'string') {
        throw new Error(`第 ${index + 1} 個例句的英文句子為必要欄位且必須為字串`);
      }
      
      if (!sentence.twSentences || typeof sentence.twSentences !== 'string') {
        throw new Error(`第 ${index + 1} 個例句的中文句子為必要欄位且必須為字串`);
      }
    });
  }

  /**
   * 檢查單字是否已存在
   * @param engWord 英文單字
   * @returns 是否已存在
   */
  static async isWordExists(engWord: string): Promise<boolean> {
    const connection = await pool.getConnection();
    
    try {
      const [rows] = await connection.execute<RowDataPacket[]>(
        'SELECT COUNT(*) as count FROM words WHERE eng_word = ? AND is_active = TRUE',
        [engWord.trim()]
      );
      
      return rows[0].count > 0;
    } finally {
      connection.release();
    }
  }

  /**
   * 依據學習日期獲取單字
   * @param day 學習日期
   * @returns 該日期的單字列表
   */
  static async getWordsByDay(day: number): Promise<WordWithDay[]> {
    const connection = await pool.getConnection();
    
    try {
      const [rows] = await connection.execute<RowDataPacket[]>(
        `SELECT 
          w.eng_word,
          w.tw_word,
          w.day_number as day,
          s.eng_sentence as engSentences,
          s.tw_sentence as twSentences
        FROM words w
        LEFT JOIN sentences s ON w.id = s.word_id
        WHERE w.day_number = ? AND w.is_active = TRUE AND s.is_active = TRUE
        ORDER BY w.eng_word, s.sentence_order`,
        [day]
      );
      
      // 將查詢結果轉換為 WordWithDay 格式
      const wordMap = new Map<string, WordWithDay>();
      
      rows.forEach(row => {
        if (!wordMap.has(row.eng_word)) {
          wordMap.set(row.eng_word, {
            engWord: row.eng_word,
            twWord: row.tw_word,
            day: row.day,
            sentences: []
          });
        }
        
        const word = wordMap.get(row.eng_word)!;
        if (row.engSentences && row.twSentences) {
          word.sentences.push({
            engSentences: row.engSentences,
            twSentences: row.twSentences
          });
        }
      });
      
      return Array.from(wordMap.values());
    } finally {
      connection.release();
    }
  }

  /**
   * 獲取所有單字
   * @returns 所有單字列表
   */
  static async getAllWords(): Promise<WordWithDay[]> {
    const connection = await pool.getConnection();
    
    try {
      const [rows] = await connection.execute<RowDataPacket[]>(
        `SELECT 
          w.eng_word,
          w.tw_word,
          w.day_number as day,
          s.eng_sentence as engSentences,
          s.tw_sentence as twSentences
        FROM words w
        LEFT JOIN sentences s ON w.id = s.word_id
        WHERE w.is_active = TRUE AND s.is_active = TRUE
        ORDER BY w.day_number, w.eng_word, s.sentence_order`
      );
      
      // 將查詢結果轉換為 WordWithDay 格式
      const wordMap = new Map<string, WordWithDay>();
      
      rows.forEach(row => {
        if (!wordMap.has(row.eng_word)) {
          wordMap.set(row.eng_word, {
            engWord: row.eng_word,
            twWord: row.tw_word,
            day: row.day,
            sentences: []
          });
        }
        
        const word = wordMap.get(row.eng_word)!;
        if (row.engSentences && row.twSentences) {
          word.sentences.push({
            engSentences: row.engSentences,
            twSentences: row.twSentences
          });
        }
      });
      
      return Array.from(wordMap.values());
    } finally {
      connection.release();
    }
  }
}