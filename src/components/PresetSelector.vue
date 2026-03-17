<template>
  <section class="control-group">
    <h3>Configuration Presets</h3>

    <div class="field">
      <label for="camera-presets">Available presets</label>

      <select
        id="camera-presets"
        v-model="selectedPreset"
        class="control-input"
        :disabled="isSubmitting"
        @change="handlePresetChange"
      >
        <option disabled value="">Select a preset...</option>
        <option
          v-for="preset in presets"
          :key="preset.value"
          :value="preset.value"
        >
          {{ preset.label }}
        </option>
      </select>
    </div>

    <button
      type="button"
      class="btn-danger"
      :disabled="isSubmitting"
      @click="handleResetCamera"
    >
      Reset to Factory Defaults
    </button>

    <p v-if="isSubmitting" class="info-text">Applying camera configuration...</p>
    <p v-if="successMessage" class="success-text">{{ successMessage }}</p>
    <p v-if="errorMessage" class="error-text">{{ errorMessage }}</p>
  </section>
</template>

<script setup>
import { ref } from 'vue'
import { applyPreset, resetCamera } from '../services/cameraApi'

const presets = [
  { label: 'Default (Hello)', value: 'RPICAM_HELLO_DEFAULT' },
  { label: 'Lunar Photography', value: 'LUNAR_PHOTOGRAPHY' },
  { label: 'Daylight', value: 'DAYLIGHT' },
  { label: 'Indoor', value: 'INDOOR' },
  { label: 'Low Light', value: 'LOW_LIGHT' },
  { label: 'Timelapse', value: 'TIMELAPSE' },
]

const selectedPreset = ref('')
const isSubmitting = ref(false)
const successMessage = ref('')
const errorMessage = ref('')

function clearMessages() {
  successMessage.value = ''
  errorMessage.value = ''
}

async function handlePresetChange() {
  if (!selectedPreset.value || isSubmitting.value) {
    return
  }

  clearMessages()
  isSubmitting.value = true

  try {
    await applyPreset(selectedPreset.value)
    successMessage.value = `Preset "${selectedPreset.value}" applied successfully.`
  } catch (error) {
    errorMessage.value =
      error instanceof Error
        ? error.message
        : 'Unable to apply preset.'
  } finally {
    isSubmitting.value = false
  }
}

async function handleResetCamera() {
  if (isSubmitting.value) {
    return
  }

  clearMessages()
  isSubmitting.value = true

  try {
    await resetCamera()
    successMessage.value = 'Camera reset successfully.'
    selectedPreset.value = ''
  } catch (error) {
    errorMessage.value =
      error instanceof Error
        ? error.message
        : 'Unable to reset camera.'
  } finally {
    isSubmitting.value = false
  }
}
</script>