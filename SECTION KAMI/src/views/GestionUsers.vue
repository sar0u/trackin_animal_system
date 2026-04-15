<template>


    <main class="main-content">
      <section class="content-body">
        <div class="page-header">
          <div>
            <h1>Gestion des Utilisateurs</h1>
            <p class="subtitle">Gérez les comptes, définissez les rôles et contrôlez les accès.</p>
          </div>
          <button class="add-user-btn">
            <i class="fas fa-user-plus"></i> Ajouter un Utilisateur
          </button>
        </div>

        <div class="filter-bar-container">
          <div class="search-input-wrapper">
            <i class="fas fa-search"></i>
            <input type="text" placeholder="Rechercher par nom, prénom ou email...">
          </div>
          <div class="filter-actions">
            <select class="filter-select"><option>Tous les rôles</option></select>
            <select class="filter-select"><option>Tous les statuts</option></select>
            <button class="filter-btn"><i class="fas fa-sliders-h"></i></button>
          </div>
        </div>

        <div class="card table-card">
          <table class="user-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>NOM & PRÉNOM</th>
                <th>EMAIL</th>
                <th>RÔLE</th>
                <th>STATUT</th>
                <th>ACTIONS</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="user in users" :key="user.id">
                <td class="user-id">#{{ user.id }}</td>
                <td class="user-info">
                  <div class="avatar-mini" :style="{ backgroundColor: user.color }">
                    {{ user.initials }}
                  </div>
                  <strong>{{ user.name }}</strong>
                </td>
                <td>{{ user.email }}</td>
                <td>
                  <span class="role-badge" :class="user.role.toLowerCase()">
                    {{ user.role }}
                  </span>
                </td>
                <td>
                  <span class="status-indicator" :class="user.status.toLowerCase()">
                    <span class="dot"></span> {{ user.status }}
                  </span>
                </td>
                <td>
                  <button class="action-btn edit"><i class="fas fa-pen"></i></button>
                </td>
              </tr>
            </tbody>
          </table>

          <div class="pagination">
            <span>Affichage de 1 - 4 sur 124 utilisateurs</span>
            <div class="pages">
              <button class="page-nav"><i class="fas fa-chevron-left"></i></button>
              <button class="page-num active">1</button>
              <button class="page-num">2</button>
              <button class="page-num">3</button>
              <button class="page-nav"><i class="fas fa-chevron-right"></i></button>
            </div>
          </div>
        </div>

        <div class="info-banner">
          <i class="fas fa-info-circle"></i>
          <div>
            <strong>Information de sécurité</strong>
            <p>Toute suppression d'utilisateur est irréversible. Préférez changer le statut en "Inactif".</p>
          </div>
        </div>
      </section>
    </main>

</template>

<style scoped>
/* POLICE ET BASE */
.main-content {
  font-family: 'Inter', sans-serif;
  color: #2d3748;
}

/* HEADER & TITRE */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.page-header h1 {
  font-size: 26px;
  font-weight: 800;
  margin: 0;
  color: #1a202c;
}

.subtitle {
  color: #718096;
  font-size: 14px;
  margin-top: 5px;
}

/* BOUTON AJOUTER */
.add-user-btn {
  background: #11D432;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(17, 212, 50, 0.2);
}

.add-user-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(17, 212, 50, 0.3);
  filter: brightness(1.1);
}

/* BARRE DE RECHERCHE ET FILTRES */
.filter-bar-container {
  background: white;
  padding: 15px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 25px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  border: 1px solid #edf2f7;
}

.search-input-wrapper {
  background: #f8fafc;
  flex: 1;
  padding: 10px 18px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 12px;
  border: 1px solid #e2e8f0;
  transition: all 0.2s;
}

.search-input-wrapper:focus-within {
  border-color: #11D432;
  background: white;
  box-shadow: 0 0 0 3px rgba(17, 212, 50, 0.1);
}

.search-input-wrapper i { color: #a0aec0; }
.search-input-wrapper input {
  border: none;
  background: transparent;
  outline: none;
  width: 100%;
  font-size: 14px;
}

.filter-select {
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 10px 15px;
  color: #4a5568;
  font-weight: 600;
  background: white;
  outline: none;
  cursor: pointer;
}

/* TABLEAU MODERNE */
.table-card {
  background: white;
  border-radius: 16px;
  border: 1px solid #edf2f7;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
  overflow: hidden;
}

.user-table {
  width: 100%;
  border-collapse: collapse;
}

.user-table th {
  text-align: left;
  padding: 18px 20px;
  background: #f8fafc;
  color: #718096;
  font-size: 11px;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid #edf2f7;
}

.user-table tr {
  transition: all 0.2s ease;
}

.user-table tr:hover {
  background-color: #f0fdf4; /* Teinte verte très légère au survol */
}

.user-table td {
  padding: 16px 20px;
  border-bottom: 1px solid #f1f5f9;
  font-size: 14px;
}

/* INFO UTILISATEUR */
.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-info strong {
  color: #1a202c;
  font-weight: 700;
}

.user-id {
  font-family: 'JetBrains Mono', monospace;
  color: #718096;
  font-weight: 600;
  font-size: 13px;
}

.avatar-mini {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 800;
  font-size: 13px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

/* BADGES ET STATUTS */
.role-badge {
  padding: 5px 12px;
  border-radius: 8px;
  font-size: 11px;
  font-weight: 700;
  display: inline-block;
}

.role-badge.éleveur { background: #EBF8FF; color: #3182CE; }
.role-badge.vétérinaire { background: #FAF5FF; color: #805AD5; }
.role-badge.admin { background: #F7FAFC; color: #4A5568; }

.status-indicator {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 700;
}

.status-indicator.actif { background: #F0FFF4; color: #38A169; }
.status-indicator.inactif { background: #F7FAFC; color: #A0AEC0; }

.dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  display: inline-block;
}
.actif .dot { background: #38A169; box-shadow: 0 0 8px #38A169; }
.inactif .dot { background: #A0AEC0; }

/* ACTIONS - CRAYON ET POUBELLE */
.action-buttons {
  display: flex;
  gap: 8px;
}

.action-btn {
  width: 34px;
  height: 34px;
  border-radius: 8px;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 14px;
}

.action-btn.edit {
  background: #EBF8FF;
  color: #3182CE;
}

.action-btn.edit:hover {
  background: #3182CE;
  color: white;
}

.action-btn.delete {
  background: #FFF5F5;
  color: #E53E3E;
}

.action-btn.delete:hover {
  background: #E53E3E;
  color: white;
}

/* PAGINATION */
.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 25px;
  background: #f8fafc;
  color: #718096;
  font-size: 13px;
  font-weight: 600;
}

.pages { display: flex; gap: 6px; }

.page-num, .page-nav {
  min-width: 32px;
  height: 32px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  background: white;
  color: #4a5568;
  font-weight: 700;
  cursor: pointer;
  transition: 0.2s;
}

.page-num.active {
  background: #11D432;
  color: white;
  border-color: #11D432;
}

.page-num:hover:not(.active) {
  background: #edf2f7;
}


.info-banner {
  background: #ebf8ff;
  border: 1px solid #bee3f8;
  margin-top: 25px;
  padding: 20px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 15px;
}

.info-banner i { color: #3182ce; font-size: 20px; }
.info-banner strong { display: block; color: #2a4365; font-size: 14px; }
.info-banner p { margin: 0; color: #2c5282; font-size: 13px; }
</style>

<script setup>
import { ref } from 'vue'

const users = ref([
  { id: 'US-2045', name: 'Selmani Salim', initials: 'SS', color: '#81E6D9', email: 'sel.sa@gmail.com', role: 'Éleveur', status: 'Actif' },
  { id: 'US-2046', name: 'Ait Daoud Younes', initials: 'AY', color: '#9AE6B4', email: 'Yns.ad@gmail.com', role: 'Vétérinaire', status: 'Actif' },
  { id: 'US-2047', name: 'El rifai Wassim', initials: 'EW', color: '#FEB2B2', email: 'elrifaiwass@gmail.com', role: 'Admin', status: 'Inactif' }
])
</script>