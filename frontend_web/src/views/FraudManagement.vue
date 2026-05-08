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
          <div class="kpi-bar-bg"><div class="kpi-bar" :style="{ width: constats.length > 0 ? '100%' : '0%' }"></div></div>
        </div>

        <div class="kpi-card kpi-red">
          <span class="kpi-label">TAUX DE FRAUDE</span>
          <div class="kpi-value-row">
            <span class="kpi-value">{{ fraudRate }}%</span>
            <span class="kpi-trend red" v-if="fraudRate > 0">Attention</span>
          </div>
          <div class="kpi-bar-bg"><div class="kpi-bar" :style="{ width: fraudRate > 0 ? fraudRate + '%' : '0%' }"></div></div>
        </div>

        <div class="kpi-card kpi-gray">
          <span class="kpi-label">ENQUÊTES EN COURS</span>
          <div class="kpi-value-row">
            <span class="kpi-value">{{ investigationsCount }}</span>
          </div>
          <div class="kpi-bar-bg"><div class="kpi-bar" :style="{ width: investigationsCount > 0 ? (investigationsCount / constats.length * 100) + '%' : '0%' }"></div></div>
        </div>

        <div class="kpi-card kpi-green">
          <span class="kpi-label">SCORE DE CONFORMITÉ</span>
          <div class="kpi-value-row">
            <span class="kpi-value">{{ complianceScore }}%</span>
            <span class="kpi-trend green">Calculé</span>
          </div>
          <div class="kpi-bar-bg"><div class="kpi-bar" :style="{ width: complianceScore > 0 ? complianceScore + '%' : '0%' }"></div></div>
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
          <span>Affichage {{ paginationStart }} - {{ paginationEnd }} sur {{ filteredConstats.length }}</span>
          <div class="page-controls" v-if="totalPages > 1">
            <button :disabled="currentPage === 1" @click="prevPage"><i class="fas fa-chevron-left"></i></button>
            <button
              v-for="page in pageNumbers"
              :key="page"
              class="page-btn"
              :class="{ active: currentPage === page }"
              :disabled="page === '...'"
              @click="typeof page === 'number' && setPage(page)"
            >{{ page }}</button>
            <button :disabled="currentPage === totalPages" @click="nextPage"><i class="fas fa-chevron-right"></i></button>
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

    <!-- MODALE CARTE -->
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

    <!-- MODALE DÉTAILS -->
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
import { ref, onMounted, computed, watch, nextTick } from 'vue';
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
const itemsPerPage = 15;

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

watch([searchQuery, filterType, filterStatus, sortDateOrder], () => {
  currentPage.value = 1;
});

const mappedConstats = computed(() =>
  constats.value.filter(c =>
    c.controlSession?.farm?.latitude != null && c.controlSession?.farm?.longitude != null
  )
);

const openMapModal = () => { showMapModal.value = true; nextTick(() => { initMap(); }); };
const closeMapModal = () => { showMapModal.value = false; if (map) { map.remove(); map = null; markersLayer = null; } };

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
    html: `<div style="background-color:#F44336;width:16px;height:16px;border-radius:50%;border:3px solid white;box-shadow:0 0 10px rgba(0,0,0,0.5);"></div>`,
    iconSize: [20, 20], iconAnchor: [10, 10], popupAnchor: [0, -10]
  });
  mappedConstats.value.forEach(constat => {
    const marker = L.marker([constat.controlSession.farm.latitude, constat.controlSession.farm.longitude], { icon: markerIcon }).addTo(markersLayer);
    marker.bindPopup(`<b>${constat.controlSession?.farm?.name || 'N/A'}</b><br>${translateType(constat.type)}`);
    marker.on('click', () => { openDetailsModal(constat); });
  });
};

const openDetailsModal = (constat) => { selectedConstat.value = constat; showDetailsModal.value = true; };
const closeDetailsModal = () => { showDetailsModal.value = false; selectedConstat.value = null; };

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

const paginatedConstats = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredConstats.value.slice(start, start + itemsPerPage);
});

const totalPages = computed(() => Math.ceil(filteredConstats.value.length / itemsPerPage));

const paginationStart = computed(() => {
  if (filteredConstats.value.length === 0) return 0;
  return (currentPage.value - 1) * itemsPerPage + 1;
});

const paginationEnd = computed(() => {
  return Math.min(currentPage.value * itemsPerPage, filteredConstats.value.length);
});

const pageNumbers = computed(() => {
  const pages = [];
  const total = totalPages.value;
  const current = currentPage.value;
  if (total <= 7) {
    for (let i = 1; i <= total; i++) pages.push(i);
  } else {
    pages.push(1);
    if (current > 3) pages.push('...');
    for (let i = Math.max(2, current - 1); i <= Math.min(total - 1, current + 1); i++) pages.push(i);
    if (current < total - 2) pages.push('...');
    pages.push(total);
  }
  return pages;
});

const prevPage = () => { if (currentPage.value > 1) currentPage.value--; };
const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++; };
const setPage = (page) => { currentPage.value = page; };

const fraudRate = computed(() => {
  if (!constats.value.length) return 0;
  const frauds = constats.value.filter(c => c.type === 'FRAUDE').length;
  return ((frauds / constats.value.length) * 100).toFixed(1);
});

const investigationsCount = computed(() => constats.value.filter(c => c.status === 'IN_REVIEW').length);

const complianceScore = computed(() => {
  if (!constats.value.length) return 100;
  const resolved = constats.value.filter(c => c.status === 'RESOLVED').length;
  return ((resolved / constats.value.length) * 100).toFixed(1);
});

const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : '--';
const formatTime = (d) => d ? new Date(d).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }) : '';

const translateType = (type) => ({ 'FRAUDE': 'Fraude', 'MANQUANT': 'Manquant', 'DOUBLON': 'Doublon', 'AUTRE': 'Autre' }[type] || type || 'N/A');
const getTypeClass = (type) => ({ 'FRAUDE': 'badge-red', 'MANQUANT': 'badge-orange', 'DOUBLON': 'badge-blue', 'AUTRE': 'badge-gray' }[type] || 'badge-gray');
const translateStatus = (status) => ({ 'PENDING': 'En attente', 'IN_REVIEW': 'Investigation', 'RESOLVED': 'Résolu', 'REJECTED': 'Rejeté' }[status] || status);
const getStatusClass = (status) => ({ 'IN_REVIEW': 'badge-blue', 'RESOLVED': 'badge-green', 'PENDING': 'badge-yellow', 'REJECTED': 'badge-red' }[status] || 'badge-gray');
const getRowClass = (type) => (type === 'FRAUDE' ? 'row-danger' : '');
const translateFarmStatus = (s) => ({ 'Active': 'Opérationnelle', 'Suspended': 'Suspendue', 'Closed': 'Fermée' }[s] || s);
const translateRole = (r) => ({ 'Administrator': 'Admin', 'Farmer': 'Éleveur', 'Inspector': 'Inspecteur', 'Veterinarian': 'Vétérinaire' }[r] || r);

const updateConstatStatus = async (newStatus) => {
  if (!selectedConstat.value) return;
  const statusLabels = { 'PENDING': 'En attente', 'IN_REVIEW': 'Investigation', 'RESOLVED': 'Résolu', 'REJECTED': 'Rejeté' };
  let message = newStatus === 'RESOLVED' ? `Classer ce constat comme résolu est irréversible.\nConfirmer ?` : newStatus === 'REJECTED' ? `Rejeter ce constat est irréversible.\nConfirmer ?` : `Passer à "${statusLabels[newStatus]}" ?`;
  if (!confirm(message)) return;
  try {
    await api.put(`/constats/${selectedConstat.value.id}/status`, { status: newStatus });
    selectedConstat.value = { ...selectedConstat.value, status: newStatus, resolvedAt: newStatus === 'RESOLVED' ? new Date().toISOString() : selectedConstat.value.resolvedAt };
    await fetchAllData();
  } catch (error) { console.error('Erreur:', error); alert('Erreur lors de la mise à jour.'); }
};

const exportConstatsToCsv = () => {
  if (!filteredConstats.value.length) { alert('Aucun constat.'); return; }
  const headers = ['ID', 'Type', 'Statut', 'Date', 'Ferme', 'Contrôleur'];
  const rows = filteredConstats.value.map(c => [c.id, translateType(c.type), translateStatus(c.status), formatDate(c.createdAt), c.controlSession?.farm?.name || 'N/A', getControleurName(c)]);
  const csv = [headers.join(','), ...rows.map(r => r.map(v => `"${v}"`).join(','))].join('\n');
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a'); link.href = URL.createObjectURL(blob); link.download = `constats_${new Date().toISOString().split('T')[0]}.csv`;
  document.body.appendChild(link); link.click(); document.body.removeChild(link);
};
</script>

<style scoped>
/* ==========================================================================
   1. BASE
   ========================================================================== */
.constats-container { font-family: 'Inter', sans-serif; background-color: #f4f7f6; min-height: 100vh; padding: 30px; color: #1e293b; }
.header-section { margin-bottom: 25px; }
.title-row { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 25px; }
.title-row h1 { font-size: 26px; font-weight: 900; margin: 0; color: #0f172a; letter-spacing: -0.5px; }
.subtitle { color: #64748b; font-size: 14px; margin-top: 5px; }
.btn-export { background: rgba(11, 93, 30, 0.08); border: 1px solid rgba(11, 93, 30, 0.2); padding: 10px 20px; border-radius: 8px; font-weight: 600; color: #063B16; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s; }
.btn-export:hover { background: rgba(11, 93, 30, 0.15); }

/* ==========================================================================
   2. KPI GRID
   ========================================================================== */
.kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
.kpi-card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); border-left: 4px solid transparent; }
.kpi-blue { border-left-color: #2196F3; }
.kpi-red { border-left-color: #F44336; }
.kpi-gray { border-left-color: #FF9800; }
.kpi-green { border-left-color: #4CAF50; }
.kpi-label { font-size: 10px; font-weight: 800; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; display: block; margin-bottom: 4px; }
.kpi-value-row { display: flex; align-items: baseline; gap: 10px; margin: 4px 0; }
.kpi-value { font-size: 24px; font-weight: 900; color: #0f172a; line-height: 1; }
.kpi-trend { font-size: 11px; font-weight: 700; }
.kpi-trend.green { color: #4CAF50; } .kpi-trend.red { color: #F44336; }
.kpi-bar-bg { height: 6px; background: rgba(11, 93, 30, 0.08); border-radius: 3px; overflow: hidden; margin-top: 8px; }
.kpi-bar { height: 100%; border-radius: 3px; transition: width 1s ease-out; }
.kpi-blue .kpi-bar { background: #2196F3; } .kpi-red .kpi-bar { background: #F44336; } .kpi-gray .kpi-bar { background: #FF9800; } .kpi-green .kpi-bar { background: #4CAF50; }

/* ==========================================================================
   3. FILTRES
   ========================================================================== */
.filters-bar { display: flex; align-items: center; gap: 20px; background: white; padding: 16px 25px; border-radius: 12px 12px 0 0; margin-bottom: 0; border: 1px solid rgba(11, 93, 30, 0.08); box-shadow: 0 2px 10px rgba(0,0,0,0.02); border-bottom: none; }
.search-box { flex: 2; position: relative; min-width: 200px; }
.search-box i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #0B5D1E; opacity: 0.6; }
.search-box input { width: 100%; padding: 10px 14px 10px 42px; border: 1px solid rgba(11, 93, 30, 0.2); border-radius: 8px; outline: none; background: rgba(11, 93, 30, 0.03); font-size: 14px; color: #063B16; height: 44px; box-sizing: border-box; }
.search-box input:focus { border-color: #0B5D1E; background: white; }
.filter-group { display: flex; flex-direction: column; gap: 6px; flex: 0 1 auto; }
.filter-group label { font-size: 10px; font-weight: 700; color: #0B5D1E; text-transform: uppercase; }
.filter-group select { padding: 10px 14px; border: 1px solid rgba(11, 93, 30, 0.2); border-radius: 8px; outline: none; background: white; font-weight: 600; color: #063B16; font-size: 13px; height: 44px; box-sizing: border-box; min-width: 150px; }

/* ==========================================================================
   4. TABLEAU
   ========================================================================== */
.main-layout { display: flex; flex-direction: column; gap: 25px; }
.registry-card { background: white; border-radius: 0 0 12px 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); overflow: hidden; border: 1px solid rgba(11, 93, 30, 0.08); border-top: none; }
.registry-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 25px; border-bottom: 1px solid rgba(11, 93, 30, 0.08); }
.registry-header h2 { margin: 0; font-size: 16px; font-weight: 800; color: #0f172a; }
.last-update { font-size: 12px; color: #0B5D1E; font-weight: 500; background: rgba(11, 93, 30, 0.05); padding: 4px 10px; border-radius: 20px; }
.registry-table { width: 100%; border-collapse: collapse; }
.registry-table th { text-align: left; padding: 14px 20px; font-size: 11px; font-weight: 800; color: #0B5D1E; text-transform: uppercase; border-bottom: 1px solid rgba(11, 93, 30, 0.08); background: rgba(11, 93, 30, 0.03); letter-spacing: 0.5px; }
.registry-table td { padding: 16px 20px; border-bottom: 1px solid rgba(11, 93, 30, 0.05); vertical-align: middle; }
.registry-table tr:hover { background-color: rgba(11, 93, 30, 0.02); }
.row-danger { background-color: rgba(244, 67, 54, 0.03); }
.insp-id { font-weight: 800; color: #0B5D1E; font-size: 14px; font-family: 'JetBrains Mono', monospace; }
.inspector-info, .target-info, .date-info { display: flex; flex-direction: column; gap: 2px; }
.name, .target-name { font-weight: 700; color: #0f172a; font-size: 14px; }
.badge-id, .target-ref { font-size: 12px; color: #64748b; }
.date { font-weight: 600; color: #063B16; font-size: 14px; }
.time { font-size: 12px; color: #94a3b8; }

/* ==========================================================================
   5. BADGES
   ========================================================================== */
.badge-result, .badge-status { padding: 4px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; display: inline-block; text-align: center; text-transform: uppercase; }
.badge-red { background: rgba(244, 67, 54, 0.1); color: #F44336; }
.badge-orange { background: rgba(255, 152, 0, 0.1); color: #FF9800; }
.badge-blue { background: rgba(33, 150, 243, 0.1); color: #2196F3; }
.badge-green { background: rgba(76, 175, 80, 0.1); color: #4CAF50; }
.badge-yellow { background: rgba(255, 152, 0, 0.1); color: #FF9800; }
.badge-gray { background: rgba(11, 93, 30, 0.05); color: #64748b; }

/* ==========================================================================
   6. BOUTON
   ========================================================================== */
.btn-view { background: rgba(11, 93, 30, 0.08); border: 1px solid rgba(11, 93, 30, 0.2); color: #0B5D1E; width: 32px; height: 32px; border-radius: 6px; cursor: pointer; transition: 0.2s; display: flex; align-items: center; justify-content: center; }
.btn-view:hover { background: #0B5D1E; color: white; border-color: #0B5D1E; }

/* ==========================================================================
   7. PAGINATION
   ========================================================================== */
.pagination { display: flex; justify-content: space-between; align-items: center; padding: 20px; background: rgba(11, 93, 30, 0.02); border-top: 1px solid rgba(11, 93, 30, 0.08); color: #64748b; font-size: 13px; font-weight: 600; }
.page-controls { display: flex; gap: 5px; }
.page-controls button, .page-btn { width: 35px; height: 35px; border: 1px solid rgba(11, 93, 30, 0.2); background: white; border-radius: 8px; cursor: pointer; color: #063B16; font-weight: 700; display: flex; align-items: center; justify-content: center; transition: all 0.2s; }
.page-controls button:hover:not(:disabled), .page-btn:hover:not(:disabled) { background: rgba(11, 93, 30, 0.1); }
.page-controls button.active, .page-btn.active { background: #0B5D1E; color: white; border-color: #0B5D1E; }
.page-controls button:disabled, .page-btn:disabled { opacity: 0.5; cursor: not-allowed; }

/* ==========================================================================
   8. CARTE
   ========================================================================== */
.map-section { width: 100%; }
.map-trigger-card { background: linear-gradient(135deg, #063B16 0%, #0B5D1E 100%); border-radius: 16px; overflow: hidden; height: 160px; position: relative; cursor: pointer; border: 2px solid rgba(11, 93, 30, 0.3); transition: all 0.2s; }
.map-trigger-card:hover { border-color: #0B5D1E; }
.card-overlay { position: absolute; inset: 0; padding: 25px; display: flex; flex-direction: column; justify-content: flex-end; color: white; }
.pulse-indicator-small { font-size: 11px; font-weight: 700; color: #F44336; text-transform: uppercase; display: flex; align-items: center; gap: 6px; margin-bottom: 8px; }
.pulse-indicator-small .dot { width: 8px; height: 8px; background: #F44336; border-radius: 50%; animation: blink 1.5s infinite; }
@keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } }
.card-overlay h3 { margin: 0 0 5px 0; font-size: 20px; font-weight: 800; }
.card-overlay p { margin: 0; font-size: 13px; color: rgba(255,255,255,0.8); display: flex; align-items: center; gap: 6px; }

/* ==========================================================================
   9. MODALES
   ========================================================================== */
.modal-overlay { position: fixed; inset: 0; background: rgba(6, 59, 22, 0.7); display: flex; justify-content: center; align-items: center; z-index: 9999; backdrop-filter: blur(4px); }
.modal-content { background: white; width: 100%; max-width: 650px; border-radius: 12px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25); animation: slideUp 0.3s ease-out; }
.modal-content-wide { max-width: 820px !important; }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 25px; border-bottom: 1px solid rgba(11, 93, 30, 0.08); background: rgba(11, 93, 30, 0.02); }
.modal-header h2 { margin: 0; font-size: 18px; font-weight: 800; color: #063B16; }
.modal-id { color: #0B5D1E; font-size: 15px; background: rgba(11, 93, 30, 0.08); padding: 2px 10px; border-radius: 20px; }
.btn-close { background: rgba(11, 93, 30, 0.08); border: none; font-size: 18px; color: #0B5D1E; cursor: pointer; width: 35px; height: 35px; border-radius: 8px; display: flex; align-items: center; justify-content: center; transition: 0.2s; }
.btn-close:hover { background: rgba(244, 67, 54, 0.1); color: #F44336; }
.modal-body { padding: 25px; display: flex; flex-direction: column; gap: 18px; max-height: 78vh; overflow-y: auto; }

.text-center { text-align: center; padding: 30px !important; color: #64748b; }
.loading { text-align: center; padding: 50px; font-size: 15px; color: #64748b; font-weight: 600; }

@media (max-width: 1200px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } .filters-bar { flex-wrap: wrap; } .search-box { flex: 100%; } }

/* ==========================================================================
   10. MODALE DÉTAILS - BANDEAU STATUT
   ========================================================================== */
.status-banner {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 18px;
  border-radius: 10px;
  background: rgba(11, 93, 30, 0.03);
  border: 1px solid rgba(11, 93, 30, 0.1);
  flex-wrap: wrap;
}

.banner-arrow {
  color: #94a3b8;
  font-size: 11px;
}

.banner-dates {
  margin-left: auto;
  display: flex;
  gap: 16px;
  font-size: 12px;
  color: #64748b;
}

.banner-dates span {
  display: flex;
  align-items: center;
  gap: 5px;
}

/* ==========================================================================
   11. MODALE DÉTAILS - SECTIONS
   ========================================================================== */
.modal-section {
  border: 1px solid rgba(11, 93, 30, 0.08);
  border-radius: 12px;
  padding: 18px;
  background: white;
}

.modal-section h4 {
  margin: 0 0 14px 0;
  font-size: 13px;
  font-weight: 800;
  color: #0B5D1E;
  display: flex;
  align-items: center;
  gap: 8px;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.modal-section h4 i {
  color: #0B5D1E;
}

.info-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 18px;
}

.notes-text {
  font-style: italic;
  color: #475569;
  line-height: 1.6;
  font-size: 13px;
  margin: 0;
}

/* ==========================================================================
   12. MODALE DÉTAILS - LISTE DE DÉTAILS
   ========================================================================== */
.detail-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13px;
  padding: 5px 0;
  border-bottom: 1px solid rgba(11, 93, 30, 0.05);
}

.detail-item:last-child {
  border-bottom: none;
}

.detail-label {
  color: #64748b;
  font-weight: 600;
  flex-shrink: 0;
  min-width: 110px;
  font-size: 12px;
}

.detail-value {
  color: #063B16;
  text-align: right;
  font-weight: 600;
}

.mono {
  font-family: 'JetBrains Mono', monospace;
  font-weight: 700;
  color: #2196F3;
}

/* ==========================================================================
   13. MODALE DÉTAILS - FERME
   ========================================================================== */
.farm-detail-grid {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 20px;
  align-items: start;
}

.gps-box {
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(11, 93, 30, 0.03);
  border: 1px solid rgba(11, 93, 30, 0.15);
  border-radius: 10px;
  padding: 14px 16px;
  min-width: 190px;
}

.gps-icon {
  color: #0B5D1E;
  font-size: 20px;
}

.gps-coords {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.gps-label {
  font-size: 10px;
  font-weight: 800;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.gps-value {
  font-size: 12px;
  font-weight: 700;
  color: #0B5D1E;
  font-family: 'JetBrains Mono', monospace;
}

.text-green {
  color: #4CAF50;
  display: flex;
  align-items: center;
  gap: 4px;
}

.text-orange {
  color: #FF9800;
  display: flex;
  align-items: center;
  gap: 4px;
}

/* ==========================================================================
   14. MODALE DÉTAILS - IMAGES
   ========================================================================== */
.images-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 4px;
}

.image-thumb {
  width: 90px;
  height: 90px;
  border-radius: 8px;
  overflow: hidden;
  border: 2px solid rgba(11, 93, 30, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(11, 93, 30, 0.03);
  position: relative;
  transition: border-color 0.2s;
}

.image-thumb:hover {
  border-color: #0B5D1E;
}

.image-thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-fallback {
  position: absolute;
  color: #94a3b8;
  font-size: 22px;
}

/* ==========================================================================
   15. MODALE DÉTAILS - ACTIONS
   ========================================================================== */
.action-section {
  border-top: 2px dashed rgba(11, 93, 30, 0.15) !important;
  background: rgba(11, 93, 30, 0.02);
}

.action-buttons {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  margin-top: 5px;
}

.btn-action {
  padding: 10px 16px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  transition: 0.2s;
  font-family: inherit;
  border: 1px solid transparent;
}

.btn-investigate {
  background: rgba(33, 150, 243, 0.08);
  color: #2196F3;
  border-color: rgba(33, 150, 243, 0.2);
}

.btn-investigate:hover {
  background: rgba(33, 150, 243, 0.15);
}

.btn-resolve {
  background: rgba(76, 175, 80, 0.08);
  color: #4CAF50;
  border-color: rgba(76, 175, 80, 0.2);
}

.btn-resolve:hover {
  background: rgba(76, 175, 80, 0.15);
}

.btn-reject {
  background: rgba(244, 67, 54, 0.08);
  color: #F44336;
  border-color: rgba(244, 67, 54, 0.2);
}

.btn-reject:hover {
  background: rgba(244, 67, 54, 0.15);
}

.status-final {
  font-size: 13px;
  color: #94a3b8;
  display: flex;
  align-items: center;
  gap: 8px;
  font-style: italic;
}

/* ==========================================================================
   16. MODALE CARTE
   ========================================================================== */
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

/* ==========================================================================
   17. RESPONSIVE
   ========================================================================== */
@media (max-width: 1200px) {
  .kpi-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .filters-bar {
    flex-wrap: wrap;
  }
  .search-box {
    flex: 100%;
  }
  .info-row {
    grid-template-columns: 1fr;
  }
  .farm-detail-grid {
    grid-template-columns: 1fr;
  }
}
</style>
