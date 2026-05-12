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
            <button :class="['toggle-btn', { active: viewMode === 'animal' }]" @click="viewMode = 'animal'">
              <i class="fas fa-list"></i> Par Animal
            </button>
            <button :class="['toggle-btn', { active: viewMode === 'farm' }]" @click="viewMode = 'farm'">
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
          <tr v-for="sub in filteredSubsidies" :key="sub.id">
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

        <div class="pagination-bar">
          <span class="pagination-info" v-if="viewMode === 'animal'">
            Affichage de {{ filteredSubsidies.length }} sur {{ totalCount }} aides
          </span>
          <span class="pagination-info" v-else>
            {{ subsidiesByFarm.length }} ferme{{ subsidiesByFarm.length > 1 ? 's' : '' }} · {{ filteredSubsidies.length }} subvention{{ filteredSubsidies.length > 1 ? 's' : '' }}
          </span>
          <div class="pagination-controls">
            <button class="page-btn active">1</button>
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
            <h2><i class="fas fa-building" style="color:#3b82f6;margin-right:8px;"></i>{{ selectedFarm.farmName }}</h2>
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
import { ref, computed, onMounted } from 'vue';
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
const viewMode = ref('animal'); // 'animal' | 'farm'

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

// --- Filtrage commun (sert aux deux vues) ---
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

  // Summary block at the top
  const now = new Date().toLocaleDateString('fr-FR');
  const totalAmt = rows.reduce((acc, s) => acc + (Number(s.amount) || 0), 0).toFixed(2);
  const summary = [
    `"Rapport des Subventions — ${now}"`,
    `"Filtres actifs : statut=${statusFilter.value || 'Tous'}, type=${typeFilter.value || 'Tous'}, recherche=${searchQuery.value || 'Aucune'}"`,
    `"Nombre de subventions : ${rows.length} | Montant total : ${totalAmt} DZD"`,
    '',
  ];

  const csvContent = '﻿' + summary.join('\n') + '\n' + [headers.join(','), ...csvRows].join('\n');
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
/* --- BASE --- */
.main-content { padding: 30px; background-color: #f8fafc; min-height: 100vh; font-family: 'Inter', sans-serif; color: #1f2937; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
h1 { font-size: 24px; font-weight: 800; margin: 0; color: #111827; }
.subtitle { font-size: 14px; color: #6b7280; margin-top: 5px; }
.api-error-banner { background: #fee2e2; color: #b91c1c; padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; font-weight: 600; }

.btn { display: inline-flex; align-items: center; gap: 8px; padding: 10px 20px; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; transition: 0.2s; }
.btn-secondary { background: #f3f4f6; color: #374151; border: 1px solid #e5e7eb; }
.btn-secondary:hover { background: #e5e7eb; }
.btn-sm { padding: 6px 10px; font-size: 13px; }
.btn-icon-only { width: 32px; height: 32px; padding: 0; justify-content: center; }

/* --- STATS --- */
.top-stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; margin-bottom: 24px; }
.stat-card { background: white; padding: 20px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); border-top: 4px solid #e5e7eb; display: flex; flex-direction: column; align-items: flex-start; }
.border-blue { border-top-color: #3b82f6; }
.border-green { border-top-color: #0B5D1E; }
.border-red { border-top-color: #ef4444; }
.border-gray { border-top-color: #9ca3af; }
.stat-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 10px; width: 100%; }
.stat-icon-bg { width: 40px; height: 40px; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 18px; }
.bg-light-blue  { background: #eff6ff; color: #3b82f6; }
.bg-light-gray  { background: #f1f5f9; color: #64748b; }
.bg-light-green { background: #f0fdf4; color: #0B5D1E; }
.bg-light-red   { background: #fef2f2; color: #ef4444; }
.stat-body { width: 100%; }
.stat-label { display: block; color: #6b7280; font-size: 13px; font-weight: 600; margin-bottom: 4px; }
.stat-value { display: block; font-size: 26px; font-weight: 900; color: #111827; }

/* --- FILTRES + TOGGLE --- */
.main-list-section { display: flex; flex-direction: column; gap: 0; }
.filters-bar { display: flex; justify-content: space-between; align-items: center; background: white; padding: 15px; border-radius: 12px 12px 0 0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); flex-wrap: wrap; gap: 15px; border-bottom: none; }
.search-box { display: flex; align-items: center; background: #f3f4f6; padding: 8px 15px; border-radius: 8px; width: 320px; }
.search-box i { color: #9ca3af; margin-right: 10px; }
.search-box input { border: none; background: transparent; width: 100%; outline: none; font-size: 14px; }
.filter-actions { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.filter-select { padding: 8px 15px; border: 1px solid #e5e7eb; border-radius: 8px; outline: none; background: white; color: #374151; font-size: 14px; cursor: pointer; }

.view-toggle { display: flex; background: #f3f4f6; border-radius: 8px; padding: 3px; gap: 2px; }
.toggle-btn { padding: 6px 14px; border: none; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer; background: transparent; color: #6b7280; transition: 0.15s; display: flex; align-items: center; gap: 6px; }
.toggle-btn.active { background: white; color: #111827; box-shadow: 0 1px 3px rgba(0,0,0,0.12); }
.toggle-btn:hover:not(.active) { color: #374151; }

/* --- TABLEAU --- */
.table-wrapper { background: white; border-radius: 0 0 12px 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden; overflow-x: auto; }
.data-table { width: 100%; border-collapse: collapse; }
th { text-align: left; padding: 15px 20px; font-size: 12px; font-weight: 700; color: #6b7280; text-transform: uppercase; border-bottom: 1px solid #f3f4f6; white-space: nowrap; }
td { padding: 15px 20px; border-bottom: 1px solid #f3f4f6; font-size: 14px; vertical-align: middle; }
.center-th { text-align: center; }
.center-td { text-align: center; }

.id-sub { font-family: monospace; font-weight: 700; color: #3b82f6; }
.id-entity .entity-id { display: block; font-weight: 800; color: #111827; }
.id-entity .entity-name { display: block; font-size: 12px; color: #6b7280; margin-top: 2px; }
.amount-cell { font-weight: 800; color: #111827; }

.count-badge { display: inline-block; background: #f1f5f9; color: #1e40af; font-weight: 800; font-size: 15px; padding: 2px 12px; border-radius: 20px; }

.status-pills { display: flex; gap: 5px; flex-wrap: wrap; }

.badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; white-space: nowrap; }
.badge-yellow { background: #fef3c7; color: #d97706; }
.badge-blue   { background: #dbeafe; color: #1e40af; }
.badge-green  { background: #d1fae5; color: #047857; }
.badge-red    { background: #fee2e2; color: #b91c1c; }
.badge-gray   { background: #e5e7eb; color: #374151; }

/* --- PAGINATION --- */
.pagination-bar { display: flex; justify-content: space-between; align-items: center; padding: 15px 20px; color: #6b7280; font-size: 13px; background: white; border-top: 1px solid #f3f4f6; }
.pagination-info { font-weight: 500; }
.pagination-controls { display: flex; gap: 5px; }
.page-btn { width: 30px; height: 30px; border: 1px solid #e5e7eb; background: white; border-radius: 6px; cursor: pointer; color: #374151; font-weight: 600; }
.page-btn.active { background: #0B5D1E; color: white; border-color: #0B5D1E; }

/* --- MODAL COMMUN --- */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; backdrop-filter: blur(4px); }
.modal-card { background: white; width: 100%; max-width: 620px; border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); animation: modalFadeIn 0.25s ease-out; max-height: 90vh; overflow-y: auto; }
.modal-farm { max-width: 820px; }
@keyframes modalFadeIn { from { opacity: 0; transform: translateY(-16px); } to { opacity: 1; transform: translateY(0); } }

.modal-header { display: flex; justify-content: space-between; align-items: flex-start; padding: 20px 25px; border-bottom: 1px solid #f3f4f6; }
.modal-header h2 { margin: 0; font-size: 18px; color: #111827; font-weight: 800; }
.farm-modal-subtitle { margin: 5px 0 0; font-size: 13px; color: #6b7280; }
.modal-close { background: none; border: none; font-size: 18px; color: #9ca3af; cursor: pointer; transition: color 0.2s; flex-shrink: 0; }
.modal-close:hover { color: #ef4444; }

.farm-status-summary { display: flex; gap: 8px; flex-wrap: wrap; padding: 12px 25px; background: #f8fafc; border-bottom: 1px solid #f3f4f6; }

/* --- MODAL SUBVENTION (par animal) --- */
.modal-body { padding: 24px; }
.info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-bottom: 24px; }
.info-item { display: flex; flex-direction: column; gap: 5px; }
.info-item.full-width { grid-column: span 2; }
.info-item label { font-size: 11px; font-weight: 700; color: #6b7280; text-transform: uppercase; letter-spacing: 0.5px; }
.info-item p { margin: 0; font-size: 14px; font-weight: 600; color: #111827; }
.info-item p.amount { font-size: 18px; font-weight: 900; color: #3b82f6; }
.notes-text { background: #f8fafc; padding: 12px; border-radius: 8px; border: 1px solid #e2e8f0; font-style: italic; color: #475569; font-weight: 500 !important; }

.status-manager { border-top: 1px dashed #cbd5e1; padding-top: 20px; }
.status-manager h3 { margin: 0 0 14px; font-size: 14px; font-weight: 800; color: #111827; }
.status-options { display: flex; gap: 10px; flex-wrap: wrap; }
.btn-status { padding: 9px 16px; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; transition: 0.2s; border: 1.5px solid #e2e8f0; background: white; color: #6b7280; font-family: 'Inter', sans-serif; }
.btn-status:hover { background: #f8fafc; color: #111827; }
.btn-status.pending.active  { background: #fef9c3; color: #854d0e; border-color: #fde68a; }
.btn-status.approved.active { background: #dbeafe; color: #1e40af; border-color: #93c5fd; }
.btn-status.paid.active     { background: #dcfce7; color: #063B16; border-color: #86efac; }
.btn-status.rejected.active { background: #fee2e2; color: #b91c1c; border-color: #fca5a5; }

/* --- TABLE DÉTAIL FERME (dans modal) --- */
.farm-detail-table th { padding: 12px 16px; }
.farm-detail-table td { padding: 12px 16px; }
</style>
