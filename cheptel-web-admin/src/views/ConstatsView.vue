<template>
  <AdminLayout page-title="Gestion des Constats">
    <div class="page-section">

      <!-- Navigation interne -->
      <div class="page-tabs">
        <button
            :class="{ active: currentPanel === 'list' }"
            @click="currentPanel = 'list'"
        >
          Liste des constats
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
        <p class="text-muted mt-2">Chargement des constats...</p>
      </div>

      <div v-else class="page-panel">

        <!-- ===================================================== -->
        <!-- PANEL LISTE -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'list'" class="table-card-fixed">

          <!-- Header compact -->
          <div class="page-header mb-2">
            <div class="d-flex justify-content-between align-items-center mb-2">
              <div>
                <h5 class="fw-bold mb-1">Constats déclarés</h5>
                <p class="text-muted small mb-0">
                  Anomalies déclarées par les contrôleurs terrain.
                </p>
              </div>

              <button class="btn btn-outline-success btn-sm" @click="reload">
                <i class="bi bi-arrow-clockwise me-1"></i>
                Actualiser
              </button>
            </div>

            <!-- Filtres compacts -->
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
                  <option value="AUTRE">Autre</option>
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

          <!-- Table -->
          <div class="data-table table-card-fixed">
            <div class="data-table-header">
              <span class="data-table-title">
                {{ filteredConstats.length }} / {{ constats.length }} constat(s)
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
                  <th>PIÈCES</th>
                  <th>DATE</th>
                  <th>ACTIONS</th>
                </tr>
                </thead>

                <tbody>
                <tr v-if="paginatedConstats.length === 0">
                  <td colspan="10" class="text-center text-muted py-4">
                    Aucun constat trouvé
                  </td>
                </tr>

                <tr v-for="c in paginatedConstats" :key="c.id">
                  <td>#{{ c.id }}</td>

                  <td>
                      <span class="badge" :class="typeBadge(c.type)">
                        {{ formatType(c.type) }}
                      </span>
                  </td>

                  <td style="max-width:200px;" class="text-truncate">
                    {{ c.description }}
                  </td>

                  <td>{{ c.controleurUsername || '—' }}</td>

                  <td>{{ c.farmName || '—' }}</td>

                  <td style="width:150px;">
                    <select
                        class="form-select form-select-sm"
                        :value="c.status"
                        @change="changeStatus(c, $event.target.value)"
                    >
                      <option value="PENDING">En attente</option>
                      <option value="IN_REVIEW">En cours</option>
                      <option value="RESOLVED">Résolu</option>
                      <option value="REJECTED">Rejeté</option>
                    </select>
                  </td>

                  <td>
                      <span
                          v-if="c.latitude && c.longitude"
                          class="badge bg-primary"
                      >
                        GPS
                      </span>
                    <span v-else class="text-muted">—</span>
                  </td>

                  <td>
                      <span
                          v-if="attachmentsCount(c) > 0"
                          class="badge bg-success"
                      >
                        {{ attachmentsCount(c) }}
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
                :total="filteredConstats.length"
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
                  icon="file-earmark-text-fill"
                  :value="constats.length"
                  label="Total constats"
                  color="#0B5D1E"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="hourglass-split"
                  :value="countByStatus('PENDING')"
                  label="En attente"
                  color="#D97706"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="shield-exclamation"
                  :value="countByType('FRAUDE')"
                  label="Fraudes"
                  color="#DC2626"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="check-circle-fill"
                  :value="countByStatus('RESOLVED')"
                  label="Résolus"
                  color="#059669"
              />
            </div>
          </div>

          <div class="data-table">
            <div class="data-table-header">
              <span class="data-table-title">
                Répartition par statut et type
              </span>
            </div>

            <div class="table-responsive">
              <table class="table mb-0">
                <thead>
                <tr>
                  <th>CATÉGORIE</th>
                  <th>NOMBRE</th>
                  <th>DESCRIPTION</th>
                </tr>
                </thead>

                <tbody>
                <tr>
                  <td>En attente</td>
                  <td>{{ countByStatus('PENDING') }}</td>
                  <td>Constats non encore traités</td>
                </tr>

                <tr>
                  <td>En cours</td>
                  <td>{{ countByStatus('IN_REVIEW') }}</td>
                  <td>Constats en traitement administratif</td>
                </tr>

                <tr>
                  <td>Résolus</td>
                  <td>{{ countByStatus('RESOLVED') }}</td>
                  <td>Constats clôturés</td>
                </tr>

                <tr>
                  <td>Fraudes</td>
                  <td>{{ countByType('FRAUDE') }}</td>
                  <td>Déclarations de fraude</td>
                </tr>

                <tr>
                  <td>Animaux manquants</td>
                  <td>{{ countByType('MANQUANT') }}</td>
                  <td>Écarts d’effectif déclarés</td>
                </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

      </div>

      <!-- ===================================================== -->
      <!-- MODAL DETAIL -->
      <!-- ===================================================== -->
      <div
          v-if="selectedConstat"
          class="modal d-block"
          style="background:rgba(0,0,0,0.5);"
      >
        <div class="modal-dialog modal-dialog-centered modal-xl">
          <div class="modal-content">

            <div class="modal-header">
              <h5 class="modal-title">
                Détail du constat #{{ selectedConstat.id }}
              </h5>
              <button class="btn-close" @click="selectedConstat = null"></button>
            </div>

            <div class="modal-body">
              <div class="row g-3">
                <div class="col-md-6">
                  <div class="border rounded p-3">
                    <h6 class="fw-bold mb-3">Informations</h6>

                    <table class="table table-sm table-borderless mb-0">
                      <tbody>
                      <tr>
                        <td class="text-muted">Type</td>
                        <td>
                            <span class="badge" :class="typeBadge(selectedConstat.type)">
                              {{ formatType(selectedConstat.type) }}
                            </span>
                        </td>
                      </tr>

                      <tr>
                        <td class="text-muted">Statut</td>
                        <td>
                            <span class="badge" :class="statusBadge(selectedConstat.status)">
                              {{ formatStatus(selectedConstat.status) }}
                            </span>
                        </td>
                      </tr>

                      <tr>
                        <td class="text-muted">Contrôleur</td>
                        <td>{{ selectedConstat.controleurUsername || '—' }}</td>
                      </tr>

                      <tr>
                        <td class="text-muted">Ferme</td>
                        <td>{{ selectedConstat.farmName || '—' }}</td>
                      </tr>

                      <tr>
                        <td class="text-muted">Date</td>
                        <td>{{ formatDateTime(selectedConstat.createdAt) }}</td>
                      </tr>
                      </tbody>
                    </table>
                  </div>
                </div>

                <div class="col-md-6">
                  <div class="border rounded p-3">
                    <h6 class="fw-bold mb-3">Localisation</h6>

                    <p class="mb-1">
                      <strong>Latitude :</strong>
                      {{ selectedConstat.latitude || '—' }}
                    </p>

                    <p class="mb-1">
                      <strong>Longitude :</strong>
                      {{ selectedConstat.longitude || '—' }}
                    </p>

                    <a
                        v-if="selectedConstat.latitude && selectedConstat.longitude"
                        :href="googleMapsUrl(selectedConstat)"
                        target="_blank"
                        class="btn btn-sm btn-outline-primary mt-2"
                    >
                      <i class="bi bi-geo-alt me-1"></i>
                      Google Maps
                    </a>
                  </div>
                </div>

                <div class="col-12">
                  <div class="border rounded p-3">
                    <h6 class="fw-bold mb-3">Description</h6>
                    <p class="mb-0">
                      {{ selectedConstat.description }}
                    </p>
                  </div>
                </div>

                <div
                    class="col-12"
                    v-if="getAttachments(selectedConstat).length > 0"
                >
                  <div class="border rounded p-3">
                    <h6 class="fw-bold mb-3">
                      Pièces jointes ({{ getAttachments(selectedConstat).length }})
                    </h6>

                    <div class="row g-2">
                      <div
                          v-for="(att, i) in getAttachments(selectedConstat)"
                          :key="i"
                          class="col-md-4"
                      >
                        <div class="border rounded p-2">
                          <img
                              v-if="isImage(att)"
                              :src="buildFileUrl(att)"
                              class="img-fluid rounded"
                              style="height:150px;object-fit:cover;width:100%;"
                              alt=""
                          />

                          <div
                              v-else
                              class="bg-light rounded d-flex flex-column justify-content-center align-items-center"
                              style="height:150px;"
                          >
                            <i class="bi bi-file-earmark-text fs-1 text-muted"></i>
                            <small class="text-muted mt-2">{{ fileName(att) }}</small>
                          </div>

                          <a
                              :href="buildFileUrl(att)"
                              target="_blank"
                              class="btn btn-sm btn-outline-success w-100 mt-2"
                          >
                            Ouvrir
                          </a>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

              </div>
            </div>

            <div class="modal-footer">
              <button class="btn btn-secondary" @click="selectedConstat = null">
                Fermer
              </button>
            </div>

          </div>
        </div>
      </div>

      <!-- Toast -->
      <div
          v-if="toast"
          class="position-fixed bottom-0 end-0 p-3"
          style="z-index:9999;"
      >
        <div class="toast show bg-success text-white">
          <div class="toast-body">
            {{ toast }}
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
import { constatsApi } from '@/api/constatsApi.js'
import { usePagination } from '@/composables/usePagination.js'

const currentPanel = ref('list')

const loading = ref(true)
const constats = ref([])

const search = ref('')
const typeFilter = ref('')
const statusFilter = ref('')

const selectedConstat = ref(null)
const toast = ref('')

const filteredConstats = computed(() => {
  let result = constats.value || []

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
  paginatedItems: paginatedConstats,
  from,
  to,
  visiblePages,
  goToPage,
  changePerPage
} = usePagination(filteredConstats)

onMounted(() => loadConstats())

async function loadConstats() {
  loading.value = true

  try {
    const res = await constatsApi.getAll()
    constats.value = res.data || []
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

function reload() {
  loadConstats()
}

function resetFilters() {
  search.value = ''
  typeFilter.value = ''
  statusFilter.value = ''
}

function openDetails(c) {
  selectedConstat.value = c
}

async function changeStatus(c, newStatus) {
  try {
    await constatsApi.updateStatus(c.id, newStatus)
    c.status = newStatus
    showToast('Statut mis à jour')
  } catch {
    alert('Erreur mise à jour statut')
  }
}

function showToast(msg) {
  toast.value = msg

  setTimeout(() => {
    toast.value = ''
  }, 3000)
}

function countByStatus(status) {
  return constats.value.filter(c => c.status === status).length
}

function countByType(type) {
  return constats.value.filter(c => c.type === type).length
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

function googleMapsUrl(c) {
  return `https://www.google.com/maps?q=${c.latitude},${c.longitude}`
}

function getAttachments(c) {
  try {
    if (c.attachmentsJson) {
      const parsed = JSON.parse(c.attachmentsJson)
      return Array.isArray(parsed) ? parsed : []
    }

    if (c.photoUrl) {
      return [c.photoUrl]
    }

    return []
  } catch {
    return c.photoUrl ? [c.photoUrl] : []
  }
}

function attachmentsCount(c) {
  return getAttachments(c).length
}

function isImage(path) {
  if (!path) return false

  const p = path.toLowerCase()

  return p.endsWith('.jpg') ||
      p.endsWith('.jpeg') ||
      p.endsWith('.png')
}

function buildFileUrl(path) {
  if (!path) return '#'

  if (path.startsWith('http')) return path

  return 'http://localhost:8080' + path
}

function fileName(path) {
  return path ? path.split('/').pop() : ''
}
</script>