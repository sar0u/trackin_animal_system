<template>
  <div class="main-content">
    <div class="page-header">
      <div>
        <h1>Portail des Subventions & Aides Financières</h1>
        <p class="subtitle">Pilotage budgétaire et suivi des versements aux exploitants</p>
      </div>
      <button class="btn-export" @click="exportData">
        <i class="fas fa-download"></i> Exporter Rapport
      </button>
    </div>

    <div class="top-stats-grid">
      <div class="stat-card border-blue">
        <div class="stat-header">
          <div class="stat-icon-bg bg-light-blue"><i class="fas fa-wallet"></i></div>
        </div>
        <div class="stat-body">
          <span class="stat-label">Budget Total Alloué</span>
          <span class="stat-value">{{ formatCurrency(totalBudget) }}</span>
        </div>
      </div>

      <div class="stat-card border-gray">
        <div class="stat-header">
          <div class="stat-icon-bg bg-light-gray"><i class="fas fa-clock"></i></div>
        </div>
        <div class="stat-body">
          <span class="stat-label">Demandes en Attente</span>
          <span class="stat-value">{{ pendingCount }}</span>
        </div>
      </div>

      <div class="stat-card border-green">
        <div class="stat-header">
          <div class="stat-icon-bg bg-light-green"><i class="fas fa-check-circle"></i></div>
        </div>
        <div class="stat-body">
          <span class="stat-label">Taux de Paiement</span>
          <span class="stat-value">{{ paymentRate }}%</span>
        </div>
      </div>

      <div class="stat-card border-red">
        <div class="stat-header">
          <div class="stat-icon-bg bg-light-red"><i class="fas fa-exclamation-triangle"></i></div>
        </div>
        <div class="stat-body">
          <span class="stat-label">Alertes Conformité</span>
          <span class="stat-value">{{ alertsCount }} suspects</span>
        </div>
      </div>
    </div>

    <div class="main-list-section">
      <div class="filters-bar">
        <div class="search-box">
          <i class="fas fa-search"></i>
          <input type="text" v-model="searchQuery" placeholder="Rechercher...">
        </div>
        <div class="filter-actions">
          <select v-model="statusFilter" class="filter-select">
            <option value="">Tous les Statuts</option>
            <option value="Pending">Pending</option>
            <option value="Approved">Approved</option>
            <option value="Paid">Paid</option>
            <option value="Rejected">Rejected</option>
          </select>
          <select v-model="typeFilter" class="filter-select">
            <option value="">Tous les Types</option>
            <option value="Aide Bio">Aide Bio</option>
            <option value="Bien-être animal">Bien-être animal</option>
            <option value="Modernisation">Modernisation</option>
          </select>
        </div>
      </div>

      <div class="table-container-card">
        <table class="subsidy-table">
          <thead>
            <tr>
              <th>ID SUBVENTION</th>
              <th>ID ANIMAL / EXPLOITANT</th>
              <th>TYPE</th>
              <th>MONTANT (DZD)</th>
              <th>STATUT</th>
              <th>DATE DEMANDE</th>
              <th>DATE PAIEMENT</th>
              <th>ACTIONS</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="isLoading">
              <td colspan="8" style="text-align: center; padding: 40px;">Chargement des données...</td>
            </tr>
            <tr v-else-if="filteredSubsidies.length === 0">
              <td colspan="8" style="text-align: center; padding: 40px;">Aucune subvention trouvée.</td>
            </tr>
            <tr v-for="sub in paginatedSubsidies" :key="sub.id">
              <td class="id-sub">#SUB-{{ sub.requestDate ? sub.requestDate.split('-')[0] : '2026' }}-{{ sub.id }}</td>
              <td class="id-entity">
                <span class="entity-id">FR-{{ sub.animalId }}-001</span>
                <span class="entity-name">{{ sub.ownerName || 'Exploitant Inconnu' }}</span>
              </td>
              <td>{{ sub.subsidyType }}</td>
              <td class="amount-cell">{{ formatNumber(sub.amount) }}</td>
              <td>
                <span :class="['status-pill', sub.status ? sub.status.toLowerCase() : 'pending']">
                  {{ sub.status }}
                </span>
              </td>
              <td>{{ formatDate(sub.requestDate) }}</td>
              <td>{{ sub.paidDate ? formatDate(sub.paidDate) : '—' }}</td>
              <td class="actions-cell">
                <button class="btn-icon" title="Détails"><i class="fas fa-eye"></i></button>
              </td>
            </tr>
          </tbody>
        </table>

        <div class="pagination">
          <span>Affichage de {{ startItem }}-{{ endItem }} sur {{ filteredSubsidies.length }} aides</span>
          <div class="page-controls">
            <button
              class="btn-page"
              @click="previousPage"
              :disabled="currentPage === 1"
            >
              <
            </button>
            <button
              v-for="page in totalPages"
              :key="page"
              class="btn-page"
              :class="{ active: currentPage === page }"
              @click="goToPage(page)"
            >
              {{ page }}
            </button>
            <button
              class="btn-page"
              @click="nextPage"
              :disabled="currentPage === totalPages"
            >
              >
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="chart-section card">
      <div class="chart-header">
        <h3><i class="fas fa-chart-line"></i> Répartition des Fonds par Filière</h3>
      </div>
      <div class="chart-placeholder">
        <div class="bar-chart">
          <div v-for="filiere in filieres" :key="filiere.name" class="bar-item">
            <div class="bar" :style="{ height: filiere.percent + '%' }"></div>
            <span class="bar-label">{{ filiere.name }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';

// --- États Réactifs pour la BDD ---
const subsidies = ref([]);
const filieres = ref([]);
const isLoading = ref(true);

// --- Filtres ---
const searchQuery = ref('');
const statusFilter = ref('');
const typeFilter = ref('');

// --- Pagination ---
const currentPage = ref(1);
const itemsPerPage = 15;

// --- Stats Calculées ---
const totalBudget = ref(0);
const totalCount = ref(0);
const paymentRate = ref(0);
const alertsCount = ref(0);

const pendingCount = computed(() =>
  subsidies.value.filter(s => s.status === 'Pending').length
);

// --- Logique de filtrage ---
const filteredSubsidies = computed(() => {
  return subsidies.value.filter(s => {
    const matchesSearch = !searchQuery.value ||
      (s.ownerName && s.ownerName.toLowerCase().includes(searchQuery.value.toLowerCase())) ||
      (s.id && s.id.toString().includes(searchQuery.value));

    const matchesStatus = !statusFilter.value || s.status === statusFilter.value;
    const matchesType = !typeFilter.value || s.subsidyType === typeFilter.value;

    return matchesSearch && matchesStatus && matchesType;
  });
});

// --- Pagination calculée ---
const totalPages = computed(() => {
  return Math.ceil(filteredSubsidies.value.length / itemsPerPage) || 1;
});

const paginatedSubsidies = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  const end = start + itemsPerPage;
  return filteredSubsidies.value.slice(start, end);
});

const startItem = computed(() => {
  return filteredSubsidies.value.length === 0 ? 0 : (currentPage.value - 1) * itemsPerPage + 1;
});

const endItem = computed(() => {
  return Math.min(currentPage.value * itemsPerPage, filteredSubsidies.value.length);
});

// --- Méthodes de pagination ---
const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++;
  }
};

const previousPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--;
  }
};

const goToPage = (page) => {
  currentPage.value = page;
};

// --- Réinitialiser la page lors du changement de filtres ---
watch([searchQuery, statusFilter, typeFilter], () => {
  currentPage.value = 1;
});

// --- Fonctions API (À connecter à ton Backend) ---
const fetchSubsidies = async () => {
  isLoading.value = true;
  try {
    // ICI : Ton appel API Spring Boot
    // const response = await axios.get('/api/subsidies');
    // subsidies.value = response.data;

    // Pour l'instant, données de test pour voir la pagination
    subsidies.value = [];
    isLoading.value = false;
  } catch (error) {
    console.error("Erreur lors de la récupération des données", error);
    isLoading.value = false;
  }
};

onMounted(() => {
  fetchSubsidies();
});

// --- Utilitaires de formatage ---
const formatNumber = (num) => {
  if (!num) return "0,00";
  return new Intl.NumberFormat('fr-FR', { minimumFractionDigits: 2 }).format(num);
};

const formatCurrency = (num) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(num);
};

const formatDate = (dateStr) => {
  if (!dateStr) return "—";
  return new Intl.DateTimeFormat('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' }).format(new Date(dateStr));
};

const exportData = () => {
  console.log("Exportation des données en cours...");
};
</script>

<style scoped>
/* ==========================================================================
   1. STRUCTURE & HEADER
   ========================================================================== */
.main-content {
  font-family: 'Inter', sans-serif;
  background: #f4f7f6;
  padding: 30px;
  min-height: 100vh;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.page-header h1 { font-size: 26px; font-weight: 900; color: #0f172a; margin: 0; letter-spacing: -0.5px; }
.subtitle { color: #64748b; font-size: 14px; margin-top: 5px; }

.btn-export {
  background: rgba(11, 93, 30, 0.08);
  border: 1px solid rgba(11, 93, 30, 0.2);
  padding: 10px 18px;
  border-radius: 8px;
  font-weight: 700;
  font-size: 13px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
  color: #063B16;
}
.btn-export:hover { background: rgba(11, 93, 30, 0.15); border-color: rgba(11, 93, 30, 0.3); }

/* ==========================================================================
   2. CARDS KPI (Mêmes dimensions que le dashboard)
   ========================================================================== */
.top-stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 25px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  border-left: 4px solid transparent;
}

/* Bordures spécifiques avec vos couleurs */
.border-blue { border-left-color: #0B5D1E; }
.border-gray { border-left-color: #063B16; }
.border-green { border-left-color: #4CAF50; }
.border-red { border-left-color: #F44336; }

.stat-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0; }

.stat-icon-bg {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
}
.bg-light-blue { background: rgba(33, 150, 243, 0.1); color: #0B5D1E; }
.bg-light-gray { background: rgba(255, 152, 0, 0.1); color: #063B16; }
.bg-light-green { background: rgba(76, 175, 80, 0.1); color: #4CAF50; }
.bg-light-red { background: rgba(244, 67, 54, 0.1); color: #F44336; }

.stat-body {
  display: flex;
  flex-direction: column;
}

.stat-label {
  font-size: 10px;
  font-weight: 800;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 24px;
  font-weight: 900;
  color: #0f172a;
  line-height: 1;
  margin-bottom: 4px;
}

/* ==========================================================================
   3. FILTRES & TABLEAU
   ========================================================================== */
.filters-bar {
  background: white;
  padding: 16px 25px;
  border-radius: 12px 12px 0 0;
  border: 1px solid rgba(11, 93, 30, 0.08);
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
}

.search-box {
  background: rgba(11, 93, 30, 0.05);
  padding: 8px 16px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 10px;
  width: 320px;
}
.search-box input { border: none; background: transparent; outline: none; width: 100%; font-size: 14px; color: #063B16; }
.search-box input::placeholder { color: #0B5D1E; opacity: 0.5; }
.search-box i { color: #0B5D1E; opacity: 0.6; }

.filter-select {
  padding: 8px 12px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  margin-left: 10px;
  font-size: 13px;
  font-weight: 600;
  color: #063B16;
  background: white;
}

.table-container-card {
  background: white;
  border: 1px solid rgba(11, 93, 30, 0.08);
  border-top: none;
  border-radius: 0 0 12px 12px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
}

.subsidy-table { width: 100%; border-collapse: collapse; text-align: left; }
.subsidy-table th {
  background: rgba(11, 93, 30, 0.03);
  padding: 14px 20px;
  font-size: 11px;
  font-weight: 800;
  color: #0B5D1E;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.subsidy-table td { padding: 16px 20px; border-bottom: 1px solid rgba(11, 93, 30, 0.05); font-size: 14px; }

.id-sub { font-family: monospace; font-weight: 700; color: #2196F3; }
.entity-id { display: block; font-weight: 800; color: #0f172a; }
.entity-name { display: block; font-size: 12px; color: #64748b; }
.amount-cell { font-weight: 800; color: #0f172a; }

/* Status Pills avec vos couleurs */
.status-pill {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
}
.status-pill.pending { background: rgba(255, 152, 0, 0.1); color: #FF9800; }
.status-pill.paid { background: rgba(76, 175, 80, 0.1); color: #4CAF50; }
.status-pill.approved { background: rgba(33, 150, 243, 0.1); color: #2196F3; }
.status-pill.rejected { background: rgba(244, 67, 54, 0.1); color: #F44336; }

.btn-icon { background: none; border: none; color: #94a3b8; cursor: pointer; padding: 5px; transition: 0.2s; }
.btn-icon:hover { color: #0B5D1E; }

/* ==========================================================================
   4. PAGINATION
   ========================================================================== */
.pagination {
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #64748b;
  font-size: 13px;
  font-weight: 600;
}
.page-controls { display: flex; gap: 5px; }
.btn-page {
  padding: 6px 12px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  background: white;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 700;
  color: #063B16;
  transition: all 0.2s;
}
.btn-page:hover:not(:disabled) { background: rgba(11, 93, 30, 0.1); }
.btn-page.active { background: #0B5D1E; color: white; border-color: #0B5D1E; }
.btn-page:disabled { opacity: 0.5; cursor: not-allowed; }

/* ==========================================================================
   5. GRAPHIQUE
   ========================================================================== */
.chart-section {
  background: white;
  border-radius: 12px;
  border: 1px solid rgba(11, 93, 30, 0.08);
  padding: 25px;
  margin-top: 25px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
}
.chart-header h3 {
  margin: 0 0 20px 0;
  font-size: 16px;
  font-weight: 800;
  color: #0f172a;
  display: flex;
  align-items: center;
  gap: 10px;
}
.chart-header i { color: #0B5D1E; }

.chart-placeholder {
  height: 250px;
  display: flex;
  align-items: flex-end;
  padding: 20px;
  background: rgba(11, 93, 30, 0.02);
  border-radius: 8px;
}
.bar-chart { display: flex; align-items: flex-end; gap: 50px; height: 100%; width: 100%; justify-content: center; }
.bar-item { display: flex; flex-direction: column; align-items: center; width: 60px; }
.bar {
  width: 100%;
  background: linear-gradient(to top, #063B16, #0B5D1E);
  border-radius: 6px 6px 0 0;
  transition: height 0.6s cubic-bezier(0.4, 0, 0.2, 1);
  min-height: 5px;
}
.bar-label { margin-top: 12px; font-size: 11px; font-weight: 800; color: #64748b; }

/* ==========================================================================
   6. RESPONSIVE
   ========================================================================== */
@media (max-width: 1200px) {
  .top-stats-grid { grid-template-columns: repeat(2, 1fr); }
}
</style>