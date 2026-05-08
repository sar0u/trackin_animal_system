<template>
  <div class="users-container">

    <div class="page-header">
      <div>
        <h1>Gestion des Utilisateurs</h1>
        <p class="subtitle">Gérez les comptes, définissez les rôles et contrôlez les accès.</p>
      </div>
      <button class="btn-add" @click="openAddModal">
        <i class="fas fa-user-plus"></i> Ajouter un Utilisateur
      </button>
    </div>

    <div class="filters-bar">
      <div class="search-box">
        <i class="fas fa-search"></i>
        <input
            type="text"
            v-model="searchQuery"
            placeholder="Rechercher (ID, nom, email, pseudo...)"
        >
      </div>

      <div class="right-filters">
        <div class="date-filters">
          <div class="date-input-group">
            <label>Du :</label>
            <input type="date" v-model="dateFrom">
          </div>
          <div class="date-input-group">
            <label>Au :</label>
            <input type="date" v-model="dateTo">
          </div>
        </div>

        <div class="dropdowns">
          <select v-model="roleFilter">
            <option value="">Tous les rôles</option>
            <option value="Administrator">Admin</option>
            <option value="Owner">Éleveur</option>
            <option value="Veterinarian">Vétérinaire</option>
            <option value="Agent de contrôle">Agent de contrôle</option>
          </select>
        </div>
      </div>
    </div>

    <div class="table-container">
      <div v-if="isLoading" class="loading">Chargement des utilisateurs...</div>
      <div v-else-if="errorMessage" class="error">{{ errorMessage }}</div>

      <table v-else>
        <thead>
        <tr>
          <th>ID</th>
          <th>NOM & PRÉNOM</th>
          <th>USERNAME</th>
          <th>EMAIL</th>
          <th>RÔLE</th>
          <th>CRÉÉ LE</th>
          <th>ACTIONS</th>
        </tr>
        </thead>
        <tbody>
        <tr v-if="filteredUsers.length === 0">
          <td colspan="7" class="empty-msg">Aucun utilisateur ne correspond à vos critères.</td>
        </tr>

        <tr v-for="user in paginatedUsers" :key="user.id">
          <td class="user-id">#{{ user.id }}</td>
          <td>
            <div class="user-profile">
              <div class="avatar" :class="getRoleClass(user.userRole)">
                {{ getInitials(user.firstName, user.lastName) }}
              </div>
              <span class="user-name">{{ user.lastName }} {{ user.firstName }}</span>
            </div>
          </td>
          <td><span class="username-tag">@{{ user.username }}</span></td>
          <td>{{ user.emailAddress }}</td>
          <td>
              <span class="badge role" :class="getRoleClass(user.userRole)">
                {{ translateRole(user.userRole) }}
              </span>
          </td>
          <td class="date-col">{{ formatDate(user.creationTimestamp) }}</td>
          <td>
            <button class="btn-edit" title="Modifier" @click="openEditModal(user)">
              <i class="fas fa-pen"></i>
            </button>
          </td>
        </tr>
        </tbody>
      </table>

      <div class="pagination">
        <span>Affichage de {{ paginationStart }} - {{ paginationEnd }} sur {{ filteredUsers.length }} utilisateurs</span>
        <div class="page-controls" v-if="totalPages > 0">
          <button :disabled="currentPage === 1" @click="prevPage">
            <i class="fas fa-chevron-left"></i>
          </button>
          <button v-for="page in totalPages" :key="page" :class="{ active: currentPage === page }" @click="setPage(page)">
            {{ page }}
          </button>
          <button :disabled="currentPage === totalPages" @click="nextPage">
            <i class="fas fa-chevron-right"></i>
          </button>
        </div>
      </div>
    </div>

    <div v-if="showUserModal" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>{{ isEditMode ? 'Modifier l\'Utilisateur' : 'Nouvel Utilisateur' }}</h2>
          <button class="btn-close" @click="closeModal"><i class="fas fa-times"></i></button>
        </div>

        <form @submit.prevent="saveUser" class="modal-form">
          <div class="form-row">
            <div class="form-group">
              <label>Prénom</label>
              <input v-model="userForm.firstName" type="text" required>
            </div>
            <div class="form-group">
              <label>Nom</label>
              <input v-model="userForm.lastName" type="text" required>
            </div>
          </div>

          <div class="form-group">
            <label>Nom d'utilisateur (Pseudo)</label>
            <input v-model="userForm.username" type="text" required>
          </div>

          <div class="form-group">
            <label>Adresse Email</label>
            <input v-model="userForm.emailAddress" type="email" required>
          </div>

          <div class="form-group">
            <label>Numéro de téléphone</label>
            <input v-model="userForm.phone" type="tel">
          </div>

          <div class="form-group" v-if="!isEditMode">
            <label>Mot de passe provisoire</label>
            <input v-model="userForm.encryptedPassword" type="password" required>
          </div>

          <div class="form-group">
            <label>Rôle</label>
            <select v-model="userForm.userRole" required>
              <option value="Owner">Éleveur</option>
              <option value="Veterinarian">Vétérinaire</option>
              <option value="Administrator">Administrateur</option>
              <option value="Agent de contrôle">Agent de contrôle</option>
            </select>
          </div>

          <div class="modal-actions" :class="{'justify-between': isEditMode}">
            <button v-if="isEditMode" type="button" class="btn-delete" @click="confirmDelete">
              <i class="fas fa-trash"></i> Supprimer
            </button>
            <div class="right-actions">
              <button type="button" class="btn-cancel" @click="closeModal">Annuler</button>
              <button type="submit" class="btn-confirm" :disabled="isSaving">
                {{ isSaving ? 'En cours...' : (isEditMode ? 'Enregistrer' : 'Créer l\'utilisateur') }}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import api from '../services/api';

const users = ref([]);
const isLoading = ref(true);
const errorMessage = ref('');
const searchQuery = ref('');
const roleFilter = ref('');
const dateFrom = ref('');
const dateTo = ref('');
const currentPage = ref(1);
const itemsPerPage = 20;

watch([searchQuery, roleFilter, dateFrom, dateTo], () => { currentPage.value = 1; });

const fetchUsers = async () => {
  try {
    const response = await api.get('/users');
    users.value = response.data;
  } catch (error) {
    errorMessage.value = "Impossible de charger les utilisateurs.";
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => { fetchUsers(); });

const formatDate = (dateString) => {
  if (!dateString) return '--/--/----';
  const date = new Date(dateString);
  return date.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }).replace(',', ' à');
};

const filteredUsers = computed(() => {
  return users.value.filter(user => {
    const searchLower = searchQuery.value.toLowerCase();
    const matchesSearch =
        String(user.id).includes(searchLower) ||
        `${user.firstName} ${user.lastName}`.toLowerCase().includes(searchLower) ||
        user.emailAddress.toLowerCase().includes(searchLower) ||
        user.username.toLowerCase().includes(searchLower);
    const matchesRole = roleFilter.value === '' || user.userRole === roleFilter.value;
    return matchesSearch && matchesRole;
  });
});

const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredUsers.value.slice(start, start + itemsPerPage);
});

const totalPages = computed(() => Math.ceil(filteredUsers.value.length / itemsPerPage));
const paginationStart = computed(() => filteredUsers.value.length === 0 ? 0 : (currentPage.value - 1) * itemsPerPage + 1);
const paginationEnd = computed(() => Math.min(currentPage.value * itemsPerPage, filteredUsers.value.length));

const prevPage = () => { if (currentPage.value > 1) currentPage.value--; };
const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++; };
const setPage = (pageNumber) => { currentPage.value = pageNumber; };

const translateRole = (role) => {
  const roles = { 'Administrator': 'Admin', 'Owner': 'Éleveur', 'Veterinarian': 'Vétérinaire', 'Agent de contrôle': 'Agent de contrôle' };
  return roles[role] || role;
};

const getRoleClass = (role) => {
  const classes = { 'Administrator': 'role-admin', 'Owner': 'role-eleveur', 'Veterinarian': 'role-veto', 'Agent de contrôle': 'role-agent' };
  return classes[role] || 'role-inconnu';
};

const getInitials = (firstName, lastName) => {
  return `${firstName?.charAt(0) || '?'}${lastName?.charAt(0) || ''}`.toUpperCase();
};

const showUserModal = ref(false);
const isEditMode = ref(false);
const currentUserId = ref(null);
const isSaving = ref(false);

// AJOUT : phoneNumber dans userForm
const userForm = ref({
  firstName: '', lastName: '', username: '', emailAddress: '',
  phoneNumber: '', encryptedPassword: '', userRole: 'Owner'
});

const openAddModal = () => {
  isEditMode.value = false;
  currentUserId.value = null;
  userForm.value = { firstName: '', lastName: '', username: '', emailAddress: '', phoneNumber: '', encryptedPassword: '', userRole: 'Owner' };
  showUserModal.value = true;
};

const openEditModal = (user) => {
  isEditMode.value = true;
  currentUserId.value = user.id;
  // CHARGEMENT : on récupère le phoneNumber depuis l'objet utilisateur
  userForm.value = {
    firstName: user.firstName,
    lastName: user.lastName,
    username: user.username,
    emailAddress: user.emailAddress,
    phone: user.phone || '',
    userRole: user.userRole
  };
  showUserModal.value = true;
};

const closeModal = () => { showUserModal.value = false; };

const saveUser = async () => {
  try {
    isSaving.value = true;
    if (isEditMode.value) {
      await api.put(`/users/${currentUserId.value}`, userForm.value);
    } else {
      await api.post('/users', userForm.value);
    }
    closeModal();
    await fetchUsers();
  } catch (error) {
    alert("Erreur lors de l'enregistrement.");
  } finally {
    isSaving.value = false;
  }
};

const confirmDelete = async () => {
  if (confirm("Supprimer définitivement cet utilisateur ?")) {
    try {
      await api.delete(`/users/${currentUserId.value}`);
      closeModal();
      await fetchUsers();
    } catch (error) {
      alert("Impossible de supprimer cet utilisateur.");
    }
  }
};
</script>

<style scoped>
/* ==========================================================================
   1. BASE
   ========================================================================== */
.users-container {
  padding: 30px;
  background-color: #f4f7f6;
  min-height: 100vh;
  font-family: 'Inter', sans-serif;
  color: #1e293b;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

h1 {
  font-size: 26px;
  font-weight: 900;
  margin: 0;
  color: #0f172a;
  letter-spacing: -0.5px;
}

.subtitle {
  font-size: 14px;
  color: #64748b;
  margin-top: 5px;
}

.btn-add {
  background-color: #0B5D1E;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: 0.2s;
}

.btn-add:hover {
  background-color: #063B16;
}

/* ==========================================================================
   2. FILTRES
   ========================================================================== */
.filters-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  padding: 16px 25px;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  margin-bottom: 25px;
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

.date-filters {
  display: flex;
  gap: 16px;
}

.date-input-group {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #063B16;
  font-weight: 600;
}

.date-input-group label {
  color: #0B5D1E;
  font-weight: 700;
  text-transform: uppercase;
  font-size: 11px;
}

.date-input-group input[type="date"] {
  padding: 8px 12px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  outline: none;
  font-family: 'Inter', sans-serif;
  color: #063B16;
  background: white;
  height: 42px;
  box-sizing: border-box;
}

.dropdowns select {
  padding: 8px 12px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  outline: none;
  background: white;
  color: #063B16;
  font-size: 14px;
  cursor: pointer;
  font-weight: 600;
  height: 42px;
  box-sizing: border-box;
}

.dropdowns select:focus {
  border-color: #0B5D1E;
  box-shadow: 0 0 0 3px rgba(11, 93, 30, 0.1);
}

/* ==========================================================================
   3. TABLEAU
   ========================================================================== */
.table-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  overflow: hidden;
  border: 1px solid rgba(11, 93, 30, 0.08);
}

table {
  width: 100%;
  border-collapse: collapse;
}

th {
  text-align: left;
  padding: 14px 20px;
  font-size: 11px;
  font-weight: 800;
  color: #0B5D1E;
  text-transform: uppercase;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  background: rgba(11, 93, 30, 0.03);
  letter-spacing: 0.5px;
}

td {
  padding: 16px 20px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.05);
  font-size: 14px;
  vertical-align: middle;
}

tr:hover {
  background-color: rgba(11, 93, 30, 0.02);
}

.empty-msg {
  text-align: center;
  color: #94a3b8;
  font-style: italic;
  padding: 30px;
}

.user-id {
  color: #64748b;
  font-weight: 500;
  font-family: 'JetBrains Mono', monospace;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 12px;
}

/* Tous les avatars en couleur primaire #0B5D1E */
.avatar {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 12px;
  color: white;
  background-color: #0B5D1E;
}

.user-name {
  font-weight: 600;
  color: #0f172a;
}

.username-tag {
  color: #0B5D1E;
  font-family: 'JetBrains Mono', monospace;
  font-size: 13px;
  background: rgba(11, 93, 30, 0.08);
  padding: 4px 8px;
  border-radius: 6px;
  font-weight: 500;
}

.date-col {
  color: #64748b;
  font-size: 13px;
}

/* Badges de rôles avec vos couleurs */
.badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
}

.role-admin {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

.role-eleveur {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

.role-veto {
  background: rgba(11, 93, 30, 0.1);
  color: #0B5D1E;
}

.role-agent {
  background: rgba(255, 152, 0, 0.1);
  color: #FF9800;
}

.role-inconnu {
  background: rgba(11, 93, 30, 0.05);
  color: #64748b;
}

.btn-edit {
  background: rgba(11, 93, 30, 0.08);
  color: #0B5D1E;
  border: 1px solid rgba(11, 93, 30, 0.2);
  width: 32px;
  height: 32px;
  border-radius: 6px;
  cursor: pointer;
  transition: 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-edit:hover {
  background: #0B5D1E;
  color: white;
  border-color: #0B5D1E;
}

/* ==========================================================================
   4. PAGINATION
   ========================================================================== */
.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  color: #64748b;
  font-size: 13px;
  font-weight: 600;
  background: rgba(11, 93, 30, 0.02);
  border-top: 1px solid rgba(11, 93, 30, 0.08);
}

.page-controls {
  display: flex;
  gap: 5px;
}

.page-controls button {
  width: 35px;
  height: 35px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  background: white;
  border-radius: 8px;
  cursor: pointer;
  color: #063B16;
  font-weight: 700;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.page-controls button:hover:not(:disabled) {
  background: rgba(11, 93, 30, 0.1);
}

.page-controls button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-controls button.active {
  background: #0B5D1E;
  color: white;
  border-color: #0B5D1E;
}

/* ==========================================================================
   5. MODALE
   ========================================================================== */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(6, 59, 22, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.modal-content {
  background: white;
  width: 100%;
  max-width: 500px;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  padding-bottom: 15px;
}

.modal-header h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 800;
  color: #063B16;
}

.btn-close {
  background: rgba(11, 93, 30, 0.08);
  border: none;
  font-size: 18px;
  color: #0B5D1E;
  cursor: pointer;
  width: 35px;
  height: 35px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.btn-close:hover {
  background: rgba(11, 93, 30, 0.15);
}

.modal-form {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.form-row {
  display: flex;
  gap: 15px;
}

.form-row .form-group {
  flex: 1;
}

.form-group label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: #063B16;
  margin-bottom: 5px;
}

.form-group input, .form-group select {
  width: 100%;
  padding: 10px 14px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  outline: none;
  color: #063B16;
  background: white;
  box-sizing: border-box;
}

.form-group input:focus, .form-group select:focus {
  border-color: #0B5D1E;
  box-shadow: 0 0 0 3px rgba(11, 93, 30, 0.1);
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 10px;
}

.justify-between {
  justify-content: space-between !important;
}

.btn-delete {
  padding: 10px 15px;
  background: rgba(244, 67, 54, 0.1);
  border: 1px solid rgba(244, 67, 54, 0.2);
  color: #F44336;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: all 0.2s;
}

.btn-delete:hover {
  background: rgba(244, 67, 54, 0.2);
}

.right-actions {
  display: flex;
  gap: 10px;
}

.btn-cancel {
  padding: 10px 15px;
  background: rgba(11, 93, 30, 0.08);
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  font-weight: 600;
  color: #063B16;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-cancel:hover {
  background: rgba(11, 93, 30, 0.15);
}

.btn-confirm {
  padding: 10px 15px;
  background: #0B5D1E;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  color: white;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-confirm:hover {
  background: #063B16;
}

.btn-confirm:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* ==========================================================================
   6. LOADING & ERROR
   ========================================================================== */
.loading {
  text-align: center;
  padding: 50px;
  color: #64748b;
  font-weight: 600;
}

.error {
  text-align: center;
  padding: 50px;
  color: #F44336;
  font-weight: 600;
  background: rgba(244, 67, 54, 0.05);
}

/* ==========================================================================
   7. RESPONSIVE
   ========================================================================== */
@media (max-width: 1200px) {
  .filters-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .search-box {
    max-width: 100%;
  }

  .right-filters {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>