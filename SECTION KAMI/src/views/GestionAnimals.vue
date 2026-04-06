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
            <button class="btn-action btn-primary">
              <i class="fas fa-plus"></i> Ajouter un animal
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
              <th>ACTIONS</th>
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
              <td>
                <button class="edit-icon-btn"><i class="far fa-edit"></i></button>
              </td>
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
          <h3>Plateforme de croissance</h3>
          <span class="badge-gm">GMQ: +0.8kg</span>
        </div>
        <div class="bar-chart-visual">
          <div class="bar" style="height: 40%"></div>
          <div class="bar" style="height: 60%"></div>
          <div class="bar highlight" style="height: 100%"></div>
          <div class="bar" style="height: 75%"></div>
          <div class="bar" style="height: 50%"></div>
        </div>
      </div>

      <div class="card species-card">
        <h3>Ratio par Espèce</h3>
        <div class="ratio-item">
          <div class="label-row"><span>Bovin</span> <span>35%</span></div>
          <div class="progress-track"><div class="fill green" style="width: 35%"></div></div>
        </div>
        <div class="ratio-item">
          <div class="label-row"><span>Ovin</span> <span>65%</span></div>
          <div class="progress-track"><div class="fill blue" style="width: 65%"></div></div>
        </div>
        <div class="pasture-load">
          <i class="fas fa-leaf"></i>
          <div>
            <strong>Charge des Pâturages</strong>
            <p>85% Capacité - Optimale</p>
          </div>
        </div>
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
.bottom-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; margin-top: 25px; }
.card { background: white; padding: 20px; border-radius: 16px; border: 1px solid #edf2f7; box-shadow: 0 4px 12px rgba(0,0,0,0.02); }
.bar-chart-visual { display: flex; align-items: flex-end; gap: 12px; height: 140px; margin-top: 20px; }
.bar { flex: 1; background: #f1f5f9; border-radius: 6px 6px 0 0; }
.bar.highlight { background: #2ecc71; }
.progress-track { background: #f1f5f9; height: 8px; border-radius: 10px; margin-top: 10px; overflow: hidden; }
.fill.green { background: #2ecc71; height: 100%; }
.fill.blue { background: #3182ce; height: 100%; }
.pasture-load { background: #f0fff4; padding: 15px; border-radius: 12px; display: flex; gap: 12px; align-items: center; margin-top: 20px; border: 1px solid #c6f6d5; }
.pasture-load i { font-size: 20px; color: #2ecc71; background: white; padding: 10px; border-radius: 10px; }
</style>

<script setup>
import { ref } from 'vue'

const animals = ref([
  { tag: '882-AF', ferme: '0042', espece: 'Bovin', sexe: 'Femelle', poids: 540, dateNaiss: '12 Oct 2021', lieu: 'Barn 2', sante: 'Sain', santeClass: 'sain', vaccinStatus: 'À jour', vaccinClass: 'ok' },
  { tag: '901-SX', ferme: '0155', espece: 'Ovin', sexe: 'Mâle', poids: 68, dateNaiss: '05 May 2023', lieu: 'Field 4', sante: 'Traité', santeClass: 'traite', vaccinStatus: '1 dose en attente', vaccinClass: 'wait' }
])
</script>