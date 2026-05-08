<template>
  <div class="inspections-container">

    <div class="header-section">
      <div class="title-row">
        <div>
          <h1>Gestion des Inspections</h1>
          <p class="subtitle">Registre national et contrôle de conformité biologique.</p>
        </div>
      </div>

      <div class="kpi-grid" v-if="!isLoading">
       <!-- KPI 1 - INSPECTIONS (TOTAL) -->
       <div class="kpi-card kpi-blue">
         <span class="kpi-label">INSPECTIONS (TOTAL)</span>
         <div class="kpi-value-row">
           <span class="kpi-value">{{ inspections.length }}</span>
         </div>
         <div class="kpi-bar-bg">
           <div class="kpi-bar" :style="{ width: inspections.length > 0 ? '100%' : '0%' }"></div>
         </div>
       </div>

       <!-- KPI 2 - TAUX DE FRAUDE -->
       <div class="kpi-card kpi-red">
         <span class="kpi-label">TAUX DE FRAUDE</span>
         <div class="kpi-value-row">
           <span class="kpi-value">{{ fraudRate }}%</span>
           <span class="kpi-trend red" v-if="fraudRate > 0">Attention</span>
         </div>
         <div class="kpi-bar-bg">
           <div class="kpi-bar" :style="{ width: fraudRate > 0 ? fraudRate + '%' : '0%' }"></div>
         </div>
       </div>

       <!-- KPI 3 - ENQUÊTES EN COURS -->
       <div class="kpi-card kpi-gray">
         <span class="kpi-label">ENQUÊTES EN COURS</span>
         <div class="kpi-value-row">
           <span class="kpi-value">{{ investigationsCount }}</span>
         </div>
         <div class="kpi-bar-bg">
           <div class="kpi-bar" :style="{ width: investigationsCount > 0 ? '45%' : '0%' }"></div>
         </div>
       </div>

       <!-- KPI 4 - SCORE DE CONFORMITÉ -->
       <div class="kpi-card kpi-green">
         <span class="kpi-label">SCORE DE CONFORMITÉ</span>
         <div class="kpi-value-row">
           <span class="kpi-value">{{ complianceScore }}%</span>
           <span class="kpi-trend green">Calculé</span>
         </div>
         <div class="kpi-bar-bg">
           <div class="kpi-bar" :style="{ width: complianceScore > 0 ? complianceScore + '%' : '0%' }"></div>
         </div>
       </div>
      </div>
    </div>

    <div class="filters-bar">
      <div class="search-box">
        <label>RECHERCHE</label>
        <div class="input-wrapper">
          <i class="fas fa-search"></i>
          <input type="text" v-model="searchQuery" placeholder="Rechercher un inspecteur ou une ferme...">
        </div>
      </div>

      <div class="filter-group">
        <label>RÉSULTAT</label>
        <select v-model="filterResult">
          <option value="">Tous les résultats</option>
          <option value="Compliant">Conforme</option>
          <option value="MinorAnomaly">Anomalie Mineure</option>
          <option value="FraudDetected">Fraude Détectée</option>
        </select>
      </div>

      <div class="filter-group">
        <label>STATUT</label>
        <select v-model="filterStatus">
          <option value="">Tous les statuts</option>
          <option value="Closed">Clôturé</option>
          <option value="Pending">En attente</option>
          <option value="UnderInvestigation">Investigation</option>
          <option value="Resolved">Résolu</option>
        </select>
      </div>

      <div class="filter-group">
        <label>TRIER PAR DATE</label>
        <select v-model="sortDateOrder">
          <option value="desc">Plus récentes d'abord</option>
          <option value="asc">Plus anciennes d'abord</option>
        </select>
      </div>
    </div>

    <div v-if="isLoading" class="loading">
      <i class="fas fa-spinner fa-spin"></i> Synchronisation des bases de données...
    </div>

    <div v-else class="main-layout">
      <div class="registry-card">
        <div class="registry-header">
          <h2>Registre National des Inspections</h2>
          <span class="last-update">{{ filteredInspections.length }} résultat(s)</span>
        </div>

        <div class="registry-table-wrapper">
        <table class="registry-table">
          <thead>
          <tr>
            <th>ID</th>
            <th>INSPECTEUR</th>
            <th>CIBLE</th>
            <th>DATE</th>
            <th>RÉSULTAT</th>
            <th>STATUT</th>
            <th>DÉTAILS</th>
          </tr>
          </thead>
          <tbody>
          <tr v-if="paginatedInspections.length === 0">
            <td colspan="7" class="text-center">Aucune inspection ne correspond à votre recherche.</td>
          </tr>
          <tr v-for="insp in paginatedInspections" :key="insp.id" :class="getRowClass(insp.result)">
            <td class="insp-id">#INS-{{ insp.id }}</td>
            <td>
              <div class="inspector-info">
                <span class="name">{{ getInspectorName(insp.inspectorId) }}</span>
                <span class="badge-id">Agent #{{ insp.inspectorId }}</span>
              </div>
            </td>
            <td>
              <div class="target-info">
                <span class="target-name">{{ getTargetName(insp) }}</span>
                <span class="target-ref">{{ getTargetRef(insp) }}</span>
              </div>
            </td>
            <td>
              <div class="date-info">
                <span class="date">{{ formatDate(insp.inspectionDate) }}</span>
                <span class="time">{{ formatTime(insp.inspectionDate) }}</span>
              </div>
            </td>
            <td>
              <span class="badge-result" :class="getResultClass(insp.result)">{{ translateResult(insp.result) }}</span>
            </td>
            <td>
              <span class="badge-status" :class="getStatusClass(insp.status)">{{ translateStatus(insp.status) }}</span>
            </td>
            <td>
              <button class="btn-view" title="Voir les détails" @click="openDetailsModal(insp)">
                <i class="fas fa-eye"></i>
              </button>
            </td>
          </tr>
          </tbody>
        </table></div>

        <div class="pagination">
          <span>Affichage {{ filteredInspections.length > 0 ? (currentPage - 1) * itemsPerPage + 1 : 0 }} - {{ Math.min(currentPage * itemsPerPage, filteredInspections.length) }} sur {{ filteredInspections.length }}</span>
          <div class="page-controls">
            <button :disabled="currentPage === 1" @click="currentPage--"><i class="fas fa-chevron-left"></i></button>
            <span class="page-num">{{ currentPage }} / {{ totalPages || 1 }}</span>
            <button :disabled="currentPage === totalPages || totalPages === 0" @click="currentPage++"><i class="fas fa-chevron-right"></i></button>
          </div>
        </div>
      </div>

      <div class="sidebar">
        <div class="map-trigger-card" @click="openMapModal">
          <div class="card-overlay">
            <div class="pulse-indicator-small"><span class="dot"></span> {{ mappedFrauds.length }} Fraudes</div>
            <h3>Cartographie des Fraudes</h3>
            <p>Cliquez pour ouvrir la carte <i class="fas fa-external-link-alt"></i></p>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showMapModal" class="modal-overlay" @click.self="closeMapModal">
      <div class="modal-content map-modal-content">
        <div class="modal-header">
          <h2>Carte des Fraudes Détectées</h2>
          <button class="btn-close" @click="closeMapModal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body map-modal-body">
          <div id="leaflet-map-fraud" class="full-leaflet-map"></div>
        </div>
      </div>
    </div>

    <div v-if="showDetailsModal" class="modal-overlay" @click.self="closeDetailsModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Détails de l'Inspection #INS-{{ selectedInspection.id }}</h2>
          <button class="btn-close" @click="closeDetailsModal"><i class="fas fa-times"></i></button>
        </div>

        <div class="modal-body">
          <div class="modal-section audit-summary-section">
            <h4><i class="fas fa-calculator"></i> Analyse des Écarts</h4>
            <div class="audit-stats-grid">
              <div class="stat-box">
                <label>Scannés</label>
                <div class="val">{{ selectedInspection.scanned_count || 0 }}</div>
              </div>
              <div class="stat-box">
                <label>Enregistrés</label>
                <div class="val">{{ selectedInspection.registered_count || 0 }}</div>
              </div>
              <div class="stat-box" :class="{'diff-error': (selectedInspection.scanned_count - selectedInspection.registered_count) !== 0}">
                <label>Différence</label>
                <div class="val">{{ (selectedInspection.scanned_count || 0) - (selectedInspection.registered_count || 0) }}</div>
              </div>
            </div>
          </div>

          <div class="modal-section bg-light-gray">
            <h4><i class="far fa-calendar-check"></i> Informations Générales</h4>
            <div class="info-grid">
              <div><strong>Date :</strong> {{ formatDate(selectedInspection.inspectionDate) }} à {{ formatTime(selectedInspection.inspectionDate) }}</div>
              <div>
                <strong>Résultat :</strong>
                <span class="badge-result" :class="getResultClass(selectedInspection.result)">{{ translateResult(selectedInspection.result) }}</span>
              </div>
              <div>
                <strong>Statut :</strong>
                <span class="badge-status" :class="getStatusClass(selectedInspection.status)">{{ translateStatus(selectedInspection.status) }}</span>
              </div>
              <div><strong>Type de Fraude :</strong> {{ translateFraudType(selectedInspection.fraudType) }}</div>
            </div>
          </div>

          <div class="info-row">
            <div class="modal-section">
              <h4><i class="fas fa-user-shield"></i> Agent Inspecteur</h4>
              <p><strong>Nom :</strong> {{ getInspectorName(selectedInspection.inspectorId) }}</p>
              <p><strong>ID Agent :</strong> #{{ selectedInspection.inspectorId }}</p>
            </div>
            <div class="modal-section">
              <h4><i class="fas fa-map-marker-alt"></i> Cible & Localisation</h4>
              <p><strong>Cible :</strong> {{ getTargetName(selectedInspection) }} ({{ getTargetRef(selectedInspection) }})</p>
              <p><strong>Lieu déclaré :</strong> {{ selectedInspection.locationDescription || 'Non renseigné' }}</p>
              <p><strong>Coordonnées GPS :</strong> {{ getInspectionCoordinates(selectedInspection) }}</p>
            </div>
          </div>

          <div class="modal-section notes-section">
            <h4><i class="fas fa-clipboard"></i> Notes et Remarques</h4>
            <p class="notes-text">{{ selectedInspection.notes || 'Aucune remarque saisie par l\'inspecteur.' }}</p>
          </div>

          <div class="modal-section photos-section">
            <div class="photos-header">
              <h4><i class="fas fa-camera"></i> Preuves Photographiques</h4>
              <button
                  v-if="!imagesLoaded && !isLoadingImages"
                  class="btn-load-photos"
                  @click="fetchInspectionImages"
              >
                <i class="fas fa-cloud-download-alt"></i> Charger les images
              </button>
            </div>

            <div v-if="isLoadingImages" class="loading-photos">
              <i class="fas fa-circle-notch fa-spin"></i> Récupération des images sécurisées...
            </div>

            <div v-if="imagesLoaded">
              <div v-if="inspectionImages.length === 0" class="empty-photos">
                <i class="fas fa-image" style="font-size: 24px; color: #cbd5e1; margin-bottom: 8px;"></i><br>
                Aucune image associée à ce contrôle.
              </div>

              <div v-else class="photos-grid">
                <div v-for="(img, index) in inspectionImages" :key="index" class="photo-card">
                  <img :src="img.imageUrl || img" alt="Preuve d'inspection" />
                  <a :href="img.imageUrl || img" target="_blank" class="photo-overlay">
                    <i class="fas fa-search-plus"></i>
                  </a>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch, nextTick } from 'vue';
import api from '../services/api';

import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

const inspections = ref([]);
const usersDict = ref({});
const farmsDict = ref({});
const isLoading = ref(true);

const searchQuery = ref('');
const filterResult = ref('');
const filterStatus = ref('');
const sortDateOrder = ref('desc');

const currentPage = ref(1);
const itemsPerPage = 20;

const showDetailsModal = ref(false);
const selectedInspection = ref(null);
const showMapModal = ref(false);

const inspectionImages = ref([]);
const isLoadingImages = ref(false);
const imagesLoaded = ref(false);

let map = null;
let markersLayer = null;

const fetchAllData = async () => {
  try {
    isLoading.value = true;
    const [inspectionsRes, usersRes, farmsRes] = await Promise.all([
      api.get('/inspections'),
      api.get('/users').catch(() => ({ data: [] })),
      api.get('/farms').catch(() => ({ data: [] }))
    ]);

    inspections.value = inspectionsRes.data;

    const uDict = {};
    usersRes.data.forEach(u => { uDict[u.id] = u; });
    usersDict.value = uDict;

    const fDict = {};
    farmsRes.data.forEach(f => { fDict[f.id] = f; });
    farmsDict.value = fDict;

  } catch (error) {
    console.error("Erreur API Globale:", error);
  } finally {
    isLoading.value = false;
  }
};

onMounted(fetchAllData);

const mappedFrauds = computed(() => {
  return inspections.value.filter(i => {
    if (i.result !== 'FraudDetected') return false;
    const farm = i.farmId ? farmsDict.value[i.farmId] : null;
    return farm && (farm.latitudeCoordinate || farm.latitude) && (farm.longitudeCoordinate || farm.longitude);
  });
});

const openMapModal = () => {
  showMapModal.value = true;
  nextTick(() => { initMap(); });
};

const closeMapModal = () => {
  showMapModal.value = false;
  if (map) { map.remove(); map = null; markersLayer = null; }
};

const initMap = () => {
  if (map) return;
  map = L.map('leaflet-map-fraud').setView([28.0339, 1.6596], 5);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(map);
  markersLayer = L.layerGroup().addTo(map);
  updateMapMarkers();
};

const updateMapMarkers = () => {
  if (!markersLayer) return;
  markersLayer.clearLayers();
  const redMarkerIcon = L.divIcon({
    className: 'custom-leaflet-marker',
    html: `<div style="background-color: #e11d48; width: 16px; height: 16px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 10px rgba(0,0,0,0.5);"></div>`,
    iconSize: [20, 20], iconAnchor: [10, 10], popupAnchor: [0, -10]
  });
  mappedFrauds.value.forEach(fraude => {
    const farm = farmsDict.value[fraude.farmId];
    const lat = farm.latitudeCoordinate || farm.latitude;
    const lng = farm.longitudeCoordinate || farm.longitude;
    const marker = L.marker([lat, lng], { icon: redMarkerIcon }).addTo(markersLayer);
    marker.bindPopup(`<b>${getTargetName(fraude)}</b>`);
    marker.on('click', () => { openDetailsModal(fraude); });
  });
};

const fetchInspectionImages = async () => {
  if (!selectedInspection.value) return;
  isLoadingImages.value = true;
  try {
    const response = await api.get(`/inspections/${selectedInspection.value.id}/images`);
    inspectionImages.value = response.data;
    imagesLoaded.value = true;
  } catch (error) {
    inspectionImages.value = [];
    imagesLoaded.value = true;
  } finally {
    isLoadingImages.value = false;
  }
};

const openDetailsModal = (insp) => {
  selectedInspection.value = insp;
  inspectionImages.value = [];
  imagesLoaded.value = false;
  showDetailsModal.value = true;
};

const closeDetailsModal = () => {
  showDetailsModal.value = false;
  selectedInspection.value = null;
};

const getInspectionCoordinates = (insp) => {
  if (!insp || !insp.farmId) return 'N/A';
  const farm = farmsDict.value[insp.farmId];
  if (farm && (farm.latitudeCoordinate || farm.latitude)) {
    return `${farm.latitudeCoordinate || farm.latitude} , ${farm.longitudeCoordinate || farm.longitude}`;
  }
  return 'N/A';
};

const getInspectorName = (id) => {
  if (!id || !usersDict.value[id]) return "Agent Inconnu";
  return `${usersDict.value[id].lastName} ${usersDict.value[id].firstName}`;
};

const getTargetName = (insp) => {
  if (insp.farmId && farmsDict.value[insp.farmId]) {
    return farmsDict.value[insp.farmId].name || farmsDict.value[insp.farmId].farmName || `Ferme #${insp.farmId}`;
  }
  return 'N/A';
};

const getTargetRef = (insp) => {
  if (insp.farmId) return `FRM-${insp.farmId}`;
  return 'GÉNÉRAL';
};

const filteredInspections = computed(() => {
  let filtered = inspections.value.filter(insp => {
    const q = searchQuery.value.toLowerCase();
    const inspectorStr = getInspectorName(insp.inspectorId).toLowerCase();
    const targetStr = getTargetName(insp).toLowerCase();
    const matchesSearch = q === '' || inspectorStr.includes(q) || targetStr.includes(q);
    const matchResult = filterResult.value === '' || insp.result === filterResult.value;
    const matchStatus = filterStatus.value === '' || insp.status === filterStatus.value;
    return matchesSearch && matchResult && matchStatus;
  });
  filtered.sort((a, b) => {
    const dateA = new Date(a.inspectionDate).getTime();
    const dateB = new Date(b.inspectionDate).getTime();
    return sortDateOrder.value === 'desc' ? dateB - dateA : dateA - dateB;
  });
  return filtered;
});

const totalPages = computed(() => Math.ceil(filteredInspections.value.length / itemsPerPage));
const paginatedInspections = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredInspections.value.slice(start, start + itemsPerPage);
});

const fraudRate = computed(() => {
  if (inspections.value.length === 0) return 0;
  const frauds = inspections.value.filter(i => i.result === 'FraudDetected').length;
  return ((frauds / inspections.value.length) * 100).toFixed(1);
});

const investigationsCount = computed(() => inspections.value.filter(i => i.status === 'UnderInvestigation').length);
const complianceScore = computed(() => {
  if (inspections.value.length === 0) return 0;
  const compliant = inspections.value.filter(i => i.result === 'Compliant').length;
  return ((compliant / inspections.value.length) * 100).toFixed(1);
});

const formatDate = (dateString) => {
  if (!dateString) return '--';
  return new Date(dateString).toLocaleDateString('fr-FR');
};

const formatTime = (dateString) => {
  if (!dateString) return '';
  return new Date(dateString).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });
};

const translateResult = (res) => {
  const map = { 'Compliant': 'Conforme', 'MinorAnomaly': 'Anomalie Mineure', 'FraudDetected': 'Fraude Détectée' };
  return map[res] || res;
};

const getResultClass = (res) => {
  const map = { 'Compliant': 'bg-green text-green-dark', 'MinorAnomaly': 'bg-orange text-orange-dark', 'FraudDetected': 'bg-red text-red-dark' };
  return map[res] || 'bg-gray text-gray-dark';
};

const translateStatus = (status) => {
  const map = { 'Closed': 'Clôturé', 'Pending': 'En attente', 'UnderInvestigation': 'Investigation', 'Resolved': 'Résolu' };
  return map[status] || status;
};

const translateFraudType = (type) => {
  const map = { 'None': 'Aucune', 'Theft': 'Vol', 'TagTampering': 'Falsification', 'IllegalMovement': 'Mouvement Illégal' };
  return map[type] || type || 'N/A';
};

const getStatusClass = (status) => {
  if (status === 'UnderInvestigation') return 'bg-navy text-white';
  return 'bg-gray-light text-gray-dark border-gray';
};

const getRowClass = (result) => result === 'FraudDetected' ? 'row-danger' : '';
</script>

<style scoped>
/* ==========================================================================
   1. BASE
   ========================================================================== */
.inspections-container {
  font-family: 'Inter', sans-serif;
  background-color: #f4f7f6;
  min-height: 100vh;
  padding: 30px;
  color: #1e293b;
}

/* ==========================================================================
   2. HEADER & KPIs (Mêmes dimensions que le dashboard)
   ========================================================================== */
.header-section {
  margin-bottom: 25px;
}

.title-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 25px;
}

.title-row h1 {
  font-size: 26px;
  font-weight: 900;
  margin: 0;
  color: #0f172a;
  letter-spacing: -0.5px;
}

.subtitle {
  color: #64748b;
  font-size: 14px;
  margin-top: 5px;
}

.btn-export {
  background: rgba(11, 93, 30, 0.08);
  border: 1px solid rgba(11, 93, 30, 0.2);
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  color: #063B16;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: 0.2s;
}

.btn-export:hover {
  background: rgba(11, 93, 30, 0.15);
}

.kpi-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.kpi-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  border-left: 4px solid transparent;
}

.kpi-blue { border-left-color: #4CAF50; }
.kpi-red { border-left-color: #F44336; }
.kpi-gray { border-left-color: #FF9800; }
.kpi-green { border-left-color: #0B5D1E; }

.kpi-label {
  font-size: 10px;
  font-weight: 800;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  display: block;
  margin-bottom: 4px;
}

.kpi-value-row {
  display: flex;
  align-items: baseline;
  gap: 10px;
  margin: 4px 0;
}

.kpi-value {
  font-size: 24px;
  font-weight: 900;
  color: #0f172a;
  line-height: 1;
}

.kpi-trend {
  font-size: 11px;
  font-weight: 700;
}

.kpi-trend.green { color: #4CAF50; }
.kpi-trend.red { color: #F44336; }

.kpi-bar-bg {
  height: 6px;
  background: rgba(11, 93, 30, 0.08);
  border-radius: 3px;
  overflow: hidden;
  margin-top: 8px;
}

.kpi-bar {
  height: 100%;
  border-radius: 3px;
  transition: width 1s ease-out;
}

.kpi-blue .kpi-bar { background: #4CAF50; }
.kpi-red .kpi-bar { background: #F44336; }
.kpi-gray .kpi-bar { background: #FF9800; }
.kpi-green .kpi-bar { background: #0B5D1E; }

/* FILTRES */
.filters-bar {
  display: flex;
  align-items: flex-end;
  gap: 20px;
  background: white;
  padding: 16px 25px;
  border-radius: 12px;
  margin-bottom: 25px;
  border: 1px solid rgba(11, 93, 30, 0.08);
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
}

.search-box {
  flex: 2;
  display: flex;
  flex-direction: column;
  gap: 6px;
  min-width: 200px;
}

.search-box label {
  font-size: 10px;
  font-weight: 700;
  color: #0B5D1E;
  text-transform: uppercase;
  white-space: nowrap;
}

.search-box .input-wrapper {
  position: relative;
}

.search-box .input-wrapper i {
  position: absolute;
  left: 14px;
  top: 50%;
  transform: translateY(-50%);
  color: #0B5D1E;
  opacity: 0.6;
  font-size: 14px;
}

.search-box input {
  width: 100%;
  padding: 10px 14px 10px 42px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  outline: none;
  background: rgba(11, 93, 30, 0.03);
  font-size: 14px;
  font-family: inherit;
  color: #063B16;
  height: 44px;
  box-sizing: border-box;
}

.search-box input::placeholder {
  color: #0B5D1E;
  opacity: 0.5;
}

.search-box input:focus {
  border-color: #0B5D1E;
  background: white;
  box-shadow: 0 0 0 3px rgba(11, 93, 30, 0.1);
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
  flex: 0 1 auto;
}

.filter-group label {
  font-size: 10px;
  font-weight: 700;
  color: #0B5D1E;
  text-transform: uppercase;
  white-space: nowrap;
}

.filter-group select {
  padding: 10px 14px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  outline: none;
  background: white;
  font-weight: 600;
  color: #063B16;
  font-size: 13px;
  height: 44px;
  box-sizing: border-box;
  min-width: 150px;
}

.filter-group select:focus {
  border-color: #0B5D1E;
  box-shadow: 0 0 0 3px rgba(11, 93, 30, 0.1);
}

/* ==========================================================================
   4. MAIN LAYOUT
   ========================================================================== */
.main-layout {
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: 25px;
}

/* ==========================================================================
   5. TABLE REGISTRY
   ========================================================================== */
.registry-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-width: 0;
  border: 1px solid rgba(11, 93, 30, 0.08);
}

.registry-table-wrapper {
  width: 100%;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.registry-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 25px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
}

.registry-header h2 {
  margin: 0;
  font-size: 16px;
  font-weight: 800;
  color: #0f172a;
}

.last-update {
  font-size: 12px;
  color: #0B5D1E;
  font-weight: 500;
  background: rgba(11, 93, 30, 0.05);
  padding: 4px 10px;
  border-radius: 20px;
}

.registry-table {
  width: 100%;
  border-collapse: collapse;
}

.registry-table th {
  text-align: left;
  padding: 14px 20px;
  font-size: 11px;
  font-weight: 800;
  color: #0B5D1E;
  text-transform: uppercase;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  background: rgba(11, 93, 30, 0.03);
  letter-spacing: 0.5px;
}

.registry-table td {
  padding: 16px 20px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.05);
  vertical-align: middle;
}

.registry-table tr:hover {
  background-color: rgba(11, 93, 30, 0.02);
}

.row-danger {
  background-color: rgba(244, 67, 54, 0.03);
}

.row-danger:hover {
  background-color: rgba(244, 67, 54, 0.06);
}

.insp-id {
  font-weight: 800;
  color: #0B5D1E;
  font-size: 14px;
  font-family: 'JetBrains Mono', monospace;
}

.inspector-info, .target-info, .date-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.name, .target-name {
  font-weight: 700;
  color: #0f172a;
  font-size: 14px;
}

.badge-id, .target-ref {
  font-size: 12px;
  color: #64748b;
}

.date {
  font-weight: 600;
  color: #063B16;
  font-size: 14px;
}

.time {
  font-size: 12px;
  color: #94a3b8;
}

/* Badges de Résultat et Statut */
.badge-result, .badge-status {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  display: inline-block;
  text-align: center;
  text-transform: uppercase;
}

.bg-green { background: rgba(76, 175, 80, 0.1); }
.text-green-dark { color: #4CAF50; }

.bg-red { background: rgba(244, 67, 54, 0.1); }
.text-red-dark { color: #F44336; }

.bg-orange { background: rgba(255, 152, 0, 0.1); }
.text-orange-dark { color: #FF9800; }

.bg-navy { background: #063B16; }
.text-white { color: white; }

.bg-gray-light { background: rgba(11, 93, 30, 0.05); }
.border-gray { border: 1px solid rgba(11, 93, 30, 0.1); }
.text-gray-dark { color: #64748b; }

.btn-view {
  background: rgba(11, 93, 30, 0.08);
  border: 1px solid rgba(11, 93, 30, 0.2);
  color: #0B5D1E;
  width: 32px;
  height: 32px;
  border-radius: 6px;
  cursor: pointer;
  transition: 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-view:hover {
  background: #0B5D1E;
  border-color: #0B5D1E;
  color: white;
}

/* ==========================================================================
   6. PAGINATION (Corrigée)
   ========================================================================== */
.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: rgba(11, 93, 30, 0.02);
  border-top: 1px solid rgba(11, 93, 30, 0.08);
  color: #64748b;
  font-size: 13px;
  font-weight: 600;
}

.page-controls {
  display: flex;
  align-items: center;
  gap: 10px;
}

.page-controls button {
  width: 35px;
  height: 35px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  background: white;
  border-radius: 8px;
  cursor: pointer;
  color: #063B16;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: 0.2s;
}

.page-controls button:hover:not(:disabled) {
  background: rgba(11, 93, 30, 0.1);
}

.page-controls button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-num {
  font-weight: 700;
  color: #063B16;
  min-width: 80px;
  text-align: center;
}

/* ==========================================================================
   7. WIDGET CARTE (SIDEBAR)
   ========================================================================== */
.sidebar {
  display: flex;
  flex-direction: column;
}

.map-trigger-card {
  background-image: url('https://images.unsplash.com/photo-1524661135-423995f22d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80');
  background-size: cover;
  background-position: center;
  border-radius: 12px;
  overflow: hidden;
  height: 250px;
  position: relative;
  cursor: pointer;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  transition: transform 0.2s, box-shadow 0.2s;
  border: 2px solid rgba(11, 93, 30, 0.2);
}

.map-trigger-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 15px rgba(11, 93, 30, 0.15);
  border-color: #0B5D1E;
}

.card-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(6, 59, 22, 0.95), rgba(6, 59, 22, 0.4));
  padding: 25px;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  color: white;
}

.pulse-indicator-small {
  font-size: 11px;
  font-weight: 700;
  color: #F44336;
  text-transform: uppercase;
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 8px;
}

.pulse-indicator-small .dot {
  width: 8px;
  height: 8px;
  background: #F44336;
  border-radius: 50%;
  display: inline-block;
  animation: blink 1s infinite;
}

@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}

.card-overlay h3 {
  margin: 0 0 5px 0;
  font-size: 20px;
  font-weight: 800;
  text-shadow: 0 2px 4px rgba(0,0,0,0.5);
}

.card-overlay p {
  margin: 0;
  font-size: 13px;
  color: #cbd5e1;
  display: flex;
  align-items: center;
  gap: 6px;
}

/* ==========================================================================
   8. MODALES
   ========================================================================== */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(6, 59, 22, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
  backdrop-filter: blur(4px);
}

.modal-content {
  background: white;
  width: 100%;
  max-width: 650px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 25px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  background: rgba(11, 93, 30, 0.02);
}

.modal-header h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 800;
  color: #063B16;
}

.btn-close {
  background: rgba(11, 93, 30, 0.08);
  border: none;
  font-size: 18px;
  color: #0B5D1E;
  cursor: pointer;
  transition: 0.2s;
  width: 35px;
  height: 35px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-close:hover {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

.modal-body {
  padding: 25px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  max-height: 70vh;
  overflow-y: auto;
}

.info-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.modal-section {
  border: 1px solid rgba(11, 93, 30, 0.08);
  border-radius: 12px;
  padding: 15px;
}

.bg-light-gray {
  background: rgba(11, 93, 30, 0.02);
  border: none;
}

.modal-section h4 {
  margin: 0 0 15px 0;
  font-size: 14px;
  font-weight: 800;
  color: #0B5D1E;
  display: flex;
  align-items: center;
  gap: 8px;
}

.modal-section p {
  margin: 0 0 8px 0;
  font-size: 13px;
  color: #475569;
}

.modal-section p strong {
  color: #063B16;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  font-size: 13px;
  color: #475569;
}

.info-grid strong {
  color: #063B16;
  display: block;
  margin-bottom: 4px;
}

.notes-section {
  background: rgba(255, 152, 0, 0.05);
  border-color: rgba(255, 152, 0, 0.2);
}

.notes-section h4 {
  color: #FF9800;
}

.notes-text {
  font-style: italic;
  color: #475569 !important;
  line-height: 1.5;
}

/* Galerie Photos */
.photos-section {
  border: none;
  background: white;
  padding: 0;
  margin-top: 10px;
}

.photos-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 2px solid rgba(11, 93, 30, 0.08);
  padding-bottom: 10px;
  margin-bottom: 15px;
}

.photos-header h4 {
  margin: 0;
  color: #063B16;
}

.btn-load-photos {
  background: rgba(11, 93, 30, 0.08);
  border: 1px solid rgba(11, 93, 30, 0.2);
  color: #0B5D1E;
  font-weight: 600;
  padding: 8px 15px;
  border-radius: 6px;
  cursor: pointer;
  transition: 0.2s;
  font-size: 12px;
}

.btn-load-photos:hover {
  background: rgba(11, 93, 30, 0.15);
  border-color: #0B5D1E;
}

.loading-photos {
  text-align: center;
  padding: 20px;
  color: #64748b;
  font-size: 13px;
  font-weight: 600;
}

.empty-photos {
  text-align: center;
  padding: 20px;
  color: #94a3b8;
  font-size: 13px;
  font-style: italic;
  background: rgba(11, 93, 30, 0.02);
  border-radius: 8px;
}

.photos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 12px;
}

.photo-card {
  position: relative;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid rgba(11, 93, 30, 0.08);
  aspect-ratio: 1;
}

.photo-card img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.photo-overlay {
  position: absolute;
  inset: 0;
  background: rgba(6, 59, 22, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  opacity: 0;
  transition: 0.2s;
  font-size: 24px;
  text-decoration: none;
}

.photo-card:hover .photo-overlay {
  opacity: 1;
}

/* Audit Stats */
.audit-stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-top: 10px;
}

.stat-box {
  background: rgba(11, 93, 30, 0.03);
  padding: 12px;
  border-radius: 8px;
  text-align: center;
  border: 1px solid rgba(11, 93, 30, 0.08);
}

.stat-box label {
  display: block;
  font-size: 10px;
  font-weight: 700;
  color: #64748b;
  text-transform: uppercase;
  margin-bottom: 5px;
}

.stat-box .val {
  font-size: 18px;
  font-weight: 800;
  color: #063B16;
}

.stat-box.diff-error {
  background: rgba(244, 67, 54, 0.05);
  border-color: rgba(244, 67, 54, 0.2);
}

.stat-box.diff-error .val {
  color: #F44336;
}

/* Modale Carte */
.map-modal-content {
  max-width: 900px !important;
}

.map-modal-body {
  padding: 0 !important;
  height: 65vh;
}

.full-leaflet-map {
  width: 100%;
  height: 100%;
}

:deep(.custom-leaflet-marker) {
  background: transparent;
  border: none;
}

.text-center {
  text-align: center;
  padding: 30px !important;
  color: #64748b;
}

.loading {
  text-align: center;
  padding: 50px;
  font-size: 15px;
  color: #64748b;
  font-weight: 600;
}

/* ==========================================================================
   9. RESPONSIVE
   ========================================================================== */
@media (max-width: 1200px) {
  .main-layout {
    grid-template-columns: 1fr;
  }
  .kpi-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .filters-bar {
    flex-wrap: wrap;
  }
  .search-box {
    flex: 100%;
    min-width: 100%;
  }
}
</style>