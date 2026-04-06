<template>

    <div class="page-header">
      <div>
        <h1>Gestion des Fermes</h1>
        <p class="subtitle">Gérez et surveillez l'ensemble de vos exploitations agricoles en temps réel.</p>
      </div>
      <button class="add-farm-btn">
        <i class="fas fa-plus-circle"></i> Ajouter une Ferme
      </button>
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
                <th>ACTIONS</th>
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
                <td>
                  <button class="edit-icon-btn"><i class="far fa-edit"></i></button>
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
.farm-page {
  background-color: #f8fafb;
  min-height: 100vh;
  padding: 20px;
  font-family: 'Inter', sans-serif;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}
.page-header h1 {
 font-weight: 800;}
.add-farm-btn {
  background: #11D432;
  color: white;
  border: none;
  padding: 12px 25px;
  border-radius: 10px;
  font-weight: bold;
  cursor: pointer;
  display: flex;
  gap: 10px;
  align-items: center;
}

.farm-content-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 220px;
  gap: 25px;
  align-items: start;
  width: 100%;
  box-sizing: border-box;
}

/* RECHERCHE ET TABLEAU */
.search-bar {
  background: white;
  padding: 18px 25px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 25px;
  margin-top: 0;
  box-shadow: 0 2px 12px rgba(0,0,0,0.03);
  border: 1px solid #edf2f7;
}

.search-bar input {
  border: none;
  width: 100%;
  outline: none;
  font-size: 15px;
  color: #4a5568;
}
.search-card i {
 color: #a0aec0;
}

.table-container-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.04);
  overflow: hidden;
}

.farm-table {
  width: 100%;
  border-collapse: collapse;
  }

.farm-table th {
  background: #fcfcfd;
  padding: 20px 15px;
  text-align: left;
  color: #718096;
  font-size: 11px;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid #edf2f7;
}

.farm-table td { padding: 22px 15px; border-bottom: 1px solid #f7fafc; }

.id-cell {
  color: #a0aec0;
  font-weight: 600;
}

.owner-cell {
  display: flex;
  align-items: center;
  gap: 10px;
}
.mini-avatar {
  width: 28px;
  height: 28px;
  background: #edf2f7;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  font-weight: bold;
  color: #718096;
}

.capacity-badge {
  background: #f0fff4;
  color: #38a169;
  padding: 4px 12px;
  border-radius: 20px;
  font-weight: bold;
  font-size: 12px;
  border: 1px solid #c6f6d5;
}

/*PAGINATION*/
.pagination-footer {
  padding: 20px 25px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fff;
}

.pagination-controls {
  display: flex;
  gap: 8px;
  }

.btn-nav, .page-num {
  padding: 8px 16px;
  border: 1px solid #edf2f7;
  border-radius: 8px;
  background: white;
  color: #718096;
  font-weight: 600;
  cursor: pointer;
  transition: 0.2s;
}

.page-num.active {
  background: #11D432;
  color: white;
  border-color: #2ecc71;
}

/* SIDEBAR STATS */
.stats-sidebar {
  display: flex;
  flex-direction: column;
  gap: 0; /* On gère les espaces via margin-top du GPS */
}

.stats-card {
  background: white;
  padding: 24px;
  border-radius: 16px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.02);
  border: 1px solid #f1f5f9;
  margin-top: 0;
}

.stats-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.stats-header h3 {
  font-size: 18px;
  font-weight: 800;
  color: #2d3748;
}

.stats-header i {
  color: #2ecc71;
  background: #f0fff4;
  padding: 8px;
  border-radius: 8px;
  font-size: 14px;
}

.stat-box {
  background: #f8fafb;
  padding: 16px 20px;
  border-radius: 12px;
  margin-bottom: 15px;
  position: relative; /* Pour positionner la barre personnalisée */
  display: flex;
  flex-direction: column;
  justify-content: center;
  border-left: none; /* On enlève la bordure standard */
}

/* Barre verte arrondie personnalisée */
.stat-box::before {
  content: "";
  position: absolute;
  left: 0;
  top: 15%; /* Elle ne fait pas toute la hauteur */
  height: 70%;
  width: 5px;
  background-color: #2ecc71;
  border-radius: 0 10px 10px 0; /* Arrondi du côté droit */
}

.stat-box .label {
  font-size: 11px;
  letter-spacing: 0.05em;
  color: #a0aec0;
  margin-bottom: 4px;
}

.stat-box .number {
  font-size: 28px; /* Un peu plus grand pour l'impact */
  font-weight: 900;
  color: #1a202c;
}

.cap-badge {
  background: #f0fff4;
  color: #2ecc71;
  padding: 5px 15px;
  border-radius: 20px;
  font-weight: 800;
  font-size: 12px;
  border: 1px solid #c6f6d5;
  white-space: nowrap;
  display: inline-block;
  min-width: max-content;
}

.dist-section h4 {
  font-size: 14px;
  color: #2d3748;
  margin: 25px 0 15px 0;
}

.progress-track {
  height: 8px;
  background: #edf2f7;
  border-radius: 10px;
  overflow: hidden;
  margin-top: 8px;
}

/* Dégradé sur la barre pour correspondre à l'image */
.progress-item:nth-child(2) .fill {
  background: #2ecc71;
  }
.progress-item:nth-child(3) .fill {
  background: #58d68d;
  }

.map-card-preview {
  margin-top: 20px;
  border-radius: 16px;
  height: 180px;
  background: linear-gradient(rgba(0,0,0,0.2), rgba(0,0,0,0.8)),
              url('https://img.freepik.com/vecteurs-libre/carte-algerie-gris_1257-251.jpg');
  background-size: cover;
  background-position: center;
  display: flex;
  align-items: flex-end;
  padding: 20px;
  color: white;
  overflow: hidden;
  border: 1px solid #edf2f7;
}

.map-overlay h4 {
  font-weight: 700;
  margin-bottom: 4px;
  }
.map-overlay p {
  font-size: 12px;
  opacity: 0.8;
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