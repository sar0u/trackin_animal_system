<template>
  <aside class="sidebar">
    <div class="logo-section">
      <img src="./Imgs/logo.png" alt="DZCheptel" class="sidebar-logo">
      <div class="logo-text">
        <span class="brand">DZCheptel</span>
        <span class="role">Admin Panel</span>
      </div>
    </div>

    <nav class="menu">
      <div class="menu-group">
        <div class="menu-section-title">Accueil</div>
        <router-link to="/dashboard" class="menu-item" active-class="active">
          <i class="fas fa-th-large"></i><span>Tableau de bord</span>
        </router-link>
      </div>

      <div class="menu-group">
        <div class="menu-section-title">Gestion</div>
        <router-link to="/users" class="menu-item" active-class="active">
          <i class="fas fa-users"></i><span>Utilisateurs</span>
        </router-link>
        <router-link to="/farms" class="menu-item" active-class="active">
          <i class="fas fa-home"></i><span>Fermes</span>
        </router-link>
        <router-link to="/subsidies" class="menu-item" active-class="active">
          <i class="fas fa-hand-holding-usd"></i><span>Subventions</span>
        </router-link>
      </div>

      <div class="menu-group">
        <div class="menu-section-title">Animaux</div>
        <router-link to="/animals" class="menu-item" active-class="active">
          <i class="fas fa-paw"></i><span>Animaux</span>
        </router-link>
        <router-link to="/reproductions" class="menu-item" active-class="active">
          <i class="fas fa-dna"></i><span>Reproductions</span>
        </router-link>
      </div>

      <div class="menu-group">
        <div class="menu-section-title">Santé</div>
        <router-link to="/health-records" class="menu-item" active-class="active">
          <i class="fas fa-notes-medical"></i><span>Dossiers Santé</span>
        </router-link>
        <router-link to="/sanitary-campaigns" class="menu-item" active-class="active">
          <i class="fas fa-syringe"></i><span>Campagnes</span>
        </router-link>
      </div>

      <div class="menu-group">
        <div class="menu-section-title">Contrôle</div>
        <router-link to="/movements" class="menu-item" active-class="active">
          <i class="fas fa-exchange-alt"></i><span>Mouvements</span>
        </router-link>
        <router-link to="/fraude" class="menu-item" active-class="active">
          <i class="fas fa-shield-alt"></i><span>Constats & Fraude</span>
        </router-link>
      </div>

      <div class="menu-group">
        <div class="menu-section-title">Audit</div>
        <router-link to="/audit" class="menu-item" active-class="active">
          <i class="fas fa-chart-line"></i><span>Journal de traçabilité</span>
        </router-link>
      </div>
    </nav>

    <div class="logout-section" @click="logout">
      <i class="fas fa-sign-out-alt"></i>
      <span>Déconnexion</span>
    </div>
  </aside>

</template>

<style scoped>

.sidebar {
  width: 245px;
  background: #ffffff;
  border-right: 1px solid #edf2f7;
  display: flex;
  flex-direction: column;
  padding: 20px 14px 14px;
  position: fixed;
  top: 0;
  left: 0;
  height: 100vh;
  box-sizing: border-box;
  font-family: 'Inter', sans-serif;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 11px;
  padding: 4px 8px 18px;
  margin-bottom: 6px;
  border-bottom: 1px solid #f1f5f9;
}

.sidebar-logo {
  width: 36px;
  height: 36px;
  object-fit: contain;
}

.logo-text {
  display: flex;
  flex-direction: column;
  line-height: 1.15;
}

.logo-text .brand {
  font-weight: 800;
  font-size: 18px;
  color: #0B5D1E;
  letter-spacing: -0.3px;
}

.logo-text .role {
  font-size: 10px;
  color: #94a3b8;
  letter-spacing: 0.4px;
  font-weight: 600;
  margin-top: 2px;
}

.menu {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  padding-right: 4px;
  margin-right: -4px;
}

.menu::-webkit-scrollbar { width: 4px; }
.menu::-webkit-scrollbar-track { background: transparent; }
.menu::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 4px; }
.menu::-webkit-scrollbar-thumb:hover { background: #cbd5e0; }

.menu-group {
  margin-bottom: 14px;
}

.menu-group:last-child {
  margin-bottom: 8px;
}

.menu-section-title {
  font-size: 10px;
  font-weight: 700;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 1px;
  padding: 0 12px 6px;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 9px 12px;
  text-decoration: none;
  color: #64748b;
  border-radius: 8px;
  margin-bottom: 2px;
  font-weight: 500;
  font-size: 13.5px;
  transition: background 0.15s ease, color 0.15s ease;
  position: relative;
}

.menu-item i {
  width: 18px;
  font-size: 14px;
  text-align: center;
  color: #94a3b8;
  transition: color 0.15s ease;
}

.menu-item:hover {
  background: #f8fafc;
  color: #0f172a;
}

.menu-item:hover i {
  color: #0B5D1E;
}

.menu-item.active {
  background: linear-gradient(135deg, #0B5D1E 0%, #063B16 100%);
  color: white;
  font-weight: 600;
  box-shadow: 0 4px 10px -2px rgba(11, 93, 30, 0.35);
}

.menu-item.active i {
  color: white;
}

.logout-section {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 11px 12px;
  margin-top: 8px;
  border-top: 1px solid #f1f5f9;
  padding-top: 14px;
  color: #ef4444;
  font-weight: 600;
  font-size: 13.5px;
  cursor: pointer;
  border-radius: 8px;
  transition: background 0.15s ease;
}

.logout-section i {
  width: 18px;
  font-size: 14px;
  text-align: center;
}

.logout-section:hover {
  background: #fef2f2;
}

</style>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

const logout = () => {

  localStorage.removeItem('isAdminAuthenticated')
  localStorage.removeItem('token')
  localStorage.removeItem('user_role')
  localStorage.removeItem('user_name')
  localStorage.removeItem('user_email')

  router.push('/')

  console.log("Déconnexion réussie")
}
</script>