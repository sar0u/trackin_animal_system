<template>
  <div class="page-cont">
    <div class="stats-overview">
      <div class="mini-stat-card">
        <div class="icon-box green"><i class="fas fa-paw"></i></div>
        <div class="stat-data">
          <span class="label">TOTAL DU BÉTAIL</span>
          <span class="number">1,284</span>
        </div>
      </div>
      <div class="mini-stat-card">
        <div class="icon-box blue"><i class="fas fa-layer-group"></i></div>
        <div class="stat-data">
          <span class="label">RÉPARTITION ESPÈCES</span>
          <span class="desc">Bovin: 450 | Ovin: 834</span>
        </div>
      </div>
      <div class="mini-stat-card">
        <div class="icon-box orange"><i class="fas fa-syringe"></i></div>
        <div class="stat-data">
          <span class="label">VACCINS À PRÉVOIR</span>
          <span class="number">12</span>
        </div>
      </div>
      <div class="mini-stat-card">
        <div class="icon-box red"><i class="fas fa-exclamation-triangle"></i></div>
        <div class="stat-data">
          <span class="label">ALERTES SANITAIRES</span>
          <span class="number">3</span>
        </div>
      </div>
    </div>

    <div class="main-white-card">
      <div class="page-header">
        <h1 class="page-title">Gestion des Animaux</h1>

        <div class="header-toolbar">
          <div class="search-wrapper">
            <i class="fas fa-qrcode"></i>
            <input type="text" placeholder="Scanner ou saisir n° de Tag...">
          </div>

          <div class="filters-group">
            <select class="filter-select"><option>Par Espèce</option></select>
            <select class="filter-select"><option>Par état santé</option></select>
          </div>

          <div class="buttons-group">
            <button class="btn-action btn-secondary">
              <i class="fas fa-download"></i> Exporter
            </button>

          </div>
        </div>
      </div>

      <div class="table-responsive">
        <table class="animal-table">
          <thead>
            <tr>
              <th>N° DE TAG</th>
              <th>ID FERME</th>
              <th>ESPÈCE</th>
              <th>SEXE</th>
              <th>POIDS</th>
              <th>INFO NAISS.</th>
              <th>SANTÉ</th>
              <th>VACCINATION</th>
              <th>REPRODUCTION</th>

            </tr>
          </thead>
          <tbody>
            <tr v-for="animal in animals" :key="animal.tag">
              <td><span class="tag-badge">{{ animal.tag }}</span></td>
              <td><strong>{{ animal.ferme }}</strong></td>
              <td>{{ animal.espece }}</td>
              <td>{{ animal.sexe }}</td>
              <td>{{ animal.poids }} kg</td>
              <td><span class="date">{{ animal.dateNaiss }}</span></td>
              <td><span class="status-pill" :class="animal.santeClass">{{ animal.sante }}</span></td>
              <td>
                <div class="vaccin-badge" :class="animal.vaccinClass">
                  <i class="fas fa-check-circle"></i> {{ animal.vaccinStatus }}
                </div>
              </td>
              <td class="repro-text">{{ animal.reproStatus || 'N/A' }}</td>

            </tr>
          </tbody>
        </table>
      </div>

      <div class="pagination-footer">
        <span class="pagination-info">Affichage de 1 à 8 sur 1,284 animaux</span>
        <div class="pagination-controls">
          <button class="btn-nav">Précédent</button>
          <button class="page-num active">1</button>
          <button class="page-num">2</button>
          <button class="page-num">3</button>
          <button class="btn-nav">Suivant</button>
        </div>
      </div>
    </div>

    <div class="bottom-grid">
      <div class="card chart-card">
        <div class="card-header-flex">
          <div class="header-titles">
            <h3>Plateforme de croissance</h3>
            <p class="card-subtitle">Évolution du poids moyen par mois</p>
          </div>
          <span class="badge-gm">GMQ: <span class="green-text">+0.8kg</span></span>
        </div>

        <div class="chart-container">
          <div class="bar-chart-visual">
            <div class="bar-wrapper"><div class="bar" style="height: 45%"></div><span class="bar-label">Jan</span></div>
            <div class="bar-wrapper"><div class="bar" style="height: 60%"></div><span class="bar-label">Fév</span></div>
            <div class="bar-wrapper"><div class="bar" style="height: 55%"></div><span class="bar-label">Mar</span></div>
            <div class="bar-wrapper"><div class="bar highlight" style="height: 90%"></div><span class="bar-label">Avr</span></div>
            <div class="bar-wrapper"><div class="bar" style="height: 75%"></div><span class="bar-label">Mai</span></div>
            <div class="bar-wrapper"><div class="bar" style="height: 80%"></div><span class="bar-label">Juin</span></div>
          </div>
        </div>
      </div>

      <div class="card species-card">
        <div class="card-header-flex">
          <h3>Ratio par Espèce</h3>
          <i class="fas fa-chart-pie chart-icon"></i>
        </div>

        <div class="ratio-section">
          <div class="ratio-item">
            <div class="label-row">
              <span class="species-name"><i class="fas fa-circle dot-bovin"></i> Bovin</span>
              <span class="percent">35%</span>
            </div>
            <div class="progress-track"><div class="fill green-tracedz" style="width: 35%"></div></div>
          </div>

          <div class="ratio-item">
            <div class="label-row">
              <span class="species-name"><i class="fas fa-circle dot-ovin"></i> Ovin</span>
              <span class="percent">65%</span>
            </div>
            <div class="progress-track"><div class="fill blue-tracedz" style="width: 65%"></div></div>
          </div>
        </div>

        <div class="pasture-load">
          <div class="icon-circle">
            <i class="fas fa-leaf"></i>
          </div>
          <div class="load-info">
            <strong>Charge des Pâturages</strong>
            <p>Capacité <span class="green-text">Optimale</span> (85%)</p>
          </div>
          <i class="fas fa-chevron-right arrow-detail"></i>
        </div>
      </div>
    </div>

    <div class="stats-footer-grid">
          <div class="card birth-card">
            <div class="card-header-flex">
              <h3>Naissances par mois</h3>
              <button class="icon-btn"><i class="fas fa-ellipsis-v"></i></button>
            </div>
            <div class="birth-chart">
              <div v-for="(val, index) in [40, 65, 80, 55, 70, 95, 45, 30]" :key="index" class="birth-bar-wrapper">
                <div class="birth-bar" :style="{ height: val + '%' }" :class="{ 'peak': val > 90 }"></div>
              </div>
            </div>
            <div class="chart-labels">
              <span>JAN</span><span>MAR</span><span>MAI</span><span>JUIL</span><span>SEPT</span><span>NOV</span>
            </div>
          </div>

          <div class="card repro-card">
            <h3>Taux de Reproduction par Région</h3>
            <div class="region-stats">
              <div class="region-item">
                <div class="region-info"><span>Est</span><strong>92%</strong></div>
                <div class="progress-bar"><div class="progress-fill" style="width: 92%"></div></div>
              </div>
              <div class="region-item">
                <div class="region-info"><span>Ouest</span><strong>87%</strong></div>
                <div class="progress-bar"><div class="progress-fill" style="width: 87%"></div></div>
              </div>
              <div class="region-item">
                <div class="region-info"><span>Capitale et ses environs</span><strong>79%</strong></div>
                <div class="progress-bar"><div class="progress-fill" style="width: 79%"></div></div>
              </div>
            </div>
          </div>

          <div class="card cheptel-card">
            <div class="cheptel-icon-box">
              <i class="fas fa-chart-line"></i>
            </div>
            <h3>ÉVOLUTION DU CHEPTEL</h3>
            <div class="cheptel-value">+14.2%</div>
            <p class="cheptel-desc">Croissance annuelle projetée basée sur les gestations actuelles.</p>
          </div>
        </div>
  </div>
</template>

<style scoped>
/* STRUCTURE GÉNÉRALE */
.page-cont {
 background-color: #f8fafb;
 min-height: 100vh;
 padding: 25px;
 font-family: 'Inter', sans-serif;
 }

/* STATS */
.stats-overview { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 25px; }
.mini-stat-card { background: white; padding: 20px; border-radius: 12px; display: flex; align-items: center; gap: 15px; border: 1px solid #edf2f7; }
.stat-data { display: flex; flex-direction: column; }
.stat-data .label { font-size: 10px; font-weight: 800; color: #a0aec0; letter-spacing: 0.5px; }
.stat-data .number { font-size: 22px; font-weight: 900; color: #2d3748; }
.stat-data .desc { font-size: 11px; color: #718096; font-weight: 600; }
.icon-box { width: 45px; height: 45px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 18px; }
.icon-box.green { background: #f0fff4; color: #2ecc71; }
.icon-box.blue { background: #ebf8ff; color: #3182ce; }
.icon-box.orange { background: #fffaf0; color: #ed8936; }
.icon-box.red { background: #fff5f5; color: #e53e3e; }

/* CADRE BLANC & HEADER */
.main-white-card { background: white; padding: 25px; border-radius: 16px; box-shadow: 0 4px 12px rgba(0,0,0,0.03); margin-bottom: 25px; border: 1px solid #edf2f7; }
.page-header { display: flex; flex-direction: column; gap: 20px; margin-bottom: 25px; }
.page-title { font-size: 24px; font-weight: 800; color: #1a202c; margin: 0; }
.header-toolbar { display: flex; align-items: center; justify-content: space-between; gap: 15px; width: 100%; }

/* INPUTS ET BOUTONS */
.search-wrapper { background: #f1f5f9; padding: 10px 15px; border-radius: 10px; display: flex; align-items: center; gap: 10px; flex: 1; max-width: 350px; }
.search-wrapper input { border: none; background: transparent; outline: none; font-size: 14px; width: 100%; color: #4a5568; }
.filters-group, .buttons-group { display: flex; gap: 10px; align-items: center; }
.btn-action, .filter-select { height: 40px; padding: 0 15px; border-radius: 10px; font-size: 13px; font-weight: 700; cursor: pointer; display: flex; align-items: center; gap: 8px; border: 1px solid transparent; }
.btn-primary { background: #11D432; color: white; }
.btn-secondary, .filter-select { background: #f8fafb; color: #718096; border-color: #edf2f7; }

/* TABLEAU */
.table-responsive { width: 100%; overflow-x: auto; }
.animal-table { width: 100%; border-collapse: collapse; min-width: 1100px; }
.animal-table th { text-align: left; padding: 15px; color: #a0aec0; font-size: 10px; text-transform: uppercase; font-weight: 800; border-bottom: 1px solid #edf2f7; }
.animal-table td { padding: 15px; border-bottom: 1px solid #f8fafb; font-size: 13px; color: #4a5568; }

.tag-badge { background: #f0fff4; color: #2ecc71; padding: 5px 12px; border-radius: 8px; font-weight: 800; border: 1px solid #c6f6d5; font-family: monospace; }
.status-pill { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: 800; }
.status-pill.sain { background: #f0fff4; color: #2ecc71; }

.vaccin-badge { display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 600; color: #2ecc71; }
.repro-text { font-weight: 600; color: #718096; font-size: 12px; }

.edit-icon-btn { background: none; border: none; color: #cbd5e0; cursor: pointer; font-size: 16px; transition: 0.2s; }
.edit-icon-btn:hover { color: #2ecc71; }

/* STYLE PAGINATION */
.pagination-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 25px;
  margin-top: 10px;
  border-top: 1px solid #f1f5f9;
}
.pagination-info { font-size: 13px; color: #a0aec0; font-weight: 600; }
.pagination-controls { display: flex; gap: 8px; }
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
}
.page-num.active { background: #11D432; color: white; border-color: #2ecc71; }

/* GRILLE BASSE */
.bottom-grid { display: grid; grid-template-columns: 1.8fr 1.2fr; gap: 20px; margin-top: 25px; }

.card {
  background: white;
  padding: 24px;
  border-radius: 20px;
  border: 1px solid rgba(226, 232, 240, 0.7);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.02);
}

h3 { font-size: 16px; font-weight: 800; color: #1a202c; margin-bottom: 4px; }
.card-subtitle { font-size: 12px; color: #a0aec0; margin-bottom: 20px; }

/* BAR CHART AMÉLIORÉ */
.card-header-flex { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 15px; }
.badge-gm { background: #f0fff4; padding: 6px 12px; border-radius: 8px; font-size: 11px; font-weight: 800; border: 1px solid #c6f6d5; }
.green-text { color: #11D432; }

.bar-chart-visual {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  height: 180px;
  padding-top: 10px;
  border-bottom: 1px solid #edf2f7;
}

.bar-wrapper { flex: 1; display: flex; flex-direction: column; align-items: center; gap: 12px; height: 100%; justify-content: flex-end; }
.bar {
  width: 35px;
  background: #f1f5f9;
  border-radius: 8px 8px 2px 2px;
  transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}
.bar:hover { filter: brightness(0.95); cursor: pointer; }
.bar.highlight {
  background: linear-gradient(180deg, #11D432 0%, #0ca326 100%);
  box-shadow: 0 4px 12px rgba(17, 212, 50, 0.2);
}
.bar-label { font-size: 11px; color: #a0aec0; font-weight: 700; margin-bottom: -25px; }

/* RATIO SECTION */
.ratio-section { margin: 25px 0; }
.ratio-item { margin-bottom: 18px; }
.label-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.species-name { font-size: 13px; font-weight: 700; color: #4a5568; display: flex; align-items: center; gap: 8px; }
.percent { font-size: 13px; font-weight: 800; color: #2d3748; }

.dot-bovin { color: #11D432; font-size: 8px; }
.dot-ovin { color: #3182ce; font-size: 8px; }

.progress-track { background: #f1f5f9; height: 10px; border-radius: 20px; overflow: hidden; }
.fill { height: 100%; border-radius: 20px; transition: width 1s ease-in-out; }
.green-tracedz { background: #11D432; }
.blue-tracedz { background: #3182ce; }

/* CHARGE PÂTURAGE STYLE "CARD IN CARD" */
.pasture-load {
  background: #f8fafb;
  padding: 16px;
  border-radius: 14px;
  display: flex;
  gap: 15px;
  align-items: center;
  margin-top: 25px;
  border: 1px solid #edf2f7;
  position: relative;
}
.icon-circle {
  width: 40px; height: 40px;
  background: white;
  color: #11D432;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}
.load-info strong { display: block; font-size: 13px; color: #2d3748; }
.load-info p { font-size: 12px; color: #718096; margin: 0; }
.arrow-detail { position: absolute; right: 15px; color: #cbd5e0; font-size: 12px; }

.chart-icon { color: #edf2f7; font-size: 20px; }

/* GRILLE DES STATS DU BAS */
.stats-footer-grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 20px;
  margin-top: 25px;
}

/* CARTE NAISSANCES */
.birth-chart {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  height: 120px;
  margin-top: 20px;
}
.birth-bar-wrapper { flex: 1; display: flex; justify-content: center; }
.birth-bar {
  width: 15px;
  background: #cbd5e0;
  border-radius: 4px;
  transition: 0.3s;
}
.birth-bar.peak { background: #1a365d; } /* Couleur sombre pour le pic */
.chart-labels {
  display: flex;
  justify-content: space-between;
  margin-top: 10px;
  font-size: 10px;
  color: #a0aec0;
  font-weight: 700;
}

/* TAUX DE REPRODUCTION */
.region-stats { margin-top: 15px; }
.region-item { margin-bottom: 15px; }
.region-info { display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 6px; }
.region-info span { color: #2d3748; font-weight: 600; }
.region-info strong { color: #1a365d; }
.progress-bar { height: 6px; background: #edf2f7; border-radius: 10px; overflow: hidden; }
.progress-fill { height: 100%; background: #11D432; border-radius: 10px; }

/* CARTE ÉVOLUTION CHEPTEL (STYLE DARK) */
.cheptel-card {
  background: #11D432; /* Bleu très sombre pour le contraste */
  color: white;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
.cheptel-card h3 { color: black; font-size: 11px; letter-spacing: 1px; }
.cheptel-icon-box {
  width: 35px;
  height: 35px;
  background: rgba(255,255,255,0.1);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 15px;
}
.cheptel-value { font-size: 32px; font-weight: 800; margin: 10px 0; color: white; }
.cheptel-desc { font-size: 12px; color: white; line-height: 1.4; }

/* UTILS */
.icon-btn { background: none; border: none; color: #a0aec0; cursor: pointer; }
</style>

<script setup>
import { ref } from 'vue'

const animals = ref([
  { tag: '882-AF', ferme: '0042', espece: 'Bovin', sexe: 'Femelle', poids: 540, dateNaiss: '12 Oct 2021', lieu: 'Barn 2', sante: 'Sain', santeClass: 'sain', vaccinStatus: 'À jour', vaccinClass: 'ok' },
  { tag: '901-SX', ferme: '0155', espece: 'Ovin', sexe: 'Mâle', poids: 68, dateNaiss: '05 May 2023', lieu: 'Field 4', sante: 'Traité', santeClass: 'traite', vaccinStatus: '1 dose en attente', vaccinClass: 'wait' }
])
</script>