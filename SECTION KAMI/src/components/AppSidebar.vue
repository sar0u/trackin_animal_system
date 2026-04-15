<template>
   <aside class="sidebar">
       <div class="logo-section">
         <img src="./Imgs/logo.png" alt="TraceDZ" class="sidebar-logo">
         <div class="logo-text">
           <span class="brand">TraceDZ</span>
           <span class="role">ADMIN PANEL</span>
         </div>
       </div>

       <nav class="menu">
         <router-link to="/dashboard" class="menu-item" active-class="active">
             <i class="fas fa-th-large"></i> Tableau de bord
         </router-link>

         <router-link to="/users" class="menu-item" active-class="active">
             <i class="fas fa-users"></i> Utilisateurs
         </router-link>

         <router-link to="/farms" class="menu-item" active-class="active">
             <i class="fas fa-home"></i> Fermes
         </router-link>

         <router-link to="/animals" class="menu-item" active-class="active">
           <i class="fas fa-paw"></i> Animaux
         </router-link>

         <router-link to="/mouves" class="menu-item" active-class="active">
           <i class="fas fa-chart-line"></i> Mouvements & Stats
         </router-link>

         <router-link to="/fraude" class="menu-item" active-class="active">
           <i class="fas fa-shield-alt"></i> Gestion Fraude
         </router-link>
       </nav>

       <div class="logout-section" @click="logout" style="cursor: pointer;">
                <i class="fas fa-sign-out-alt"></i>
                <span>Déconnexion</span>
       </div>
   </aside>

</template>

<style scoped>

.sidebar {
  width: 260px;
  background: white;
  border-right: 1px solid #edf2f7;
  display: flex;
  flex-direction: column;
  padding: 25px 20px;
  position: fixed; /* Reste fixe à gauche */
  top: 0;
  left: 0;
  height: 100vh;
  box-sizing: border-box;
  font-family: 'Inter', sans-serif;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 40px;
}

.sidebar-logo { width: 35px; }

.logo-text .brand {
  display: block;
  font-weight: 800;
  font-size: 20px;
  color: #11D432; /* Vert TraceDZ */
}

.logo-text .role {
  font-size: 10px;
  color: #a0aec0;
  letter-spacing: 1.5px;
  text-transform: uppercase;
}

.menu {
  flex-grow: 1;
 }

.menu-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 12px 15px;
  text-decoration: none;
  color: #718096;
  border-radius: 10px;
  margin-bottom: 8px;
  font-weight: 500;
  transition: all 0.3s;
}

.menu-item i {
  width: 20px;
  font-size: 18px;
  }

.menu-item:hover {
  background: #f7fafc;
  color: #2ecc71;
}

.menu-item.active {
  background: #11D432; /* Fond vert pour l'élément actif */
  color: white;
}

.logout-section {
  color: #e53e3e;
  text-decoration: none;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 15px;
}

</style>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

const logout = () => {

  localStorage.removeItem('isAdminAuthenticated')
  localStorage.removeItem('user_role')
  localStorage.removeItem('user_name')

  router.push('/')

  console.log("Déconnexion réussie")
}
</script>