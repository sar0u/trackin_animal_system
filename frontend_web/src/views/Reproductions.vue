<template>
  <div class="page-container">
    <div class="page-header">
      <div>
        <h1>Gestion des Reproductions</h1>
        <p class="subtitle">Suivi des cycles de reproduction et données de natalité du cheptel national.</p>
      </div>
    </div>

    <p v-if="loadError" class="api-error-banner">{{ loadError }}</p>

    <div class="kpi-grid">
      <div class="kpi-card kpi-blue">
        <span class="kpi-label">TOTAL</span>
        <div class="kpi-value">{{ reproductions.length }}</div>
      </div>
      <div class="kpi-card kpi-orange">
        <span class="kpi-label">EN COURS</span>
        <div class="kpi-value">{{ inProgressCount }}</div>
      </div>
      <div class="kpi-card kpi-green">
        <span class="kpi-label">RÉUSSIES</span>
        <div class="kpi-value">{{ successCount }}</div>
      </div>
      <div class="kpi-card kpi-red">
        <span class="kpi-label">ÉCHOUÉES / AVORTÉES</span>
        <div class="kpi-value">{{ failedCount }}</div>
      </div>
    </div>

    <div class="filters-bar">
      <div class="search-box">
        <i class="fas fa-search"></i>
        <input type="text" v-model="searchQuery" placeholder="Rechercher par ID reproduction, ID animal ou vétérinaire...">
      </div>
      <select v-model="filterStatus" class="filter-select">
        <option value="">Tous les statuts</option>
        <option value="IN_PROGRESS">En cours</option>
        <option value="SUCCESSFUL">Réussie</option>
        <option value="FAILED">Échouée</option>
        <option value="ABORTED">Avortée</option>
      </select>
    </div>

    <div class="table-wrapper">
      <div v-if="isLoading" class="loading-state">
        <i class="fas fa-circle-notch fa-spin"></i> Chargement...
      </div>
      <table v-else class="data-table">
        <thead>
        <tr>
          <th>ID</th>
          <th>FEMELLE</th>
          <th>MÂLE</th>
          <th>DATE SAILLIE</th>
          <th>NAISSANCE PRÉVUE</th>
          <th>NAISSANCE RÉELLE</th>
          <th>NAISSANCES</th>
          <th>STATUT</th>
          <th>VÉTÉRINAIRE</th>
          <th>DÉTAILS</th>
        </tr>
        </thead>
        <tbody>
        <tr v-if="filteredReproductions.length === 0">
          <td colspan="10" class="empty-row">Aucune reproduction à afficher.</td>
        </tr>
        <tr v-for="repro in paginatedReproductions" :key="repro.id">
          <td class="mono-id">#RPR-{{ repro.id }}</td>
          <td>
            <span class="mono-id" style="color:#2196F3;">#ANI-{{ repro.female?.id || '--' }}</span>
            <span class="sub-info">{{ [repro.female?.species, repro.female?.breed].filter(Boolean).join(' · ') }}</span>
          </td>
          <td>
            <span v-if="repro.male">
              <span class="mono-id" style="color:#2196F3;">#ANI-{{ repro.male.id }}</span>
              <span class="sub-info">{{ repro.male?.species || '' }}</span>
            </span>
            <span v-else>—</span>
          </td>
          <td>{{ formatDate(repro.breedingDate) }}</td>
          <td>{{ formatDate(repro.expectedBirthDate) }}</td>
          <td>{{ repro.actualBirthDate ? formatDate(repro.actualBirthDate) : '—' }}</td>
          <td class="center-td">{{ repro.offspringCount ?? 0 }}</td>
          <td>
            <span class="badge" :class="getStatusClass(repro.status)">{{ translateStatus(repro.status) }}</span>
          </td>
          <td>{{ getVetName(repro) }}</td>
          <td>
            <button class="btn-icon" @click="openModal(repro)">
              <i class="fas fa-eye"></i>
            </button>
          </td>
        </tr>
        </tbody>
      </table>

      <div class="pagination-bar">
        <span class="pagination-info">
          Affichage de {{ paginationStart }} à {{ paginationEnd }} sur {{ filteredReproductions.length }} reproductions
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

    <div class="stats-section">
      <h3 class="stats-title"><i class="fas fa-chart-bar"></i> Statistiques</h3>
      <!-- Stats Grid - Icônes sans violet -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-icon" style="background:rgba(33,150,243,0.1);color:#2196F3;"><i class="fas fa-horse"></i></div>
          <div class="stat-body">
            <span class="stat-label">Taux de réussite</span>
            <span class="stat-value">{{ successRate }}%</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="background:rgba(76,175,80,0.1);color:#4CAF50;"><i class="fas fa-baby"></i></div>
          <div class="stat-body">
            <span class="stat-label">Total naissances</span>
            <span class="stat-value">{{ totalOffspring }}</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="background:rgba(33,150,243,0.1);color:#2196F3;"><i class="fas fa-calculator"></i></div>
          <div class="stat-body">
            <span class="stat-label">Moy. naissances / repro réussie</span>
            <span class="stat-value">{{ avgOffspring }}</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="background:rgba(255,152,0,0.1);color:#FF9800;"><i class="fas fa-clock"></i></div>
          <div class="stat-body">
            <span class="stat-label">Durée moy. gestation (jours)</span>
            <span class="stat-value">{{ avgGestationDays }}</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="background:rgba(244,67,54,0.1);color:#F44336;"><i class="fas fa-venus"></i></div>
          <div class="stat-body">
            <span class="stat-label">Femelles distinctes</span>
            <span class="stat-value">{{ distinctFemales }}</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="background:rgba(11,93,30,0.1);color:#0B5D1E;"><i class="fas fa-mars"></i></div>
          <div class="stat-body">
            <span class="stat-label">Mâles distincts</span>
            <span class="stat-value">{{ distinctMales }}</span>
          </div>
        </div>
      </div>

      <div class="breakdown-row">
        <div class="breakdown-card">
          <h4>Répartition par statut</h4>
          <div class="breakdown-bars">
            <div class="bar-item" v-for="item in statusBreakdown" :key="item.label">
              <div class="bar-label-row">
                <span class="badge" :class="item.cls">{{ item.label }}</span>
                <span class="bar-count">{{ item.count }}</span>
              </div>
              <div class="bar-track">
                <div class="bar-fill" :style="{ width: item.pct + '%', background: item.color }"></div>
              </div>
            </div>
          </div>
        </div>

        <div class="breakdown-card">
          <h4>Reproductions par mois (12 derniers mois)</h4>
          <div class="monthly-list">
            <div class="monthly-item" v-for="m in monthlyBreakdown" :key="m.label">
              <span class="monthly-label">{{ m.label }}</span>
              <div class="bar-track" style="flex:1;">
                <div class="bar-fill" :style="{ width: m.pct + '%', background: '#0B5D1E' }"></div>
              </div>
              <span class="bar-count">{{ m.count }}</span>
            </div>
            <div v-if="monthlyBreakdown.length === 0" class="empty-stat">Aucune donnée</div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showModal && selectedRepro" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Reproduction #RPR-{{ selectedRepro.id }}</h2>
          <button class="btn-close" @click="closeModal">&times;</button>
        </div>
        <div class="modal-body">
          <div class="detail-grid">
            <div class="detail-item">
              <span class="detail-label">Femelle</span>
              <span class="detail-value">
                #ANI-{{ selectedRepro.female?.id || '--' }}
                <span v-if="selectedRepro.female?.species || selectedRepro.female?.breed" style="color:#6b7280;font-size:12px;margin-left:6px;">
                  ({{ [selectedRepro.female?.species, selectedRepro.female?.breed].filter(Boolean).join(' · ') }})
                </span>
              </span>
            </div>
            <div class="detail-item">
              <span class="detail-label">Mâle</span>
              <span class="detail-value">
                {{ selectedRepro.male ? '#ANI-' + selectedRepro.male.id : '—' }}
                <span v-if="selectedRepro.male?.species" style="color:#6b7280;font-size:12px;margin-left:6px;">({{ selectedRepro.male.species }})</span>
              </span>
            </div>
            <div class="detail-item"><span class="detail-label">Date de saillie</span><span class="detail-value">{{ formatDate(selectedRepro.breedingDate) }}</span></div>
            <div class="detail-item"><span class="detail-label">Naissance prévue</span><span class="detail-value">{{ formatDate(selectedRepro.expectedBirthDate) }}</span></div>
            <div class="detail-item"><span class="detail-label">Naissance réelle</span><span class="detail-value">{{ selectedRepro.actualBirthDate ? formatDate(selectedRepro.actualBirthDate) : '—' }}</span></div>
            <div class="detail-item"><span class="detail-label">Naissances</span><span class="detail-value">{{ selectedRepro.offspringCount ?? 0 }}</span></div>
            <div class="detail-item"><span class="detail-label">Statut</span><span class="badge" :class="getStatusClass(selectedRepro.status)">{{ translateStatus(selectedRepro.status) }}</span></div>
            <div class="detail-item"><span class="detail-label">Vétérinaire</span><span class="detail-value">{{ getVetName(selectedRepro) }}</span></div>
            <div class="detail-item"><span class="detail-label">Créé le</span><span class="detail-value">{{ formatDate(selectedRepro.createdAt) }}</span></div>
            <div class="detail-item"><span class="detail-label">Mis à jour le</span><span class="detail-value">{{ formatDate(selectedRepro.updatedAt) }}</span></div>
          </div>
          <div v-if="selectedRepro.notes" class="notes-block">
            <h4><i class="fas fa-sticky-note"></i> Notes</h4>
            <p>{{ selectedRepro.notes }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import api from '../services/api';

const reproductions = ref([]);
const isLoading = ref(true);
const loadError = ref('');
const searchQuery = ref('');
const filterStatus = ref('');
const showModal = ref(false);
const selectedRepro = ref(null);

// --- Pagination ---
const currentPage = ref(1);
const itemsPerPage = 15;

onMounted(async () => {
  try {
    const res = await api.get('/reproductions');
    reproductions.value = Array.isArray(res.data) ? res.data : [];
  } catch (err) {
    loadError.value = err.response?.data?.message || err.message || 'Impossible de charger les reproductions.';
    reproductions.value = [];
  } finally {
    isLoading.value = false;
  }
});

const filteredReproductions = computed(() => {
  const q = searchQuery.value.toLowerCase();
  return reproductions.value.filter(r => {
    const matchSearch = !q ||
      String(r.id || '').includes(q) ||
      String(r.female?.id || '').includes(q) ||
      String(r.male?.id || '').includes(q) ||
      getVetName(r).toLowerCase().includes(q);
    const matchStatus = !filterStatus.value || r.status === filterStatus.value;
    return matchSearch && matchStatus;
  });
});

// --- Pagination calculée ---
watch([searchQuery, filterStatus], () => {
  currentPage.value = 1;
});

const paginatedReproductions = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredReproductions.value.slice(start, start + itemsPerPage);
});

const totalPages = computed(() => Math.ceil(filteredReproductions.value.length / itemsPerPage));

const paginationStart = computed(() => {
  if (filteredReproductions.value.length === 0) return 0;
  return (currentPage.value - 1) * itemsPerPage + 1;
});

const paginationEnd = computed(() => {
  return Math.min(currentPage.value * itemsPerPage, filteredReproductions.value.length);
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
const inProgressCount = computed(() => reproductions.value.filter(r => r.status === 'IN_PROGRESS').length);
const successCount = computed(() => reproductions.value.filter(r => r.status === 'SUCCESSFUL').length);
const failedCount = computed(() => reproductions.value.filter(r => r.status === 'FAILED' || r.status === 'ABORTED').length);

const totalOffspring = computed(() => reproductions.value.reduce((s, r) => s + (r.offspringCount || 0), 0));

const successRate = computed(() => {
  const closed = reproductions.value.filter(r => r.status !== 'IN_PROGRESS').length;
  if (closed === 0) return '—';
  return Math.round((successCount.value / closed) * 100);
});

const avgOffspring = computed(() => {
  const successful = reproductions.value.filter(r => r.status === 'SUCCESSFUL');
  if (successful.length === 0) return '—';
  const total = successful.reduce((s, r) => s + (r.offspringCount || 0), 0);
  return (total / successful.length).toFixed(1);
});

const avgGestationDays = computed(() => {
  const withDates = reproductions.value.filter(r => r.breedingDate && r.actualBirthDate);
  if (withDates.length === 0) return '—';
  const total = withDates.reduce((s, r) => {
    const diff = new Date(r.actualBirthDate) - new Date(r.breedingDate);
    return s + Math.round(diff / 86400000);
  }, 0);
  return Math.round(total / withDates.length);
});

const distinctFemales = computed(() => new Set(reproductions.value.map(r => r.female?.id).filter(Boolean)).size);
const distinctMales = computed(() => new Set(reproductions.value.map(r => r.male?.id).filter(Boolean)).size);

const statusBreakdown = computed(() => {
  const total = reproductions.value.length || 1;
  return [
    { label: 'En cours',  cls: 'badge-blue',   color: '#2196F3', count: inProgressCount.value, pct: Math.round(inProgressCount.value / total * 100) },
    { label: 'Réussie',   cls: 'badge-green',  color: '#4CAF50', count: successCount.value,     pct: Math.round(successCount.value / total * 100) },
    { label: 'Échouée',   cls: 'badge-red',    color: '#F44336', count: reproductions.value.filter(r => r.status === 'FAILED').length,  pct: Math.round(reproductions.value.filter(r => r.status === 'FAILED').length / total * 100) },
    { label: 'Avortée',   cls: 'badge-orange', color: '#FF9800', count: reproductions.value.filter(r => r.status === 'ABORTED').length, pct: Math.round(reproductions.value.filter(r => r.status === 'ABORTED').length / total * 100) },
  ];
});

const monthlyBreakdown = computed(() => {
  const counts = {};
  const now = new Date();
  for (let i = 11; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
    counts[key] = 0;
  }
  reproductions.value.forEach(r => {
    if (!r.breedingDate) return;
    const key = r.breedingDate.slice(0, 7);
    if (key in counts) counts[key]++;
  });
  const max = Math.max(...Object.values(counts), 1);
  return Object.entries(counts).map(([key, count]) => ({
    label: new Date(key + '-01').toLocaleDateString('fr-FR', { month: 'short', year: '2-digit' }),
    count,
    pct: Math.round(count / max * 100),
  }));
});

const getVetName = (r) => {
  const v = r.veterinarian;
  if (!v) return '—';
  return `${v.firstName || ''} ${v.lastName || ''}`.trim() || v.username || `#${v.id}`;
};

const translateStatus = (s) => ({
  'IN_PROGRESS': 'En cours', 'SUCCESSFUL': 'Réussie', 'FAILED': 'Échouée', 'ABORTED': 'Avortée'
}[s] || s || '--');

const getStatusClass = (s) => ({
  'IN_PROGRESS': 'badge-blue', 'SUCCESSFUL': 'badge-green', 'FAILED': 'badge-red', 'ABORTED': 'badge-orange'
}[s] || 'badge-gray');

const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : '--';

const openModal = (r) => { selectedRepro.value = r; showModal.value = true; };
const closeModal = () => { showModal.value = false; selectedRepro.value = null; };
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

.kpi-blue { border-left-color: #2196F3; }
.kpi-orange { border-left-color: #FF9800; }
.kpi-green { border-left-color: #4CAF50; }
.kpi-red { border-left-color: #F44336; }

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

tr:hover {
  background-color: rgba(11, 93, 30, 0.02);
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
}

.center-td {
  text-align: center;
  font-weight: 700;
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
  max-width: 600px;
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
}

.modal-header h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 800;
  color: #063B16;
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
  transition: all 0.2s;
}

.btn-close:hover {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

.modal-body {
  padding: 25px;
}

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

.notes-block {
  background: rgba(255, 152, 0, 0.05);
  border-left: 4px solid #FF9800;
  border-radius: 8px;
  padding: 15px;
}

.notes-block h4 {
  margin: 0 0 10px 0;
  font-size: 14px;
  font-weight: 800;
  color: #FF9800;
  display: flex;
  align-items: center;
  gap: 8px;
}

.notes-block p {
  margin: 0;
  font-size: 13px;
  color: #475569;
  font-style: italic;
}

/* ==========================================================================
   9. STATS SECTION
   ========================================================================== */
.stats-section {
  margin-top: 25px;
}

.stats-title {
  font-size: 16px;
  font-weight: 800;
  color: #0f172a;
  margin: 0 0 16px 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.stats-title i {
  color: #0B5D1E;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 20px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  border: 1px solid rgba(11, 93, 30, 0.08);
  padding: 18px 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
}

.stat-icon {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  flex-shrink: 0;
}

.stat-body {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.stat-card .stat-label {
  font-size: 10px;
  font-weight: 800;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.stat-card .stat-value {
  font-size: 24px;
  font-weight: 900;
  color: #0f172a;
  line-height: 1;
}

.breakdown-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.breakdown-card {
  background: white;
  border: 1px solid rgba(11, 93, 30, 0.08);
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
}

.breakdown-card h4 {
  margin: 0 0 16px 0;
  font-size: 13px;
  font-weight: 800;
  color: #063B16;
}

.breakdown-bars {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.bar-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.bar-label-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.bar-count {
  font-size: 13px;
  font-weight: 700;
  color: #063B16;
}

.bar-track {
  height: 8px;
  background: rgba(11, 93, 30, 0.08);
  border-radius: 99px;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  border-radius: 99px;
  transition: width 0.6s ease;
}

.monthly-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 260px;
  overflow-y: auto;
}

.monthly-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.monthly-label {
  font-size: 12px;
  font-weight: 600;
  color: #64748b;
  width: 52px;
  flex-shrink: 0;
}

.empty-stat {
  text-align: center;
  color: #94a3b8;
  font-style: italic;
  padding: 20px;
}

/* ==========================================================================
   10. RESPONSIVE
   ========================================================================== */
@media (max-width: 1200px) {
  .kpi-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .breakdown-row {
    grid-template-columns: 1fr;
  }
}
</style>