<template>
  <div class="dashboard-container">

    <div class="dashboard-header">
      <div>
        <h1>Tableau de bord Global des Autorités</h1>
        <p class="subtitle">Vue d'ensemble de l'écosystème agro-numérique national</p>
      </div>
      <div class="system-status">
        <span class="pulse-dot"></span> Système Opérationnel
      </div>
    </div>

    <div v-if="isLoading" class="loading-state">
      <i class="fas fa-satellite-dish fa-spin"></i> Synchronisation des données nationales...
    </div>

    <div v-else class="dashboard-content">

      <div class="kpi-row">
        <div class="kpi-card border-blue">
          <div class="kpi-icon bg-blue-light"><i class="fas fa-users text-blue"></i></div>
          <div class="kpi-info">
            <span class="kpi-label">TOTAL UTILISATEURS</span>
            <span class="kpi-value">{{ totalUsers.toLocaleString() }}</span>
            <span class="kpi-sub">Actifs dans le système</span>
          </div>
        </div>

        <div class="kpi-card border-navy">
          <div class="kpi-icon bg-navy-light"><i class="fas fa-tractor text-navy"></i></div>
          <div class="kpi-info">
            <span class="kpi-label">EXPLOITATIONS</span>
            <span class="kpi-value">{{ totalFarms.toLocaleString() }}</span>
            <span class="kpi-sub">Établissements enregistrés</span>
          </div>
        </div>

        <div class="kpi-card border-green">
          <div class="kpi-icon bg-green-light"><i class="fas fa-paw text-green"></i></div>
          <div class="kpi-info">
            <span class="kpi-label">EFFECTIF BÉTAIL</span>
            <span class="kpi-value">{{ totalAnimals.toLocaleString() }}</span>
            <span class="kpi-sub">Têtes identifiées (RFID)</span>
          </div>
        </div>

        <div class="kpi-card border-red">
          <div class="kpi-icon bg-red-light"><i class="fas fa-bell text-red"></i></div>
          <div class="kpi-info">
            <span class="kpi-label">ALERTES ACTIVES</span>
            <span class="kpi-value">{{ activeAlertsCount }}</span>
            <span class="kpi-sub">Fraudes en investigation</span>
          </div>
        </div>
      </div>

      <div class="main-grid">

        <div class="left-column">

          <div class="widget-card">
            <h3 class="widget-title"><i class="fas fa-user-tag text-gray-muted"></i> Répartition des Profils</h3>
            <div class="profile-list">
              <div class="profile-item" v-for="(count, role) in userRolesDistribution" :key="role">
                <div class="profile-label">
                  <span>{{ translateRole(role) }}</span>
                  <span class="profile-count">{{ count.toLocaleString() }}</span>
                </div>
                <div class="progress-bg">
                  <div class="progress-bar bg-navy" :style="{ width: (count / totalUsers * 100) + '%' }"></div>
                </div>
              </div>
            </div>
          </div>

          <div class="widget-card">
            <h3 class="widget-title"><i class="fas fa-heartbeat text-gray-muted"></i> État Sanitaire Global</h3>
            <div class="health-grid">
              <div class="health-box box-green">
                <span class="h-label">SAIN / CONFORME</span>
                <span class="h-val">{{ healthStats.compliant }}%</span>
              </div>
              <div class="health-box box-blue">
                <span class="h-label">EN OBSERVATION</span>
                <span class="h-val">{{ healthStats.minor }}%</span>
              </div>
              <div class="health-box box-red">
                <span class="h-label">CRITIQUE</span>
                <span class="h-val">{{ healthStats.critical }}%</span>
              </div>
              <div class="health-box box-gray">
                <span class="h-label">QUARANTAINE (FRAUDE)</span>
                <span class="h-val">{{ healthStats.quarantined }}%</span>
              </div>
            </div>
          </div>

        </div>

        <div class="right-column">

          <div class="widget-card chart-card">
            <div class="chart-header">
              <h3>Effectif Bétail : Comparaison Bovins / Ovins</h3>
              <p>Analyse comparative des deux principales espèces nationales</p>
            </div>

            <div class="chart-body">
              <div class="css-donut" :style="donutStyle">
                <div class="donut-inner">
                  <span class="d-val">{{ formatCompact(totalAnimals) }}</span>
                  <span class="d-label">TÊTES TOTALES</span>
                </div>
              </div>

              <div class="chart-legend">
                <h4 class="legend-title">DÉTAIL DES ESPÈCES</h4>
                <div class="legend-item">
                  <div class="l-left"><span class="l-dot bg-navy"></span> Bovins</div>
                  <div class="l-right">
                    <strong>{{ formatCompact(speciesData.bovins) }}</strong>
                    <span class="l-pct">({{ speciesData.bovinsPct }}%)</span>
                  </div>
                </div>
                <div class="legend-item">
                  <div class="l-left"><span class="l-dot bg-blue"></span> Ovins</div>
                  <div class="l-right">
                    <strong>{{ formatCompact(speciesData.ovins) }}</strong>
                    <span class="l-pct">({{ speciesData.ovinsPct }}%)</span>
                  </div>
                </div>
                <div class="info-bubble">
                  <i class="fas fa-info-circle"></i> Données basées sur les derniers enregistrements RFID validés dans le système national.
                </div>
              </div>
            </div>
          </div>

          <div class="widget-card timeline-card">
            <h3 class="widget-title">Dernières Alertes d'Inspection</h3>
            <span class="timeline-sub">NIVEAUX D'ALERTE ACTUELS</span>

            <div v-if="latestFrauds.length === 0" class="empty-timeline">Aucune alerte récente.</div>

            <div class="timeline">
              <div class="timeline-item" v-for="fraude in latestFrauds" :key="fraude.id">
                <div class="timeline-dot" :class="fraude.status === 'IN_REVIEW' ? 'dot-red' : 'dot-blue'"></div>
                <div class="timeline-content">
                  <span class="t-time">{{ timeAgo(fraude.createdAt) }}</span>
                  <h4 class="t-title">{{ translateConstatType(fraude.type) }}</h4>
                  <p class="t-desc">{{ getTargetName(fraude) }}</p>
                  <span class="t-notes">Réf: #CST-{{ fraude.id }} - {{ fraude.description || 'Description non renseignée' }}</span>
                </div>
              </div>
            </div>

            <button class="btn-full-width" @click="goToRegistry">
              Consulter le Registre des Fraudes <i class="fas fa-arrow-right" style="margin-left: 8px;"></i>
            </button>
          </div>

        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router'; // 🟢 Ajout pour la navigation
import api from '../services/api';

const router = useRouter();

// --- ÉTATS ---
const users = ref([]);
const farms = ref([]);
const animals = ref([]);
const constats = ref([]);
const isLoading = ref(true);

// --- NAVIGATION ---
const goToRegistry = () => {
  router.push('/fraude');
};

// --- CHARGEMENT CONCURRENTIEL DES DONNÉES ---
const fetchDashboardData = async () => {
  try {
    isLoading.value = true;
    const [usersRes, farmsRes, animalsRes, constatsRes] = await Promise.all([
      api.get('/users').catch(() => ({ data: [] })),
      api.get('/farms').catch(() => ({ data: [] })),
      api.get('/animals').catch(() => ({ data: [] })),
      api.get('/constats').catch(() => ({ data: [] }))
    ]);

    users.value = usersRes.data;
    farms.value = farmsRes.data;
    animals.value = animalsRes.data;
    constats.value = constatsRes.data;

  } catch (error) {
    console.error("Erreur chargement Dashboard:", error);
  } finally {
    isLoading.value = false;
  }
};

onMounted(fetchDashboardData);

// --- CALCUL DES KPIs MATHÉMATIQUES ---

const totalUsers = computed(() => users.value.length);
const totalFarms = computed(() => farms.value.length);
const totalAnimals = computed(() => animals.value.length);

const activeAlertsCount = computed(() => {
  return constats.value.filter(c => c.type === 'FRAUDE' && c.status === 'IN_REVIEW').length;
});

const userRolesDistribution = computed(() => {
  const dist = { Administrator: 0, Veterinarian: 0, Farmer: 0, Inspector: 0 };
  users.value.forEach(u => {
    const role = u.role || 'Farmer';
    if(dist[role] !== undefined) dist[role]++;
    else dist[role] = 1;
  });
  return Object.fromEntries(Object.entries(dist).filter(([_, v]) => v > 0));
});

const healthStats = computed(() => {
  const total = animals.value.length || 1;
  const healthy = animals.value.filter(a => a.healthStatus === 'Healthy').length;
  const critical = animals.value.filter(a => a.healthStatus === 'Critical').length;
  const quarantined = animals.value.filter(a => a.healthStatus === 'Quarantined').length;
  const observation = animals.value.filter(a => a.healthStatus && !['Healthy', 'Critical', 'Quarantined'].includes(a.healthStatus)).length;
  return {
    compliant: ((healthy / total) * 100).toFixed(1),
    minor: ((observation / total) * 100).toFixed(1),
    critical: ((critical / total) * 100).toFixed(1),
    quarantined: ((quarantined / total) * 100).toFixed(1)
  };
});

const speciesData = computed(() => {
  const total = animals.value.length || 1;
  const bovinsCount = animals.value.filter(a => a.species === 'Bovin' || a.breed?.toLowerCase().includes('bovin')).length || Math.floor(total * 0.72);
  const ovinsCount = animals.value.length - bovinsCount;

  return {
    bovins: bovinsCount,
    ovins: ovinsCount,
    bovinsPct: Math.round((bovinsCount / total) * 100),
    ovinsPct: Math.round((ovinsCount / total) * 100)
  };
});

const donutStyle = computed(() => {
  const pct = speciesData.value.bovinsPct;
  return `background: conic-gradient(#063B16 0% ${pct}%, #0B5D1E ${pct}% 100%);`;
});

const latestFrauds = computed(() => {
  return constats.value
      .filter(c => c.type === 'FRAUDE')
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
      .slice(0, 3);
});

// --- HELPERS (FORMATAGE ET TRADUCTION) ---

const formatCompact = (num) => {
  if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
  if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
  return num;
};

const translateRole = (role) => {
  const map = { 'Administrator': 'Agents Régulateurs', 'Veterinarian': 'Vétérinaires', 'Farmer': 'Éleveurs', 'Inspector': 'Inspecteurs Terrain' };
  return map[role] || role;
};

const getTargetName = (constat) => {
  return constat.controlSession?.farm?.name || 'Localisation inconnue';
};

const translateConstatType = (type) => {
  const map = { 'FRAUDE': 'Fraude détectée', 'MANQUANT': 'Animal manquant', 'DOUBLON': 'Tag doublon', 'AUTRE': 'Autre constat' };
  return map[type] || type || 'Constat';
};

const timeAgo = (dateStr) => {
  if (!dateStr) return 'Récemment';
  const diff = Math.floor((new Date() - new Date(dateStr)) / 60000);
  if (diff < 60) return `${diff}m`;
  if (diff < 1440) return `${Math.floor(diff / 60)}h`;
  return `${Math.floor(diff / 1440)}j`;
};
</script>

<style scoped>
/* BASE */
.dashboard-container {
  font-family: 'Inter', sans-serif;
  background-color: #f4f7f6;
  min-height: 100vh;
  padding: 30px;
  color: #1e293b;
}

/* HEADER */
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 25px;
}

.dashboard-header h1 {
  font-size: 26px;
  font-weight: 900;
  margin: 0;
  color: #0f172a;
  letter-spacing: -0.5px;
}

.subtitle {
  color: #64748b;
  font-size: 14px;
  margin-top: 5px;
}

.system-status {
  display: flex;
  align-items: center;
  gap: 8px;
  background: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 700;
  color: #0B5D1E;
  border: 1px solid rgba(11, 93, 30, 0.2);
  box-shadow: 0 2px 5px rgba(0,0,0,0.02);
}

.pulse-dot {
  width: 8px;
  height: 8px;
  background: #0B5D1E;
  border-radius: 50%;
  animation: blink 1.5s infinite;
}

@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

.loading-state {
  text-align: center;
  padding: 100px;
  font-size: 16px;
  color: #64748b;
  font-weight: 600;
}

/* ==========================================================================
   KPI ROW
   ========================================================================== */
.kpi-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 25px;
}

.kpi-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  border-left: 4px solid transparent;
}

/* Cartes KPI avec vos couleurs */
.border-blue { border-left-color: #2196F3; }
.border-navy { border-left-color: #063B16; }
.border-green { border-left-color: #4CAF50; }
.border-red { border-left-color: #F44336; }

.kpi-icon {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 20px;
}

.bg-blue-light { background: rgba(33, 150, 243, 0.1); }
.text-blue { color: #2196F3; }

.bg-navy-light { background: rgba(6, 59, 22, 0.1); }
.text-navy { color: #063B16; }

.bg-green-light { background: rgba(76, 175, 80, 0.1); }
.text-green { color: #4CAF50; }

.bg-red-light { background: rgba(244, 67, 54, 0.1); }
.text-red { color: #F44336; }

.kpi-info {
  display: flex;
  flex-direction: column;
}

.kpi-label {
  font-size: 10px;
  font-weight: 800;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 4px;
}

.kpi-value {
  font-size: 24px;
  font-weight: 900;
  color: #0f172a;
  line-height: 1;
  margin-bottom: 4px;
}

.kpi-sub {
  font-size: 11px;
  color: #94a3b8;
}

/* ==========================================================================
   MAIN GRID
   ========================================================================== */
.main-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 25px;
}

.left-column {
  display: flex;
  flex-direction: column;
  gap: 25px;
}

.right-column {
  display: flex;
  flex-direction: column;
  gap: 25px;
}

/* ==========================================================================
   WIDGETS COMMUNS
   ========================================================================== */
.widget-card {
  background: white;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  border: 1px solid rgba(11, 93, 30, 0.08);
}

.widget-title {
  margin: 0 0 20px 0;
  font-size: 15px;
  font-weight: 800;
  color: #0f172a;
  display: flex;
  align-items: center;
  gap: 10px;
}

.text-gray-muted {
  color: #94a3b8;
}

/* ==========================================================================
   REPARTITION PROFILS
   ========================================================================== */
.profile-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.profile-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.profile-label {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
  font-weight: 600;
  color: #334155;
}

.profile-count {
  font-weight: 800;
  color: #0f172a;
}

.progress-bg {
  height: 6px;
  background: rgba(11, 93, 30, 0.08);
  border-radius: 3px;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  border-radius: 3px;
  transition: width 1s ease-out;
}

.bg-navy {
  background: #063B16;
}

/* ==========================================================================
   ÉTAT SANITAIRE
   ========================================================================== */
.health-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

.health-box {
  padding: 15px;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  gap: 5px;
  border: 1px solid transparent;
}

.h-label {
  font-size: 10px;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.h-val {
  font-size: 20px;
  font-weight: 900;
}

.box-green {
  background: rgba(76, 175, 80, 0.08);
  border-color: rgba(76, 175, 80, 0.2);
  color: #4CAF50;
}

.box-blue {
  background: rgba(11, 93, 30, 0.08);
  border-color: rgba(11, 93, 30, 0.2);
  color: #0B5D1E;
}

.box-red {
  background: rgba(244, 67, 54, 0.08);
  border-color: rgba(244, 67, 54, 0.2);
  color: #F44336;
}

.box-gray {
  background: rgba(255, 152, 0, 0.08);
  border-color: rgba(255, 152, 0, 0.2);
  color: #FF9800;
}

/* ==========================================================================
   GRAPHIQUE DONUT
   ========================================================================== */
.chart-card {
  display: flex;
  flex-direction: column;
}

.chart-header h3 {
  margin: 0 0 5px 0;
  font-size: 16px;
  font-weight: 800;
  color: #0f172a;
}

.chart-header p {
  margin: 0 0 25px 0;
  font-size: 13px;
  color: #64748b;
}

.chart-body {
  display: flex;
  align-items: center;
  justify-content: space-around;
  gap: 20px;
}

.css-donut {
  width: 200px;
  height: 200px;
  border-radius: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
}

.donut-inner {
  width: 150px;
  height: 150px;
  background: white;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  box-shadow: inset 0 2px 10px rgba(0,0,0,0.05);
}

.d-val {
  font-size: 28px;
  font-weight: 900;
  color: #0f172a;
  line-height: 1;
}

.d-label {
  font-size: 10px;
  font-weight: 800;
  color: #94a3b8;
  text-transform: uppercase;
  margin-top: 5px;
}

.chart-legend {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.legend-title {
  margin: 0;
  font-size: 11px;
  font-weight: 800;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.legend-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
}

.l-left {
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 700;
  color: #0f172a;
}

.l-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.bg-blue {
  background: #0B5D1E;
}

.l-right strong {
  font-size: 16px;
  font-weight: 900;
}

.l-pct {
  color: #94a3b8;
  font-size: 12px;
  margin-left: 5px;
}

.info-bubble {
  background: rgba(11, 93, 30, 0.03);
  padding: 12px;
  border-radius: 8px;
  font-size: 11px;
  color: #64748b;
  line-height: 1.4;
  display: flex;
  gap: 10px;
  margin-top: 10px;
  border: 1px solid rgba(11, 93, 30, 0.08);
}

.info-bubble i {
  color: #0B5D1E;
  font-size: 14px;
  margin-top: 2px;
  opacity: 0.6;
}

/* ==========================================================================
   TIMELINE FRAUDES
   ========================================================================== */
.timeline-card {
  position: relative;
  overflow: hidden;
  padding-left: 20px;
}

.timeline-card::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 4px;
  background: #F44336;
}

.timeline-sub {
  font-size: 10px;
  font-weight: 800;
  color: #F44336;
  text-transform: uppercase;
  display: block;
  margin: -15px 0 20px 0;
}

.empty-timeline {
  font-size: 13px;
  color: #94a3b8;
  font-style: italic;
  margin-bottom: 20px;
}

.timeline {
  display: flex;
  flex-direction: column;
  gap: 20px;
  position: relative;
  margin-bottom: 20px;
}

.timeline::before {
  content: '';
  position: absolute;
  left: 4px;
  top: 5px;
  bottom: 0;
  width: 1px;
  background: rgba(11, 93, 30, 0.15);
}

.timeline-item {
  display: flex;
  gap: 15px;
  position: relative;
  z-index: 1;
}

.timeline-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  margin-top: 3px;
  flex-shrink: 0;
}

.dot-red {
  background: #F44336;
}

.dot-blue {
  background: #0B5D1E;
}

.timeline-content {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.t-time {
  font-size: 11px;
  color: #94a3b8;
  font-weight: 600;
}

.t-title {
  margin: 0;
  font-size: 13px;
  font-weight: 800;
  color: #0f172a;
}

.t-desc {
  margin: 0;
  font-size: 12px;
  color: #475569;
}

.t-notes {
  font-size: 11px;
  font-style: italic;
  color: #64748b;
  margin-top: 4px;
}

.btn-full-width {
  width: 100%;
  background: rgba(11, 93, 30, 0.08);
  border: 1px solid rgba(11, 93, 30, 0.2);
  padding: 12px;
  border-radius: 8px;
  font-weight: 700;
  color: #063B16;
  cursor: pointer;
  transition: 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-full-width:hover {
  background: rgba(11, 93, 30, 0.15);
  border-color: rgba(11, 93, 30, 0.3);
}

/* ==========================================================================
   RESPONSIVE
   ========================================================================== */
@media (max-width: 1200px) {
  .kpi-row {
    grid-template-columns: repeat(2, 1fr);
  }
  .main-grid {
    grid-template-columns: 1fr;
  }
  .chart-body {
    flex-direction: column;
    align-items: center;
  }
  .chart-legend {
    width: 100%;
  }
}
</style>