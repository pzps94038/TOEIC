<template>
  <div class="flex justify-center items-center mt-8" v-if="totalPages > 1">
    <UPagination
      v-model="props.currentPage!"
      :page-count="pageSize"
      :total="total"
      :max="maxVisiblePages"
      show-last
      show-first
      @update:page="change"
    />
  </div>
</template>

<script setup lang="ts">
interface Props {
  total: number;
  currentPage: number;
  pageSize?: number;
  maxVisiblePages?: number;
}

interface Emits {
  (e: "change", page: number): void;
}

const props = withDefaults(defineProps<Props>(), {
  pageSize: 10,
  maxVisiblePages: 5,
});

const emit = defineEmits<Emits>();

const totalPages = computed(() => {
  return Math.ceil(props.total / props.pageSize);
});

const change = (page: number) => {
  emit("change", page);
};

const currentPageModel = computed({
  get: () => props.currentPage,
  set: (value: number) => {
    console.log(value);
    emit("change", value);
  },
});
</script>
