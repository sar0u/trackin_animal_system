<template>
  <AdminLayout page-title="Gestion des Subventions">
    <div class="page-section">

      <!-- Tabs internes -->
      <div class="page-tabs">
        <button
            :class="{ active: currentPanel === 'list' }"
            @click="currentPanel = 'list'"
        >
          Liste des subventions
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
        <p class="text-muted mt-2">Chargement des subventions...</p>
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
                <h5 class="fw-bold mb-1">Subventions</h5>
                <p class="text-muted small mb-0">
                  Gestion des aides attribuées aux exploitations.
                </p>
              </div>

              <button class="btn btn-sm btn-success" @click="openCreate">
                <i class="bi bi-plus-circle me-1"></i>
                Nouvelle
              </button>
            </div>

            <!-- Filtres compacts -->
            <div class="row g-2">
              <div class="col-md-5">
                <input
                    v-model="search"
                    type="text"
                    class="form-control form-control-sm"
                    placeholder="Rechercher ferme, propriétaire, type..."
                />
              </div>

              <div class="col-md-3">
                <select v-model="statusFilter" class="form-select form-select-sm">
                  <option value="">Tous les statuts</option>
                  <option value="PENDING">En attente</option>
                  <option value="APPROVED">Approuvée</option>
                  <option value="REJECTED">Rejetée</option>
                  <option value="PAID">Payée</option>
                </select>
              </div>

              <div class="col-md-2">
                <input
                    v-model="yearFilter"
                    type="number"
                    class="form-control form-control-sm"
                    placeholder="Année"
                />
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
                {{ filteredSubventions.length }} subvention(s)
              </span>
            </div>

            <div class="table-responsive">
              <table class="table mb-0">
                <thead>
                <tr>
                  <th>ID</th>
                  <th>FERME</th>
                  <th>PROPRIÉTAIRE</th>
                  <th>MONTANT</th>
                  <th>TYPE</th>
                  <th>ANNÉE</th>
                  <th>STATUT</th>
                  <th>APPROUVÉ PAR</th>
                  <th>DATE</th>
                  <th>ACTIONS</th>
                </tr>
                </thead>

                <tbody>
                <tr v-if="paginatedSubventions.length === 0">
                  <td colspan="10" class="text-center text-muted py-4">
                    Aucune subvention
                  </td>
                </tr>

                <tr v-for="s in paginatedSubventions" :key="s.id">
                  <td>#{{ s.id }}</td>

                  <td class="fw-semibold">
                    {{ s.farmName || '—' }}
                  </td>

                  <td>{{ s.ownerName || '—' }}</td>

                  <td class="fw-bold">
                    {{ formatAmount(s.amount) }}
                  </td>

                  <td>{{ s.type || '—' }}</td>

                  <td>{{ s.year || '—' }}</td>

                  <td>
                      <span class="badge" :class="statusBadge(s.status)">
                        {{ formatSubventionStatus(s.status) }}
                      </span>
                  </td>

                  <td>{{ s.approvedBy || '—' }}</td>

                  <td>
                    <small>{{ formatDate(s.createdAt) }}</small>
                  </td>

                  <td>
                    <div class="btn-group btn-group-sm">
                      <button
                          class="btn btn-outline-success"
                          @click="changeStatus(s, 'APPROVED')"
                          :disabled="s.status === 'APPROVED' || s.status === 'PAID'"
                          title="Approuver"
                      >
                        <i class="bi bi-check-lg"></i>
                      </button>

                      <button
                          class="btn btn-outline-primary"
                          @click="changeStatus(s, 'PAID')"
                          :disabled="s.status === 'PAID'"
                          title="Payée"
                      >
                        <i class="bi bi-credit-card"></i>
                      </button>

                      <button
                          class="btn btn-outline-danger"
                          @click="changeStatus(s, 'REJECTED')"
                          :disabled="s.status === 'PAID'"
                          title="Rejeter"
                      >
                        <i class="bi bi-x-lg"></i>
                      </button>

                      <button
                          class="btn btn-outline-secondary"
                          @click="remove(s)"
                          title="Supprimer"
                      >
                        <i class="bi bi-trash"></i>
                      </button>
                    </div>
                  </td>
                </tr>
                </tbody>
              </table>
            </div>

            <!-- Pagination -->
            <TablePagination
                :current-page="currentPage"
                :total-pages="totalPages"
                :total="filteredSubventions.length"
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
                  icon="cash-coin"
                  :value="subventions.length"
                  label="Total dossiers"
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
                  icon="check-circle-fill"
                  :value="countByStatus('APPROVED')"
                  label="Approuvées"
                  color="#059669"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="credit-card-fill"
                  :value="countByStatus('PAID')"
                  label="Payées"
                  color="#2563EB"
              />
            </div>
          </div>

          <div class="data-table">
            <div class="data-table-header">
              <span class="data-table-title">
                Répartition par statut
              </span>
            </div>

            <div class="table-responsive">
              <table class="table mb-0">
                <thead>
                <tr>
                  <th>STATUT</th>
                  <th>NOMBRE</th>
                  <th>MONTANT TOTAL</th>
                </tr>
                </thead>

                <tbody>
                <tr v-for="item in statusStats" :key="item.status">
                  <td>
                      <span class="badge" :class="statusBadge(item.status)">
                        {{ formatSubventionStatus(item.status) }}
                      </span>
                  </td>

                  <td>{{ item.count }}</td>

                  <td class="fw-bold">
                    {{ formatAmount(item.totalAmount) }}
                  </td>
                </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

      </div>

      <!-- ===================================================== -->
      <!-- MODAL CREATION -->
      <!-- ===================================================== -->
      <div
          v-if="showModal"
          class="modal d-block"
          style="background:rgba(0,0,0,0.5);"
      >
        <div class="modal-dialog modal-dialog-centered">
          <div class="modal-content">

            <div class="modal-header">
              <h5 class="modal-title">
                Nouvelle subvention
              </h5>

              <button class="btn-close" @click="closeModal"></button>
            </div>

            <div class="modal-body">
              <div class="mb-3">
                <label class="form-label">Ferme *</label>

                <select v-model="form.farmId" class="form-select">
                  <option value="">Choisir une ferme</option>

                  <option
                      v-for="f in farms"
                      :key="f.id"
                      :value="f.id"
                  >
                    {{ f.name }} — {{ f.wilaya || '' }}
                  </option>
                </select>
              </div>

              <div class="mb-3">
                <label class="form-label">Montant *</label>

                <input
                    v-model="form.amount"
                    type="number"
                    min="0"
                    class="form-control"
                />
              </div>

              <div class="mb-3">
                <label class="form-label">Type</label>

                <select v-model="form.type" class="form-select">
                  <option value="AIDE_ALIMENTATION">Aide alimentation</option>
                  <option value="AIDE_VACCINATION">Aide vaccination</option>
                  <option value="AIDE_ELEVAGE">Aide élevage</option>
                  <option value="AUTRE">Autre</option>
                </select>
              </div>

              <div class="mb-3">
                <label class="form-label">Année *</label>

                <input
                    v-model="form.year"
                    type="number"
                    class="form-control"
                />
              </div>

              <div class="mb-3">
                <label class="form-label">Motif</label>

                <textarea
                    v-model="form.reason"
                    class="form-control"
                    rows="3"
                ></textarea>
              </div>

              <div v-if="modalError" class="alert alert-danger py-2">
                {{ modalError }}
              </div>
            </div>

            <div class="modal-footer">
              <button class="btn btn-secondary" @click="closeModal">
                Annuler
              </button>

              <button
                  class="btn btn-success"
                  @click="create"
                  :disabled="saving"
              >
                <span
                    v-if="saving"
                    class="spinner-border spinner-border-sm me-2"
                ></span>

                Créer
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
import { computed, onMounted, ref } from 'vue'

import AdminLayout from '@/layouts/AdminLayout.vue'
import StatCard from '@/components/common/StatCard.vue'
import TablePagination from '@/components/common/TablePagination.vue'

import { formatDate } from '@/utils/formatters.js'
import { farmsApi } from '@/api/farmsApi.js'

import { usePagination } from '@/composables/usePagination.js'
import {subventionsApi} from "@/api/subventionApi.js";

const currentPanel = ref('list')

const loading = ref(true)
const saving = ref(false)

const subventions = ref([])
const farms = ref([])

const showModal = ref(false)
const modalError = ref('')
const toast = ref('')

const search = ref('')
const statusFilter = ref('')
const yearFilter = ref('')

const form = ref({
  farmId: '',
  amount: '',
  type: 'AIDE_ALIMENTATION',
  year: new Date().getFullYear(),
  reason: ''
})

const filteredSubventions = computed(() => {
  let result = subventions.value || []

  if (search.value.trim()) {
    const q = search.value.toLowerCase()

    result = result.filter(s =>
        s.farmName?.toLowerCase().includes(q) ||
        s.ownerName?.toLowerCase().includes(q) ||
        s.type?.toLowerCase().includes(q)
    )
  }

  if (statusFilter.value) {
    result = result.filter(s => s.status === statusFilter.value)
  }

  if (yearFilter.value) {
    result = result.filter(s => String(s.year) === String(yearFilter.value))
  }

  return result
})

const {
  currentPage,
  perPage,
  totalPages,
  paginatedItems: paginatedSubventions,
  from,
  to,
  visiblePages,
  goToPage,
  changePerPage
} = usePagination(filteredSubventions)

const statusStats = computed(() => {
  const statuses = ['PENDING', 'APPROVED', 'REJECTED', 'PAID']

  return statuses.map(status => {
    const list = subventions.value.filter(s => s.status === status)

    const totalAmount = list.reduce((sum, s) => {
      return sum + Number(s.amount || 0)
    }, 0)

    return {
      status,
      count: list.length,
      totalAmount
    }
  })
})

onMounted(async () => {
  await Promise.all([
    loadSubventions(),
    loadFarms()
  ])
})

async function loadSubventions() {
  loading.value = true

  try {
    const res = await subventionsApi.getAll()
    subventions.value = res.data || []
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

async function loadFarms() {
  try {
    const res = await farmsApi.getAll()
    farms.value = res.data || []
  } catch (e) {
    console.error(e)
  }
}

function openCreate() {
  modalError.value = ''

  form.value = {
    farmId: '',
    amount: '',
    type: 'AIDE_ALIMENTATION',
    year: new Date().getFullYear(),
    reason: ''
  }

  showModal.value = true
}

function closeModal() {
  showModal.value = false
}

function resetFilters() {
  search.value = ''
  statusFilter.value = ''
  yearFilter.value = ''
}

async function create() {
  modalError.value = ''

  if (!form.value.farmId) {
    modalError.value = 'La ferme est obligatoire.'
    return
  }

  if (!form.value.amount || Number(form.value.amount) <= 0) {
    modalError.value = 'Le montant est obligatoire.'
    return
  }

  saving.value = true

  try {
    await subventionsApi.create(form.value)
    showModal.value = false
    showToast('Subvention créée')
    await loadSubventions()
  } catch (e) {
    modalError.value = e.response?.data?.message || 'Erreur'
  } finally {
    saving.value = false
  }
}

async function changeStatus(s, status) {
  try {
    await subventionsApi.updateStatus(s.id, status)
    s.status = status
    showToast('Statut mis à jour')
  } catch {
    alert('Erreur changement statut')
  }
}

async function remove(s) {
  if (!confirm('Supprimer ?')) return

  try {
    await subventionsApi.delete(s.id)
    subventions.value = subventions.value.filter(x => x.id !== s.id)
    showToast('Subvention supprimée')
  } catch {
    alert('Erreur suppression')
  }
}

function countByStatus(status) {
  return subventions.value.filter(x => x.status === status).length
}

function statusBadge(status) {
  return {
    PENDING: 'bg-warning text-dark',
    APPROVED: 'bg-success',
    REJECTED: 'bg-danger',
    PAID: 'bg-primary'
  }[status] || 'bg-secondary'
}

function formatSubventionStatus(status) {
  return {
    PENDING: 'En attente',
    APPROVED: 'Approuvée',
    REJECTED: 'Rejetée',
    PAID: 'Payée'
  }[status] || status
}

function formatAmount(value) {
  return value
      ? Number(value).toLocaleString('fr-FR') + ' DA'
      : '0 DA'
}

function showToast(msg) {
  toast.value = msg

  setTimeout(() => {
    toast.value = ''
  }, 3000)
}
</script>