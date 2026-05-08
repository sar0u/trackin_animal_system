<template>
  <div class="main-content">

    <div class="page-header">
      <div>
        <h1>Gestion des Animaux</h1>
        <p class="subtitle">Suivi global du cheptel, état de santé et traçabilité de chaque bête.</p>
      </div>
    </div>

    <p v-if="loadError" class="api-error-banner">{{ loadError }}</p>

    <div class="animal-content-stacked">

      <div class="top-stats-grid">
        <div class="stat-card">
          <div class="stat-icon icon-green"><i class="fas fa-paw"></i></div>
          <div class="stat-info">
            <span class="stat-title">TOTAL DU BÉTAIL</span>
            <span class="stat-value">{{ totalAnimals }}</span>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon icon-blue"><i class="fas fa-layer-group"></i></div>
          <div class="stat-info">
            <span class="stat-title">RÉPARTITION ESPÈCES</span>
            <span class="stat-subtext">{{ speciesDistributionText }}</span>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon icon-orange"><i class="fas fa-heartbeat"></i></div>
          <div class="stat-info">
            <span class="stat-title">TAUX DE SANTÉ</span>
            <span class="stat-value">{{ healthRate }}%</span>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon icon-red"><i class="fas fa-exclamation-triangle"></i></div>
          <div class="stat-info">
            <span class="stat-title">ALERTES SANITAIRES</span>
            <span class="stat-value">{{ sickAnimalsCount }}</span>
          </div>
        </div>
      </div>

      <div class="main-list-section">
        <div class="filters-bar">
          <div class="search-box">
            <i class="fas fa-search"></i>
            <input type="text" v-model="searchQuery" placeholder="Rechercher Tag, ID, Propriétaire...">
          </div>

          <div class="right-filters">
            <div class="dropdown-filters">
              <select v-model="selectedSpecies" class="styled-input">
                <option value="">Toutes les espèces</option>
                <option v-for="species in uniqueSpecies" :key="species" :value="species">{{ species }}</option>
              </select>
              <select v-model="selectedHealth" class="styled-input">
                <option value="">Tous les états</option>
                <option v-for="health in uniqueHealth" :key="health" :value="health">{{ formatEnum(health) }}</option>
              </select>
            </div>
            <div class="number-filters">
              <div class="number-input-group">
                <label>Né(e) après :</label>
                <input type="date" v-model="dateMin" class="styled-input">
              </div>
            </div>
          </div>
        </div>

        <div class="table-container-card">
          <div v-if="isLoading" style="padding: 40px; text-align: center; color: #718096;">
            <i class="fas fa-circle-notch fa-spin"></i> Chargement des données...
          </div>

          <table class="animal-table" v-else>
            <thead>
            <tr>
              <th>ID</th>
              <th>N° DE TAG</th>
              <th>ID FERME</th>
              <th>ESPÈCE</th>
              <th>RACE</th>
              <th>SANTÉ</th>
              <th>DATE DE NAISS.</th>
              <th>POIDS</th>
              <th>DÉTAILS</th>
            </tr>
            </thead>
            <tbody>
            <tr v-if="filteredAnimals.length === 0">
              <td colspan="9" class="empty-msg">Aucun animal trouvé.</td>
            </tr>
            <tr v-for="animal in paginatedAnimals" :key="animal.id">
              <td class="id-text" style="color: #0B5D1E;">#ANI-{{ animal.id }}</td>
              <td class="tag-badge">{{ animal.rfidTag?.rfidCode || animal.rfidTag?.id || 'Sans Tag' }}</td>
              <td class="id-text" style="color: #3b82f6;">#FRM-{{ animal.farm?.id || '--' }}</td>
              <td><span class="species-text">{{ animal.species || 'Inconnue' }}</span></td>
              <td><span class="breed-text">{{ animal.breed || '—' }}</span></td>
              <td>
                  <span class="health-badge" :class="getHealthClass(animal.healthStatus)">
                    {{ formatEnum(animal.healthStatus) }}
                  </span>
              </td>
              <td class="date-text">
                <i class="far fa-calendar-alt" style="margin-right: 5px; color:#a0aec0;"></i>
                {{ formatDate(animal.birthDate) }}
              </td>
              <td class="weight-text">{{ animal.weight ? animal.weight + ' kg' : '--' }}</td>
              <td>
                <button class="btn-details" @click="openDetailsModal(animal)">
                  <i class="fas fa-eye"></i>
                </button>
              </td>
            </tr>
            </tbody>
          </table>

          <div class="pagination-footer">
            <span class="pagination-info">
              Affichage de {{ paginationStart }} à {{ paginationEnd }} sur {{ filteredAnimals.length }} animaux
            </span>
            <div class="pagination-controls" v-if="totalPages > 1">
              <button class="btn-nav" :disabled="currentPage === 1" @click="prevPage"><</button>
              <button class="page-num" v-for="page in totalPages" :key="page" :class="{ active: currentPage === page }" @click="setPage(page)">{{ page }}</button>
              <button class="btn-nav" :disabled="currentPage === totalPages" @click="nextPage">></button>
            </div>
          </div>
        </div>
      </div>

      <div class="bottom-charts-grid">
        <div class="chart-card">
          <div class="chart-header">
            <h3>Plateforme de croissance</h3>
            <div class="gmq-badge">GMQ: +{{ dynamicGrowthStats.avgGMQ }}kg</div>
          </div>
          <div class="css-bar-chart">
            <div class="chart-bars">
              <div class="bar-container" v-for="(bar, index) in dynamicGrowthStats.bars" :key="index">
                <div class="bar-fill" :style="{ height: bar.heightPercent + '%' }">
                  <span class="bar-tooltip">{{ bar.avgWeight }} kg</span>
                </div>
                <span class="bar-label">{{ bar.label }}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="chart-card">
          <div class="chart-header"><h3>Ratio par Espèce</h3></div>
          <div class="ratio-list">
            <div class="ratio-item" v-for="(sp, index) in dynamicSpeciesRatio" :key="index">
              <div class="ratio-item-header">
                <span><span class="dot" :style="{ background: sp.color }"></span> {{ sp.name }}</span>
                <span>{{ sp.percentage }}%</span>
              </div>
              <div class="progress-track"><div class="progress-fill" :style="{ width: sp.percentage + '%', background: sp.color }"></div></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showDetailsModal && selectedAnimal" class="modal-overlay" @click.self="closeDetailsModal">
      <div class="modal-content details-modal">
        <div class="modal-header">
          <div class="header-titles">
            <h2>Fiche Animal <span>#ANI-{{ selectedAnimal.id }}</span></h2>
            <span class="tag-chip">TAG: {{ selectedAnimal.rfidTag?.rfidCode || selectedAnimal.rfidTag?.id || 'Non assigné' }}</span>
          </div>
          <button class="btn-close" @click="closeDetailsModal"><i class="fas fa-times"></i></button>
        </div>

        <div class="modal-body-grid">
          <div class="info-card">
            <h3><i class="fas fa-tag"></i> Identité & Caractéristiques</h3>
            <div class="info-row"><span class="info-label">Espèce :</span> <span class="info-value">{{ selectedAnimal.species || '--' }}</span></div>
            <div class="info-row"><span class="info-label">Race :</span> <span class="info-value">{{ selectedAnimal.breed || '--' }}</span></div>
            <div class="info-row"><span class="info-label">Sexe :</span> <span class="info-value">{{ formatEnum(selectedAnimal.gender) }}</span></div>
            <div class="info-row"><span class="info-label">Statut vital :</span> <span class="info-value">{{ formatEnum(selectedAnimal.lifeStatus) }}</span></div>
            <div class="info-row"><span class="info-label">Type d'origine :</span> <span class="info-value">{{ formatEnum(selectedAnimal.originType) }}</span></div>
          </div>

          <div class="info-card">
            <h3><i class="fas fa-heartbeat"></i> Santé & Prévention</h3>
            <div class="info-row">
              <span class="info-label">État de Santé :</span>
              <span class="badge" :class="getHealthClass(selectedAnimal.healthStatus)">
                {{ formatEnum(selectedAnimal.healthStatus) }}
              </span>
            </div>
            <div class="info-row"><span class="info-label">Poids Actuel :</span> <span class="info-value">{{ selectedAnimal.weight || '--' }} kg</span></div>
          </div>

          <div class="info-card">
            <h3><i class="fas fa-map-marked-alt"></i> Origine & Acquisition</h3>
            <div class="info-row"><span class="info-label">Lieu de Naissance :</span> <span class="info-value">{{ selectedAnimal.birthPlace || 'Inconnu' }}</span></div>
            <div class="info-row"><span class="info-label">Lieu d'Acquisition :</span> <span class="info-value">{{ selectedAnimal.acquisitionPlace || 'N/A' }}</span></div>
            <div class="info-row">
              <span class="info-label">Propriétaire :</span>
              <span class="info-value">
                <span v-if="selectedAnimal.owner?.firstName || selectedAnimal.owner?.lastName">
                  {{ (selectedAnimal.owner?.firstName || '') + ' ' + (selectedAnimal.owner?.lastName || '') }}
                </span>
                <span v-else-if="selectedAnimal.owner?.id" class="blue-text">#USR-{{ selectedAnimal.owner.id }}</span>
                <span v-else>--</span>
              </span>
            </div>
          </div>

          <div class="info-card">
            <h3><i class="fas fa-dna"></i> Généalogie</h3>
            <div class="info-row"><span class="info-label">Mère (ID) :</span> <span class="info-value">{{ selectedAnimal.mother?.id ? '#ANI-' + selectedAnimal.mother.id : 'Non renseignée' }}</span></div>
            <div class="info-row"><span class="info-label">Père (ID) :</span> <span class="info-value">{{ selectedAnimal.father?.id ? '#ANI-' + selectedAnimal.father.id : 'Non renseigné' }}</span></div>
          </div>

          <div class="info-card">
            <h3><i class="fas fa-farm"></i> Exploitation</h3>
            <div class="info-row"><span class="info-label">Ferme :</span> <span class="info-value blue-mono">#FRM-{{ selectedAnimal.farm?.id || '--' }}</span></div>
            <div class="info-row"><span class="info-label">Nom Ferme :</span> <span class="info-value">{{ selectedAnimal.farm?.name || '--' }}</span></div>
          </div>

          <div class="info-card full-width">
            <h3><i class="fas fa-comment-alt"></i> Notes & Observations</h3>
            <div class="notes-content">
              {{ selectedAnimal.notes || 'Aucune observation particulière.' }}
            </div>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import api from '../services/api';

// --- ÉTATS ---
const animals = ref([]);
const isLoading = ref(true);
const loadError = ref('');
const searchQuery = ref('');
const selectedSpecies = ref('');
const selectedHealth = ref('');
const dateMin = ref('');
const dateMax = ref('');
const showDetailsModal = ref(false);
const selectedAnimal = ref(null);
const currentPage = ref(1);
const itemsPerPage = 10;

// --- API ---
const fetchAnimals = async () => {
  loadError.value = '';
  try {
    const response = await api.get('/animals');
    const rows = response.data;
    animals.value = Array.isArray(rows) ? rows : [];
    if (!Array.isArray(rows)) {
      loadError.value = 'Réponse API inattendue pour /animals (tableau attendu).';
    }
  } catch (error) {
    console.error("Erreur API:", error);
    animals.value = [];
    const msg = error.response?.data;
    loadError.value =
        typeof msg === 'string' ? msg
        : msg?.message || error.message || 'Impossible de charger les animaux (vérifiez le backend et la console réseau).';
  } finally {
    isLoading.value = false;
  }
};
onMounted(fetchAnimals);

// --- UTILITAIRES ---
const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : '--';
const translateHealthStatus = (status) => ({
  'Healthy': 'Sain',
  'UnderTreatment': 'En traitement',
  'Critical': 'Critique',
  'Quarantined': 'En quarantaine'
}[status] || status);

const formatEnum = (v) => {
  if (!v) return '--';
  // Pour les statuts de santé, utiliser la traduction
  if (v === 'Healthy' || v === 'UnderTreatment' || v === 'Critical' || v === 'Quarantined') {
    return translateHealthStatus(v);
  }
  // Pour les autres enums, faire la mise en forme standard
  return v.charAt(0).toUpperCase() + v.slice(1).toLowerCase().replace('_', ' ');
};

const getHealthClass = (s) => {
  if (!s) return 'badge-gray';
  const val = s.toUpperCase();
  if (val.includes('HEALTHY')) return 'badge-green';
  if (val.includes('CRITICAL') || val.includes('QUARANTINED')) return 'badge-red';
  return 'badge-orange';
};

// --- LOGIQUE FILTRAGE ---
const filteredAnimals = computed(() => {
  const q = searchQuery.value.toLowerCase();
  return animals.value.filter(a => {
    const matchesSearch = String(a.id).includes(q) ||
        (a.rfidTag?.id && String(a.rfidTag.id).includes(q)) ||
        (a.rfidTag?.rfidCode && String(a.rfidTag.rfidCode).toLowerCase().includes(q)) ||
        (a.owner?.id && String(a.owner.id).includes(q)) ||
        (a.breed && a.breed.toLowerCase().includes(q)) ||
        (a.owner?.firstName && `${a.owner.firstName} ${a.owner.lastName || ''}`.toLowerCase().includes(q));
    const matchesSpecies = !selectedSpecies.value || a.species === selectedSpecies.value;
    const matchesHealth = !selectedHealth.value || a.healthStatus === selectedHealth.value;
    return matchesSearch && matchesSpecies && matchesHealth;
  });
});

// --- PAGINATION ---
const paginatedAnimals = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredAnimals.value.slice(start, start + itemsPerPage);
});
const totalPages = computed(() => Math.ceil(filteredAnimals.value.length / itemsPerPage));
const paginationStart = computed(() => (currentPage.value - 1) * itemsPerPage + 1);
const paginationEnd = computed(() => Math.min(currentPage.value * itemsPerPage, filteredAnimals.value.length));
const prevPage = () => { if (currentPage.value > 1) currentPage.value--; };
const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++; };
const setPage = (p) => { currentPage.value = p; };

// --- STATISTIQUES DYNAMIQUES ---
const totalAnimals = computed(() => animals.value.length);
const sickAnimalsCount = computed(() => animals.value.filter(a => ['Critical', 'Quarantined'].includes(a.healthStatus)).length);
const healthRate = computed(() => totalAnimals.value ? Math.round(((totalAnimals.value - sickAnimalsCount.value) / totalAnimals.value) * 100) : 0);

const uniqueSpecies = computed(() => [...new Set(animals.value.map(a => a.species))].filter(Boolean));
const uniqueHealth = computed(() => [...new Set(animals.value.map(a => a.healthStatus))].filter(Boolean));

const speciesDistributionText = computed(() => {
  const counts = {};
  animals.value.forEach(a => counts[a.species] = (counts[a.species] || 0) + 1);
  return Object.entries(counts).map(([s, c]) => `${s}: ${c}`).join(' | ');
});

const dynamicSpeciesRatio = computed(() => {
  const counts = {};
  animals.value.forEach(a => counts[a.species] = (counts[a.species] || 0) + 1);
  const colors = ['#0B5D1E', '#3b82f6', '#f97316', '#8b5cf6'];
  return Object.entries(counts).map(([name, count], i) => ({
    name, count, percentage: Math.round((count / totalAnimals.value) * 100), color: colors[i % colors.length]
  }));
});

const dynamicGrowthStats = computed(() => {
  const weightBySp = {};
  animals.value.forEach(a => {
    if (!weightBySp[a.species]) weightBySp[a.species] = { total: 0, count: 0 };
    weightBySp[a.species].total += (a.weight || 0);
    weightBySp[a.species].count++;
  });
  const bars = Object.entries(weightBySp).map(([label, data]) => {
    const avgWeight = Math.round(data.total / data.count);
    return { label, avgWeight, heightPercent: Math.min(90, (avgWeight / 500) * 100) };
  });

  const today = new Date();
  let totalGmq = 0, validCount = 0;
  animals.value.forEach(a => {
    if (a.weight && a.birthDate) {
      const birth = new Date(a.birthDate);
      const days = Math.floor((today - birth) / 86400000);
      if (days > 0) { totalGmq += a.weight / days; validCount++; }
    }
  });
  const avgGMQ = validCount > 0 ? (totalGmq / validCount).toFixed(3) : 'N/A';

  return { avgGMQ, bars };
});

// --- MODALE ---
const openDetailsModal = (a) => { selectedAnimal.value = a; showDetailsModal.value = true; };
const closeDetailsModal = () => { showDetailsModal.value = false; };
</script>

<style scoped>
/* ==========================================================================
   1. BASE ET TYPOGRAPHIE
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

.animal-content-stacked {
  display: flex;
  flex-direction: column;
  gap: 25px;
}

.api-error-banner {
  background: rgba(244, 67, 54, 0.08);
  border: 1px solid rgba(244, 67, 54, 0.2);
  color: #F44336;
  padding: 12px 20px;
  border-radius: 8px;
  font-weight: 600;
  font-size: 14px;
  margin-bottom: 15px;
}

/* ==========================================================================
   2. CARTES DE STATISTIQUES (TOP)
   ========================================================================== */
.top-stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 5px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 20px;
  border-left: 4px solid transparent;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
}

.stat-card:nth-child(1) { border-left-color: #4CAF50; }
.stat-card:nth-child(2) { border-left-color: #2196F3; }
.stat-card:nth-child(3) { border-left-color: #FF9800; }
.stat-card:nth-child(4) { border-left-color: #F44336; }

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  flex-shrink: 0;
}

.stat-card:nth-child(1) .stat-icon { background: rgba(76, 175, 80, 0.1); color: #4CAF50; }
.stat-card:nth-child(2) .stat-icon { background: rgba(33, 150, 243, 0.1); color: #2196F3; }
.stat-card:nth-child(3) .stat-icon { background: rgba(255, 152, 0, 0.1); color: #FF9800; }
.stat-card:nth-child(4) .stat-icon { background: rgba(244, 67, 54, 0.1); color: #F44336; }

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-title {
  font-size: 10px;
  font-weight: 800;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 24px;
  font-weight: 900;
  color: #0f172a;
  line-height: 1;
}

.stat-subtext {
  font-size: 12px;
  font-weight: 600;
  color: #64748b;
  line-height: 1.4;
}

/* ==========================================================================
   3. BARRE DE FILTRES
   ========================================================================== */
.filters-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  padding: 16px 25px;
  border-radius: 12px 12px 0 0;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  flex-wrap: wrap;
  gap: 20px;
  border: 1px solid rgba(11, 93, 30, 0.08);
}

.search-box {
  display: flex;
  align-items: center;
  background: rgba(11, 93, 30, 0.05);
  padding: 8px 16px;
  border-radius: 8px;
  flex: 1;
  min-width: 250px;
  max-width: 400px;
  transition: 0.3s;
}

.search-box:focus-within {
  background: #fff;
  box-shadow: 0 0 0 2px #0B5D1E;
}

.search-box i {
  color: #0B5D1E;
  opacity: 0.6;
  margin-right: 10px;
}

.search-box input {
  border: none;
  background: transparent;
  width: 100%;
  outline: none;
  font-size: 14px;
  color: #063B16;
}

.search-box input::placeholder {
  color: #0B5D1E;
  opacity: 0.5;
}

.right-filters {
  display: flex;
  gap: 20px;
  align-items: center;
  flex-wrap: wrap;
}

.dropdown-filters {
  display: flex;
  gap: 16px;
}

.number-filters {
  display: flex;
  gap: 15px;
}

.number-input-group {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #063B16;
  font-weight: 600;
}

.number-input-group label {
  color: #0B5D1E;
  font-weight: 700;
}

.styled-input {
  padding: 10px 14px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  outline: none;
  font-family: 'Inter', sans-serif;
  color: #063B16;
  transition: 0.3s;
  background: white;
  font-size: 13px;
  height: 42px;
  box-sizing: border-box;
}

.styled-input:focus {
  border-color: #0B5D1E;
  box-shadow: 0 0 0 3px rgba(11, 93, 30, 0.1);
}

/* ==========================================================================
   4. TABLEAU
   ========================================================================== */
.table-container-card {
  background: white;
  border-radius: 0 0 12px 12px;
  border: 1px solid rgba(11, 93, 30, 0.08);
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  overflow: hidden;
}

.animal-table {
  width: 100%;
  border-collapse: collapse;
}

.animal-table th {
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

.animal-table td {
  padding: 16px 20px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.05);
  font-size: 14px;
  vertical-align: middle;
  color: #1e293b;
}

.animal-table tr:hover {
  background-color: rgba(11, 93, 30, 0.02);
}

.tag-badge {
  font-family: 'JetBrains Mono', monospace;
  font-weight: 600;
  color: #0B5D1E;
  background: rgba(11, 93, 30, 0.05);
  padding: 4px 8px;
  border-radius: 6px;
  border: 1px solid rgba(11, 93, 30, 0.1);
  font-size: 13px;
}

.id-text {
  font-family: 'JetBrains Mono', monospace;
  font-weight: 600;
}

.species-text {
  font-weight: 700;
  color: #0f172a;
}

.breed-text {
  color: #475569;
  font-size: 13px;
  font-weight: 500;
}

.date-text, .weight-text {
  color: #475569;
  font-weight: 500;
  font-size: 13px;
}

/* ==========================================================================
   5. HEALTH BADGES
   ========================================================================== */
.health-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-weight: 700;
  font-size: 11px;
  display: inline-block;
  text-align: center;
  text-transform: uppercase;
}

.badge-green {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

.badge-red {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

.badge-orange {
  background: rgba(255, 152, 0, 0.1);
  color: #FF9800;
}

.badge-gray {
  background: rgba(11, 93, 30, 0.05);
  color: #64748b;
}

/* ==========================================================================
   6. BOUTON DETAILS
   ========================================================================== */
.btn-details {
  background: rgba(11, 93, 30, 0.08);
  border: 1px solid rgba(11, 93, 30, 0.2);
  color: #0B5D1E;
  width: 32px;
  height: 32px;
  border-radius: 8px;
  font-weight: 600;
  font-size: 12px;
  cursor: pointer;
  transition: 0.2s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.btn-details:hover {
  background: #0B5D1E;
  color: white;
  border-color: #0B5D1E;
}

/* ==========================================================================
   7. PAGINATION
   ========================================================================== */
.pagination-footer {
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(11, 93, 30, 0.02);
  border-top: 1px solid rgba(11, 93, 30, 0.08);
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

.page-num.active {
  background: #0B5D1E;
  color: white;
  border-color: #0B5D1E;
}

.btn-nav:hover:not(:disabled), .page-num:hover:not(.active) {
  background: rgba(11, 93, 30, 0.1);
}

.btn-nav:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ==========================================================================
   8. SECTION BASSE : GRAPHES
   ========================================================================== */
.bottom-charts-grid {
  display: grid;
  grid-template-columns: 3fr 2fr;
  gap: 25px;
}

.chart-card {
  background: white;
  border-radius: 12px;
  border: 1px solid rgba(11, 93, 30, 0.08);
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  padding: 25px;
  display: flex;
  flex-direction: column;
}

/* Chart 1: Croissance */
.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 25px;
}

.chart-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 800;
  color: #0f172a;
}

.gmq-badge {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
  padding: 6px 12px;
  border-radius: 8px;
  font-weight: 800;
  font-size: 12px;
  border: 1px solid rgba(76, 175, 80, 0.2);
}

.css-bar-chart {
  flex: 1;
  display: flex;
  align-items: flex-end;
  justify-content: center;
  padding-top: 20px;
  min-height: 200px;
}

.chart-bars {
  display: flex;
  gap: 40px;
  height: 180px;
  align-items: flex-end;
}

.bar-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  height: 100%;
  position: relative;
  width: 45px;
}

.bar-fill {
  width: 100%;
  background: rgba(11, 93, 30, 0.15);
  border-radius: 6px 6px 0 0;
  position: relative;
  transition: height 1s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
}

.bar-container:hover .bar-fill {
  background: #0B5D1E;
  box-shadow: 0 10px 25px rgba(11, 93, 30, 0.3);
}

.bar-label {
  margin-top: 10px;
  font-size: 12px;
  font-weight: 700;
  color: #64748b;
}

.bar-tooltip {
  position: absolute;
  top: -30px;
  left: 50%;
  transform: translateX(-50%);
  background: #063B16;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 700;
  opacity: 0;
  transition: 0.2s;
  pointer-events: none;
  white-space: nowrap;
}

.bar-container:hover .bar-tooltip {
  opacity: 1;
  top: -35px;
}

/* Chart 2: Ratio */
.ratio-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-bottom: 30px;
}

.ratio-item-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
  font-weight: 700;
  color: #063B16;
}

.dot {
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  margin-right: 5px;
}

.progress-track {
  height: 6px;
  background: rgba(11, 93, 30, 0.08);
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  border-radius: 3px;
  transition: width 1s ease-out;
}

/* ==========================================================================
   9. MODALE DETAILS
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

.details-modal {
  background: #f4f7f6;
  width: 95%;
  max-width: 900px;
  border-radius: 20px;
  padding: 30px;
  box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
  animation: slideUp 0.3s ease-out;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
  border-bottom: 2px solid rgba(11, 93, 30, 0.08);
  padding-bottom: 20px;
}

.header-titles h2 {
  margin: 0 0 10px 0;
  font-size: 24px;
  color: #063B16;
  font-weight: 800;
}

.header-titles h2 span {
  color: #0B5D1E;
  font-family: 'JetBrains Mono', monospace;
  font-weight: 600;
}

.tag-chip {
  background: rgba(11, 93, 30, 0.08);
  color: #0B5D1E;
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 700;
  font-family: 'JetBrains Mono', monospace;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  border: 1px solid rgba(11, 93, 30, 0.15);
}

.btn-close {
  border: none;
  background: rgba(11, 93, 30, 0.08);
  width: 36px;
  height: 36px;
  border-radius: 8px;
  font-size: 16px;
  cursor: pointer;
  color: #0B5D1E;
  transition: 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-close:hover {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

.modal-body-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 20px;
}

.info-card {
  background: white;
  padding: 25px;
  border-radius: 16px;
  border: 1px solid rgba(11, 93, 30, 0.08);
  box-shadow: 0 2px 8px rgba(0,0,0,0.02);
}

.info-card h3 {
  margin: 0 0 20px 0;
  font-size: 15px;
  color: #063B16;
  font-weight: 800;
  display: flex;
  align-items: center;
  gap: 8px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
}

.info-card h3 i {
  color: #0B5D1E;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px dashed rgba(11, 93, 30, 0.05);
}

.info-row:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.info-label {
  color: #64748b;
  font-size: 13px;
  font-weight: 600;
}

.info-value {
  color: #063B16;
  font-size: 14px;
  font-weight: 700;
  text-align: right;
}

.blue-text {
  color: #2196F3;
  font-family: 'JetBrains Mono', monospace;
}

.blue-mono {
  font-family: 'JetBrains Mono', monospace;
  color: #2196F3;
}

.notes-content {
  background: rgba(11, 93, 30, 0.03);
  padding: 18px;
  border-radius: 12px;
  font-style: italic;
  border-left: 5px solid #0B5D1E;
  line-height: 1.6;
  color: #475569;
}

.full-width {
  grid-column: 1 / -1;
}

.empty-msg {
  text-align: center;
  padding: 40px;
  color: #94a3b8;
  font-style: italic;
}

/* ==========================================================================
   10. ANIMATIONS & RESPONSIVE
   ========================================================================== */
@keyframes slideUp {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

@media (max-width: 1200px) {
  .top-stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .bottom-charts-grid {
    grid-template-columns: 1fr;
  }
}
</style>