<template>
  <AdminLayout page-title="Campagnes Sanitaires">

    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h5 class="fw-bold mb-1">Campagnes de vaccination</h5>
        <p class="text-muted small mb-0">Planification et suivi des campagnes sanitaires.</p>
      </div>
      <button class="btn btn-success" @click="openCreate">
        <i class="bi bi-plus-circle me-2"></i>Nouvelle campagne
      </button>
    </div>

    <div class="row g-3 mb-4">
      <div class="col-md-3">
        <StatCard icon="calendar-check-fill" :value="campaigns.length" label="Total campagnes" color="#0B5D1E" />
      </div>
      <div class="col-md-3">
        <StatCard icon="play-circle-fill" :value="countByStatus('ACTIVE')" label="En cours" color="#059669" />
      </div>
      <div class="col-md-3">
        <StatCard icon="clock-fill" :value="countByStatus('PLANNED')" label="Planifiées" color="#D97706" />
      </div>
      <div class="col-md-3">
        <StatCard icon="check-circle-fill" :value="countByStatus('COMPLETED')" label="Terminées" color="#2563EB" />
      </div>
    </div>

    <div v-if="loading" class="text-center py-5">
      <div class="spinner-border text-success"></div>
    </div>

    <div v-else class="data-table">
      <div class="data-table-header">
        <span class="data-table-title">{{ campaigns.length }} campagne(s)</span>
      </div>

      <div class="table-responsive">
        <table class="table mb-0">
          <thead>
          <tr>
            <th>NOM</th>
            <th>VACCIN</th>
            <th>ESPÈCE CIBLE</th>
            <th>DÉBUT</th>
            <th>FIN</th>
            <th>STATUT</th>
            <th>CRÉÉE PAR</th>
            <th>ACTIONS</th>
          </tr>
          </thead>

          <tbody>
          <tr v-if="paginatedCampaigns.length === 0">
            <td colspan="8" class="text-center text-muted py-4">Aucune campagne</td>
          </tr>

          <tr v-for="c in paginatedCampaigns" :key="c.id">
            <td class="fw-semibold">{{ c.name }}</td>
            <td>{{ c.vaccineName || '—' }}</td>
            <td>{{ formatSpecies(c.targetSpecies) }}</td>
            <td>{{ formatDate(c.startDate) }}</td>
            <td>{{ formatDate(c.endDate) }}</td>
            <td>
                <span class="badge" :class="statusBadge(c.status)">
                  {{ formatCampaignStatus(c.status) }}
                </span>
            </td>
            <td>{{ c.createdBy || '—' }}</td>
            <td>
              <div class="btn-group btn-group-sm">
                <button class="btn btn-outline-success" @click="openDetails(c)">
                  <i class="bi bi-eye"></i>
                </button>
                <button class="btn btn-outline-primary" @click="changeStatus(c, 'ACTIVE')" v-if="c.status === 'PLANNED'" title="Lancer">
                  <i class="bi bi-play-fill"></i>
                </button>
                <button class="btn btn-outline-secondary" @click="changeStatus(c, 'COMPLETED')" v-if="c.status === 'ACTIVE'" title="Terminer">
                  <i class="bi bi-check-lg"></i>
                </button>
                <button class="btn btn-outline-danger" @click="deleteCampaign(c)" title="Supprimer">
                  <i class="bi bi-trash"></i>
                </button>
              </div>
            </td>
          </tr>
          </tbody>
        </table>
      </div>

      <TablePagination
          :current-page="currentPage"
          :total-pages="totalPages"
          :total="campaigns.length"
          :per-page="perPage"
          :from="from"
          :to="to"
          :visible-pages="visiblePages"
          @change="goToPage"
          @per-page-change="changePerPage"
      />
    </div>

    <!-- Modal Création -->
    <div v-if="showCreateModal" class="modal d-block" style="background:rgba(0,0,0,0.5);">
      <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Nouvelle campagne sanitaire</h5>
            <button class="btn-close" @click="showCreateModal = false"></button>
          </div>
          <div class="modal-body">
            <div class="row g-3">
              <div class="col-12">
                <label class="form-label">Nom *</label>
                <input v-model="form.name" type="text" class="form-control" placeholder="ex: Campagne vaccination FMD 2026" />
              </div>
              <div class="col-md-6">
                <label class="form-label">Vaccin ciblé</label>
                <input v-model="form.vaccineName" type="text" class="form-control" placeholder="ex: Fièvre Aphteuse" />
              </div>
              <div class="col-md-6">
                <label class="form-label">Espèce cible</label>
                <select v-model="form.targetSpecies" class="form-select">
                  <option value="ALL">Toutes les espèces</option>
                  <option value="OVIN">Ovins</option>
                  <option value="BOVIN">Bovins</option>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label">Date de début *</label>
                <input v-model="form.startDate" type="date" class="form-control" />
              </div>
              <div class="col-md-6">
                <label class="form-label">Date de fin *</label>
                <input v-model="form.endDate" type="date" class="form-control" />
              </div>
              <div class="col-12">
                <label class="form-label">Description</label>
                <textarea v-model="form.description" class="form-control" rows="3"></textarea>
              </div>
              <div v-if="createError" class="col-12">
                <div class="alert alert-danger py-2">{{ createError }}</div>
              </div>
              <div class="col-12">
                <div class="alert alert-info small py-2">
                  <i class="bi bi-info-circle me-1"></i>
                  Tous les animaux actifs de l'espèce cible seront automatiquement enrôlés.
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" @click="showCreateModal = false">Annuler</button>
            <button class="btn btn-success" @click="createCampaign" :disabled="saving">
              <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
              Créer la campagne
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Détails -->
    <div v-if="selectedCampaign" class="modal d-block" style="background:rgba(0,0,0,0.5);">
      <div class="modal-dialog modal-dialog-centered modal-xl">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ selectedCampaign.name }}</h5>
            <button class="btn-close" @click="selectedCampaign = null"></button>
          </div>
          <div class="modal-body">
            <div v-if="loadingDetails" class="text-center py-4">
              <div class="spinner-border text-success"></div>
            </div>
            <div v-else-if="campaignDetails">
              <div class="row g-3 mb-3">
                <div class="col-md-3">
                  <div class="p-3 bg-light rounded text-center">
                    <div class="text-muted small">Total animaux</div>
                    <h4 class="fw-bold">{{ campaignDetails.totalAnimaux || 0 }}</h4>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="p-3 rounded text-center" style="background:#dcfce7;">
                    <div class="text-muted small">Vaccinés</div>
                    <h4 class="fw-bold text-success">{{ campaignDetails.vaccinés || 0 }}</h4>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="p-3 rounded text-center" style="background:#fef3c7;">
                    <div class="text-muted small">En attente</div>
                    <h4 class="fw-bold text-warning">{{ campaignDetails.enAttente || 0 }}</h4>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="p-3 rounded text-center" style="background:#dbeafe;">
                    <div class="text-muted small">Couverture</div>
                    <h4 class="fw-bold text-primary">{{ coverageRate(campaignDetails) }}%</h4>
                  </div>
                </div>
              </div>

              <div class="table-responsive">
                <table class="table">
                  <thead>
                  <tr>
                    <th>ANIMAL</th>
                    <th>ESPÈCE</th>
                    <th>FERME</th>
                    <th>VÉTÉRINAIRE</th>
                    <th>DATE VACCINATION</th>
                    <th>STATUT</th>
                  </tr>
                  </thead>
                  <tbody>
                  <tr v-for="p in campaignDetails.participations" :key="p.id">
                    <td class="fw-semibold">{{ p.animalRfid || '—' }}</td>
                    <td>{{ p.animalSpecies || '—' }}</td>
                    <td>{{ p.farmName || '—' }}</td>
                    <td>{{ p.veterinarian || '—' }}</td>
                    <td>{{ formatDate(p.vaccinationDate) }}</td>
                    <td>
                        <span class="badge" :class="participationBadge(p.status)">
                          {{ formatParticipationStatus(p.status) }}
                        </span>
                    </td>
                  </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" @click="selectedCampaign = null">Fermer</button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="toast" class="position-fixed bottom-0 end-0 p-3" style="z-index:9999;">
      <div class="toast show bg-success text-white">
        <div class="toast-body">{{ toast }}</div>
      </div>
    </div>

  </AdminLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import StatCard from "@/components/common/StatCard.vue";
import AdminLayout from "@/layouts/AdminLayout.vue";
import TablePagination from "@/components/common/TablePagination.vue";
import {formatDate} from "../utils/formatters.js";
import {usePagination} from "@/composables/usePagination.js";
import api from "@/api/axios.js";

const loading = ref(true)
const saving = ref(false)
const loadingDetails = ref(false)
const campaigns = ref([])
const showCreateModal = ref(false)
const selectedCampaign = ref(null)
const campaignDetails = ref(null)
const createError = ref('')
const toast = ref('')

const form = ref({
  name: '', vaccineName: '', targetSpecies: 'ALL',
  startDate: '', endDate: '', description: ''
})

const {
  currentPage, perPage, totalPages,
  paginatedItems: paginatedCampaigns,
  from, to, visiblePages, goToPage, changePerPage
} = usePagination(campaigns)

onMounted(() => loadCampaigns())

async function loadCampaigns() {
  loading.value = true
  try {
    const res = await api.get('/admin/campaigns')
    campaigns.value = res.data || []
  } catch (e) { console.error(e) }
  finally { loading.value = false }
}

function openCreate() {
  createError.value = ''
  form.value = { name: '', vaccineName: '', targetSpecies: 'ALL', startDate: '', endDate: '', description: '' }
  showCreateModal.value = true
}

async function createCampaign() {
  createError.value = ''
  if (!form.value.name || !form.value.startDate || !form.value.endDate) {
    createError.value = 'Nom, date de début et date de fin sont obligatoires.'
    return
  }
  saving.value = true
  try {
    const res = await api.post('/admin/campaigns', form.value)
    showToast(res.data?.message || 'Campagne créée')
    showCreateModal.value = false
    await loadCampaigns()
  } catch (e) { createError.value = e.response?.data?.message || 'Erreur' }
  finally { saving.value = false }
}

async function openDetails(campaign) {
  selectedCampaign.value = campaign
  campaignDetails.value = null
  loadingDetails.value = true
  try {
    const res = await api.get(`/admin/campaigns/${campaign.id}`)
    campaignDetails.value = res.data
  } catch (e) { console.error(e) }
  finally { loadingDetails.value = false }
}

async function changeStatus(campaign, status) {
  try {
    await api.put(`/admin/campaigns/${campaign.id}/status`, { status })
    campaign.status = status
    showToast('Statut mis à jour')
  } catch (e) { alert(e.response?.data?.message || 'Erreur') }
}

async function deleteCampaign(campaign) {
  if (!confirm(`Supprimer la campagne "${campaign.name}" ?`)) return
  try {
    await api.delete(`/admin/campaigns/${campaign.id}`)
    campaigns.value = campaigns.value.filter(c => c.id !== campaign.id)
    showToast('Campagne supprimée')
  } catch (e) { alert(e.response?.data?.message || 'Erreur') }
}

function countByStatus(status) { return campaigns.value.filter(c => c.status === status).length }
function coverageRate(details) {
  if (!details || !details.totalAnimaux || details.totalAnimaux === 0) return 0
  return Math.round((details.vaccinés / details.totalAnimaux) * 100)
}
function statusBadge(status) { return { PLANNED: 'bg-warning text-dark', ACTIVE: 'bg-success', COMPLETED: 'bg-primary', CANCELLED: 'bg-danger' }[status] || 'bg-secondary' }
function participationBadge(status) { return { PENDING: 'bg-warning text-dark', DONE: 'bg-success', REFUSED: 'bg-danger' }[status] || 'bg-secondary' }
function formatCampaignStatus(status) { return { PLANNED: 'Planifiée', ACTIVE: 'En cours', COMPLETED: 'Terminée', CANCELLED: 'Annulée' }[status] || status }
function formatParticipationStatus(status) { return { PENDING: 'En attente', DONE: 'Vacciné', REFUSED: 'Refusé' }[status] || status }
function formatSpecies(species) { return { ALL: 'Toutes espèces', OVIN: 'Ovins', BOVIN: 'Bovins' }[species] || species }
function showToast(msg) { toast.value = msg; setTimeout(() => { toast.value = '' }, 3000) }
</script>