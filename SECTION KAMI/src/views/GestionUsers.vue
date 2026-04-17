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

          <button
              v-for="page in totalPages"
              :key="page"
              :class="{ active: currentPage === page }"
              @click="setPage(page)"
          >
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
import { ref, onMounted, computed, watch } from 'vue'; // Ajout de 'watch' ici
import api from '../services/api';

const users = ref([]);
const isLoading = ref(true);
const errorMessage = ref('');

// Variables de filtres
const searchQuery = ref('');
const roleFilter = ref('');
const dateFrom = ref('');
const dateTo = ref('');

// --- VARIABLES POUR LA PAGINATION ---
const currentPage = ref(1);
const itemsPerPage = 20;

// Remettre la page à 1 si on change un filtre ou la recherche
watch([searchQuery, roleFilter, dateFrom, dateTo], () => {
  currentPage.value = 1;
});

const fetchUsers = async () => {
  try {
    const response = await api.get('/users');
    users.value = response.data;
  } catch (error) {
    console.error("Erreur récupération users:", error);
    errorMessage.value = "Impossible de charger les utilisateurs.";
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => {
  fetchUsers();
});

const formatDate = (dateString) => {
  if (!dateString) return '--/--/----';
  const date = new Date(dateString);
  return date.toLocaleDateString('fr-FR', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  }).replace(',', ' à');
};

const filteredUsers = computed(() => {
  return users.value.filter(user => {
    const fName = user.firstName || '';
    const lName = user.lastName || '';
    const email = user.emailAddress || '';
    const uName = user.username || '';
    const role = user.userRole || '';
    const idStr = user.id ? String(user.id) : '';
    const formattedId = user.id ? `#us-${2000 + user.id}` : '';

    const searchLower = searchQuery.value.toLowerCase();
    const matchesSearch =
        idStr.includes(searchLower) ||
        formattedId.includes(searchLower) ||
        `${fName} ${lName}`.toLowerCase().includes(searchLower) ||
        `${lName} ${fName}`.toLowerCase().includes(searchLower) ||
        email.toLowerCase().includes(searchLower) ||
        uName.toLowerCase().includes(searchLower);

    const matchesRole = roleFilter.value === '' || role === roleFilter.value;

    let matchesDate = true;
    if ((dateFrom.value || dateTo.value) && user.creationTimestamp) {
      const userDate = new Date(user.creationTimestamp);

      if (dateFrom.value) {
        const from = new Date(dateFrom.value);
        from.setHours(0, 0, 0, 0);
        if (userDate < from) matchesDate = false;
      }

      if (dateTo.value) {
        const to = new Date(dateTo.value);
        to.setHours(23, 59, 59, 999);
        if (userDate > to) matchesDate = false;
      }
    }

    return matchesSearch && matchesRole && matchesDate;
  });
});

// --- LOGIQUE COMPUTED DE LA PAGINATION ---

// Les utilisateurs à afficher sur la page actuelle
const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  const end = start + itemsPerPage;
  return filteredUsers.value.slice(start, end);
});

// Nombre total de pages nécessaires
const totalPages = computed(() => {
  return Math.ceil(filteredUsers.value.length / itemsPerPage);
});

// Calcul du texte "Affichage de X..."
const paginationStart = computed(() => {
  if (filteredUsers.value.length === 0) return 0;
  return (currentPage.value - 1) * itemsPerPage + 1;
});

// Calcul du texte "... à Y"
const paginationEnd = computed(() => {
  return Math.min(currentPage.value * itemsPerPage, filteredUsers.value.length);
});

// Actions des boutons
const prevPage = () => {
  if (currentPage.value > 1) currentPage.value--;
};

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++;
};

const setPage = (pageNumber) => {
  currentPage.value = pageNumber;
};
// ------------------------------------------

const translateRole = (role) => {
  if (!role) return 'Inconnu';
  const roles = { 'Administrator': 'Admin', 'Owner': 'Éleveur', 'Veterinarian': 'Vétérinaire', 'Agent de contrôle': 'Agent de contrôle' };
  return roles[role] || role;
};

const getRoleClass = (role) => {
  const classes = { 'Administrator': 'role-admin', 'Owner': 'role-eleveur', 'Veterinarian': 'role-veto', 'Agent de contrôle': 'role-agent' };
  return classes[role] || 'role-inconnu';
};

const getInitials = (firstName, lastName) => {
  const f = firstName ? String(firstName).charAt(0) : '?';
  const l = lastName ? String(lastName).charAt(0) : '';
  return `${f}${l}`.toUpperCase();
};

const showUserModal = ref(false);
const isEditMode = ref(false);
const currentUserId = ref(null);
const isSaving = ref(false);

const userForm = ref({
  firstName: '', lastName: '', username: '', emailAddress: '',
  encryptedPassword: '', userRole: 'Owner'
});

const openAddModal = () => {
  isEditMode.value = false;
  currentUserId.value = null;
  userForm.value = { firstName: '', lastName: '', username: '', emailAddress: '', encryptedPassword: '', userRole: 'Owner' };
  showUserModal.value = true;
};

const openEditModal = (user) => {
  isEditMode.value = true;
  currentUserId.value = user.id;
  userForm.value = { firstName: user.firstName, lastName: user.lastName, username: user.username, emailAddress: user.emailAddress, userRole: user.userRole };
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
    console.error("Erreur de sauvegarde :", error);
    alert("Une erreur est survenue lors de l'enregistrement.");
  } finally {
    isSaving.value = false;
  }
};

const confirmDelete = async () => {
  if (confirm("⚠️ Êtes-vous sûr de vouloir supprimer définitivement cet utilisateur ? Cette action est irréversible.")) {
    try {
      await api.delete(`/users/${currentUserId.value}`);
      closeModal();

      // Sécurité : Si on supprime le dernier utilisateur de la page actuelle, on recule d'une page
      if (paginatedUsers.value.length === 1 && currentPage.value > 1) {
        currentPage.value--;
      }

      await fetchUsers();
    } catch (error) {
      console.error("Erreur de suppression :", error);
      alert("Impossible de supprimer cet utilisateur.");
    }
  }
};
</script>

<style scoped>
/* --- STYLES DE BASE --- */
.users-container { padding: 30px; background-color: #f8fafc; min-height: 100vh; font-family: 'Inter', sans-serif; color: #1f2937; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
h1 { font-size: 24px; font-weight: 800; margin: 0; color: #111827; }
.subtitle { font-size: 14px; color: #6b7280; margin-top: 5px; }

.btn-add { background-color: #22c55e; color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s; }
.btn-add:hover { background-color: #16a34a; }

/* Filtres */
.filters-bar { display: flex; justify-content: space-between; align-items: center; background: white; padding: 15px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 20px; flex-wrap: wrap; gap: 15px; }
.search-box { display: flex; align-items: center; background: #f3f4f6; padding: 8px 15px; border-radius: 8px; width: 350px; }
.search-box i { color: #9ca3af; margin-right: 10px; }
.search-box input { border: none; background: transparent; width: 100%; outline: none; font-size: 14px; }

/* Nouveaux styles pour les filtres de droite (Dates + Dropdown) */
.right-filters { display: flex; gap: 15px; align-items: center; flex-wrap: wrap; }
.date-filters { display: flex; gap: 15px; }
.date-input-group { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #4b5563; font-weight: 500; }
.date-input-group input[type="date"] { padding: 6px 10px; border: 1px solid #e5e7eb; border-radius: 6px; outline: none; font-family: 'Inter', sans-serif; color: #374151; }

.dropdowns select { padding: 8px 15px; border: 1px solid #e5e7eb; border-radius: 8px; outline: none; background: white; color: #374151; font-size: 14px; cursor: pointer; }

/* Tableau */
.table-container { background: white; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden; }
table { width: 100%; border-collapse: collapse; }
th { text-align: left; padding: 15px 20px; font-size: 12px; font-weight: 700; color: #6b7280; text-transform: uppercase; border-bottom: 1px solid #f3f4f6; }
td { padding: 15px 20px; border-bottom: 1px solid #f3f4f6; font-size: 14px; vertical-align: middle; }

.empty-msg { text-align: center; color: #9ca3af; font-style: italic; padding: 30px; }

.user-id { color: #6b7280; font-weight: 500; }
.user-profile { display: flex; align-items: center; gap: 12px; }
.avatar { width: 32px; height: 32px; border-radius: 6px; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 12px; color: white; }
.user-name { font-weight: 600; }

.username-tag { color: #3b82f6; font-family: 'Monaco', monospace; font-size: 13px; background: #eff6ff; padding: 4px 8px; border-radius: 6px; font-weight: 500; }
.date-col { color: #6b7280; font-size: 13px; }

/* Badges */
.badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; }
.role-admin { background: #fee2e2; color: #b91c1c; }
.role-eleveur { background: #d1fae5; color: #047857; }
.role-veto { background: #f3e8ff; color: #7e22ce; }
.role-agent { background: #fef3c7; color: #d97706; } /* Jaune/Orange pour Agent */
.role-inconnu { background: #e5e7eb; color: #374151; }

.btn-edit { background: #eff6ff; color: #3b82f6; border: none; width: 32px; height: 32px; border-radius: 6px; cursor: pointer; transition: 0.2s; }
.btn-edit:hover { background: #dbeafe; }

/* Pagination */
.pagination { display: flex; justify-content: space-between; align-items: center; padding: 15px 20px; color: #6b7280; font-size: 13px; }
.page-controls { display: flex; gap: 5px; }
.page-controls button { width: 30px; height: 30px; border: 1px solid #e5e7eb; background: white; border-radius: 6px; cursor: pointer; color: #374151;}
.page-controls button:disabled { opacity: 0.5; cursor: not-allowed; }
.page-controls button.active { background: #22c55e; color: white; border-color: #22c55e; }
.page-controls button:hover:not(.active):not(:disabled) { background: #f3f4f6; }

/* --- STYLES DE LA MODALE --- */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0, 0, 0, 0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; backdrop-filter: blur(4px); }
.modal-content { background: white; width: 100%; max-width: 500px; border-radius: 12px; padding: 25px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); animation: modalFadeIn 0.3s ease-out; }
@keyframes modalFadeIn { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }
.modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid #f3f4f6; padding-bottom: 15px; }
.modal-header h2 { margin: 0; font-size: 18px; color: #111827; }
.btn-close { background: none; border: none; font-size: 18px; color: #9ca3af; cursor: pointer; transition: color 0.2s; }
.btn-close:hover { color: #ef4444; }
.modal-form { display: flex; flex-direction: column; gap: 15px; }
.form-row { display: flex; gap: 15px; }
.form-row .form-group { flex: 1; }
.form-group label { display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 5px; }
.form-group input, .form-group select { width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 8px; outline: none; transition: border-color 0.2s; }
.form-group input:focus, .form-group select:focus { border-color: #22c55e; }
.modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 10px; }
.justify-between { justify-content: space-between !important; }
.right-actions { display: flex; gap: 10px; }
.btn-cancel { padding: 10px 15px; background: white; border: 1px solid #d1d5db; border-radius: 8px; font-weight: 600; color: #374151; cursor: pointer; }
.btn-cancel:hover { background: #f3f4f6; }
.btn-confirm { padding: 10px 15px; background: #22c55e; border: none; border-radius: 8px; font-weight: 600; color: white; cursor: pointer; }
.btn-confirm:hover:not(:disabled) { background: #16a34a; }
.btn-confirm:disabled { opacity: 0.7; cursor: not-allowed; }
.btn-delete { padding: 10px 15px; background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; border-radius: 8px; font-weight: 600; cursor: pointer; transition: 0.2s; }
.btn-delete:hover { background: #fee2e2; border-color: #ef4444; }
</style>