<template>
  <section class="video-stream">
    <div class="video-wrapper">
      <img
        :src="streamUrl"
        alt="Camera Stream"
        class="video-feed"
        @load="handleLoad"
        @error="handleError"
      />

      <div v-if="isLoading" class="video-overlay">
        <span>Connecting to camera stream...</span>
      </div>

      <div v-if="hasError" class="video-overlay video-overlay--error">
        <span>Unable to load camera stream.</span>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, ref } from 'vue'

const props = defineProps({
  baseUrl: {
    type: String,
    default: '/api/camera',
  },
  streamPath: {
    type: String,
    default: '/video_feed',
  },
})

const isLoading = ref(true)
const hasError = ref(false)

const streamUrl = computed(() => {
  if (!props.baseUrl) {
    return props.streamPath
  }

  return `${props.baseUrl}${props.streamPath}`
})

function handleLoad() {
  isLoading.value = false
  hasError.value = false
}

function handleError() {
  isLoading.value = false
  hasError.value = true
}
</script>

<style scoped>
.video-stream {
  width: 100%;
}

.video-wrapper {
  position: relative;
  width: 100%;
  min-height: 320px;
  overflow: hidden;
  border-radius: 12px;
  background: #0f1115;
  display: flex;
  align-items: center;
  justify-content: center;
}

.video-feed {
  display: block;
  width: 100%;
  height: auto;
}

.video-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(15, 17, 21, 0.55);
  color: #f5f7fa;
  font-weight: 600;
  text-align: center;
  padding: 1rem;
}

.video-overlay--error {
  background: rgba(80, 20, 20, 0.7);
}
</style>