<template>
  <section class="control-group">
    <h3>Image (Hardware ISP)</h3>

    <div class="slider-item">
      <div class="label-row">
        <label>Brightness</label>
        <span>{{ brightness.toFixed(1) }}</span>
      </div>

      <input
        v-model.number="brightness"
        type="range"
        min="-1.0"
        max="1.0"
        step="0.1"
        class="camera-slider"
      />
    </div>

    <div class="slider-item">
      <div class="label-row">
        <label>Contrast</label>
        <span>{{ contrast.toFixed(1) }}</span>
      </div>

      <input
        v-model.number="contrast"
        type="range"
        min="0.0"
        max="10.0"
        step="0.1"
        class="camera-slider"
      />
    </div>

    <div class="slider-item">
      <div class="label-row">
        <label>Saturation</label>
        <span>{{ saturation.toFixed(1) }}</span>
      </div>

      <input
        v-model.number="saturation"
        type="range"
        min="0.0"
        max="10.0"
        step="0.1"
        class="camera-slider"
      />
    </div>

    <p v-if="errorMessage" class="error-text">
      {{ errorMessage }}
    </p>
  </section>
</template>

<script setup>

import { ref, watch } from "vue"
import { updateSettings } from "../services/cameraApi"

const brightness = ref(0.0)
const contrast = ref(1.0)
const saturation = ref(1.0)

const errorMessage = ref("")

let debounceTimer = null

function sendUpdate() {

  clearTimeout(debounceTimer)

  debounceTimer = setTimeout(async () => {

    try {

      await updateSettings({
        Brightness: brightness.value,
        Contrast: contrast.value,
        Saturation: saturation.value
      })

      errorMessage.value = ""

    } catch (error) {

      errorMessage.value =
        error instanceof Error
          ? error.message
          : "Unable to update image settings."

    }

  }, 300)

}

watch(brightness, sendUpdate)
watch(contrast, sendUpdate)
watch(saturation, sendUpdate)

</script>

<style scoped>

.control-group {
  background:#222a35;
  border-radius:12px;
  padding:16px;
}

.control-group h3{
  margin-bottom:14px;
}

.slider-item{
  display:flex;
  flex-direction:column;
  gap:8px;
  margin-bottom:16px;
}

.label-row{
  display:flex;
  justify-content:space-between;
  font-size:0.9rem;
}

.camera-slider{
  width:100%;
}

.error-text{
  color:#ff6b6b;
}

</style>