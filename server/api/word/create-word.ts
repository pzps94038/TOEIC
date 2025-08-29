import { ReturnCode } from "~~/server/model/shared/return-code.model";
import type { BaseResponse } from "~~/server/model/shared/base-response.model";
import type { WordWithDay, Sentence } from "~~/server/model/word/word-model";
import { WordService } from "~~/server/services/word.service";

export interface CreateWordRequest {
  /**
   * 英文單字
   */
  engWord: string;
  /**
   * 中文單字
   */
  twWord: string;
  /**
   * 第幾天的單字
   */
  day: number;
  /**
   * 範例句
   */
  sentences: Sentence[];
}

export interface CreateWordResponse extends BaseResponse<WordWithDay> { }

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event) as CreateWordRequest;
    
    // 使用 WordService 建立單字 (遵循 word-model.ts 的結構)
    const newWord = await WordService.createWord({
      engWord: body.engWord,
      twWord: body.twWord,
      day: body.day,
      sentences: body.sentences
    });

    return {
      code: ReturnCode.Success,
      message: '單字建立成功',
      data: newWord
    } as CreateWordResponse;

  } catch (error) {
    console.error('Create word error:', error);
    
    // 如果是驗證錯誤，回傳具體錯誤訊息
    if (error instanceof Error) {
      return {
        code: ReturnCode.Fail,
        message: error.message,
        data: null
      } as CreateWordResponse;
    }
    
    return {
      code: ReturnCode.Fail,
      message: '伺服器內部錯誤',
      data: null
    } as CreateWordResponse;
  }
});