<template>
  <div class="inspections-container">

    <div class="header-section">
      <div class="title-row">
        <div>
          <h1>Gestion des Inspections</h1>
          <p class="subtitle">Registre national et contrôle de conformité biologique.</p>
        </div>
        <button class="btn-export">
          <i class="fas fa-download"></i> Exporter pour Audit
        </button>
      </div>

      <div class="kpi-grid" v-if="!isLoading">
        <div class="kpi-card kpi-blue">
          <span class="kpi-label">INSPECTIONS (TOTAL)</span>
          <div class="kpi-value-row">
            <span class="kpi-value">{{ inspections.length }}</span>
          </div>
          <div class="kpi-bar-bg"><div class="kpi-bar" style="width: 100%"></div></div>
        </div>

        <div class="kpi-card kpi-red">
          <span class="kpi-label">TAUX DE FRAUDE</span>
          <div class="kpi-value-row">
            <span class="kpi-value">{{ fraudRate }}%</span>
            <span class="kpi-trend red" v-if="fraudRate > 0">Attention</span>
          </div>
          <div class="kpi-bar-bg"><div class="kpi-bar" :style="{ width: fraudRate + '%' }"></div></div>
        </div>

        <div class="kpi-card kpi-gray">
          <span class="kpi-label">ENQUÊTES EN COURS</span>
          <div class="kpi-value-row">
            <span class="kpi-value">{{ investigationsCount }}</span>
          </div>
          <div class="kpi-bar-bg"><div class="kpi-bar" style="width: 45%"></div></div>
        </div>

        <div class="kpi-card kpi-green">
          <span class="kpi-label">SCORE DE CONFORMITÉ</span>
          <div class="kpi-value-row">
            <span class="kpi-value">{{ complianceScore }}%</span>
            <span class="kpi-trend green">Calculé</span>
          </div>
          <div class="kpi-bar-bg"><div class="kpi-bar" :style="{ width: complianceScore + '%' }"></div></div>
        </div>
      </div>
    </div>

    <div class="filters-bar">
      <div class="search-box">
        <i class="fas fa-search"></i>
        <input type="text" v-model="searchQuery" placeholder="Rechercher un inspecteur ou une ferme...">
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
        </table>

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

// --- 🟢 LOGIQUE LEAFLET AVEC FARMDATAS ---
const mappedFrauds = computed(() => {
  return inspections.value.filter(i => {
    if (i.result !== 'FraudDetected') return false;

    // On vérifie que l'inspection est liée à une ferme connue
    const farm = i.farmId ? farmsDict.value[i.farmId] : null;

    // On vérifie que la ferme possède des coordonnées
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
    // On récupère la ferme associée
    const farm = farmsDict.value[fraude.farmId];
    const lat = farm.latitudeCoordinate || farm.latitude;
    const lng = farm.longitudeCoordinate || farm.longitude;

    const marker = L.marker([lat, lng], { icon: redMarkerIcon }).addTo(markersLayer);
    marker.bindPopup(`
      <div style="text-align:center;">
        <strong style="color:#e11d48; font-size:14px;">FRAUDE DÉTECTÉE</strong><br>
        <b>${getTargetName(fraude)}</b><br>
        <span style="font-size:12px; color:#64748b;">${translateFraudType(fraude.fraudType)}</span>
      </div>
    `);
    marker.on('click', () => { openDetailsModal(fraude); });
  });
};

// --- LOGIQUE DES IMAGES ---
const fetchInspectionImages = async () => {
  if (!selectedInspection.value) return;

  isLoadingImages.value = true;
  try {
    const response = await api.get(`/inspections/${selectedInspection.value.id}/images`);
    inspectionImages.value = response.data;
    imagesLoaded.value = true;
  } catch (error) {
    console.error("Erreur récupération images :", error);
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


// --- HELPERS ---

// 🟢 Fonction pour récupérer les coordonnées GPS via la ferme
const getInspectionCoordinates = (insp) => {
  if (!insp || !insp.farmId) return 'N/A';
  const farm = farmsDict.value[insp.farmId];

  if (farm && (farm.latitudeCoordinate || farm.latitude)) {
    const lat = farm.latitudeCoordinate || farm.latitude;
    const lng = farm.longitudeCoordinate || farm.longitude;
    return `${lat} , ${lng}`;
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
  if (insp.farmId) return `Ferme Inconnue (#${insp.farmId})`;
  if (insp.animalId) return `Bétail Isolé`;
  return insp.locationDescription || 'Contrôle Général';
};

const getTargetRef = (insp) => {
  if (insp.farmId) return `FRM-${insp.farmId}`;
  if (insp.animalId) return `ANI-${insp.animalId}`;
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

watch([searchQuery, filterResult, filterStatus, sortDateOrder], () => { currentPage.value = 1; });

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

const investigationsCount = computed(() => {
  return inspections.value.filter(i => i.status === 'UnderInvestigation').length;
});

const complianceScore = computed(() => {
  if (inspections.value.length === 0) return 100;
  const compliant = inspections.value.filter(i => i.result === 'Compliant').length;
  return ((compliant / inspections.value.length) * 100).toFixed(1);
});

const formatDate = (dateString) => {
  if (!dateString) return '--';
  return new Date(dateString).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' });
};

const formatTime = (dateString) => {
  if (!dateString) return '';
  return new Date(dateString).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });
};

const translateResult = (res) => {
  const map = { 'Compliant': 'Conforme', 'MinorAnomaly': 'Anomalie Mineure', 'FraudDetected': 'Fraude Détectée' };
  return map[res] || res || 'Inconnu';
};

const getResultClass = (res) => {
  const map = { 'Compliant': 'bg-green text-green-dark', 'MinorAnomaly': 'bg-orange text-orange-dark', 'FraudDetected': 'bg-red text-red-dark' };
  return map[res] || 'bg-gray text-gray-dark';
};

const translateStatus = (status) => {
  const map = { 'Closed': 'Clôturé', 'Pending': 'En attente', 'UnderInvestigation': 'Investigation', 'Resolved': 'Résolu', 'Rejected': 'Rejeté' };
  return map[status] || status || 'N/A';
};

const translateFraudType = (type) => {
  const map = { 'None': 'Aucune', 'Theft': 'Vol / Disparition', 'TagTampering': 'Falsification de Boucle', 'IllegalMovement': 'Mouvement Illégal', 'FakeVaccination': 'Fausse Vaccination', 'Other': 'Autre' };
  return map[type] || type || 'N/A';
};

const getStatusClass = (status) => {
  if (status === 'UnderInvestigation') return 'bg-navy text-white';
  if (status === 'Closed' || status === 'Resolved') return 'bg-gray-light text-gray-dark border-gray';
  if (status === 'Pending') return 'bg-gray-light text-gray-dark border-gray';
  return 'bg-gray text-gray-dark';
};

const getRowClass = (result) => { return result === 'FraudDetected' ? 'row-danger' : ''; };
</script>

<style scoped>
/* BASE */
.inspections-container { font-family: 'Inter', sans-serif; background-color: #f4f7f6; min-height: 100vh; padding: 40px; color: #1e293b; }

/* HEADER & KPIs */
.header-section { margin-bottom: 30px; }
.title-row { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 25px; }
.title-row h1 { font-size: 28px; font-weight: 900; margin: 0; color: #0f172a; letter-spacing: -0.5px; }
.subtitle { color: #64748b; font-size: 15px; margin-top: 6px; }
.btn-export { background: white; border: 1px solid #cbd5e1; padding: 10px 20px; border-radius: 8px; font-weight: 600; color: #334155; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
.btn-export:hover { background: #f8fafc; border-color: #94a3b8; }
.kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
.kpi-card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); border-left: 4px solid transparent; }
.kpi-blue { border-left-color: #1e3a8a; } .kpi-red { border-left-color: #e11d48; } .kpi-gray { border-left-color: #475569; } .kpi-green { border-left-color: #15803d; }
.kpi-label { font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; }
.kpi-value-row { display: flex; align-items: baseline; gap: 10px; margin: 10px 0; }
.kpi-value { font-size: 28px; font-weight: 800; color: #0f172a; }
.kpi-trend { font-size: 12px; font-weight: 700; }
.kpi-trend.green { color: #15803d; } .kpi-trend.red { color: #e11d48; }
.kpi-bar-bg { height: 4px; background: #f1f5f9; border-radius: 2px; overflow: hidden; }
.kpi-bar { height: 100%; border-radius: 2px; }
.kpi-blue .kpi-bar { background: #1e3a8a; } .kpi-red .kpi-bar { background: #e11d48; } .kpi-gray .kpi-bar { background: #475569; } .kpi-green .kpi-bar { background: #15803d; }

/* FILTRES */
.filters-bar { display: flex; gap: 20px; background: #f8fafc; padding: 15px 20px; border-radius: 12px; margin-bottom: 25px; border: 1px solid #e2e8f0; align-items: flex-end;}
.search-box { flex: 2; position: relative; }
.search-box i { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #94a3b8; }
.search-box input { width: 100%; padding: 12px 15px 12px 40px; border: 1px solid #cbd5e1; border-radius: 8px; outline: none; background: white; font-size: 14px; font-family: inherit;}
.search-box input:focus { border-color: #1e3a8a; }
.filter-group { display: flex; flex-direction: column; gap: 6px; flex: 1; }
.filter-group label { font-size: 10px; font-weight: 700; color: #64748b; text-transform: uppercase; }
.filter-group select { padding: 11px; border: 1px solid #cbd5e1; border-radius: 8px; outline: none; background: white; font-weight: 600; color: #334155; font-size: 13px;}

/* MAIN LAYOUT */
.main-layout { display: grid; grid-template-columns: 1fr 300px; gap: 25px; }

/* TABLE REGISTRY */
.registry-card { background: white; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); overflow: hidden; display: flex; flex-direction: column; justify-content: space-between;}
.registry-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 25px; border-bottom: 1px solid #f1f5f9; }
.registry-header h2 { margin: 0; font-size: 18px; font-weight: 800; color: #0f172a; }
.last-update { font-size: 12px; color: #94a3b8; font-weight: 500; background: #f1f5f9; padding: 4px 10px; border-radius: 20px; }
.registry-table { width: 100%; border-collapse: collapse; }
.registry-table th { text-align: left; padding: 15px 25px; font-size: 11px; font-weight: 800; color: #64748b; text-transform: uppercase; border-bottom: 1px solid #f1f5f9; }
.registry-table td { padding: 15px 25px; border-bottom: 1px solid #f8fafc; vertical-align: middle; }

/* PAGINATION */
.pagination { display: flex; justify-content: space-between; align-items: center; padding: 15px 25px; background: #fafafa; border-top: 1px solid #f1f5f9; color: #64748b; font-size: 13px; font-weight: 500;}
.page-controls { display: flex; align-items: center; gap: 10px; }
.page-controls button { width: 32px; height: 32px; border: 1px solid #cbd5e1; background: white; border-radius: 6px; cursor: pointer; color: #334155; display: flex; align-items: center; justify-content: center; transition: 0.2s;}
.page-controls button:hover:not(:disabled) { background: #f1f5f9; }
.page-controls button:disabled { opacity: 0.5; cursor: not-allowed; }
.page-num { font-weight: 700; color: #0f172a; }

.row-danger { background-color: #fffafb; }
.insp-id { font-weight: 800; color: #1e3a8a; font-size: 14px; }
.inspector-info, .target-info, .date-info { display: flex; flex-direction: column; gap: 2px; }
.name, .target-name { font-weight: 700; color: #0f172a; font-size: 14px; }
.badge-id, .target-ref { font-size: 12px; color: #64748b; }
.date { font-weight: 600; color: #334155; font-size: 14px; }
.time { font-size: 12px; color: #94a3b8; }

.badge-result, .badge-status { padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; display: inline-block; text-align: center; }
.bg-green { background: #dcfce3; } .text-green-dark { color: #166534; }
.bg-red { background: #fee2e2; } .text-red-dark { color: #991b1b; }
.bg-orange { background: #ffedd5; } .text-orange-dark { color: #c2410c; }
.bg-navy { background: #1e3a8a; } .text-white { color: white; }
.bg-gray-light { background: #f1f5f9; } .border-gray { border: 1px solid #cbd5e1; } .text-gray-dark { color: #475569; }
.btn-view { background: #f1f5f9; border: 1px solid transparent; color: #1e3a8a; width: 32px; height: 32px; border-radius: 6px; cursor: pointer; transition: 0.2s; display: flex; align-items: center; justify-content: center;}
.btn-view:hover { background: #e2e8f0; border-color: #cbd5e1; }

/* WIDGET DÉCLENCHEUR DE CARTE (SIDEBAR) */
.sidebar { display: flex; flex-direction: column; }
.map-trigger-card {
  background-image: url('https://images.unsplash.com/photo-1524661135-423995f22d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80');
  background-size: cover;
  background-position: center;
  border-radius: 16px;
  overflow: hidden;
  height: 250px;
  position: relative;
  cursor: pointer;
  box-shadow: 0 4px 15px rgba(0,0,0,0.05);
  transition: transform 0.2s, box-shadow 0.2s;
  border: 4px solid #22c55e;
}
.map-trigger-card:hover { transform: translateY(-3px); box-shadow: 0 10px 25px rgba(0,0,0,0.15); }
.card-overlay {
  position: absolute; inset: 0;
  background: linear-gradient(to top, rgba(15, 23, 42, 0.95), rgba(15, 23, 42, 0.4));
  padding: 25px; display: flex; flex-direction: column; justify-content: flex-end; color: white;
}
.pulse-indicator-small { font-size: 11px; font-weight: 700; color: #fca5a5; text-transform: uppercase; display: flex; align-items: center; gap: 6px; margin-bottom: 8px;}
.pulse-indicator-small .dot { width: 8px; height: 8px; background: #ef4444; border-radius: 50%; display: inline-block; animation: blink 1s infinite; }
@keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } }
.card-overlay h3 { margin: 0 0 5px 0; font-size: 20px; font-weight: 800; text-shadow: 0 2px 4px rgba(0,0,0,0.5);}
.card-overlay p { margin: 0; font-size: 13px; color: #cbd5e1; display: flex; align-items: center; gap: 6px;}

/* MODALES (Communes) */
.modal-overlay { position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6); display: flex; justify-content: center; align-items: center; z-index: 9999; backdrop-filter: blur(4px); }
.modal-content { background: white; width: 100%; max-width: 650px; border-radius: 16px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); animation: slideUp 0.3s ease-out; }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 25px; border-bottom: 1px solid #f1f5f9; background: #f8fafc; }
.modal-header h2 { margin: 0; font-size: 18px; font-weight: 800; color: #0f172a; }
.btn-close { background: transparent; border: none; font-size: 20px; color: #94a3b8; cursor: pointer; transition: 0.2s; }
.btn-close:hover { color: #e11d48; }

/* MODALE DETAILS */
.modal-body { padding: 25px; display: flex; flex-direction: column; gap: 20px; max-height: 70vh; overflow-y: auto;}
.info-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.modal-section { border: 1px solid #e2e8f0; border-radius: 12px; padding: 15px; }
.bg-light-gray { background: #f8fafc; border: none; }
.modal-section h4 { margin: 0 0 15px 0; font-size: 14px; font-weight: 800; color: #1e3a8a; display: flex; align-items: center; gap: 8px;}
.modal-section p { margin: 0 0 8px 0; font-size: 13px; color: #475569; }
.modal-section p strong { color: #0f172a; }
.info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; font-size: 13px; color: #475569;}
.info-grid strong { color: #0f172a; display: block; margin-bottom: 4px;}
.notes-section { background: #fffbeb; border-color: #fde68a; }
.notes-section h4 { color: #b45309; }
.notes-text { font-style: italic; color: #92400e !important; line-height: 1.5;}

/* CSS GALERIE PHOTOS */
.photos-section { border: none; background: white; padding: 0; margin-top: 10px; }
.photos-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 15px; }
.photos-header h4 { margin: 0; color: #0f172a;}
.btn-load-photos { background: #f8fafc; border: 1px solid #cbd5e1; color: #1e3a8a; font-weight: 600; padding: 8px 15px; border-radius: 6px; cursor: pointer; transition: 0.2s; font-size: 12px;}
.btn-load-photos:hover { background: #e0f2fe; border-color: #7dd3fc; color: #0369a1; }
.loading-photos { text-align: center; padding: 20px; color: #64748b; font-size: 13px; font-weight: 600; }
.empty-photos { text-align: center; padding: 20px; color: #94a3b8; font-size: 13px; font-style: italic; background: #f8fafc; border-radius: 8px;}
.photos-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 12px; }
.photo-card { position: relative; border-radius: 8px; overflow: hidden; border: 1px solid #e2e8f0; aspect-ratio: 1; }
.photo-card img { width: 100%; height: 100%; object-fit: cover; display: block; }
.photo-overlay { position: absolute; inset: 0; background: rgba(15, 23, 42, 0.4); display: flex; align-items: center; justify-content: center; color: white; opacity: 0; transition: 0.2s; font-size: 24px; text-decoration: none;}
.photo-card:hover .photo-overlay { opacity: 1; }

/* MODALE CARTE LEAFLET */
.map-modal-content { max-width: 900px !important; }
.map-modal-body { padding: 0 !important; height: 65vh; }
.full-leaflet-map { width: 100%; height: 100%; }
:deep(.custom-leaflet-marker) { background: transparent; border: none; }

.text-center { text-align: center; padding: 30px !important; color: #64748b; }
.loading { text-align: center; padding: 50px; font-size: 15px; color: #64748b; font-weight: 600; }

@media (max-width: 1200px) {
  .main-layout { grid-template-columns: 1fr; }
  .kpi-grid { grid-template-columns: repeat(2, 1fr); }
  .filters-bar { flex-wrap: wrap; }
  .search-box { flex: 100%; }
}
</style>