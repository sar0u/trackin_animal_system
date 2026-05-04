<template>
  <aside class="sidebar">

    <!-- Brand -->
    <div class="sidebar-brand">
      <div class="brand-wrap">

        <!-- Logo image -->
        <img
            v-if="showLogo"
            src="../../assets/logo.png"
            class="sidebar-logo"
            alt="DZcheptel logo"
            @error="showLogo = false"
        />

        <!-- Fallback icon -->
        <div v-else class="brand-icon">
          <i class="bi bi-diagram-3-fill"></i>
        </div>

        <div class="brand-text">
          <h5>DZcheptel</h5>
          <small>Administration</small>
        </div>
      </div>
    </div>

    <!-- Navigation -->
    <nav class="sidebar-nav">

      <div class="nav-group">

        <div class="nav-section">Principal</div>

        <RouterLink to="/dashboard" class="nav-link" active-class="active">
          <i class="bi bi-grid-1x2-fill"></i>
          <span>Dashboard</span>
        </RouterLink>

        <div class="nav-section">Gestion</div>

        <RouterLink to="/users" class="nav-link" active-class="active">
          <i class="bi bi-people-fill"></i>
          <span>Utilisateurs</span>
        </RouterLink>

        <RouterLink to="/farms" class="nav-link" active-class="active">
          <i class="bi bi-house-fill"></i>
          <span>Fermes</span>
        </RouterLink>

        <RouterLink to="/animals" class="nav-link" active-class="active">
          <i class="bi bi-tags-fill"></i>
          <span>Animaux</span>
        </RouterLink>

        <RouterLink to="/subventions" class="nav-link" active-class="active">
          <i class="bi bi-cash-coin"></i>
          <span>Subventions</span>
        </RouterLink>

        <div class="nav-section">Sanitaire</div>

        <RouterLink to="/campaigns" class="nav-link" active-class="active">
          <i class="bi bi-shield-plus"></i>
          <span>Campagnes</span>
        </RouterLink>

        <div class="nav-section">Contrôle</div>

        <RouterLink to="/constats" class="nav-link" active-class="active">
          <i class="bi bi-file-earmark-text-fill"></i>
          <span>Constats</span>

          <span
              v-if="pendingConstats > 0"
              class="badge bg-warning text-dark ms-auto nav-badge"
          >
            {{ pendingConstats }}
          </span>
        </RouterLink>

        <RouterLink to="/fraud" class="nav-link" active-class="active">
          <i class="bi bi-shield-exclamation"></i>
          <span>Fraude</span>
        </RouterLink>

        <RouterLink to="/audit" class="nav-link" active-class="active">
          <i class="bi bi-clock-history"></i>
          <span>Audit</span>
        </RouterLink>

        <div class="nav-section">Admin</div>

        <RouterLink to="/exports" class="nav-link" active-class="active">
          <i class="bi bi-download"></i>
          <span>Exports</span>
        </RouterLink>

        <RouterLink to="/settings" class="nav-link" active-class="active">
          <i class="bi bi-gear-fill"></i>
          <span>Paramètres</span>
        </RouterLink>
      </div>

      <!-- Déconnexion -->
      <div class="nav-group logout-group">
        <button type="button" class="nav-link logout-btn" @click="handleLogout">
          <i class="bi bi-box-arrow-left"></i>
          <span>Déconnexion</span>
        </button>
      </div>

    </nav>
  </aside>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink, useRouter } from 'vue-router'

import api from '../../api/axios.js'
import { useAuthStore } from '@/stores/authStore.js'

const router = useRouter()
const auth = useAuthStore()

const pendingConstats = ref(0)
const showLogo = ref(true)

onMounted(async () => {
  try {
    const res = await api.get('/admin/constats')
    pendingConstats.value = (res.data || []).filter(c => c.status === 'PENDING').length
  } catch {
    pendingConstats.value = 0
  }
})

function handleLogout() {
  auth.logout()
  router.push('/login')
}
</script>

<style scoped>
.sidebar {
  width: var(--sidebar-width);
  height: 100vh;
  background-color: var(--primary-green);
  color: white;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* BRAND */
.sidebar-brand {
  height: 54px;
  padding: 8px 12px;
  border-bottom: 1px solid rgba(255,255,255,0.15);
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

.brand-wrap {
  display: flex;
  align-items: center;
  gap: 9px;
}

.sidebar-logo {
  width: 36px;
  height: 36px;
  object-fit: contain;
  background: white;
  border-radius: 9px;
  padding: 4px;
}

.brand-icon {
  width: 36px;
  height: 36px;
  border-radius: 9px;
  background: rgba(255,255,255,0.16);
  display: flex;
  align-items: center;
  justify-content: center;
}

.brand-text h5 {
  margin: 0;
  font-size: 15px;
  font-weight: 700;
  line-height: 1.1;
}

.brand-text small {
  font-size: 9px;
  opacity: 0.75;
}

/* NAVIGATION */
.sidebar-nav {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 4px 0 6px;
  overflow: hidden;
}

.nav-group {
  flex-shrink: 0;
}

.nav-section {
  padding: 4px 12px 2px;
  font-size: 8px;
  letter-spacing: 1px;
  text-transform: uppercase;
  color: rgba(255,255,255,0.45);
  font-weight: 700;
}

.nav-link {
  height: 29px;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 0 12px;
  color: rgba(255,255,255,0.84);
  text-decoration: none;
  font-size: 11.8px;
  border-left: 3px solid transparent;
  transition: 0.18s;
  width: 100%;
}

.nav-link:hover {
  color: white;
  background-color: rgba(255,255,255,0.1);
}

.nav-link.active {
  color: white;
  background-color: rgba(255,255,255,0.16);
  border-left-color: white;
  font-weight: 600;
}

.nav-link i {
  font-size: 13.5px;
  width: 17px;
  text-align: center;
}

.nav-badge {
  font-size: 9px;
  padding: 2px 5px;
}

.logout-group {
  margin-top: auto;
}

.logout-btn {
  border: none;
  background: transparent;
  text-align: left;
  cursor: pointer;
}

/* Pour très petits écrans en hauteur */
@media (max-height: 720px) {
  .sidebar-brand {
    height: 48px;
  }

  .sidebar-logo,
  .brand-icon {
    width: 30px;
    height: 30px;
  }

  .brand-text h5 {
    font-size: 14px;
  }

  .brand-text small {
    display: none;
  }

  .nav-section {
    padding: 3px 12px 1px;
    font-size: 7.5px;
  }

  .nav-link {
    height: 27px;
    font-size: 11px;
  }

  .nav-link i {
    font-size: 12.5px;
  }
}
</style>