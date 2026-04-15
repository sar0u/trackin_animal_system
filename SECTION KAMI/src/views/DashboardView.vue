<template>
  <div class="dashboard-container">
    <header class="dashboard-header">
      <div class="header-left">
        <h1>Tableau de bord Global</h1>
        <p class="subtitle">Vue d'ensemble de l'écosystème agro-numérique national</p>
      </div>
      <div class="header-right">
        <span class="status-badge">
          <span class="dot green"></span>
          Système Opérationnel
        </span>
      </div>
    </header>

    <section class="kpi-grid">
      <div class="kpi-card blue-border">
        <div class="kpi-icon blue-bg">
          <i class="fas fa-users"></i>
        </div>
        <div class="kpi-info">
          <span class="kpi-title">TOTAL UTILISATEURS</span>
          <span class="kpi-value">{{ stats.totalUsers.toLocaleString() }}</span>
          <span class="kpi-trend">Actifs dans les 30 derniers jours</span>
        </div>
      </div>

      <div class="kpi-card blue-border">
        <div class="kpi-icon blue-bg">
          <i class="fas fa-tractor"></i>
        </div>
        <div class="kpi-info">
          <span class="kpi-title">EXPLOITATIONS</span>
          <span class="kpi-value">{{ stats.totalFarms.toLocaleString() }}</span>
          <span class="kpi-trend">Établissements enregistrés</span>
        </div>
      </div>

      <div class="kpi-card green-border">
        <div class="kpi-icon green-bg">
          <i class="fas fa-paw"></i>
        </div>
        <div class="kpi-info">
          <span class="kpi-title">EFFECTIF BÉTAIL</span>
          <span class="kpi-value">{{ stats.totalLivestock.toLocaleString() }}</span>
          <span class="kpi-trend">Têtes identifiées (RFID)</span>
        </div>
      </div>

      <div class="kpi-card red-border">
        <div class="kpi-icon red-bg">
          <i class="fas fa-bell"></i>
        </div>
        <div class="kpi-info">
          <span class="kpi-title">ALERTES ACTIVES</span>
          <span class="kpi-value red-text">{{ stats.activeAlerts }}</span>
          <span class="kpi-trend">92% taux de résolution (24h)</span>
        </div>
      </div>
    </section>

    <section class="main-grid">
      <aside class="side-column">
        <div class="card">
          <h3 class="card-title"><i class="fas fa-user-tag"></i> Répartition des Profils</h3>
          <div class="profile-item">
            <span class="profile-name">Éleveurs</span>
            <div class="progress-bar-wrap">
              <div class="progress-bar dark-blue" :style="{ width: (stats.totalUsers > 0 ? (stats.eleveursCount / stats.totalUsers * 100) : 0) + '%' }"></div>
            </div>
            <span class="profile-value">{{ stats.eleveursCount.toLocaleString() }}</span>
          </div>
          <div class="profile-item">
            <span class="profile-name">Vétérinaires</span>
            <div class="progress-bar-wrap">
              <div class="progress-bar blue" :style="{ width: (stats.totalUsers > 0 ? (stats.vetsCount / stats.totalUsers * 100) : 0) + '%' }"></div>
            </div>
            <span class="profile-value">{{ stats.vetsCount.toLocaleString() }}</span>
          </div>
          <div class="profile-item">
            <span class="profile-name">Agents Régulateurs</span>
            <div class="progress-bar-wrap">
              <div class="progress-bar light-blue" :style="{ width: (stats.totalUsers > 0 ? (stats.agentsCount / stats.totalUsers * 100) : 0) + '%' }"></div>
            </div>
            <span class="profile-value">{{ stats.agentsCount.toLocaleString() }}</span>
          </div>
        </div>

        <div class="card health-card">
          <h3 class="card-title"><i class="fas fa-heartbeat"></i> État Sanitaire Global</h3>
          <div class="health-grid">
            <div class="health-item green-box">
              <span class="health-status">SAIN / CONFORME</span>
              <span class="health-value">{{ stats.healthStats.sain }}%</span>
            </div>
            <div class="health-item blue-box">
              <span class="health-status">EN OBSERVATION</span>
              <span class="health-value">{{ stats.healthStats.observation }}%</span>
            </div>
            <div class="health-item red-box">
              <span class="health-status">QUARANTAINE</span>
              <span class="health-value">{{ stats.healthStats.quarantaine }}%</span>
            </div>
            <div class="health-item gray-box">
              <span class="health-status">EN ATTENTE</span>
              <span class="health-value">{{ stats.healthStats.attente }}%</span>
            </div>
          </div>
        </div>

        <div class="card fraud-card">
          <div class="fraud-card-header">
            <h3 class="card-title">Gestion des Fraudes</h3>
            <span class="frauds-sub">NIVEAUX D'ALERTE ACTUELS</span>
            <span class="attention-badge" v-if="stats.frauds.length > 0">ATTENTION</span>
          </div>

          <div v-for="fraud in stats.frauds" :key="fraud.id"
               :class="['fraud-item', fraud.severity === 'HIGH' ? 'red-alert' : 'blue-info']">
            <div class="fraud-meta">
              <span>{{ fraud.timeAgo }}</span>
              <span :class="['dot', fraud.severity === 'HIGH' ? 'red' : 'blue']"></span>
            </div>
            <strong>{{ fraud.type }}</strong>
            <p>Exploitation #{{ fraud.farmId }}</p>
            <p class="fraud-desc">{{ fraud.description }}</p>
          </div>

          <div class="fraud-footer">
            <span>Taux de résolution (MTTR)</span>
            <span class="fraud-rate green-text">{{ stats.fraudRate }}%</span>
            <div class="fraud-progress green-bg" :style="{ width: stats.fraudRate + '%' }"></div>
            <button class="action-btn">Accéder au Centre de Litiges</button>
          </div>
        </div>
      </aside>

      <section class="main-content">
        <div class="card center-data-card">
          <div class="data-header">
            <h3>Effectif Bétail : Comparaison Bovins / Ovins</h3>
            <p class="subtitle">Analyse comparative des deux principales espèces nationales</p>
          </div>

          <div class="circular-chart-container">
            <div class="donut-chart-wrap">
              <div class="donut-chart" :style="{ '--percent': stats.bovinsPercent }">
                <div class="donut-inner">
                  <span class="total-count">{{ stats.totalLivestock.toLocaleString() }}</span>
                  <span class="total-label">Têtes Totales</span>
                </div>
              </div>
            </div>

            <div class="chart-details">
              <h4>DÉTAIL DES ESPÈCES</h4>
              <div class="detail-item">
                <span class="dot dark-blue"></span>
                <strong>Bovins</strong>
                <span class="detail-value">{{ stats.bovinsCount }}<small>({{ stats.bovinsPercent }}%)</small></span>
              </div>
              <div class="detail-item">
                <span class="dot light-blue"></span>
                <strong>Ovins</strong>
                <span class="detail-value">{{ stats.ovinsCount }}<small>({{ 100 - stats.bovinsPercent }}%)</small></span>
              </div>

              <div class="chart-info-box">
                <i class="fas fa-info-circle"></i>
                <p>Données basées sur les derniers scans RFID valides dans le système national Auvergne-Rhône-Alpes.</p>
              </div>
            </div>
          </div>
        </div>

        <div class="card movements-card">
          <div class="movements-header">
            <h3>Mouvements Nationaux (Dernières 24h)</h3>
            <button class="export-btn"><i class="fas fa-download"></i> EXPORTER (.CSV)</button>
          </div>

          <table class="data-table">
            <thead>
              <tr>
                <th>HORODATAGE</th>
                <th>ORIGINE / DESTINATION</th>
                <th>TYPE / QUANTITÉ</th>
                <th>STATUT</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="move in stats.movements" :key="move.id">
                <td>
                  <strong>{{ move.time }}</strong><br>
                  {{ move.date }}
                </td>
                <td>{{ move.origin }} <i class="fas fa-arrow-right"></i> {{ move.destination }}</td>
                <td>
                  <strong>{{ move.species }}</strong>
                  <span class="type-tag blue-tag">{{ move.quantity }} têtes</span>
                </td>
                <td>
                  <span class="status-tag" :class="move.status === 'VÉRIFIÉ' ? 'green-tag' : 'red-tag'">
                    <i :class="move.status === 'VÉRIFIÉ' ? 'fas fa-check' : 'fas fa-exclamation-triangle'"></i>
                    {{ move.status }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>

          <button @click="goToMovements" class="view-all-btn">
            VOIR L'HISTORIQUE COMPLET
          </button>
        </div>
      </section>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import api from '@/services/api'; // Ton instance Axios configurée avec l'URL de base et le Token

const router = useRouter();
const loading = ref(true);

// États réactifs pour les chiffres du dashboard
// Initialisation avec des valeurs par défaut pour éviter les erreurs d'affichage au chargement
const stats = ref({
  totalUsers: 0,
  totalFarms: 0,
  totalLivestock: 0,
  activeAlerts: 0,
  bovinsCount: 0,
  ovinsCount: 0,
  bovinsPercent: 0,
  eleveursCount: 0,
  vetsCount: 0,
  agentsCount: 0,
  healthStats: {
    sain: 0,
    observation: 0,
    quarantaine: 0,
    attente: 0
  },
  movements: [],
  fraudRate: 0,
  frauds: []
});

/**
 * Récupère les données consolidées depuis le backend Spring Boot
 */
const fetchDashboardData = async () => {
  loading.value = true;
  try {
    // Appel au endpoint global de statistiques
    const response = await api.get('/animals/stats/summary');
    const data = response.data;

    // Mise à jour de l'état réactif avec les données réelles
    stats.value = {
      totalUsers: data.totalUsers || 0,
      totalFarms: data.totalFarms || 0,
      totalLivestock: data.totalAnimals || 0,
      activeAlerts: data.activeAlerts || 0,

      // Statistiques par espèces
      bovinsCount: data.speciesStats?.Bovin || 0,
      ovinsCount: data.speciesStats?.Ovin || 0,

      // Calcul du pourcentage pour le graphique donut
      bovinsPercent: data.totalAnimals > 0
        ? Math.round((data.speciesStats?.Bovin / data.totalAnimals) * 100)
        : 0,

      // Répartition des profils (utilisé pour les barres de progression)
      eleveursCount: data.userProfiles?.Éleveurs || 0,
      vetsCount: data.userProfiles?.Vétérinaires || 0,
      agentsCount: data.userProfiles?.Agents || 0,

      // État sanitaire (utilisé pour les box de couleur)
      healthStats: data.healthStats || { sain: 0, observation: 0, quarantaine: 0, attente: 0 },

      // Liste des mouvements pour le tableau (v-for)
      movements: data.recentMovements || []
    };
  } catch (error) {
    console.error("Erreur lors de la récupération des données du dashboard :", error);
    // Optionnel : redirection vers login si erreur 401/403
    if (error.response && (error.response.status === 401 || error.response.status === 403)) {
      router.push({ name: 'login' });
    }
  } finally {
    loading.value = false;
  }

  try {
      const response = await api.get('/animals/stats/summary');
      const data = response.data;

      stats.value = {
        // ... tes autres assignations
        fraudRate: data.fraudRate || 82,
        frauds: data.recentFrauds || [] // On récupère les dernières fraudes
      };
    } catch (error) {
      console.error("Erreur de chargement des fraudes:", error);
    }
};



/**
 * Navigation vers la page de l'historique complet
 */
const goToMovements = () => {
  router.push({ name: 'mouves' });
};

// Chargement des données au montage du composant
onMounted(() => {
  fetchDashboardData();
});
</script>

<style scoped>

.dashboard-container {
  --blue-primary: #3182CE;
  --blue-dark: #2C5282;
  --blue-light: #63B3ED;
  --green-primary: #11D432;
  --red-primary: #E53E3E;
  --text-dark: #2D3748;
  --text-sub: #718096;
  --bg-page: #F4F7FA;
  --border-color: #E2E8F0;

  background-color: var(--bg-page);
  color: var(--text-dark);
  font-family: 'Inter', sans-serif;
  padding: 30px;
  min-height: 100vh;
}

h1, h3, h4 { margin: 0; font-weight: 800; }
.subtitle { color: var(--text-sub); margin: 0; font-size: 14px; }
.red-text { color: var(--danger) !important; }
.green-text { color: var(--tracedz-green) !important; }
button { cursor: pointer; border: none; font-family: inherit; }


.dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 8px; }
.green { background-color: var(--green-primary); }
.blue { background-color: var(--blue-primary); }
.dark-blue { background-color: var(--blue-dark); }
.light-blue { background-color: var(--blue-light); }
.red { background-color: var(--red-primary); }


.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

h1 { font-size: 26px; }

.status-badge {
  display: flex;
  align-items: center;
  background-color: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
  border: 1px solid var(--border-color);
}


.kpi-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.kpi-card {
  background-color: white;
  padding: 20px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  border: 1px solid var(--border-color);
  box-shadow: 0 2px 4px rgba(0,0,0,0.02);
}

.blue-border { border-left: 4px solid var(--blue-primary); }
.green-border { border-left: 4px solid var(--green-primary); }
.red-border { border-left: 4px solid var(--red-primary); }

.kpi-icon {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20px;
  font-size: 20px;
}
.blue-bg { background-color: #EBF8FF; color: var(--blue-primary); }
.green-bg { background-color: #F0FFF4; color: var(--green-primary); }
.red-bg { background-color: #FFF5F5; color: var(--red-primary); }

.kpi-info { display: flex; flex-direction: column; }
.kpi-title { font-size: 11px; font-weight: 700; color: var(--text-sub); letter-spacing: 0.5px; }
.kpi-value { font-size: 28px; font-weight: 800; margin: 4px 0; }
.kpi-trend { font-size: 12px; color: var(--text-sub); }


.main-grid {
  display: grid;
  grid-template-columns: 300px 1fr;
  gap: 25px;
  align-items: start;
}


.card {
  background-color: white;
  padding: 25px;
  border-radius: 12px;
  border: 1px solid var(--border-color);
  margin-bottom: 25px;
}

.card-title {
  font-size: 16px;
  color: var(--text-dark);
  margin-bottom: 20px;
  display: flex;
  align-items: center;
}
.card-title i { margin-right: 10px; color: var(--text-sub); }


.profile-item {
  display: grid;
  grid-template-columns: 1fr 1fr 60px;
  align-items: center;
  margin-bottom: 15px;
  font-size: 13px;
}
.profile-name { color: var(--text-dark); }
.progress-bar-wrap {
  height: 6px;
  background-color: #EDF2F7;
  border-radius: 3px;
  overflow: hidden;
  margin: 0 10px;
}
.progress-bar { height: 100%; border-radius: 3px; }
.progress-bar.dark-blue { background-color: var(--blue-dark); }
.progress-bar.blue { background-color: var(--blue-primary); }
.progress-bar.light-blue { background-color: var(--blue-light); }
.profile-value { font-weight: 700; text-align: right; }


.health-card { padding: 20px; }
.health-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}
.health-item {
  display: flex;
  flex-direction: column;
  padding: 15px;
  border-radius: 8px;
  border: 1px solid;
}
.health-status { font-size: 10px; font-weight: 700; margin-bottom: 5px; }
.health-value { font-size: 20px; font-weight: 800; }

.green-box { background-color: #F0FFF4; border-color: #C6F6D5; color: var(--green-primary); }
.blue-box { background-color: #EBF8FF; border-color: #BEE3F8; color: var(--blue-primary); }
.red-box { background-color: #FFF5F5; border-color: #FED7D7; color: var(--red-primary); }
.gray-box { background-color: #F7FAFC; border-color: var(--border-color); color: var(--text-sub); }


.fraud-card { padding: 0; overflow: hidden; }
.fraud-card-header {
  padding: 25px;
  padding-bottom: 0;
  display: flex;
  flex-direction: column;
}
.frauds-sub { font-size: 10px; font-weight: 700; color: var(--text-sub); text-transform: uppercase; margin-top: -15px; margin-bottom: 5px; }
.attention-badge {
  background-color: #FFF5F5;
  color: var(--red-primary);
  font-size: 11px;
  font-weight: 700;
  padding: 4px 8px;
  border-radius: 4px;
  align-self: start;
}

.fraud-item {
  padding: 20px 25px;
  border-bottom: 1px solid var(--border-color);
  font-size: 13px;
  position: relative;
}
.red-alert { border-left: 4px solid var(--red-primary); background-color: rgba(229,62,62, 0.02); }
.blue-info { border-left: 4px solid var(--blue-primary); }

.fraud-meta { display: flex; justify-content: space-between; align-items: center; color: var(--text-sub); margin-bottom: 5px; font-size: 12px;}
.fraud-item strong { color: var(--text-dark); display: block; margin-bottom: 2px; }
.fraud-item p { margin: 0; color: var(--text-dark); }
.fraud-desc { font-style: italic; color: var(--text-sub) !important; margin-top: 5px !important; }

.fraud-footer {
  padding: 25px;
  font-size: 13px;
  color: var(--text-sub);
}
.fraud-rate { font-weight: 700; margin-left: 10px; }
.fraud-rate small { font-weight: 400; color: var(--green-primary); opacity: 0.8;}
.fraud-progress { height: 4px; background-color: var(--green-primary); border-radius: 2px; width: 82%; margin: 10px 0; }

.action-btn {
  width: 100%;
  background-color: #F7FAFC;
  color: var(--blue-dark);
  border: 1px solid var(--border-color);
  padding: 12px;
  border-radius: 8px;
  font-weight: 600;
  font-size: 14px;
  margin-top: 15px;
}


.main-content {
  display: flex;
  flex-direction: column;
}


.center-data-card {
  padding: 0;
  display: flex;
  flex-direction: column;
}

.data-header {
  padding: 25px;
  border-bottom: 1px solid var(--border-color);
}
.data-header h3 { font-size: 18px; margin-bottom: 5px; }

.circular-chart-container {
  padding: 30px;
  display: flex;
  align-items: center;
  justify-content: space-around;
  gap: 30px;
}


.donut-chart-wrap {
  width: 200px;
  height: 200px;
}

.donut-chart {
  position: relative;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  /* Conic gradient pour simuler les segments */
  background: conic-gradient(
    var(--blue-dark) calc(var(--percent) * 1%),
    var(--blue-light) 0
  );
  display: flex;
  align-items: center;
  justify-content: center;
}

.donut-inner {
  width: 150px;
  height: 150px;
  background-color: white;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  box-shadow: inset 0 2px 10px rgba(0,0,0,0.05);
}

.total-count {
  font-size: 32px;
  font-weight: 800;
  color: var(--text-dark);
}
.total-label {
  font-size: 12px;
  color: var(--text-sub);
  text-transform: uppercase;
}


.chart-details {
  flex: 1;
  max-width: 300px;
}
.chart-details h4 {
  font-size: 12px;
  color: var(--text-sub);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 15px;
}

.detail-item {
  display: flex;
  align-items: center;
  font-size: 14px;
  margin-bottom: 12px;
}
.detail-item strong {
  color: var(--text-dark);
  flex: 1;
}
.detail-value {
  font-weight: 700;
  color: var(--text-dark);
}
.detail-value small {
  font-weight: 400;
  color: var(--text-sub);
  margin-left: 5px;
}

.chart-info-box {
  margin-top: 25px;
  display: flex;
  background-color: #F7FAFC;
  padding: 15px;
  border-radius: 8px;
  font-size: 12px;
  color: var(--text-sub);
  line-height: 1.5;
}
.chart-info-box i {
  color: var(--blue-primary);
  margin-right: 10px;
  font-size: 16px;
}
.chart-info-box p { margin: 0; }


.movements-card { padding: 0; }

.movements-header {
  padding: 25px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid var(--border-color);
}
.movements-header h3 { font-size: 18px; }

.export-btn {
  background-color: white;
  border: 1px solid var(--border-color);
  color: var(--text-dark);
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
}
.export-btn i { margin-right: 8px; color: var(--text-sub); }

.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}

.data-table th {
  text-align: left;
  color: var(--text-sub);
  font-weight: 600;
  padding: 15px 25px;
  border-bottom: 1px solid var(--border-color);
}

.data-table td {
  padding: 20px 25px;
  border-bottom: 1px solid var(--border-color);
  vertical-align: middle;
}

.data-table strong { color: var(--text-dark); }
.data-table em { font-style: normal; font-weight: 600;}
.data-table i { margin: 0 5px; color: var(--border-color); }

.type-tag { margin-left: 10px; font-weight: 600;}
.blue-tag { color: var(--blue-primary); }

.status-tag {
  display: inline-flex;
  align-items: center;
  padding: 4px 8px;
  border-radius: 4px;
  font-weight: 700;
  font-size: 11px;
}
.status-tag i { margin-right: 5px; font-size: 10px; color: inherit; }
.green-tag { background-color: #F0FFF4; color: var(--green-primary); }
.red-tag { background-color: #FFF5F5; color: var(--red-primary); }

.view-all-btn {
  width: 100%;
  padding: 15px;
  background-color: #F7FAFC;
  color: var(--blue-dark);
  font-weight: 700;
  font-size: 14px;
  border-bottom-left-radius: 12px;
  border-bottom-right-radius: 12px;
}
</style>





