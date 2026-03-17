<template>
  <section class="control-group">
    <h3>Orientation</h3>

    <div class="btn-grid">
      <button
        v-for="angle in rotationOptions"
        :key="angle"
        type="button"
        class="rotation-button"
        :class="{ active: currentRotation === angle }"
        :disabled="isSubmitting"
        @click="handleRotationClick(angle)"
      >
        {{ angle }}°
      </button>
    </div>

    <p v-if="isSubmitting" class="info-text">Applying rotation...</p>
    <p v-if="successMessage" class="success-text">{{ successMessage }}</p>
    <p v-if="errorMessage" class="error-text">{{ errorMessage }}</p>
  </section>
</template>

<script setup>
import { ref } from 'vue'
import { updateSettings } from '../services/cameraApi'

const rotationOptions = [0, 90, 180, 270]

const currentRotation = ref(0)
const isSubmitting = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

async function handleRotationClick(angle) {
  if (isSubmitting.value) {
    return
  }

  errorMessage.value = ''
  successMessage.value = ''
  isSubmitting.value = true

  try {
    await updateSettings({ rotation: angle })
    currentRotation.value = angle
    successMessage.value = `Rotation set to ${angle}°.`
  } catch (error) {
    errorMessage.value =
      error instanceof Error ? error.message : 'Unable to update rotation.'
  } finally {
    isSubmitting.value = false
  }
}
</script>

<style scoped>
.control-group {
  background: #222a35;
  border-radius: 12px;
  padding: 16px;
}

.control-group h3 {
  margin: 0 0 12px;
  font-size: 1rem;
  color: #e8ecf1;
}

.btn-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
}

.rotation-button {
  border: none;
  border-radius: 10px;
  padding: 12px;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  background: #313b49;
  color: #e8ecf1;
  transition: transform 0.15s ease, opacity 0.15s ease;
}

.rotation-button:hover:not(:disabled) {
  transform: translateY(-1px);
}

.rotation-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.rotation-button.active {
  outline: 2px solid #00d17a;
}

.info-text,
.success-text,
.error-text {
  margin: 12px 0 0;
  font-size: 0.9rem;
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