<template>
  <AdminLayout page-title="Gestion des Animaux">
    <div class="page-section">

      <!-- Navigation interne -->
      <div class="page-tabs">
        <button
            :class="{ active: currentPanel === 'list' }"
            @click="currentPanel = 'list'"
        >
          Liste des animaux
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
        <p class="text-muted mt-2">Chargement des animaux...</p>
      </div>

      <div v-else-if="errorMsg" class="alert alert-danger">
        {{ errorMsg }}
      </div>

      <div v-else class="page-panel">

        <!-- ===================================================== -->
        <!-- PANEL LISTE -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'list'" class="table-card-fixed">

          <!-- Header + Filtres -->
          <div class="page-header mb-2">
            <div class="d-flex justify-content-between align-items-center mb-2">
              <div>
                <h5 class="fw-bold mb-1">Registre des animaux</h5>
                <p class="text-muted small mb-0">
                  Liste complète des animaux enregistrés.
                </p>
              </div>

              <button class="btn btn-outline-success btn-sm" @click="loadAnimals">
                <i class="bi bi-arrow-clockwise me-1"></i>
                Actualiser
              </button>
            </div>

            <div class="row g-2">
              <div class="col-md-3">
                <select
                    v-model="filterSpecies"
                    class="form-select form-select-sm"
                    @change="loadAnimals"
                >
                  <option value="">Toutes les espèces</option>
                  <option value="OVIN">Ovins</option>
                  <option value="BOVIN">Bovins</option>
                </select>
              </div>

              <div class="col-md-3">
                <select
                    v-model="filterStatus"
                    class="form-select form-select-sm"
                    @change="loadAnimals"
                >
                  <option value="">Tous les statuts</option>
                  <option value="ACTIVE">Actifs</option>
                  <option value="SOLD">Vendus</option>
                  <option value="DEAD">Décédés</option>
                  <option value="SLAUGHTERED">Abattus</option>
                  <option value="QUARANTINED">Quarantaine</option>
                  <option value="LOST">Perdus</option>
                </select>
              </div>

              <div class="col-md-4">
                <input
                    v-model="searchQuery"
                    type="text"
                    class="form-control form-control-sm"
                    placeholder="Rechercher RFID, race, ferme..."
                />
              </div>

              <div class="col-md-2">
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
                {{ filteredAnimals.length }} / {{ animals.length }} animal(aux)
              </span>
            </div>

            <div class="table-responsive">
              <table class="table mb-0">
                <thead>
                <tr>
                  <th>ID RFID</th>
                  <th>ESPÈCE</th>
                  <th>RACE</th>
                  <th>SEXE</th>
                  <th>POIDS</th>
                  <th>STATUT</th>
                  <th>FERME</th>
                  <th>WILAYA</th>
                  <th>NAISSANCE</th>
                  <th>HISTORIQUE</th>
                </tr>
                </thead>

                <tbody>
                <tr v-if="paginatedAnimals.length === 0">
                  <td colspan="10" class="text-center text-muted py-4">
                    Aucun animal trouvé
                  </td>
                </tr>

                <tr v-for="a in paginatedAnimals" :key="a.id">
                  <td class="fw-bold text-success">
                    {{ a.rfidTag }}
                  </td>

                  <td>{{ formatSpecies(a.species) }}</td>

                  <td>{{ a.breed || '—' }}</td>

                  <td>
                    <span v-if="a.gender === 'MALE'">♂ Mâle</span>
                    <span v-else-if="a.gender === 'FEMALE'">♀ Femelle</span>
                    <span v-else>—</span>
                  </td>

                  <td>{{ a.weight ? a.weight + ' kg' : '—' }}</td>

                  <td>
                      <span class="badge" :class="statusClass(a.status)">
                        {{ formatStatus(a.status) }}
                      </span>
                  </td>

                  <td>{{ a.farmName || '—' }}</td>

                  <td>{{ a.farmWilaya || '—' }}</td>

                  <td>
                    <small>{{ formatDate(a.birthDate) }}</small>
                  </td>

                  <td>
                    <RouterLink
                        :to="`/animals/${a.id}`"
                        class="btn btn-sm btn-outline-success"
                        title="Voir historique"
                    >
                      <i class="bi bi-clock-history"></i>
                    </RouterLink>
                  </td>
                </tr>
                </tbody>
              </table>
            </div>

            <!-- Pagination -->
            <TablePagination
                :current-page="currentPage"
                :total-pages="totalPages"
                :total="filteredAnimals.length"
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
        <!-- PANEL STATISTIQUES -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'stats'" class="page-panel-scroll">

          <div class="row g-2 mb-3">
            <div class="col-md-3">
              <StatCard
                  icon="tags-fill"
                  :value="filteredAnimals.length"
                  label="Affichés"
                  color="#0B5D1E"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="circle-fill"
                  :value="countBySpecies('OVIN')"
                  label="Ovins"
                  color="#0891B2"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="circle-fill"
                  :value="countBySpecies('BOVIN')"
                  label="Bovins"
                  color="#2563EB"
              />
            </div>

            <div class="col-md-3">
              <StatCard
                  icon="check-circle-fill"
                  :value="countByStatus('ACTIVE')"
                  label="Actifs"
                  color="#059669"
              />
            </div>
          </div>

          <div class="data-table">
            <div class="data-table-header">
              <span class="data-table-title">
                Répartition des animaux
              </span>
            </div>

            <div class="table-responsive">
              <table class="table mb-0">
                <thead>
                <tr>
                  <th>CATÉGORIE</th>
                  <th>NOMBRE</th>
                  <th>DESCRIPTION</th>
                </tr>
                </thead>

                <tbody>
                <tr>
                  <td>Ovins</td>
                  <td>{{ countBySpecies('OVIN') }}</td>
                  <td>Total des ovins affichés selon les filtres.</td>
                </tr>

                <tr>
                  <td>Bovins</td>
                  <td>{{ countBySpecies('BOVIN') }}</td>
                  <td>Total des bovins affichés selon les filtres.</td>
                </tr>

                <tr>
                  <td>Actifs</td>
                  <td>{{ countByStatus('ACTIVE') }}</td>
                  <td>Animaux encore actifs dans le système.</td>
                </tr>

                <tr>
                  <td>Vendus</td>
                  <td>{{ countByStatus('SOLD') }}</td>
                  <td>Animaux sortis par vente.</td>
                </tr>

                <tr>
                  <td>Décédés</td>
                  <td>{{ countByStatus('DEAD') }}</td>
                  <td>Animaux déclarés morts.</td>
                </tr>
                </tbody>
              </table>
            </div>
          </div>

        </div>

      </div>
    </div>
  </AdminLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'

import AdminLayout from '@/layouts/AdminLayout.vue'
import StatCard from '@/components/common/StatCard.vue'
import TablePagination from '@/components/common/TablePagination.vue'

import {
  formatDate,
  formatSpecies,
  formatStatus
} from '@/utils/formatters.js'

import { usePagination } from '@/composables/usePagination.js'
import {animalsApi} from "@/api/animalApi.js";


const currentPanel = ref('list')

const loading = ref(true)
const errorMsg = ref('')

const animals = ref([])

const filterSpecies = ref('')
const filterStatus = ref('')
const searchQuery = ref('')

const filteredAnimals = computed(() => {
  let result = animals.value || []

  if (searchQuery.value.trim()) {
    const q = searchQuery.value.toLowerCase()

    result = result.filter(a =>
        a.rfidTag?.toLowerCase().includes(q) ||
        a.breed?.toLowerCase().includes(q) ||
        a.farmName?.toLowerCase().includes(q) ||
        a.farmWilaya?.toLowerCase().includes(q)
    )
  }

  return result
})

const {
  currentPage,
  perPage,
  totalPages,
  paginatedItems: paginatedAnimals,
  from,
  to,
  visiblePages,
  goToPage,
  changePerPage
} = usePagination(filteredAnimals)

onMounted(() => loadAnimals())

async function loadAnimals() {
  loading.value = true
  errorMsg.value = ''

  try {
    const params = {}

    if (filterSpecies.value) {
      params.species = filterSpecies.value
    }

    if (filterStatus.value) {
      params.status = filterStatus.value
    }

    const res = await animalsApi.getAll(params)
    animals.value = Array.isArray(res.data) ? res.data : []
  } catch (e) {
    errorMsg.value =
        e.response?.data?.message ||
        'Erreur chargement animaux'
  } finally {
    loading.value = false
  }
}

function resetFilters() {
  filterSpecies.value = ''
  filterStatus.value = ''
  searchQuery.value = ''
  loadAnimals()
}

function countBySpecies(s) {
  return filteredAnimals.value.filter(a => a.species === s).length
}

function countByStatus(s) {
  return filteredAnimals.value.filter(a => a.status === s).length
}

function statusClass(status) {
  return {
    ACTIVE: 'bg-success',
    SOLD: 'bg-primary',
    DEAD: 'bg-danger',
    SLAUGHTERED: 'bg-dark',
    QUARANTINED: 'bg-warning text-dark',
    LOST: 'bg-secondary'
  }[status] || 'bg-secondary'
}
</script>