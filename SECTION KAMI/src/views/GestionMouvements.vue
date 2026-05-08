<template>
  <div class="movements-container">
    <div class="header-section">
      <div class="title-row">
        <div>
          <h1>Gestion des Mouvements Nationaux</h1>
          <p class="subtitle">Supervision en temps réel de l'intégrité biologique du territoire.</p>
        </div>
      </div>

      <div class="kpi-grid">
        <div class="kpi-card">
          <span class="kpi-label">TOTAL CE MOIS</span>
          <div class="kpi-value">{{ movements.length }}</div>

        </div>
        <div class="kpi-card">
          <span class="kpi-label">EN ATTENTE</span>
          <div class="kpi-value">{{ pendingCount }}</div>
          <div class="kpi-bar-bg"><div class="kpi-bar yellow" :style="{width: (movements.length ? (pendingCount/movements.length)*100 : 0) + '%'}"></div></div>
        </div>
        <div class="kpi-card">
          <span class="kpi-label">REJETÉS (FRAUDE)</span>
          <div class="kpi-value">{{ rejectedCount }}</div>
          <div class="kpi-bar-bg"><div class="kpi-bar red" :style="{width: (movements.length ? (rejectedCount/movements.length)*100 : 0) + '%'}"></div></div>
        </div>
        <div class="kpi-card">
          <span class="kpi-label">TAUX DE CONFORMITÉ</span>
          <div class="kpi-value">{{ complianceRate }}%</div>
          <div class="kpi-bar-bg"><div class="kpi-bar green" :style="{width: complianceRate + '%'}"></div></div>
        </div>
      </div>
    </div>

    <div class="filters-bar">
      <div class="search-box">
        <i class="fas fa-search"></i>
        <input type="text" v-model="searchQuery" placeholder="Rechercher un ID Animal ou une Ferme...">
      </div>

      <div class="date-filters">
        <div class="date-input-group">
          <label>Du</label>
          <input type="date" v-model="startDate" class="filter-date">
        </div>
        <div class="date-input-group">
          <label>Au</label>
          <input type="date" v-model="endDate" class="filter-date">
        </div>
      </div>

      <select v-model="statusFilter" class="filter-select">
        <option value="">Tous les statuts</option>
        <option value="APPROVED">Approuvé</option>
        <option value="PENDING">En attente</option>
        <option value="REJECTED">Rejeté</option>
      </select>
    </div>

    <div class="registry-card">
      <table class="movement-table">
        <thead>
          <tr>
            <th>ID MOUVEMENT</th>
            <th>ID ANIMAL</th>
            <th>Départ</th>
            <th>Destination</th>
            <th>RAISON</th>
            <th>DATE</th>
            <th>STATUT</th>
            <th>INFOS</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="mvt in filteredMovements" :key="mvt.id">
            <td class="mvt-id">#MV-{{ mvt.id }}</td>
            <td class="animal-id">#{{ mvt.animalId }}</td>
            <td>{{ mvt.originFarmName }}</td>
            <td>{{ mvt.destinationFarmName }}</td>
            <td><span class="badge-reason">{{ mvt.reason }}</span></td>
            <td>{{ formatDate(mvt.departureDate) }}</td>
            <td>
              <span class="status-badge" :class="mvt.status.toLowerCase()">
                {{ translateStatus(mvt.status) }}
              </span>
            </td>
            <td>
                <button class="btn-info" @click="openMvtDetails(mvt)">
                  <i class="fas fa-info-circle"></i>
                </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="showMvtModal" class="modal-overlay" @click.self="showMvtModal = false">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Détails d'Approbation #MV-{{ selectedMvt.id }}</h2>
          <button class="close-btn" @click="showMvtModal = false">&times;</button>
        </div>
        <div class="modal-body">
          <div class="info-block">
            <label><i class="fas fa-user-check"></i> Traité par :</label>
            <p>{{ selectedMvt.processedBy || 'En attente de traitement' }}</p>
          </div>
          <div class="info-block note-block">
            <label><i class="fas fa-sticky-note"></i> Note de l'agent :</label>
            <p>{{ selectedMvt.adminNote || 'Aucune note particulière.' }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '../services/api';

const movements = ref([]);
const searchQuery = ref('');
const statusFilter = ref('');
const startDate = ref('');
const endDate = ref('');
const showMvtModal = ref(false);
const selectedMvt = ref(null);

onMounted(async () => {
  try {
    const res = await api.get('/movements');
    movements.value = res.data;
  } catch (err) {
    console.error("Erreur chargement mouvements", err);
  }
});

const filteredMovements = computed(() => {
  return movements.value.filter(m => {
    // 1. Recherche texte
    const matchesSearch = m.animalId.toString().includes(searchQuery.value) ||
                          m.originFarmName.toLowerCase().includes(searchQuery.value.toLowerCase());

    // 2. Filtre Statut
    const matchesStatus = !statusFilter.value || m.status === statusFilter.value;

    // 3. Filtre Dates
    const mDate = new Date(m.departureDate).setHours(0,0,0,0);
    const start = startDate.value ? new Date(startDate.value).setHours(0,0,0,0) : null;
    const end = endDate.value ? new Date(endDate.value).setHours(0,0,0,0) : null;

    let matchesDate = true;
    if (start && mDate < start) matchesDate = false;
    if (end && mDate > end) matchesDate = false;

    return matchesSearch && matchesStatus && matchesDate;
  });
});

const pendingCount = computed(() => movements.value.filter(m => m.status === 'PENDING').length);
const rejectedCount = computed(() => movements.value.filter(m => m.status === 'REJECTED').length);
const complianceRate = computed(() => {
  if (!movements.value.length) return 0;
  return (((movements.value.length - rejectedCount.value) / movements.value.length) * 100).toFixed(1);
});

const formatDate = (date) => new Date(date).toLocaleDateString('fr-FR');
const translateStatus = (s) => ({ 'APPROVED': 'APPROUVÉ', 'PENDING': 'EN ATTENTE', 'REJECTED': 'REJETÉ' }[s] || s);

const openMvtDetails = (mvt) => {
  selectedMvt.value = mvt;
  showMvtModal.value = true;
};

const exportData = () => {
  console.log("Exportation des données filtrées...");
};
</script>

<style scoped>
/* ==========================================================================
   1. STRUCTURE & BASE
   ========================================================================== */
.movements-container {
  padding: 30px;
  background-color: #f4f7f6;
  min-height: 100vh;
  font-family: 'Inter', sans-serif;
  color: #1e293b;
}

.title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.title-row h1 {
  color: #0f172a;
  font-size: 26px;
  font-weight: 900;
  margin: 0;
  letter-spacing: -0.5px;
}

.subtitle {
  color: #64748b;
  font-size: 14px;
  margin-top: 5px;
}

.btn-export {
  background-color: #0B5D1E;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: 0.3s;
}

.btn-export:hover {
  background-color: #063B16;
}

/* ==========================================================================
   2. KPI CARDS (Mêmes dimensions que le dashboard)
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

.kpi-card:nth-child(1) { border-left-color: #4CAF50; }
.kpi-card:nth-child(2) { border-left-color: #FF9800; }
.kpi-card:nth-child(3) { border-left-color: #F44336; }
.kpi-card:nth-child(4) { border-left-color: #0B5D1E; }

.kpi-label {
  font-size: 10px;
  font-weight: 800;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 4px;
  display: block;
}

.kpi-value {
  font-size: 24px;
  font-weight: 900;
  color: #0f172a;
  margin: 4px 0;
  line-height: 1;
}

.kpi-footer {
  font-size: 11px;
  font-weight: 600;
  margin-top: 8px;
}

.kpi-footer.green {
  color: #4CAF50;
}

.kpi-bar-bg {
  height: 6px;
  background: rgba(11, 93, 30, 0.08);
  border-radius: 3px;
  margin-top: 8px;
}

.kpi-bar {
  height: 100%;
  border-radius: 3px;
  transition: width 1s ease-out;
}

.kpi-bar.green { background: #4CAF50; }
.kpi-bar.yellow { background: #FF9800; }
.kpi-bar.red { background: #F44336; }

/* ==========================================================================
   3. FILTRES (Alignés proprement avec distances égales)
   ========================================================================== */
.filters-bar {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 25px;
  background: white;
  padding: 20px 25px;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  border: 1px solid rgba(11, 93, 30, 0.08);
  flex-wrap: wrap;
}

.search-box {
  flex: 2;
  position: relative;
  min-width: 250px;
}

.search-box i {
  position: absolute;
  left: 14px;
  top: 50%;
  transform: translateY(-50%);
  color: #0B5D1E;
  opacity: 0.6;
  font-size: 14px;
}

.search-box input {
  width: 100%;
  padding: 10px 14px 10px 42px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  font-size: 14px;
  background: rgba(11, 93, 30, 0.03);
  color: #063B16;
  outline: none;
  height: 44px;
  box-sizing: border-box;
}

.search-box input::placeholder {
  color: #0B5D1E;
  opacity: 0.5;
}

.search-box input:focus {
  border-color: #0B5D1E;
  background: white;
  box-shadow: 0 0 0 3px rgba(11, 93, 30, 0.1);
}

.date-filters {
  display: flex;
  gap: 16px;
  align-items: center;
}

.date-input-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.date-input-group label {
  font-size: 12px;
  font-weight: 700;
  color: #0B5D1E;
  text-transform: uppercase;
  white-space: nowrap;
  min-width: 25px;
}

.filter-date {
  padding: 10px 14px;
  border-radius: 8px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  background: white;
  font-size: 13px;
  color: #063B16;
  height: 44px;
  box-sizing: border-box;
  width: 160px;
}

.filter-date:focus {
  border-color: #0B5D1E;
  outline: none;
  box-shadow: 0 0 0 3px rgba(11, 93, 30, 0.1);
}

.filter-select {
  padding: 10px 14px;
  border-radius: 8px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  color: #063B16;
  min-width: 180px;
  background: white;
  font-size: 14px;
  font-weight: 600;
  height: 44px;
  box-sizing: border-box;
  cursor: pointer;
}

.filter-select:focus {
  border-color: #0B5D1E;
  outline: none;
  box-shadow: 0 0 0 3px rgba(11, 93, 30, 0.1);
}

/* ==========================================================================
   4. TABLEAU
   ========================================================================== */
.registry-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  border: 1px solid rgba(11, 93, 30, 0.08);
}

.movement-table {
  width: 100%;
  border-collapse: collapse;
}

.movement-table th {
  background: rgba(11, 93, 30, 0.03);
  padding: 14px 20px;
  font-size: 11px;
  color: #0B5D1E;
  text-transform: uppercase;
  text-align: left;
  font-weight: 800;
  letter-spacing: 0.5px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
}

.movement-table td {
  padding: 16px 20px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.05);
  font-size: 14px;
  color: #1e293b;
}

.movement-table tr:hover {
  background-color: rgba(11, 93, 30, 0.03);
}

.mvt-id {
  font-weight: 700;
  color: #0B5D1E;
  font-family: 'JetBrains Mono', monospace;
}

.animal-id {
  font-family: 'JetBrains Mono', monospace;
  color: #2196F3;
  font-weight: 600;
}

.badge-reason {
  background: rgba(11, 93, 30, 0.08);
  color: #063B16;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
}

/* Badges de Statut */
.status-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
}

.status-badge.approved {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

.status-badge.pending {
  background: rgba(255, 152, 0, 0.1);
  color: #FF9800;
}

.status-badge.rejected {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

.btn-info {
  background: rgba(11, 93, 30, 0.08);
  border: 1px solid rgba(11, 93, 30, 0.2);
  color: #0B5D1E;
  width: 32px;
  height: 32px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-info:hover {
  background: #0B5D1E;
  color: white;
  border-color: #0B5D1E;
}

/* ==========================================================================
   5. PAGINATION
   ========================================================================== */
.pagination-footer {
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(11, 93, 30, 0.02);
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
   6. MODALE
   ========================================================================== */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(6, 59, 22, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.modal-content {
  background: white;
  border-radius: 12px;
  width: 400px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0,0,0,0.2);
}

.modal-header {
  background: rgba(11, 93, 30, 0.03);
  padding: 15px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
}

.modal-header h2 {
  font-size: 16px;
  margin: 0;
  font-weight: 800;
  color: #063B16;
}

.modal-body {
  padding: 20px;
}

.info-block {
  margin-bottom: 15px;
}

.info-block label {
  display: block;
  font-size: 12px;
  font-weight: 700;
  color: #64748b;
  margin-bottom: 5px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.info-block label i {
  color: #0B5D1E;
}

.info-block p {
  background: rgba(11, 93, 30, 0.03);
  padding: 10px;
  border-radius: 6px;
  margin: 0;
  font-size: 14px;
  color: #063B16;
}

.note-block p {
  background: rgba(255, 152, 0, 0.05);
  border-left: 4px solid #FF9800;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #0B5D1E;
  width: 32px;
  height: 32px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.close-btn:hover {
  background: rgba(11, 93, 30, 0.1);
}

/* ==========================================================================
   7. RESPONSIVE
   ========================================================================== */
@media (max-width: 1200px) {
  .kpi-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .filters-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .search-box {
    min-width: 100%;
  }
}
</style>