import type { ReturnCode } from "./return-code.model";


/**
 * 基礎訊息回應模型
 */
export interface BaseMessageResponse {
  /**
   * 回傳代碼
   */
  code: ReturnCode;
  /**
   * 回傳訊息
   */
  message: string;
};

/**
 * 基礎回應模型
 * @template T - 資料類型
 */
export interface BaseResponse<T> extends BaseMessageResponse {
  /**
   * 回傳資料
   */
  data: T;
};