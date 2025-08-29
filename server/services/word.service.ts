import type { WordWithDay, Sentence } from "~~/server/model/word/word-model";

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
    
    // 建立單字物件 (遵循 word-model.ts 的結構)
    const newWord: WordWithDay = {
      engWord: wordData.engWord.trim(),
      twWord: wordData.twWord.trim(),
      day: wordData.day,
      sentences: wordData.sentences.map(sentence => ({
        engSentences: sentence.engSentences.trim(),
        twSentences: sentence.twSentences.trim()
      }))
    };

    // TODO: 將單字儲存到 MySQL 資料庫
    // 使用之前建立的 database migration 結構
    // INSERT INTO words (eng_word, tw_word, day_number, difficulty_level, word_type, created_by)
    // INSERT INTO sentences (word_id, eng_sentence, tw_sentence, sentence_order, created_by)
    
    return newWord;
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
    // TODO: 查詢資料庫檢查單字是否已存在
    // SELECT COUNT(*) FROM words WHERE eng_word = ?
    return false;
  }

  /**
   * 依據學習日期獲取單字
   * @param day 學習日期
   * @returns 該日期的單字列表
   */
  static async getWordsByDay(day: number): Promise<WordWithDay[]> {
    // TODO: 從資料庫查詢指定日期的單字
    // SELECT w.*, s.* FROM words w LEFT JOIN sentences s ON w.id = s.word_id WHERE w.day_number = ?
    return [];
  }
}