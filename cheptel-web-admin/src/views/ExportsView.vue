<template>
  <AdminLayout page-title="Exports">

    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h5 class="fw-bold mb-1">Export des données</h5>
        <p class="text-muted small mb-0">
          Exportez les données de la plateforme DZcheptel au format Excel.
        </p>
      </div>

      <button
          class="btn btn-success"
          @click="exportAll"
          :disabled="loading"
      >
        <i class="bi bi-download me-2"></i>
        Export global
      </button>
    </div>

    <div class="alert alert-info">
      <i class="bi bi-info-circle me-2"></i>
      Les exports sont générés à partir des données réelles de la base MySQL.
    </div>

    <div class="row g-4 mb-4">

      <div class="col-md-6 col-xl-3">
        <div class="export-card">
          <div class="export-icon bg-success-subtle text-success">
            <i class="bi bi-tags-fill"></i>
          </div>

          <h5>Animaux</h5>

          <p class="text-muted small">
            RFID, espèce, race, statut, ferme et poids.
          </p>

          <button
              class="btn btn-success w-100"
              @click="exportAnimals"
              :disabled="loading"
          >
            <i class="bi bi-file-earmark-excel me-2"></i>
            Export Animaux
          </button>
        </div>
      </div>

      <div class="col-md-6 col-xl-3">
        <div class="export-card">
          <div class="export-icon bg-primary-subtle text-primary">
            <i class="bi bi-house-fill"></i>
          </div>

          <h5>Fermes</h5>

          <p class="text-muted small">
            Exploitations, propriétaires, wilayas, coordonnées.
          </p>

          <button
              class="btn btn-primary w-100"
              @click="exportFarms"
              :disabled="loading"
          >
            <i class="bi bi-file-earmark-excel me-2"></i>
            Export Fermes
          </button>
        </div>
      </div>

      <div class="col-md-6 col-xl-3">
        <div class="export-card">
          <div class="export-icon bg-danger-subtle text-danger">
            <i class="bi bi-file-earmark-text-fill"></i>
          </div>

          <h5>Constats</h5>

          <p class="text-muted small">
            Anomalies, statut, contrôleur, ferme et date.
          </p>

          <button
              class="btn btn-danger w-100"
              @click="exportConstats"
              :disabled="loading"
          >
            <i class="bi bi-file-earmark-excel me-2"></i>
            Export Constats
          </button>
        </div>
      </div>

      <div class="col-md-6 col-xl-3">
        <div class="export-card">
          <div class="export-icon bg-warning-subtle text-warning">
            <i class="bi bi-bell-fill"></i>
          </div>

          <h5>Alertes</h5>

          <p class="text-muted small">
            Alertes sanitaires, animaux, sévérité et échéances.
          </p>

          <button
              class="btn btn-warning w-100"
              @click="exportAlerts"
              :disabled="loading"
          >
            <i class="bi bi-file-earmark-excel me-2"></i>
            Export Alertes
          </button>
        </div>
      </div>

    </div>

    <div v-if="loading" class="text-center py-4">
      <div class="spinner-border text-success"></div>
      <p class="text-muted mt-2">Génération de l’export...</p>
    </div>

    <div v-if="error" class="alert alert-danger">
      {{ error }}
    </div>

    <div v-if="lastExport" class="alert alert-success">
      <i class="bi bi-check-circle me-2"></i>
      Dernier export généré :
      <strong>{{ lastExport }}</strong>
    </div>

    <div v-if="history.length > 0" class="data-table">
      <div class="data-table-header">
        <span class="data-table-title">
          Historique local des exports
        </span>
      </div>

      <div class="table-responsive">
        <table class="table mb-0">
          <thead>
          <tr>
            <th>FICHIER</th>
            <th>TYPE</th>
            <th>DATE</th>
          </tr>
          </thead>

          <tbody>
          <tr v-for="(h, i) in history" :key="i">
            <td>{{ h.file }}</td>
            <td>
                <span class="badge bg-success">
                  {{ h.type }}
                </span>
            </td>
            <td>{{ h.date }}</td>
          </tr>
          </tbody>
        </table>
      </div>
    </div>

  </AdminLayout>
</template>

<script setup>
import { ref } from 'vue'
import * as XLSX from 'xlsx'
import AdminLayout from "@/layouts/AdminLayout.vue";
import api from "@/api/axios.js";



const loading = ref(false)
const error = ref('')
const lastExport = ref('')
const history = ref([])

async function fetchData(url) {
  const res = await api.get(url)
  return Array.isArray(res.data) ? res.data : []
}

function writeExcel(data, sheetName, fileName, type) {
  if (!data || data.length === 0) {
    alert('Aucune donnée à exporter')
    return
  }

  const worksheet = XLSX.utils.json_to_sheet(data)
  const workbook = XLSX.utils.book_new()

  XLSX.utils.book_append_sheet(workbook, worksheet, sheetName)
  XLSX.writeFile(workbook, fileName)

  lastExport.value = fileName

  history.value.unshift({
    file: fileName,
    type,
    date: new Date().toLocaleString('fr-FR')
  })
}

async function exportAnimals() {
  await doExport(
      '/admin/export/animals',
      'Animaux',
      `dzcheptel_animaux_${dateSuffix()}.xlsx`,
      'Animaux'
  )
}

async function exportFarms() {
  await doExport(
      '/admin/export/farms',
      'Fermes',
      `dzcheptel_fermes_${dateSuffix()}.xlsx`,
      'Fermes'
  )
}

async function exportConstats() {
  await doExport(
      '/admin/export/constats',
      'Constats',
      `dzcheptel_constats_${dateSuffix()}.xlsx`,
      'Constats'
  )
}

async function exportAlerts() {
  await doExport(
      '/admin/export/alerts',
      'Alertes',
      `dzcheptel_alertes_${dateSuffix()}.xlsx`,
      'Alertes'
  )
}

async function doExport(url, sheetName, fileName, type) {
  loading.value = true
  error.value = ''

  try {
    const data = await fetchData(url)
    writeExcel(data, sheetName, fileName, type)
  } catch (e) {
    console.error(e)
    error.value = e.response?.data?.message || 'Erreur lors de l’export'
  } finally {
    loading.value = false
  }
}

async function exportAll() {
  loading.value = true
  error.value = ''

  try {
    const [animals, farms, constats, alerts] = await Promise.all([
      fetchData('/admin/export/animals'),
      fetchData('/admin/export/farms'),
      fetchData('/admin/export/constats'),
      fetchData('/admin/export/alerts')
    ])

    const workbook = XLSX.utils.book_new()

    XLSX.utils.book_append_sheet(
        workbook,
        XLSX.utils.json_to_sheet(animals),
        'Animaux'
    )

    XLSX.utils.book_append_sheet(
        workbook,
        XLSX.utils.json_to_sheet(farms),
        'Fermes'
    )

    XLSX.utils.book_append_sheet(
        workbook,
        XLSX.utils.json_to_sheet(constats),
        'Constats'
    )

    XLSX.utils.book_append_sheet(
        workbook,
        XLSX.utils.json_to_sheet(alerts),
        'Alertes'
    )

    const fileName = `dzcheptel_export_global_${dateSuffix()}.xlsx`

    XLSX.writeFile(workbook, fileName)

    lastExport.value = fileName

    history.value.unshift({
      file: fileName,
      type: 'Global',
      date: new Date().toLocaleString('fr-FR')
    })
  } catch (e) {
    console.error(e)
    error.value = e.response?.data?.message || 'Erreur export global'
  } finally {
    loading.value = false
  }
}

function dateSuffix() {
  const d = new Date()

  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  const hh = String(d.getHours()).padStart(2, '0')
  const mi = String(d.getMinutes()).padStart(2, '0')

  return `${yyyy}${mm}${dd}_${hh}${mi}`
}
</script>

<style scoped>
.export-card {
  background: white;
  border: 1px solid var(--border-color);
  border-radius: 18px;
  padding: 24px;
  height: 100%;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.export-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 24px rgba(0,0,0,0.08);
}

.export-icon {
  width: 58px;
  height: 58px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 26px;
  margin-bottom: 16px;
}

.export-card h5 {
  font-weight: 700;
  margin-bottom: 8px;
}
</style>