<template>
  <div class="page-container">
    <div class="page-header">
      <div class="title-group">
        <h1>Gestion Mouvements & Statistiques</h1>
        <p class="subtitle">Monitoring livestock logistics and transit performance.</p>
      </div>

      <div class="header-ctrl">
        <div class="date-selector">
          <i class="fas fa-chevron-left"></i>
          <span>Octobre 2023</span>
          <i class="fas fa-chevron-right"></i>
        </div>
        <button class="export-btn">
          <i class="fas fa-paper-plane"></i> Exporter
        </button>
      </div>
    </div>

    <div class="card movement-card">
      <div class="card-title-row">
        <h3><i class="fas fa-exchange-alt green-icon"></i> Mouvements Récents</h3>
        <button class="filter-btn-new">
          <i class="fas fa-sliders-h"></i> Filtrer
        </button>
      </div>

      <div class="table-responsive">
        <table class="movement-table">
          <thead>
            <tr>
              <th>ID Animal</th>
              <th>De la Ferme</th> <th>Vers la Ferme</th> <th>Date</th>
              <th>Raison</th>
              <th>Statut</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="mvt in movements" :key="mvt.id">
              <td><span class="id-tag">{{ mvt.animal }}</span></td>
              <td class="farm-name">{{ mvt.from }}</td> <td class="farm-name">{{ mvt.to }}</td>   <td class="date-cell">{{ mvt.date }}</td>
              <td>{{ mvt.reason }}</td>
              <td>
                <span class="status-badge" :class="mvt.statusClass">
                  <span class="dot"></span> {{ mvt.status }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="pagination-footer">
            <span class="pagination-info">Affichage de 1 à 8 sur 1,284 mouvements</span>
            <div class="pagination-controls">
              <button class="btn-nav">Précédent</button>
              <button class="page-num active">1</button>
              <button class="page-num">2</button>
              <button class="page-num">3</button>
              <button class="btn-nav">Suivant</button>
            </div>
          </div>
    </div>


    <div class="card chart-full-card">
      <div class="card-header-chart">
        <div>
          <h3>Diagramme de déplacement</h3>
          <p>Évolution des flux de transit sur l'année en cours</p>
        </div>
        <select class="year-select"><option>2023 (Toutes les régions)</option></select>
      </div>
      <div class="line-chart-visual">
        <svg viewBox="0 0 1000 200" class="curve">
          <path d="M0,150 Q150,140 300,120 T600,130 T900,20 L1000,80" fill="none" stroke="#2ecc71" stroke-width="4"/>
          <circle cx="300" cy="120" r="6" fill="#2ecc71" />
          <circle cx="600" cy="130" r="6" fill="#2ecc71" />
          <circle cx="900" cy="20" r="6" fill="#2ecc71" />
        </svg>
        <div class="months-labels">
          <span>JAN</span><span>FEV</span><span>MAR</span><span>AVR</span><span>MAI</span><span>JUIN</span>
          <span>JUIL</span><span>AOUT</span><span>SEPT</span><span>OCT</span><span>NOV</span><span>DEC</span>
        </div>
      </div>
    </div>

    <h2 class="section-title">Statistiques Globales</h2>

    <div class="bottom-stats-grid">
      <div class="stats-col">
        <div class="mini-card">
          <div class="info">
            <span class="label">UTILISATEURS ACTIFS</span>
            <span class="val">1,284</span>
            <span class="trend">+12% ce mois</span>
          </div>
          <i class="fas fa-users-cog colored-icon-users"></i>
        </div>
        <div class="mini-card">
          <div class="info">
            <span class="label">TOTAL FERMES</span>
            <span class="val">42</span>
            <span class="trend stable">Stable</span>
          </div>
          <i class="fas fa-tractor colored-icon-farms"></i>
        </div>
        <div class="mini-card">
          <div class="info">
            <span class="label">TOTAL ANIMAUX</span>
            <span class="val">15,702</span>
            <span class="trend">+345 ce mois</span>
          </div>
          <i class="fas fa-paw colored-icon-animaux"></i>
        </div>
      </div>

      <div class="card activity-card">
        <h3>Activité par Ferme</h3>
        <div v-for="farm in farmActivity" :key="farm.name" class="progress-item">
          <div class="progress-info"><span>{{ farm.name }}</span> <span>{{ farm.val }}%</span></div>
          <div class="progress-bar"><div class="fill" :style="{width: farm.val + '%'}"></div></div>
        </div>
      </div>

      <div class="card donut-card">
        <h3>Répartition par Espèce</h3>
        <div class="donut-container">
          <div class="donut-hole">
            <strong>15k</strong>
            <span>TOTAL</span>
          </div>
        </div>
        <ul class="legend">
          <li><span class="dot bovin"></span> BOVINS (65%)</li>
          <li><span class="dot ovin"></span> OVINS (25%)</li>
          <li><span class="dot autres"></span> AUTRES (10%)</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* BASE ET TYPOGRAPHIE */
.page-container {
  background-color: #f8fafb;
  min-height: 100vh;
  padding: 30px;
  font-family: 'Inter', sans-serif;
  color: #2d3748;
}

/* HEADER */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.title-group h1 {
  font-size: 26px;
  font-weight: 800;
  color: #1a202c;
  margin: 0;
}

.subtitle {
  color: #718096;
  font-size: 14px;
  margin-top: 5px;
}

.header-ctrl {
  display: flex;
  gap: 15px;
}

.date-selector {
  background: white;
  padding: 10px 20px;
  border-radius: 12px;
  border: 1px solid #edf2f7;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 15px;
  color: #4a5568;
  box-shadow: 0 2px 4px rgba(0,0,0,0.02);
}

.date-selector i {
  cursor: pointer;
  color: #cbd5e0;
  transition: color 0.2s;
}

.date-selector i:hover { color: #11D432; }

.export-btn {
  background: #11D432;
  color: white;
  border: none;
  padding: 0 25px;
  border-radius: 12px;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(17, 212, 50, 0.2);
}

.export-btn:hover {
  transform: translateY(-2px);
  filter: brightness(1.1);
}

/* CARTES COMMUNES */
.card {
  background: white;
  border-radius: 20px;
  border: 1px solid #edf2f7;
  padding: 25px;
  margin-bottom: 25px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.03);
}

/* SECTION MOUVEMENTS */
.card-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.card-title-row h3 {
  font-size: 18px;
  font-weight: 800;
}

.green-icon {
  color: #11D432;
  margin-right: 12px;
}

.filter-btn-new {
  background: #f8fafc;
  color: #718096;
  border: 1px solid #e2e8f0;
  padding: 8px 16px;
  border-radius: 10px;
  font-weight: 700;
  font-size: 13px;
  cursor: pointer;
}

/* TABLEAU DES MOUVEMENTS AMÉLIORÉ */
/* TABLEAU DES MOUVEMENTS */
.table-responsive {
  border-radius: 12px;
  overflow-x: auto; /* Permet le scroll si le texte est très long */
  background: white;
}

.movement-table {
  width: 100%;
  border-collapse: collapse;
  table-layout: auto; /* Laisse les colonnes s'ajuster au contenu */
}

.movement-table th {
  text-align: left;
  padding: 15px 20px;
  color: #a0aec0;
  font-size: 11px;
  font-weight: 800;
  text-transform: uppercase;
  border-bottom: 2px solid #f1f5f9;
  white-space: nowrap;
}

.movement-table td {
  padding: 16px 20px;
  vertical-align: middle;
  border-bottom: 1px solid #f8fafb;
  white-space: nowrap; /* Force l'affichage sur une seule ligne */
  color: #2d3748;
  font-size: 14px;
}

/* Effet au survol */
.movement-table tr:hover td {
  background-color: #f0fdf4;
}

.farm-name {
  font-weight: 700;
  color: #1a202c;
  font-size: 14px;
}

.id-tag {
  display: inline-block;
  color: #11D432 !important;
  font-weight: 900 !important;
  background: #f0fff4;
  padding: 6px 10px;
  border-radius: 8px;
  font-family: 'JetBrains Mono', monospace;
  font-size: 13px;
}

/* L'effet de ligne au survol */
.movement-table tr:hover td {
  background-color: #f0fdf4;
}

.table-responsive {
  border-radius: 12px;
  overflow-x: auto; /* Permet le scroll horizontal sur mobile */
}

.pagination-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 25px;
  padding-top: 20px;
  border-top: 1px solid #f1f5f9;
}

.pagination-info {
  font-size: 13px;
  color: #718096;
  font-weight: 500;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-nav {
  background: white;
  border: 1px solid #e2e8f0;
  color: #4a5568;
  padding: 8px 16px;
  border-radius: 10px;
  font-weight: 600;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s;
}

.page-num {
  width: 38px;
  height: 38px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 10px;
  background: white;
  border: 1px solid #e2e8f0;
  color: #4a5568;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
}

.page-num.active {
  background: #11D432;
  color: white;
  border-color: #11D432;
  box-shadow: 0 4px 10px rgba(17, 212, 50, 0.2);
}

.page-num:hover:not(.active), .btn-nav:hover {
  background: #f8fafc;
  border-color: #cbd5e0;
}

/* Style de l'ID Animal */
.id-tag {
  color: #11D432 !important;
  font-weight: 900 !important;
  background: #f0fff4;
  padding: 6px 10px;
  border-radius: 8px;
  font-family: 'JetBrains Mono', monospace;
}

/* Chemin du mouvement (Flèche) */
.movement-path {
  display: flex;
  align-items: center;
  gap: 12px;
  font-weight: 600;
}

.transit-arrow {
  color: #11D432;
  font-size: 12px;
  opacity: 0.6;
}

.farm-name {
  color: #1a202c;
}

.date-cell {
  color: #718096;
  font-weight: 500;
}

/* Status Badge avec Point */
.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 14px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 800;
}

.status-badge .dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

.status-badge.complet { background: #f0fff4; color: #11D432; }
.status-badge.complet .dot { background: #11D432; }

.status-badge.transit { background: #ebf8ff; color: #3182ce; }
.status-badge.transit .dot { background: #3182ce; }

/* GRAPHIQUE LINÉAIRE */
.chart-full-card {
  background: linear-gradient(to bottom, #ffffff, #fcfdfd);
}

.card-header-chart h3 { font-size: 18px; font-weight: 800; margin: 0; }
.card-header-chart p { color: #a0aec0; font-size: 13px; margin: 5px 0 0; }

.line-chart-visual {
  margin-top: 30px;
  position: relative;
}

.curve path {
  stroke-dasharray: 1000;
  stroke-dashoffset: 1000;
  animation: draw 2s forwards ease-in-out;
}

@keyframes draw { to { stroke-dashoffset: 0; } }

.months-labels {
  display: flex;
  justify-content: space-between;
  margin-top: 20px;
  color: #cbd5e0;
  font-size: 11px;
  font-weight: 800;
}

/* STATS DU BAS */
.bottom-stats-grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 25px;
}

.mini-card {
  background: white;
  padding: 25px;
  border-radius: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border: 1px solid #edf2f7;
  transition: transform 0.3s;
}

.mini-card:hover { transform: translateY(-5px); }

.mini-card .label { font-size: 11px; font-weight: 800; color: #a0aec0; text-transform: uppercase; }
.mini-card .val { display: block; font-size: 28px; font-weight: 900; color: #1a202c; margin: 5px 0; }
.mini-card .trend { font-size: 12px; font-weight: 700; color: #11D432; }
.mini-card .trend.stable { color: #a0aec0; }

.colored-icon-users, .colored-icon-animaux { color: #11D432; font-size: 32px; opacity: 0.2; }
.colored-icon-farms { color: #3182ce; font-size: 32px; opacity: 0.2; }

/* PROGRESSION ACTIVITÉ */
.activity-card h3 { font-size: 16px; margin-bottom: 20px; }
.progress-item { margin-bottom: 20px; }
.progress-info { display: flex; justify-content: space-between; font-size: 13px; font-weight: 700; margin-bottom: 8px; }
.progress-bar { height: 10px; background: #f1f5f9; border-radius: 20px; overflow: hidden; }
.progress-bar .fill { background: linear-gradient(90deg, #11D432, #58d68d); border-radius: 20px; transition: width 1s ease-in-out; }

/* DONUT CHART */
.donut-card { text-align: center; }
.donut-container {
  width: 150px;
  height: 150px;
  margin: 20px auto;
  border-radius: 50%;
  background: conic-gradient(#11D432 65%, #3182ce 65% 90%, #e2e8f0 90%);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.donut-hole {
  width: 110px;
  height: 110px;
  background: white;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  box-shadow: inset 0 2px 10px rgba(0,0,0,0.05);
}

.donut-hole strong { font-size: 24px; color: #1a202c; }
.donut-hole span { font-size: 10px; color: #a0aec0; font-weight: 800; }

.legend {
  list-style: none;
  padding: 0;
  text-align: left;
  margin-top: 20px;
}

.legend li {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 12px;
  font-weight: 700;
  margin-bottom: 8px;
}
</style>

<script setup>
import { ref } from 'vue'

const movements = ref([
  { animal: '#ANM-0892', from: 'Green Valley East', to: 'Central Hub A', date: '12 Oct, 2023', reason: 'Pâturage de saison', status: 'Complété', statusClass: 'complet' },
  { animal: '#ANM-0744', from: 'North Plateau', to: 'Green Valley East', date: '11 Oct, 2023', reason: 'Soins médicaux', status: 'En transit', statusClass: 'transit' }
])

const farmActivity = ref([
  { name: 'Central Hub A', val: 72 },
  { name: 'Green Valley East', val: 58 },
  { name: 'North Plateau', val: 45 }
])
</script>