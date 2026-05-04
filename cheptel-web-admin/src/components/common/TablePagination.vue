<template>
  <div
      v-if="total > 0"
      class="d-flex align-items-center justify-content-between px-3 py-2 border-top"
      style="background:#fafafa;flex-wrap:wrap;gap:8px;"
  >
    <div class="text-muted" style="font-size:12px;">
      <strong>{{ from }}</strong> – <strong>{{ to }}</strong>
      sur <strong>{{ total }}</strong>
    </div>

    <div class="d-flex gap-1">
      <button
          class="btn btn-sm btn-outline-secondary"
          :disabled="currentPage === 1"
          @click="$emit('change', currentPage - 1)"
          style="padding:2px 8px;font-size:12px;"
      >
        <i class="bi bi-chevron-left"></i>
      </button>

      <button
          v-for="page in visiblePages"
          :key="page"
          class="btn btn-sm"
          :class="page === currentPage ? 'btn-success' : 'btn-outline-secondary'"
          @click="$emit('change', page)"
          style="padding:2px 8px;font-size:12px;min-width:30px;"
      >
        {{ page }}
      </button>

      <button
          class="btn btn-sm btn-outline-secondary"
          :disabled="currentPage === totalPages"
          @click="$emit('change', currentPage + 1)"
          style="padding:2px 8px;font-size:12px;"
      >
        <i class="bi bi-chevron-right"></i>
      </button>
    </div>

    <div class="d-flex align-items-center gap-1">
      <span class="text-muted" style="font-size:12px;">Lignes</span>
      <select
          class="form-select form-select-sm"
          style="width:65px;font-size:12px;"
          :value="perPage"
          @change="$emit('per-page-change', Number($event.target.value))"
      >
        <option value="10">10</option>
        <option value="20">20</option>
        <option value="50">50</option>
      </select>
    </div>
  </div>
</template>

<script setup>
defineProps({
  currentPage: { type: Number, required: true },
  totalPages: { type: Number, required: true },
  total: { type: Number, required: true },
  perPage: { type: Number, default: 10 },
  from: { type: Number, default: 0 },
  to: { type: Number, default: 0 },
  visiblePages: { type: Array, default: () => [] }
})

defineEmits(['change', 'per-page-change'])
</script>