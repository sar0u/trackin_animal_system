<template>
  <div class="movements-container">
    <div class="header-section">
      <div class="title-row">
        <div>
          <h1>Gestion des Mouvements Nationaux</h1>
          <p class="subtitle">Supervision en temps réel de l'intégrité biologique du territoire.</p>
        </div>
      </div>

      <p v-if="loadError" class="api-error-banner">{{ loadError }}</p>

      <div class="kpi-grid">
        <div class="kpi-card">
          <span class="kpi-label">TOTAL CE MOIS</span>
          <div class="kpi-value">{{ movements.length }}</div>
          <div class="kpi-footer" :class="monthTrend.startsWith('-') ? 'red' : 'green'">{{ monthTrend }} vs mois dernier</div>
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
        <input type="text" v-model="searchQuery" placeholder="Rechercher par ID mouvement, ID animal ou ferme...">
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
        <option value="Approved">Approuvé</option>
        <option value="Pending">En attente</option>
        <option value="Rejected">Rejeté</option>
      </select>
    </div>

    <div class="table-wrapper">
      <table class="data-table">
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
        <tr v-if="!isLoading && filteredMovements.length === 0">
          <td colspan="8" class="empty-row">Aucun mouvement à afficher (ou erreur de chargement).</td>
        </tr>
        <tr v-for="mvt in paginatedMovements" :key="mvt.id">
          <td class="mvt-id">#MV-{{ mvt.id }}</td>
          <td class="animal-id">#{{ mvt.animal?.id || '--' }}</td>
          <td>{{ mvt.fromFarm?.name || '--' }}</td>
          <td>{{ mvt.toFarm?.name || '--' }}</td>
          <td><span class="badge-reason">{{ mvt.reason }}</span></td>
          <td>{{ formatDate(mvt.createdAt) }}</td>
          <td>
              <span class="badge" :class="getMvtStatusClass(mvt.approvalStatus)">
                {{ translateStatus(mvt.approvalStatus) }}
              </span>
          </td>
          <td>
            <button class="btn btn-secondary btn-icon-only btn-sm" @click="openMvtDetails(mvt)">
              <i class="fas fa-eye"></i>
            </button>
          </td>
        </tr>
        </tbody>
      </table>

      <!-- PAGINATION -->
      <div class="pagination-bar">
        <span class="pagination-info">
          Affichage de {{ paginationStart }} à {{ paginationEnd }} sur {{ filteredMovements.length }} mouvements
        </span>
        <div class="pagination-controls" v-if="totalPages > 1">
          <button class="page-btn" :disabled="currentPage === 1" @click="prevPage">
            <i class="fas fa-chevron-left"></i>
          </button>
          <button
            v-for="page in pageNumbers"
            :key="page"
            class="page-btn"
            :class="{ active: currentPage === page }"
            :disabled="page === '...'"
            @click="typeof page === 'number' && setPage(page)"
          >
            {{ page }}
          </button>
          <button class="page-btn" :disabled="currentPage === totalPages" @click="nextPage">
            <i class="fas fa-chevron-right"></i>
          </button>
        </div>
      </div>
    </div>

    <div v-if="showMvtModal" class="modal-overlay" @click.self="showMvtModal = false">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Mouvement <span class="mvt-id-header">#MV-{{ selectedMvt.id }}</span></h2>
          <button class="close-btn" @click="showMvtModal = false">&times;</button>
        </div>
        <div class="modal-body">

          <div class="detail-grid">
            <div class="info-block">
              <label><i class="fas fa-paw"></i> Animal</label>
              <p class="mono-val">#ANI-{{ selectedMvt.animal?.id || '--' }}</p>
            </div>
            <div class="info-block">
              <label><i class="fas fa-calendar-alt"></i> Date</label>
              <p>{{ formatDate(selectedMvt.createdAt) }}</p>
            </div>
            <div class="info-block">
              <label><i class="fas fa-map-marker-alt"></i> Départ</label>
              <p>{{ selectedMvt.fromFarm?.name || '--' }}</p>
            </div>
            <div class="info-block">
              <label><i class="fas fa-map-pin"></i> Destination</label>
              <p>{{ selectedMvt.toFarm?.name || '--' }}</p>
            </div>
            <div class="info-block">
              <label><i class="fas fa-tag"></i> Raison</label>
              <p>{{ selectedMvt.reason || '—' }}</p>
            </div>
            <div class="info-block">
              <label><i class="fas fa-info-circle"></i> Statut actuel</label>
              <p><span class="badge" :class="getMvtStatusClass(selectedMvt.approvalStatus)">{{ translateStatus(selectedMvt.approvalStatus) }}</span></p>
            </div>
            <div class="info-block">
              <label><i class="fas fa-user-check"></i> Traité par</label>
              <p>{{ selectedMvt.treatedBy?.username || 'En attente de traitement' }}</p>
            </div>
          </div>

          <div class="info-block note-block">
            <label><i class="fas fa-sticky-note"></i> Note de l'agent</label>
            <p>{{ selectedMvt.notes || 'Aucune note particulière.' }}</p>
          </div>

          <div class="status-manager">
            <h3><i class="fas fa-cogs"></i> Modifier le Statut</h3>
            <div v-if="selectedMvt.approvalStatus === 'Approved'" class="approved-lock-banner">
              <i class="fas fa-lock"></i> Ce mouvement est <strong>approuvé</strong> — le transfert de ferme a été appliqué et ne peut plus être modifié.
            </div>
            <div v-else class="status-options">
              <button
                class="btn-status pending"
                :class="{ active: selectedMvt.approvalStatus === 'Pending' }"
                @click="updateMovementStatus('Pending')"
              >En attente</button>
              <button
                class="btn-status approved"
                :class="{ active: selectedMvt.approvalStatus === 'Approved' }"
                @click="updateMovementStatus('Approved')"
              ><i class="fas fa-check"></i> Approuver</button>
              <button
                class="btn-status rejected"
                :class="{ active: selectedMvt.approvalStatus === 'Rejected' }"
                @click="updateMovementStatus('Rejected')"
              ><i class="fas fa-times"></i> Rejeter</button>
            </div>
          </div>

        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import api from '../services/api';

const movements = ref([]);
const loadError = ref('');
const isLoading = ref(true);
const searchQuery = ref('');
const statusFilter = ref('');
const startDate = ref('');
const endDate = ref('');
const showMvtModal = ref(false);
const selectedMvt = ref(null);

// --- PAGINATION ---
const currentPage = ref(1);
const itemsPerPage = 10;

onMounted(async () => {
  loadError.value = '';
  isLoading.value = true;
  try {
    const res = await api.get('/movements');
    const rows = res.data;
    movements.value = Array.isArray(rows) ? rows : [];
    if (!Array.isArray(rows)) {
      loadError.value = 'Réponse API inattendue pour /movements (tableau attendu).';
    }
  } catch (err) {
    console.error("Erreur chargement mouvements", err);
    movements.value = [];
    const msg = err.response?.data;
    loadError.value =
        typeof msg === 'string' ? msg
        : msg?.message || err.message || 'Impossible de charger les mouvements.';
  } finally {
    isLoading.value = false;
  }
});

const filteredMovements = computed(() => {
  const rawQ = searchQuery.value.trim();
  const q = rawQ.toLowerCase();
  return movements.value.filter(m => {
    const matchesSearch = !rawQ ||
        String(m.id || '').includes(rawQ) ||
        String(m.animal?.id || '').includes(rawQ) ||
        (m.fromFarm?.name || '').toLowerCase().includes(q) ||
        (m.toFarm?.name || '').toLowerCase().includes(q);

    const matchesStatus = !statusFilter.value || m.approvalStatus === statusFilter.value;

    const mDate = m.createdAt ? new Date(m.createdAt).setHours(0,0,0,0) : null;
    const start = startDate.value ? new Date(startDate.value).setHours(0,0,0,0) : null;
    const end = endDate.value ? new Date(endDate.value).setHours(0,0,0,0) : null;

    let matchesDate = true;
    if (start && mDate && mDate < start) matchesDate = false;
    if (end && mDate && mDate > end) matchesDate = false;

    return matchesSearch && matchesStatus && matchesDate;
  });
});

// --- Réinitialiser la page quand les filtres changent ---
watch([searchQuery, statusFilter, startDate, endDate], () => {
  currentPage.value = 1;
});

// --- Pagination calculée ---
const paginatedMovements = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredMovements.value.slice(start, start + itemsPerPage);
});

const totalPages = computed(() => Math.ceil(filteredMovements.value.length / itemsPerPage));

const paginationStart = computed(() => {
  if (filteredMovements.value.length === 0) return 0;
  return (currentPage.value - 1) * itemsPerPage + 1;
});

const paginationEnd = computed(() => {
  return Math.min(currentPage.value * itemsPerPage, filteredMovements.value.length);
});

const pageNumbers = computed(() => {
  const pages = [];
  const total = totalPages.value;
  const current = currentPage.value;

  if (total <= 7) {
    for (let i = 1; i <= total; i++) pages.push(i);
  } else {
    pages.push(1);
    if (current > 3) pages.push('...');
    for (let i = Math.max(2, current - 1); i <= Math.min(total - 1, current + 1); i++) {
      pages.push(i);
    }
    if (current < total - 2) pages.push('...');
    pages.push(total);
  }
  return pages;
});

const prevPage = () => { if (currentPage.value > 1) currentPage.value--; };
const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++; };
const setPage = (page) => { currentPage.value = page; };

// --- Stats ---
const pendingCount = computed(() => movements.value.filter(m => m.approvalStatus === 'Pending').length);
const rejectedCount = computed(() => movements.value.filter(m => m.approvalStatus === 'Rejected').length);

const monthTrend = computed(() => {
  const now = new Date();
  const thisMonth = now.getMonth(), thisYear = now.getFullYear();
  const lastMonth = thisMonth === 0 ? 11 : thisMonth - 1;
  const lastMonthYear = thisMonth === 0 ? thisYear - 1 : thisYear;

  const thisCount = movements.value.filter(m => {
    const d = new Date(m.createdAt);
    return d.getMonth() === thisMonth && d.getFullYear() === thisYear;
  }).length;

  const lastCount = movements.value.filter(m => {
    const d = new Date(m.createdAt);
    return d.getMonth() === lastMonth && d.getFullYear() === lastMonthYear;
  }).length;

  if (lastCount === 0) return thisCount > 0 ? '+100%' : '0%';
  const pct = Math.round(((thisCount - lastCount) / lastCount) * 100);
  return (pct >= 0 ? '+' : '') + pct + '%';
});

const complianceRate = computed(() => {
  if (!movements.value.length) return 0;
  return (((movements.value.length - rejectedCount.value) / movements.value.length) * 100).toFixed(1);
});

const formatDate = (date) => new Date(date).toLocaleDateString('fr-FR');
const translateStatus = (s) => ({ 'Approved': 'APPROUVÉ', 'Pending': 'EN ATTENTE', 'Rejected': 'REJETÉ' }[s] || s);

const getMvtStatusClass = (status) => {
  const map = { 'Approved': 'badge-green', 'Pending': 'badge-yellow', 'Rejected': 'badge-red' };
  return map[status] || 'badge-gray';
};

const openMvtDetails = (mvt) => {
  selectedMvt.value = mvt;
  showMvtModal.value = true;
};

const updateMovementStatus = async (newStatus) => {
  if (!selectedMvt.value || selectedMvt.value.approvalStatus === newStatus) return;
  if (selectedMvt.value.approvalStatus === 'Approved') return;

  const labels = { Pending: 'En attente', Approved: 'Approuvé', Rejected: 'Rejeté' };
  const message = newStatus === 'Approved'
    ? `Approuver ce mouvement est irréversible.\nLe transfert de l'animal vers "${selectedMvt.value.toFarm?.name || 'la ferme de destination'}" sera appliqué définitivement.\n\nConfirmer ?`
    : `Êtes-vous sûr de vouloir passer ce mouvement à "${labels[newStatus]}" ?`;

  if (!confirm(message)) return;

  try {
    const res = await api.put(`/movements/${selectedMvt.value.id}/status`, { status: newStatus });
    selectedMvt.value = res.data;
    const idx = movements.value.findIndex(m => m.id === res.data.id);
    if (idx !== -1) movements.value[idx] = res.data;
  } catch (error) {
    console.error('Erreur mise à jour statut mouvement:', error);
    alert('Erreur lors de la mise à jour du statut.');
  }
};
</script>

<style scoped>
/* ==========================================================================
   1. BASE
   ========================================================================== */
.movements-container {
  padding: 30px;
  background-color: #f4f7f6;
  min-height: 100vh;
  font-family: 'Inter', sans-serif;
  color: #1e293b;
}

.header-section {
  display: flex;
  flex-direction: column;
  margin-bottom: 25px;
}

.title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

h1 {
  font-size: 26px;
  font-weight: 900;
  margin: 0;
  color: #0f172a;
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

.kpi-card:nth-child(1) { border-left-color: #2196F3; }
.kpi-card:nth-child(2) { border-left-color: #FF9800; }
.kpi-card:nth-child(3) { border-left-color: #F44336; }
.kpi-card:nth-child(4) { border-left-color: #4CAF50; }

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
  margin: 4px 0;
}

.kpi-footer {
  font-size: 11px;
  font-weight: 600;
}

.kpi-footer.green { color: #4CAF50; }
.kpi-footer.red { color: #F44336; }

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
   3. FILTRES
   ========================================================================== */
.filters-bar {
  display: flex;
  align-items: center;
  gap: 20px;
  background: white;
  padding: 16px 25px;
  border-radius: 12px 12px 0 0;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  margin-bottom: 0;
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
  max-width: 400px;
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

.date-filters {
  display: flex;
  gap: 16px;
  align-items: center;
}

.date-input-group {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #063B16;
  font-weight: 600;
}

.date-input-group label {
  font-size: 11px;
  font-weight: 700;
  color: #0B5D1E;
  text-transform: uppercase;
}

.filter-date {
  padding: 10px 14px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  outline: none;
  font-family: 'Inter', sans-serif;
  color: #063B16;
  background: white;
  height: 42px;
  box-sizing: border-box;
}

.filter-select {
  padding: 10px 14px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  outline: none;
  background: white;
  color: #063B16;
  font-size: 14px;
  cursor: pointer;
  font-weight: 600;
  height: 42px;
  box-sizing: border-box;
}

.filter-select:focus, .filter-date:focus {
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
  border: 1px solid rgba(11, 93, 30, 0.08);
  border-top: none;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th {
  text-align: left;
  padding: 14px 20px;
  font-size: 11px;
  font-weight: 800;
  color: #0B5D1E;
  text-transform: uppercase;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  background: rgba(11, 93, 30, 0.03);
  letter-spacing: 0.5px;
}

td {
  padding: 16px 20px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.05);
  font-size: 14px;
  vertical-align: middle;
}

tr:hover td {
  background-color: rgba(11, 93, 30, 0.02);
}

.empty-row {
  text-align: center;
  color: #94a3b8;
  font-style: italic;
  padding: 30px;
}

.mvt-id {
  font-weight: 700;
  color: #0B5D1E;
  font-family: 'JetBrains Mono', monospace;
}

.animal-id {
  font-family: 'JetBrains Mono', monospace;
  font-weight: 600;
  color: #2196F3;
}

.badge-reason {
  background: rgba(11, 93, 30, 0.05);
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  color: #063B16;
}

/* ==========================================================================
   5. BADGES
   ========================================================================== */
.badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
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
   6. BOUTONS
   ========================================================================== */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 15px;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: 0.2s;
}

.btn-secondary {
  background: rgba(11, 93, 30, 0.08);
  color: #063B16;
  border: 1px solid rgba(11, 93, 30, 0.2);
}

.btn-secondary:hover {
  background: rgba(11, 93, 30, 0.15);
}

.btn-icon-only {
  padding: 8px;
  width: 32px;
  height: 32px;
  justify-content: center;
}

.btn-sm {
  padding: 6px 12px;
  font-size: 12px;
}

/* ==========================================================================
   7. PAGINATION
   ========================================================================== */
.pagination-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  color: #64748b;
  font-size: 13px;
  background: rgba(11, 93, 30, 0.02);
  border-top: 1px solid rgba(11, 93, 30, 0.08);
}

.pagination-info {
  font-weight: 600;
}

.pagination-controls {
  display: flex;
  gap: 5px;
}

.page-btn {
  width: 35px;
  height: 35px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  background: white;
  border-radius: 8px;
  cursor: pointer;
  color: #063B16;
  font-weight: 700;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.page-btn:hover:not(:disabled) {
  background: rgba(11, 93, 30, 0.1);
}

.page-btn.active {
  background: #0B5D1E;
  color: white;
  border-color: #0B5D1E;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ==========================================================================
   8. MODALE
   ========================================================================== */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
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
  max-width: 600px;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
  animation: modalFadeIn 0.3s ease-out;
  max-height: 90vh;
  overflow-y: auto;
}

@keyframes modalFadeIn {
  from { opacity: 0; transform: translateY(-20px); }
  to { opacity: 1; transform: translateY(0); }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  padding-bottom: 15px;
}

.modal-header h2 {
  margin: 0;
  font-size: 18px;
  color: #063B16;
  font-weight: 800;
  display: flex;
  align-items: center;
  gap: 10px;
}

.mvt-id-header {
  font-family: 'JetBrains Mono', monospace;
  color: #0B5D1E;
}

.close-btn {
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
  transition: all 0.2s;
}

.close-btn:hover {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

.modal-body {
  padding: 5px 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.info-block label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  font-weight: 700;
  color: #0B5D1E;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 6px;
}

.info-block p {
  background: rgba(11, 93, 30, 0.03);
  padding: 10px 14px;
  border-radius: 8px;
  margin: 0;
  font-size: 14px;
  color: #063B16;
  font-weight: 600;
}

.mono-val {
  font-family: 'JetBrains Mono', monospace !important;
  color: #2196F3 !important;
}

.note-block p {
  background: rgba(255, 152, 0, 0.05);
  border-left: 4px solid #FF9800;
}

/* ==========================================================================
   9. MODIFICATEUR DE STATUT
   ========================================================================== */
.status-manager {
  border-top: 1px dashed rgba(11, 93, 30, 0.15);
  padding-top: 18px;
}

.status-manager h3 {
  margin: 0 0 14px 0;
  font-size: 14px;
  font-weight: 800;
  color: #063B16;
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-manager h3 i {
  color: #0B5D1E;
}

.status-options {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.btn-status {
  padding: 9px 16px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  border: 1.5px solid rgba(11, 93, 30, 0.2);
  background: white;
  color: #64748b;
  font-family: 'Inter', sans-serif;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.btn-status:hover {
  background: rgba(11, 93, 30, 0.05);
  color: #063B16;
}

.btn-status.pending.active {
  background: rgba(255, 152, 0, 0.12);
  color: #FF9800;
  border-color: rgba(255, 152, 0, 0.4);
  font-weight: 700;
}

.btn-status.approved.active {
  background: rgba(76, 175, 80, 0.12);
  color: #4CAF50;
  border-color: rgba(76, 175, 80, 0.4);
  font-weight: 700;
}

.btn-status.rejected.active {
  background: rgba(244, 67, 54, 0.12);
  color: #F44336;
  border-color: rgba(244, 67, 54, 0.4);
  font-weight: 700;
}

.approved-lock-banner {
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(76, 175, 80, 0.08);
  border: 1px solid rgba(76, 175, 80, 0.25);
  border-radius: 8px;
  padding: 14px 18px;
  font-size: 13px;
  color: #4CAF50;
  font-weight: 500;
  line-height: 1.6;
}

.approved-lock-banner i {
  font-size: 18px;
  flex-shrink: 0;
  color: #4CAF50;
}

.approved-lock-banner strong {
  color: #4CAF50;
  font-weight: 700;
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