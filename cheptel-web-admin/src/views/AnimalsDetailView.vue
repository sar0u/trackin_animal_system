<template>
  <AdminLayout :page-title="animal ? `Historique — ${animal.rfidTag}` : 'Historique Animal'">

    <div class="mb-3">
      <button class="btn btn-outline-secondary btn-sm" @click="$router.back()">
        <i class="bi bi-arrow-left me-1"></i>
        Retour
      </button>
    </div>

    <div v-if="loading" class="text-center py-5">
      <div class="spinner-border text-success"></div>
      <p class="text-muted mt-2">Chargement de l'historique...</p>
    </div>

    <div v-else-if="error" class="alert alert-danger">
      <i class="bi bi-exclamation-triangle me-2"></i>
      {{ error }}
    </div>

    <div v-else-if="!animal" class="alert alert-warning">
      Animal introuvable.
    </div>

    <div v-else>

      <!-- Identité + Filiation -->
      <div class="row g-3 mb-4">

        <div class="col-md-8">
          <div class="data-table h-100">
            <div class="data-table-header">
              <span class="data-table-title">
                <i class="bi bi-tag-fill me-2 text-success"></i>
                Identité de l'animal
              </span>
            </div>

            <div class="p-4">
              <div class="row">
                <div class="col-md-6">
                  <table class="table table-sm table-borderless mb-0">
                    <tbody>
                    <tr>
                      <td class="text-muted">Tag RFID</td>
                      <td class="fw-bold text-success">{{ animal.rfidTag }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Espèce</td>
                      <td>{{ formatSpecies(animal.species) }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Race</td>
                      <td>{{ animal.breed || '—' }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Sexe</td>
                      <td>{{ animal.gender === 'MALE' ? '♂ Mâle' : '♀ Femelle' }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Couleur</td>
                      <td>{{ animal.color || '—' }}</td>
                    </tr>
                    </tbody>
                  </table>
                </div>

                <div class="col-md-6">
                  <table class="table table-sm table-borderless mb-0">
                    <tbody>
                    <tr>
                      <td class="text-muted">Naissance</td>
                      <td>{{ formatDate(animal.birthDate) }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Poids</td>
                      <td>{{ animal.weight ? animal.weight + ' kg' : '—' }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Statut</td>
                      <td>
                          <span class="badge" :class="statusBadge(animal.status)">
                            {{ formatStatus(animal.status) }}
                          </span>
                      </td>
                    </tr>
                    <tr>
                      <td class="text-muted">Ferme actuelle</td>
                      <td class="fw-bold text-success">{{ animal.currentFarm || '—' }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Wilaya</td>
                      <td>{{ animal.currentFarmWilaya || '—' }}</td>
                    </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-4">
          <div class="data-table h-100">
            <div class="data-table-header">
              <span class="data-table-title">
                <i class="bi bi-diagram-2-fill me-2 text-success"></i>
                Filiation
              </span>
            </div>

            <div class="p-4">
              <div class="mb-3">
                <div class="text-muted small fw-semibold mb-1">MÈRE</div>
                <div v-if="animal.mother" class="border rounded p-2" style="background:#F7FAF5;">
                  <div class="fw-bold text-success">{{ animal.mother.rfidTag }}</div>
                  <small class="text-muted">
                    {{ formatSpecies(animal.mother.species) }} — {{ animal.mother.breed || '—' }}
                  </small>
                  <br />
                  <RouterLink
                      :to="`/animals/${encodeURIComponent(animal.mother.rfidTag)}`"
                      class="btn btn-sm btn-outline-success mt-1"
                  >
                    Voir
                  </RouterLink>
                </div>
                <div v-else class="text-muted fst-italic small">Non renseignée</div>
              </div>

              <div>
                <div class="text-muted small fw-semibold mb-1">PÈRE</div>
                <div v-if="animal.father" class="border rounded p-2" style="background:#F7FAF5;">
                  <div class="fw-bold text-success">{{ animal.father.rfidTag }}</div>
                  <small class="text-muted">
                    {{ formatSpecies(animal.father.species) }} — {{ animal.father.breed || '—' }}
                  </small>
                  <br />
                  <RouterLink
                      :to="`/animals/${encodeURIComponent(animal.father.rfidTag)}`"
                      class="btn btn-sm btn-outline-success mt-1"
                  >
                    Voir
                  </RouterLink>
                </div>
                <div v-else class="text-muted fst-italic small">Non renseigné</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Descendance -->
      <div v-if="animal.offspring && animal.offspring.length > 0" class="data-table mb-4">
        <div class="data-table-header">
          <span class="data-table-title">
            <i class="bi bi-diagram-3-fill me-2 text-success"></i>
            Descendants ({{ animal.offspring.length }})
          </span>
        </div>

        <div class="table-responsive">
          <table class="table mb-0">
            <thead>
            <tr>
              <th>RFID</th>
              <th>ESPÈCE</th>
              <th>RACE</th>
              <th>SEXE</th>
              <th>NAISSANCE</th>
              <th>STATUT</th>
              <th>RELATION</th>
              <th>ACTION</th>
            </tr>
            </thead>

            <tbody>
            <tr v-for="child in animal.offspring" :key="child.id">
              <td class="fw-semibold text-success">{{ child.rfidTag }}</td>
              <td>{{ formatSpecies(child.species) }}</td>
              <td>{{ child.breed || '—' }}</td>
              <td>{{ child.gender === 'MALE' ? '♂' : '♀' }}</td>
              <td>{{ formatDate(child.birthDate) }}</td>
              <td>
                  <span class="badge" :class="statusBadge(child.status)">
                    {{ formatStatus(child.status) }}
                  </span>
              </td>
              <td><span class="badge bg-info text-dark">{{ child.relation }}</span></td>
              <td>
                <RouterLink
                    :to="`/animals/${encodeURIComponent(child.rfidTag)}`"
                    class="btn btn-sm btn-outline-primary"
                >
                  <i class="bi bi-eye"></i>
                </RouterLink>
              </td>
            </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Mouvements -->
      <div class="data-table mb-4">
        <div class="data-table-header">
          <span class="data-table-title">
            <i class="bi bi-arrow-left-right me-2 text-success"></i>
            Mouvements ({{ animal.movements?.length || 0 }})
          </span>
        </div>

        <div class="table-responsive">
          <table class="table mb-0">
            <thead>
            <tr>
              <th>TYPE</th>
              <th>DE</th>
              <th>VERS</th>
              <th>PRIX</th>
              <th>CONTREPARTIE</th>
              <th>PAR</th>
              <th>DATE</th>
            </tr>
            </thead>

            <tbody>
            <tr v-if="!animal.movements || animal.movements.length === 0">
              <td colspan="7" class="text-center text-muted py-3">Aucun mouvement</td>
            </tr>

            <tr v-for="m in animal.movements" :key="m.id">
              <td>
                <span class="badge" :class="movementBadge(m.type)">{{ m.type }}</span>
              </td>
              <td>{{ m.fromFarm || '—' }}</td>
              <td>{{ m.toFarm || '—' }}</td>
              <td>{{ m.price ? m.price + ' DA' : '—' }}</td>
              <td>{{ m.counterpartyName || '—' }}</td>
              <td>{{ m.performedBy || '—' }}</td>
              <td><small>{{ formatDateTime(m.date) }}</small></td>
            </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Vaccinations -->
      <div class="data-table mb-4">
        <div class="data-table-header">
          <span class="data-table-title">
            <i class="bi bi-shield-fill-check me-2 text-success"></i>
            Vaccinations ({{ animal.vaccinations?.length || 0 }})
          </span>
        </div>

        <div class="table-responsive">
          <table class="table mb-0">
            <thead>
            <tr>
              <th>VACCIN</th>
              <th>TYPE</th>
              <th>FABRICANT</th>
              <th>LOT</th>
              <th>DATE ADMIN.</th>
              <th>EXPIRATION</th>
              <th>VÉTÉRINAIRE</th>
            </tr>
            </thead>

            <tbody>
            <tr v-if="!animal.vaccinations || animal.vaccinations.length === 0">
              <td colspan="7" class="text-center text-muted py-3">Aucune vaccination</td>
            </tr>

            <tr v-for="v in animal.vaccinations" :key="v.id">
              <td class="fw-semibold">{{ v.vaccineName }}</td>
              <td>{{ v.vaccineType || '—' }}</td>
              <td>{{ v.manufacturer || '—' }}</td>
              <td>{{ v.batchNumber || '—' }}</td>
              <td>{{ formatDate(v.vaccinationDate) }}</td>
              <td>
                  <span :class="isExpired(v.expirationDate) ? 'text-danger fw-bold' : 'text-success'">
                    {{ formatDate(v.expirationDate) }}
                    <i v-if="isExpired(v.expirationDate)" class="bi bi-exclamation-triangle-fill ms-1"></i>
                  </span>
              </td>
              <td>{{ v.veterinarian || '—' }}</td>
            </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Dossiers médicaux -->
      <div class="data-table mb-4">
        <div class="data-table-header">
          <span class="data-table-title">
            <i class="bi bi-file-medical-fill me-2 text-success"></i>
            Dossiers Médicaux ({{ animal.healthRecords?.length || 0 }})
          </span>
        </div>

        <div class="table-responsive">
          <table class="table mb-0">
            <thead>
            <tr>
              <th>TYPE</th>
              <th>DIAGNOSTIC</th>
              <th>TRAITEMENT</th>
              <th>SÉVÉRITÉ</th>
              <th>VÉTÉRINAIRE</th>
              <th>DATE</th>
              <th>RÉSOLU</th>
            </tr>
            </thead>

            <tbody>
            <tr v-if="!animal.healthRecords || animal.healthRecords.length === 0">
              <td colspan="7" class="text-center text-muted py-3">Aucun dossier médical</td>
            </tr>

            <tr v-for="r in animal.healthRecords" :key="r.id">
              <td><span class="badge bg-secondary">{{ r.recordType }}</span></td>
              <td>{{ r.diagnosis || '—' }}</td>
              <td>{{ r.treatment || '—' }}</td>
              <td>
                  <span class="badge" :class="severityBadge(r.severity)">
                    {{ r.severity || '—' }}
                  </span>
              </td>
              <td>{{ r.veterinarian || '—' }}</td>
              <td><small>{{ formatDateTime(r.visitDate) }}</small></td>
              <td>
                <i :class="r.isResolved ? 'bi bi-check-circle-fill text-success' : 'bi bi-x-circle-fill text-danger'"></i>
              </td>
            </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Événements -->
      <div class="data-table mb-4">
        <div class="data-table-header">
          <span class="data-table-title">
            <i class="bi bi-activity me-2 text-success"></i>
            Événements Cycle de Vie ({{ animal.events?.length || 0 }})
          </span>
        </div>

        <div class="table-responsive">
          <table class="table mb-0">
            <thead>
            <tr>
              <th>TYPE</th>
              <th>LOCALISATION</th>
              <th>PAR</th>
              <th>DATE</th>
              <th>NOTES</th>
            </tr>
            </thead>

            <tbody>
            <tr v-if="!animal.events || animal.events.length === 0">
              <td colspan="5" class="text-center text-muted py-3">Aucun événement</td>
            </tr>

            <tr v-for="e in animal.events" :key="e.id">
              <td><span class="badge bg-primary">{{ e.eventType }}</span></td>
              <td>{{ e.location || '—' }}</td>
              <td>{{ e.performedBy || '—' }}</td>
              <td><small>{{ formatDateTime(e.eventDate) }}</small></td>
              <td><small class="text-muted">{{ e.notes || '—' }}</small></td>
            </tr>
            </tbody>
          </table>
        </div>
      </div>

    </div>

  </AdminLayout>
</template>

<script setup>


import {formatDate, formatDateTime, formatSpecies, formatStatus} from "../utils/formatters.js";
import AdminLayout from "@/layouts/AdminLayout.vue";
import {animalsApi} from "@/api/animalApi.js";
import {useRoute} from "vue-router";
import {onMounted, ref} from "vue";

const route = useRoute()
const loading = ref(true)
const error = ref('')
const animal = ref(null)

onMounted(() => {
  loadAnimal()
})

async function loadAnimal() {
  loading.value = true
  error.value = ''
  animal.value = null

  try {
    const res = await animalsApi.getHistory(route.params.id)
    animal.value = res.data
  } catch (e) {
    console.error('Erreur historique animal :', e)
    error.value = e.response?.data?.message || 'Animal non disponible'
  } finally {
    loading.value = false
  }
}

function statusBadge(status) {
  return {
    ACTIVE: 'bg-success',
    SOLD: 'bg-primary',
    DEAD: 'bg-danger',
    SLAUGHTERED: 'bg-dark',
    QUARANTINED: 'bg-warning text-dark',
    LOST: 'bg-secondary'
  }[status] || 'bg-secondary'
}

function movementBadge(type) {
  return {
    SALE: 'bg-primary',
    PURCHASE: 'bg-success',
    TRANSFER: 'bg-info text-dark',
    DEATH: 'bg-danger',
    SLAUGHTER: 'bg-dark',
    BIRTH: 'bg-warning text-dark'
  }[type] || 'bg-secondary'
}

function severityBadge(severity) {
  return {
    CRITICAL: 'bg-danger',
    HIGH: 'bg-warning text-dark',
    MEDIUM: 'bg-info text-dark',
    LOW: 'bg-success',
    INFO: 'bg-info text-dark'
  }[severity] || 'bg-secondary'
}

function isExpired(dateStr) {
  if (!dateStr) return false
  return new Date(dateStr) < new Date()
}
</script>