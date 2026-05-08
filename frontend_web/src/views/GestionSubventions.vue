<template>
  <div class="main-content">
    <div class="page-header">
      <div>
        <h1>Portail des Subventions & Aides Financières</h1>
        <p class="subtitle">Pilotage budgétaire et suivi des versements aux exploitants</p>
      </div>
      <button class="btn btn-secondary" @click="exportData">
        <i class="fas fa-download"></i> Exporter Rapport
      </button>
    </div>

    <p v-if="loadError" class="api-error-banner">{{ loadError }}</p>

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
          <input type="text" v-model="searchQuery" :placeholder="viewMode === 'animal' ? 'Rechercher par animal, exploitant...' : 'Rechercher par ferme, exploitant...'">
        </div>
        <div class="filter-actions">
          <select v-model="statusFilter" class="filter-select">
            <option value="">Tous les Statuts</option>
            <option value="Pending">En attente</option>
            <option value="Approved">Approuvée</option>
            <option value="Paid">Payée</option>
            <option value="Rejected">Rejetée</option>
          </select>
          <select v-model="typeFilter" class="filter-select">
            <option value="">Tous les Types</option>
            <option value="Aide Bio">Aide Bio</option>
            <option value="Bien-être animal">Bien-être animal</option>
            <option value="Modernisation">Modernisation</option>
          </select>
          <div class="view-toggle">
            <button :class="['toggle-btn', { active: viewMode === 'animal' }]" @click="switchView('animal')">
              <i class="fas fa-list"></i> Par Animal
            </button>
            <button :class="['toggle-btn', { active: viewMode === 'farm' }]" @click="switchView('farm')">
              <i class="fas fa-building"></i> Par Ferme
            </button>
          </div>
        </div>
      </div>

      <div class="table-wrapper">

        <!-- ===== VUE PAR ANIMAL ===== -->
        <table v-if="viewMode === 'animal'" class="data-table">
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
              <span class="entity-id">ANI-{{ sub.animal?.id || '--' }}</span>
              <span class="entity-name">{{ ownerLabel(sub) }}</span>
            </td>
            <td>{{ sub.type }}</td>
            <td class="amount-cell">{{ formatNumber(sub.amount) }}</td>
            <td>
              <span :class="['badge', getSubsidyStatusClass(sub.status)]">{{ translateSubsidyStatus(sub.status) }}</span>
            </td>
            <td>{{ formatDate(sub.requestDate) }}</td>
            <td>{{ sub.paidDate ? formatDate(sub.paidDate) : '—' }}</td>
            <td class="actions-cell">
              <button class="btn btn-secondary btn-icon-only btn-sm" title="Détails" @click="openDetails(sub)">
                <i class="fas fa-eye"></i>
              </button>
            </td>
          </tr>
          </tbody>
        </table>

        <!-- ===== VUE PAR FERME ===== -->
        <table v-else class="data-table">
          <thead>
          <tr>
            <th>FERME / EXPLOITANT</th>
            <th class="center-th">NB SUBVENTIONS</th>
            <th>MONTANT TOTAL (DZD)</th>
            <th>STATUTS</th>
            <th class="center-th">DÉTAILS</th>
          </tr>
          </thead>
          <tbody>
          <tr v-if="isLoading">
            <td colspan="5" style="text-align: center; padding: 40px;">Chargement des données...</td>
          </tr>
          <tr v-else-if="subsidiesByFarm.length === 0">
            <td colspan="5" style="text-align: center; padding: 40px;">Aucune subvention trouvée.</td>
          </tr>
          <tr v-for="group in subsidiesByFarm" :key="group.farmId">
            <td class="id-entity">
              <span class="entity-id">{{ group.farmName }}</span>
              <span class="entity-name">{{ group.ownerName }}</span>
            </td>
            <td class="center-td">
              <span class="count-badge">{{ group.count }}</span>
            </td>
            <td class="amount-cell">{{ formatNumber(group.totalAmount) }}</td>
            <td>
              <div class="status-pills">
                <span v-if="group.pending"  class="badge badge-yellow">{{ group.pending }} En attente</span>
                <span v-if="group.approved" class="badge badge-blue">{{ group.approved }} Approuvée{{ group.approved > 1 ? 's' : '' }}</span>
                <span v-if="group.paid"     class="badge badge-green">{{ group.paid }} Payée{{ group.paid > 1 ? 's' : '' }}</span>
                <span v-if="group.rejected" class="badge badge-red">{{ group.rejected }} Rejetée{{ group.rejected > 1 ? 's' : '' }}</span>
              </div>
            </td>
            <td class="center-td">
              <button class="btn btn-secondary btn-icon-only btn-sm" title="Voir les animaux" @click="openFarmDetails(group)">
                <i class="fas fa-eye"></i>
              </button>
            </td>
          </tr>
          </tbody>
        </table>

        <!-- Pagination -->
        <div class="pagination-bar">
          <span class="pagination-info" v-if="viewMode === 'animal'">
            Affichage de {{ paginationStart }} à {{ paginationEnd }} sur {{ filteredSubsidies.length }} aides
          </span>
          <span class="pagination-info" v-else>
            {{ subsidiesByFarm.length }} ferme{{ subsidiesByFarm.length > 1 ? 's' : '' }} · {{ filteredSubsidies.length }} subvention{{ filteredSubsidies.length > 1 ? 's' : '' }}
          </span>
          <div class="pagination-controls" v-if="viewMode === 'animal' && totalPages > 1">
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
    </div>

    <!-- ===== MODAL DÉTAILS SUBVENTION (par animal) ===== -->
    <div class="modal-overlay" v-if="showModal" @click.self="closeModal">
      <div class="modal-card modal-lg">
        <div class="modal-header">
          <h2>Détails de la Subvention #SUB-{{ selectedSubsidy.id }}</h2>
          <button class="modal-close" @click="closeModal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="info-grid">
            <div class="info-item">
              <label>Exploitant (Demandeur)</label>
              <p>{{ ownerLabel(selectedSubsidy) }}</p>
            </div>
            <div class="info-item">
              <label>Animal concerné</label>
              <p>ANI-{{ selectedSubsidy.animal?.id || 'Aucun' }}</p>
            </div>
            <div class="info-item">
              <label>Ferme</label>
              <p>{{ selectedSubsidy.animal?.farm?.name || '—' }}</p>
            </div>
            <div class="info-item">
              <label>Type de subvention</label>
              <p>{{ selectedSubsidy.type || selectedSubsidy.subsidyType }}</p>
            </div>
            <div class="info-item">
              <label>Montant</label>
              <p class="amount">{{ formatCurrency(selectedSubsidy.amount) }}</p>
            </div>
            <div class="info-item">
              <label>Date de demande</label>
              <p>{{ formatDate(selectedSubsidy.requestDate) }}</p>
            </div>
            <div class="info-item">
              <label>Date d'approbation</label>
              <p>{{ selectedSubsidy.approvedDate ? formatDate(selectedSubsidy.approvedDate) : 'Non approuvé' }}</p>
            </div>
            <div class="info-item">
              <label>Traité par</label>
              <p>{{ selectedSubsidy.treatedBy ? ((selectedSubsidy.treatedBy.firstName || '') + ' ' + (selectedSubsidy.treatedBy.lastName || '')).trim() || selectedSubsidy.treatedBy.username : '—' }}</p>
            </div>
            <div class="info-item">
              <label>Date de paiement</label>
              <p>{{ selectedSubsidy.paidDate ? formatDate(selectedSubsidy.paidDate) : 'Non payé' }}</p>
            </div>
            <div class="info-item full-width">
              <label>Notes & Commentaires</label>
              <p class="notes-text">{{ selectedSubsidy.notes || 'Aucun commentaire.' }}</p>
            </div>
          </div>

          <div class="status-manager">
            <h3>Modifier le Statut</h3>
            <div class="status-options">
              <button class="btn-status pending"  :class="{ active: selectedSubsidy.status === 'Pending' }"  @click="updateStatus('Pending')">En attente</button>
              <button class="btn-status approved" :class="{ active: selectedSubsidy.status === 'Approved' }" @click="updateStatus('Approved')">Approuver</button>
              <button class="btn-status paid"     :class="{ active: selectedSubsidy.status === 'Paid' }"     @click="updateStatus('Paid')">Payée</button>
              <button class="btn-status rejected" :class="{ active: selectedSubsidy.status === 'Rejected' }" @click="updateStatus('Rejected')">Rejeter</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ===== MODAL DÉTAILS FERME ===== -->
    <div class="modal-overlay" v-if="showFarmModal && selectedFarm" @click.self="closeFarmModal">
      <div class="modal-card modal-farm">
        <div class="modal-header">
          <div>
            <h2><i class="fas fa-building" style="color:#2196F3;margin-right:8px;"></i>{{ selectedFarm.farmName }}</h2>
            <p class="farm-modal-subtitle">
              Exploitant : <strong>{{ selectedFarm.ownerName }}</strong>
              &nbsp;·&nbsp; {{ selectedFarm.count }} subvention{{ selectedFarm.count > 1 ? 's' : '' }}
              &nbsp;·&nbsp; Total : <strong>{{ formatCurrency(selectedFarm.totalAmount) }}</strong>
            </p>
          </div>
          <button class="modal-close" @click="closeFarmModal"><i class="fas fa-times"></i></button>
        </div>

        <div class="farm-status-summary">
          <span v-if="selectedFarm.pending"  class="badge badge-yellow">{{ selectedFarm.pending }} En attente</span>
          <span v-if="selectedFarm.approved" class="badge badge-blue">{{ selectedFarm.approved }} Approuvée{{ selectedFarm.approved > 1 ? 's' : '' }}</span>
          <span v-if="selectedFarm.paid"     class="badge badge-green">{{ selectedFarm.paid }} Payée{{ selectedFarm.paid > 1 ? 's' : '' }}</span>
          <span v-if="selectedFarm.rejected" class="badge badge-red">{{ selectedFarm.rejected }} Rejetée{{ selectedFarm.rejected > 1 ? 's' : '' }}</span>
        </div>

        <div class="modal-body" style="padding:0;">
          <table class="data-table farm-detail-table">
            <thead>
            <tr>
              <th>ANIMAL</th>
              <th>TYPE</th>
              <th>MONTANT (DZD)</th>
              <th>STATUT</th>
              <th>DATE DEMANDE</th>
              <th>DATE PAIEMENT</th>
            </tr>
            </thead>
            <tbody>
            <tr v-for="sub in selectedFarm.subsidies" :key="sub.id">
              <td>
                <span class="entity-id">ANI-{{ sub.animal?.id || '--' }}</span>
                <span class="entity-name">{{ sub.animal?.species || '' }}</span>
              </td>
              <td>{{ sub.type || '—' }}</td>
              <td class="amount-cell">{{ formatNumber(sub.amount) }}</td>
              <td><span :class="['badge', getSubsidyStatusClass(sub.status)]">{{ translateSubsidyStatus(sub.status) }}</span></td>
              <td>{{ formatDate(sub.requestDate) }}</td>
              <td>{{ sub.paidDate ? formatDate(sub.paidDate) : '—' }}</td>
            </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import api from '../services/api';

const translateSubsidyStatus = (status) => {
  const map = { Pending: 'En attente', Approved: 'Approuvée', Paid: 'Payée', Rejected: 'Rejetée' };
  return map[status] || status;
};

const getSubsidyStatusClass = (status) => {
  const map = { Pending: 'badge-yellow', Approved: 'badge-blue', Paid: 'badge-green', Rejected: 'badge-red' };
  return map[status] || 'badge-gray';
};

// --- États réactifs ---
const subsidies  = ref([]);
const isLoading  = ref(true);
const loadError  = ref('');

// --- Vue active ---
const viewMode = ref('animal');

// --- Modal subvention (par animal) ---
const showModal       = ref(false);
const selectedSubsidy = ref(null);

// --- Modal détail ferme ---
const showFarmModal = ref(false);
const selectedFarm  = ref(null);

// --- Filtres ---
const searchQuery  = ref('');
const statusFilter = ref('');
const typeFilter   = ref('');

// --- Pagination ---
const currentPage = ref(1);
const itemsPerPage = 5;

// --- Stats calculées ---
const totalBudget  = ref(0);
const totalCount   = ref(0);
const paymentRate  = ref(0);
const alertsCount  = ref(0);

const pendingCount = computed(() => subsidies.value.filter(s => s.status === 'Pending').length);

// --- Helpers ---
const ownerLabel = (sub) => {
  const o = sub.animal?.owner;
  if (o) return `${o.firstName || ''} ${o.lastName || ''}`.trim() || '—';
  return sub.treatedBy?.username || 'Non assigné';
};

// --- Filtrage commun ---
const filteredSubsidies = computed(() => {
  const q = searchQuery.value.trim().toLowerCase();
  return subsidies.value.filter(s => {
    const owner     = ownerLabel(s).toLowerCase();
    const farmName  = (s.animal?.farm?.name || '').toLowerCase();
    const matchSearch = !q ||
      owner.includes(q) ||
      farmName.includes(q) ||
      (s.treatedBy?.username && s.treatedBy.username.toLowerCase().includes(q)) ||
      (s.id != null && String(s.id).includes(q)) ||
      (s.animal?.id != null && String(s.animal.id).includes(q));
    const matchStatus = !statusFilter.value || s.status === statusFilter.value;
    const matchType   = !typeFilter.value   || s.type   === typeFilter.value;
    return matchSearch && matchStatus && matchType;
  });
});

// --- Pagination calculée ---
const paginatedSubsidies = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredSubsidies.value.slice(start, start + itemsPerPage);
});

const totalPages = computed(() => Math.ceil(filteredSubsidies.value.length / itemsPerPage));

const paginationStart = computed(() => {
  if (filteredSubsidies.value.length === 0) return 0;
  return (currentPage.value - 1) * itemsPerPage + 1;
});

const paginationEnd = computed(() => {
  return Math.min(currentPage.value * itemsPerPage, filteredSubsidies.value.length);
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

// --- Navigation pagination ---
const prevPage = () => {
  if (currentPage.value > 1) currentPage.value--;
};

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++;
};

const setPage = (page) => {
  currentPage.value = page;
};

const switchView = (mode) => {
  viewMode.value = mode;
  currentPage.value = 1;
};

// --- Réinitialiser la page quand les filtres changent ---
watch([searchQuery, statusFilter, typeFilter], () => {
  currentPage.value = 1;
});

// --- Groupement par ferme ---
const subsidiesByFarm = computed(() => {
  const groups = {};
  filteredSubsidies.value.forEach(sub => {
    const farmId   = sub.animal?.farm?.id   ?? 'unknown';
    const farmName = sub.animal?.farm?.name ?? 'Ferme inconnue';
    const owner    = sub.animal?.owner;
    const ownerName = owner
      ? `${owner.firstName || ''} ${owner.lastName || ''}`.trim() || '—'
      : '—';

    if (!groups[farmId]) {
      groups[farmId] = { farmId, farmName, ownerName, totalAmount: 0, count: 0, pending: 0, approved: 0, paid: 0, rejected: 0, subsidies: [] };
    }
    const g = groups[farmId];
    g.totalAmount += Number(sub.amount) || 0;
    g.count++;
    if (sub.status === 'Pending')  g.pending++;
    else if (sub.status === 'Approved') g.approved++;
    else if (sub.status === 'Paid')     g.paid++;
    else if (sub.status === 'Rejected') g.rejected++;
    g.subsidies.push(sub);
  });
  return Object.values(groups).sort((a, b) => b.totalAmount - a.totalAmount);
});

// --- Chargement API ---
const fetchSubsidies = async () => {
  loadError.value = '';
  isLoading.value = true;
  try {
    const response = await api.get('/subsidies');
    const rows = response.data;
    subsidies.value = Array.isArray(rows) ? rows : [];
    if (!Array.isArray(rows)) loadError.value = 'Réponse API inattendue pour /subsidies (tableau attendu).';
    totalCount.value  = subsidies.value.length;
    totalBudget.value = subsidies.value.reduce((acc, s) => acc + (Number(s.amount) || 0), 0);
    const paidCount   = subsidies.value.filter(s => s.status === 'Paid').length;
    paymentRate.value = totalCount.value ? Number(((paidCount / totalCount.value) * 100).toFixed(1)) : 0;
    alertsCount.value = subsidies.value.filter(s => s.status === 'Rejected').length;
  } catch (error) {
    console.error('Erreur lors de la récupération des données', error);
    subsidies.value   = [];
    totalBudget.value = 0;
    totalCount.value  = 0;
    paymentRate.value = 0;
    alertsCount.value = 0;
    const msg = error.response?.data;
    loadError.value = typeof msg === 'string' ? msg : msg?.message || error.message || 'Impossible de charger les subventions.';
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => fetchSubsidies());

// --- Modal subvention (par animal) ---
const openDetails = (sub) => { selectedSubsidy.value = { ...sub }; showModal.value = true; };
const closeModal  = () => { showModal.value = false; selectedSubsidy.value = null; };

// --- Modal détail ferme ---
const openFarmDetails = (group) => { selectedFarm.value = group; showFarmModal.value = true; };
const closeFarmModal  = () => { showFarmModal.value = false; selectedFarm.value = null; };

// --- Mise à jour statut ---
const updateStatus = async (newStatus) => {
  if (!selectedSubsidy.value || selectedSubsidy.value.status === newStatus) return;
  if (!confirm(`Êtes-vous sûr de vouloir changer le statut à "${newStatus}" ?`)) return;
  try {
    const res = await api.put(`/subsidies/${selectedSubsidy.value.id}/status`, { status: newStatus });
    selectedSubsidy.value = res.data;
    const idx = subsidies.value.findIndex(s => s.id === res.data.id);
    if (idx !== -1) subsidies.value[idx] = res.data;
  } catch (error) {
    console.error('Erreur lors de la mise à jour du statut', error);
    alert('Une erreur est survenue lors de la mise à jour du statut.');
  }
};

// --- Formatage ---
const formatNumber   = (num) => num ? new Intl.NumberFormat('fr-FR', { minimumFractionDigits: 2 }).format(num) : '0,00';
const formatCurrency = (num) => new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'DZD' }).format(num || 0);
const formatDate     = (d)   => d ? new Intl.DateTimeFormat('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' }).format(new Date(d)) : '—';

const exportData = () => {
  const rows = filteredSubsidies.value;
  if (!rows.length) { alert('Aucune donnée à exporter.'); return; }

  const escape = (v) => {
    if (v == null) return '';
    const s = String(v).replace(/"/g, '""');
    return s.includes(',') || s.includes('\n') || s.includes('"') ? `"${s}"` : s;
  };

  const headers = [
    'ID Subvention', 'Animal ID', 'Espèce', 'Ferme', 'Exploitant',
    'Type', 'Montant (DZD)', 'Statut',
    'Date Demande', 'Date Approbation', 'Date Paiement',
    'Traité par', 'Notes'
  ];

  const csvRows = rows.map(s => {
    const year = s.requestDate ? s.requestDate.split('-')[0] : '2026';
    const approver = s.treatedBy
      ? `${s.treatedBy.firstName || ''} ${s.treatedBy.lastName || ''}`.trim() || s.treatedBy.username
      : '';
    return [
      `SUB-${year}-${s.id}`,
      s.animal?.id ? `ANI-${s.animal.id}` : '',
      s.animal?.species || '',
      s.animal?.farm?.name || '',
      ownerLabel(s),
      s.type || '',
      s.amount != null ? Number(s.amount).toFixed(2) : '',
      s.status || '',
      s.requestDate || '',
      s.approvedDate || '',
      s.paidDate || '',
      approver,
      s.notes || ''
    ].map(escape).join(',');
  });

  const now = new Date().toLocaleDateString('fr-FR');
  const totalAmt = rows.reduce((acc, s) => acc + (Number(s.amount) || 0), 0).toFixed(2);
  const summary = [
    `"Rapport des Subventions — ${now}"`,
    `"Filtres actifs : statut=${statusFilter.value || 'Tous'}, type=${typeFilter.value || 'Tous'}, recherche=${searchQuery.value || 'Aucune'}"`,
    `"Nombre de subventions : ${rows.length} | Montant total : ${totalAmt} DZD"`,
    '',
  ];

  const csvContent = '\uFEFF' + summary.join('\n') + '\n' + [headers.join(','), ...csvRows].join('\n');
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const url  = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href     = url;
  link.download = `subventions_${new Date().toISOString().split('T')[0]}.csv`;
  link.click();
  URL.revokeObjectURL(url);
};
</script>

<style scoped>
/* ==========================================================================
   1. BASE
   ========================================================================== */
.main-content {
  padding: 30px;
  background-color: #f4f7f6;
  min-height: 100vh;
  font-family: 'Inter', sans-serif;
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
   2. BOUTONS
   ========================================================================== */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
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

.btn-sm {
  padding: 6px 10px;
  font-size: 13px;
}

.btn-icon-only {
  width: 32px;
  height: 32px;
  padding: 0;
  justify-content: center;
}

/* ==========================================================================
   3. STATS (Mêmes dimensions que le dashboard)
   ========================================================================== */
.top-stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 25px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  border-left: 4px solid transparent;
  display: flex;
  align-items: center;
  gap: 20px;
}

.border-blue { border-left-color: #2196F3; }
.border-gray { border-left-color: #FF9800; }
.border-green { border-left-color: #4CAF50; }
.border-red { border-left-color: #F44336; }

.stat-header {
  display: flex;
  align-items: flex-start;
  margin-bottom: 0;
}

.stat-icon-bg {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  flex-shrink: 0;
}

.bg-light-blue { background: rgba(33, 150, 243, 0.1); color: #2196F3; }
.bg-light-gray { background: rgba(255, 152, 0, 0.1); color: #FF9800; }
.bg-light-green { background: rgba(76, 175, 80, 0.1); color: #4CAF50; }
.bg-light-red { background: rgba(244, 67, 54, 0.1); color: #F44336; }

.stat-body {
  display: flex;
  flex-direction: column;
}

.stat-label {
  display: block;
  color: #64748b;
  font-size: 10px;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 4px;
}

.stat-value {
  display: block;
  font-size: 24px;
  font-weight: 900;
  color: #0f172a;
  line-height: 1;
}

/* ==========================================================================
   4. FILTRES + TOGGLE
   ========================================================================== */
.main-list-section {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.filters-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  padding: 16px 25px;
  border-radius: 12px 12px 0 0;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  flex-wrap: wrap;
  gap: 20px;
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

.filter-actions {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
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

.filter-select:focus {
  border-color: #0B5D1E;
}

.view-toggle {
  display: flex;
  background: rgba(11, 93, 30, 0.05);
  border-radius: 8px;
  padding: 3px;
  gap: 2px;
}

.toggle-btn {
  padding: 6px 14px;
  border: none;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  background: transparent;
  color: #64748b;
  transition: 0.15s;
  display: flex;
  align-items: center;
  gap: 6px;
}

.toggle-btn.active {
  background: #0B5D1E;
  color: white;
}

.toggle-btn:hover:not(.active) {
  color: #063B16;
}

/* ==========================================================================
   5. TABLEAU
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
  padding: 14px 20px;
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
  padding: 16px 20px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.05);
  font-size: 14px;
  vertical-align: middle;
}

tr:hover {
  background-color: rgba(11, 93, 30, 0.02);
}

.center-th { text-align: center; }
.center-td { text-align: center; }

.id-sub {
  font-family: 'JetBrains Mono', monospace;
  font-weight: 700;
  color: #2196F3;
}

.id-entity .entity-id {
  display: block;
  font-weight: 800;
  color: #0f172a;
}

.id-entity .entity-name {
  display: block;
  font-size: 12px;
  color: #64748b;
  margin-top: 2px;
}

.amount-cell {
  font-weight: 800;
  color: #0f172a;
}

.count-badge {
  display: inline-block;
  background: rgba(33, 150, 243, 0.1);
  color: #2196F3;
  font-weight: 800;
  font-size: 15px;
  padding: 2px 12px;
  border-radius: 20px;
}

.status-pills {
  display: flex;
  gap: 5px;
  flex-wrap: wrap;
}

/* ==========================================================================
   6. BADGES (Vos couleurs)
   ========================================================================== */
.badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  white-space: nowrap;
  text-transform: uppercase;
}

.badge-yellow {
  background: rgba(255, 152, 0, 0.1);
  color: #FF9800;
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

.badge-gray {
  background: rgba(11, 93, 30, 0.05);
  color: #64748b;
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
}

.page-btn:hover {
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

.page-btn:disabled:hover {
  background: white;
}

/* ==========================================================================
   8. MODAL COMMUN
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

.modal-card {
  background: white;
  width: 100%;
  max-width: 620px;
  border-radius: 12px;
  box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
  animation: modalFadeIn 0.25s ease-out;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-farm {
  max-width: 820px;
}

@keyframes modalFadeIn {
  from { opacity: 0; transform: translateY(-16px); }
  to { opacity: 1; transform: translateY(0); }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 20px 25px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
}

.modal-header h2 {
  margin: 0;
  font-size: 18px;
  color: #063B16;
  font-weight: 800;
}

.farm-modal-subtitle {
  margin: 5px 0 0;
  font-size: 13px;
  color: #64748b;
}

.modal-close {
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
  flex-shrink: 0;
}

.modal-close:hover {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

.farm-status-summary {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  padding: 12px 25px;
  background: rgba(11, 93, 30, 0.02);
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
}

/* ==========================================================================
   9. MODAL SUBVENTION (par animal)
   ========================================================================== */
.modal-body {
  padding: 24px;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 18px;
  margin-bottom: 24px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.info-item.full-width {
  grid-column: span 2;
}

.info-item label {
  font-size: 11px;
  font-weight: 700;
  color: #0B5D1E;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.info-item p {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
  color: #063B16;
}

.info-item p.amount {
  font-size: 18px;
  font-weight: 900;
  color: #2196F3;
}

.notes-text {
  background: rgba(11, 93, 30, 0.03);
  padding: 12px;
  border-radius: 8px;
  border: 1px solid rgba(11, 93, 30, 0.1);
  font-style: italic;
  color: #475569;
  font-weight: 500 !important;
}

.status-manager {
  border-top: 1px dashed rgba(11, 93, 30, 0.15);
  padding-top: 20px;
}

.status-manager h3 {
  margin: 0 0 14px;
  font-size: 14px;
  font-weight: 800;
  color: #063B16;
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
  transition: 0.2s;
  border: 1.5px solid rgba(11, 93, 30, 0.15);
  background: white;
  color: #64748b;
  font-family: 'Inter', sans-serif;
}

.btn-status:hover {
  background: rgba(11, 93, 30, 0.05);
  color: #063B16;
}

.btn-status.pending.active {
  background: rgba(255, 152, 0, 0.1);
  color: #FF9800;
  border-color: rgba(255, 152, 0, 0.3);
}

.btn-status.approved.active {
  background: rgba(33, 150, 243, 0.1);
  color: #2196F3;
  border-color: rgba(33, 150, 243, 0.3);
}

.btn-status.paid.active {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
  border-color: rgba(76, 175, 80, 0.3);
}

.btn-status.rejected.active {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
  border-color: rgba(244, 67, 54, 0.3);
}

/* ==========================================================================
   10. TABLE DÉTAIL FERME (dans modal)
   ========================================================================== */
.farm-detail-table th {
  padding: 12px 16px;
}

.farm-detail-table td {
  padding: 12px 16px;
}

/* ==========================================================================
   11. RESPONSIVE
   ========================================================================== */
@media (max-width: 1200px) {
  .top-stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .filters-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .search-box {
    max-width: 100%;
  }
}
</style>
