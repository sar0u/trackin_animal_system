<template>
  <div class="page-container">
    <div class="page-header">
      <div class="title-group">
        <h1>Analyse et Détection de Fraudes</h1>
        <p class="subtitle">Vue centralisée des anomalies d'exploitation et d'aide à la décision.</p>
      </div>
      <div class="header-ctrl">
        <select class="region-select">
          <option>Toutes les Régions (Algérie)</option>
        </select>
        <button class="filter-btn">
          <i class="fas fa-filter"></i> Filtrer
        </button>
      </div>
    </div>

    <div class="grid-top">
      <div class="card map-card">
        <div class="map-legend">
          <h4>VUE SATELLITE TACTIQUE</h4>
          <div class="legend-item red">
            <span class="dot"></span> Anomalie Critique
          </div>
          <div class="legend-item green">
            <span class="dot"></span> Zone Certifiée
          </div>
        </div>
        <div class="map-visual">
          <img src="https://i.ibb.co/3S89Y8v/satellite-placeholder.png" alt="Vue Satellite Tactique" class="map-img" />
          <div class="coords">LAT : 36.1834 / LON : 5.2341</div>
        </div>
      </div>

      <div class="stats-col">
        <div class="card stat-card sub-fraud-card">
          <div class="stat-header">
            <h3>Fraude aux Subventions</h3>
            <i class="fas fa-ellipsis-v"></i>
          </div>
          <div class="stat-info-row">
            <span>Nombre Déclaré</span>
            <strong>1,240</strong>
          </div>
          <div class="stat-info-row">
            <span>Nombre Réel Scanné</span>
            <strong class="red-text">892</strong>
          </div>
          <div class="progress-container">
            <div class="progress-bar red">
              <div class="fill" :style="{ width: '71%' }"></div>
            </div>
          </div>
          <div class="alert-box-warning">
            <i class="fas fa-exclamation-triangle"></i>
            <div>
              <strong>Écart de 28% détecté sur l'exploitation #FR-402.</strong>
              Potential détournement de 45,000€.
            </div>
          </div>
        </div>

        <div class="card stat-card suspects-card">
          <div class="stat-header">
            <h3>Animaux Fictifs</h3>
            <span class="tag-suspects">12 SUSPECTS</span>
          </div>
          <div class="suspect-item">
            <i class="fas fa-shield-alt icon-suspect green-trace"></i>
            <div>
              <strong>Bovin ID #992-K</strong><br>
              Zéro historique de scan (24 mois)
            </div>
          </div>
          <div class="suspect-item">
            <i class="fas fa-clock icon-suspect green-trace"></i>
            <div>
              <strong>Ovin ID #221-M</strong><br>
              Déclaré sans balise active
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="grid-bottom">
      <div class="card table-card doubles-card">
        <div class="table-card-header">
          <h3>Animaux en Doublon (Conflit RFID)</h3>
          <a href="#" class="view-all green-trace">Voir tous les doublons <i class="fas fa-arrow-right"></i></a>
        </div>
        <table class="doubles-table">
          <thead>
            <tr>
              <th>IDENTIFIANT RFID</th>
              <th>LOCALISATION A</th>
              <th>LOCALISATION B</th>
              <th>SCORE RISQUE</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="dup in duplicates" :key="dup.rfid">
              <td class="rfid-tag">{{ dup.rfid }}</td>
              <td class="farm-name">{{ dup.locA }}</td>
              <td class="farm-name">{{ dup.locB }}</td>
              <td><span class="tag-score" :class="dup.scoreClass">{{ dup.score }}</span></td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="incoherent-card-section">
        <div class="card incoherent-card">
          <div class="incoherent-header">
            <h3>Déclarations Incohérentes</h3>
            <i class="fas fa-question-circle green-trace"></i>
          </div>

          <div class="incoherent-item alert-red">
            <div class="icon-side">
              <i class="fas fa-times-circle"></i>
            </div>
            <div class="incoherent-info">
              <strong>Mort mais Actif</strong>
              <p>Animal déclaré mort en abattoir le 12/01, mais listé comme actif sur l'exploitation FR-22.</p>
              <div class="meta">URGENT Réf : AB-9912-22</div>
            </div>
          </div>

          <div class="incoherent-item alert-green">
            <div class="icon-side">
              <i class="fas fa-random"></i>
            </div>
            <div class="incoherent-info">
              <strong>Vendu mais Présent</strong>
              <p>Transaction validée vers l'Espagne, mais la balise continue d'émettre en zone Oran-Nord.</p>
              <div class="meta">INVESTIGATION Réf : TX-441-22</div>
            </div>
          </div>

          <div class="incoherent-item alert-light-green">
            <div class="icon-side">
              <i class="fas fa-paw"></i>
            </div>
            <div class="incoherent-info">
              <strong>Naissance Orpheline</strong>
              <p>Veau enregistré sans mère correspondante ou avec mère stérile déclarée.</p>
              <div class="meta">ANOMALIE BDD Réf : BR-003-10K</div>
            </div>
          </div>
        </div>

        <div class="help-float green-trace-bg">
          <i class="fas fa-bell"></i>
        </div>
      </div>
    </div>

    <div class="fraud-action-footer">
      <div class="agent-info">
        <i class="fas fa-id-card agent-icon green-trace"></i>
        <div>
          <strong>Agent de Fraude : J. Dupont</strong><br>
          Session active · Fin de tour dans 2h 15m
        </div>
      </div>
      <div class="action-buttons">
        <button class="btn-secondary">Ignorer les Alertes Mineures</button>
        <button class="btn-primary green-trace-bg">Lancer l'Intervention sur Site <i class="fas fa-arrow-right"></i></button>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref } from 'vue'

const duplicates = ref([
  { rfid: 'DZ-7762-990', locA: 'Tizi Ouzou (Ferme Amirouche)', locB: 'Sétif (Coopérative El Fath)', score: 'CRITIQUE', scoreClass: 'critique' },
  { rfid: 'DZ-1120-884', locA: 'Bouira (Plaine Hamza)', locB: 'Blida (Atlas Fruits)', score: 'MODÉRÉ', scoreClass: 'modere' },
  { rfid: 'DZ-5431-002', locA: 'Constantine (Mila Elevage)', locB: 'Constantine (Interne)', score: 'INTERNE', scoreClass: 'interne' }
])
</script>

<style scoped>
/* STRUCTURE ET TYPOGRAPHIE TRACEDZ */
.page-container {
  background-color: #f8fafb;
  min-height: 100vh;
  padding: 30px;
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  color: #1a202c;
}

/* HEADER GLOBAL DE PAGE */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.title-group h1 { font-size: 26px; font-weight: 800; color: #1a202c; letter-spacing: -0.02em; margin: 0; }
.subtitle { color: #718096; font-size: 14px; margin-top: 5px; }

.header-ctrl { display: flex; gap: 12px; }
.region-select { background: white; padding: 10px 18px; border-radius: 12px; border: 1px solid #edf2f7; font-weight: 600; font-size: 13px; color: #4a5568; }
.filter-btn { background: white; color: #4a5568; border: 1px solid #edf2f7; padding: 10px 20px; border-radius: 12px; font-weight: 600; font-size: 13px; cursor: pointer; }

/* CARTES ET GRILLES COMMUNES */
.card { background: white; border-radius: 16px; border: 1px solid rgba(226, 232, 240, 0.8); padding: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); margin-bottom: 25px; }

h3 { font-size: 16px; font-weight: 800; color: #1a202c; margin: 0; }

/* COULEURS ET ACCENTS (VERT TRACEDZ CORRIGÉ) */
.green-trace { color: #11D432 !important; }
.green-trace-bg { background-color: #11D432 !important; color: white !important; }

/* GRILLE SUPÉRIEURE (Carte + Stats) */
.grid-top { display: grid; grid-template-columns: 1fr 1fr; gap: 25px; align-items: flex-start; }

/* 1. CARTE TACTIQUE SATELLITE */
.map-card { padding: 0; overflow: hidden; position: relative; }

.map-legend {
  position: absolute;
  top: 20px;
  left: 20px;
  background: rgba(255,255,255,0.9);
  padding: 15px;
  border-radius: 12px;
  border: 1px solid rgba(226, 232, 240, 0.8);
  z-index: 5;
  box-shadow: 0 4px 6px rgba(0,0,0,0.02);
}

.map-legend h4 { font-size: 11px; font-weight: 800; color: #a0aec0; text-transform: uppercase; letter-spacing: 0.1em; margin: 0 0 10px 0; }
.legend-item { display: flex; align-items: center; gap: 10px; font-size: 12px; font-weight: 700; color: #2d3748; margin-bottom: 8px; }
.legend-item.red { color: #e53e3e; }
.legend-item.green { color: #11D432; }

.dot { width: 8px; height: 8px; border-radius: 50%; background: currentColor; }

.map-visual { position: relative; }
.map-img { width: 100%; height: auto; display: block; filter: contrast(1.1) brightness(1.05); }

.coords {
  position: absolute;
  bottom: 20px;
  right: 20px;
  background: rgba(26, 32, 44, 0.85);
  color: #a0aec0;
  font-family: 'JetBrains Mono', monospace;
  font-size: 11px;
  padding: 6px 10px;
  border-radius: 8px;
}

/* 2. STATS RAPIDES COLONNE */
.stats-col { display: grid; grid-template-columns: 1fr; gap: 25px; }
.stat-card { display: flex; flex-direction: column; }
.stat-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }

/* a. Fraude Subventions */
.stat-info-row { display: flex; justify-content: space-between; font-size: 13px; color: #718096; margin-bottom: 8px; }
.stat-info-row strong { font-size: 18px; color: #1a202c; font-weight: 900; }
.red-text { color: #e53e3e !important; }

.progress-container { margin-bottom: 20px; }
.progress-bar { height: 10px; background: #f1f5f9; border-radius: 10px; overflow: hidden; box-shadow: inset 0 2px 4px rgba(0,0,0,0.05); }
.progress-bar .fill { height: 100%; border-radius: 10px; transition: width 0.3s; }
.progress-bar.red .fill { background-color: #e53e3e; }
.progress-bar.green .fill { background-color: #11D432; }

.alert-box-warning { display: flex; gap: 15px; padding: 15px; border-radius: 12px; background-color: #fffaf0; border: 1px solid #fee2b3; color: #c05621; font-size: 12px; align-items: flex-start; }
.alert-box-warning i { font-size: 16px; margin-top: 2px; }

/* b. Animaux Fictifs */
.tag-suspects { font-size: 11px; font-weight: 800; color: #718096; background: #f7fafc; padding: 4px 10px; border-radius: 8px; }

.suspect-item { display: flex; gap: 15px; align-items: center; padding: 15px 0; border-bottom: 1px solid #f8fafb; }
.suspect-item:last-child { border-bottom: none; }
.icon-suspect { font-size: 18px; color: #edf2f7; }

.suspect-item strong { font-weight: 800; color: #1a202c; font-size: 14px; }
.suspect-item div { font-size: 13px; color: #718096; }

/* GRILLE INFÉRIEURE (Doublons + Incohérences) */
.grid-bottom { display: grid; grid-template-columns: 1fr 1fr; gap: 25px; align-items: flex-start; }

/* 3. ANIMAUX EN DOUBLON (Tableau) */
.table-card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
.view-all { font-size: 13px; font-weight: 600; text-decoration: none; display: flex; align-items: center; gap: 8px; }

.doubles-table { width: 100%; border-collapse: separate; border-spacing: 0 5px; margin-top: -5px; }
.doubles-table th { padding: 12px 15px; color: #a0aec0; font-size: 11px; font-weight: 800; text-transform: uppercase; text-align: left; }
.doubles-table td { padding: 15px; background: #ffffff; border-bottom: 1px solid #f8fafb; font-size: 13px; color: #2d3748; }

.rfid-tag { color: #1a202c !important; font-weight: 900 !important; }
.farm-name { font-weight: 600; color: #1a202c; }

.tag-score { font-size: 10px; font-weight: 900; padding: 5px 10px; border-radius: 8px; letter-spacing: 0.05em; }
.tag-score.critique { background: #fff5f5; color: #e53e3e; border: 1px solid #fed7d7; }
.tag-score.modere { background: #fffaf0; color: #dd6b20; border: 1px solid #fee2e2; }
.tag-score.interne { background: #f7fafc; color: #718096; border: 1px solid #e2e8f0; }

/* 4. DÉCLARATIONS INCOHÉRENTES */
.incoherent-card-section { position: relative; }
.incoherent-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
.incoherent-header i { font-size: 16px; }

.incoherent-item { display: flex; gap: 20px; border-radius: 12px; margin-bottom: 15px; padding: 20px; align-items: flex-start; }

.alert-red { background: #fff5f5; border: 1px solid #fed7d7; color: #e53e3e; }
.alert-red .icon-side { color: #e53e3e; }

.alert-green { background: #f0fff4; border: 1px solid rgba(17, 212, 50, 0.2); color: #11D432; }
.alert-green .icon-side { color: #11D432; }

.alert-light-green { background: #f0fff4; border: 1px solid rgba(17, 212, 50, 0.2); color: #11D432; opacity: 0.8; }
.alert-light-green .icon-side { color: #11D432; opacity: 0.8; }

.icon-side { font-size: 24px; margin-top: 5px; }
.incoherent-info strong { display: block; font-size: 15px; font-weight: 800; color: inherit; margin-bottom: 5px; }
.incoherent-info p { margin: 0; font-size: 13px; color: #4a5568; }
.incoherent-info .meta { margin-top: 10px; font-size: 10px; font-weight: 800; color: #718096; }

.help-float { position: absolute; bottom: 15px; right: -30px; width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; box-shadow: 0 4px 10px rgba(17, 212, 50, 0.3); z-index: 10; font-size: 18px; }

/* FOOTER D'ACTION (Actionneur de Fraude) */
.fraud-action-footer { display: flex; justify-content: space-between; align-items: center; background: white; border-radius: 16px; border: 1px solid rgba(226, 232, 240, 0.8); padding: 25px 30px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); margin-top: 10px; }

.agent-info { display: flex; align-items: center; gap: 15px; font-size: 13px; color: #718096; }
.agent-icon { font-size: 24px; color: #cbd5e0; }
.agent-info strong { font-size: 14px; font-weight: 800; color: #1a202c; }

.action-buttons { display: flex; gap: 12px; }
.btn-secondary { background: white; color: #4a5568; border: 1px solid #edf2f7; padding: 12px 24px; border-radius: 12px; font-weight: 600; font-size: 13px; cursor: pointer; }
.btn-secondary:hover { background: #f8fafc; border-color: #cbd5e0; }

.btn-primary { border: none; padding: 12px 24px; border-radius: 12px; font-weight: 600; font-size: 13px; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: all 0.3s; }
.btn-primary:hover { filter: brightness(1.1); }
</style>