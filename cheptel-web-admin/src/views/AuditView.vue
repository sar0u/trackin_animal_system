<template>
  <AdminLayout page-title="Journal d'Audit">
    <div class="page-section">

      <!-- Navigation interne -->
      <div class="page-tabs">
        <button
            :class="{ active: currentPanel === 'journal' }"
            @click="currentPanel = 'journal'"
        >
          Journal
        </button>

        <button
            :class="{ active: currentPanel === 'stats' }"
            @click="currentPanel = 'stats'"
        >
          Statistiques
        </button>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-success"></div>
        <p class="text-muted mt-2">Chargement du journal...</p>
      </div>

      <div v-else class="page-panel">

        <!-- ===================================================== -->
        <!-- PANEL JOURNAL -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'journal'" class="table-card-fixed">

          <!-- Header compact -->
          <div class="page-header mb-2">
            <div class="d-flex justify-content-between align-items-center mb-2">
              <div>
                <h5 class="fw-bold mb-1">Journal des opérations</h5>
                <p class="text-muted small mb-0">
                  Actions récentes réalisées sur la plateforme.
                </p>
              </div>

              <button class="btn btn-outline-success btn-sm" @click="reload">
                <i class="bi bi-arrow-clockwise me-1"></i>
                Actualiser
              </button>
            </div>

            <!-- Filtres compacts -->
            <div class="row g-2">
              <div class="col-md-5">
                <input
                    v-model="search"
                    type="text"
                    class="form-control form-control-sm"
                    placeholder="Rechercher action, utilisateur, détails..."
                />
              </div>

              <div class="col-md-3">
                <select v-model="typeFilter" class="form-select form-select-sm">
                  <option value="">Tous les types</option>
                  <option value="CONSTAT">Constats</option>
                  <option value="MOUVEMENT">Mouvements</option>
                  <option value="VACCINATION">Vaccinations</option>
                  <option value="HEALTH_RECORD">Dossiers médicaux</option>
                  <option value="USER">Utilisateurs</option>
                </select>
              </div>

              <div class="col-md-2">
                <select v-model="periodFilter" class="form-select form-select-sm">
                  <option value="">Période</option>
                  <option value="today">Aujourd'hui</option>
                  <option value="week">7 jours</option>
                  <option value="month">30 jours</option>
                </select>
              </div>

              <div class="col-md-2">
                <button
                    class="btn btn-outline-secondary w-100 btn-sm"
                    @click="resetFilters"
                >
                  Reset
                </button>
              </div>
            </div>
          </div>

          <!-- Timeline paginée -->
          <div class="data-table table-card-fixed">
            <div class="data-table-header">
              <span class="data-table-title">
                <i class="bi bi-list-check me-2 text-success"></i>
                {{ filteredLogs.length }} action(s)
              </span>
            </div>

            <div class="audit-list">
              <div
                  v-if="paginatedLogs.length === 0"
                  class="text-center text-muted py-4"
              >
                Aucune action trouvée
              </div>

              <div
                  v-for="(log, index) in paginatedLogs"
                  :key="index"
                  class="audit-item"
              >
                <!-- Icon -->
                <div
                    class="audit-icon"
                    :class="typeIconClass(log.type)"
                >
                  <i :class="typeIcon(log.type)"></i>
                </div>

                <!-- Content -->
                <div class="audit-content">
                  <div class="d-flex justify-content-between align-items-start">
                    <div>
                      <div class="fw-semibold">
                        {{ log.action }}
                      </div>

                      <div class="text-muted small mt-1">
                        <i class="bi bi-person me-1"></i>
                        {{ log.user || 'Utilisateur inconnu' }}
                      </div>
                    </div>

                    <span
                        class="badge"
                        :class="typeBadge(log.type)"
                    >
                      {{ log.type || 'ACTION' }}
                    </span>
                  </div>

                  <div
                      v-if="log.details"
                      class="audit-details mt-2"
                  >
                    {{ log.details }}
                  </div>

                  <div class="d-flex justify-content-between align-items-center mt-2">
                    <div class="text-muted small">
                      <i class="bi bi-calendar-event me-1"></i>
                      {{ formatDateTime(log.timestamp) }}
                    </div>

                    <small class="text-muted">
                      {{ timeAgo(log.timestamp) }}
                    </small>
                  </div>
                </div>
              </div>
            </div>

            <!-- Pagination -->
            <TablePagination
                :current-page="currentPage"
                :total-pages="totalPages"
                :total="filteredLogs.length"
                :per-page="perPage"
                :from="from"
                :to="to"
                :visible-pages="visiblePages"
                @change="goToPage"
                @per-page-change="changePerPage"
            />
          </div>
        </div>

        <!-- ===================================================== -->
        <!-- PANEL STATS -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'stats'" class="page-panel-scroll">

          <div class="row g-2 mb-3">
            <div class="col-md-3">
              <StatCard
                  icon="clock-history"
                  :value="logs.length"
                  label="Actions totales"
                  color="#0B5D1E"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="file-earmark-text-fill"
                  :value="countByType('CONSTAT')"
                  label="Actions constats"
                  color="#DC2626"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="arrow-left-right"
                  :value="countByType('MOUVEMENT')"
                  label="Actions mouvements"
                  color="#2563EB"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="people-fill"
                  :value="uniqueUsersCount"
                  label="Utilisateurs impliqués"
                  color="#7C3AED"
              />
            </div>
          </div>

          <div class="data-table">
            <div class="data-table-header">
              <span class="data-table-title">
                Répartition par type d’action
              </span>
            </div>

            <div class="table-responsive">
              <table class="table mb-0">
                <thead>
                <tr>
                  <th>TYPE</th>
                  <th>NOMBRE</th>
                  <th>DESCRIPTION</th>
                </tr>
                </thead>

                <tbody>
                <tr>
                  <td>Constats</td>
                  <td>{{ countByType('CONSTAT') }}</td>
                  <td>Actions liées aux déclarations de constats.</td>
                </tr>

                <tr>
                  <td>Mouvements</td>
                  <td>{{ countByType('MOUVEMENT') }}</td>
                  <td>Actions liées aux mouvements d’animaux.</td>
                </tr>

                <tr>
                  <td>Vaccinations</td>
                  <td>{{ countByType('VACCINATION') }}</td>
                  <td>Actions liées aux campagnes ou soins vaccinaux.</td>
                </tr>

                <tr>
                  <td>Dossiers médicaux</td>
                  <td>{{ countByType('HEALTH_RECORD') }}</td>
                  <td>Actions liées aux consultations vétérinaires.</td>
                </tr>
                </tbody>
              </table>
            </div>
          </div>

        </div>

      </div>
    </div>
  </AdminLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

import AdminLayout from '@/layouts/AdminLayout.vue'
import StatCard from '@/components/common/StatCard.vue'
import TablePagination from '@/components/common/TablePagination.vue'

import { formatDateTime } from '@/utils/formatters.js'
import { usePagination } from '@/composables/usePagination.js'
import api from '@/api/axios.js'

const currentPanel = ref('journal')

const loading = ref(true)
const logs = ref([])

const search = ref('')
const typeFilter = ref('')
const periodFilter = ref('')

const filteredLogs = computed(() => {
  let result = logs.value || []

  if (search.value.trim()) {
    const q = search.value.toLowerCase()

    result = result.filter(log =>
        log.action?.toLowerCase().includes(q) ||
        log.user?.toLowerCase().includes(q) ||
        log.details?.toLowerCase().includes(q) ||
        log.type?.toLowerCase().includes(q)
    )
  }

  if (typeFilter.value) {
    result = result.filter(log => log.type === typeFilter.value)
  }

  if (periodFilter.value) {
    const now = new Date()

    result = result.filter(log => {
      if (!log.timestamp) return false

      const date = new Date(log.timestamp)
      const diffTime = now.getTime() - date.getTime()
      const diffDays = diffTime / (1000 * 60 * 60 * 24)

      if (periodFilter.value === 'today') {
        return diffDays <= 1
      }

      if (periodFilter.value === 'week') {
        return diffDays <= 7
      }

      if (periodFilter.value === 'month') {
        return diffDays <= 30
      }

      return true
    })
  }

  return result
})

const uniqueUsersCount = computed(() => {
  const set = new Set(
      logs.value
          .map(log => log.user)
          .filter(Boolean)
  )

  return set.size
})

const {
  currentPage,
  perPage,
  totalPages,
  paginatedItems: paginatedLogs,
  from,
  to,
  visiblePages,
  goToPage,
  changePerPage
} = usePagination(filteredLogs)

onMounted(() => {
  loadLogs()
})

async function loadLogs() {
  loading.value = true

  try {
    const res = await api.get('/admin/audit')
    logs.value = res.data || []
  } catch (e) {
    console.error('Erreur audit :', e)
  } finally {
    loading.value = false
  }
}

function reload() {
  loadLogs()
}

function resetFilters() {
  search.value = ''
  typeFilter.value = ''
  periodFilter.value = ''
}

function countByType(type) {
  return logs.value.filter(log => log.type === type).length
}

function typeBadge(type) {
  return {
    CONSTAT: 'bg-danger',
    MOUVEMENT: 'bg-primary',
    VACCINATION: 'bg-success',
    HEALTH_RECORD: 'bg-warning text-dark',
    USER: 'bg-info text-dark'
  }[type] || 'bg-secondary'
}

function typeIcon(type) {
  return {
    CONSTAT: 'bi bi-file-earmark-text-fill',
    MOUVEMENT: 'bi bi-arrow-left-right',
    VACCINATION: 'bi bi-shield-fill-check',
    HEALTH_RECORD: 'bi bi-file-medical-fill',
    USER: 'bi bi-person-fill'
  }[type] || 'bi bi-info-circle'
}

function typeIconClass(type) {
  return {
    CONSTAT: 'audit-danger',
    MOUVEMENT: 'audit-primary',
    VACCINATION: 'audit-success',
    HEALTH_RECORD: 'audit-warning',
    USER: 'audit-info'
  }[type] || 'audit-secondary'
}

function timeAgo(dateStr) {
  if (!dateStr) return ''

  const date = new Date(dateStr)
  const now = new Date()
  const diffMs = now - date

  const minutes = Math.floor(diffMs / (1000 * 60))
  const hours = Math.floor(diffMs / (1000 * 60 * 60))
  const days = Math.floor(diffMs / (1000 * 60 * 60 * 24))

  if (minutes < 1) return 'À l’instant'
  if (minutes < 60) return `Il y a ${minutes} min`
  if (hours < 24) return `Il y a ${hours} h`

  return `Il y a ${days} j`
}
</script>

<style scoped>
.audit-list {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  padding: 10px 16px;
}

.audit-item {
  display: flex;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px solid #e5e7eb;
}

.audit-item:last-child {
  border-bottom: none;
}

.audit-icon {
  width: 38px;
  height: 38px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.audit-icon i {
  font-size: 18px;
}

.audit-content {
  flex: 1;
}

.audit-details {
  padding: 8px 10px;
  background: #f9fafb;
  border-radius: 9px;
  color: #6b7280;
  font-size: 12px;
}

.audit-danger {
  background: #fee2e2;
  color: #dc2626;
}

.audit-primary {
  background: #dbeafe;
  color: #2563eb;
}

.audit-success {
  background: #dcfce7;
  color: #059669;
}

.audit-warning {
  background: #fef3c7;
  color: #d97706;
}

.audit-info {
  background: #e0f2fe;
  color: #0284c7;
}

.audit-secondary {
  background: #f3f4f6;
  color: #6b7280;
}
</style>