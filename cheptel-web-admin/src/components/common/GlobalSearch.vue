<template>
  <div class="global-search position-relative">
    <div class="input-group">
      <span class="input-group-text">
        <i class="bi bi-search"></i>
      </span>

      <input
          v-model="query"
          type="text"
          class="form-control"
          placeholder="Recherche globale : animal, ferme, utilisateur, constat..."
          @input="onInput"
          @focus="showResults = true"
      />
    </div>

    <div
        v-if="showResults && query.length >= 2"
        class="search-dropdown"
    >
      <div v-if="loading" class="p-3 text-center text-muted">
        Recherche...
      </div>

      <div v-else-if="!hasResults" class="p-3 text-center text-muted">
        Aucun résultat trouvé
      </div>

      <div v-else>
        <div v-for="group in groupedResults" :key="group.label">
          <div v-if="group.items.length > 0">
            <div class="search-section">
              {{ group.label }}
            </div>

            <RouterLink
                v-for="item in group.items"
                :key="item.type + item.id"
                :to="item.route"
                class="search-item"
                @click="close"
            >
              <div class="search-icon" :class="iconClass(item.type)">
                <i :class="iconFor(item.type)"></i>
              </div>

              <div>
                <div class="fw-semibold">{{ item.title }}</div>
                <small class="text-muted">{{ item.subtitle }}</small>
              </div>
            </RouterLink>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { RouterLink } from 'vue-router'
import { searchApi } from '@/api/searchApi.js'

const query = ref('')
const loading = ref(false)
const showResults = ref(false)

const results = ref({
  users: [],
  farms: [],
  animals: [],
  constats: []
})

let timer = null

const groupedResults = computed(() => [
  { label: 'Animaux', items: results.value.animals || [] },
  { label: 'Fermes', items: results.value.farms || [] },
  { label: 'Utilisateurs', items: results.value.users || [] },
  { label: 'Constats', items: results.value.constats || [] }
])

const hasResults = computed(() => {
  return groupedResults.value.some(group => group.items.length > 0)
})

function onInput() {
  clearTimeout(timer)

  if (query.value.trim().length < 2) {
    results.value = {
      users: [],
      farms: [],
      animals: [],
      constats: []
    }
    return
  }

  timer = setTimeout(async () => {
    loading.value = true

    try {
      const res = await searchApi.global(query.value.trim())
      results.value = res.data
      showResults.value = true
    } catch (e) {
      console.error('Erreur recherche globale :', e)
    } finally {
      loading.value = false
    }
  }, 300)
}

function close() {
  showResults.value = false
  query.value = ''
}

function iconFor(type) {
  return {
    ANIMAL: 'bi bi-tags-fill',
    FARM: 'bi bi-house-fill',
    USER: 'bi bi-person-fill',
    CONSTAT: 'bi bi-file-earmark-text-fill'
  }[type] || 'bi bi-search'
}

function iconClass(type) {
  return {
    ANIMAL: 'bg-success-subtle text-success',
    FARM: 'bg-primary-subtle text-primary',
    USER: 'bg-warning-subtle text-warning',
    CONSTAT: 'bg-danger-subtle text-danger'
  }[type] || 'bg-secondary'
}
</script>

<style scoped>
.global-search {
  width: 100%;
}

.search-dropdown {
  position: absolute;
  top: 48px;
  left: 0;
  right: 0;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  box-shadow: 0 12px 28px rgba(0,0,0,0.12);
  z-index: 3000;
  max-height: 420px;
  overflow-y: auto;
}

.search-section {
  padding: 10px 14px 4px;
  font-size: 11px;
  font-weight: 700;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.search-item {
  display: flex;
  gap: 12px;
  padding: 12px 14px;
  color: #1f2a24;
  text-decoration: none;
}

.search-item:hover {
  background: #f7faf5;
}

.search-icon {
  width: 38px;
  height: 38px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>