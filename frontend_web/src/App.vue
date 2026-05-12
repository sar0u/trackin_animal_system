<template>
  <router-view v-if="route.name === 'login'" />

  <div v-else class="app-layout">
    <component :is="sidebarComponent" class="global-sidebar" />

    <div class="main-wrapper">
      <component :is="topbarComponent" class="global-topbar" />
      <main class="page-container">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

// 1. IMPORTATIONS : Vérifie bien que les noms de fichiers sont corrects
import AppSidebar from '@/components/AppSidebar.vue'
import AppTopbar from '@/components/AppTopbar.vue'
import FarmSidebar from '@/components/FarmSidebar.vue' // <-- Vérifie ce nom
import FarmTopbar from '@/components/FarmTopbar.vue'   // <-- Vérifie ce nom

const route = useRoute()

const isAdminSystem = computed(() => {
  return route.meta?.requiresAdmin === true
})

const sidebarComponent = computed(() => {
  if (route.name === 'login') return null
  return isAdminSystem.value ? AppSidebar : FarmSidebar
})

const topbarComponent = computed(() => {
  if (route.name === 'login') return null
  return isAdminSystem.value ? AppTopbar : FarmTopbar
})
</script>

<style>
/* Reset global */
html, body {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  font-family: 'Inter', sans-serif;
}

.app-layout {
  display: flex;
  min-height: 100vh;
  background-color: #f8fafc; /* Fond gris très léger comme sur tes images */
}

.global-sidebar {
  width: 260px; /* Largeur de ta barre verte/noire */
  position: fixed;
  left: 0;
  top: 0;
  bottom: 0;
  z-index: 1000;
}

.main-wrapper {
  flex: 1;
  /* ESSENTIEL : margin-left doit être égal à la largeur de la sidebar */
  margin-left: 260px;
  display: flex;
  flex-direction: column;
  min-width: 0; /* Évite les bugs de tableaux qui dépassent */
}

.global-topbar {
  position: sticky;
  top: 0;
  z-index: 900;
  width: 100%;
  background: white;
}

.page-container {
  padding: 30px;
  flex: 1;
}
</style>