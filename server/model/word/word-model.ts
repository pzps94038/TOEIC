import type { BaseResponse } from "../shared/base-response.model";

export interface GetWordResponse extends BaseResponse<Word[]> { }

/**
 * Word API 回傳資料結構
 */
export interface Word {
  /**
   * 英文單字
   */
  engWord: string;
  /**
   * 中文單字
   */
  twWord: string;
  /**
   * 範例句
   */
  sentences: Sentence[];
}

/**
 * 完整單字資料結構 (包含學習日期)
 */
export interface WordWithDay extends Word {
  /**
   * 第幾天的單字
   */
  day: number;
}

/**
 * 例句
 */
export interface Sentence {
  /**
   * 中文例句
   */
  twSentences: string;
  /**
   * 英文例句
   */
  engSentences: string;
}

export enum Lang {
  ENG = "en",
  ZH_TW = "zh-TW",
};

export const wordData = [
  {
    engWord: "resume",
    twWord: "履歷表",
    day: 1,
    sentences: [
      {
        engSentences: "Fax Your resume and cover letter to the above number.",
        twSentences: "請把你的履歷表和求職信傳真到上面的號碼。",
      },
    ],
  },
  {
    engWord: "opening",
    twWord: "空缺、職缺、開張、開始",
    day: 1,
    sentences: [
      {
        engSentences:
          "There are several job openings at the restaurant right now.",
        twSentences: "這間餐廳目前有好幾個職缺。",
      },
    ],
  },
  {
    engWord: "application",
    twWord: "申請、應用程式",
    day: 1,
    sentences: [
      {
        engSentences:
          "Please submit your application by the end of this month.",
        twSentences: "請在本月底前提交您的申請。",
      },
    ],
  },
  {
    engWord: "interview",
    twWord: "面試",
    day: 2,
    sentences: [
      {
        engSentences: "I have a job interview tomorrow morning.",
        twSentences: "我明天早上有工作面試。",
      },
    ],
  },
  {
    engWord: "experience",
    twWord: "經驗",
    day: 2,
    sentences: [
      {
        engSentences: "She has five years of experience in marketing.",
        twSentences: "她在行銷方面有五年的經驗。",
      },
    ],
  },
  {
    engWord: "qualification",
    twWord: "資格",
    day: 2,
    sentences: [
      {
        engSentences:
          "Do you have the necessary qualifications for this position?",
        twSentences: "你具備這個職位所需的資格嗎？",
      },
    ],
  },
  {
    engWord: "schedule",
    twWord: "時間表、排程",
    day: 3,
    sentences: [
      {
        engSentences: "Please check your schedule for next week.",
        twSentences: "請檢查你下週的時間表。",
      },
    ],
  },
  {
    engWord: "appointment",
    twWord: "約會、預約",
    day: 3,
    sentences: [
      {
        engSentences: "I need to make an appointment with the doctor.",
        twSentences: "我需要和醫生預約。",
      },
    ],
  },
  {
    engWord: "deadline",
    twWord: "截止日期",
    day: 3,
    sentences: [
      {
        engSentences: "The deadline for this project is next Friday.",
        twSentences: "這個專案的截止日期是下週五。",
      },
    ],
  },
  {
    engWord: "meeting",
    twWord: "會議",
    day: 4,
    sentences: [
      {
        engSentences: "We have a team meeting at 2 PM today.",
        twSentences: "我們今天下午2點有團隊會議。",
      },
    ],
  },
  {
    engWord: "presentation",
    twWord: "簡報、展示",
    day: 4,
    sentences: [
      {
        engSentences: "The presentation will begin in ten minutes.",
        twSentences: "簡報將在十分鐘後開始。",
      },
    ],
  },
  {
    engWord: "conference",
    twWord: "會議、研討會",
    day: 4,
    sentences: [
      {
        engSentences: "The annual conference will be held in Tokyo.",
        twSentences: "年度研討會將在東京舉行。",
      },
    ],
  },
]
