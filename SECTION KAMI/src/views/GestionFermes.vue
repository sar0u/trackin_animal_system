<template>
  <div class="main-content">

    <div class="page-header">
      <div>
        <h1>Gestion des Fermes</h1>
        <p class="subtitle">Surveillez l'ensemble de vos exploitations agricoles en temps réel.</p>
      </div>
    </div>

    <div class="farm-content-stacked">

      <div class="main-list-section">

        <div class="filters-bar">
          <div class="search-box">
            <i class="fas fa-search"></i>
            <input type="text" v-model="searchQuery" placeholder="Rechercher (ID, nom, lieu, propriétaire)...">
          </div>

          <div class="right-filters">
            <div class="number-filters">
              <div class="number-input-group">
                <label>Capacité Min :</label>
                <input type="number" v-model="capacityMin" min="0" placeholder="0">
                <span>Ha</span>
              </div>
              <div class="number-input-group">
                <label>Max :</label>
                <input type="number" v-model="capacityMax" min="0" placeholder="∞">
                <span>Ha</span>
              </div>
            </div>
          </div>
        </div>

        <div class="table-container-card">
          <div v-if="isLoading" style="padding: 40px; text-align: center; color: #718096;">
            <i class="fas fa-circle-notch fa-spin"></i> Chargement des données...
          </div>

          <table class="farm-table" v-else>
            <thead>
            <tr>
              <th>ID FERME</th>
              <th>PROPRIÉTAIRE</th>
              <th>NOM DE LA FERME</th>
              <th>ADRESSE</th>
              <th>LATITUDE</th>
              <th>LONGITUDE</th>
              <th>CAPACITÉ</th>
              <th>STATUT</th> </tr>
            </thead>
            <tbody>
            <tr v-if="filteredFarms.length === 0">
              <td colspan="7" class="empty-msg">Aucune ferme ne correspond à vos critères.</td>
            </tr>

            <tr v-for="farm in paginatedFarms" :key="farm.id">
              <td class="id-text">#{{ farm.id }}</td>

              <td class="id-text" style="color: #3b82f6;">
                #USR-{{ farm.owner && farm.owner.user ? farm.owner.user.id : '--' }}
              </td>

              <td><span class="farm-name">{{ farm.farmName }}</span></td>

              <td class="location-text">
                <i class="fas fa-map-marker-alt" style="color: #e53e3e; margin-right: 5px;"></i>
                {{ farm.geographicAddress || 'Non définie' }}
              </td>

              <td class="mono-text">{{ farm.latitudeCoordinate || '--' }}</td>
              <td class="mono-text">{{ farm.longitudeCoordinate || '--' }}</td>

              <td>
                <span class="cap-badge">{{ farm.capacity || 0 }} Ha</span>
              </td>

              <td>
                  <span :class="['status-badge', farm.status.toLowerCase()]">
                    {{ farm.status }}
                  </span>
              </td>
            </tr>
            </tbody>
          </table>

          <div class="pagination-footer">
            <span class="pagination-info">
              Affichage de {{ paginationStart }} à {{ paginationEnd }} sur {{ filteredFarms.length }} fermes
            </span>
            <div class="pagination-controls" v-if="totalPages > 1">
              <button class="btn-nav" :disabled="currentPage === 1" @click="prevPage">Précédent</button>
              <button
                  class="page-num"
                  v-for="page in totalPages" :key="page"
                  :class="{ active: currentPage === page }"
                  @click="setPage(page)"
              >
                {{ page }}
              </button>
              <button class="btn-nav" :disabled="currentPage === totalPages" @click="nextPage">Suivant</button>
            </div>
          </div>
        </div>
      </div>

      <div class="bottom-dashboard">

        <div class="stat-box">
          <span class="label">TOTAL FERMES</span>
          <span class="number">{{ totalFarms }}</span>
        </div>

        <div class="stat-box">
          <span class="label">CAPACITÉ TOTALE</span>
          <span class="number">{{ totalCapacity.toLocaleString() }} <small>Ha</small></span>
        </div>

        <div class="stats-card">
          <div class="stats-header-mini">
            <h4>Distribution par Capacité</h4>
            <i class="fas fa-chart-pie"></i>
          </div>
          <div class="dist-section">
            <div class="progress-item">
              <div class="progress-labels"><span>> 5000 Ha</span> <span>{{ distOver5000 }}%</span></div>
              <div class="progress-track"><div class="fill" :style="{ width: distOver5000 + '%' }"></div></div>
            </div>
            <div class="progress-item">
              <div class="progress-labels"><span>2000 - 5000 Ha</span> <span>{{ distUnder5000 }}%</span></div>
              <div class="progress-track"><div class="fill" :style="{ width: distUnder5000 + '%' }"></div></div>
            </div>
          </div>
        </div>

        <div class="map-card-preview" @click="openMapModal">
          <div class="map-overlay">
            <h4>Localisation des Fermes</h4>
            <p>Cliquez pour ouvrir la carte <i class="fas fa-external-link-alt"></i></p>
          </div>
        </div>

      </div>

    </div>

    <div v-if="showMapModal" class="modal-overlay" @click.self="closeMapModal">
      <div class="modal-content map-modal">
        <div class="modal-header">
          <h2>Carte des Exploitations</h2>
          <button class="btn-close" @click="closeMapModal"><i class="fas fa-times"></i></button>
        </div>
        <div id="farm-map" class="map-container"></div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch, nextTick } from 'vue';
import api from '../services/api';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

// --- CONFIGURATION LEAFLET (ICÔNES) ---
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

// --- ÉTATS ---
const farms = ref([]);
const isLoading = ref(true);
const searchQuery = ref('');
const capacityMin = ref('');
const capacityMax = ref('');

const currentPage = ref(1);
const itemsPerPage = 7;

const showMapModal = ref(false);
let mapInstance = null;

// --- RÉCUPÉRATION DES DONNÉES ---
const fetchFarms = async () => {
  try {
    const response = await api.get('/farms');
    farms.value = response.data;
  } catch (error) {
    console.error("Erreur API:", error);
  } finally {
    isLoading.value = false;
  }
};

onMounted(fetchFarms);

// --- LOGIQUE DE FILTRAGE ---
const filteredFarms = computed(() => {
  const search = searchQuery.value.toLowerCase();
  const min = capacityMin.value !== '' ? Number(capacityMin.value) : null;
  const max = capacityMax.value !== '' ? Number(capacityMax.value) : null;

  return farms.value.filter(f => {

    const matchesSearch =
        String(f.id).includes(search) ||
        (f.owner && String(f.owner.id).includes(search)) ||
        (f.farmName || '').toLowerCase().includes(search) ||
        (f.geographicAddress || '').toLowerCase().includes(search) ||
        ownerName.includes(search);

    let matchesCapacity = true;
    const cap = f.capacity || 0;
    if (min !== null && cap < min) matchesCapacity = false;
    if (max !== null && cap > max) matchesCapacity = false;

    return matchesSearch && matchesCapacity;
  });
});

// --- PAGINATION ---
watch([searchQuery, capacityMin, capacityMax], () => currentPage.value = 1);

const paginatedFarms = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredFarms.value.slice(start, start + itemsPerPage);
});

const totalPages = computed(() => Math.ceil(filteredFarms.value.length / itemsPerPage));
const paginationStart = computed(() => filteredFarms.value.length === 0 ? 0 : (currentPage.value - 1) * itemsPerPage + 1);
const paginationEnd = computed(() => Math.min(currentPage.value * itemsPerPage, filteredFarms.value.length));

const prevPage = () => { if (currentPage.value > 1) currentPage.value--; };
const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++; };
const setPage = (page) => { currentPage.value = page; };

// --- STATISTIQUES ---
const totalFarms = computed(() => farms.value.length);
const totalCapacity = computed(() => farms.value.reduce((acc, f) => acc + (f.capacity || 0), 0));

const distOver5000 = computed(() => {
  if (!totalFarms.value) return 0;
  return Math.round((farms.value.filter(f => f.capacity > 5000).length / totalFarms.value) * 100);
});

const distUnder5000 = computed(() => {
  if (!totalFarms.value) return 0;
  return Math.round((farms.value.filter(f => f.capacity >= 2000 && f.capacity <= 5000).length / totalFarms.value) * 100);
});

// --- CARTE ---
const openMapModal = async () => {
  showMapModal.value = true;
  await nextTick();
  mapInstance = L.map('farm-map').setView([28.0339, 1.6596], 5);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: '© OpenStreetMap' }).addTo(mapInstance);

  farms.value.forEach(f => {
    if (f.latitudeCoordinate && f.longitudeCoordinate) {
      L.marker([f.latitudeCoordinate, f.longitudeCoordinate])
          .addTo(mapInstance)
          .bindPopup(`<b>${f.farmName}</b><br>Capacité: ${f.capacity || 0} Ha`);
    }
  });
};

const closeMapModal = () => {
  showMapModal.value = false;
  if (mapInstance) { mapInstance.remove(); mapInstance = null; }
};
</script>

<style scoped>
/* ==========================================================================
   1. STRUCTURE & HEADER
   ========================================================================== */
.main-content {
  font-family: 'Inter', sans-serif;
  background-color: #f4f7f6;
  min-height: 100vh;
  padding: 30px;
  color: #1e293b;
}

.page-header {
  margin-bottom: 25px;
}

.page-header h1 {
  font-size: 26px;
  font-weight: 900;
  color: #0f172a;
  margin: 0;
  letter-spacing: -0.5px;
}

.subtitle {
  color: #64748b;
  font-size: 14px;
  margin-top: 5px;
}

.farm-content-stacked {
  display: flex;
  flex-direction: column;
  gap: 25px;
}

/* ==========================================================================
   2. FILTRES
   ========================================================================== */
.filters-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  padding: 16px 25px;
  border-radius: 12px 12px 0 0;
  border: 1px solid rgba(11, 93, 30, 0.08);
  gap: 20px;
  flex-wrap: wrap;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
}

.search-box {
  display: flex;
  align-items: center;
  background: rgba(11, 93, 30, 0.05);
  padding: 8px 16px;
  border-radius: 8px;
  flex: 1;
  max-width: 400px;
}

.search-box input {
  border: none;
  background: transparent;
  width: 100%;
  outline: none;
  margin-left: 10px;
  font-size: 14px;
  color: #063B16;
}

.search-box input::placeholder {
  color: #0B5D1E;
  opacity: 0.5;
}

.search-box i {
  color: #0B5D1E;
  opacity: 0.6;
}

.right-filters {
  display: flex;
  align-items: center;
}

.number-filters {
  display: flex;
  gap: 20px;
}

.number-input-group {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  font-weight: 600;
  color: #063B16;
}

.number-input-group label {
  color: #0B5D1E;
  font-weight: 700;
}

.number-input-group input {
  width: 80px;
  padding: 8px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 6px;
  color: #063B16;
  background: white;
}

.number-input-group span {
  color: #0B5D1E;
  opacity: 0.7;
}

/* ==========================================================================
   3. TABLEAU
   ========================================================================== */
.table-container-card {
  background: white;
  border-radius: 0 0 12px 12px;
  border: 1px solid rgba(11, 93, 30, 0.08);
  box-shadow: 0 4px 12px rgba(0,0,0,0.03);
  overflow: hidden;
}

.farm-table {
  width: 100%;
  border-collapse: collapse;
}

.farm-table th {
  background: rgba(11, 93, 30, 0.03);
  padding: 14px 20px;
  text-align: left;
  font-size: 11px;
  color: #0B5D1E;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-weight: 800;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
}

.farm-table td {
  padding: 16px 20px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.05);
  font-size: 14px;
  color: #1e293b;
}

.farm-table tr:hover {
  background-color: rgba(11, 93, 30, 0.03);
}

.id-text {
  font-family: 'JetBrains Mono', monospace;
  font-weight: 600;
  color: #94a3b8;
}

.farm-name {
  font-weight: 700;
  color: #0f172a;
}

.location-text {
  color: #475569;
}

.mono-text {
  font-family: monospace;
  color: #475569;
}

.cap-badge {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
  padding: 5px 12px;
  border-radius: 8px;
  font-weight: 800;
  font-size: 12px;
  border: 1px solid rgba(76, 175, 80, 0.2);
}

.empty-msg {
  text-align: center;
  padding: 40px;
  color: #94a3b8;
  font-style: italic;
}

/* Badges de Statut - avec vos couleurs */
.status-badge {
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
}

.status-badge.active {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

.status-badge.suspended {
  background: rgba(255, 152, 0, 0.1);
  color: #063B16;
}

.status-badge.closed {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

/* ==========================================================================
   4. PAGINATION
   ========================================================================== */
.pagination-footer {
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(11, 93, 30, 0.02);
}

.pagination-info {
  font-size: 13px;
  color: #64748b;
  font-weight: 600;
}

.pagination-controls {
  display: flex;
  gap: 6px;
}

.btn-nav, .page-num {
  padding: 6px 12px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  background: white;
  font-weight: 700;
  font-size: 13px;
  cursor: pointer;
  color: #063B16;
  transition: all 0.2s;
}

.btn-nav:hover:not(:disabled), .page-num:hover {
  background: rgba(11, 93, 30, 0.1);
}

.page-num.active {
  background: #0B5D1E;
  color: white;
  border-color: #0B5D1E;
}

.btn-nav:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ==========================================================================
   5. DASHBOARD BAS (statistiques existantes)
   ========================================================================== */
.bottom-dashboard {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 25px;
}

.stat-box, .stats-card {
  background: white;
  padding: 25px;
  border-radius: 12px;
  border: 1px solid rgba(11, 93, 30, 0.08);
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
}

/* Première stat box - Total Fermes */
.stat-box:nth-child(1) {
  position: relative;
  border-left: 4px solid #0B5D1E;
}

.stat-box:nth-child(1)::before {
  display: none;
}

.stat-box:nth-child(1) .label {
  color: #0B5D1E;
}

.stat-box:nth-child(1) .number {
  color: #0B5D1E;
}

/* Deuxième stat box - Capacité Totale */
.stat-box:nth-child(2) {
  position: relative;
  border-left: 4px solid #4CAF50;
}

.stat-box:nth-child(2)::before {
  display: none;
}

.stat-box:nth-child(2) .label {
  color: #4CAF50;
}

.stat-box:nth-child(2) .number {
  color: #4CAF50;
}

.stat-box .label {
  font-size: 10px;
  font-weight: 800;
  display: block;
  margin-bottom: 5px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.stat-box .number {
  font-size: 24px;
  font-weight: 900;
  line-height: 1;
}

.stat-box .number small {
  font-size: 16px;
  font-weight: 600;
}

/* Stats Card - Distribution */
.stats-card {
  border-left: 4px solid #063B16;
}

.stats-header-mini {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.stats-header-mini h4 {
  font-size: 15px;
  font-weight: 800;
  color: #0f172a;
  margin: 0;
}

.stats-header-mini i {
  color: #063B16;
}

.progress-item {
  margin-bottom: 15px;
}

.progress-labels {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 6px;
  color: #063B16;
}

.progress-track {
  height: 6px;
  background: rgba(11, 93, 30, 0.08);
  border-radius: 3px;
  overflow: hidden;
}

.fill {
  height: 100%;
  background: #FF9800;
  border-radius: 3px;
  transition: width 1s ease-out;
}

/* ==========================================================================
   6. WIDGET CARTE
   ========================================================================== */
.map-card-preview {
  border-radius: 12px;
  background: linear-gradient(rgba(6, 59, 22, 0.6), rgba(11, 93, 30, 0.8)),
              url('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=600&q=80');
  background-size: cover;
  background-position: center;
  padding: 25px;
  display: flex;
  align-items: flex-end;
  color: white;
  cursor: pointer;
  border: 2px solid rgba(11, 93, 30, 0.2);
  transition: 0.3s;
  height: auto;
  min-height: 150px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
}

.map-card-preview:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 15px rgba(11, 93, 30, 0.15);
  border-color: #0B5D1E;
}

.map-overlay h4 {
  margin: 0;
  font-size: 16px;
  font-weight: 800;
}

.map-overlay p {
  margin: 5px 0 0;
  font-size: 12px;
  opacity: 0.9;
}

/* ==========================================================================
   7. MODALE
   ========================================================================== */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(6, 59, 22, 0.7);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.map-modal {
  background: white;
  width: 90%;
  max-width: 900px;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.2);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid rgba(11, 93, 30, 0.1);
  padding-bottom: 15px;
  margin-bottom: 15px;
}

.modal-header h2 {
  font-size: 18px;
  font-weight: 800;
  color: #063B16;
}

.map-container {
  height: 60vh;
  width: 100%;
  border-radius: 8px;
}

.btn-close {
  border: none;
  background: rgba(11, 93, 30, 0.08);
  font-size: 18px;
  cursor: pointer;
  color: #0B5D1E;
  width: 35px;
  height: 35px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.btn-close:hover {
  background: rgba(11, 93, 30, 0.15);
}

/* ==========================================================================
   8. RESPONSIVE
   ========================================================================== */
@media (max-width: 1200px) {
  .bottom-dashboard {
    grid-template-columns: 1fr;
  }

  .filters-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .search-box {
    max-width: 100%;
  }
}
</style>