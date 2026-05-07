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
              <th>ADRESSE GÉOGRAPHIQUE</th>
              <th>STATUT</th>
              <th>VÉRIFIÉ</th>
              <th>
                CAPACITÉ
                <button class="sort-btn" @click="cycleCapacitySort" :title="capacitySortLabel">
                  <i :class="capacitySortIcon"></i>
                </button>
              </th>
              <th>ACTIONS</th>
            </tr>
            </thead>
            <tbody>
            <tr v-if="filteredFarms.length === 0">
              <td colspan="8" class="empty-msg">Aucune ferme ne correspond à vos critères.</td>
            </tr>

            <tr v-for="farm in paginatedFarms" :key="farm.id">
              <td class="id-text">#FRM-{{ farm.id }}</td>

              <td>
                <span v-if="farm.owner?.firstName || farm.owner?.lastName" class="owner-name">
                  {{ (farm.owner?.firstName || '') + ' ' + (farm.owner?.lastName || '') }}
                </span>
                <span v-else-if="farm.owner?.id" class="id-text" style="color:#3b82f6;">#USR-{{ farm.owner.id }}</span>
                <span v-else class="id-text">--</span>
              </td>

              <td><span class="farm-name">{{ farm.name }}</span></td>

              <td>
                <div class="location-text">
                  <i class="fas fa-map-marker-alt" style="color: #e53e3e; margin-right: 5px;"></i>
                  {{ farm.location || 'Non définie' }}
                </div>
                <div class="coords-text" v-if="farm.latitude && farm.longitude">
                  <i class="fas fa-satellite"></i> {{ farm.latitude }}, {{ farm.longitude }}
                </div>
              </td>

              <td>
                <span class="farm-status-badge" :class="getFarmStatusClass(farm.status)">{{ translateFarmStatus(farm.status) || '—' }}</span>
              </td>

              <td>
                <span class="farm-status-badge" :class="farm.isVerified ? 'badge-verified' : 'badge-unverified'">
                  <i :class="farm.isVerified ? 'fas fa-check' : 'fas fa-times'"></i>
                  {{ farm.isVerified ? 'Oui' : 'Non' }}
                </span>
              </td>

              <td>
                <span class="cap-badge">{{ farm.capacity || 0 }} Ha</span>
              </td>

              <td>
                <button class="btn-action" @click="openEditModal(farm)" title="Administrer la ferme">
                  <i class="fas fa-cog"></i>
                </button>
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
              >{{ page }}</button>
              <button class="btn-nav" :disabled="currentPage === totalPages" @click="nextPage">Suivant</button>
            </div>
          </div>
        </div>
      </div>

      <div class="bottom-dashboard">
        <div class="stat-box detailed-stat-box">
          <div class="stat-main">
            <span class="label">TOTAL FERMES</span>
            <span class="number">{{ totalFarms }}</span>
          </div>
          <div class="stat-details">
            <div class="detail-row">
              <span class="detail-label"><i class="fas fa-check-circle text-green"></i> Vérifiées</span>
              <span class="detail-val">{{ verifiedFarmsCount }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label"><i class="fas fa-times-circle text-gray"></i> Non vérifiées</span>
              <span class="detail-val">{{ unverifiedFarmsCount }}</span>
            </div>
            <div class="divider"></div>
            <div class="detail-row">
              <span class="detail-label"><i class="fas fa-play-circle text-blue"></i> Actives</span>
              <span class="detail-val">{{ activeFarmsCount }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label"><i class="fas fa-pause-circle text-yellow"></i> Suspendues</span>
              <span class="detail-val">{{ suspendedFarmsCount }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label"><i class="fas fa-stop-circle text-red"></i> Fermées</span>
              <span class="detail-val">{{ closedFarmsCount }}</span>
            </div>
          </div>
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
              <div class="progress-labels"><span>&lt; 20 Ha</span> <span>{{ distUnder20 }}%</span></div>
              <div class="progress-track"><div class="fill" :style="{ width: distUnder20 + '%' }"></div></div>
            </div>
            <div class="progress-item">
              <div class="progress-labels"><span>20 – 100 Ha</span> <span>{{ dist20to100 }}%</span></div>
              <div class="progress-track"><div class="fill" :style="{ width: dist20to100 + '%' }"></div></div>
            </div>
            <div class="progress-item">
              <div class="progress-labels"><span>100 – 500 Ha</span> <span>{{ dist100to500 }}%</span></div>
              <div class="progress-track"><div class="fill" :style="{ width: dist100to500 + '%' }"></div></div>
            </div>
            <div class="progress-item">
              <div class="progress-labels"><span>&gt; 500 Ha</span> <span>{{ distOver500 }}%</span></div>
              <div class="progress-track"><div class="fill" :style="{ width: distOver500 + '%' }"></div></div>
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

    <div v-if="showEditModal" class="modal-overlay" @click.self="closeEditModal">
      <div class="modal-content edit-modal">
        <div class="modal-header">
          <h2>Administration de la Ferme #FRM-{{ selectedFarm.id }}</h2>
          <button class="btn-close" @click="closeEditModal"><i class="fas fa-times"></i></button>
        </div>
        <div class="farm-admin-controls">
          <div class="control-group">
            <label>Statut de l'exploitation :</label>
            <select v-model="selectedFarm.status" class="status-select">
              <option value="Active">Opérationnelle</option>
              <option value="Suspended">Suspendue (Anomalie/Sanction)</option>
              <option value="Closed">Fermée</option>
            </select>
          </div>

          <div class="control-group checkbox-group">
            <label>Vérification Officielle :</label>
            <div class="toggle-switch">
              <input type="checkbox" id="verify-toggle" v-model="selectedFarm.isVerified" />
              <label for="verify-toggle">
                {{ selectedFarm.isVerified ? 'Ferme Vérifiée & Conforme' : 'En attente de vérification' }}
              </label>
            </div>
          </div>

          <button class="btn-save-status" @click="saveFarmStatus" :disabled="isSaving">
            <i class="fas fa-spinner fa-spin" v-if="isSaving"></i>
            <i class="fas fa-save" v-else></i> Enregistrer les modifications
          </button>
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

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

const farms = ref([]);
const isLoading = ref(true);
const searchQuery = ref('');
const capacityMin = ref('');
const capacityMax = ref('');

const currentPage = ref(1);
const itemsPerPage = 7;
const capacitySort = ref('none');

const showMapModal = ref(false);
let mapInstance = null;

const showEditModal = ref(false);
const selectedFarm = ref(null);
const isSaving = ref(false);

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

const openEditModal = (farm) => {
  selectedFarm.value = { ...farm };
  showEditModal.value = true;
};

const closeEditModal = () => {
  showEditModal.value = false;
  selectedFarm.value = null;
};

const saveFarmStatus = async () => {
  if (!selectedFarm.value) return;

  try {
    isSaving.value = true;

    await api.put(`/farms/${selectedFarm.value.id}/status`, {
      status: selectedFarm.value.status,
      isVerified: selectedFarm.value.isVerified
    });

    const index = farms.value.findIndex(f => f.id === selectedFarm.value.id);
    if (index !== -1) {
      farms.value[index].status = selectedFarm.value.status;
      farms.value[index].isVerified = selectedFarm.value.isVerified;
    }

    closeEditModal();
  } catch (error) {
    console.error("Erreur lors de la mise à jour :", error);
    alert("Impossible de mettre à jour la ferme.");
  } finally {
    isSaving.value = false;
  }
};

const filteredFarms = computed(() => {
  const search = searchQuery.value.toLowerCase();
  const min = capacityMin.value !== '' ? Number(capacityMin.value) : null;
  const max = capacityMax.value !== '' ? Number(capacityMax.value) : null;

  return farms.value.filter(f => {
    const matchesSearch =
        String(f.id).includes(search) ||
        (f.owner && String(f.owner.id).includes(search)) ||
        (f.name || '').toLowerCase().includes(search) ||
        (f.location || '').toLowerCase().includes(search) ||
        (`${f.owner?.firstName || ''} ${f.owner?.lastName || ''}`.toLowerCase().includes(search));

    let matchesCapacity = true;
    const cap = f.capacity || 0;
    if (min !== null && cap < min) matchesCapacity = false;
    if (max !== null && cap > max) matchesCapacity = false;

    return matchesSearch && matchesCapacity;
  });
});

const cycleCapacitySort = () => {
  if (capacitySort.value === 'none') capacitySort.value = 'asc';
  else if (capacitySort.value === 'asc') capacitySort.value = 'desc';
  else capacitySort.value = 'none';
};

const capacitySortIcon = computed(() => {
  if (capacitySort.value === 'asc') return 'fas fa-sort-up';
  if (capacitySort.value === 'desc') return 'fas fa-sort-down';
  return 'fas fa-sort';
});

const capacitySortLabel = computed(() => {
  if (capacitySort.value === 'asc') return 'Tri croissant';
  if (capacitySort.value === 'desc') return 'Tri décroissant';
  return 'Trier par capacité';
});

const sortedFilteredFarms = computed(() => {
  const result = [...filteredFarms.value];
  if (capacitySort.value === 'asc') result.sort((a, b) => (a.capacity || 0) - (b.capacity || 0));
  if (capacitySort.value === 'desc') result.sort((a, b) => (b.capacity || 0) - (a.capacity || 0));
  return result;
});

watch([searchQuery, capacityMin, capacityMax, capacitySort], () => currentPage.value = 1);

const paginatedFarms = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return sortedFilteredFarms.value.slice(start, start + itemsPerPage);
});

const totalPages = computed(() => Math.ceil(sortedFilteredFarms.value.length / itemsPerPage));
const paginationStart = computed(() => sortedFilteredFarms.value.length === 0 ? 0 : (currentPage.value - 1) * itemsPerPage + 1);
const paginationEnd = computed(() => Math.min(currentPage.value * itemsPerPage, sortedFilteredFarms.value.length));

const prevPage = () => { if (currentPage.value > 1) currentPage.value--; };
const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++; };
const setPage = (page) => { currentPage.value = page; };

const translateFarmStatus = (status) => {
  const map = { 'Active': 'Opérationnelle', 'Suspended': 'Suspendue', 'Closed': 'Fermée' };
  return map[status] || status;
};

const getFarmStatusClass = (status) => {
  const map = { 'Active': 'badge-green', 'Suspended': 'badge-yellow', 'Closed': 'badge-red' };
  return map[status] || 'badge-gray';
};

const totalFarms = computed(() => farms.value.length);
const activeFarmsCount = computed(() => farms.value.filter(f => f.status === 'Active').length);
const suspendedFarmsCount = computed(() => farms.value.filter(f => f.status === 'Suspended').length);
const closedFarmsCount = computed(() => farms.value.filter(f => f.status === 'Closed').length);
const verifiedFarmsCount = computed(() => farms.value.filter(f => f.isVerified === true).length);
const unverifiedFarmsCount = computed(() => farms.value.filter(f => f.isVerified === false).length);

const totalCapacity = computed(() => farms.value.reduce((acc, f) => acc + (f.capacity || 0), 0));

const distUnder20 = computed(() => {
  if (!totalFarms.value) return 0;
  return Math.round((farms.value.filter(f => (f.capacity || 0) < 20).length / totalFarms.value) * 100);
});
const dist20to100 = computed(() => {
  if (!totalFarms.value) return 0;
  return Math.round((farms.value.filter(f => (f.capacity || 0) >= 20 && (f.capacity || 0) < 100).length / totalFarms.value) * 100);
});
const dist100to500 = computed(() => {
  if (!totalFarms.value) return 0;
  return Math.round((farms.value.filter(f => (f.capacity || 0) >= 100 && (f.capacity || 0) < 500).length / totalFarms.value) * 100);
});
const distOver500 = computed(() => {
  if (!totalFarms.value) return 0;
  return Math.round((farms.value.filter(f => (f.capacity || 0) >= 500).length / totalFarms.value) * 100);
});

const openMapModal = async () => {
  showMapModal.value = true;
  await nextTick();
  mapInstance = L.map('farm-map').setView([28.0339, 1.6596], 5);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: '© OpenStreetMap' }).addTo(mapInstance);

  farms.value.forEach(f => {
    if (f.latitude && f.longitude) {
      L.marker([f.latitude, f.longitude])
          .addTo(mapInstance)
          .bindPopup(`<b>${f.name}</b><br>Capacité: ${f.capacity || 0} Ha`);
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

.filters-bar { display: flex; justify-content: space-between; align-items: center; background: white; padding: 15px 20px; border-radius: 12px; border: 1px solid #edf2f7; gap: 20px; flex-wrap: wrap; }
.search-box { display: flex; align-items: center; background: #f3f4f6; padding: 10px 15px; border-radius: 8px; flex: 1; max-width: 400px; }
.search-box input { border: none; background: transparent; width: 100%; outline: none; margin-left: 10px; font-size: 14px; }

.number-filters { display: flex; gap: 20px; }
.number-input-group { display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 600; }
.number-input-group input { width: 80px; padding: 8px; border: 1px solid #e5e7eb; border-radius: 6px; }

.table-container-card { background: white; border-radius: 16px; border: 1px solid #edf2f7; box-shadow: 0 4px 12px rgba(0,0,0,0.03); overflow: hidden; }
.farm-table { width: 100%; border-collapse: collapse; }
.farm-table th { background: #f8fafc; padding: 15px 20px; text-align: left; font-size: 11px; color: #718096; text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 1px solid #edf2f7; }
.farm-table td { padding: 18px 20px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
.farm-table tr:hover { background-color: #f0fdf4; }
.id-text { font-family: 'JetBrains Mono', monospace; font-weight: 600; color: #a0aec0; }
.farm-name { font-weight: 700; color: #1a202c; }
.mono-text { font-family: monospace; color: #4a5568; }
.coords-text { font-family: 'JetBrains Mono', monospace; font-size: 11px; color: #64748b; background: #f1f5f9; padding: 4px 8px; border-radius: 6px; display: inline-flex; align-items: center; gap: 5px; margin-top: 6px; }
.cap-badge { background: #f0fff4; color: #38a169; padding: 5px 12px; border-radius: 8px; font-weight: 800; font-size: 12px; border: 1px solid #c6f6d5; }
.empty-msg { text-align: center; padding: 40px; color: #a0aec0; font-style: italic; }

.btn-action { background: #f1f5f9; border: 1px solid transparent; color: #3b82f6; width: 32px; height: 32px; border-radius: 6px; cursor: pointer; transition: 0.2s; display: flex; align-items: center; justify-content: center;}
.btn-action:hover { background: #e2e8f0; border-color: #cbd5e1; color: #1e3a8a;}

.pagination-footer { padding: 15px 25px; display: flex; justify-content: space-between; align-items: center; background: #fcfcfd; }
.pagination-info { font-size: 13px; color: #718096; font-weight: 600; }
.pagination-controls { display: flex; gap: 6px; }
.btn-nav, .page-num { padding: 6px 12px; border: 1px solid #e2e8f0; border-radius: 8px; background: white; font-weight: 700; font-size: 13px; cursor: pointer; }
.page-num.active { background: #0B5D1E; color: white; border-color: #0B5D1E; }

.bottom-dashboard { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; align-items: start; }
.stat-box, .stats-card { background: white; padding: 20px; border-radius: 16px; border: 1px solid #edf2f7; box-shadow: 0 4px 10px rgba(0,0,0,0.02); }
.stat-box { position: relative; }
.stat-box::before { content: ""; position: absolute; left: 0; top: 20%; height: 60%; width: 4px; background: #0B5D1E; border-radius: 0 4px 4px 0; }

.detailed-stat-box { display: flex; flex-direction: column; gap: 15px; }
.stat-main { display: flex; flex-direction: column; }
.stat-main .label { font-size: 10px; font-weight: 800; color: #a0aec0; margin-bottom: 5px; }
.stat-main .number { font-size: 26px; font-weight: 900; color: #1a202c; }

.stat-details { display: flex; flex-direction: column; gap: 8px; font-size: 12px; font-weight: 600; color: #475569; background: #f8fafc; padding: 12px; border-radius: 8px; border: 1px solid #f1f5f9; }
.detail-row { display: flex; justify-content: space-between; align-items: center; }
.detail-label i { width: 14px; margin-right: 4px; text-align: center; }
.detail-val { font-weight: 700; color: #1a202c; }
.divider { height: 1px; background: #e2e8f0; margin: 4px 0; }

.text-green { color: #059669; }
.text-gray { color: #6b7280; }
.text-blue { color: #2563eb; }
.text-yellow { color: #d97706; }
.text-red { color: #dc2626; }

.stat-box .label:not(.detailed-stat-box .label) { font-size: 10px; font-weight: 800; color: #a0aec0; display: block; margin-bottom: 5px; }
.stat-box .number:not(.detailed-stat-box .number) { font-size: 26px; font-weight: 900; color: #1a202c; }

.stats-header-mini { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
.stats-header-mini h4 { font-size: 13px; font-weight: 800; margin: 0; }
.progress-item { margin-bottom: 10px; }
.progress-labels { display: flex; justify-content: space-between; font-size: 11px; font-weight: 700; margin-bottom: 4px; }
.progress-track { height: 6px; background: #edf2f7; border-radius: 10px; overflow: hidden; }
.fill { height: 100%; background: linear-gradient(90deg, #0B5D1E, #58d68d); }

.map-card-preview { border-radius: 16px; background: linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.8)), url('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=600&q=80'); background-size: cover; background-position: center; padding: 20px; display: flex; align-items: flex-end; color: white; cursor: pointer; border: 3px solid white; transition: 0.3s; height: 120px; }
.map-card-preview:hover { transform: translateY(-3px); box-shadow: 0 8px 15px rgba(0,0,0,0.1); border-color: #0B5D1E; }
.map-overlay h4 { margin: 0; font-size: 16px; }
.map-overlay p { margin: 5px 0 0; font-size: 11px; opacity: 0.8; }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 1000; }
.map-modal { background: white; width: 90%; max-width: 900px; border-radius: 12px; padding: 20px; }
.edit-modal { background: white; width: 100%; max-width: 500px; border-radius: 12px; padding: 25px; box-shadow: 0 10px 25px rgba(0,0,0,0.2); }

.modal-header { display: flex; justify-content: space-between; border-bottom: 1px solid #edf2f7; padding-bottom: 15px; margin-bottom: 20px; align-items: center; }
.modal-header h2 { margin: 0; font-size: 18px; font-weight: 800; color: #1a202c;}
.map-container { height: 60vh; width: 100%; border-radius: 8px; }
.btn-close { border: none; background: none; font-size: 20px; cursor: pointer; color: #a0aec0; transition: 0.2s;}
.btn-close:hover { color: #e53e3e; }

.farm-admin-controls { display: flex; flex-direction: column; gap: 20px; }
.control-group { display: flex; flex-direction: column; gap: 8px; }
.checkbox-group { margin-top: 5px; }
.control-group label { font-weight: 700; color: #4a5568; font-size: 13px; }

.status-select { padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; font-weight: 600; outline: none; background: #f8fafc; color: #1e293b;}
.status-select:focus { border-color: #3b82f6; background: white;}

.toggle-switch { display: flex; align-items: center; gap: 10px; background: #f8fafc; padding: 12px; border-radius: 8px; border: 1px solid #cbd5e1;}
.toggle-switch input[type="checkbox"] { width: 18px; height: 18px; cursor: pointer; accent-color: #0B5D1E; }
.toggle-switch label { margin: 0; font-weight: 600; color: #1e293b; cursor: pointer; }

.btn-save-status { background-color: #0B5D1E; color: white; border: none; border-radius: 8px; padding: 12px; font-weight: 700; font-size: 14px; cursor: pointer; width: 100%; transition: 0.2s; margin-top: 10px; display: flex; align-items: center; justify-content: center; gap: 8px;}
.btn-save-status:hover:not(:disabled) { background-color: #0ea828; }
.btn-save-status:disabled { opacity: 0.7; cursor: not-allowed; }

.sort-btn { background: none; border: none; cursor: pointer; color: #a0aec0; margin-left: 6px; font-size: 11px; padding: 2px 4px; border-radius: 4px; transition: color 0.2s; vertical-align: middle; }
.sort-btn:hover { color: #0B5D1E; }
.owner-name { font-weight: 600; color: #1a202c; }
.farm-status-badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 700; display: inline-flex; align-items: center; gap: 4px; }
.badge-green { background: #d1fae5; color: #047857; }
.badge-yellow { background: #fef9c3; color: #854d0e; }
.badge-red { background: #fee2e2; color: #b91c1c; }
.badge-gray { background: #f1f5f9; color: #475569; }
.badge-verified { background: #d1fae5; color: #047857; }
.badge-unverified { background: #f1f5f9; color: #6b7280; }
</style>