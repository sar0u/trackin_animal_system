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
              <th>MONTANT (€)</th>
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
            <tr v-for="sub in filteredSubsidies" :key="sub.id">
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
          <span>Affichage de {{ filteredSubsidies.length }} sur {{ totalCount }} aides</span>
          <div class="page-controls">
            <button class="btn-page">Précédent</button>
            <button class="btn-page active">1</button>
            <button class="btn-page">Suivant</button>
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
import { ref, computed, onMounted } from 'vue';

// --- États Réactifs pour la BDD ---
const subsidies = ref([]);
const filieres = ref([]);
const isLoading = ref(true);

// --- Filtres ---
const searchQuery = ref('');
const statusFilter = ref('');
const typeFilter = ref('');

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

// --- Fonctions API (À connecter à ton Backend) ---
const fetchSubsidies = async () => {
  isLoading.ref = true;
  try {
    // ICI : Ton appel API Spring Boot
    // const response = await axios.get('/api/subsidies');
    // subsidies.value = response.data;

    // Pour l'instant, on laisse vide pour ta connexion
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
  background: #f8fafb;
  padding: 30px;
  min-height: 100vh;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.page-header h1 { font-size: 24px; font-weight: 800; color: #1a202c; margin: 0; }
.subtitle { color: #718096; font-size: 14px; margin-top: 4px; }

.btn-export {
  background: white;
  border: 1px solid #e2e8f0;
  padding: 10px 18px;
  border-radius: 8px;
  font-weight: 700;
  font-size: 13px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
}
.btn-export:hover { background: #f8fafc; border-color: #cbd5e0; }

/* ==========================================================================
   2. CARDS KPI (DESIGN IMAGE 2)
   ========================================================================== */
.top-stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
  border-top: 4px solid #cbd5e0; /* Fallback */
}

/* Bordures spécifiques */
.border-blue { border-top-color: #3b82f6; }
.border-green { border-top-color: #10b981; }
.border-red { border-top-color: #ef4444; }
.border-gray { border-top-color: #94a3b8; }

.stat-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 15px; }

.stat-icon-bg {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
}
.bg-light-blue { background: #eff6ff; color: #3b82f6; }
.bg-light-gray { background: #f1f5f9; color: #64748b; }
.bg-light-green { background: #f0fdf4; color: #10b981; }
.bg-light-red { background: #fef2f2; color: #ef4444; }

.trend-badge { font-size: 11px; font-weight: 800; padding: 2px 8px; border-radius: 12px; }
.trend-badge.positive { background: #dcfce7; color: #166534; }
.trend-badge.negative { background: #fee2e2; color: #991b1b; }

.stat-label { display: block; color: #718096; font-size: 14px; font-weight: 600; margin-bottom: 5px; }
.stat-value { display: block; font-size: 26px; font-weight: 900; color: #1a202c; }

/* ==========================================================================
   3. FILTRES & TABLEAU
   ========================================================================== */
.filters-bar {
  background: white;
  padding: 16px;
  border-radius: 12px 12px 0 0;
  border: 1px solid #edf2f7;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-box {
  background: #f3f4f6;
  padding: 8px 16px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 10px;
  width: 320px;
}
.search-box input { border: none; background: transparent; outline: none; width: 100%; font-size: 14px; }
.search-box i { color: #a0aec0; }

.filter-select {
  padding: 8px 12px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  margin-left: 10px;
  font-size: 13px;
  font-weight: 600;
  color: #4a5568;
}

.table-container-card {
  background: white;
  border: 1px solid #edf2f7;
  border-top: none;
  border-radius: 0 0 12px 12px;
  overflow: hidden;
}

.subsidy-table { width: 100%; border-collapse: collapse; text-align: left; }
.subsidy-table th {
  background: #f8fafc;
  padding: 14px 20px;
  font-size: 11px;
  font-weight: 800;
  color: #718096;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.subsidy-table td { padding: 16px 20px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }

.id-sub { font-family: monospace; font-weight: 700; color: #3b82f6; }
.entity-id { display: block; font-weight: 800; color: #1a202c; }
.entity-name { display: block; font-size: 12px; color: #718096; }
.amount-cell { font-weight: 800; color: #1a202c; }

/* Status Pills */
.status-pill {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
}
.status-pill.pending { background: #e0f2fe; color: #0369a1; }
.status-pill.paid { background: #dcfce7; color: #15803d; }
.status-pill.approved { background: #e0e7ff; color: #4338ca; }
.status-pill.rejected { background: #fee2e2; color: #b91c1c; }

.btn-icon { background: none; border: none; color: #a0aec0; cursor: pointer; padding: 5px; transition: 0.2s; }
.btn-icon:hover { color: #11D432; }

/* ==========================================================================
   4. PAGINATION
   ========================================================================== */
.pagination { padding: 20px; display: flex; justify-content: space-between; align-items: center; color: #718096; font-size: 13px; font-weight: 600; }
.page-controls { display: flex; gap: 5px; }
.btn-page {
  padding: 6px 12px;
  border: 1px solid #e2e8f0;
  background: white;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 700;
}
.btn-page.active { background: #1a202c; color: white; border-color: #1a202c; }

/* ==========================================================================
   5. GRAPHIQUE (DESIGN IMAGE 3)
   ========================================================================== */
.chart-section { background: white; border-radius: 12px; border: 1px solid #edf2f7; padding: 25px; margin-top: 30px; }
.chart-header h3 { margin: 0 0 20px 0; font-size: 16px; font-weight: 800; display: flex; align-items: center; gap: 10px; }
.chart-header i { color: #11D432; }

.chart-placeholder {
  height: 250px;
  display: flex;
  align-items: flex-end;
  padding: 20px;
  background: #fcfcfd;
  border-radius: 8px;
}
.bar-chart { display: flex; align-items: flex-end; gap: 50px; height: 100%; width: 100%; justify-content: center; }
.bar-item { display: flex; flex-direction: column; align-items: center; width: 60px; }
.bar {
  width: 100%;
  background: linear-gradient(to top, #3b82f6, #60a5fa);
  border-radius: 6px 6px 0 0;
  transition: height 0.6s cubic-bezier(0.4, 0, 0.2, 1);
  min-height: 5px;
}
.bar-label { margin-top: 12px; font-size: 11px; font-weight: 800; color: #64748b; }
</style>