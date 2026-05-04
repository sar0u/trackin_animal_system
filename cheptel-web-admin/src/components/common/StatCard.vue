<template>
  <div class="stat-card">
    <div
        class="stat-icon"
        :style="{ backgroundColor: `${color}20`, color }"
    >
      <i :class="`bi bi-${icon}`"></i>
    </div>

    <div class="stat-value">{{ value }}</div>

    <div class="stat-label">{{ label }}</div>
  </div>
</template>

<script setup>
defineProps({
  icon: { type: String, required: true },
  value: { type: [String, Number], required: true },
  label: { type: String, required: true },
  color: { type: String, default: '#0B5D1E' }
})
</script>