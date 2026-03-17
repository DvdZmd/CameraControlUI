<template>
  <div class="status-bar">
    <span :class="['status-indicator', isLive ? 'status-online' : 'status-offline']">
      ● {{ isLive ? 'LIVE' : 'OFFLINE' }}
    </span>

    <span class="resolution-label">
      {{ resolution }}
    </span>
  </div>
</template>

<script setup>
defineProps({
  isLive: {
    type: Boolean,
    default: true,
  },
  resolution: {
    type: String,
    default: '1280x720 @ 30fps',
  },
})
</script>

<style scoped>
.status-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  border-radius: 10px;
  background: #1a2029;
  color: #e8ecf1;
  font-size: 14px;
  gap: 12px;
}

.status-indicator {
  font-weight: 700;
}

.status-online {
  color: #00d17a;
}

.status-offline {
  color: #ff5f5f;
}

.resolution-label {
  color: #b8c0cc;
  text-align: right;
}
</style>