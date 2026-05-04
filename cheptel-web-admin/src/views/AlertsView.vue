<template>
  <AdminLayout page-title="Alertes Sanitaires">
    <div class="page-section">

      <!-- Navigation interne -->
      <div class="page-tabs">
        <button
            :class="{ active: currentPanel === 'list' }"
            @click="currentPanel = 'list'"
        >
          Liste des alertes
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
        <p class="text-muted mt-2">Chargement des alertes...</p>
      </div>

      <div v-else class="page-panel">

        <!-- ===================================================== -->
        <!-- PANEL LISTE -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'list'" class="table-card-fixed">

          <!-- Header + filtres -->
          <div class="page-header mb-2">
            <div class="d-flex justify-content-between align-items-center mb-2">
              <div>
                <h5 class="fw-bold mb-1">Alertes Sanitaires</h5>
                <p class="text-muted small mb-0">
                  Alertes de vaccination et de contrôle.
                </p>
              </div>

              <button
                  class="btn btn-outline-success btn-sm"
                  @click="generateAndLoad"
              >
                <i class="bi bi-arrow-clockwise me-1"></i>
                Générer & Actualiser
              </button>
            </div>

            <!-- Filtres compacts -->
            <div class="row g-2">
              <div class="col-md-4">
                <input
                    v-model="search"
                    type="text"
                    class="form-control form-control-sm"
                    placeholder="Rechercher animal, ferme, message..."
                />
              </div>

              <div class="col-md-3">
                <select v-model="severityFilter" class="form-select form-select-sm">
                  <option value="">Toutes les sévérités</option>
                  <option value="CRITICAL">Critique</option>
                  <option value="HIGH">Haute</option>
                  <option value="WARNING">Warning</option>
                  <option value="MEDIUM">Moyenne</option>
                  <option value="LOW">Basse</option>
                  <option value="INFO">Info</option>
                </select>
              </div>

              <div class="col-md-3">
                <select v-model="statusFilter" class="form-select form-select-sm">
                  <option value="">Tous les statuts</option>
                  <option value="active">Actives</option>
                  <option value="resolved">Résolues</option>
                </select>
              </div>

              <div class="col-md-2">
                <button
                    class="btn btn-sm btn-outline-secondary w-100"
                    @click="resetFilters"
                >
                  Reset
                </button>
              </div>
            </div>
          </div>

          <!-- Table -->
          <div class="data-table table-card-fixed">
            <div class="data-table-header">
              <span class="data-table-title">
                {{ filteredAlerts.length }} alerte(s)
              </span>
            </div>

            <div class="table-responsive">
              <table class="table mb-0">
                <thead>
                <tr>
                  <th>ID</th>
                  <th>ANIMAL</th>
                  <th>FERME</th>
                  <th>TYPE</th>
                  <th>MESSAGE</th>
                  <th>DATE LIMITE</th>
                  <th>SÉVÉRITÉ</th>
                  <th>STATUT</th>
                  <th>ACTIONS</th>
                </tr>
                </thead>

                <tbody>
                <tr v-if="paginatedAlerts.length === 0">
                  <td colspan="9" class="text-center text-muted py-4">
                    Aucune alerte
                  </td>
                </tr>

                <tr v-for="a in paginatedAlerts" :key="a.id">
                  <td>#{{ a.id }}</td>

                  <td class="fw-semibold">
                    {{ a.animalRfidTag || '—' }}
                  </td>

                  <td>{{ a.farmName || '—' }}</td>

                  <td>{{ formatAlertType(a.alertType) }}</td>

                  <td style="max-width:220px;" class="text-truncate">
                    {{ a.message }}
                  </td>

                  <td>{{ formatDate(a.dueDate) }}</td>

                  <td>
                      <span class="badge" :class="severityBadge(a.severity)">
                        {{ formatSeverity(a.severity) }}
                      </span>
                  </td>

                  <td>
                      <span
                          :class="a.isResolved ? 'badge bg-success' : 'badge bg-warning text-dark'"
                      >
                        {{ a.isResolved ? 'Résolue' : 'Active' }}
                      </span>
                  </td>

                  <td>
                    <button
                        v-if="!a.isResolved"
                        class="btn btn-sm btn-outline-success"
                        @click="resolveAlert(a)"
                    >
                      <i class="bi bi-check-lg"></i>
                      Résoudre
                    </button>

                    <span v-else class="text-muted small">
                        —
                      </span>
                  </td>
                </tr>
                </tbody>
              </table>
            </div>

            <!-- Pagination -->
            <TablePagination
                :current-page="currentPage"
                :total-pages="totalPages"
                :total="filteredAlerts.length"
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
        <!-- PANEL STATISTIQUES -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'stats'" class="page-panel-scroll">

          <div class="row g-2 mb-3">
            <div class="col-md-3">
              <StatCard
                  icon="bell-fill"
                  :value="alerts.length"
                  label="Total alertes"
                  color="#0B5D1E"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="exclamation-triangle-fill"
                  :value="countActive"
                  label="Actives"
                  color="#D97706"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="check-circle-fill"
                  :value="countResolved"
                  label="Résolues"
                  color="#059669"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="shield-exclamation"
                  :value="countCritical"
                  label="Critiques"
                  color="#DC2626"
              />
            </div>
          </div>

          <div class="data-table">
            <div class="data-table-header">
              <span class="data-table-title">
                Répartition par sévérité
              </span>
            </div>

            <div class="table-responsive">
              <table class="table mb-0">
                <thead>
                <tr>
                  <th>SÉVÉRITÉ</th>
                  <th>NOMBRE</th>
                  <th>DESCRIPTION</th>
                </tr>
                </thead>

                <tbody>
                <tr>
                  <td>
                    <span class="badge bg-danger">Critique</span>
                  </td>
                  <td>{{ countBySeverity('CRITICAL') }}</td>
                  <td>Alerte nécessitant une intervention immédiate.</td>
                </tr>

                <tr>
                  <td>
                    <span class="badge bg-warning text-dark">Warning</span>
                  </td>
                  <td>{{ countBySeverity('WARNING') }}</td>
                  <td>Alerte importante à traiter rapidement.</td>
                </tr>

                <tr>
                  <td>
                    <span class="badge bg-info text-dark">Info</span>
                  </td>
                  <td>{{ countBySeverity('INFO') }}</td>
                  <td>Information sanitaire ou rappel simple.</td>
                </tr>

                <tr>
                  <td>
                    <span class="badge bg-success">Basse</span>
                  </td>
                  <td>{{ countBySeverity('LOW') }}</td>
                  <td>Alerte mineure.</td>
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

import api from '@/api/axios.js'
import { formatDate } from '@/utils/formatters.js'
import { usePagination } from '@/composables/usePagination.js'

const currentPanel = ref('list')

const loading = ref(true)
const alerts = ref([])

const search = ref('')
const severityFilter = ref('')
const statusFilter = ref('')

const filteredAlerts = computed(() => {
  let result = alerts.value || []

  if (search.value.trim()) {
    const q = search.value.toLowerCase()

    result = result.filter(a =>
        a.message?.toLowerCase().includes(q) ||
        a.animalRfidTag?.toLowerCase().includes(q) ||
        a.farmName?.toLowerCase().includes(q) ||
        a.alertType?.toLowerCase().includes(q)
    )
  }

  if (severityFilter.value) {
    result = result.filter(a => a.severity === severityFilter.value)
  }

  if (statusFilter.value === 'active') {
    result = result.filter(a => !a.isResolved)
  }

  if (statusFilter.value === 'resolved') {
    result = result.filter(a => a.isResolved)
  }

  return result
})

const {
  currentPage,
  perPage,
  totalPages,
  paginatedItems: paginatedAlerts,
  from,
  to,
  visiblePages,
  goToPage,
  changePerPage
} = usePagination(filteredAlerts)

const countActive = computed(() =>
    alerts.value.filter(a => !a.isResolved).length
)

const countResolved = computed(() =>
    alerts.value.filter(a => a.isResolved).length
)

const countCritical = computed(() =>
    alerts.value.filter(a => a.severity === 'CRITICAL').length
)

onMounted(() => generateAndLoad())

async function generateAndLoad() {
  loading.value = true

  try {
    await api.post('/alerts/generate')
    const res = await api.get('/admin/alerts')
    alerts.value = res.data || []
  } catch (e) {
    console.error('Erreur alertes :', e)
  } finally {
    loading.value = false
  }
}

async function resolveAlert(alert) {
  try {
    await api.put(`/alerts/${alert.id}/resolve`)
    alert.isResolved = true
  } catch (e) {
    console.error(e)
  }
}

function resetFilters() {
  search.value = ''
  severityFilter.value = ''
  statusFilter.value = ''
}

function countBySeverity(severity) {
  return alerts.value.filter(a => a.severity === severity).length
}

function severityBadge(severity) {
  return {
    CRITICAL: 'bg-danger',
    HIGH: 'bg-danger',
    WARNING: 'bg-warning text-dark',
    MEDIUM: 'bg-warning text-dark',
    LOW: 'bg-success',
    INFO: 'bg-info text-dark'
  }[severity] || 'bg-secondary'
}

function formatSeverity(severity) {
  return {
    CRITICAL: 'Critique',
    HIGH: 'Haute',
    WARNING: 'Warning',
    MEDIUM: 'Moyenne',
    LOW: 'Basse',
    INFO: 'Info'
  }[severity] || severity
}

function formatAlertType(type) {
  return {
    VACCINATION_DUE: 'Vaccination',
    CHECKUP_DUE: 'Contrôle',
    TREATMENT_FOLLOWUP: 'Suivi traitement',
    PREGNANCY_CHECK: 'Gestation'
  }[type] || type
}
</script>