import { ReturnCode } from "~~/server/model/shared/return-code.model";
import { GetWordResponse, wordData } from "~~/server/model/word/word-model";

export default defineEventHandler(() => {
  return {
    code: ReturnCode.Success,
    message: '',
    data: wordData
  } as GetWordResponse;
})