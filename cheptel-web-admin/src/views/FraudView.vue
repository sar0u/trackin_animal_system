<template>
  <AdminLayout page-title="Détection de Fraude">
    <div class="page-section">

      <!-- Navigation interne de la page -->
      <div class="page-tabs">
        <button
            :class="{ active: currentPanel === 'indicators' }"
            @click="currentPanel = 'indicators'"
        >
          Indicateurs
        </button>

        <button
            :class="{ active: currentPanel === 'suspects' }"
            @click="currentPanel = 'suspects'"
        >
          Constats suspects
        </button>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-success"></div>
        <p class="text-muted mt-2">Chargement des indicateurs...</p>
      </div>

      <div v-else class="page-panel">

        <!-- ===================================================== -->
        <!-- PANEL 1 : INDICATEURS -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'indicators'" class="page-panel-scroll">

          <div class="d-flex justify-content-between align-items-center mb-2">
            <div>
              <h5 class="fw-bold mb-1">Indicateurs de fraude et anomalies</h5>
              <p class="text-muted small mb-0">
                Analyse des constats suspects et incohérences terrain.
              </p>
            </div>

            <button class="btn btn-outline-success btn-sm" @click="reload">
              <i class="bi bi-arrow-clockwise me-1"></i>
              Actualiser
            </button>
          </div>

          <!-- Cartes statistiques compactes -->
          <div class="row g-2 mb-2">
            <div class="col-md-3">
              <StatCard
                  icon="shield-exclamation"
                  :value="indicators.totalFraudes || 0"
                  label="Constats fraude"
                  color="#DC2626"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="question-circle-fill"
                  :value="indicators.totalManquants || 0"
                  label="Animaux manquants"
                  color="#D97706"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="hourglass-split"
                  :value="indicators.constatsNonResolus || 0"
                  label="Non résolus"
                  color="#7C3AED"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="house-exclamation"
                  :value="indicators.fermesVides || 0"
                  label="Fermes sans animaux"
                  color="#0891B2"
              />
            </div>
          </div>

          <!-- Score de risque -->
          <div class="chart-container mb-2">
            <div class="d-flex justify-content-between align-items-center mb-2">
              <h6 class="fw-bold mb-0">
                <i class="bi bi-speedometer2 me-2 text-danger"></i>
                Niveau de risque global
              </h6>

              <span class="badge" :class="riskBadge">
                {{ riskLabel }}
              </span>
            </div>

            <div class="progress" style="height:26px;">
              <div
                  class="progress-bar"
                  :class="riskProgressClass"
                  role="progressbar"
                  :style="{ width: riskScore + '%' }"
              >
                {{ riskScore }}%
              </div>
            </div>

            <p class="text-muted small mt-2 mb-0">
              Score calculé selon les fraudes, animaux manquants, constats non résolus et fermes vides.
            </p>
          </div>

          <!-- Analyse synthétique -->
          <div class="row g-2">
            <div class="col-md-4">
              <div class="analysis-card">
                <i class="bi bi-shield-check text-success fs-3"></i>
                <div>
                  <h6>Conformité</h6>
                  <p>
                    {{ indicators.constatsNonResolus || 0 }}
                    constat(s) nécessitent un traitement.
                  </p>
                </div>
              </div>
            </div>

            <div class="col-md-4">
              <div class="analysis-card">
                <i class="bi bi-exclamation-triangle text-warning fs-3"></i>
                <div>
                  <h6>Animaux manquants</h6>
                  <p>
                    {{ indicators.totalManquants || 0 }}
                    signalement(s) d’animaux manquants.
                  </p>
                </div>
              </div>
            </div>

            <div class="col-md-4">
              <div class="analysis-card">
                <i class="bi bi-house-exclamation text-primary fs-3"></i>
                <div>
                  <h6>Fermes vides</h6>
                  <p>
                    {{ indicators.fermesVides || 0 }}
                    ferme(s) sans animaux enregistrés.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- ===================================================== -->
        <!-- PANEL 2 : CONSTATS SUSPECTS -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'suspects'" class="table-card-fixed">

          <!-- Header et filtres compacts -->
          <div class="page-header mb-2">
            <div class="d-flex justify-content-between align-items-center mb-2">
              <div>
                <h5 class="fw-bold mb-1">Constats suspects</h5>
                <p class="text-muted small mb-0">
                  Fraudes, animaux manquants, doublons et constats non résolus.
                </p>
              </div>

              <button class="btn btn-outline-success btn-sm" @click="reload">
                <i class="bi bi-arrow-clockwise me-1"></i>
                Actualiser
              </button>
            </div>

            <div class="row g-2">
              <div class="col-md-4">
                <input
                    v-model="search"
                    type="text"
                    class="form-control form-control-sm"
                    placeholder="Rechercher description, ferme, contrôleur..."
                />
              </div>

              <div class="col-md-3">
                <select v-model="typeFilter" class="form-select form-select-sm">
                  <option value="">Tous les types</option>
                  <option value="FRAUDE">Fraude</option>
                  <option value="MANQUANT">Animal manquant</option>
                  <option value="DOUBLON">Doublon</option>
                </select>
              </div>

              <div class="col-md-3">
                <select v-model="statusFilter" class="form-select form-select-sm">
                  <option value="">Tous les statuts</option>
                  <option value="PENDING">En attente</option>
                  <option value="IN_REVIEW">En cours</option>
                  <option value="RESOLVED">Résolu</option>
                  <option value="REJECTED">Rejeté</option>
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

          <!-- Table paginée -->
          <div class="data-table table-card-fixed">
            <div class="data-table-header">
              <span class="data-table-title">
                <i class="bi bi-shield-exclamation me-2 text-danger"></i>
                {{ filteredFrauds.length }} constat(s) suspect(s)
              </span>
            </div>

            <div class="table-responsive">
              <table class="table mb-0">
                <thead>
                <tr>
                  <th>ID</th>
                  <th>TYPE</th>
                  <th>DESCRIPTION</th>
                  <th>CONTRÔLEUR</th>
                  <th>FERME</th>
                  <th>STATUT</th>
                  <th>GPS</th>
                  <th>DATE</th>
                  <th>ACTION</th>
                </tr>
                </thead>

                <tbody>
                <tr v-if="paginatedFrauds.length === 0">
                  <td colspan="9" class="text-center text-muted py-4">
                    Aucun constat suspect
                  </td>
                </tr>

                <tr v-for="c in paginatedFrauds" :key="c.id">
                  <td>#{{ c.id }}</td>

                  <td>
                      <span class="badge" :class="typeBadge(c.type)">
                        {{ formatType(c.type) }}
                      </span>
                  </td>

                  <td style="max-width:220px;" class="text-truncate">
                    {{ c.description }}
                  </td>

                  <td>{{ c.controleurUsername || '—' }}</td>

                  <td>{{ c.farmName || '—' }}</td>

                  <td>
                      <span class="badge" :class="statusBadge(c.status)">
                        {{ formatStatus(c.status) }}
                      </span>
                  </td>

                  <td>
                      <span v-if="c.latitude && c.longitude" class="badge bg-primary">
                        GPS
                      </span>
                    <span v-else class="text-muted">—</span>
                  </td>

                  <td>
                    <small>{{ formatDateTime(c.createdAt) }}</small>
                  </td>

                  <td>
                    <button
                        class="btn btn-sm btn-outline-success"
                        @click="openDetails(c)"
                    >
                      <i class="bi bi-eye"></i>
                    </button>
                  </td>
                </tr>
                </tbody>
              </table>
            </div>

            <!-- Pagination -->
            <TablePagination
                :current-page="currentPage"
                :total-pages="totalPages"
                :total="filteredFrauds.length"
                :per-page="perPage"
                :from="from"
                :to="to"
                :visible-pages="visiblePages"
                @change="goToPage"
                @per-page-change="changePerPage"
            />
          </div>
        </div>
      </div>

      <!-- ===================================================== -->
      <!-- MODAL DETAIL -->
      <!-- ===================================================== -->
      <div
          v-if="selected"
          class="modal d-block"
          style="background:rgba(0,0,0,0.5);"
      >
        <div class="modal-dialog modal-dialog-centered modal-lg">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">
                Constat suspect #{{ selected.id }}
              </h5>

              <button class="btn-close" @click="selected = null"></button>
            </div>

            <div class="modal-body">
              <div class="row g-3">
                <div class="col-md-6">
                  <div class="border rounded p-3">
                    <h6 class="fw-bold mb-2">Informations</h6>

                    <p class="mb-1">
                      <strong>Type :</strong>
                      <span class="badge" :class="typeBadge(selected.type)">
                        {{ formatType(selected.type) }}
                      </span>
                    </p>

                    <p class="mb-1">
                      <strong>Statut :</strong>
                      <span class="badge" :class="statusBadge(selected.status)">
                        {{ formatStatus(selected.status) }}
                      </span>
                    </p>

                    <p class="mb-1">
                      <strong>Contrôleur :</strong>
                      {{ selected.controleurUsername || '—' }}
                    </p>

                    <p class="mb-1">
                      <strong>Ferme :</strong>
                      {{ selected.farmName || '—' }}
                    </p>

                    <p class="mb-0">
                      <strong>Date :</strong>
                      {{ formatDateTime(selected.createdAt) }}
                    </p>
                  </div>
                </div>

                <div class="col-md-6">
                  <div class="border rounded p-3">
                    <h6 class="fw-bold mb-2">Localisation</h6>

                    <p class="mb-1">
                      Lat : {{ selected.latitude || '—' }}
                    </p>

                    <p class="mb-1">
                      Lng : {{ selected.longitude || '—' }}
                    </p>

                    <a
                        v-if="selected.latitude && selected.longitude"
                        :href="`https://www.google.com/maps?q=${selected.latitude},${selected.longitude}`"
                        target="_blank"
                        class="btn btn-sm btn-outline-primary mt-1"
                    >
                      <i class="bi bi-geo-alt me-1"></i>
                      Google Maps
                    </a>
                  </div>
                </div>

                <div class="col-12">
                  <div class="border rounded p-3">
                    <h6 class="fw-bold mb-2">Description</h6>
                    <p class="mb-0">
                      {{ selected.description }}
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <div class="modal-footer">
              <button class="btn btn-secondary" @click="selected = null">
                Fermer
              </button>
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

import { formatDateTime, formatStatus } from '@/utils/formatters.js'
import { usePagination } from '@/composables/usePagination.js'
import { constatsApi } from '@/api/constatsApi.js'
import api from '@/api/axios.js'

const currentPanel = ref('indicators')

const loading = ref(true)
const indicators = ref({})
const constats = ref([])

const search = ref('')
const typeFilter = ref('')
const statusFilter = ref('')
const selected = ref(null)

const suspiciousConstats = computed(() =>
    constats.value.filter(c =>
        c.type === 'FRAUDE' ||
        c.type === 'MANQUANT' ||
        c.type === 'DOUBLON' ||
        c.status === 'PENDING'
    )
)

const filteredFrauds = computed(() => {
  let result = suspiciousConstats.value || []

  if (search.value.trim()) {
    const q = search.value.toLowerCase()

    result = result.filter(c =>
        c.description?.toLowerCase().includes(q) ||
        c.farmName?.toLowerCase().includes(q) ||
        c.controleurUsername?.toLowerCase().includes(q)
    )
  }

  if (typeFilter.value) {
    result = result.filter(c => c.type === typeFilter.value)
  }

  if (statusFilter.value) {
    result = result.filter(c => c.status === statusFilter.value)
  }

  return result
})

const {
  currentPage,
  perPage,
  totalPages,
  paginatedItems: paginatedFrauds,
  from,
  to,
  visiblePages,
  goToPage,
  changePerPage
} = usePagination(filteredFrauds)

const riskScore = computed(() => {
  const f = indicators.value.totalFraudes || 0
  const m = indicators.value.totalManquants || 0
  const p = indicators.value.constatsNonResolus || 0
  const e = indicators.value.fermesVides || 0

  return Math.min(f * 15 + m * 10 + p * 5 + e * 3, 100)
})

const riskProgressClass = computed(() =>
    riskScore.value >= 70
        ? 'bg-danger'
        : riskScore.value >= 40
            ? 'bg-warning'
            : 'bg-success'
)

const riskLabel = computed(() =>
    riskScore.value >= 70
        ? 'Risque élevé'
        : riskScore.value >= 40
            ? 'Risque moyen'
            : 'Risque faible'
)

const riskBadge = computed(() =>
    riskScore.value >= 70
        ? 'bg-danger'
        : riskScore.value >= 40
            ? 'bg-warning text-dark'
            : 'bg-success'
)

onMounted(() => loadData())

async function loadData() {
  loading.value = true

  try {
    const [indRes, constatsRes] = await Promise.all([
      api.get('/admin/fraud/indicators'),
      constatsApi.getAll()
    ])

    indicators.value = indRes.data || {}
    constats.value = constatsRes.data || []
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

function reload() {
  loadData()
}

function resetFilters() {
  search.value = ''
  typeFilter.value = ''
  statusFilter.value = ''
}

function openDetails(c) {
  selected.value = c
}

function typeBadge(type) {
  return {
    FRAUDE: 'bg-danger',
    MANQUANT: 'bg-warning text-dark',
    DOUBLON: 'bg-dark',
    AUTRE: 'bg-secondary'
  }[type] || 'bg-secondary'
}

function statusBadge(status) {
  return {
    PENDING: 'bg-warning text-dark',
    IN_REVIEW: 'bg-primary',
    RESOLVED: 'bg-success',
    REJECTED: 'bg-danger'
  }[status] || 'bg-secondary'
}

function formatType(type) {
  return {
    FRAUDE: 'Fraude',
    MANQUANT: 'Animal manquant',
    DOUBLON: 'Doublon',
    AUTRE: 'Autre'
  }[type] || type
}
</script>

<style scoped>
.analysis-card {
  background: white;
  border: 1px solid var(--border-color);
  border-radius: 14px;
  padding: 12px;
  display: flex;
  gap: 10px;
  height: 100%;
}

.analysis-card h6 {
  font-size: 14px;
  font-weight: 700;
  margin-bottom: 2px;
}

.analysis-card p {
  margin-bottom: 0;
  color: var(--text-grey);
  font-size: 12px;
}
</style>