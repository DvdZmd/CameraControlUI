<template>
  <section class="control-group">
    <h3>Stream Settings</h3>

    <div class="field">
      <label for="res-preset">Resolution</label>
      <select
        id="res-preset"
        v-model="selectedPreset"
        class="control-input"
        :disabled="isSubmitting"
        @change="handlePresetChange"
      >
        <option
          v-for="preset in resolutionPresets"
          :key="preset.value"
          :value="preset.value"
        >
          {{ preset.label }}
        </option>
      </select>
    </div>

    <div v-if="selectedPreset === 'custom'" class="custom-resolution">
      <div class="field">
        <label for="custom-width">Width</label>
        <input
          id="custom-width"
          v-model.number="customWidth"
          type="number"
          min="1"
          class="control-input"
          :disabled="isSubmitting"
        />
      </div>

      <div class="field">
        <label for="custom-height">Height</label>
        <input
          id="custom-height"
          v-model.number="customHeight"
          type="number"
          min="1"
          class="control-input"
          :disabled="isSubmitting"
        />
      </div>

      <button
        type="button"
        class="btn-primary"
        :disabled="isSubmitting || !isCustomResolutionValid"
        @click="applyCustomResolution"
      >
        Apply Custom Resolution
      </button>
    </div>

    <p class="current-value">
      Current stream resolution: <strong>{{ currentResolutionLabel }}</strong>
    </p>

    <p v-if="isSubmitting" class="info-text">Applying stream resolution...</p>
    <p v-if="successMessage" class="success-text">{{ successMessage }}</p>
    <p v-if="errorMessage" class="error-text">{{ errorMessage }}</p>
  </section>
</template>

<script setup>
import { computed, ref } from 'vue'
import { updateSettings } from '../services/cameraApi'

const resolutionPresets = [
  { label: '480p (VGA) - 640x480', value: '640x480' },
  { label: '720p (HD) - 1280x720', value: '1280x720' },
  { label: '1080p (Full HD) - 1920x1080', value: '1920x1080' },
  { label: '1640x1232', value: '1640x1232' },
  { label: 'Custom', value: 'custom' },
]

const selectedPreset = ref('1280x720')
const customWidth = ref(1920)
const customHeight = ref(1080)

const currentWidth = ref(1280)
const currentHeight = ref(720)

const isSubmitting = ref(false)
const successMessage = ref('')
const errorMessage = ref('')

const isCustomResolutionValid = computed(() => {
  return Number.isInteger(customWidth.value) &&
    Number.isInteger(customHeight.value) &&
    customWidth.value > 0 &&
    customHeight.value > 0
})

const currentResolutionLabel = computed(() => {
  return `${currentWidth.value}x${currentHeight.value}`
})

function clearMessages() {
  successMessage.value = ''
  errorMessage.value = ''
}

function parseResolution(value) {
  const [widthText, heightText] = value.split('x')
  const width = Number.parseInt(widthText, 10)
  const height = Number.parseInt(heightText, 10)

  if (!Number.isInteger(width) || !Number.isInteger(height)) {
    throw new Error('Invalid resolution preset.')
  }

  return { width, height }
}

async function applyResolution(width, height) {
  clearMessages()
  isSubmitting.value = true

  try {
    await updateSettings({ width, height })
    currentWidth.value = width
    currentHeight.value = height
    successMessage.value = `Stream resolution updated to ${width}x${height}.`
  } catch (error) {
    errorMessage.value =
      error instanceof Error
        ? error.message
        : 'Unable to update stream resolution.'
  } finally {
    isSubmitting.value = false
  }
}

async function handlePresetChange() {
  if (selectedPreset.value === 'custom') {
    clearMessages()
    return
  }

  const { width, height } = parseResolution(selectedPreset.value)
  await applyResolution(width, height)
}

async function applyCustomResolution() {
  if (!isCustomResolutionValid.value) {
    errorMessage.value = 'Please enter a valid custom resolution.'
    return
  }

  await applyResolution(customWidth.value, customHeight.value)
}
</script>

<style scoped>
.control-group {
  background: #222a35;
  border-radius: 12px;
  padding: 16px;
}

.control-group h3 {
  margin: 0 0 14px;
  font-size: 1rem;
  color: #e8ecf1;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 12px;
}

.field label {
  font-size: 0.9rem;
  color: #c8d0db;
}

.control-input {
  width: 100%;
  box-sizing: border-box;
  border: 1px solid #3a4658;
  border-radius: 10px;
  padding: 10px 12px;
  background: #313b49;
  color: #e8ecf1;
  font-size: 0.95rem;
}

.custom-resolution {
  margin-top: 8px;
}

.btn-primary {
  width: 100%;
  border: none;
  border-radius: 10px;
  padding: 12px;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  background: #00a86b;
  color: #ffffff;
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.current-value,
.info-text,
.success-text,
.error-text {
  margin: 12px 0 0;
  font-size: 0.9rem;
}

.current-value {
  color: #b8c0cc;
}

.info-text {
  color: #b8c0cc;
}

.success-text {
  color: #00d17a;
}

.error-text {
  color: #ff6b6b;
}
</style>