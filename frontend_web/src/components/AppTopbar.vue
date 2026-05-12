<template>
  <header class="topbar">

    <div class="search-container">
      <div class="search-bar" :class="{ 'is-active': showDropdown && searchQuery }">
        <i class="fas fa-search"></i>
        <input
            type="text"
            v-model="searchQuery"
            @focus="showDropdown = true"
            @blur="hideDropdown"
            placeholder="Rechercher un module, une page..."
        >
      </div>

      <div v-if="showDropdown && searchQuery" class="search-dropdown">

        <div v-if="filteredResults.length === 0" class="no-results">
          <i class="fas fa-folder-open"></i>
          Aucun résultat pour "<strong>{{ searchQuery }}</strong>"
        </div>

        <div
            v-else
            v-for="res in filteredResults"
            :key="res.title"
            class="search-item"
            @click="navigateTo(res.route)"
        >
          <div class="item-icon" :class="res.colorClass">
            <i :class="res.icon"></i>
          </div>
          <div class="item-info">
            <span class="item-title">{{ res.title }}</span>
            <span class="item-type">{{ res.type }}</span>
          </div>
          <i class="fas fa-chevron-right item-arrow"></i>
        </div>

      </div>
    </div>

    <div class="user-profile">
      <div class="profile-info">
        <span class="name">{{ displayEmail }}</span>
        <span class="tag">@{{ displayUsername }}</span>
      </div>

      <div class="avatar-circle">
        {{ initials }}
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// --- ÉTATS DU PROFIL ---
const displayEmail = ref('Chargement...');
const displayUsername = ref('Chargement...');
const initials = ref('U');

// --- ÉTATS DE LA RECHERCHE ---
const searchQuery = ref('');
const showDropdown = ref(false);

// Liste des modules et pages disponibles pour la recherche
const siteModules = [
  { title: 'Tableau de bord', route: '/dashboard', icon: 'fas fa-chart-pie', type: 'Menu Principal', colorClass: 'bg-green' },
  { title: 'Utilisateurs', route: '/users', icon: 'fas fa-users', type: 'Administration', colorClass: 'bg-blue' },
  { title: 'Fermes', route: '/farms', icon: 'fas fa-tractor', type: 'Exploitations', colorClass: 'bg-navy' },
  { title: 'Animaux', route: '/animals', icon: 'fas fa-paw', type: 'Registre National', colorClass: 'bg-green' },
  { title: 'Mouvements & Stats', route: '/movements', icon: 'fas fa-chart-line', type: 'Analytique', colorClass: 'bg-gray' },
  { title: 'Gestion Fraude', route: '/fraude', icon: 'fas fa-shield-alt', type: 'Sécurité & Inspections', colorClass: 'bg-red' },
  { title: 'Journal de traçabilité', route: '/audit', icon: 'fas fa-list-alt', type: 'Intégrité système', colorClass: 'bg-navy' }
];

// Filtre les résultats de recherche en direct
const filteredResults = computed(() => {
  const q = searchQuery.value.toLowerCase().trim();
  if (!q) return [];

  return siteModules.filter(mod =>
      mod.title.toLowerCase().includes(q) ||
      mod.type.toLowerCase().includes(q)
  );
});

// Ferme le dropdown avec un délai court pour que le clic se fait bien
const hideDropdown = () => {
  setTimeout(() => {
    showDropdown.value = false;
  }, 200);
};

// Navigue vers une page et réinitialise la recherche
const navigateTo = (path) => {
  searchQuery.value = '';
  showDropdown.value = false;
  router.push(path);
};

// Récupère et affiche les infos de l'utilisateur connecté
onMounted(() => {
  const val1 = localStorage.getItem('user_name') || '';
  const val2 = localStorage.getItem('user_email') || '';

  if (val1.includes('@')) {
    displayEmail.value = val1;
    displayUsername.value = val2 || 'utilisateur';
  } else if (val2.includes('@')) {
    displayEmail.value = val2;
    displayUsername.value = val1 || 'utilisateur';
  } else {
    displayEmail.value = 'admin@dzcheptel.dz';
    displayUsername.value = val1 || 'superadmin';
  }

  const firstLetter = displayUsername.value.charAt(0).toUpperCase();
  initials.value = `${firstLetter}`;
});
</script>

<style scoped>
.topbar {
  background: white;
  padding: 12px 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #edf2f7;
  position: sticky;
  top: 0;
  z-index: 1000; /* Z-index élevé pour passer au dessus de tout */
  width: 100%;
  box-sizing: border-box;
  font-family: 'Inter', sans-serif;
}

/* --- RECHERCHE INTELLIGENTE --- */
.search-container {
  position: relative;
}

.search-bar {
  background: #f8fafc;
  padding: 10px 20px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 12px;
  width: 400px;
  border: 1px solid #e2e8f0;
  transition: all 0.2s;
  position: relative;
  z-index: 1001;
}

.search-bar.is-active {
  border-color: #0B5D1E;
  background: white;
  border-bottom-left-radius: 0;
  border-bottom-right-radius: 0;
}

.search-bar i { color: #94a3b8; }
.search-bar input {
  border: none;
  background: transparent;
  outline: none;
  width: 100%;
  font-size: 14px;
  color: #334155;
}

/* LE MENU DÉROULANT */
.search-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  width: 100%;
  background: white;
  border: 1px solid #0B5D1E;
  border-top: none;
  border-bottom-left-radius: 12px;
  border-bottom-right-radius: 12px;
  box-shadow: 0 10px 25px rgba(0,0,0,0.1);
  overflow: hidden;
  z-index: 1000;
  max-height: 400px;
  overflow-y: auto;
}

.search-item {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  gap: 15px;
  cursor: pointer;
  transition: background 0.2s;
  border-bottom: 1px solid #f1f5f9;
}

.search-item:last-child { border-bottom: none; }
.search-item:hover { background: #f8fafc; }

.item-icon {
  width: 35px;
  height: 35px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 14px;
}

/* Couleurs des icônes */
.bg-green { background: #0B5D1E; }
.bg-blue { background: #3b82f6; }
.bg-navy { background: #1e3a8a; }
.bg-red { background: #ef4444; }
.bg-gray { background: #64748b; }

.item-info {
  display: flex;
  flex-direction: column;
  flex: 1;
}

.item-title { font-size: 14px; font-weight: 700; color: #0f172a; }
.item-type { font-size: 11px; color: #64748b; font-weight: 600; text-transform: uppercase; margin-top: 2px;}

.item-arrow { color: #cbd5e1; font-size: 12px; transition: 0.2s;}
.search-item:hover .item-arrow { color: #0B5D1E; transform: translateX(3px);}

.no-results {
  padding: 20px;
  text-align: center;
  color: #64748b;
  font-size: 13px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}
.no-results i { font-size: 24px; color: #cbd5e1; }


/* --- PROFIL UTILISATEUR --- */
.user-profile {
  display: flex;
  align-items: center;
  gap: 20px;
}
.profile-info { text-align: right; }
.profile-info .name { display: block; font-weight: 700; font-size: 13px; color: #0f172a; }
.profile-info .tag { font-size: 11px; color: #0B5D1E; font-weight: 700; text-transform: lowercase; }
.avatar-circle {
  width: 40px; height: 40px; border-radius: 50%;
  background-color: #dcfce3; color: #063B16;
  display: flex; align-items: center; justify-content: center;
  font-weight: 800; font-size: 15px; border: 2px solid #0B5D1E;
}
</style>