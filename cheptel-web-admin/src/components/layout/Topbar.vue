<template>
  <div class="topbar">

    <div class="d-flex align-items-center gap-3 flex-grow-1 me-3">
      <span class="topbar-title">{{ title }}</span>

      <div style="width:400px;max-width:50vw;position:relative;">
        <div class="input-group input-group-sm">
          <span class="input-group-text bg-white">
            <i class="bi bi-search text-muted" style="font-size:12px;"></i>
          </span>
          <input
              v-model="searchQuery"
              type="text"
              class="form-control border-start-0"
              placeholder="Rechercher animal, ferme, utilisateur..."
              style="font-size:13px;"
              @input="onSearchInput"
              @focus="showResults = true"
          />
        </div>

        <div
            v-if="showResults && hasResults"
            class="position-absolute bg-white border rounded shadow"
            style="top:36px;left:0;right:0;z-index:3000;max-height:360px;overflow-y:auto;"
        >
          <div v-for="group in resultGroups" :key="group.label">
            <div v-if="group.items.length > 0">
              <div
                  class="px-3 py-1 text-muted fw-bold"
                  style="font-size:10px;letter-spacing:1px;background:#f9fafb;border-bottom:1px solid #eee;"
              >
                {{ group.label }}
              </div>

              <RouterLink
                  v-for="item in group.items"
                  :key="item.type + item.id"
                  :to="item.route"
                  class="d-flex align-items-center gap-2 px-3 py-2 text-decoration-none"
                  style="color:#1f2a24;"
                  @click="closeSearch"
              >
                <div
                    class="rounded-2 d-flex align-items-center justify-content-center"
                    :style="iconStyle(item.type)"
                    style="width:28px;height:28px;font-size:13px;flex-shrink:0;"
                >
                  <i :class="iconFor(item.type)"></i>
                </div>

                <div>
                  <div class="fw-semibold" style="font-size:13px;">{{ item.title }}</div>
                  <div class="text-muted" style="font-size:11px;">{{ item.subtitle }}</div>
                </div>
              </RouterLink>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="topbar-user">
      <span class="text-muted d-none d-md-block" style="font-size:13px;">
        {{ username }}
      </span>

      <div class="user-avatar">{{ initials }}</div>

      <button
          class="btn btn-sm btn-outline-secondary"
          style="font-size:12px;padding:4px 8px;"
          @click="logout"
      >
        <i class="bi bi-box-arrow-right"></i>
      </button>
    </div>

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/authStore.js'
import api from '../../api/axios.js'

defineProps({
  title: {
    type: String,
    default: 'Tableau de Bord'
  }
})

const router = useRouter()
const auth = useAuthStore()

const username = computed(() => auth.username || '')
const initials = computed(() => {
  if (!auth.username) return 'AD'
  return auth.username.substring(0, 2).toUpperCase()
})

const searchQuery = ref('')
const showResults = ref(false)
const results = ref({ users: [], farms: [], animals: [], constats: [] })
let timer = null

const resultGroups = computed(() => [
  { label: 'ANIMAUX', items: results.value.animals || [] },
  { label: 'FERMES', items: results.value.farms || [] },
  { label: 'UTILISATEURS', items: results.value.users || [] },
  { label: 'CONSTATS', items: results.value.constats || [] }
])

const hasResults = computed(() =>
    resultGroups.value.some(g => g.items.length > 0)
)

function onSearchInput() {
  clearTimeout(timer)
  if (searchQuery.value.trim().length < 2) {
    results.value = { users: [], farms: [], animals: [], constats: [] }
    return
  }
  timer = setTimeout(async () => {
    try {
      const res = await api.get('/admin/search', { params: { q: searchQuery.value.trim() } })
      results.value = res.data || {}
      showResults.value = true
    } catch (e) {
      console.error(e)
    }
  }, 300)
}

function closeSearch() {
  showResults.value = false
  searchQuery.value = ''
}

function iconFor(type) {
  return {
    ANIMAL: 'bi bi-tags-fill',
    FARM: 'bi bi-house-fill',
    USER: 'bi bi-person-fill',
    CONSTAT: 'bi bi-file-earmark-text-fill'
  }[type] || 'bi bi-search'
}

function iconStyle(type) {
  const map = {
    ANIMAL: 'background:#dcfce7;color:#059669;',
    FARM: 'background:#dbeafe;color:#2563eb;',
    USER: 'background:#fef3c7;color:#d97706;',
    CONSTAT: 'background:#fee2e2;color:#dc2626;'
  }
  return map[type] || 'background:#f3f4f6;color:#6b7280;'
}

function logout() {
  auth.logout()
  router.push('/login')
}
</script>