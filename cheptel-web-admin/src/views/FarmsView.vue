<template>
  <AdminLayout page-title="Gestion des Fermes">
    <div class="page-section">

      <!-- Navigation interne -->
      <div class="page-tabs">
        <button
            :class="{ active: currentPanel === 'list' }"
            @click="currentPanel = 'list'"
        >
          Liste des fermes
        </button>

        <button
            :class="{ active: currentPanel === 'map' }"
            @click="currentPanel = 'map'"
        >
          Carte
        </button>

        <button
            :class="{ active: currentPanel === 'stats' }"
            @click="currentPanel = 'stats'"
        >
          Statistiques
        </button>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-success"></div>
        <p class="text-muted mt-2">Chargement des fermes...</p>
      </div>

      <!-- Content -->
      <div v-else class="page-panel">

        <!-- ===================================================== -->
        <!-- PANEL LISTE -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'list'" class="table-card-fixed">

          <!-- Header + filtres compactés -->
          <div class="page-header mb-2">
            <div class="d-flex justify-content-between align-items-center mb-2">
              <div>
                <h5 class="mb-1 fw-bold">Exploitations agricoles</h5>
                <p class="text-muted mb-0 small">
                  Fermes enregistrées, localisation et effectifs.
                </p>
              </div>

              <button class="btn btn-outline-success btn-sm" @click="reload">
                <i class="bi bi-arrow-clockwise me-1"></i>
                Actualiser
              </button>
            </div>

            <div class="row g-2">
              <div class="col-md-5">
                <input
                    v-model="search"
                    type="text"
                    class="form-control form-control-sm"
                    placeholder="Rechercher nom, propriétaire, commune..."
                />
              </div>

              <div class="col-md-4">
                <select v-model="wilayaFilter" class="form-select form-select-sm">
                  <option value="">Toutes les wilayas</option>
                  <option
                      v-for="w in wilayas"
                      :key="w"
                      :value="w"
                  >
                    {{ w }}
                  </option>
                </select>
              </div>

              <div class="col-md-3">
                <button
                    class="btn btn-outline-secondary w-100 btn-sm"
                    @click="resetFilters"
                >
                  Reset
                </button>
              </div>
            </div>
          </div>

          <!-- Table -->
          <div class="data-table table-card-fixed">
            <div class="data-table-header">
              <span class="data-table-title">
                {{ filteredFarms.length }} ferme(s)
              </span>
            </div>

            <div class="table-responsive">
              <table class="table mb-0">
                <thead>
                <tr>
                  <th>ID</th>
                  <th>NOM</th>
                  <th>PROPRIÉTAIRE</th>
                  <th>WILAYA</th>
                  <th>COMMUNE</th>
                  <th>ANIMAUX</th>
                  <th>GPS</th>
                  <th>ACTIONS</th>
                </tr>
                </thead>

                <tbody>
                <tr v-if="paginatedFarms.length === 0">
                  <td colspan="8" class="text-center text-muted py-4">
                    Aucune ferme trouvée
                  </td>
                </tr>

                <tr v-for="farm in paginatedFarms" :key="farm.id">
                  <td>#{{ farm.id }}</td>

                  <td>
                    <div class="fw-semibold">
                      {{ farm.name }}
                    </div>
                    <small class="text-muted">
                      {{ farm.location || '—' }}
                    </small>
                  </td>

                  <td>{{ farm.ownerName || '—' }}</td>

                  <td>{{ farm.wilaya || '—' }}</td>

                  <td>{{ farm.commune || '—' }}</td>

                  <td>
                      <span class="badge bg-success">
                        {{ farm.totalAnimaux || 0 }}
                      </span>
                  </td>

                  <td>
                      <span
                          v-if="farm.latitude && farm.longitude"
                          class="badge bg-primary"
                      >
                        Localisée
                      </span>

                    <span
                        v-else
                        class="badge bg-secondary"
                    >
                        Non localisée
                      </span>
                  </td>

                  <td>
                    <button
                        class="btn btn-sm btn-outline-success"
                        @click="openDetails(farm)"
                    >
                      <i class="bi bi-eye"></i>
                    </button>
                  </td>
                </tr>
                </tbody>
              </table>
            </div>

            <!-- Pagination -->
            <TablePagination
                :current-page="currentPage"
                :total-pages="totalPages"
                :total="filteredFarms.length"
                :per-page="perPage"
                :from="from"
                :to="to"
                :visible-pages="visiblePages"
                @change="goToPage"
                @per-page-change="changePerPage"
            />
          </div>
        </div>

        <!-- ===================================================== -->
        <!-- PANEL CARTE -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'map'" class="page-panel-scroll">

          <div class="d-flex justify-content-between align-items-center mb-2">
            <div>
              <h5 class="fw-bold mb-1">Localisation des fermes</h5>
              <p class="text-muted small mb-0">
                Carte compacte des exploitations disposant de coordonnées GPS.
              </p>
            </div>

            <button class="btn btn-sm btn-outline-success" @click="reload">
              Actualiser
            </button>
          </div>

          <div class="map-compact-wrapper">
            <FarmMap :farms="filteredFarms" />
          </div>
        </div>

        <!-- ===================================================== -->
        <!-- PANEL STATISTIQUES -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'stats'" class="page-panel-scroll">

          <div class="d-flex justify-content-between align-items-center mb-2">
            <div>
              <h5 class="fw-bold mb-1">Statistiques des fermes</h5>
              <p class="text-muted small mb-0">
                Vue synthétique des exploitations.
              </p>
            </div>
          </div>

          <div class="row g-2 mb-3">
            <div class="col-md-3">
              <StatCard
                  icon="house-fill"
                  :value="farms.length"
                  label="Total fermes"
                  color="#0B5D1E"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="tags-fill"
                  :value="totalAnimals"
                  label="Animaux déclarés"
                  color="#2563EB"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="geo-alt-fill"
                  :value="farmsWithGps"
                  label="Fermes localisées"
                  color="#D97706"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="map-fill"
                  :value="wilayas.length"
                  label="Wilayas couvertes"
                  color="#7C3AED"
              />
            </div>
          </div>

          <div class="data-table">
            <div class="data-table-header">
              <span class="data-table-title">
                Répartition par wilaya
              </span>
            </div>

            <div class="table-responsive">
              <table class="table mb-0">
                <thead>
                <tr>
                  <th>WILAYA</th>
                  <th>FERMES</th>
                  <th>ANIMAUX</th>
                  <th>LOCALISÉES</th>
                </tr>
                </thead>

                <tbody>
                <tr v-for="item in statsByWilaya" :key="item.wilaya">
                  <td>{{ item.wilaya }}</td>
                  <td>
                      <span class="badge bg-success">
                        {{ item.totalFarms }}
                      </span>
                  </td>
                  <td>{{ item.totalAnimals }}</td>
                  <td>{{ item.localized }}</td>
                </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

      </div>

      <!-- ===================================================== -->
      <!-- MODAL DÉTAIL FERME -->
      <!-- ===================================================== -->
      <div
          v-if="selectedFarm"
          class="modal d-block"
          style="background:rgba(0,0,0,0.5);"
      >
        <div class="modal-dialog modal-dialog-centered modal-lg">
          <div class="modal-content">

            <div class="modal-header">
              <h5 class="modal-title">
                <i class="bi bi-house-fill me-2 text-success"></i>
                {{ selectedFarm.name }}
              </h5>

              <button class="btn-close" @click="closeDetails"></button>
            </div>

            <div class="modal-body">
              <div v-if="loadingDetails" class="text-center py-4">
                <div class="spinner-border text-success"></div>
              </div>

              <div v-else-if="farmDetails">
                <div class="row g-3 mb-3">
                  <div class="col-md-6">
                    <div class="border rounded p-3">
                      <h6 class="fw-bold mb-3">
                        Informations générales
                      </h6>

                      <table class="table table-sm table-borderless mb-0">
                        <tbody>
                        <tr>
                          <td class="text-muted">Nom</td>
                          <td class="fw-semibold">
                            {{ farmDetails.name }}
                          </td>
                        </tr>

                        <tr>
                          <td class="text-muted">Adresse</td>
                          <td>{{ farmDetails.location || '—' }}</td>
                        </tr>

                        <tr>
                          <td class="text-muted">Wilaya</td>
                          <td>{{ farmDetails.wilaya || '—' }}</td>
                        </tr>

                        <tr>
                          <td class="text-muted">Commune</td>
                          <td>{{ farmDetails.commune || '—' }}</td>
                        </tr>

                        <tr>
                          <td class="text-muted">Coordonnées</td>
                          <td>
                              <span v-if="farmDetails.latitude && farmDetails.longitude">
                                {{ farmDetails.latitude }},
                                {{ farmDetails.longitude }}
                              </span>

                            <span v-else>—</span>
                          </td>
                        </tr>
                        </tbody>
                      </table>
                    </div>
                  </div>

                  <div class="col-md-6">
                    <div class="border rounded p-3">
                      <h6 class="fw-bold mb-3">
                        Propriétaire
                      </h6>

                      <table class="table table-sm table-borderless mb-0">
                        <tbody>
                        <tr>
                          <td class="text-muted">Nom</td>
                          <td class="fw-semibold">
                            {{ farmDetails.ownerName || '—' }}
                          </td>
                        </tr>

                        <tr>
                          <td class="text-muted">Email</td>
                          <td>{{ farmDetails.ownerEmail || '—' }}</td>
                        </tr>

                        <tr>
                          <td class="text-muted">Téléphone</td>
                          <td>{{ farmDetails.ownerPhone || '—' }}</td>
                        </tr>
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>

                <div class="row g-3">
                  <div class="col-md-3">
                    <div class="p-3 rounded bg-light text-center">
                      <div class="text-muted small">Total Animaux</div>
                      <h4 class="fw-bold mb-0">
                        {{ farmDetails.totalAnimaux || 0 }}
                      </h4>
                    </div>
                  </div>

                  <div class="col-md-3">
                    <div class="p-3 rounded text-center" style="background:#dcfce7;">
                      <div class="text-muted small">Actifs</div>
                      <h4 class="fw-bold text-success mb-0">
                        {{ farmDetails.actifs || 0 }}
                      </h4>
                    </div>
                  </div>

                  <div class="col-md-3">
                    <div class="p-3 rounded text-center" style="background:#dbeafe;">
                      <div class="text-muted small">Ovins</div>
                      <h4 class="fw-bold text-primary mb-0">
                        {{ farmDetails.ovins || 0 }}
                      </h4>
                    </div>
                  </div>

                  <div class="col-md-3">
                    <div class="p-3 rounded text-center" style="background:#fef3c7;">
                      <div class="text-muted small">Bovins</div>
                      <h4 class="fw-bold text-warning mb-0">
                        {{ farmDetails.bovins || 0 }}
                      </h4>
                    </div>
                  </div>
                </div>

                <div
                    v-if="farmDetails.latitude && farmDetails.longitude"
                    class="mt-3"
                >
                  <a
                      class="btn btn-sm btn-outline-primary"
                      target="_blank"
                      :href="`https://www.google.com/maps?q=${farmDetails.latitude},${farmDetails.longitude}`"
                  >
                    <i class="bi bi-geo-alt me-1"></i>
                    Voir sur Google Maps
                  </a>
                </div>
              </div>
            </div>

            <div class="modal-footer">
              <button class="btn btn-secondary" @click="closeDetails">
                Fermer
              </button>
            </div>

          </div>
        </div>
      </div>

    </div>
  </AdminLayout>
</template>

<script setup>
import AdminLayout from '@/layouts/AdminLayout.vue'
import StatCard from '@/components/common/StatCard.vue'
import FarmMap from '@/components/common/FarmMap.vue'
import TablePagination from '@/components/common/TablePagination.vue'

import { computed, onMounted, ref } from 'vue'
import { farmsApi } from '@/api/farmsApi.js'
import { usePagination } from '@/composables/usePagination.js'

const currentPanel = ref('list')

const loading = ref(true)
const farms = ref([])

const search = ref('')
const wilayaFilter = ref('')

const selectedFarm = ref(null)
const farmDetails = ref(null)
const loadingDetails = ref(false)

const filteredFarms = computed(() => {
  let result = farms.value || []

  if (search.value.trim()) {
    const q = search.value.toLowerCase()

    result = result.filter(f =>
        f.name?.toLowerCase().includes(q) ||
        f.ownerName?.toLowerCase().includes(q) ||
        f.commune?.toLowerCase().includes(q) ||
        f.wilaya?.toLowerCase().includes(q)
    )
  }

  if (wilayaFilter.value) {
    result = result.filter(f => f.wilaya === wilayaFilter.value)
  }

  return result
})

const {
  currentPage,
  perPage,
  totalPages,
  paginatedItems: paginatedFarms,
  from,
  to,
  visiblePages,
  goToPage,
  changePerPage
} = usePagination(filteredFarms)

const wilayas = computed(() =>
    [...new Set(farms.value.map(f => f.wilaya).filter(Boolean))]
)

const totalAnimals = computed(() =>
    farms.value.reduce((sum, f) => sum + (f.totalAnimaux || 0), 0)
)

const farmsWithGps = computed(() =>
    farms.value.filter(f => f.latitude && f.longitude).length
)

const statsByWilaya = computed(() => {
  const map = {}

  for (const farm of farms.value) {
    const wilaya = farm.wilaya || 'Inconnue'

    if (!map[wilaya]) {
      map[wilaya] = {
        wilaya,
        totalFarms: 0,
        totalAnimals: 0,
        localized: 0
      }
    }

    map[wilaya].totalFarms++
    map[wilaya].totalAnimals += farm.totalAnimaux || 0

    if (farm.latitude && farm.longitude) {
      map[wilaya].localized++
    }
  }

  return Object.values(map)
})

onMounted(() => loadFarms())

async function loadFarms() {
  loading.value = true

  try {
    const res = await farmsApi.getAll()
    farms.value = res.data || []
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

function reload() {
  loadFarms()
}

function resetFilters() {
  search.value = ''
  wilayaFilter.value = ''
}

async function openDetails(farm) {
  selectedFarm.value = farm
  farmDetails.value = null
  loadingDetails.value = true

  try {
    const res = await farmsApi.getById(farm.id)
    farmDetails.value = res.data
  } catch (e) {
    console.error(e)
  } finally {
    loadingDetails.value = false
  }
}

function closeDetails() {
  selectedFarm.value = null
  farmDetails.value = null
}
</script>

<style scoped>
.map-compact-wrapper :deep(.farm-map) {
  height: 340px !important;
}
</style>