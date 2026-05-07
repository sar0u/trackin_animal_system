<template>
  <div class="constats-container">

    <div class="header-section">
      <div class="title-row">
        <div>
          <h1>Gestion des Constats</h1>
          <p class="subtitle">Registre national des constats terrain et contrôle de conformité.</p>
        </div>
        <button class="btn-export" @click="exportConstatsToCsv">
          <i class="fas fa-download"></i> Exporter pour Audit
        </button>
      </div>

      <div class="kpi-grid" v-if="!isLoading">
        <div class="kpi-card kpi-blue">
          <span class="kpi-label">CONSTATS (TOTAL)</span>
          <div class="kpi-value-row">
            <span class="kpi-value">{{ constats.length }}</span>
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
        <input type="text" v-model="searchQuery" placeholder="Rechercher par ID, contrôleur ou ferme...">
      </div>
      <div class="filter-group">
        <label>TYPE</label>
        <select v-model="filterType">
          <option value="">Tous les types</option>
          <option value="FRAUDE">Fraude</option>
          <option value="MANQUANT">Manquant</option>
          <option value="DOUBLON">Doublon</option>
          <option value="AUTRE">Autre</option>
        </select>
      </div>
      <div class="filter-group">
        <label>STATUT</label>
        <select v-model="filterStatus">
          <option value="">Tous les statuts</option>
          <option value="PENDING">En attente</option>
          <option value="IN_REVIEW">Investigation</option>
          <option value="RESOLVED">Résolu</option>
          <option value="REJECTED">Rejeté</option>
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
          <h2>Registre National des Constats</h2>
          <span class="last-update">{{ filteredConstats.length }} résultat(s)</span>
        </div>

        <table class="registry-table">
          <thead>
          <tr>
            <th>ID</th>
            <th>CONTRÔLEUR</th>
            <th>FERME</th>
            <th>TYPE</th>
            <th>DATE</th>
            <th>STATUT</th>
            <th>DÉTAILS</th>
          </tr>
          </thead>
          <tbody>
          <tr v-if="paginatedConstats.length === 0">
            <td colspan="7" class="text-center">Aucun constat ne correspond à votre recherche.</td>
          </tr>
          <tr v-for="constat in paginatedConstats" :key="constat.id" :class="getRowClass(constat.type)">
            <td class="insp-id">#CST-{{ constat.id }}</td>
            <td>
              <div class="inspector-info">
                <span class="name">{{ getControleurName(constat) }}</span>
                <span class="badge-id" v-if="constat.controlSession?.controller?.id">Agent #{{ constat.controlSession.controller.id }}</span>
              </div>
            </td>
            <td>
              <div class="target-info">
                <span class="target-name">{{ constat.controlSession?.farm?.name || '—' }}</span>
                <span class="target-ref" v-if="constat.controlSession?.farm?.id">#FRM-{{ constat.controlSession.farm.id }}</span>
              </div>
            </td>
            <td>
              <span class="badge-result" :class="getTypeClass(constat.type)">{{ translateType(constat.type) }}</span>
            </td>
            <td>
              <div class="date-info">
                <span class="date">{{ formatDate(constat.createdAt) }}</span>
                <span class="time">{{ formatTime(constat.createdAt) }}</span>
              </div>
            </td>
            <td>
              <span class="badge-status" :class="getStatusClass(constat.status)">{{ translateStatus(constat.status) }}</span>
            </td>
            <td>
              <button class="btn-view" title="Voir les détails" @click="openDetailsModal(constat)">
                <i class="fas fa-eye"></i>
              </button>
            </td>
          </tr>
          </tbody>
        </table>

        <div class="pagination">
          <span>Affichage {{ filteredConstats.length > 0 ? (currentPage - 1) * itemsPerPage + 1 : 0 }} - {{ Math.min(currentPage * itemsPerPage, filteredConstats.length) }} sur {{ filteredConstats.length }}</span>
          <div class="page-controls">
            <button :disabled="currentPage === 1" @click="currentPage--"><i class="fas fa-chevron-left"></i></button>
            <span class="page-num">{{ currentPage }} / {{ totalPages || 1 }}</span>
            <button :disabled="currentPage === totalPages || totalPages === 0" @click="currentPage++"><i class="fas fa-chevron-right"></i></button>
          </div>
        </div>
      </div>

      <div class="map-section">
        <div class="map-trigger-card" @click="openMapModal">
          <div class="card-overlay">
            <div class="pulse-indicator-small"><span class="dot"></span> {{ mappedConstats.length }} Constats géolocalisés</div>
            <h3>Cartographie des Constats</h3>
            <p>Cliquez pour ouvrir la carte <i class="fas fa-external-link-alt"></i></p>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showMapModal" class="modal-overlay" @click.self="closeMapModal">
      <div class="modal-content map-modal-content">
        <div class="modal-header">
          <h2>Carte des Constats Géolocalisés</h2>
          <button class="btn-close" @click="closeMapModal"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body map-modal-body">
          <div id="leaflet-map-fraud" class="full-leaflet-map"></div>
        </div>
      </div>
    </div>

    <div v-if="showDetailsModal && selectedConstat" class="modal-overlay" @click.self="closeDetailsModal">
      <div class="modal-content modal-content-wide">
        <div class="modal-header">
          <h2>Détails du Constat <span class="modal-id">#CST-{{ selectedConstat.id }}</span></h2>
          <button class="btn-close" @click="closeDetailsModal"><i class="fas fa-times"></i></button>
        </div>

        <div class="modal-body">

          <!-- Bandeau statut -->
          <div class="status-banner" :class="'banner-' + (selectedConstat.status || '').toLowerCase()">
            <span class="badge-result" :class="getTypeClass(selectedConstat.type)">{{ translateType(selectedConstat.type) }}</span>
            <i class="fas fa-arrow-right banner-arrow"></i>
            <span class="badge-status" :class="getStatusClass(selectedConstat.status)">{{ translateStatus(selectedConstat.status) }}</span>
            <span class="banner-dates">
              <span><i class="far fa-clock"></i> Créé le {{ formatDate(selectedConstat.createdAt) }} à {{ formatTime(selectedConstat.createdAt) }}</span>
              <span v-if="selectedConstat.resolvedAt"><i class="fas fa-check"></i> Résolu le {{ formatDate(selectedConstat.resolvedAt) }}</span>
            </span>
          </div>

          <!-- Description -->
          <div class="modal-section" v-if="selectedConstat.description">
            <h4><i class="fas fa-file-alt"></i> Description du constat</h4>
            <p class="notes-text">{{ selectedConstat.description }}</p>
          </div>

          <!-- Grille : Agent + Session -->
          <div class="info-row">
            <div class="modal-section">
              <h4><i class="fas fa-user-shield"></i> Agent Contrôleur</h4>
              <div class="detail-list">
                <div class="detail-item">
                  <span class="detail-label">Nom complet</span>
                  <span class="detail-value">{{ getControleurName(selectedConstat) }}</span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession?.controller?.id">
                  <span class="detail-label">ID Agent</span>
                  <span class="detail-value mono">#AGT-{{ selectedConstat.controlSession.controller.id }}</span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession?.controller?.role">
                  <span class="detail-label">Rôle</span>
                  <span class="detail-value">{{ translateRole(selectedConstat.controlSession.controller.role) }}</span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession?.controller?.email">
                  <span class="detail-label">Email</span>
                  <span class="detail-value">{{ selectedConstat.controlSession.controller.email }}</span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession?.controller?.phone">
                  <span class="detail-label">Téléphone</span>
                  <span class="detail-value">{{ selectedConstat.controlSession.controller.phone }}</span>
                </div>
              </div>
            </div>

            <div class="modal-section">
              <h4><i class="fas fa-clipboard-list"></i> Session de Contrôle</h4>
              <div class="detail-list">
                <div class="detail-item" v-if="selectedConstat.controlSession?.id">
                  <span class="detail-label">Référence</span>
                  <span class="detail-value mono">#SES-{{ selectedConstat.controlSession.id }}</span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession?.result">
                  <span class="detail-label">Résultat</span>
                  <span class="detail-value">
                    <span class="badge-result" :class="selectedConstat.controlSession.result === 'CONFORME' ? 'badge-green' : selectedConstat.controlSession.result === 'NON_CONFORME' ? 'badge-red' : 'badge-yellow'">
                      {{ selectedConstat.controlSession.result }}
                    </span>
                  </span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession?.startedAt">
                  <span class="detail-label">Début</span>
                  <span class="detail-value">{{ formatDate(selectedConstat.controlSession.startedAt) }} {{ formatTime(selectedConstat.controlSession.startedAt) }}</span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession?.endedAt">
                  <span class="detail-label">Fin</span>
                  <span class="detail-value">{{ formatDate(selectedConstat.controlSession.endedAt) }} {{ formatTime(selectedConstat.controlSession.endedAt) }}</span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession?.expectedCount != null">
                  <span class="detail-label">Animaux attendus</span>
                  <span class="detail-value">{{ selectedConstat.controlSession.expectedCount }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Ferme -->
          <div class="modal-section" v-if="selectedConstat.controlSession?.farm">
            <h4><i class="fas fa-warehouse"></i> Ferme Inspectée</h4>
            <div class="farm-detail-grid">
              <div class="detail-list">
                <div class="detail-item">
                  <span class="detail-label">Nom</span>
                  <span class="detail-value"><strong>{{ selectedConstat.controlSession.farm.name }}</strong></span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession.farm.id">
                  <span class="detail-label">Référence</span>
                  <span class="detail-value mono">#FRM-{{ selectedConstat.controlSession.farm.id }}</span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession.farm.location">
                  <span class="detail-label">Adresse</span>
                  <span class="detail-value">{{ selectedConstat.controlSession.farm.location }}</span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession.farm.status">
                  <span class="detail-label">Statut</span>
                  <span class="detail-value">
                    <span class="badge-status" :class="selectedConstat.controlSession.farm.status === 'Active' ? 'badge-green' : selectedConstat.controlSession.farm.status === 'Suspended' ? 'badge-yellow' : 'badge-red'">
                      {{ translateFarmStatus(selectedConstat.controlSession.farm.status) }}
                    </span>
                  </span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession.farm.capacity">
                  <span class="detail-label">Capacité</span>
                  <span class="detail-value">{{ selectedConstat.controlSession.farm.capacity }} animaux</span>
                </div>
                <div class="detail-item" v-if="selectedConstat.controlSession.farm.isVerified != null">
                  <span class="detail-label">Vérifiée</span>
                  <span class="detail-value">
                    <span :class="selectedConstat.controlSession.farm.isVerified ? 'text-green' : 'text-orange'">
                      <i :class="selectedConstat.controlSession.farm.isVerified ? 'fas fa-check-circle' : 'fas fa-exclamation-circle'"></i>
                      {{ selectedConstat.controlSession.farm.isVerified ? 'Oui' : 'Non' }}
                    </span>
                  </span>
                </div>
              </div>
              <div class="gps-box" v-if="selectedConstat.controlSession.farm.latitude != null">
                <i class="fas fa-map-marker-alt gps-icon"></i>
                <div class="gps-coords">
                  <span class="gps-label">GPS</span>
                  <span class="gps-value">{{ selectedConstat.controlSession.farm.latitude }}, {{ selectedConstat.controlSession.farm.longitude }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Images -->
          <div class="modal-section" v-if="selectedConstat.images && selectedConstat.images.length">
            <h4><i class="fas fa-images"></i> Photos du constat ({{ selectedConstat.images.length }})</h4>
            <div class="images-grid">
              <a v-for="img in selectedConstat.images" :key="img.id" :href="img.imageUrl" target="_blank" class="image-thumb">
                <img :src="img.imageUrl" :alt="'Photo constat'" @error="$event.target.style.display='none'" />
                <span class="image-fallback"><i class="fas fa-image"></i></span>
              </a>
            </div>
          </div>

          <!-- Actions -->
          <div class="modal-section action-section">
            <h4><i class="fas fa-cogs"></i> Modifier le Statut</h4>
            <div class="action-buttons">
              <button v-if="selectedConstat.status === 'PENDING'" class="btn-action btn-investigate" @click="updateConstatStatus('IN_REVIEW')">
                <i class="fas fa-search"></i> Mettre en investigation
              </button>
              <button v-if="selectedConstat.status === 'IN_REVIEW'" class="btn-action btn-resolve" @click="updateConstatStatus('RESOLVED')">
                <i class="fas fa-check-circle"></i> Marquer résolu
              </button>
              <button v-if="['PENDING','IN_REVIEW'].includes(selectedConstat.status)" class="btn-action btn-reject" @click="updateConstatStatus('REJECTED')">
                <i class="fas fa-times-circle"></i> Rejeter
              </button>
              <span v-if="['RESOLVED','REJECTED'].includes(selectedConstat.status)" class="status-final">
                <i class="fas fa-lock"></i> Statut final — aucune action disponible
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, computed, nextTick } from 'vue';
import api from '../services/api';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

const constats = ref([]);
const isLoading = ref(true);

const searchQuery = ref('');
const filterType = ref('');
const filterStatus = ref('');
const sortDateOrder = ref('desc');

const currentPage = ref(1);
const itemsPerPage = 20;

const showDetailsModal = ref(false);
const selectedConstat = ref(null);
const showMapModal = ref(false);

let map = null;
let markersLayer = null;

const fetchAllData = async () => {
  try {
    isLoading.value = true;
    const res = await api.get('/constats');
    constats.value = Array.isArray(res.data) ? res.data : [];
  } catch (error) {
    console.error('Erreur API Constats:', error);
    constats.value = [];
  } finally {
    isLoading.value = false;
  }
};

onMounted(fetchAllData);

const mappedConstats = computed(() =>
  constats.value.filter(c =>
    c.controlSession?.farm?.latitude != null && c.controlSession?.farm?.longitude != null
  )
);

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
  const markerIcon = L.divIcon({
    className: 'custom-leaflet-marker',
    html: `<div style="background-color:#e11d48;width:16px;height:16px;border-radius:50%;border:3px solid white;box-shadow:0 0 10px rgba(0,0,0,0.5);"></div>`,
    iconSize: [20, 20], iconAnchor: [10, 10], popupAnchor: [0, -10]
  });
  mappedConstats.value.forEach(constat => {
    const marker = L.marker([constat.controlSession.farm.latitude, constat.controlSession.farm.longitude], { icon: markerIcon }).addTo(markersLayer);
    marker.bindPopup(`<b>${constat.controlSession?.farm?.name || 'N/A'}</b><br>${translateType(constat.type)}`);
    marker.on('click', () => { openDetailsModal(constat); });
  });
};

const openDetailsModal = (constat) => {
  selectedConstat.value = constat;
  showDetailsModal.value = true;
};

const closeDetailsModal = () => {
  showDetailsModal.value = false;
  selectedConstat.value = null;
};

const getControleurName = (constat) => {
  const u = constat.controlSession?.controller;
  if (!u) return '—';
  return `${u.firstName || ''} ${u.lastName || ''}`.trim() || u.username || `Agent #${u.id}`;
};

const filteredConstats = computed(() => {
  let filtered = constats.value.filter(c => {
    const q = searchQuery.value.toLowerCase();
    const controleurStr = getControleurName(c).toLowerCase();
    const farmStr = (c.controlSession?.farm?.name || '').toLowerCase();
    const matchesSearch = !q || controleurStr.includes(q) || farmStr.includes(q) || String(c.id).includes(q);
    const matchType = !filterType.value || c.type === filterType.value;
    const matchStatus = !filterStatus.value || c.status === filterStatus.value;
    return matchesSearch && matchType && matchStatus;
  });
  filtered.sort((a, b) => {
    const dateA = new Date(a.createdAt).getTime();
    const dateB = new Date(b.createdAt).getTime();
    return sortDateOrder.value === 'desc' ? dateB - dateA : dateA - dateB;
  });
  return filtered;
});

const totalPages = computed(() => Math.ceil(filteredConstats.value.length / itemsPerPage));
const paginatedConstats = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredConstats.value.slice(start, start + itemsPerPage);
});

const fraudRate = computed(() => {
  if (!constats.value.length) return 0;
  const frauds = constats.value.filter(c => c.type === 'FRAUDE').length;
  return ((frauds / constats.value.length) * 100).toFixed(1);
});

const investigationsCount = computed(() =>
  constats.value.filter(c => c.status === 'IN_REVIEW').length
);

const complianceScore = computed(() => {
  if (!constats.value.length) return 100;
  const resolved = constats.value.filter(c => c.status === 'RESOLVED').length;
  return ((resolved / constats.value.length) * 100).toFixed(1);
});

const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : '--';
const formatTime = (d) => d ? new Date(d).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }) : '';

const translateType = (type) => {
  const map = { 'FRAUDE': 'Fraude', 'MANQUANT': 'Manquant', 'DOUBLON': 'Doublon', 'AUTRE': 'Autre' };
  return map[type] || type || 'N/A';
};

const getTypeClass = (type) => {
  const map = { 'FRAUDE': 'badge-red', 'MANQUANT': 'badge-orange', 'DOUBLON': 'badge-navy', 'AUTRE': 'badge-gray' };
  return map[type] || 'badge-gray';
};

const translateStatus = (status) => {
  const map = { 'PENDING': 'En attente', 'IN_REVIEW': 'Investigation', 'RESOLVED': 'Résolu', 'REJECTED': 'Rejeté' };
  return map[status] || status;
};

const translateFarmStatus = (status) => {
  const map = { 'Active': 'Opérationnelle', 'Suspended': 'Suspendue', 'Closed': 'Fermée' };
  return map[status] || status;
};

const translateRole = (role) => {
  const map = { 'Administrator': 'Admin', 'Farmer': 'Éleveur', 'Inspector': 'Inspecteur', 'Veterinarian': 'Vétérinaire' };
  return map[role] || role;
};

const getStatusClass = (status) => {
  const map = { 'IN_REVIEW': 'badge-blue', 'RESOLVED': 'badge-green', 'PENDING': 'badge-yellow', 'REJECTED': 'badge-red' };
  return map[status] || 'badge-gray';
};

const getRowClass = (type) => (type === 'FRAUDE' ? 'row-danger' : '');

const updateConstatStatus = async (newStatus) => {
  if (!selectedConstat.value) return;

  const statusLabels = {
    'PENDING': 'En attente',
    'IN_REVIEW': 'Investigation',
    'RESOLVED': 'Résolu',
    'REJECTED': 'Rejeté'
  };

  let message = '';
  if (newStatus === 'RESOLVED') {
    message = `Classer ce constat comme résolu est irréversible.\nLe dossier sera fermé et archivé.\n\nConfirmer ?`;
  } else if (newStatus === 'REJECTED') {
    message = `Rejeter ce constat est irréversible.\nLe dossier sera fermé.\n\nConfirmer ?`;
  } else {
    message = `Êtes-vous sûr de vouloir passer ce constat à "${statusLabels[newStatus]}" ?`;
  }

  if (!confirm(message)) return;

  try {
    await api.put(`/constats/${selectedConstat.value.id}/status`, { status: newStatus });
    selectedConstat.value = {
      ...selectedConstat.value,
      status: newStatus,
      resolvedAt: newStatus === 'RESOLVED' ? new Date().toISOString() : selectedConstat.value.resolvedAt
    };
    await fetchAllData();
  } catch (error) {
    console.error('Erreur mise à jour statut:', error);
    alert('Erreur lors de la mise à jour du statut.');
  }
};

const exportConstatsToCsv = () => {
  if (!filteredConstats.value.length) {
    alert('Aucun constat à exporter.');
    return;
  }

  const headers = ['ID', 'Type', 'Statut', 'Date Création', 'Ferme', 'Contrôleur', 'Résultat Contrôle', 'Statut Ferme'];
  const rows = filteredConstats.value.map(c => [
    c.id,
    translateType(c.type),
    translateStatus(c.status),
    formatDate(c.createdAt),
    c.controlSession?.farm?.name || 'N/A',
    getControleurName(c),
    c.controlSession?.result || 'N/A',
    translateFarmStatus(c.controlSession?.farm?.status) || 'N/A'
  ]);

  const csvContent = [
    headers.join(','),
    ...rows.map(r => r.map(v => `"${v}"`).join(','))
  ].join('\n');

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);
  const timestamp = new Date().toISOString().split('T')[0];
  link.setAttribute('href', url);
  link.setAttribute('download', `constats_audit_${timestamp}.csv`);
  link.style.visibility = 'hidden';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};
</script>

<style scoped>
.constats-container { font-family: 'Inter', sans-serif; background-color: #f4f7f6; min-height: 100vh; padding: 40px; color: #1e293b; }

.header-section { margin-bottom: 30px; }
.title-row { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 25px; }
.title-row h1 { font-size: 28px; font-weight: 900; margin: 0; color: #0f172a; letter-spacing: -0.5px; }
.subtitle { color: #64748b; font-size: 15px; margin-top: 6px; }
.btn-export { background: white; border: 1px solid #cbd5e1; padding: 10px 20px; border-radius: 8px; font-weight: 600; color: #334155; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
.btn-export:hover { background: #f8fafc; border-color: #94a3b8; }

.kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
.kpi-card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); border-left: 4px solid transparent; }
.kpi-blue { border-left-color: #1e3a8a; } .kpi-red { border-left-color: #e11d48; } .kpi-gray { border-left-color: #475569; } .kpi-green { border-left-color: #063B16; }
.kpi-label { font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; }
.kpi-value-row { display: flex; align-items: baseline; gap: 10px; margin: 10px 0; }
.kpi-value { font-size: 28px; font-weight: 800; color: #0f172a; }
.kpi-trend { font-size: 12px; font-weight: 700; }
.kpi-trend.green { color: #063B16; } .kpi-trend.red { color: #e11d48; }
.kpi-bar-bg { height: 4px; background: #f1f5f9; border-radius: 2px; overflow: hidden; }
.kpi-bar { height: 100%; border-radius: 2px; }
.kpi-blue .kpi-bar { background: #1e3a8a; } .kpi-red .kpi-bar { background: #e11d48; } .kpi-gray .kpi-bar { background: #475569; } .kpi-green .kpi-bar { background: #063B16; }

.filters-bar { display: flex; gap: 20px; background: #f8fafc; padding: 15px 20px; border-radius: 12px; margin-bottom: 25px; border: 1px solid #e2e8f0; align-items: flex-end; }
.search-box { flex: 2; position: relative; }
.search-box i { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #94a3b8; }
.search-box input { width: 100%; padding: 12px 15px 12px 40px; border: 1px solid #cbd5e1; border-radius: 8px; outline: none; background: white; font-size: 14px; font-family: inherit; box-sizing: border-box; }
.search-box input:focus { border-color: #1e3a8a; }
.filter-group { display: flex; flex-direction: column; gap: 6px; flex: 1; }
.filter-group label { font-size: 10px; font-weight: 700; color: #64748b; text-transform: uppercase; }
.filter-group select { padding: 11px; border: 1px solid #cbd5e1; border-radius: 8px; outline: none; background: white; font-weight: 600; color: #334155; font-size: 13px; }

.main-layout { display: flex; flex-direction: column; gap: 25px; }

.registry-card { background: white; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); overflow: hidden; }
.registry-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 25px; border-bottom: 1px solid #f1f5f9; }
.registry-header h2 { margin: 0; font-size: 18px; font-weight: 800; color: #0f172a; }
.last-update { font-size: 12px; color: #94a3b8; font-weight: 500; background: #f1f5f9; padding: 4px 10px; border-radius: 20px; }
.registry-table { width: 100%; border-collapse: collapse; }
.registry-table th { text-align: left; padding: 15px 25px; font-size: 11px; font-weight: 800; color: #64748b; text-transform: uppercase; border-bottom: 1px solid #f1f5f9; }
.registry-table td { padding: 15px 25px; border-bottom: 1px solid #f8fafc; vertical-align: middle; }

.pagination { display: flex; justify-content: space-between; align-items: center; padding: 15px 25px; background: #fafafa; border-top: 1px solid #f1f5f9; color: #64748b; font-size: 13px; font-weight: 500; }
.page-controls { display: flex; align-items: center; gap: 10px; }
.page-controls button { width: 32px; height: 32px; border: 1px solid #cbd5e1; background: white; border-radius: 6px; cursor: pointer; color: #334155; display: flex; align-items: center; justify-content: center; transition: 0.2s; }
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
.badge-red { background: #fee2e2; color: #991b1b; }
.badge-orange { background: #ffedd5; color: #c2410c; }
.badge-navy { background: #eff6ff; color: #1e40af; }
.badge-blue { background: #dbeafe; color: #1e40af; }
.badge-green { background: #dcfce3; color: #063B16; }
.badge-yellow { background: #fef9c3; color: #854d0e; }
.badge-gray { background: #f1f5f9; color: #475569; }

.btn-view { background: #f1f5f9; border: 1px solid transparent; color: #1e3a8a; width: 32px; height: 32px; border-radius: 6px; cursor: pointer; transition: 0.2s; display: flex; align-items: center; justify-content: center; }
.btn-view:hover { background: #e2e8f0; border-color: #cbd5e1; }

.map-section { width: 100%; }
.map-trigger-card {
  background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%);
  border-radius: 16px;
  overflow: hidden;
  height: 160px;
  position: relative;
  cursor: pointer;
  border: 4px solid #0B5D1E;
  will-change: opacity;
  transition: opacity 0.2s;
}
.map-trigger-card:hover { opacity: 0.92; }
.card-overlay { position: absolute; inset: 0; padding: 25px; display: flex; flex-direction: column; justify-content: flex-end; color: white; }
.pulse-indicator-small { font-size: 11px; font-weight: 700; color: #fca5a5; text-transform: uppercase; display: flex; align-items: center; gap: 6px; margin-bottom: 8px; }
.pulse-indicator-small .dot { width: 8px; height: 8px; background: #ef4444; border-radius: 50%; display: inline-block; }
@keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } }
.card-overlay h3 { margin: 0 0 5px 0; font-size: 20px; font-weight: 800; text-shadow: 0 2px 4px rgba(0,0,0,0.5); }
.card-overlay p { margin: 0; font-size: 13px; color: #cbd5e1; display: flex; align-items: center; gap: 6px; }

.modal-overlay { position: fixed; inset: 0; background: rgba(15, 23, 42, 0.65); display: flex; justify-content: center; align-items: center; z-index: 9999; }
.modal-content { background: white; width: 100%; max-width: 650px; border-radius: 16px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25); animation: slideUp 0.3s ease-out; }
.modal-content-wide { max-width: 820px !important; }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 25px; border-bottom: 1px solid #f1f5f9; background: #f8fafc; }
.modal-header h2 { margin: 0; font-size: 18px; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 10px; }
.modal-id { color: #1e3a8a; font-size: 15px; background: #eff6ff; padding: 2px 10px; border-radius: 20px; }
.btn-close { background: transparent; border: none; font-size: 20px; color: #94a3b8; cursor: pointer; transition: 0.2s; }
.btn-close:hover { color: #e11d48; }

.modal-body { padding: 25px; display: flex; flex-direction: column; gap: 18px; max-height: 78vh; overflow-y: auto; }
.info-row { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
.modal-section { border: 1px solid #e2e8f0; border-radius: 12px; padding: 18px; }
.bg-light-gray { background: #f8fafc; border: none; }
.modal-section h4 { margin: 0 0 14px 0; font-size: 13px; font-weight: 800; color: #1e3a8a; display: flex; align-items: center; gap: 8px; text-transform: uppercase; letter-spacing: 0.3px; }
.modal-section p { margin: 0 0 8px 0; font-size: 13px; color: #475569; }
.modal-section p strong { color: #0f172a; }
.info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; font-size: 13px; color: #475569; }
.info-grid strong { color: #0f172a; display: block; margin-bottom: 4px; }
.notes-text { font-style: italic; color: #334155; line-height: 1.6; font-size: 13px; margin: 0; }

/* Status banner */
.status-banner { display: flex; align-items: center; gap: 12px; padding: 14px 18px; border-radius: 10px; background: #f8fafc; border: 1px solid #e2e8f0; flex-wrap: wrap; }
.banner-arrow { color: #94a3b8; font-size: 11px; }
.banner-dates { margin-left: auto; display: flex; gap: 16px; font-size: 12px; color: #64748b; }
.banner-dates span { display: flex; align-items: center; gap: 5px; }

/* Detail list */
.detail-list { display: flex; flex-direction: column; gap: 8px; }
.detail-item { display: flex; justify-content: space-between; align-items: center; font-size: 13px; padding: 5px 0; border-bottom: 1px solid #f8fafc; }
.detail-item:last-child { border-bottom: none; }
.detail-label { color: #64748b; font-weight: 600; flex-shrink: 0; min-width: 110px; }
.detail-value { color: #0f172a; text-align: right; }
.mono { font-family: monospace; font-weight: 700; color: #1e3a8a; }

/* Farm detail */
.farm-detail-grid { display: grid; grid-template-columns: 1fr auto; gap: 20px; align-items: start; }
.gps-box { display: flex; align-items: center; gap: 10px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px; padding: 14px 16px; min-width: 190px; }
.gps-icon { color: #1e3a8a; font-size: 20px; }
.gps-coords { display: flex; flex-direction: column; gap: 2px; }
.gps-label { font-size: 10px; font-weight: 800; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; }
.gps-value { font-size: 12px; font-weight: 700; color: #1e3a8a; font-family: monospace; }
.text-green { color: #063B16; }
.text-orange { color: #c2410c; }

/* Images */
.images-grid { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 4px; }
.image-thumb { width: 90px; height: 90px; border-radius: 8px; overflow: hidden; border: 2px solid #e2e8f0; display: flex; align-items: center; justify-content: center; background: #f8fafc; position: relative; transition: border-color 0.2s; }
.image-thumb:hover { border-color: #1e3a8a; }
.image-thumb img { width: 100%; height: 100%; object-fit: cover; }
.image-fallback { position: absolute; color: #94a3b8; font-size: 22px; }

.map-modal-content { max-width: 900px !important; }
.map-modal-body { padding: 0 !important; height: 65vh; }
.full-leaflet-map { width: 100%; height: 100%; }
:deep(.custom-leaflet-marker) { background: transparent; border: none; }

.text-center { text-align: center; padding: 30px !important; color: #64748b; }
.loading { text-align: center; padding: 50px; font-size: 15px; color: #64748b; font-weight: 600; }
.action-section { border-top: 2px dashed #e2e8f0 !important; background: #fafafa; }
.action-buttons { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 5px; }
.btn-action { padding: 10px 16px; border-radius: 8px; font-size: 13px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; transition: 0.2s; font-family: inherit; }
.btn-investigate { background: #dbeafe; color: #1e40af; border: 1px solid #93c5fd; }
.btn-investigate:hover { background: #bfdbfe; }
.btn-resolve { background: #dcfce7; color: #063B16; border: 1px solid #86efac; }
.btn-resolve:hover { background: #bbf7d0; }
.btn-reject { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }
.btn-reject:hover { background: #fecaca; }
.status-final { font-size: 13px; color: #94a3b8; display: flex; align-items: center; gap: 8px; font-style: italic; }

@media (max-width: 1200px) {
  .kpi-grid { grid-template-columns: repeat(2, 1fr); }
  .filters-bar { flex-wrap: wrap; }
  .search-box { flex: 100%; }
}
</style>
