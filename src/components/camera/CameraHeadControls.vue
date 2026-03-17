<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import {
  centerEsp32,
  connectEsp32,
  disconnectEsp32,
  getEsp32Status,
  moveEsp32,
  setEsp32Speed,
  stopEsp32,
  type MoveDirection,
} from '../../services/esp32Api'

const HOLD_DELAY_MS = 250

const isConnected = ref(false)
const isBusy = ref(false)
const isMoving = ref(false)
const activeDirection = ref<MoveDirection | null>(null)
const errorMessage = ref('')
const speedMode = ref(1)

const pressedDirection = ref<MoveDirection | null>(null)
const holdTimerId = ref<number | null>(null)
const holdStarted = ref(false)
const activePointerId = ref<number | null>(null)

const connectionLabel = computed(() =>
  isConnected.value ? 'Connected' : 'Disconnected'
)

function clearHoldTimer() {
  if (holdTimerId.value !== null) {
    window.clearTimeout(holdTimerId.value)
    holdTimerId.value = null
  }
}

function resetPressState() {
  clearHoldTimer()
  pressedDirection.value = null
  holdStarted.value = false
  activePointerId.value = null
}

async function refreshStatus() {
  try {
    errorMessage.value = ''
    const status = await getEsp32Status()
    isConnected.value = Boolean(status.connected)
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Failed to fetch ESP32 status'
  }
}

async function handleConnect() {
  try {
    isBusy.value = true
    errorMessage.value = ''
    await connectEsp32()
    await refreshStatus()
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Failed to connect'
  } finally {
    isBusy.value = false
  }
}

async function handleDisconnect() {
  try {
    isBusy.value = true
    errorMessage.value = ''
    await stopMovement(true)
    await disconnectEsp32()
    await refreshStatus()
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Failed to disconnect'
  } finally {
    isBusy.value = false
  }
}

async function executeSingleStep(direction: MoveDirection) {
  if (!isConnected.value || isBusy.value) return

  try {
    errorMessage.value = ''
    await moveEsp32(direction)
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Failed to move camera head'
  }
}

async function startMovement(direction: MoveDirection) {
  if (!isConnected.value || isBusy.value) return
  if (isMoving.value && activeDirection.value === direction) return

  try {
    errorMessage.value = ''
    activeDirection.value = direction
    isMoving.value = true
    await moveEsp32(direction)
  } catch (error) {
    isMoving.value = false
    activeDirection.value = null
    errorMessage.value = error instanceof Error ? error.message : 'Failed to start continuous movement'
  }
}

async function stopMovement(force = false) {
  if (!isConnected.value) return
  if (!force && !isMoving.value && !activeDirection.value) return

  try {
    await stopEsp32()
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Failed to stop camera head'
  } finally {
    isMoving.value = false
    activeDirection.value = null
  }
}

async function handleCenter() {
  if (!isConnected.value || isBusy.value) return

  try {
    isBusy.value = true
    errorMessage.value = ''
    await centerEsp32()
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Failed to center camera head'
  } finally {
    isBusy.value = false
  }
}

async function handleSpeedChange() {
  if (!isConnected.value || isBusy.value) return

  try {
    isBusy.value = true
    errorMessage.value = ''
    await setEsp32Speed(speedMode.value)
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Failed to set speed'
  } finally {
    isBusy.value = false
  }
}

function handlePointerDown(direction: MoveDirection, event: PointerEvent) {
  if (!isConnected.value || isBusy.value) return

  event.preventDefault()

  activePointerId.value = event.pointerId
  pressedDirection.value = direction
  holdStarted.value = false

  ;(event.currentTarget as HTMLElement | null)?.setPointerCapture?.(event.pointerId)

  clearHoldTimer()
  holdTimerId.value = window.setTimeout(() => {
    if (pressedDirection.value !== direction) return

    holdStarted.value = true
    void startMovement(direction)
  }, HOLD_DELAY_MS)
}

function isSamePointer(event: PointerEvent) {
  return activePointerId.value === null || activePointerId.value === event.pointerId
}

async function handlePointerUp(event: PointerEvent) {
  if (!isSamePointer(event)) return

  event.preventDefault()

  const direction = pressedDirection.value
  const shouldSingleStep = !holdStarted.value && direction !== null

  ;(event.currentTarget as HTMLElement | null)?.releasePointerCapture?.(event.pointerId)

  resetPressState()

  if (shouldSingleStep && direction) {
    await executeSingleStep(direction)
    return
  }

  if (isMoving.value) {
    await stopMovement()
  }
}

async function handlePointerCancel(event?: PointerEvent) {
  if (event && !isSamePointer(event)) return

  resetPressState()

  if (isMoving.value) {
    await stopMovement(true)
  }
}

function bindDirectionalControl(direction: MoveDirection) {
  return {
    pointerdown: (event: PointerEvent) => handlePointerDown(direction, event),
    pointerup: (event: PointerEvent) => void handlePointerUp(event),
    pointercancel: (event: PointerEvent) => void handlePointerCancel(event),
    pointerleave: (event: PointerEvent) => {
      if (holdStarted.value) {
        void handlePointerCancel(event)
      }
    },
    contextmenu: (event: MouseEvent) => event.preventDefault(),
  }
}

function handleWindowPointerUp() {
  resetPressState()

  if (isMoving.value) {
    void stopMovement(true)
  }
}

function handleVisibilityChange() {
  if (document.hidden) {
    resetPressState()

    if (isMoving.value) {
      void stopMovement(true)
    }
  }
}

onMounted(() => {
  void refreshStatus()

  window.addEventListener('pointerup', handleWindowPointerUp)
  window.addEventListener('blur', handleWindowPointerUp)
  window.addEventListener('pagehide', handleWindowPointerUp)
  document.addEventListener('visibilitychange', handleVisibilityChange)
})

onBeforeUnmount(() => {
  window.removeEventListener('pointerup', handleWindowPointerUp)
  window.removeEventListener('blur', handleWindowPointerUp)
  window.removeEventListener('pagehide', handleWindowPointerUp)
  document.removeEventListener('visibilitychange', handleVisibilityChange)

  resetPressState()
  void stopMovement(true)
})
</script>

<template>
  <section class="camera-head-controls">
    <header class="panel-header">
      <div>
        <h3>Camera Head Controls</h3>
        <p class="status-line">
          Status:
          <span :class="['status-badge', isConnected ? 'connected' : 'disconnected']">
            {{ connectionLabel }}
          </span>
        </p>
      </div>

      <div class="connection-actions">
        <button
          type="button"
          class="secondary-btn"
          :disabled="isBusy || isConnected"
          @click="handleConnect"
        >
          Connect
        </button>

        <button
          type="button"
          class="secondary-btn"
          :disabled="isBusy || !isConnected"
          @click="handleDisconnect"
        >
          Disconnect
        </button>
      </div>
    </header>

    <p v-if="errorMessage" class="error-text">
      {{ errorMessage }}
    </p>

    <div class="speed-row">
      <label for="speedMode">Speed</label>
      <select
        id="speedMode"
        v-model.number="speedMode"
        :disabled="!isConnected || isBusy"
        @change="handleSpeedChange"
      >
        <option :value="0">0</option>
        <option :value="1">1</option>
        <option :value="2">2</option>
        <option :value="3">3</option>
      </select>
    </div>

    <div class="dpad">
      <button
        type="button"
        class="control-btn up"
        :disabled="!isConnected || isBusy"
        v-on="bindDirectionalControl('up')"
      >
        Up
      </button>

      <button
        type="button"
        class="control-btn left"
        :disabled="!isConnected || isBusy"
        v-on="bindDirectionalControl('left')"
      >
        Left
      </button>

      <button
        type="button"
        class="control-btn center"
        :disabled="!isConnected || isBusy"
        @click="handleCenter"
      >
        Center
      </button>

      <button
        type="button"
        class="control-btn right"
        :disabled="!isConnected || isBusy"
        v-on="bindDirectionalControl('right')"
      >
        Right
      </button>

      <button
        type="button"
        class="control-btn down"
        :disabled="!isConnected || isBusy"
        v-on="bindDirectionalControl('down')"
      >
        Down
      </button>
    </div>
  </section>
</template>

<style scoped>
.camera-head-controls {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1rem;
  border: 1px solid #dcdcdc;
  border-radius: 12px;
  background: #ffffff;
}

.panel-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1rem;
}

.panel-header h3 {
  margin: 0;
  font-size: 1.1rem;
}

.status-line {
  margin: 0.25rem 0 0;
}

.status-badge {
  display: inline-block;
  padding: 0.2rem 0.55rem;
  border-radius: 999px;
  font-size: 0.85rem;
  font-weight: 600;
}

.status-badge.connected {
  background: #e9f8ee;
  color: #18794e;
}

.status-badge.disconnected {
  background: #fdecec;
  color: #b42318;
}

.connection-actions {
  display: flex;
  gap: 0.5rem;
}

.secondary-btn,
.control-btn {
  border: 1px solid #cfcfcf;
  background: #f7f7f7;
  color: #222;
  border-radius: 10px;
  padding: 0.7rem 1rem;
  cursor: pointer;
  font-weight: 600;
}

.secondary-btn:disabled,
.control-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.error-text {
  margin: 0;
  color: #b42318;
  font-size: 0.95rem;
}

.speed-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.speed-row select {
  min-width: 80px;
  padding: 0.45rem 0.6rem;
  border-radius: 8px;
  border: 1px solid #cfcfcf;
}

.dpad {
  display: grid;
  grid-template-columns: 90px 90px 90px;
  grid-template-rows: 56px 56px 56px;
  gap: 0.75rem;
  justify-content: center;
  align-items: center;
}

.up {
  grid-column: 2;
  grid-row: 1;
}

.left {
  grid-column: 1;
  grid-row: 2;
}

.center {
  grid-column: 2;
  grid-row: 2;
}

.right {
  grid-column: 3;
  grid-row: 2;
}

.down {
  grid-column: 2;
  grid-row: 3;
}
</style>