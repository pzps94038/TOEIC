<template>
  <div class="min-h-screen">
    <UContainer>
      <div class="py-8">
        <!-- 搜尋區域 -->
        <UCard class="mb-8">
          <div class="flex flex-col sm:flex-row gap-4">
            <div class="flex-1">
              <UInput
                class="w-full"
                v-model="searchKeyword"
                placeholder="輸入英文單字、中文意思或例句..."
                icon="i-heroicons-magnifying-glass"
                size="lg"
              />
            </div>
            <div class="flex items-end">
              <UButton
                @click="clearSearch"
                variant="solid"
                size="lg"
                class="cursor-pointer"
              >
                清除
              </UButton>
            </div>
          </div>
        </UCard>

        <!-- 語音設定區域 -->
        <UCard class="mb-8">
          <div class="flex flex-row items-center w-full flex-wrap">
            <div class="w-30 flex items-center">
              <UIcon name="i-heroicons-speaker-wave" class="w-5 h-5 mx-2" />
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300"
                >語音速率:</span
              >
            </div>
            <div class="w-full py-3">
              <USlider
                v-model="speechRate"
                :min="0.5"
                :max="2.0"
                :step="0.1"
                class="cursor-pointer"
              />
            </div>
            <div class="flex items-center col-12 ml-auto">
              <span class="text-sm text-gray-600 dark:text-gray-400"
                >{{ speechRate }}x</span
              >
              <UButton
                @click="resetSpeechRate"
                color="gray"
                variant="ghost"
                size="sm"
                class="cursor-pointer"
                icon="i-heroicons-arrow-path"
                title="重置為預設值"
              />
            </div>
          </div>
        </UCard>

        <!-- 載入狀態 -->
        <div v-if="pending" class="text-center py-12">
          <UIcon
            name="i-heroicons-arrow-path"
            class="w-8 h-8 animate-spin text-primary"
          />
          <p class="mt-4 text-gray-700 dark:text-gray-300">載入中...</p>
        </div>

        <!-- 錯誤狀態 -->
        <div v-else-if="error" class="text-center py-12">
          <UAlert
            color="red"
            variant="soft"
            title="載入失敗"
            :description="`錯誤訊息: ${error}`"
            class="mb-4"
          />
          <UButton @click="refresh()" color="primary" variant="solid">
            重試
          </UButton>
        </div>

        <!-- 單字列表 -->
        <div v-else-if="paginatedWords.length > 0" class="space-y-6">
          <UCard
            v-for="word in paginatedWords"
            :key="word.engWord"
            class="hover:shadow-lg transition-shadow"
          >
            <!-- 單字標題 -->
            <div
              class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-4"
            >
              <div class="space-y-2">
                <div class="flex items-center gap-3">
                  <h3 class="text-2xl font-bold text-gray-800 dark:text-white">
                    {{ word.engWord }}
                  </h3>
                  <UButton
                    @click="speakText(word.engWord, 'en')"
                    color="blue"
                    variant="ghost"
                    icon="i-heroicons-speaker-wave"
                    size="sm"
                    :ui="{ rounded: 'rounded-full' }"
                    title="英文發音"
                    class="cursor-pointer"
                  />
                </div>
                <div class="flex items-center gap-3">
                  <span class="text-lg text-gray-700 dark:text-gray-300">{{
                    word.twWord
                  }}</span>
                  <UButton
                    @click="speakText(word.twWord, 'zh-TW')"
                    color="green"
                    variant="ghost"
                    icon="i-heroicons-speaker-wave"
                    size="sm"
                    :ui="{ rounded: 'rounded-full' }"
                    title="中文發音"
                    class="cursor-pointer"
                  />
                </div>
              </div>
            </div>

            <!-- 例句 -->
            <div
              v-if="word.sentences && word.sentences.length > 0"
              class="space-y-4"
            >
              <UDivider label="例句" />
              <div
                v-for="(sentence, index) in word.sentences"
                :key="index"
                class="space-y-3"
              >
                <UCard color="gray" variant="soft">
                  <div class="space-y-3">
                    <div class="flex items-start gap-3">
                      <div class="flex-1">
                        <p
                          class="text-gray-800 dark:text-gray-200 leading-relaxed"
                        >
                          {{ sentence.engSentences }}
                        </p>
                      </div>
                      <UButton
                        @click="speakText(sentence.engSentences, 'en')"
                        color="blue"
                        variant="ghost"
                        icon="i-heroicons-speaker-wave"
                        size="xs"
                        title="英文例句發音"
                        class="cursor-pointer"
                      />
                    </div>
                    <div class="flex items-start gap-3">
                      <div class="flex-1">
                        <p
                          class="text-gray-700 dark:text-gray-300 leading-relaxed"
                        >
                          {{ sentence.twSentences }}
                        </p>
                      </div>
                      <UButton
                        @click="speakText(sentence.twSentences, 'zh-TW')"
                        color="green"
                        variant="ghost"
                        icon="i-heroicons-speaker-wave"
                        size="xs"
                        title="中文例句發音"
                        class="cursor-pointer"
                      />
                    </div>
                  </div>
                </UCard>
              </div>
            </div>
          </UCard>

          <!-- 分頁元件 -->
          <SharedPagination
            v-if="Math.ceil(filteredWords.length / pageSize) > 1"
            :total="filteredWords.length"
            :current-page="currentPage"
            :page-size="pageSize"
            :max-visible-pages="5"
            @change="handlePageChange"
          />
        </div>

        <!-- 無資料狀態 -->
        <div v-else class="text-center py-12">
          <UIcon
            name="i-heroicons-light-bulb"
            class="mx-auto h-12 w-12 text-gray-400 mb-4"
          />
          <h3 class="text-lg font-medium text-gray-800 dark:text-white mb-2">
            {{ searchKeyword ? "找不到相關單字" : "沒有單字資料" }}
          </h3>
          <p class="text-gray-600 dark:text-gray-400">
            {{ searchKeyword ? "請嘗試其他關鍵字" : "請稍後再試" }}
          </p>
        </div>
      </div>
    </UContainer>
  </div>
</template>

<script setup lang="ts">
// 定義介面
interface Sentence {
  twSentences: string;
  engSentences: string;
}

interface Word {
  engWord: string;
  twWord: string;
  sentences: Sentence[];
}

interface WordResponse {
  code: number;
  message: string;
  data: Word[];
}

// 響應式數據
const searchKeyword = ref("");
const currentPage = ref(1);
const pageSize = ref(10);
const speechRate = ref(0.8); // 語音速率，預設為 0.8

// 獲取單字資料
const {
  data: wordsResponse,
  pending,
  error,
  refresh,
} = await useFetch<WordResponse>("/api/word/get-words");

// 計算所有單字
const allWords = computed(() => {
  return wordsResponse.value?.data || [];
});

// 篩選後的單字
const filteredWords = computed(() => {
  if (!searchKeyword.value.trim()) {
    return allWords.value;
  }

  const keyword = searchKeyword.value.toLowerCase().trim();

  return allWords.value.filter((word) => {
    // 搜尋英文單字
    if (word.engWord.toLowerCase().includes(keyword)) {
      return true;
    }

    // 搜尋中文單字
    if (word.twWord.includes(keyword)) {
      return true;
    }

    // 搜尋例句
    if (word.sentences && word.sentences.length > 0) {
      return word.sentences.some(
        (sentence) =>
          sentence.engSentences.toLowerCase().includes(keyword) ||
          sentence.twSentences.includes(keyword)
      );
    }

    return false;
  });
});

// 分頁後的單字
const paginatedWords = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return filteredWords.value.slice(start, end);
});

// 清除搜尋
const clearSearch = () => {
  searchKeyword.value = "";
  currentPage.value = 1;
};

// 重置語音速率
const resetSpeechRate = () => {
  speechRate.value = 0.8;
};

// 分頁變更處理
const handlePageChange = (page: number) => {
  currentPage.value = page;
  // 滾動到頂部
  window.scrollTo({ top: 0, behavior: "smooth" });
};

// 語音合成功能
const speakText = (text: string, lang: string) => {
  if ("speechSynthesis" in window) {
    // 停止當前播放
    window.speechSynthesis.cancel();

    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = lang;
    utterance.rate = speechRate.value; // 使用動態語音速率
    utterance.volume = 0.8;

    // 根據語言設置不同的音調
    if (lang === "en") {
      utterance.pitch = 1.0;
    } else {
      utterance.pitch = 1.1;
    }

    window.speechSynthesis.speak(utterance);
  } else {
    console.warn("瀏覽器不支援語音合成功能");
  }
};

// 設置頁面標題
useHead({
  title: "TOEIC Vocabulary Trainer - 多益單字練習",
  meta: [
    {
      name: "description",
      content: "提升你的TOEIC單字能力，包含發音練習和例句學習",
    },
  ],
});
</script>
