<template>
  <AdminLayout page-title="Tableau de Bord">
    <div class="page-section">

      <!-- Navigation interne du dashboard -->
      <div class="page-tabs">
        <button
            :class="{ active: currentPanel === 'global' }"
            @click="currentPanel = 'global'"
        >
          Vue globale
        </button>

        <button
            :class="{ active: currentPanel === 'map' }"
            @click="currentPanel = 'map'"
        >
          Carte des fermes
        </button>

        <button
            :class="{ active: currentPanel === 'charts' }"
            @click="currentPanel = 'charts'"
        >
          Graphiques
        </button>

        <button
            :class="{ active: currentPanel === 'constats' }"
            @click="currentPanel = 'constats'"
        >
          Constats récents
        </button>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-success"></div>
        <p class="text-muted mt-2">Chargement du tableau de bord...</p>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="alert alert-danger">
        {{ error }}
      </div>

      <!-- Content -->
      <div v-else class="page-panel">

        <!-- ===================================================== -->
        <!-- SECTION 1 : VUE GLOBALE -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'global'" class="page-panel-scroll">

          <div class="row g-2 mb-2">
            <div class="col-xl-3 col-md-6">
              <StatCard
                  icon="people-fill"
                  :value="stats.totalUtilisateurs || 0"
                  label="Utilisateurs terrain"
                  color="#0B5D1E"
              />
            </div>

            <div class="col-xl-3 col-md-6">
              <StatCard
                  icon="house-fill"
                  :value="stats.totalFermes || 0"
                  label="Fermes"
                  color="#1D4ED8"
              />
            </div>

            <div class="col-xl-3 col-md-6">
              <StatCard
                  icon="tags-fill"
                  :value="stats.totalAnimaux || 0"
                  label="Total animaux"
                  color="#0891B2"
              />
            </div>

            <div class="col-xl-3 col-md-6">
              <StatCard
                  icon="check-circle-fill"
                  :value="stats.animauxActifs || 0"
                  label="Animaux actifs"
                  color="#059669"
              />
            </div>
          </div>

          <div class="row g-2 mb-2">
            <div class="col-xl-3 col-md-6">
              <StatCard
                  icon="file-earmark-text-fill"
                  :value="stats.constatsEnAttente || 0"
                  label="Constats en attente"
                  color="#DC2626"
              />
            </div>

            <div class="col-xl-3 col-md-6">
              <StatCard
                  icon="arrow-left-right"
                  :value="stats.totalMovements || 0"
                  label="Mouvements"
                  color="#7C3AED"
              />
            </div>

            <div class="col-xl-3 col-md-6">
              <StatCard
                  icon="circle-fill"
                  :value="stats.animauxOvins || 0"
                  label="Ovins actifs"
                  color="#EA580C"
              />
            </div>

            <div class="col-xl-3 col-md-6">
              <StatCard
                  icon="circle-fill"
                  :value="stats.animauxBovins || 0"
                  label="Bovins actifs"
                  color="#2563EB"
              />
            </div>
          </div>

          <div class="chart-container mt-2">
            <h6 class="fw-bold mb-2">
              <i class="bi bi-info-circle me-2 text-success"></i>
              État général de la plateforme
            </h6>

            <div class="row g-2">
              <div class="col-md-4">
                <div class="p-2 bg-light rounded">
                  <div class="text-muted small">Backend</div>
                  <strong class="text-success">Opérationnel</strong>
                </div>
              </div>

              <div class="col-md-4">
                <div class="p-2 bg-light rounded">
                  <div class="text-muted small">Base centralisée</div>
                  <strong class="text-success">Connectée</strong>
                </div>
              </div>

              <div class="col-md-4">
                <div class="p-2 bg-light rounded">
                  <div class="text-muted small">Sécurité</div>
                  <strong>JWT + RBAC</strong>
                </div>
              </div>
            </div>
          </div>

          <div class="chart-container mt-2">
            <h6 class="fw-bold mb-2">
              <i class="bi bi-check2-circle me-2 text-success"></i>
              Rappel fonctionnel
            </h6>

            <ul class="mb-0 text-muted small">
              <li>Les fermiers gèrent uniquement les animaux de leur exploitation.</li>
              <li>Les vétérinaires consultent et complètent les dossiers médicaux.</li>
              <li>Les contrôleurs vérifient les effectifs et déclarent les constats.</li>
              <li>Les administrateurs supervisent les données depuis cette interface.</li>
            </ul>
          </div>
        </div>

        <!-- ===================================================== -->
        <!-- SECTION 2 : CARTE -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'map'" class="page-panel-scroll">
          <FarmMap :farms="farms" />
        </div>

        <!-- ===================================================== -->
        <!-- SECTION 3 : GRAPHIQUES -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'charts'" class="page-panel-scroll">

          <div class="row g-2">
            <div class="col-md-4">
              <div class="chart-container">
                <h6 class="fw-bold mb-2">
                  <i class="bi bi-pie-chart-fill me-2 text-success"></i>
                  Répartition par espèce
                </h6>

                <Doughnut
                    v-if="speciesChartData.labels.length > 0"
                    :data="speciesChartData"
                    :options="doughnutOptions"
                />

                <div v-else class="text-muted text-center py-3">
                  Aucune donnée
                </div>
              </div>
            </div>

            <div class="col-md-8">
              <div class="chart-container">
                <h6 class="fw-bold mb-2">
                  <i class="bi bi-bar-chart-fill me-2 text-success"></i>
                  Animaux par wilaya
                </h6>

                <Bar
                    v-if="wilayaChartData.labels.length > 0"
                    :data="wilayaChartData"
                    :options="barOptions"
                />

                <div v-else class="text-muted text-center py-3">
                  Aucune donnée
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- ===================================================== -->
        <!-- SECTION 4 : CONSTATS -->
        <!-- ===================================================== -->
        <div v-if="currentPanel === 'constats'" class="page-panel-scroll">
          <div class="data-table">
            <div class="data-table-header">
              <span class="data-table-title">
                <i class="bi bi-file-earmark-text-fill me-2 text-success"></i>
                Derniers constats
              </span>

              <RouterLink to="/constats" class="btn btn-sm btn-outline-success">
                Voir tout
              </RouterLink>
            </div>

            <div class="table-responsive">
              <table class="table mb-0">
                <thead>
                <tr>
                  <th>ID</th>
                  <th>TYPE</th>
                  <th>DESCRIPTION</th>
                  <th>CONTRÔLEUR</th>
                  <th>FERME</th>
                  <th>STATUT</th>
                  <th>DATE</th>
                </tr>
                </thead>

                <tbody>
                <tr v-if="lastConstats.length === 0">
                  <td colspan="7" class="text-center text-muted py-4">
                    Aucun constat
                  </td>
                </tr>

                <tr v-for="c in lastConstats" :key="c.id">
                  <td>#{{ c.id }}</td>

                  <td>
                      <span class="badge" :class="typeBadge(c.type)">
                        {{ c.type }}
                      </span>
                  </td>

                  <td style="max-width:260px;" class="text-truncate">
                    {{ c.description }}
                  </td>

                  <td>{{ c.controleurUsername || '—' }}</td>

                  <td>{{ c.farmName || '—' }}</td>

                  <td>
                      <span class="badge" :class="statusBadge(c.status)">
                        {{ formatStatus(c.status) }}
                      </span>
                  </td>

                  <td>
                    <small>{{ formatDateTime(c.createdAt) }}</small>
                  </td>
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

import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  ArcElement,
  Tooltip,
  Legend
} from 'chart.js'

import { Bar, Doughnut } from 'vue-chartjs'

import AdminLayout from '@/layouts/AdminLayout.vue'
import StatCard from '@/components/common/StatCard.vue'
import FarmMap from '@/components/common/FarmMap.vue'
import api from '@/api/axios.js'

import {
  formatDateTime,
  formatStatus
} from '@/utils/formatters.js'

ChartJS.register(
    CategoryScale,
    LinearScale,
    BarElement,
    ArcElement,
    Tooltip,
    Legend
)

const loading = ref(true)
const error = ref('')
const currentPanel = ref('global')

const stats = ref({})
const farms = ref([])
const wilayas = ref([])
const speciesList = ref([])
const lastConstats = ref([])

const doughnutOptions = {
  responsive: true,
  maintainAspectRatio: true,
  plugins: {
    legend: {
      position: 'bottom'
    }
  }
}

const barOptions = {
  responsive: true,
  maintainAspectRatio: true,
  plugins: {
    legend: {
      position: 'bottom'
    }
  }
}

const speciesChartData = computed(() => {
  const list = speciesList.value || []

  return {
    labels: list.map(s => {
      if (s.species === 'OVIN') return 'Ovins'
      if (s.species === 'BOVIN') return 'Bovins'
      return s.species || ''
    }),
    datasets: [
      {
        data: list.map(s => Number(s.count) || 0),
        backgroundColor: ['#059669', '#2563EB', '#EA580C', '#7C3AED'],
        borderWidth: 0
      }
    ]
  }
})

const wilayaChartData = computed(() => {
  const list = wilayas.value || []

  return {
    labels: list.map(w => w.wilaya || 'Inconnue'),
    datasets: [
      {
        label: 'Animaux',
        data: list.map(w => Number(w.totalAnimaux) || 0),
        backgroundColor: '#0B5D1E'
      },
      {
        label: 'Fermes',
        data: list.map(w => Number(w.totalFermes) || 0),
        backgroundColor: '#A7F3D0'
      }
    ]
  }
})

onMounted(async () => {
  await loadDashboard()
})

async function loadDashboard() {
  loading.value = true
  error.value = ''

  try {
    const [
      dashRes,
      wilayaRes,
      speciesRes,
      constatsRes,
      farmsRes
    ] = await Promise.all([
      api.get('/admin/dashboard').catch(() => ({ data: {} })),
      api.get('/admin/stats/by-wilaya').catch(() => ({ data: [] })),
      api.get('/admin/stats/by-species').catch(() => ({ data: [] })),
      api.get('/admin/constats').catch(() => ({ data: [] })),
      api.get('/admin/farms').catch(() => ({ data: [] }))
    ])

    stats.value = dashRes.data || {}
    wilayas.value = Array.isArray(wilayaRes.data) ? wilayaRes.data : []
    speciesList.value = Array.isArray(speciesRes.data) ? speciesRes.data : []
    lastConstats.value = Array.isArray(constatsRes.data)
        ? constatsRes.data.slice(0, 8)
        : []
    farms.value = Array.isArray(farmsRes.data) ? farmsRes.data : []
  } catch (e) {
    console.error('Erreur dashboard :', e)
    error.value = 'Erreur de chargement du tableau de bord'
  } finally {
    loading.value = false
  }
}

function typeBadge(type) {
  return {
    FRAUDE: 'bg-danger',
    MANQUANT: 'bg-warning text-dark',
    DOUBLON: 'bg-dark',
    AUTRE: 'bg-secondary'
  }[type] || 'bg-secondary'
}

function statusBadge(status) {
  return {
    PENDING: 'bg-warning text-dark',
    IN_REVIEW: 'bg-primary',
    RESOLVED: 'bg-success',
    REJECTED: 'bg-danger'
  }[status] || 'bg-secondary'
}
</script>