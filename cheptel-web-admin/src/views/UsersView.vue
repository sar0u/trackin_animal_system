<template>
  <AdminLayout page-title="Gestion des Utilisateurs">

    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h5 class="mb-1 fw-bold">Utilisateurs terrain</h5>
        <p class="text-muted mb-0 small">
          Gérez les comptes fermiers, vétérinaires et contrôleurs.
        </p>
      </div>

      <button class="btn btn-success" @click="openCreate">
        <i class="bi bi-person-plus me-2"></i>
        Créer
      </button>
    </div>

    <div class="row g-3 mb-4">
      <div class="col-md-5">
        <input
            v-model="search"
            type="text"
            class="form-control"
            placeholder="Rechercher nom, email, téléphone..."
        />
      </div>

      <div class="col-md-3">
        <select v-model="roleFilter" class="form-select">
          <option value="">Tous les rôles</option>
          <option value="FERMIER">Fermiers</option>
          <option value="VETERINAIRE">Vétérinaires</option>
          <option value="CONTROLEUR">Contrôleurs</option>
        </select>
      </div>

      <div class="col-md-2">
        <select v-model="statusFilter" class="form-select">
          <option value="">Tous</option>
          <option value="true">Actifs</option>
          <option value="false">Désactivés</option>
        </select>
      </div>

      <div class="col-md-2">
        <button class="btn btn-outline-secondary w-100" @click="resetFilters">
          Reset
        </button>
      </div>
    </div>

    <div v-if="loading" class="text-center py-5">
      <div class="spinner-border text-success"></div>
    </div>

    <div v-else-if="errorMsg" class="alert alert-danger">
      {{ errorMsg }}
    </div>

    <div v-else class="data-table">
      <div class="data-table-header">
        <span class="data-table-title">
          {{ filteredUsers.length }} utilisateur(s)
        </span>
      </div>

      <div class="table-responsive">
        <table class="table mb-0">
          <thead>
          <tr>
            <th>ID</th>
            <th>NOM</th>
            <th>EMAIL</th>
            <th>TÉLÉPHONE</th>
            <th>RÔLE</th>
            <th>FERME</th>
            <th>STATUT</th>
            <th>CRÉÉ LE</th>
            <th>ACTIONS</th>
          </tr>
          </thead>

          <tbody>
          <tr v-if="filteredUsers.length === 0">
            <td colspan="9" class="text-center text-muted py-4">
              Aucun utilisateur trouvé
            </td>
          </tr>

          <tr v-for="u in paginatedUsers" :key="u.id">
            <td>#{{ u.id }}</td>
            <td class="fw-semibold">{{ u.username }}</td>
            <td>{{ u.email || '—' }}</td>
            <td>{{ u.phoneNumber || '—' }}</td>


            <td>
                <span :class="getRoleBadge(u.role)">
                  {{ formatRole(u.role) }}
                </span>
            </td>

            <td>{{ u.farmName || '—' }}</td>

            <td>
                <span :class="u.enabled ? 'badge bg-success' : 'badge bg-danger'">
                  {{ u.enabled ? 'Actif' : 'Désactivé' }}
                </span>
            </td>

            <td>
              <small>{{ formatDate(u.createdAt) }}</small>
            </td>

            <td>
              <div class="btn-group btn-group-sm">
                <button
                    class="btn btn-outline-primary"
                    title="Modifier"
                    @click="openEdit(u)"
                >
                  <i class="bi bi-pencil"></i>
                </button>

                <button
                    class="btn"
                    :class="u.enabled ? 'btn-outline-warning' : 'btn-outline-success'"
                    @click="toggleUser(u)"
                >
                  <i :class="u.enabled ? 'bi bi-pause-fill' : 'bi bi-play-fill'"></i>
                </button>

                <button
                    class="btn btn-outline-danger"
                    @click="deleteUser(u)"
                >
                  <i class="bi bi-trash"></i>
                </button>
              </div>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal -->
    <div
        v-if="showModal"
        class="modal d-block"
        style="background:rgba(0,0,0,0.5);"
    >
      <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              {{ isEditMode ? 'Modifier' : 'Créer' }} un utilisateur
            </h5>
            <button class="btn-close" @click="closeModal"></button>
          </div>

          <div class="modal-body">
            <div class="row g-3">

              <div class="col-md-6">
                <label class="form-label">Nom d'utilisateur *</label>
                <input
                    v-model="form.username"
                    type="text"
                    class="form-control"
                    placeholder="ex: fermier01"
                />
              </div>

              <div class="col-md-6">
                <label class="form-label">Email *</label>
                <input
                    v-model="form.email"
                    type="email"
                    class="form-control"
                    placeholder="ex: user@cheptel.dz"
                />
              </div>

              <div class="col-md-6">
                <label class="form-label">Téléphone</label>
                <input
                    v-model="form.phoneNumber"
                    type="text"
                    class="form-control"
                    placeholder="ex: 0555123456"
                />
              </div>

              <div class="col-12">
                <div class="alert alert-info py-2 small">
                  <i class="bi bi-info-circle me-2"></i>
                  Depuis l'interface web, seuls les comptes <strong>Administrateur</strong> peuvent être créés.
                  Les autres rôles (Fermier, Vétérinaire, Contrôleur) sont créés depuis l'application mobile.
                </div>
              </div>

              <div class="col-12" v-if="form.role === 'FERMIER'">
                <label class="form-label">Ferme associée</label>
                <select v-model="form.farmId" class="form-select">
                  <option value="">— Aucune ferme —</option>
                  <option
                      v-for="f in farms"
                      :key="f.id"
                      :value="f.id"
                  >
                    {{ f.name }} — {{ f.wilaya || '' }}
                  </option>
                </select>
                <small class="text-muted">
                  Le fermier ne pourra voir que les animaux de cette ferme.
                </small>
              </div>

              <div class="col-12" v-if="!isEditMode">
                <label class="form-label">Mot de passe *</label>
                <input
                    v-model="form.password"
                    type="text"
                    class="form-control"
                    placeholder="Minimum 6 caractères"
                />
              </div>

              <div v-if="modalError" class="col-12">
                <div class="alert alert-danger py-2">
                  {{ modalError }}
                </div>
              </div>

            </div>
          </div>

          <div class="modal-footer">
            <button class="btn btn-secondary" @click="closeModal">
              Annuler
            </button>

            <button
                class="btn btn-success"
                @click="saveUser"
                :disabled="saving"
            >
              <span
                  v-if="saving"
                  class="spinner-border spinner-border-sm me-2"
              ></span>
              {{ isEditMode ? 'Mettre à jour' : 'Créer' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast -->
    <div
        v-if="toast"
        class="position-fixed bottom-0 end-0 p-3"
        style="z-index:9999;"
    >
      <div class="toast show bg-success text-white">
        <div class="toast-body">{{ toast }}</div>
      </div>
    </div>

    <TablePagination
        :current-page="currentPage"
        :total-pages="totalPages"
        :total="filteredUsers.length"
        :per-page="perPage"
        @change="currentPage = $event"
        @per-page-change="(v) => { perPage = v; currentPage = 1 }"
    />

  </AdminLayout>
</template>

<script setup>

import AdminLayout from "@/layouts/AdminLayout.vue";
import {formatDate} from "../utils/formatters.js";
import {computed, onMounted, ref} from "vue";
import api from "@/api/axios.js";
import TablePagination from "@/components/common/TablePagination.vue";

const loading = ref(true)
const errorMsg = ref('')
const saving = ref(false)

const users = ref([])
const farms = ref([])

const search = ref('')
const roleFilter = ref('')
const statusFilter = ref('')

const showModal = ref(false)
const isEditMode = ref(false)
const modalError = ref('')
const toast = ref('')

const form = ref({
  id: null,
  username: '',
  email: '',
  phoneNumber: '',
  role: 'FERMIER',
  farmId: '',
  password: ''
})

const filteredUsers = computed(() => {
  let result = users.value || []

  if (search.value.trim()) {
    const q = search.value.toLowerCase()
    result = result.filter(u =>
        u.username?.toLowerCase().includes(q) ||
        u.email?.toLowerCase().includes(q) ||
        u.phoneNumber?.toLowerCase().includes(q) ||
        u.farmName?.toLowerCase().includes(q)
    )
  }

  if (roleFilter.value) {
    result = result.filter(u => u.role === roleFilter.value)
  }

  if (statusFilter.value !== '') {
    const enabled = statusFilter.value === 'true'
    result = result.filter(u => u.enabled === enabled)
  }

  return result
})

onMounted(async () => {
  await Promise.all([loadUsers(), loadFarms()])
})

async function loadUsers() {
  loading.value = true
  errorMsg.value = ''

  try {
    const res = await api.get('/admin/users')
    users.value = Array.isArray(res.data) ? res.data : []
  } catch (e) {
    errorMsg.value = e.response?.data?.message || 'Erreur chargement utilisateurs'
  } finally {
    loading.value = false
  }
}

async function loadFarms() {
  try {
    const res = await api.get('/admin/farms')
    farms.value = Array.isArray(res.data) ? res.data : []
  } catch (e) {
    console.error(e)
  }
}

function resetFilters() {
  search.value = ''
  roleFilter.value = ''
  statusFilter.value = ''
}

function openCreate() {
  isEditMode.value = false
  modalError.value = ''
  form.value = {
    id: null,
    username: '',
    email: '',
    phoneNumber: '',
    role: 'FERMIER',
    farmId: '',
    password: ''
  }
  showModal.value = true
}

function openEdit(user) {
  isEditMode.value = true
  modalError.value = ''
  form.value = {
    id: user.id,
    username: user.username,
    email: user.email || '',
    phoneNumber: user.phoneNumber || '',
    role: user.role,
    farmId: user.farmId || '',
    password: ''
  }
  showModal.value = true
}

function closeModal() {
  showModal.value = false
}

async function saveUser() {
  modalError.value = ''

  if (!form.value.username || !form.value.email || !form.value.role) {
    modalError.value = 'Nom, email et rôle sont obligatoires.'
    return
  }

  if (!isEditMode.value && (!form.value.password || form.value.password.length < 6)) {
    modalError.value = 'Mot de passe minimum 6 caractères.'
    return
  }

  saving.value = true

  try {
    const payload = {
      username: form.value.username,
      email: form.value.email,
      phoneNumber: form.value.phoneNumber,
      role: form.value.role,
      farmId: form.value.farmId || null
    }

    if (!isEditMode.value) {
      payload.password = form.value.password
      await api.post('/admin/users', payload)
      showToast('Utilisateur créé')
    } else {
      await api.put(`/admin/users/${form.value.id}`, payload)
      showToast('Utilisateur modifié')
    }

    showModal.value = false
    await loadUsers()
  } catch (e) {
    modalError.value = e.response?.data?.message || 'Erreur opération'
  } finally {
    saving.value = false
  }
}

async function toggleUser(user) {
  try {
    const res = await api.put(`/admin/users/${user.id}/toggle`)
    user.enabled = res.data.enabled
    showToast(user.enabled ? 'Compte activé' : 'Compte désactivé')
  } catch {
    alert('Erreur activation/désactivation')
  }
}

async function deleteUser(user) {
  if (!confirm(`Désactiver le compte "${user.username}" ?`)) return

  try {
    await api.delete(`/admin/users/${user.id}`)
    user.enabled = false
    showToast('Compte désactivé')
  } catch {
    alert('Erreur désactivation')
  }
}

function showToast(message) {
  toast.value = message
  setTimeout(() => { toast.value = '' }, 3000)
}

function formatRole(role) {
  return {
    FERMIER: 'Fermier',
    VETERINAIRE: 'Vétérinaire',
    CONTROLEUR: 'Contrôleur',
    ADMIN: 'Admin'
  }[role] || role
}

function getRoleBadge(role) {
  return {
    FERMIER: 'badge bg-success',
    VETERINAIRE: 'badge bg-primary',
    CONTROLEUR: 'badge bg-warning text-dark',
    ADMIN: 'badge bg-danger'
  }[role] || 'badge bg-secondary'
}

const currentPage = ref(1)
const perPage = ref(10)

const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * perPage.value
  return filteredUsers.value.slice(start, start + perPage.value)
})

const totalPages = computed(() =>
    Math.ceil(filteredUsers.value.length / perPage.value)
)
</script>