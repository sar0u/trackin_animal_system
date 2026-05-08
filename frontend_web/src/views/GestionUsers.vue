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
            <option value="Farmer">Éleveur</option>
            <option value="Veterinarian">Vétérinaire</option>
            <option value="Inspector">Inspecteur</option>
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
          <th>TÉLÉPHONE</th>
          <th>RÔLE</th>
          <th>STATUT</th>
          <th>CRÉÉ LE</th>
          <th>ACTIONS</th>
        </tr>
        </thead>
        <tbody>
        <tr v-if="filteredUsers.length === 0">
          <td colspan="9" class="empty-msg">Aucun utilisateur ne correspond à vos critères.</td>
        </tr>

        <tr v-for="user in paginatedUsers" :key="user.id">
          <td class="user-id">#USR-{{ user.id }}</td>
          <td>
            <div class="user-profile">
              <div class="avatar" :class="getRoleClass(user.role)">
                {{ getInitials(user.firstName, user.lastName) }}
              </div>
              <span class="user-name">{{ user.lastName }} {{ user.firstName }}</span>
            </div>
          </td>
          <td><span class="username-tag">@{{ user.username }}</span></td>
          <td>{{ user.email }}</td>
          <td class="phone-col">{{ user.phone || '—' }}</td>
          <td>
              <span class="badge role" :class="getRoleClass(user.role)">
                {{ translateRole(user.role) }}
              </span>
          </td>
          <td>
            <span class="badge" :class="user.isActive !== false ? 'status-active' : 'status-inactive'">
              <i :class="user.isActive !== false ? 'fas fa-circle' : 'far fa-circle'" style="font-size:8px;"></i>
              {{ user.isActive !== false ? 'Actif' : 'Inactif' }}
            </span>
          </td>
          <td class="date-col">{{ formatDate(user.createdAt) }}</td>
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

        <form @submit.prevent="saveUser" class="modal-form" novalidate>
          <div class="form-row">
            <div class="form-group">
              <label>Prénom</label>
              <input
                v-model="userForm.firstName"
                type="text"
                required
                pattern="[A-Za-zÀ-ÿ\s\-']+"
                title="Lettres uniquement (accents et tirets acceptés)"
                @input="userForm.firstName = userForm.firstName.replace(/[^A-Za-zÀ-ÿ\s\-']/g, '')"
                :class="{ 'input-error': formErrors.firstName }"
              >
              <span v-if="formErrors.firstName" class="field-error">{{ formErrors.firstName }}</span>
            </div>
            <div class="form-group">
              <label>Nom</label>
              <input
                v-model="userForm.lastName"
                type="text"
                required
                pattern="[A-Za-zÀ-ÿ\s\-']+"
                title="Lettres uniquement (accents et tirets acceptés)"
                @input="userForm.lastName = userForm.lastName.replace(/[^A-Za-zÀ-ÿ\s\-']/g, '')"
                :class="{ 'input-error': formErrors.lastName }"
              >
              <span v-if="formErrors.lastName" class="field-error">{{ formErrors.lastName }}</span>
            </div>
          </div>

          <div class="form-group">
            <label>Nom d'utilisateur (Pseudo)</label>
            <input
              v-model="userForm.username"
              type="text"
              required
              placeholder="ex: ali_boudiaf"
              @input="userForm.username = userForm.username.replace(/[^A-Za-z0-9_\-\.]/g, '').toLowerCase()"
              :class="{ 'input-error': formErrors.username }"
            >
            <span class="field-hint">Lettres minuscules, chiffres, _ . - uniquement. Pas d'espaces.</span>
            <span v-if="formErrors.username" class="field-error">{{ formErrors.username }}</span>
          </div>

          <div class="form-group">
            <label>Adresse Email</label>
            <input
              v-model="userForm.email"
              type="email"
              required
              placeholder="exemple@domaine.com"
              :class="{ 'input-error': formErrors.email }"
            >
            <span v-if="formErrors.email" class="field-error">{{ formErrors.email }}</span>
          </div>

          <div class="form-group">
            <label>Numéro de téléphone</label>
            <input
              v-model="userForm.phone"
              type="tel"
              placeholder="0600000000 ou +213600000000"
              @input="userForm.phone = userForm.phone.replace(/[^0-9\+\s]/g, '')"
              :class="{ 'input-error': formErrors.phone }"
            >
            <span class="field-hint">Format : 06xxxxxxxx, 07xxxxxxxx ou +213xxxxxxxxx</span>
            <span v-if="formErrors.phone" class="field-error">{{ formErrors.phone }}</span>
          </div>

          <div class="form-group" v-if="!isEditMode">
            <label>Mot de passe provisoire</label>
            <input
              v-model="userForm.password"
              type="password"
              required
              minlength="8"
              placeholder="8 caractères minimum"
              :class="{ 'input-error': formErrors.password }"
            >
            <span class="field-hint">8 caractères minimum, lettres et chiffres recommandés.</span>
            <span v-if="formErrors.password" class="field-error">{{ formErrors.password }}</span>
          </div>

          <div class="form-group" v-if="isEditMode && currentUserUpdatedAt">
            <label>Dernière modification</label>
            <div class="form-static-value">{{ formatDate(currentUserUpdatedAt) }}</div>
          </div>

          <div class="form-group">
            <label>Rôle</label>
            <select v-model="userForm.role" required>
              <option value="Farmer">Éleveur</option>
              <option value="Veterinarian">Vétérinaire</option>
              <option value="Administrator">Administrateur</option>
              <option value="Inspector">Inspecteur</option>
            </select>
          </div>

          <div class="modal-actions" :class="{'justify-between': isEditMode}">
            <button
              v-if="isEditMode"
              type="button"
              :class="userForm.isActive ? 'btn-deactivate-account' : 'btn-activate-account'"
              @click="confirmToggleActive"
            >
              <i :class="userForm.isActive ? 'fas fa-user-slash' : 'fas fa-user-check'"></i>
              {{ userForm.isActive ? 'Désactiver' : 'Réactiver' }}
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
const itemsPerPage = 10;

// Retour à la première page lors d'un changement de filtre
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
    const email = user.email || '';
    const uName = user.username || '';
    const role = user.role || '';
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
    if ((dateFrom.value || dateTo.value) && user.createdAt) {
      const userDate = new Date(user.createdAt);

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

// Logique de pagination

// Utilisateurs du slice pour la page courante
const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  const end = start + itemsPerPage;
  return filteredUsers.value.slice(start, end);
});

// Nombre total de pages
const totalPages = computed(() => {
  return Math.ceil(filteredUsers.value.length / itemsPerPage);
});

// Premier utilisateur affiché (ex: 1, 21, 41...)
const paginationStart = computed(() => {
  if (filteredUsers.value.length === 0) return 0;
  return (currentPage.value - 1) * itemsPerPage + 1;
});

// Dernier utilisateur affiché sur la page
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
  const roles = { 'Administrator': 'Admin', 'Farmer': 'Éleveur', 'Veterinarian': 'Vétérinaire', 'Inspector': 'Inspecteur' };
  return roles[role] || role;
};

const getRoleClass = (role) => {
  const classes = { 'Administrator': 'role-admin', 'Farmer': 'role-eleveur', 'Veterinarian': 'role-veto', 'Inspector': 'role-agent' };
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
const currentUserUpdatedAt = ref('');
const isSaving = ref(false);

const userForm = ref({
  firstName: '', lastName: '', username: '', email: '',
  phone: '', password: '', role: 'Farmer', isActive: true
});

const formErrors = ref({});

const validateForm = () => {
  const errors = {};
  const nameRegex = /^[A-Za-zÀ-ÿ\s\-']+$/;
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  const phoneRegex = /^(\+213|0)(5|6|7)[0-9]{8}$/;
  const usernameRegex = /^[a-z0-9_\-\.]+$/;

  if (!userForm.value.firstName.trim()) {
    errors.firstName = 'Le prénom est obligatoire.';
  } else if (!nameRegex.test(userForm.value.firstName)) {
    errors.firstName = 'Le prénom ne doit contenir que des lettres.';
  }

  if (!userForm.value.lastName.trim()) {
    errors.lastName = 'Le nom est obligatoire.';
  } else if (!nameRegex.test(userForm.value.lastName)) {
    errors.lastName = 'Le nom ne doit contenir que des lettres.';
  }

  if (!userForm.value.username.trim()) {
    errors.username = 'Le nom d\'utilisateur est obligatoire.';
  } else if (userForm.value.username.length < 3) {
    errors.username = 'Minimum 3 caractères.';
  } else if (!usernameRegex.test(userForm.value.username)) {
    errors.username = 'Lettres minuscules, chiffres, _ . - uniquement.';
  }

  if (!userForm.value.email.trim()) {
    errors.email = 'L\'email est obligatoire.';
  } else if (!emailRegex.test(userForm.value.email)) {
    errors.email = 'Format email invalide (ex: nom@domaine.com).';
  }

  if (userForm.value.phone && !phoneRegex.test(userForm.value.phone.replace(/\s/g, ''))) {
    errors.phone = 'Format invalide. Ex: 0600000000 ou +213600000000';
  }

  if (!isEditMode.value) {
    if (!userForm.value.password) {
      errors.password = 'Le mot de passe est obligatoire.';
    } else if (userForm.value.password.length < 8) {
      errors.password = 'Le mot de passe doit contenir au moins 8 caractères.';
    }
  }

  formErrors.value = errors;
  return Object.keys(errors).length === 0;
};

const openAddModal = () => {
  isEditMode.value = false;
  currentUserId.value = null;
  userForm.value = { firstName: '', lastName: '', username: '', email: '', phone: '', password: '', role: 'Farmer', isActive: true };
  formErrors.value = {};
  showUserModal.value = true;
};

const openEditModal = (user) => {
  isEditMode.value = true;
  currentUserId.value = user.id;
  currentUserUpdatedAt.value = user.updatedAt || '';
  userForm.value = {
    firstName: user.firstName,
    lastName: user.lastName,
    username: user.username,
    email: user.email,
    phone: user.phone || '',
    role: user.role,
    isActive: user.isActive ?? true
  };
  formErrors.value = {};
  showUserModal.value = true;
};

const closeModal = () => { showUserModal.value = false; };

const saveUser = async () => {
  if (!validateForm()) return;
  try {
    isSaving.value = true;
    if (isEditMode.value) {
      const payload = {
        firstName: userForm.value.firstName,
        lastName: userForm.value.lastName,
        username: userForm.value.username,
        email: userForm.value.email,
        phone: userForm.value.phone,
        role: userForm.value.role,
        isActive: userForm.value.isActive
      };
      await api.put(`/users/${currentUserId.value}`, payload);
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

const confirmToggleActive = async () => {
  const newStatus = !userForm.value.isActive;
  const label = newStatus ? 'réactiver' : 'désactiver';
  if (!confirm(`Êtes-vous sûr de vouloir ${label} le compte de "${userForm.value.username}" ?`)) return;
  try {
    const payload = {
      firstName: userForm.value.firstName,
      lastName: userForm.value.lastName,
      username: userForm.value.username,
      email: userForm.value.email,
      phone: userForm.value.phone || '',
      role: userForm.value.role,
      isActive: newStatus
    };
    await api.put(`/users/${currentUserId.value}`, payload);
    closeModal();
    await fetchUsers();
  } catch (error) {
    console.error('Erreur changement statut utilisateur:', error);
    alert("Erreur lors de la mise à jour du statut.");
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
  font-size: 11px;
  text-transform: uppercase;
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
  font-size: 13px;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 12px;
}

/* Tous les avatars en couleur primaire */
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

.phone-col {
  color: #475569;
  font-size: 13px;
}

.date-col {
  color: #64748b;
  font-size: 13px;
}

/* ==========================================================================
   4. BADGES (Rôles avec vos couleurs)
   ========================================================================== */
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

/* Badges de statut */
.status-active {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
  display: inline-flex;
  align-items: center;
  gap: 5px;
}

.status-inactive {
  background: rgba(244, 67, 54, 0.08);
  color: #F44336;
  display: inline-flex;
  align-items: center;
  gap: 5px;
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
   5. PAGINATION
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

.page-controls button:hover:not(:disabled):not(.active) {
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
   6. MODALE
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
  animation: modalFadeIn 0.3s ease-out;
}

@keyframes modalFadeIn {
  from { opacity: 0; transform: translateY(-20px); }
  to { opacity: 1; transform: translateY(0); }
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
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
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
  transition: border-color 0.2s;
  color: #063B16;
  background: white;
  box-sizing: border-box;
}

.form-group input:focus, .form-group select:focus {
  border-color: #0B5D1E;
  box-shadow: 0 0 0 3px rgba(11, 93, 30, 0.1);
}

.form-static-value {
  padding: 10px 14px;
  background: rgba(11, 93, 30, 0.03);
  border: 1px solid rgba(11, 93, 30, 0.1);
  border-radius: 8px;
  font-size: 14px;
  color: #063B16;
  font-weight: 500;
}

.input-error {
  border-color: #F44336 !important;
  background: rgba(244, 67, 54, 0.03);
}

.input-error:focus {
  border-color: #F44336 !important;
  box-shadow: 0 0 0 3px rgba(244, 67, 54, 0.1);
}

.field-error {
  display: block;
  margin-top: 4px;
  font-size: 12px;
  color: #F44336;
  font-weight: 500;
}

.field-hint {
  display: block;
  margin-top: 3px;
  font-size: 11px;
  color: #94a3b8;
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

.right-actions {
  display: flex;
  gap: 10px;
}

.btn-cancel {
  padding: 10px 15px;
  background: white;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  font-weight: 600;
  color: #063B16;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-cancel:hover {
  background: rgba(11, 93, 30, 0.05);
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

.btn-confirm:hover:not(:disabled) {
  background: #063B16;
}

.btn-confirm:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.btn-deactivate-account {
  padding: 10px 15px;
  background: rgba(244, 67, 54, 0.08);
  border: 1px solid rgba(244, 67, 54, 0.2);
  color: #F44336;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.btn-deactivate-account:hover {
  background: rgba(244, 67, 54, 0.15);
}

.btn-activate-account {
  padding: 10px 15px;
  background: rgba(76, 175, 80, 0.08);
  border: 1px solid rgba(76, 175, 80, 0.2);
  color: #4CAF50;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.btn-activate-account:hover {
  background: rgba(76, 175, 80, 0.15);
}

/* ==========================================================================
   7. LOADING & ERROR
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
   8. RESPONSIVE
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