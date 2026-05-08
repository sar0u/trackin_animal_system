<template>
  <div class="page-container">
    <div class="page-header">
      <div>
        <h1>Dossiers Santé</h1>
        <p class="subtitle">Suivi des visites vétérinaires, dossiers médicaux et historique de vaccination du cheptel national.</p>
      </div>
    </div>

    <p v-if="loadError" class="api-error-banner">{{ loadError }}</p>

    <div class="kpi-grid">
      <div class="kpi-card">
        <span class="kpi-label">TOTAL DOSSIERS</span>
        <div class="kpi-value">{{ records.length }}</div>
      </div>
      <div class="kpi-card kpi-green">
        <span class="kpi-label">VALIDÉS</span>
        <div class="kpi-value">{{ validatedCount }}</div>
      </div>
      <div class="kpi-card kpi-yellow">
        <span class="kpi-label">EN ATTENTE VALIDATION</span>
        <div class="kpi-value">{{ pendingValidationCount }}</div>
      </div>
      <div class="kpi-card kpi-blue">
        <span class="kpi-label">VACCINATIONS</span>
        <div class="kpi-value">{{ totalVaccinations }}</div>
      </div>
    </div>

    <div class="filters-bar">
      <div class="search-box">
        <i class="fas fa-search"></i>
        <input type="text" v-model="searchQuery" placeholder="Rechercher par ID dossier, ID animal, vétérinaire, diagnostic...">
      </div>
      <select v-model="filterType" class="filter-select">
        <option value="">Tous les types</option>
        <option value="Routine">Routine</option>
        <option value="Emergency">Urgence</option>
        <option value="Vaccination">Vaccination</option>
        <option value="Surgery">Opération</option>
      </select>
      <select v-model="filterValidated" class="filter-select">
        <option value="">Tous</option>
        <option value="true">Validés</option>
        <option value="false">Non validés</option>
      </select>
    </div>

    <div class="table-wrapper">
      <div v-if="isLoading" class="loading-state">
        <i class="fas fa-circle-notch fa-spin"></i> Chargement des dossiers santé...
      </div>
      <table v-else class="data-table">
        <thead>
        <tr>
          <th>ID</th>
          <th>ANIMAL</th>
          <th>TYPE</th>
          <th>VÉTÉRINAIRE</th>
          <th>DATE VISITE</th>
          <th>PROCHAINE VISITE</th>
          <th>DIAGNOSTIC</th>
          <th>VALIDÉ</th>
          <th>DÉTAILS</th>
        </tr>
        </thead>
        <tbody>
        <tr v-if="filteredRecords.length === 0">
          <td colspan="9" class="empty-row">Aucun dossier santé à afficher.</td>
        </tr>
        <tr v-for="record in paginatedRecords" :key="record.id">
          <td class="mono-id">#HR-{{ record.id }}</td>
          <td>
            <span class="mono-id" style="color:#3b82f6;">#ANI-{{ record.animal?.id || '--' }}</span>
            <span class="sub-info">{{ record.animal?.species || '' }}</span>
          </td>
          <td><span class="badge" :class="getTypeClass(record.recordType)">{{ translateRecordType(record.recordType) || '—' }}</span></td>
          <td>{{ getVetName(record) }}</td>
          <td>{{ formatDateTime(record.visitDate) }}</td>
          <td>{{ record.nextVisitDate ? formatDate(record.nextVisitDate) : '—' }}</td>
          <td class="diagnosis-cell">{{ record.diagnosis ? record.diagnosis.substring(0, 50) + (record.diagnosis.length > 50 ? '...' : '') : '—' }}</td>
          <td>
            <span class="badge" :class="record.isValidated ? 'badge-green' : 'badge-yellow'">
              <i :class="record.isValidated ? 'fas fa-check' : 'fas fa-clock'" style="font-size:10px;"></i>
              {{ record.isValidated ? 'Validé' : 'En attente' }}
            </span>
          </td>
          <td>
            <button class="btn-icon" @click="openModal(record)"><i class="fas fa-eye"></i></button>
          </td>
        </tr>
        </tbody>
      </table>

      <div class="pagination-footer">
        <span class="pagination-info">Affichage de {{ paginationStart }} à {{ paginationEnd }} sur {{ filteredRecords.length }} dossiers</span>
        <div class="pagination-controls" v-if="totalPages > 1">
          <button class="btn-nav" :disabled="currentPage === 1" @click="currentPage--"><</button>
          <button class="page-num" v-for="p in totalPages" :key="p" :class="{ active: currentPage === p }" @click="currentPage = p">{{ p }}</button>
          <button class="btn-nav" :disabled="currentPage === totalPages" @click="currentPage++">></button>
        </div>
      </div>
    </div>

    <div v-if="showModal && selectedRecord" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Dossier Santé <span>#HR-{{ selectedRecord.id }}</span></h2>
          <button class="btn-close" @click="closeModal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="detail-section">
            <h4><i class="fas fa-info-circle"></i> Informations Générales</h4>
            <div class="detail-grid">
              <div class="detail-item">
                <span class="detail-label">Animal</span>
                <span class="detail-value mono">#ANI-{{ selectedRecord.animal?.id || '--' }}{{ selectedRecord.animal?.species ? ' (' + selectedRecord.animal.species + ')' : '' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">Type de dossier</span>
                <span class="badge" :class="getTypeClass(selectedRecord.recordType)">{{ selectedRecord.recordType || '—' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">Vétérinaire</span>
                <span class="detail-value">{{ getVetName(selectedRecord) }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">Validé</span>
                <span class="badge" :class="selectedRecord.isValidated ? 'badge-green' : 'badge-yellow'">{{ selectedRecord.isValidated ? 'Oui' : 'Non' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">Date de visite</span>
                <span class="detail-value">{{ formatDateTime(selectedRecord.visitDate) }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">Prochaine visite</span>
                <span class="detail-value">{{ selectedRecord.nextVisitDate ? formatDate(selectedRecord.nextVisitDate) : '—' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">Créé le</span>
                <span class="detail-value">{{ formatDateTime(selectedRecord.createdAt) }}</span>
              </div>
            </div>
          </div>

          <div class="detail-section" v-if="selectedRecord.diagnosis || selectedRecord.symptoms || selectedRecord.treatmentPlan">
            <h4><i class="fas fa-stethoscope"></i> Rapport Médical</h4>
            <div v-if="selectedRecord.diagnosis" class="medical-block">
              <strong>Diagnostic</strong>
              <p>{{ selectedRecord.diagnosis }}</p>
            </div>
            <div v-if="selectedRecord.symptoms" class="medical-block">
              <strong>Symptômes</strong>
              <p>{{ selectedRecord.symptoms }}</p>
            </div>
            <div v-if="selectedRecord.treatmentPlan" class="medical-block">
              <strong>Plan de traitement</strong>
              <p>{{ selectedRecord.treatmentPlan }}</p>
            </div>
          </div>

          <div v-if="selectedRecord.notes" class="detail-section">
            <h4><i class="fas fa-sticky-note"></i> Notes</h4>
            <p class="notes-text">{{ selectedRecord.notes }}</p>
          </div>

          <div class="detail-section">
            <h4><i class="fas fa-syringe"></i> Vaccinations associées</h4>
            <div v-if="isLoadingVaccinations" class="loading-state">
              <i class="fas fa-circle-notch fa-spin"></i> Chargement...
            </div>
            <div v-else-if="vaccinations.length === 0" class="empty-vac">Aucune vaccination enregistrée pour ce dossier.</div>
            <table v-else class="vac-table">
              <thead>
              <tr>
                <th>VACCIN</th>
                <th>TYPE</th>
                <th>FABRICANT</th>
                <th>LOT</th>
                <th>DOSE</th>
                <th>EXPIRATION</th>
                <th>RAPPEL</th>
              </tr>
              </thead>
              <tbody>
              <tr v-for="vac in vaccinations" :key="vac.id">
                <td class="vac-name">{{ vac.vaccineName || '—' }}</td>
                <td>{{ vac.vaccineType || '—' }}</td>
                <td>{{ vac.manufacturer || '—' }}</td>
                <td class="mono-id">{{ vac.batchNumber || '—' }}</td>
                <td>{{ vac.dose || '—' }}</td>
                <td>{{ vac.expirationDate ? formatDate(vac.expirationDate) : '—' }}</td>
                <td>{{ vac.nextDoseDate ? formatDate(vac.nextDoseDate) : '—' }}</td>
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
import { ref, computed, onMounted } from 'vue';
import api from '../services/api';

const records = ref([]);
const isLoading = ref(true);
const loadError = ref('');
const searchQuery = ref('');
const filterType = ref('');
const filterValidated = ref('');
const showModal = ref(false);
const selectedRecord = ref(null);
const vaccinations = ref([]);
const isLoadingVaccinations = ref(false);
const totalVaccinations = ref(0);
const currentPage = ref(1);
const itemsPerPage = 10;

onMounted(async () => {
  try {
    const [recRes, vacRes] = await Promise.all([
      api.get('/health-records'),
      api.get('/vaccinations').catch(() => ({ data: [] }))
    ]);
    records.value = Array.isArray(recRes.data) ? recRes.data : [];
    totalVaccinations.value = Array.isArray(vacRes.data) ? vacRes.data.length : 0;
  } catch (err) {
    loadError.value = err.response?.data?.message || err.message || 'Impossible de charger les dossiers santé.';
    records.value = [];
  } finally {
    isLoading.value = false;
  }
});

const filteredRecords = computed(() => {
  const q = searchQuery.value.toLowerCase();
  return records.value.filter(r => {
    const matchSearch = !q ||
      String(r.id || '').includes(q) ||
      String(r.animal?.id || '').includes(q) ||
      (r.diagnosis || '').toLowerCase().includes(q) ||
      (r.symptoms || '').toLowerCase().includes(q) ||
      getVetName(r).toLowerCase().includes(q);
    const matchType = !filterType.value || r.recordType === filterType.value;
    const matchValidated = !filterValidated.value ||
      (filterValidated.value === 'true' ? r.isValidated : !r.isValidated);
    return matchSearch && matchType && matchValidated;
  });
});

const validatedCount = computed(() => records.value.filter(r => r.isValidated).length);
const pendingValidationCount = computed(() => records.value.filter(r => !r.isValidated).length);

const paginatedRecords = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredRecords.value.slice(start, start + itemsPerPage);
});
const totalPages = computed(() => Math.ceil(filteredRecords.value.length / itemsPerPage));
const paginationStart = computed(() => filteredRecords.value.length === 0 ? 0 : (currentPage.value - 1) * itemsPerPage + 1);
const paginationEnd = computed(() => Math.min(currentPage.value * itemsPerPage, filteredRecords.value.length));

const getVetName = (r) => {
  const v = r.veterinarian;
  if (!v) return '—';
  return `${v.firstName || ''} ${v.lastName || ''}`.trim() || v.username || `#${v.id}`;
};

const translateRecordType = (type) => ({
  'Routine': 'Routine',
  'Emergency': 'Urgence',
  'Vaccination': 'Vaccination',
  'Surgery': 'Opération'
}[type] || type);

const getTypeClass = (type) => ({
  'Routine': 'badge-blue',
  'Emergency': 'badge-red',
  'Vaccination': 'badge-green',
  'Surgery': 'badge-orange'
}[type] || 'badge-gray');

const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : '--';
const formatDateTime = (d) => d ? new Date(d).toLocaleString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : '--';

const openModal = async (record) => {
  selectedRecord.value = record;
  showModal.value = true;
  isLoadingVaccinations.value = true;
  try {
    const res = await api.get(`/vaccinations/record/${record.id}`);
    vaccinations.value = Array.isArray(res.data) ? res.data : [];
  } catch {
    vaccinations.value = [];
  } finally {
    isLoadingVaccinations.value = false;
  }
};

const closeModal = () => {
  showModal.value = false;
  selectedRecord.value = null;
  vaccinations.value = [];
};
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

.kpi-green { border-left-color: #4CAF50; }
.kpi-yellow { border-left-color: #FF9800; }
.kpi-blue { border-left-color: #2196F3; }

/* KPI Total (premier) */
.kpi-card:first-child { border-left-color: #0B5D1E; }

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
  border-radius: 12px 12px 0 0;
  margin-bottom: 0;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  flex-wrap: wrap;
  border: 1px solid rgba(11, 93, 30, 0.08);
  border-bottom: none;
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
   4. TABLEAU
   ========================================================================== */
.table-wrapper {
  background: white;
  border-radius: 0 0 12px 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  overflow: hidden;
  overflow-x: auto;
  border: 1px solid rgba(11, 93, 30, 0.08);
  border-top: none;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
}

th {
  text-align: left;
  padding: 14px 18px;
  font-size: 11px;
  font-weight: 800;
  color: #0B5D1E;
  text-transform: uppercase;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  white-space: nowrap;
  background: rgba(11, 93, 30, 0.03);
  letter-spacing: 0.5px;
}

td {
  padding: 14px 18px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.05);
  font-size: 14px;
  vertical-align: middle;
}

tr:hover td {
  background: rgba(11, 93, 30, 0.02);
}

.empty-row {
  text-align: center;
  color: #94a3b8;
  font-style: italic;
  padding: 30px;
}

.loading-state {
  text-align: center;
  padding: 40px;
  color: #64748b;
  font-size: 14px;
}

.mono-id {
  font-family: 'JetBrains Mono', monospace;
  font-weight: 700;
}

.sub-info {
  display: block;
  font-size: 11px;
  color: #64748b;
  margin-top: 2px;
}

.diagnosis-cell {
  max-width: 180px;
  color: #64748b;
  font-size: 13px;
}

/* ==========================================================================
   5. BADGES
   ========================================================================== */
.badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  display: inline-flex;
  align-items: center;
  gap: 4px;
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

.badge-orange {
  background: rgba(255, 152, 0, 0.1);
  color: #FF9800;
}

.badge-gray {
  background: rgba(11, 93, 30, 0.05);
  color: #64748b;
}

/* ==========================================================================
   6. BOUTON
   ========================================================================== */
.btn-icon {
  background: rgba(11, 93, 30, 0.08);
  border: 1px solid rgba(11, 93, 30, 0.2);
  color: #0B5D1E;
  width: 32px;
  height: 32px;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: 0.2s;
}

.btn-icon:hover {
  background: #0B5D1E;
  color: white;
  border-color: #0B5D1E;
}

/* ==========================================================================
   7. PAGINATION
   ========================================================================== */
.pagination-footer {
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(11, 93, 30, 0.02);
  flex-wrap: wrap;
  gap: 10px;
  border-top: 1px solid rgba(11, 93, 30, 0.08);
}

.pagination-info {
  font-size: 13px;
  color: #64748b;
  font-weight: 600;
}

.pagination-controls {
  display: flex;
  gap: 6px;
}

.btn-nav, .page-num {
  padding: 6px 12px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  background: white;
  font-weight: 700;
  font-size: 13px;
  cursor: pointer;
  color: #063B16;
  transition: all 0.2s;
}

.btn-nav:hover:not(:disabled), .page-num:hover {
  background: rgba(11, 93, 30, 0.1);
}

.page-num.active {
  background: #0B5D1E;
  color: white;
  border-color: #0B5D1E;
}

.btn-nav:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ==========================================================================
   8. MODALE
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
  max-width: 850px;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
  animation: slideUp 0.3s ease;
  max-height: 90vh;
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
}

.modal-header h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 800;
  color: #063B16;
}

.modal-header h2 span {
  color: #0B5D1E;
  font-family: 'JetBrains Mono', monospace;
}

.btn-close {
  background: rgba(11, 93, 30, 0.08);
  border: none;
  font-size: 18px;
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
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* ==========================================================================
   9. DETAIL SECTION
   ========================================================================== */
.detail-section {
  border: 1px solid rgba(11, 93, 30, 0.08);
  border-radius: 12px;
  padding: 20px;
}

.detail-section h4 {
  margin: 0 0 16px 0;
  font-size: 14px;
  font-weight: 800;
  color: #063B16;
  display: flex;
  align-items: center;
  gap: 8px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  padding-bottom: 12px;
}

.detail-section h4 i {
  color: #0B5D1E;
}

.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
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

.detail-value.mono {
  font-family: 'JetBrains Mono', monospace;
  color: #2196F3;
}

.medical-block {
  margin-bottom: 12px;
  padding: 12px;
  background: rgba(11, 93, 30, 0.02);
  border-radius: 8px;
}

.medical-block strong {
  font-size: 11px;
  font-weight: 800;
  color: #0B5D1E;
  text-transform: uppercase;
  display: block;
  margin-bottom: 6px;
}

.medical-block p {
  margin: 0;
  font-size: 14px;
  color: #475569;
  line-height: 1.5;
}

.notes-text {
  font-style: italic;
  color: #475569;
  padding: 12px;
  background: rgba(11, 93, 30, 0.02);
  border-radius: 8px;
  border-left: 4px solid #0B5D1E;
  margin: 0;
}

.empty-vac {
  text-align: center;
  padding: 20px;
  color: #94a3b8;
  font-style: italic;
}

.vac-table {
  width: 100%;
  border-collapse: collapse;
}

.vac-table th {
  text-align: left;
  padding: 8px 12px;
  font-size: 11px;
  font-weight: 800;
  color: #0B5D1E;
  text-transform: uppercase;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  white-space: nowrap;
  background: rgba(11, 93, 30, 0.03);
}

.vac-table td {
  padding: 10px 12px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.05);
  font-size: 13px;
  color: #1e293b;
}

.vac-name {
  font-weight: 700;
  color: #0f172a;
}

/* ==========================================================================
   10. RESPONSIVE
   ========================================================================== */
@media (max-width: 1200px) {
  .kpi-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
