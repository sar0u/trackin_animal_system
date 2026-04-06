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
              <th>ID ANIMAL</th>
              <th>DE LA FERME</th>
              <th>VERS LA FERME</th>
              <th>DATE</th>
              <th>RAISON</th>
              <th>STATUT</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="mvt in movements" :key="mvt.id">
              <td class="id-tag">{{ mvt.animal }}</td>
              <td>{{ mvt.from }}</td>
              <td>{{ mvt.to }}</td>
              <td>{{ mvt.date }}</td>
              <td>{{ mvt.reason }}</td>
              <td>
                <span class="status-badge" :class="mvt.statusClass">
                  {{ mvt.status }}
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
/* STRUCTURE */
.page-container {
 background-color: #f8fafb;
 min-height: 100vh;
 padding: 25px;
 font-family: 'Inter', sans-serif;
 }

/* HEADER : Alignement horizontal parfait */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}
.title-group h1 { font-size: 28px; font-weight: 800; color: #1a202c; margin: 0; white-space: nowrap; }
.subtitle { color: #a0aec0; font-size: 14px; margin-top: 4px; }

.header-ctrl { display: flex; gap: 15px; align-items: center; }
.date-selector {
  background: white;
  padding: 10px 18px;
  border-radius: 10px;
  border: 1px solid #edf2f7;
  font-size: 14px;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 12px;
  color: #4a5568;
}
.export-btn {
  background: #11D432;
  color: white;
  border: none;
  height: 40px;
  padding: 0 20px;
  border-radius: 10px;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
}

/* CARDS */
.card { background: white; border-radius: 16px; border: 1px solid #edf2f7; padding: 25px; margin-bottom: 25px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); }

/* SECTION MOUVEMENTS RÉCENTS */
.card-title-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
.card-title-row h3 { font-size: 18px; font-weight: 800; color: #2d3748; display: flex; align-items: center; }

/* Modification : Icône verte du titre */
.green-icon { color: #2ecc71; margin-right: 12px; font-size: 20px; }

/* Modification : Bouton filtrer style TraceDZ */
.filter-btn-new {
  background-color: #f8fafb;
  color: #718096;
  border: 1px solid #edf2f7;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: 0.2s;
}
.filter-btn-new:hover {
  background-color: #edf2f7;
  }

/* TABLEAU */
.table-responsive {
  width: 100%;
  overflow-x: auto;
  }
.movement-table {
  width: 100%;
  border-collapse: collapse;
  }
.movement-table th { text-align: left; padding: 12px; color: #a0aec0; font-size: 11px; text-transform: uppercase; border-bottom: 1px solid #f1f5f9; letter-spacing: 0.5px; }
.movement-table td { padding: 16px 12px; font-size: 13px; border-bottom: 1px solid #f8fafb; color: #4a5568; }
.id-tag { color: #2ecc71; font-weight: 800; font-family: monospace; }
.status-badge { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: 800; }
.status-badge.complet { background: #f0fff4; color: #2ecc71; }
.status-badge.transit { background: #ebf8ff; color: #3182ce; }

.pagination-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 25px;
  margin-top: 15px;
  border-top: 1px solid #f1f5f9; /* Ligne de séparation subtile */
}

.pagination-info {
  font-size: 13px;
  color: #a0aec0;
  font-weight: 600;
}

.pagination-controls {
  display: flex;
  gap: 8px;
}

.btn-nav, .page-num {
  height: 36px;
  padding: 0 14px;
  border-radius: 8px;
  background: white;
  border: 1px solid #edf2f7;
  color: #718096;
  font-weight: 700;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s ease;
}

/* Style pour la page active (Vert TraceDZ) */
.page-num.active {
  background: #11D432;
  color: white;
  border-color: #2ecc71;
  box-shadow: 0 4px 10px rgba(46, 204, 113, 0.2);
}

.btn-nav:hover, .page-num:hover:not(.active) {
  background: #f8fafb;
  border-color: #cbd5e0;
}

/* GRAPHIQUE */
.card-header-chart { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 25px; }
.year-select { padding: 8px 12px; border-radius: 8px; border: 1px solid #edf2f7; color: #718096; font-size: 13px; background: #f8fafb; }
.line-chart-visual { padding: 20px 0; }
.months-labels { display: flex; justify-content: space-between; margin-top: 25px; color: #a0aec0; font-size: 11px; font-weight: 700; }

/* STATS GRID */
.section-title { font-size: 18px; font-weight: 800; color: #2d3748; margin: 35px 0 20px; }
.bottom-stats-grid { display: grid; grid-template-columns: 1fr 1.5fr 1.2fr; gap: 20px; }
.mini-card { background: white; padding: 20px; border-radius: 12px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center; border: 1px solid #edf2f7; }
.mini-card .val { display: block; font-size: 24px; font-weight: 800; color: #2d3748; margin: 5px 0; }
.mini-card .label { font-size: 10px; font-weight: 800; color: #a0aec0; letter-spacing: 0.5px; }
.mini-card i { font-size: 24px; color: #edf2f7; }
/* --- Partie CSS à modifier ou ajouter --- */

/* Carte Utilisateurs Actifs */
.colored-icon-users {
  color: #2ecc71; /* Vert */

}

/* Carte Total Fermes */
.colored-icon-farms {
  color: #3182ce; /* Bleu */

}

/* Carte Total Animaux (Nouvelle classe) */
.colored-icon-animaux {
  color: #2ecc71; /* Vert */

}

.progress-bar { height: 8px; background: #f1f5f9; border-radius: 10px; margin: 12px 0 20px; overflow: hidden; }
.progress-bar .fill { height: 100%; background: #2ecc71; border-radius: 10px; }

.donut-container { width: 140px; height: 140px; border-radius: 50%; border: 12px solid #2ecc71; margin: 30px auto; display: flex; align-items: center; justify-content: center; }
.legend { list-style: none; padding: 0; font-size: 12px; font-weight: 700; color: #718096; }
.legend li { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
.dot { width: 8px; height: 8px; border-radius: 50%; }
.dot.bovin { background: #2ecc71; }
.dot.ovin { background: #3182ce; }
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