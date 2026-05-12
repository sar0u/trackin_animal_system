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
      <div class="kpi-card">
        <span class="kpi-label">TOTAL</span>
        <div class="kpi-value">{{ reproductions.length }}</div>
      </div>
      <div class="kpi-card kpi-blue">
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
        <tr v-for="repro in filteredReproductions" :key="repro.id">
          <td class="mono-id">#RPR-{{ repro.id }}</td>
          <td>
            <span class="mono-id" style="color:#3b82f6;">#ANI-{{ repro.female?.id || '--' }}</span>
            <span class="sub-info">{{ [repro.female?.species, repro.female?.breed].filter(Boolean).join(' · ') }}</span>
          </td>
          <td>
            <span v-if="repro.male">
              <span class="mono-id" style="color:#8b5cf6;">#ANI-{{ repro.male.id }}</span>
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
    </div>

    <div class="stats-section">
      <h3 class="stats-title"><i class="fas fa-chart-bar"></i> Statistiques</h3>
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-icon" style="background:#ede9fe;color:#7c3aed;"><i class="fas fa-horse"></i></div>
          <div class="stat-body">
            <span class="stat-label">Taux de réussite</span>
            <span class="stat-value">{{ successRate }}%</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="background:#dcfce7;color:#063B16;"><i class="fas fa-baby"></i></div>
          <div class="stat-body">
            <span class="stat-label">Total naissances</span>
            <span class="stat-value">{{ totalOffspring }}</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="background:#dbeafe;color:#1d4ed8;"><i class="fas fa-calculator"></i></div>
          <div class="stat-body">
            <span class="stat-label">Moy. naissances / repro réussie</span>
            <span class="stat-value">{{ avgOffspring }}</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="background:#fef9c3;color:#a16207;"><i class="fas fa-clock"></i></div>
          <div class="stat-body">
            <span class="stat-label">Durée moy. gestation (jours)</span>
            <span class="stat-value">{{ avgGestationDays }}</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="background:#fee2e2;color:#b91c1c;"><i class="fas fa-venus"></i></div>
          <div class="stat-body">
            <span class="stat-label">Femelles distinctes</span>
            <span class="stat-value">{{ distinctFemales }}</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="background:#ffedd5;color:#c2410c;"><i class="fas fa-mars"></i></div>
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
                <div class="bar-fill" :style="{ width: m.pct + '%', background: '#8b5cf6' }"></div>
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
import { ref, computed, onMounted } from 'vue';
import api from '../services/api';

const reproductions = ref([]);
const isLoading = ref(true);
const loadError = ref('');
const searchQuery = ref('');
const filterStatus = ref('');
const showModal = ref(false);
const selectedRepro = ref(null);

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
    { label: 'En cours',  cls: 'badge-blue',   color: '#3b82f6', count: inProgressCount.value, pct: Math.round(inProgressCount.value / total * 100) },
    { label: 'Réussie',   cls: 'badge-green',  color: '#0B5D1E', count: successCount.value,     pct: Math.round(successCount.value / total * 100) },
    { label: 'Échouée',   cls: 'badge-red',    color: '#ef4444', count: reproductions.value.filter(r => r.status === 'FAILED').length,  pct: Math.round(reproductions.value.filter(r => r.status === 'FAILED').length / total * 100) },
    { label: 'Avortée',   cls: 'badge-orange', color: '#f97316', count: reproductions.value.filter(r => r.status === 'ABORTED').length, pct: Math.round(reproductions.value.filter(r => r.status === 'ABORTED').length / total * 100) },
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
.page-container { font-family: 'Inter', sans-serif; background: #f8fafc; min-height: 100vh; padding: 30px; color: #1f2937; }
.page-header { margin-bottom: 25px; }
h1 { font-size: 24px; font-weight: 800; color: #111827; margin: 0; }
.subtitle { font-size: 14px; color: #6b7280; margin-top: 5px; }
.api-error-banner { background: #fee2e2; color: #b91c1c; padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; font-weight: 600; }

.kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 24px; }
.kpi-card { background: white; padding: 20px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #e5e7eb; border-top: 4px solid #6b7280; }
.kpi-card.kpi-blue { border-top-color: #3b82f6; }
.kpi-card.kpi-green { border-top-color: #0B5D1E; }
.kpi-card.kpi-red { border-top-color: #ef4444; }
.kpi-label { font-size: 11px; font-weight: 700; color: #6b7280; text-transform: uppercase; }
.kpi-value { font-size: 28px; font-weight: 800; color: #111827; margin-top: 8px; }

.filters-bar { display: flex; gap: 15px; background: white; padding: 15px; border-radius: 12px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); flex-wrap: wrap; }
.search-box { display: flex; align-items: center; background: #f3f4f6; padding: 8px 15px; border-radius: 8px; flex: 1; min-width: 250px; }
.search-box i { color: #9ca3af; margin-right: 10px; }
.search-box input { border: none; background: transparent; width: 100%; outline: none; font-size: 14px; }
.filter-select { padding: 8px 15px; border: 1px solid #e5e7eb; border-radius: 8px; outline: none; background: white; color: #374151; font-size: 14px; }

.table-wrapper { background: white; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden; overflow-x: auto; }
.data-table { width: 100%; border-collapse: collapse; }
th { text-align: left; padding: 14px 18px; font-size: 11px; font-weight: 700; color: #6b7280; text-transform: uppercase; border-bottom: 1px solid #f3f4f6; white-space: nowrap; }
td { padding: 14px 18px; border-bottom: 1px solid #f3f4f6; font-size: 14px; vertical-align: middle; }
.empty-row { text-align: center; color: #9ca3af; font-style: italic; padding: 30px; }
.loading-state { text-align: center; padding: 40px; color: #6b7280; }
.center-td { text-align: center; font-weight: 700; }
.mono-id { font-family: monospace; font-weight: 700; }
.sub-info { display: block; font-size: 11px; color: #6b7280; margin-top: 2px; }

.badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; display: inline-block; }
.badge-blue { background: #dbeafe; color: #1e40af; }
.badge-green { background: #dcfce7; color: #063B16; }
.badge-red { background: #fee2e2; color: #991b1b; }
.badge-orange { background: #ffedd5; color: #c2410c; }
.badge-gray { background: #f1f5f9; color: #475569; }

.btn-icon { background: #f1f5f9; border: 1px solid #e5e7eb; color: #1e3a8a; width: 32px; height: 32px; border-radius: 6px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s; }
.btn-icon:hover { background: #e5e7eb; }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.55); display: flex; justify-content: center; align-items: center; z-index: 1000; }
.modal-content { background: white; width: 100%; max-width: 600px; border-radius: 16px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25); animation: slideUp 0.3s ease; max-height: 85vh; overflow-y: auto; }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 25px; border-bottom: 1px solid #f1f5f9; background: #f8fafc; }
.modal-header h2 { margin: 0; font-size: 18px; font-weight: 800; color: #0f172a; }
.btn-close { background: none; border: none; font-size: 22px; color: #9ca3af; cursor: pointer; }
.btn-close:hover { color: #ef4444; }
.modal-body { padding: 25px; }

.detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 20px; }
.detail-item { display: flex; flex-direction: column; gap: 4px; }
.detail-label { font-size: 11px; font-weight: 700; color: #6b7280; text-transform: uppercase; }
.detail-value { font-size: 14px; font-weight: 600; color: #111827; }

.notes-block { background: #fffbeb; border-left: 4px solid #f59e0b; border-radius: 8px; padding: 15px; }
.notes-block h4 { margin: 0 0 10px 0; font-size: 14px; font-weight: 800; color: #b45309; display: flex; align-items: center; gap: 8px; }
.notes-block p { margin: 0; font-size: 13px; color: #92400e; font-style: italic; }

@media (max-width: 1024px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } }

/* ── Stats section ── */
.stats-section { margin-top: 28px; }
.stats-title { font-size: 16px; font-weight: 800; color: #111827; margin: 0 0 16px 0; display: flex; align-items: center; gap: 8px; }
.stats-title i { color: #8b5cf6; }

.stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 20px; }
.stat-card { background: white; border-radius: 12px; border: 1px solid #e5e7eb; padding: 18px 20px; display: flex; align-items: center; gap: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
.stat-icon { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
.stat-body { display: flex; flex-direction: column; gap: 3px; }
.stat-label { font-size: 11px; font-weight: 700; color: #6b7280; text-transform: uppercase; }
.stat-value { font-size: 24px; font-weight: 800; color: #111827; }

.breakdown-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.breakdown-card { background: white; border: 1px solid #e5e7eb; border-radius: 12px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
.breakdown-card h4 { margin: 0 0 16px 0; font-size: 13px; font-weight: 800; color: #374151; }

.breakdown-bars { display: flex; flex-direction: column; gap: 12px; }
.bar-item { display: flex; flex-direction: column; gap: 6px; }
.bar-label-row { display: flex; justify-content: space-between; align-items: center; }
.bar-count { font-size: 13px; font-weight: 700; color: #374151; }
.bar-track { height: 8px; background: #f1f5f9; border-radius: 99px; overflow: hidden; }
.bar-fill { height: 100%; border-radius: 99px; transition: width 0.6s ease; }

.monthly-list { display: flex; flex-direction: column; gap: 8px; max-height: 260px; overflow-y: auto; }
.monthly-item { display: flex; align-items: center; gap: 10px; }
.monthly-label { font-size: 12px; font-weight: 600; color: #6b7280; width: 52px; flex-shrink: 0; }
.empty-stat { text-align: center; color: #9ca3af; font-style: italic; padding: 20px; }

@media (max-width: 1024px) {
  .stats-grid { grid-template-columns: repeat(2, 1fr); }
  .breakdown-row { grid-template-columns: 1fr; }
}
</style>
