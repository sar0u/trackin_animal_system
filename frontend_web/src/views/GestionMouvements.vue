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
        <tr v-for="mvt in filteredMovements" :key="mvt.id">
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
import { ref, computed, onMounted } from 'vue';
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
    // 1. Recherche texte (q vide = tout afficher)
    const matchesSearch = !rawQ ||
        String(m.id || '').includes(rawQ) ||
        String(m.animal?.id || '').includes(rawQ) ||
        (m.fromFarm?.name || '').toLowerCase().includes(q) ||
        (m.toFarm?.name || '').toLowerCase().includes(q);

    // 2. Filtre Statut
    const matchesStatus = !statusFilter.value || m.approvalStatus === statusFilter.value;

    // 3. Filtre Dates
    const mDate = m.createdAt ? new Date(m.createdAt).setHours(0,0,0,0) : null;
    const start = startDate.value ? new Date(startDate.value).setHours(0,0,0,0) : null;
    const end = endDate.value ? new Date(endDate.value).setHours(0,0,0,0) : null;

    let matchesDate = true;
    if (start && mDate && mDate < start) matchesDate = false;
    if (end && mDate && mDate > end) matchesDate = false;

    return matchesSearch && matchesStatus && matchesDate;
  });
});

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
/* --- STYLES DE BASE --- */
.movements-container { padding: 30px; background-color: #f8fafc; min-height: 100vh; font-family: 'Inter', sans-serif; color: #1f2937; }
.header-section { display: flex; flex-direction: column; margin-bottom: 25px; }
.title-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
h1 { font-size: 24px; font-weight: 800; margin: 0; color: #111827; }
.subtitle { font-size: 14px; color: #6b7280; margin-top: 5px; }

/* KPI cards */
.kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 24px; }
.kpi-card { background: white; padding: 20px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #e5e7eb; border-top: 4px solid #0B5D1E; }
.kpi-label { font-size: 11px; font-weight: 700; color: #6b7280; text-transform: uppercase; letter-spacing: 0.5px; }
.kpi-value { font-size: 26px; font-weight: 800; color: #111827; margin: 8px 0; }
.kpi-footer { font-size: 12px; font-weight: 600; color: #063B16; }
.kpi-bar-bg { height: 5px; background: #f3f4f6; border-radius: 3px; margin-top: 8px; }
.kpi-bar { height: 100%; border-radius: 3px; }
.kpi-bar.green { background: #0B5D1E; }
.kpi-bar.yellow { background: #eab308; }
.kpi-bar.red { background: #ef4444; }

/* Filters */
.filters-bar { display: flex; justify-content: space-between; align-items: center; background: white; padding: 15px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 20px; flex-wrap: wrap; gap: 15px; }
.search-box { display: flex; align-items: center; background: #f3f4f6; padding: 8px 15px; border-radius: 8px; width: 350px; }
.search-box i { color: #9ca3af; margin-right: 10px; }
.search-box input { border: none; background: transparent; width: 100%; outline: none; font-size: 14px; }

.date-filters { display: flex; gap: 15px; }
.date-input-group { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #4b5563; font-weight: 500; }
.date-input-group label { font-size: 12px; font-weight: 600; }
.filter-date { padding: 6px 10px; border: 1px solid #e5e7eb; border-radius: 6px; outline: none; font-family: 'Inter', sans-serif; color: #374151; }

.filter-select { padding: 8px 15px; border: 1px solid #e5e7eb; border-radius: 8px; outline: none; background: white; color: #374151; font-size: 14px; cursor: pointer; }

/* Tableau */
.table-wrapper { background: white; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden; }
table { width: 100%; border-collapse: collapse; }
th { text-align: left; padding: 15px 20px; font-size: 12px; font-weight: 700; color: #6b7280; text-transform: uppercase; border-bottom: 1px solid #f3f4f6; }
td { padding: 15px 20px; border-bottom: 1px solid #f3f4f6; font-size: 14px; vertical-align: middle; }

.empty-row { text-align: center; color: #9ca3af; font-style: italic; padding: 30px; }

.mvt-id { font-weight: 700; color: #0B5D1E; font-family: monospace; }
.animal-id { font-family: monospace; font-weight: 600; color: #3b82f6; }
.badge-reason { background: #f1f5f9; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 600; color: #475569; }

.badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; }
.badge-green { background: #d1fae5; color: #047857; }
.badge-yellow { background: #fef3c7; color: #d97706; }
.badge-red { background: #fee2e2; color: #b91c1c; }
.badge-gray { background: #e5e7eb; color: #374151; }

.btn { display: inline-flex; align-items: center; gap: 8px; padding: 10px 15px; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; transition: 0.2s; }
.btn-secondary { background: #f3f4f6; color: #374151; border: 1px solid #e5e7eb; }
.btn-secondary:hover { background: #e5e7eb; }
.btn-icon-only { padding: 8px; width: 32px; height: 32px; justify-content: center; }
.btn-sm { padding: 6px 12px; font-size: 12px; }

/* Modal */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0, 0, 0, 0.55); display: flex; justify-content: center; align-items: center; z-index: 1000; }
.modal-content { background: white; width: 100%; max-width: 600px; border-radius: 12px; padding: 25px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); animation: modalFadeIn 0.3s ease-out; max-height: 90vh; overflow-y: auto; }
@keyframes modalFadeIn { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }
.modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid #f3f4f6; padding-bottom: 15px; }
.modal-header h2 { margin: 0; font-size: 18px; color: #111827; font-weight: 800; display: flex; align-items: center; gap: 10px; }
.mvt-id-header { font-family: monospace; color: #0B5D1E; }
.close-btn { background: none; border: none; font-size: 18px; color: #9ca3af; cursor: pointer; transition: color 0.2s; }
.close-btn:hover { color: #ef4444; }
.modal-body { padding: 5px 0; display: flex; flex-direction: column; gap: 16px; }
.detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.info-block label { display: flex; align-items: center; gap: 6px; font-size: 11px; font-weight: 700; color: #6b7280; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px; }
.info-block p { background: #f1f5f9; padding: 10px 14px; border-radius: 8px; margin: 0; font-size: 14px; color: #1f2937; font-weight: 600; }
.mono-val { font-family: monospace !important; color: #3b82f6 !important; }
.note-block p { background: #fffbeb; border-left: 4px solid #f59e0b; }
.status-manager { border-top: 1px dashed #cbd5e1; padding-top: 18px; }
.status-manager h3 { margin: 0 0 14px 0; font-size: 14px; font-weight: 800; color: #111827; display: flex; align-items: center; gap: 8px; }
.status-options { display: flex; gap: 10px; flex-wrap: wrap; }
.btn-status { padding: 9px 16px; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; transition: 0.2s; border: 1.5px solid #e2e8f0; background: white; color: #6b7280; font-family: 'Inter', sans-serif; display: inline-flex; align-items: center; gap: 6px; }
.btn-status:hover { background: #f8fafc; color: #111827; }
.btn-status.pending.active { background: #fef9c3; color: #854d0e; border-color: #fde68a; }
.btn-status.approved.active { background: #dcfce7; color: #063B16; border-color: #86efac; }
.btn-status.rejected.active { background: #fee2e2; color: #b91c1c; border-color: #fca5a5; }
.approved-lock-banner { display: flex; align-items: center; gap: 10px; background: #f0fdf4; border: 1px solid #86efac; border-radius: 8px; padding: 12px 16px; font-size: 13px; color: #063B16; font-weight: 500; }
.approved-lock-banner i { font-size: 15px; flex-shrink: 0; }

@media (max-width: 1024px) {
  .kpi-grid { grid-template-columns: repeat(2, 1fr); }
}
</style>