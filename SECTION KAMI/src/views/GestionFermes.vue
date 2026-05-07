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
.main-content { font-family: 'Inter', sans-serif; background-color: #f8fafb; min-height: 100vh; padding: 30px; color: #2d3748; }
.page-header { margin-bottom: 25px; }
.page-header h1 { font-size: 26px; font-weight: 800; color: #1a202c; margin: 0; }
.subtitle { color: #718096; font-size: 14px; }

.farm-content-stacked { display: flex; flex-direction: column; gap: 20px; }

/* FILTRES */
.filters-bar { display: flex; justify-content: space-between; align-items: center; background: white; padding: 15px 20px; border-radius: 12px; border: 1px solid #edf2f7; gap: 20px; flex-wrap: wrap; }
.search-box { display: flex; align-items: center; background: #f3f4f6; padding: 10px 15px; border-radius: 8px; flex: 1; max-width: 400px; }
.search-box input { border: none; background: transparent; width: 100%; outline: none; margin-left: 10px; font-size: 14px; }

.number-filters { display: flex; gap: 20px; }
.number-input-group { display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 600; }
.number-input-group input { width: 80px; padding: 8px; border: 1px solid #e5e7eb; border-radius: 6px; }

/* TABLEAU */
.table-container-card { background: white; border-radius: 16px; border: 1px solid #edf2f7; box-shadow: 0 4px 12px rgba(0,0,0,0.03); overflow: hidden; }
.farm-table { width: 100%; border-collapse: collapse; }
.farm-table th { background: #f8fafc; padding: 15px 20px; text-align: left; font-size: 11px; color: #718096; text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 1px solid #edf2f7; }
.farm-table td { padding: 18px 20px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
.farm-table tr:hover { background-color: #f0fdf4; }
.id-text { font-family: 'JetBrains Mono', monospace; font-weight: 600; color: #a0aec0; }
.farm-name { font-weight: 700; color: #1a202c; }
.mono-text { font-family: monospace; color: #4a5568; }
.cap-badge { background: #f0fff4; color: #38a169; padding: 5px 12px; border-radius: 8px; font-weight: 800; font-size: 12px; border: 1px solid #c6f6d5; }
.empty-msg { text-align: center; padding: 40px; color: #a0aec0; font-style: italic; }

/* Badges de Statut */
.status-badge {
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
}
.status-badge.active {
  background: #def7ec;
  color: #03543f;
}
.status-badge.suspended {
  background: #fef3c7;
  color: #92400e;
}
.status-badge.closed {
  background: #fde8e8;
  color: #9b1c1c;
}

.owner-text {
  font-weight: 600;
  color: #4a5568;
}

/* PAGINATION */
.pagination-footer { padding: 15px 25px; display: flex; justify-content: space-between; align-items: center; background: #fcfcfd; }
.pagination-info { font-size: 13px; color: #718096; font-weight: 600; }
.pagination-controls { display: flex; gap: 6px; }
.btn-nav, .page-num { padding: 6px 12px; border: 1px solid #e2e8f0; border-radius: 8px; background: white; font-weight: 700; font-size: 13px; cursor: pointer; }
.page-num.active { background: #11D432; color: white; border-color: #11D432; }

/* DASHBOARD BAS */
.bottom-dashboard { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
.stat-box, .stats-card { background: white; padding: 20px; border-radius: 16px; border: 1px solid #edf2f7; box-shadow: 0 4px 10px rgba(0,0,0,0.02); }
.stat-box { position: relative; }
.stat-box::before { content: ""; position: absolute; left: 0; top: 20%; height: 60%; width: 4px; background: #11D432; border-radius: 0 4px 4px 0; }
.stat-box .label { font-size: 10px; font-weight: 800; color: #a0aec0; display: block; margin-bottom: 5px; }
.stat-box .number { font-size: 26px; font-weight: 900; color: #1a202c; }

.stats-header-mini { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
.stats-header-mini h4 { font-size: 13px; font-weight: 800; margin: 0; }
.progress-item { margin-bottom: 10px; }
.progress-labels { display: flex; justify-content: space-between; font-size: 11px; font-weight: 700; margin-bottom: 4px; }
.progress-track { height: 6px; background: #edf2f7; border-radius: 10px; overflow: hidden; }
.fill { height: 100%; background: linear-gradient(90deg, #11D432, #58d68d); }

/* WIDGET CARTE */
.map-card-preview { border-radius: 16px; background: linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.8)), url('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=600&q=80'); background-size: cover; background-position: center; padding: 20px; display: flex; align-items: flex-end; color: white; cursor: pointer; border: 3px solid white; transition: 0.3s; height: 120px; }
.map-card-preview:hover { transform: translateY(-3px); box-shadow: 0 8px 15px rgba(0,0,0,0.1); border-color: #11D432; }
.map-overlay h4 { margin: 0; font-size: 16px; }
.map-overlay p { margin: 5px 0 0; font-size: 11px; opacity: 0.8; }

/* MODALE */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 1000; }
.map-modal { background: white; width: 90%; max-width: 900px; border-radius: 12px; padding: 20px; }
.modal-header { display: flex; justify-content: space-between; border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 15px; }
.map-container { height: 60vh; width: 100%; border-radius: 8px; }
.btn-close { border: none; background: none; font-size: 20px; cursor: pointer; color: #9ca3af; }
</style>