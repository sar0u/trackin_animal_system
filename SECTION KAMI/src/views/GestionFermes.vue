<template>

    <div class="page-header">
      <div>
        <h1>Gestion des Fermes</h1>
        <p class="subtitle">Gérez et surveillez l'ensemble de vos exploitations agricoles en temps réel.</p>
      </div>

    </div>

    <div class="farm-content-grid">
      <div class="main-list-section">
        <div class="search-bar">
          <i class="fas fa-search"></i>
          <input type="text" placeholder="Rechercher par ID, nom de ferme, propriétaire ou localisation...">
        </div>

        <div class="table-container-card">
          <table class="farm-table">
            <thead>
              <tr>
                <th>ID FERME</th>
                <th>NOM</th>
                <th>PROPRIÉTAIRE</th>
                <th>LOCALISATION</th>
                <th>CAPACITÉ</th>

              </tr>
            </thead>
            <tbody>
              <tr v-for="farm in farms" :key="farm.id">
                <td class="id-text">#{{ farm.id }}</td>
                <td><span class="farm-name">{{ farm.name }}</span></td>
                <td>
                  <div class="owner-info">
                    <div class="owner-avatar">{{ farm.initials }}</div>
                    <span>{{ farm.owner }}</span>
                  </div>
                </td>
                <td class="location-text">{{ farm.location }}</td>
                <td>
                  <span class="cap-badge">{{ farm.capacity }} Ha</span>
                </td>

              </tr>
            </tbody>
          </table>

          <div class="pagination-footer">
            <span class="pagination-info">Affichage de 1 à 4 sur 24 fermes</span>
            <div class="pagination-controls">
              <button class="btn-nav">Précédent</button>
              <button class="page-num active">1</button>
              <button class="page-num">2</button>
              <button class="btn-nav">Suivant</button>
            </div>
          </div>
        </div>
      </div>

      <aside class="stats-sidebar">
        <div class="stats-card">
          <div class="stats-header">
            <h3>Statistiques Globales</h3>
            <i class="fas fa-chart-line"></i>
          </div>

          <div class="stat-box green-border">
            <span class="label">TOTAL FERMES</span>
            <span class="number">24</span>
          </div>

          <div class="stat-box green-border">
            <span class="label">CAPACITÉ TOTALE</span>
            <span class="number">16,700 <small>Ha</small></span>
          </div>

          <div class="dist-section">
            <h4>Distribution par Capacité</h4>
            <div class="progress-item">
              <div class="progress-labels"><span>> 5000 Ha</span> <span>38%</span></div>
              <div class="progress-track"><div class="fill" style="width: 38%"></div></div>
            </div>
            <div class="progress-item">
              <div class="progress-labels"><span>2000 - 5000 Ha</span> <span>45%</span></div>
              <div class="progress-track"><div class="fill" style="width: 45%"></div></div>
            </div>
          </div>
        </div>

        <div class="map-card-preview">
          <div class="map-overlay">
            <h4>Localisation des Fermes</h4>
            <p>Vue d'ensemble nationale</p>
          </div>
        </div>
      </aside>
    </div>

</template>

<style scoped>
/* BASE ET TYPOGRAPHIE */
.main-content {
  font-family: 'Inter', sans-serif;
  color: #2d3748;
  background-color: #f8fafb;
  min-height: 100vh;
  padding: 30px;
}

/* HEADER */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.page-header h1 {
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

/* GRILLE PRINCIPALE */
.farm-content-grid {
  display: grid;
  grid-template-columns: 1fr 300px; /* Sidebar légèrement plus large */
  gap: 30px;
  align-items: start;
}

/* BARRE DE RECHERCHE */
.search-bar {
  background: white;
  padding: 15px 25px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 25px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.03);
  border: 1px solid #edf2f7;
  transition: all 0.3s ease;
}

.search-bar:focus-within {
  border-color: #11D432;
  box-shadow: 0 4px 15px rgba(17, 212, 50, 0.1);
}

.search-bar i {
  color: #a0aec0;
}

.search-bar input {
  border: none;
  width: 100%;
  outline: none;
  font-size: 15px;
  font-weight: 500;
  color: #4a5568;
}

/* TABLEAU DES FERMES */
.table-container-card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.04);
  border: 1px solid #edf2f7;
  overflow: hidden;
}

.farm-table {
  width: 100%;
  border-collapse: collapse;
}

.farm-table th {
  background: #f8fafc;
  padding: 18px 20px;
  text-align: left;
  color: #718096;
  font-size: 11px;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  border-bottom: 1px solid #edf2f7;
}

.farm-table td {
  padding: 20px;
  border-bottom: 1px solid #f1f5f9;
  font-size: 14px;
  vertical-align: middle;
}

.farm-table tr {
  transition: background 0.2s;
}

.farm-table tr:hover {
  background-color: #f0fdf4; /* Effet hover léger vert */
}

.id-text {
  font-family: 'JetBrains Mono', monospace;
  color: #a0aec0;
  font-weight: 600;
}

.farm-name {
  font-weight: 700;
  color: #1a202c;
}

/* PROPRIÉTAIRE AVEC AVATAR */
.owner-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.owner-avatar {
  width: 32px;
  height: 32px;
  background: #11D432;
  color: white;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 800;
  box-shadow: 0 2px 6px rgba(17, 212, 50, 0.2);
}

.location-text {
  color: #718096;
  font-weight: 500;
}

/* BADGE CAPACITÉ */
.cap-badge {
  background: #f0fff4;
  color: #38a169;
  padding: 6px 14px;
  border-radius: 10px;
  font-weight: 800;
  font-size: 12px;
  border: 1px solid #c6f6d5;
  display: inline-block;
}

/* SIDEBAR ET STATS */
.stats-card {
  background: white;
  padding: 25px;
  border-radius: 20px;
  border: 1px solid #edf2f7;
  box-shadow: 0 4px 15px rgba(0,0,0,0.02);
}

.stats-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.stats-header h3 {
  font-size: 16px;
  font-weight: 800;
}

.stats-header i {
  color: #11D432;
  font-size: 18px;
}

.stat-box {
  background: #f8fafc;
  padding: 18px;
  border-radius: 16px;
  margin-bottom: 15px;
  position: relative;
  overflow: hidden;
  border: 1px solid #f1f5f9;
}

.stat-box::before {
  content: "";
  position: absolute;
  left: 0;
  top: 15%;
  height: 70%;
  width: 4px;
  background: #11D432;
  border-radius: 0 4px 4px 0;
}

.stat-box .label {
  display: block;
  font-size: 10px;
  font-weight: 800;
  color: #a0aec0;
  text-transform: uppercase;
  margin-bottom: 6px;
}

.stat-box .number {
  font-size: 26px;
  font-weight: 900;
  color: #1a202c;
}

.stat-box .number small {
  font-size: 14px;
  color: #718096;
  font-weight: 600;
}

/* PROGRESS BARS */
.dist-section h4 {
  font-size: 13px;
  font-weight: 800;
  margin: 25px 0 15px;
  color: #4a5568;
}

.progress-item {
  margin-bottom: 15px;
}

.progress-labels {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  font-weight: 700;
  margin-bottom: 6px;
}

.progress-track {
  height: 8px;
  background: #edf2f7;
  border-radius: 10px;
  overflow: hidden;
}

.progress-track .fill {
  height: 100%;
  background: linear-gradient(90deg, #11D432, #58d68d);
  border-radius: 10px;
}

/* CARTE PREVIEW */
.map-card-preview {
  margin-top: 25px;
  border-radius: 20px;
  height: 200px;
  background: linear-gradient(rgba(0,0,0,0.2), rgba(0,0,0,0.7)),
              url('https://api.placeholder.com/400/300?text=Carte+Algérie'); /* Utilise un vrai lien d'image ici */
  background-size: cover;
  background-position: center;
  display: flex;
  align-items: flex-end;
  padding: 20px;
  border: 4px solid white;
  box-shadow: 0 10px 20px rgba(0,0,0,0.1);
}

.map-overlay h4 {
  color: white;
  font-weight: 800;
  margin: 0;
}

.map-overlay p {
  color: rgba(255,255,255,0.8);
  font-size: 12px;
  margin: 4px 0 0;
}

/* PAGINATION */
.pagination-footer {
  padding: 20px 25px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fcfcfd;
}

.pagination-info {
  font-size: 13px;
  color: #718096;
  font-weight: 600;
}

.pagination-controls {
  display: flex;
  gap: 8px;
}

.btn-nav, .page-num {
  padding: 8px 14px;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  background: white;
  color: #4a5568;
  font-weight: 700;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s;
}

.page-num.active {
  background: #11D432;
  color: white;
  border-color: #11D432;
}

.btn-nav:hover:not(:disabled), .page-num:hover:not(.active) {
  background: #f8fafc;
  border-color: #cbd5e0;
}
</style>

<script setup>
import { ref } from 'vue'

const farms = ref([
  { id: 'FRM-001', name: 'Ferme des Plaines', owner: 'Cherfi Anes', initials: 'CA', location: 'Bejaïa , DZ', capacity: 5000 },
  { id: 'FRM-002', name: 'L\'Oasis Verte', owner: 'Ouarab Rayan', initials: 'OR', location: 'Djelfa, DZ', capacity: 2500 },
  { id: 'FRM-003', name: 'Le Vallon Fleuri', owner: 'Ziri Samy', initials: 'ZS', location: 'Médéa, DZ', capacity: 3200 }
])
</script>