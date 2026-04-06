<template>


    <main class="main-content">

      <section class="content-body">
        <div class="welcome-header">
          <h1>Bienvenue, Administrateur</h1>
          <p class="subtitle">Voici l'aperçu de votre exploitation agricole aujourd'hui.</p>
        </div>

        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-icon green"><i class="fas fa-paw"></i></div>
            <div class="stat-data">
              <span class="label">TOTAL BÉTAIL</span>
              <span class="value">{{ totalBetail.toLocaleString() }}</span>
            </div>
            <span class="trend positive">+12%</span>
          </div>

          <div class="stat-card">
            <div class="stat-icon blue"><i class="fas fa-map-marker-alt"></i></div>
            <div class="stat-data">
              <span class="label">FERMES ACTIVES</span>
              <span class="value">{{ fermesActives }}</span>
            </div>
            <span class="trend positive">+5%</span>
          </div>

          <div class="stat-card">
            <div class="stat-icon teal"><i class="fas fa-users"></i></div>
            <div class="stat-data">
              <span class="label">UTILISATEURS</span>
              <span class="value">{{ totalUtilisateurs }}</span>
            </div>
            <span class="trend positive">+8%</span>
          </div>
        </div>

        <div class="dashboard-main-grid">
          <div class="card chart-section">
            <div class="card-header">
              <h3>Mouvements Récents</h3>
              <select class="period-select">
                <option>Derniers 30 jours</option>
              </select>
            </div>
            <div class="chart-container">
                   <div class="bar-chart-placeholder"></div>
            </div>
          </div>

          <div class="card users-section">
            <div class="card-header">
              <h3>Derniers Utilisateurs</h3>
            </div>
            <div class="user-list">
              </div>
            <a href="#" class="view-all">Voir tous les utilisateurs</a>
          </div>
        </div>

        <div class="card table-section">
          <div class="card-header">
            <h3>Répartition par Ferme</h3>
            <button class="export-btn"><i class="fas fa-download"></i> Exporter</button>
          </div>
          <table class="data-table">
            <thead>
              <tr>
                <th>FERME</th>
                <th>PROPRIÉTAIRE</th>
                <th>BÉTAIL</th>
                <th>LOCALISATION</th>
                <th>STATUT</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><strong>Grande Plaine</strong></td>
                <td>Bouriche Anis</td>
                <td>342</td>
                <td>Normandie</td>
                <td><span class="status-badge active">Actif</span></td>
              </tr>
            </tbody>
          </table>
        </div>

      </section>
    </main>
</template>

<script setup>
import AppSidebar from '@/components/AppSidebar.vue'
import AppTopbar from '@/components/AppTopbar.vue'
import { ref, onMounted } from 'vue'

// Initialisation avec des valeurs par défaut pour éviter le "null"
const totalBetail = ref(0)
const fermesActives = ref(0)
const totalUtilisateurs = ref(0)

onMounted(() => {
  totalBetail.value = 1240
  fermesActives.value = 45
})
</script>

<style scoped>

/* 5. BODY & GRID */
.content-body {
  width: 100%;
  font-family: 'Inter', sans-serif;
}

.welcome-header h1 {
  font-size: 28px;
  color: #1a202c;
  margin-bottom: 8px;
  font-weight: 800;
}
.subtitle {
  color: #718096;
  font-size: 15px;
  margin-bottom: 35px;
}

/* 6. STAT CARDS */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 25px;
  margin-bottom: 40px;
}

.stat-card {
  background: white;
  padding: 25px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  position: relative;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
}

.stat-icon {
  width: 55px;
  height: 55px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  margin-right: 20px;
}

/* Couleurs des icônes selon la maquette */
.stat-icon.green {
  background: #f0fff4;
  color: #38a169;
}
.stat-icon.blue {
  background: #ebf8ff;
  color: #3182ce;
}
.stat-icon.teal {
  background: #e6fffa;
  color: #319795;
}

.value {
  display: block;
  font-size: 26px;
  font-weight: 800;
  color: #2d3748;
  margin-top: 5px;
}
.label {
  font-size: 12px;
  color: #a0aec0;
  font-weight: 700;
  letter-spacing: 0.5px;
}

.trend {
  position: absolute;
  top: 25px;
  right: 25px;
  font-size: 13px;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 30px;
}

.trend.positive {
  background: #f0fff4;
  color: #38a169;
}

.dashboard-main-grid {
  display: grid;
  /* Définit deux colonnes : la première est 2x plus grande que la seconde */
  grid-template-columns: 2fr 1fr;
  gap: 25px; /* Espace entre les deux blocs */
  margin-bottom: 30px;
  align-items: start; /* Aligne le haut des deux cartes */
}

/* 7. TABLES & CARDS */
/* Style des cartes pour correspondre à l'image */
.card {
  box-sizing: border-box;
  background: white;
  border-radius: 16px;
  padding: 25px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
  height: auto;

}

.chart-section {
  min-height: 400px; /* Taille adaptée pour le graphique à barres */
}

.users-section {
  display: flex;
  flex-direction: column;
}

.view-all-link {
  margin-top: auto; /* Pousse le lien vers le bas de la carte */
  text-align: center;
  color: #2ecc71;
  text-decoration: none;
  font-weight: 700;
  font-size: 14px;
  padding-top: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
}

.data-table th {
  color: #a0aec0;
  font-size: 12px;
  text-transform: uppercase;
  padding: 15px;
  border-bottom: 1px solid #edf2f7;
}

.data-table td {
  padding: 18px 15px;
  border-bottom: 1px solid #f7fafc;
  font-size: 14px;
}

.status-badge {
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 700;
}

.status-badge.active {
  background: #f0fff4;
  color: #38a169;
}

.export-btn {
  background: white;
  border: 1px solid #edf2f7;
  padding: 8px 15px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  color: #4a5568;
  display: flex;
  align-items: center;
  gap: 8px;
}
</style>





