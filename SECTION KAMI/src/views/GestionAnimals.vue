<template>
  <div class="main-content">

    <div class="page-header">
      <div>
        <h1>Gestion des Animaux</h1>
        <p class="subtitle">Suivi global du cheptel, état de santé et traçabilité de chaque bête.</p>
      </div>
    </div>

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
          <div v-if="isLoading" class="loading-state">
            <i class="fas fa-circle-notch fa-spin"></i> Chargement des données...
          </div>

          <table class="animal-table" v-else>
            <thead>
              <tr>
                <th>N° DE TAG</th>
                <th>ID FERME</th>
                <th>ESPÈCE</th>
                <th>SANTÉ</th>
                <th>DATE DE NAISS.</th>
                <th>POIDS</th>
                <th style="text-align: right;">ACTION</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="filteredAnimals.length === 0">
                <td colspan="7" class="empty-msg">Aucun animal trouvé.</td>
              </tr>
              <tr v-for="animal in paginatedAnimals" :key="animal.id">
                <td class="tag-badge">{{ animal.rfidTag?.id || 'Sans Tag' }}</td>
                <td class="id-text" style="color: #3b82f6;">#FRM-{{ animal.currentFarm?.id || '--' }}</td>
                <td><span class="species-text">{{ animal.species || 'Inconnue' }}</span></td>
                <td>
                  <span class="health-badge" :class="getHealthClass(animal.healthStatus)">
                    {{ formatEnum(animal.healthStatus) }}
                  </span>
                </td>
                <td class="date-text">{{ formatDate(animal.birthDate) }}</td>
                <td class="weight-text">{{ animal.currentWeightKilograms ? animal.currentWeightKilograms + ' kg' : '--' }}</td>
                <td style="text-align: right;">
                  <button class="btn-details" @click="openDetailsModal(animal)">
                    <i class="fas fa-eye"></i> Détails
                  </button>
                </td>
              </tr>
            </tbody>
          </table>

          <div class="pagination-footer">
            <span class="pagination-info">Affichage de {{ paginationStart }} à {{ paginationEnd }} sur {{ filteredAnimals.length }}</span>
            <div class="pagination-controls" v-if="totalPages > 1">
              <button class="btn-nav" :disabled="currentPage === 1" @click="prevPage">Précédent</button>
              <button class="page-num" v-for="page in totalPages" :key="page" :class="{ active: currentPage === page }" @click="setPage(page)">
                {{ page }}
              </button>
              <button class="btn-nav" :disabled="currentPage === totalPages" @click="nextPage">Suivant</button>
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
            <span class="tag-chip">TAG: {{ selectedAnimal.rfidTag?.id || 'Non assigné' }}</span>
          </div>
          <button class="btn-close" @click="closeDetailsModal"><i class="fas fa-times"></i></button>
        </div>

        <div class="modal-body-grid">
          <div class="info-card">
            <h3><i class="fas fa-heartbeat"></i> Santé & Prévention</h3>
            <div class="info-row">
              <span class="info-label">Vaccination :</span>
              <span :class="['vaccin-badge', selectedAnimal.vaccinationStatus?.toLowerCase() || 'not_vaccinated']">
                <i class="fas fa-shield-alt"></i> {{ formatVaccination(selectedAnimal.vaccinationStatus) }}
              </span>
            </div>
            <div class="info-row">
              <span class="info-label">État de Santé :</span>
              <span class="health-badge" :class="getHealthClass(selectedAnimal.healthStatus)">
                {{ formatEnum(selectedAnimal.healthStatus) }}
              </span>
            </div>
            <div class="info-row"><span class="info-label">Poids Actuel :</span> <span class="info-value">{{ selectedAnimal.currentWeightKilograms || '--' }} kg</span></div>
          </div>

          <div class="info-card">
            <h3><i class="fas fa-map-marked-alt"></i> Origine & Acquisition</h3>
            <div class="info-row"><span class="info-label">Lieu de Naissance :</span> <span class="info-value">{{ selectedAnimal.birthPlace || 'Inconnu' }}</span></div>
            <div class="info-row"><span class="info-label">Lieu d'Acquisition :</span> <span class="info-value">{{ selectedAnimal.acquisitionPlace || 'N/A' }}</span></div>
            <div class="info-row"><span class="info-label">Propriétaire ID :</span> <span class="info-value blue-mono">#USR-{{ selectedAnimal.ownerId || '--' }}</span></div>
          </div>

          <div class="info-card">
            <h3><i class="fas fa-dna"></i> Généalogie</h3>
            <div class="info-row"><span class="info-label">Mère (ID) :</span> <span class="info-value">{{ selectedAnimal.motherId ? '#ANI-' + selectedAnimal.motherId : 'Non renseignée' }}</span></div>
            <div class="info-row"><span class="info-label">Père (ID) :</span> <span class="info-value">{{ selectedAnimal.fatherId ? '#ANI-' + selectedAnimal.fatherId : 'Non renseigné' }}</span></div>
          </div>

          <div class="info-card">
            <h3><i class="fas fa-farm"></i> Exploitation</h3>
            <div class="info-row"><span class="info-label">Ferme :</span> <span class="info-value blue-mono">#FRM-{{ selectedAnimal.currentFarm?.id || '--' }}</span></div>
            <div class="info-row"><span class="info-label">Nom Ferme :</span> <span class="info-value">{{ selectedAnimal.currentFarm?.farmName || '--' }}</span></div>
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
const searchQuery = ref('');
const selectedSpecies = ref('');
const selectedHealth = ref('');
const dateMin = ref('');
const dateMax = ref('');
const showDetailsModal = ref(false);
const selectedAnimal = ref(null);
const currentPage = ref(1);
const itemsPerPage = 8;

// --- API ---
const fetchAnimals = async () => {
  try {
    const response = await api.get('/animals');
    animals.value = response.data;
  } catch (error) {
    console.error("Erreur API:", error);
  } finally {
    isLoading.value = false;
  }
};
onMounted(fetchAnimals);

// --- UTILITAIRES ---
const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : '--';
const formatEnum = (v) => v ? v.charAt(0).toUpperCase() + v.slice(1).toLowerCase().replace('_', ' ') : '--';

const formatVaccination = (status) => {
  const map = { 'UpToDate': 'À jour', 'Expired': 'Expiré', 'Not_vaccinated': 'Non vacciné' };
  return map[status] || 'Non vacciné';
};

const getHealthClass = (s) => {
  if (!s) return 'badge-gray';
  const val = s.toUpperCase();
  if (val.includes('HEALTHY')) return 'badge-green';
  if (val.includes('SICK')) return 'badge-red';
  return 'badge-orange';
};

// --- LOGIQUE FILTRAGE ---
const filteredAnimals = computed(() => {
  const q = searchQuery.value.toLowerCase();
  return animals.value.filter(a => {
    const matchesSearch = String(a.id).includes(q) ||
                         (a.rfidTag?.id && String(a.rfidTag.id).includes(q)) ||
                         (a.ownerId && String(a.ownerId).includes(q));
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
const sickAnimalsCount = computed(() => animals.value.filter(a => a.healthStatus?.includes('SICK')).length);
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
  const colors = ['#11D432', '#3b82f6', '#f97316', '#8b5cf6'];
  return Object.entries(counts).map(([name, count], i) => ({
    name, count, percentage: Math.round((count / totalAnimals.value) * 100), color: colors[i % colors.length]
  }));
});

const dynamicGrowthStats = computed(() => {
  const weightBySp = {};
  animals.value.forEach(a => {
    if (!weightBySp[a.species]) weightBySp[a.species] = { total: 0, count: 0 };
    weightBySp[a.species].total += (a.currentWeightKilograms || 0);
    weightBySp[a.species].count++;
  });
  const bars = Object.entries(weightBySp).map(([label, data]) => {
    const avgWeight = Math.round(data.total / data.count);
    return { label, avgWeight, heightPercent: Math.min(90, (avgWeight / 500) * 100) };
  });
  return { avgGMQ: "0.85", bars };
});

// --- MODALE ---
const openDetailsModal = (a) => { selectedAnimal.value = a; showDetailsModal.value = true; };
const closeDetailsModal = () => { showDetailsModal.value = false; };
</script>

<style scoped>
/* ==========================================================================
   1. VARIABLES & BASE
   ========================================================================== */
.main-content {
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  background: #f8fafb;
  padding: 30px;
  min-height: 100vh;
  color: #2d3748;
}

.page-header { margin-bottom: 25px; }
.page-header h1 { font-size: 26px; font-weight: 800; color: #1a202c; margin: 0; }
.subtitle { color: #718096; font-size: 14px; margin-top: 5px; }

/* ==========================================================================
   2. STATISTIQUES (TOP CARDS)
   ========================================================================== */
.top-stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  padding: 22px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 15px;
  border: 1px solid #edf2f7;
  transition: transform 0.2s ease;
}

.stat-card:hover { transform: translateY(-3px); }

.stat-icon {
  width: 50px; height: 50px; border-radius: 12px;
  display: flex; align-items: center; justify-content: center; font-size: 20px;
}

.icon-green  { background: #ecfdf5; color: #10b981; }
.icon-blue   { background: #eff6ff; color: #3b82f6; }
.icon-orange { background: #fff7ed; color: #f97316; }
.icon-red    { background: #fef2f2; color: #ef4444; }

.stat-title { font-size: 11px; font-weight: 800; color: #9ca3af; text-transform: uppercase; letter-spacing: 0.5px; }
.stat-value { font-size: 24px; font-weight: 900; color: #1a202c; display: block; }
.stat-subtext { font-size: 12px; color: #718096; font-weight: 500; }

/* ==========================================================================
   3. FILTRES & RECHERCHE
   ========================================================================== */
.filters-bar {
  background: white; padding: 18px; border-radius: 14px;
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 25px; border: 1px solid #edf2f7; box-shadow: 0 2px 4px rgba(0,0,0,0.02);
}

.search-box {
  background: #f3f4f6; padding: 10px 16px; border-radius: 10px;
  display: flex; align-items: center; width: 350px; border: 1px solid transparent;
  transition: all 0.2s;
}

.search-box:focus-within { background: white; border-color: #11D432; box-shadow: 0 0 0 3px rgba(17, 212, 50, 0.1); }
.search-box input { border: none; background: transparent; margin-left: 10px; outline: none; width: 100%; font-size: 14px; }

.right-filters { display: flex; gap: 15px; align-items: center; }
.styled-input {
  padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 8px;
  font-size: 13px; font-weight: 600; color: #4a5568; outline: none; cursor: pointer;
}

/* ==========================================================================
   4. TABLEAU DES ANIMAUX
   ========================================================================== */
.table-container-card { background: white; border-radius: 16px; border: 1px solid #edf2f7; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
.animal-table { width: 100%; border-collapse: collapse; }
.animal-table th { background: #f8fafc; padding: 16px; text-align: left; font-size: 11px; color: #718096; text-transform: uppercase; letter-spacing: 1px; border-bottom: 1px solid #edf2f7; }
.animal-table td { padding: 16px; border-bottom: 1px solid #f1f5f9; font-size: 14px; vertical-align: middle; }
.animal-table tr:hover { background-color: #f9fafb; }

.tag-badge { background: #f1f5f9; padding: 5px 10px; border-radius: 6px; font-family: 'JetBrains Mono', monospace; font-weight: 700; color: #475569; font-size: 12px; }
.id-text { font-family: 'JetBrains Mono', monospace; font-weight: 700; font-size: 13px; }

/* Badges de Santé */
.health-badge { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: 800; text-transform: uppercase; }
.badge-green  { background: #dcfce7; color: #15803d; }
.badge-red    { background: #fee2e2; color: #b91c1c; }
.badge-orange { background: #fef3c7; color: #b45309; }
.badge-gray   { background: #f1f5f9; color: #475569; }

.btn-details {
  background: white; border: 1px solid #e2e8f0; padding: 8px 16px; border-radius: 8px;
  cursor: pointer; font-weight: 700; font-size: 12px; transition: all 0.2s; color: #4a5568;
}
.btn-details:hover { background: #11D432; color: white; border-color: #11D432; box-shadow: 0 4px 10px rgba(17, 212, 50, 0.2); }

/* ==========================================================================
   5. GRAPHES & CHARTS
   ========================================================================== */
.bottom-charts-grid { display: grid; grid-template-columns: 1.6fr 1fr; gap: 20px; margin-top: 25px; }
.chart-card { background: white; border-radius: 18px; border: 1px solid #edf2f7; padding: 25px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); }

.chart-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 25px; }
.chart-header h3 { font-size: 17px; font-weight: 800; margin: 0; }
.gmq-badge { background: #f0fdf4; color: #16a34a; padding: 6px 14px; border-radius: 8px; font-weight: 800; font-size: 12px; border: 1px solid #bbf7d0; }

.css-bar-chart { height: 200px; display: flex; align-items: flex-end; padding-top: 20px; }
.chart-bars { display: flex; gap: 35px; align-items: flex-end; width: 100%; justify-content: space-around; }
.bar-container { display: flex; flex-direction: column; align-items: center; width: 40px; position: relative; }
.bar-fill {
  width: 100%; background: #e2e8f0; border-radius: 6px 6px 0 0; transition: all 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  position: relative; cursor: pointer;
}
.bar-container:hover .bar-fill { background: #11D432; }
.bar-tooltip {
  position: absolute; top: -35px; background: #1a202c; color: white; padding: 4px 8px;
  border-radius: 5px; font-size: 11px; font-weight: 800; opacity: 0; transition: 0.2s;
}
.bar-container:hover .bar-tooltip { opacity: 1; transform: translateY(-5px); }
.bar-label { margin-top: 12px; font-size: 11px; font-weight: 700; color: #718096; }

/* ==========================================================================
   6. MODALE DE DÉTAILS
   ========================================================================== */
.modal-overlay {
  position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6);
  display: flex; align-items: center; justify-content: center; z-index: 1000; backdrop-filter: blur(6px);
}

.details-modal {
  background: #f8fafb; width: 95%; max-width: 900px; border-radius: 24px; padding: 35px;
  box-shadow: 0 25px 50px -12px rgba(0,0,0,0.3); animation: slideUp 0.4s ease-out; max-height: 90vh; overflow-y: auto;
}

.modal-header { display: flex; justify-content: space-between; margin-bottom: 30px; border-bottom: 2px solid #edf2f7; padding-bottom: 20px; }
.header-titles h2 { font-size: 24px; font-weight: 900; margin: 0 0 8px 0; }
.header-titles h2 span { color: #94a3b8; font-family: monospace; }

.modal-body-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px; }
.info-card { background: white; padding: 24px; border-radius: 18px; border: 1px solid #edf2f7; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
.info-card h3 {
  font-size: 15px; font-weight: 800; margin: 0 0 20px 0; padding-bottom: 12px;
  border-bottom: 1px solid #f1f5f9; color: #11D432; display: flex; align-items: center; gap: 10px;
}

.info-row { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px dashed #f1f5f9; }
.info-row:last-child { border-bottom: none; }
.info-label { color: #64748b; font-weight: 600; font-size: 13px; }
.info-value { font-weight: 700; font-size: 14px; color: #1e293b; }

.notes-content {
  background: #f1f5f9; padding: 18px; border-radius: 12px; font-style: italic;
  border-left: 5px solid #11D432; line-height: 1.6; color: #475569;
}

.full-width { grid-column: 1 / -1; }

/* ==========================================================================
   7. PAGINATION & ANIMATIONS
   ========================================================================== */
.pagination-footer { padding: 20px; display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #edf2f7; }
.page-num {
  width: 35px; height: 35px; border-radius: 8px; border: 1px solid #e2e8f0;
  background: white; font-weight: 700; cursor: pointer; transition: 0.2s;
}
.page-num.active { background: #11D432; color: white; border-color: #11D432; }

@keyframes slideUp { from { opacity: 0; transform: translateY(40px); } to { opacity: 1; transform: translateY(0); } }

/* RESPONSIVE */
@media (max-width: 1024px) {
  .bottom-charts-grid { grid-template-columns: 1fr; }
  .search-box { width: 100%; }
}
</style>