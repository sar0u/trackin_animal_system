<template>
  <div class="page-container">
    <div class="page-header">
      <div>
        <h1>Campagnes Sanitaires</h1>
        <p class="subtitle">Gestion des campagnes de vaccination et suivi des participations du cheptel.</p>
      </div>
      <button class="btn-add" @click="openAddModal">
        <i class="fas fa-plus"></i> Nouvelle campagne
      </button>
    </div>

    <p v-if="loadError" class="api-error-banner">{{ loadError }}</p>

    <div class="kpi-grid">
      <div class="kpi-card">
        <span class="kpi-label">TOTAL CAMPAGNES</span>
        <div class="kpi-value">{{ campaigns.length }}</div>
      </div>
      <div class="kpi-card kpi-blue">
        <span class="kpi-label">ACTIVES</span>
        <div class="kpi-value">{{ activeCampaigns }}</div>
      </div>
      <div class="kpi-card kpi-green">
        <span class="kpi-label">TERMINÉES</span>
        <div class="kpi-value">{{ completedCampaigns }}</div>
      </div>
      <div class="kpi-card kpi-yellow">
        <span class="kpi-label">PLANIFIÉES</span>
        <div class="kpi-value">{{ plannedCampaigns }}</div>
      </div>
    </div>

    <div class="filters-bar">
      <div class="search-box">
        <i class="fas fa-search"></i>
        <input type="text" v-model="searchQuery" placeholder="Rechercher par nom ou vaccin...">
      </div>
      <select v-model="filterStatus" class="filter-select">
        <option value="">Tous les statuts</option>
        <option value="Planned">Planifiée</option>
        <option value="Active">Actifs</option>
        <option value="Completed">Complétée</option>
        <option value="Cancelled">Annulée</option>
      </select>
      <select v-model="filterSpecies" class="filter-select">
        <option value="">Toutes les espèces</option>
        <option value="Ovin">Ovin</option>
        <option value="Bovin">Bovin</option>
        <option value="Caprin">Caprin</option>
        <option value="All">Toutes</option>
      </select>
    </div>

    <div class="campaigns-grid" v-if="!isLoading">
      <div v-if="filteredCampaigns.length === 0" class="empty-state">
        <i class="fas fa-syringe"></i>
        <p>Aucune campagne trouvée.</p>
      </div>
      <div class="campaign-card" v-for="campaign in filteredCampaigns" :key="campaign.id">
        <div class="campaign-header">
          <div class="campaign-title">
            <h3>{{ campaign.name }}</h3>
            <span class="badge" :class="getStatusClass(campaign.status)">{{ translateStatus(campaign.status) }}</span>
          </div>
          <span class="campaign-id">#CMP-{{ campaign.id }}</span>
        </div>
        <div class="campaign-meta">
          <div class="meta-item" v-if="campaign.vaccineName">
            <i class="fas fa-syringe"></i> {{ campaign.vaccineName }}
          </div>
          <div class="meta-item">
            <i class="fas fa-paw"></i> {{ campaign.targetSpecies || 'Toutes espèces' }}
          </div>
          <div class="meta-item">
            <i class="far fa-calendar-alt"></i> {{ formatDate(campaign.startDate) }} → {{ formatDate(campaign.endDate) }}
          </div>
          <div class="meta-item" v-if="campaign.createdAt">
            <i class="fas fa-clock"></i> Créée le {{ formatDate(campaign.createdAt) }}
          </div>
        </div>
        <p class="campaign-description" v-if="campaign.description">{{ campaign.description }}</p>
        <div class="campaign-footer">
          <span class="created-by" v-if="campaign.createdBy">
            <i class="fas fa-user"></i> {{ getCampaignCreator(campaign) }}
          </span>
          <div class="footer-actions">
            <button class="btn-edit" @click="openEditModal(campaign)">
              <i class="fas fa-pen"></i> Modifier
            </button>
            <button class="btn-details" @click="openModal(campaign)">
              <i class="fas fa-list-ul"></i> Participations
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-else class="loading-state">
      <i class="fas fa-circle-notch fa-spin"></i> Chargement des campagnes...
    </div>

    <div v-if="showAddModal" class="modal-overlay" @click.self="closeAddModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>{{ isEditMode ? 'Modifier la campagne' : 'Nouvelle Campagne Sanitaire' }}</h2>
          <button class="btn-close" @click="closeAddModal">&times;</button>
        </div>
        <form @submit.prevent="saveCampaign" class="modal-form" novalidate>
          <div class="form-group">
            <label>Nom de la campagne <span class="required">*</span></label>
            <input v-model="campaignForm.name" type="text" :class="{ 'input-error': formErrors.name }" placeholder="Ex : Campagne FMD 2026">
            <span v-if="formErrors.name" class="field-error">{{ formErrors.name }}</span>
          </div>
          <div class="form-group">
            <label>Description</label>
            <textarea v-model="campaignForm.description" rows="3" placeholder="Description de la campagne..."></textarea>
          </div>
          <div class="form-group">
            <label>Nom du vaccin</label>
            <input v-model="campaignForm.vaccineName" type="text" placeholder="Ex : Aftovax">
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Espèce cible</label>
              <select v-model="campaignForm.targetSpecies">
                <option value="All">Toutes</option>
                <option value="Ovin">Ovin</option>
                <option value="Bovin">Bovin</option>
                <option value="Caprin">Caprin</option>
                <option value="Autre">Autre</option>
              </select>
            </div>
            <div class="form-group">
              <label>Statut</label>
              <select v-model="campaignForm.status">
                <option value="Planned">Planifiée</option>
                <option value="Active">Actifs</option>
                <option value="Completed">Complétée</option>
                <option value="Cancelled">Annulée</option>
              </select>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Date de début <span class="required">*</span></label>
              <input v-model="campaignForm.startDate" type="date" :class="{ 'input-error': formErrors.startDate }">
              <span v-if="formErrors.startDate" class="field-error">{{ formErrors.startDate }}</span>
            </div>
            <div class="form-group">
              <label>Date de fin <span class="required">*</span></label>
              <input v-model="campaignForm.endDate" type="date" :class="{ 'input-error': formErrors.endDate }">
              <span v-if="formErrors.endDate" class="field-error">{{ formErrors.endDate }}</span>
            </div>
          </div>
          <p v-if="saveError" class="api-error-banner" style="margin-top:8px;">{{ saveError }}</p>
          <div class="modal-actions">
            <button type="button" class="btn-cancel" @click="closeAddModal">Annuler</button>
            <button type="submit" class="btn-confirm" :disabled="isSaving">
              <i class="fas fa-save"></i> {{ isSaving ? 'Enregistrement...' : (isEditMode ? 'Enregistrer' : 'Créer la campagne') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="showModal && selectedCampaign" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>{{ selectedCampaign.name }} <span class="badge" :class="getStatusClass(selectedCampaign.status)">{{ translateStatus(selectedCampaign.status) }}</span></h2>
          <button class="btn-close" @click="closeModal">&times;</button>
        </div>
        <div class="modal-body">
          <div class="detail-grid">
            <div class="detail-item"><span class="detail-label">Vaccin</span><span class="detail-value">{{ selectedCampaign.vaccineName || '—' }}</span></div>
            <div class="detail-item"><span class="detail-label">Espèce cible</span><span class="detail-value">{{ selectedCampaign.targetSpecies || '—' }}</span></div>
            <div class="detail-item"><span class="detail-label">Début</span><span class="detail-value">{{ formatDate(selectedCampaign.startDate) }}</span></div>
            <div class="detail-item"><span class="detail-label">Fin</span><span class="detail-value">{{ formatDate(selectedCampaign.endDate) }}</span></div>
          </div>

          <div v-if="isLoadingParticipations" class="loading-state">
            <i class="fas fa-circle-notch fa-spin"></i> Chargement des participations...
          </div>
          <div v-else>
            <h4 class="participations-title">
              <i class="fas fa-list-check"></i> Participations ({{ participations.length }})
            </h4>
            <div v-if="participations.length === 0" class="empty-participations">
              Aucune participation enregistrée.
            </div>
            <table v-else class="participation-table">
              <thead>
              <tr>
                <th>ID</th>
                <th>ANIMAL</th>
                <th>DATE VACCINATION</th>
                <th>STATUT</th>
                <th>VÉTÉRINAIRE</th>
                <th>NOTES</th>
              </tr>
              </thead>
              <tbody>
              <tr v-for="p in participations" :key="p.id">
                <td>#PRT-{{ p.id }}</td>
                <td>#ANI-{{ p.animal?.id || '--' }}</td>
                <td>{{ formatDate(p.vaccinationDate) }}</td>
                <td><span class="badge" :class="getParticipationStatusClass(p.status)">{{ translateParticipationStatus(p.status) }}</span></td>
                <td>{{ getVetName(p) }}</td>
                <td class="notes-cell">{{ p.notes || '—' }}</td>
              </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import api from '../services/api';

const campaigns = ref([]);
const participations = ref([]);
const isLoading = ref(true);
const isLoadingParticipations = ref(false);
const loadError = ref('');
const searchQuery = ref('');
const filterStatus = ref('');
const filterSpecies = ref('');
const showModal = ref(false);
const selectedCampaign = ref(null);
const showAddModal = ref(false);
const isEditMode = ref(false);
const editingId = ref(null);
const isSaving = ref(false);
const saveError = ref('');
const formErrors = ref({});
const campaignForm = ref({ name: '', description: '', vaccineName: '', targetSpecies: 'All', status: 'Planned', startDate: '', endDate: '' });

onMounted(async () => {
  try {
    const res = await api.get('/sanitary-campaigns');
    campaigns.value = Array.isArray(res.data) ? res.data : [];
  } catch (err) {
    loadError.value = err.response?.data?.message || err.message || 'Impossible de charger les campagnes.';
    campaigns.value = [];
  } finally {
    isLoading.value = false;
  }
});

const filteredCampaigns = computed(() => {
  const q = searchQuery.value.toLowerCase();
  return campaigns.value.filter(c => {
    const matchSearch = !q || c.name?.toLowerCase().includes(q) || (c.vaccineName || '').toLowerCase().includes(q);
    const matchStatus = !filterStatus.value || c.status === filterStatus.value;
    const matchSpecies = !filterSpecies.value || c.targetSpecies === filterSpecies.value;
    return matchSearch && matchStatus && matchSpecies;
  });
});

const activeCampaigns = computed(() => campaigns.value.filter(c => c.status === 'Active').length);
const completedCampaigns = computed(() => campaigns.value.filter(c => c.status === 'Completed').length);
const plannedCampaigns = computed(() => campaigns.value.filter(c => c.status === 'Planned').length);

const openModal = async (campaign) => {
  selectedCampaign.value = campaign;
  showModal.value = true;
  isLoadingParticipations.value = true;
  try {
    const res = await api.get(`/campaign-participations/campaign/${campaign.id}`);
    participations.value = Array.isArray(res.data) ? res.data : [];
  } catch {
    participations.value = [];
  } finally {
    isLoadingParticipations.value = false;
  }
};

const closeModal = () => {
  showModal.value = false;
  selectedCampaign.value = null;
  participations.value = [];
};

const openAddModal = () => {
  isEditMode.value = false;
  editingId.value = null;
  campaignForm.value = { name: '', description: '', vaccineName: '', targetSpecies: 'All', status: 'Planned', startDate: '', endDate: '' };
  formErrors.value = {};
  saveError.value = '';
  showAddModal.value = true;
};

const openEditModal = (c) => {
  isEditMode.value = true;
  editingId.value = c.id;
  campaignForm.value = {
    name: c.name || '',
    description: c.description || '',
    vaccineName: c.vaccineName || '',
    targetSpecies: c.targetSpecies || 'All',
    status: c.status || 'Planned',
    startDate: c.startDate ? c.startDate.slice(0, 10) : '',
    endDate: c.endDate ? c.endDate.slice(0, 10) : '',
  };
  formErrors.value = {};
  saveError.value = '';
  showAddModal.value = true;
};

const closeAddModal = () => { showAddModal.value = false; };

const validateCampaignForm = () => {
  const errors = {};
  if (!campaignForm.value.name.trim()) errors.name = 'Le nom est obligatoire.';
  if (!campaignForm.value.startDate) errors.startDate = 'La date de début est obligatoire.';
  if (!campaignForm.value.endDate) errors.endDate = 'La date de fin est obligatoire.';
  if (campaignForm.value.startDate && campaignForm.value.endDate && campaignForm.value.endDate < campaignForm.value.startDate)
    errors.endDate = 'La date de fin doit être après la date de début.';
  formErrors.value = errors;
  return Object.keys(errors).length === 0;
};

const saveCampaign = async () => {
  if (!validateCampaignForm()) return;
  isSaving.value = true;
  saveError.value = '';
  try {
    if (isEditMode.value) {
      await api.put(`/sanitary-campaigns/${editingId.value}`, campaignForm.value);
      // Recharger la campagne modifiée pour avoir les données à jour
      const fresh = await api.get(`/sanitary-campaigns/${editingId.value}`);
      const idx = campaigns.value.findIndex(c => c.id === editingId.value);
      if (idx !== -1) campaigns.value[idx] = fresh.data;
    } else {
      const res = await api.post('/sanitary-campaigns', campaignForm.value);
      // Recharger la campagne créée pour avoir createdAt et createdBy depuis la BDD
      const fresh = await api.get(`/sanitary-campaigns/${res.data.id}`);
      campaigns.value.unshift(fresh.data);
    }
    closeAddModal();
  } catch (err) {
    saveError.value = err.response?.data?.message || (isEditMode.value ? 'Erreur lors de la modification.' : 'Erreur lors de la création.');
  } finally {
    isSaving.value = false;
  }
};

const getCampaignCreator = (c) => {
  const u = c.createdBy;
  if (!u) return '—';
  return `${u.firstName || ''} ${u.lastName || ''}`.trim() || u.username || `#${u.id}`;
};

const getVetName = (p) => {
  const v = p.veterinarian;
  if (!v) return '—';
  return `${v.firstName || ''} ${v.lastName || ''}`.trim() || v.username || `#${v.id}`;
};

const translateStatus = (s) => ({ 'Planned': 'Planifiée', 'Active': 'Actifs', 'Completed': 'Complétée', 'Cancelled': 'Annulée' }[s] || s || '--');
const getStatusClass = (s) => ({ 'Planned': 'badge-yellow', 'Active': 'badge-blue', 'Completed': 'badge-green', 'Cancelled': 'badge-gray' }[s] || 'badge-gray');

const translateParticipationStatus = (s) => ({ 'Pending': 'En attente', 'Done': 'Effectuée', 'Refused': 'Refusée' }[s] || s || '--');
const getParticipationStatusClass = (s) => ({ 'Done': 'badge-green', 'Refused': 'badge-red', 'Pending': 'badge-yellow' }[s] || 'badge-gray');

const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : '--';
</script>

<style scoped>
/* ==========================================================================
   1. BASE
   ========================================================================== */
.page-container {
  font-family: 'Inter', sans-serif;
  background: #f4f7f6;
  min-height: 100vh;
  padding: 30px;
  color: #1e293b;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

h1 {
  font-size: 26px;
  font-weight: 900;
  color: #0f172a;
  margin: 0;
  letter-spacing: -0.5px;
}

.subtitle {
  font-size: 14px;
  color: #64748b;
  margin-top: 5px;
}

.api-error-banner {
  background: rgba(244, 67, 54, 0.08);
  color: #F44336;
  padding: 12px 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  font-weight: 600;
  border: 1px solid rgba(244, 67, 54, 0.2);
}

.btn-add {
  background: #0B5D1E;
  color: white;
  border: none;
  padding: 10px 18px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: 0.2s;
  white-space: nowrap;
}

.btn-add:hover {
  background: #063B16;
}

/* ==========================================================================
   2. KPI GRID
   ========================================================================== */
.kpi-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 25px;
}

.kpi-card {
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  border-left: 4px solid transparent;
}

.kpi-card:first-child { border-left-color: #0B5D1E; }
.kpi-blue { border-left-color: #2196F3; }
.kpi-green { border-left-color: #4CAF50; }
.kpi-yellow { border-left-color: #FF9800; }

.kpi-label {
  font-size: 10px;
  font-weight: 800;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  display: block;
  margin-bottom: 4px;
}

.kpi-value {
  font-size: 24px;
  font-weight: 900;
  color: #0f172a;
  line-height: 1;
}

/* ==========================================================================
   3. FILTRES
   ========================================================================== */
.filters-bar {
  display: flex;
  gap: 20px;
  background: white;
  padding: 16px 25px;
  border-radius: 12px;
  margin-bottom: 25px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  flex-wrap: wrap;
  border: 1px solid rgba(11, 93, 30, 0.08);
}

.search-box {
  display: flex;
  align-items: center;
  background: rgba(11, 93, 30, 0.05);
  padding: 8px 16px;
  border-radius: 8px;
  flex: 1;
  min-width: 250px;
}

.search-box i {
  color: #0B5D1E;
  opacity: 0.6;
  margin-right: 10px;
}

.search-box input {
  border: none;
  background: transparent;
  width: 100%;
  outline: none;
  font-size: 14px;
  color: #063B16;
}

.search-box input::placeholder {
  color: #0B5D1E;
  opacity: 0.5;
}

.filter-select {
  padding: 10px 14px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  outline: none;
  background: white;
  color: #063B16;
  font-size: 14px;
  font-weight: 600;
  height: 42px;
  box-sizing: border-box;
}

.filter-select:focus {
  border-color: #0B5D1E;
}

/* ==========================================================================
   4. GRILLE DE CAMPAGNES
   ========================================================================== */
.campaigns-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 20px;
}

.campaign-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  border: 1px solid rgba(11, 93, 30, 0.08);
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.campaign-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.campaign-title {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.campaign-title h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 800;
  color: #0f172a;
}

.campaign-id {
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  color: #94a3b8;
  font-weight: 600;
}

.campaign-meta {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.meta-item {
  font-size: 13px;
  color: #64748b;
  display: flex;
  align-items: center;
  gap: 8px;
}

.meta-item i {
  color: #0B5D1E;
  opacity: 0.6;
  width: 14px;
}

.campaign-description {
  font-size: 13px;
  color: #475569;
  font-style: italic;
  margin: 0;
  line-height: 1.5;
}

.campaign-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 4px;
}

.created-by {
  font-size: 12px;
  color: #94a3b8;
  display: flex;
  align-items: center;
  gap: 6px;
}

.footer-actions {
  display: flex;
  gap: 8px;
}

.btn-edit {
  background: rgba(11, 93, 30, 0.08);
  border: 1px solid rgba(11, 93, 30, 0.2);
  color: #0B5D1E;
  padding: 8px 14px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: 0.2s;
}

.btn-edit:hover {
  background: rgba(11, 93, 30, 0.15);
}

.btn-details {
  background: rgba(33, 150, 243, 0.08);
  border: 1px solid rgba(33, 150, 243, 0.2);
  color: #2196F3;
  padding: 8px 14px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: 0.2s;
}

.btn-details:hover {
  background: rgba(33, 150, 243, 0.15);
}

/* ==========================================================================
   5. BADGES
   ========================================================================== */
.badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  display: inline-block;
  text-transform: uppercase;
}

.badge-blue {
  background: rgba(33, 150, 243, 0.1);
  color: #2196F3;
}

.badge-green {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

.badge-yellow {
  background: rgba(255, 152, 0, 0.1);
  color: #FF9800;
}

.badge-red {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

.badge-gray {
  background: rgba(11, 93, 30, 0.05);
  color: #64748b;
}

/* ==========================================================================
   6. LOADING & EMPTY
   ========================================================================== */
.loading-state {
  text-align: center;
  padding: 40px;
  color: #64748b;
  font-size: 15px;
}

.empty-state {
  grid-column: 1 / -1;
  text-align: center;
  padding: 60px;
  color: #94a3b8;
}

.empty-state i {
  font-size: 40px;
  margin-bottom: 15px;
  display: block;
  color: #0B5D1E;
  opacity: 0.5;
}

/* ==========================================================================
   7. MODALE
   ========================================================================== */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(6, 59, 22, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.modal-content {
  background: white;
  width: 100%;
  max-width: 700px;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
  animation: slideUp 0.3s ease;
  max-height: 85vh;
  overflow-y: auto;
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 25px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  background: rgba(11, 93, 30, 0.02);
  gap: 10px;
  flex-wrap: wrap;
}

.modal-header h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 800;
  color: #063B16;
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.btn-close {
  background: rgba(11, 93, 30, 0.08);
  border: none;
  font-size: 20px;
  color: #0B5D1E;
  cursor: pointer;
  width: 35px;
  height: 35px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: 0.2s;
}

.btn-close:hover {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

.modal-body {
  padding: 25px;
}

/* ==========================================================================
   8. DETAIL GRID
   ========================================================================== */
.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin-bottom: 20px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.detail-label {
  font-size: 11px;
  font-weight: 700;
  color: #0B5D1E;
  text-transform: uppercase;
}

.detail-value {
  font-size: 14px;
  font-weight: 600;
  color: #063B16;
}

.participations-title {
  margin: 0 0 15px 0;
  font-size: 15px;
  font-weight: 800;
  color: #063B16;
  display: flex;
  align-items: center;
  gap: 8px;
  border-top: 1px solid rgba(11, 93, 30, 0.08);
  padding-top: 20px;
}

.empty-participations {
  text-align: center;
  padding: 20px;
  color: #94a3b8;
  font-style: italic;
}

.participation-table {
  width: 100%;
  border-collapse: collapse;
}

.participation-table th {
  text-align: left;
  padding: 10px 15px;
  font-size: 11px;
  font-weight: 800;
  color: #0B5D1E;
  text-transform: uppercase;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  background: rgba(11, 93, 30, 0.03);
}

.participation-table td {
  padding: 10px 15px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.05);
  font-size: 13px;
  color: #1e293b;
}

.notes-cell {
  max-width: 180px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  font-style: italic;
  color: #64748b;
}

/* ==========================================================================
   9. FORMULAIRE
   ========================================================================== */
.modal-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 25px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-group label {
  font-size: 12px;
  font-weight: 700;
  color: #063B16;
  text-transform: uppercase;
}

.form-group input, .form-group select, .form-group textarea {
  padding: 9px 12px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  font-size: 14px;
  outline: none;
  background: white;
  font-family: inherit;
  color: #063B16;
}

.form-group input:focus, .form-group select:focus, .form-group textarea:focus {
  border-color: #0B5D1E;
  box-shadow: 0 0 0 3px rgba(11, 93, 30, 0.1);
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.input-error {
  border-color: #F44336 !important;
  background: rgba(244, 67, 54, 0.03);
}

.field-error {
  font-size: 12px;
  color: #F44336;
  font-weight: 600;
}

.required {
  color: #F44336;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  padding-top: 8px;
  border-top: 1px solid rgba(11, 93, 30, 0.08);
  margin-top: 4px;
}

.btn-cancel {
  background: rgba(11, 93, 30, 0.08);
  border: 1px solid rgba(11, 93, 30, 0.2);
  color: #063B16;
  padding: 9px 18px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-cancel:hover {
  background: rgba(11, 93, 30, 0.15);
}

.btn-confirm {
  background: #0B5D1E;
  border: none;
  color: white;
  padding: 9px 18px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: all 0.2s;
}

.btn-confirm:hover {
  background: #063B16;
}

.btn-confirm:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* ==========================================================================
   10. RESPONSIVE
   ========================================================================== */
@media (max-width: 1200px) {
  .kpi-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .form-row {
    grid-template-columns: 1fr;
  }
}
</style>