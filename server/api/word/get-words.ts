import { ReturnCode } from "~~/server/model/shared/return-code.model";
import { GetWordResponse } from "~~/server/model/word/word-model";
import { WordService } from "~~/server/services/word.service";

export default defineEventHandler(async () => {
  try {
    // 從資料庫獲取所有單字，而不是使用靜態 wordData
    const words = await WordService.getAllWords();
    
    return {
      code: ReturnCode.Success,
      message: '',
      data: words
    } as GetWordResponse;
    
  } catch (error) {
    console.error('Get words error:', error);
    
    return {
      code: ReturnCode.Fail,
      message: '獲取單字資料失敗',
      data: []
    } as GetWordResponse;
  }
})