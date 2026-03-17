<template>
  <main class="camera-dashboard">
    <section class="stream-panel">
      <StatusBar
        :is-live="true"
        resolution="1280x720 @ 30fps"
      />
      <VideoStream />
    </section>
    <aside class="sidebar-section">
      <CameraHeadControls />
    </aside>
    <aside class="controls-panel">
      <h1 class="dashboard-title">Camera IoT Pro</h1>
        <StreamSettings />
        <PresetSelector />
        <RotationControl />
        <ImageControls />
      <div class="placeholder-card">
        <h2>Controls panel</h2>
        <p>
          Control components will be migrated here incrementally from the legacy HTML frontend.
        </p>
      </div>
    </aside>
  </main>
</template>

<script setup>
import StatusBar from '../components/StatusBar.vue'
import VideoStream from '../components/VideoStream.vue'
import StreamSettings from '../components/StreamSettings.vue'
import RotationControl from '../components/RotationControl.vue'
import PresetSelector from '../components/PresetSelector.vue'
import ImageControls from '../components/ImageControls.vue'
import CameraHeadControls from '@/components/camera/CameraHeadControls.vue'
</script>

<style scoped>
.camera-dashboard {
  display: grid;
  grid-template-columns: minmax(0, 2fr) minmax(320px, 420px);
  gap: 24px;
  padding: 24px;
  min-height: 100vh;
  box-sizing: border-box;
  background: #11151b;
}

.stream-panel {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-width: 0;
}

.controls-panel {
  background: #1a2029;
  border-radius: 16px;
  padding: 20px;
  color: #e8ecf1;
  box-sizing: border-box;
}

.dashboard-title {
  margin: 0 0 20px;
  font-size: 1.75rem;
  line-height: 1.2;
}

.placeholder-card {
  background: #222a35;
  border-radius: 12px;
  padding: 16px;
}

.placeholder-card h2 {
  margin: 0 0 8px;
  font-size: 1.1rem;
}

.placeholder-card p {
  margin: 0;
  color: #b8c0cc;
  line-height: 1.5;
}

@media (max-width: 960px) {
  .camera-dashboard {
    grid-template-columns: 1fr;
  }

  .controls-panel {
    order: 2;
  }
}
</style>