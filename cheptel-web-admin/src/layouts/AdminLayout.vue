<template>
  <div>
    <Sidebar />

    <div class="main-content">
      <Topbar :title="pageTitle" />

      <main class="content-area">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup>
import Sidebar from '../components/layout/Sidebar.vue'
import Topbar from '../components/layout/Topbar.vue'

defineProps({
  pageTitle: {
    type: String,
    default: 'Tableau de Bord'
  }
})
</script>