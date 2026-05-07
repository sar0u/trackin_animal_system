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
          <div class="kpi-footer green">+12% vs mois dernier</div>
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
.movements-container {
  padding: 30px;
  background-color: #f8fafc;
  min-height: 100vh;
  font-family: 'Inter', sans-serif;
}

.title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.title-row h1 { color: #0f172a; font-size: 24px; font-weight: 800; margin: 0; }
.subtitle { color: #64748b; font-size: 14px; }

.btn-export {
  background-color: #22c55e;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: 0.3s;
}

.kpi-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.kpi-card {
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  border-top: 4px solid #22c55e;
}

.kpi-label { font-size: 11px; font-weight: 700; color: #94a3b8; }
.kpi-value { font-size: 24px; font-weight: 800; color: #0f172a; margin: 8px 0; }
.kpi-bar-bg { height: 6px; background: #f1f5f9; border-radius: 3px; }
.kpi-bar { height: 100%; border-radius: 3px; }
.kpi-bar.green { background: #22c55e; }
.kpi-bar.yellow { background: #eab308; }
.kpi-bar.red { background: #ef4444; }

/* FILTRES CORRIGÉS */
.filters-bar {
  display: flex;
  align-items: flex-end; /* Aligne les champs sur le bas */
  gap: 20px;
  margin-bottom: 25px;
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}

.search-box {
  flex: 2;
  position: relative;
}

.search-box i {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #94a3b8;
}

.search-box input {
  width: 100%;
  padding: 12px 12px 12px 40px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
}

.date-filters {
  display: flex;
  gap: 10px;
}

.date-input-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.date-input-group label {
  font-size: 11px;
  font-weight: 700;
  color: #94a3b8;
  text-transform: uppercase;
}

.filter-date {
  padding: 10px;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  background: #f8fafc;
  font-size: 13px;
  color: #1e293b;
}

.filter-select {
  padding: 11px;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  color: #475569;
  min-width: 160px;
  background: #f8fafc;
}

/* TABLE */
.registry-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
}

.movement-table {
  width: 100%;
  border-collapse: collapse;
}

.movement-table th {
  background: #f8fafc;
  padding: 15px;
  font-size: 12px;
  color: #64748b;
  text-transform: uppercase;
  text-align: left;
}

.movement-table td {
  padding: 15px;
  border-bottom: 1px solid #f1f5f9;
  font-size: 14px;
  color: #1e293b;
}

.mvt-id { font-weight: 700; color: #22c55e; }

.status-badge {
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
}

.status-badge.approved { background: #dcfce7; color: #15803d; }
.status-badge.pending { background: #fef9c3; color: #a16207; }
.status-badge.rejected { background: #fee2e2; color: #b91c1c; }

.btn-info {
  background: #f0fdf4;
  border: 1px solid #22c55e;
  color: #22c55e;
  width: 32px;
  height: 32px;
  border-radius: 6px;
  cursor: pointer;
}

.btn-info:hover { background: #22c55e; color: white; }

/* MODAL */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex; justify-content: center; align-items: center;
  z-index: 1000;
}

.modal-content { background: white; border-radius: 12px; width: 400px; overflow: hidden; }
.modal-header { background: #f8fafc; padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; }
.modal-header h2 { font-size: 16px; margin: 0; }
.modal-body { padding: 20px; }
.info-block { margin-bottom: 15px; }
.info-block label { display: block; font-size: 12px; font-weight: 700; color: #64748b; margin-bottom: 5px; }
.info-block p { background: #f1f5f9; padding: 10px; border-radius: 6px; margin: 0; font-size: 14px; }
.note-block p { background: #fffbeb; border-left: 4px solid #f59e0b; }
.close-btn { background: none; border: none; font-size: 24px; cursor: pointer; color: #94a3b8; }
</style>