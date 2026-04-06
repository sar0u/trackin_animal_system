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
.main-content {
 font-family: 'Inter', sans-serif;
}

/* REPRISE DU LAYOUT DE BASE */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}
.page-header h1 {
 font-weight: 800;
}

.add-user-btn {
  background: #11D432;
  color: white;
  border: none;
  padding: 12px 20px;
  border-radius: 10px;
  font-weight: bold;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  box-shadow: 0 4px 15px rgba(46, 204, 113, 0.2);
}

/* FILTRES */

.filter-bar-container {
  background: white;
  padding: 15px 25px;
  border-radius: 12px; /* Arrondi plus doux */
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 25px;
  box-shadow: 0 4px 15px rgba(0,0,0,0.02);
}

.search-input-wrapper {
  background: #f1f5f9; /* Couleur exacte de l'image */
  flex: 2; /* Pour qu'elle prenne plus de place */
  padding: 12px 20px;
  border-radius: 12px;
}

.search-input-wrapper input {
  border: none;
  background: transparent;
  outline: none;
  width: 100%;
}

.filter-actions { display: flex; gap: 10px; }
.filter-select {
  border: 1px solid #edf2f7;
  border-radius: 8px;
  padding: 0 15px;
  color: #718096;
}

/* TABLEAU ET BADGES */
.table-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
  overflow: hidden;
}

.user-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  }
.user-table th {
  text-align: left;
  padding: 20px 15px;
  color: #718096; /* Gris bleuté plus soutenu */
  font-size: 11px;
  font-weight: 800; /* Plus gras */
  text-transform: uppercase;
  letter-spacing: 0.1em;
  border-bottom: 1px solid #edf2f7;
  }
.user-table td {
  padding: 15px;
  border-bottom: 1px solid #f8fafb;
  }

.avatar-mini {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: bold;
  font-size: 12px;
  margin-right: 12px;
}

.role-badge {
  padding: 6px 16px;
  border-radius: 20px; /* Style pilule */
  font-size: 10px;
  font-weight: 800;
}
.role-badge.éleveur {
  background: #eff6ff;
  color: #3b82f6;
  }
.role-badge.vétérinaire {
  background: #f5f3ff;
  color: #8b5cf6;
  }
.role-badge.admin {
  background: #f1f5f9;
  color: #475569;
  }

.status-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  font-weight: 700;
  }
.status-indicator.actif {
  color: #38a169;
  }
.status-indicator.inactif {
  color: #a0aec0;
  }
.status-indicator .dot {
  width: 8px;
  height: 8px;
  box-shadow: 0 0 5px rgba(46, 204, 113, 0.4);
  }

.action-btn {
  background: none;
  border: none;
  color: #a0aec0;
  cursor: pointer;
  font-size: 16px;
  }

/* PAGINATION */
.pagination {
  display: flex;
  justify-content: space-between; /* Espace le texte à gauche et les boutons à droite */
  align-items: center;
  padding: 20px 25px;
  background: white;
  border-top: 1px solid #edf2f7;
}

.pages {
  display: flex;
  gap: 8px;
  margin-left: auto;
}

.page-num, .page-nav {
  width: 36px;
  height: 36px;
  background: white;
  border: 1px solid #edf2f7;
  border-radius: 8px; /* Carré arrondi */
  color: #718096;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
}

.page-num.active {
  background: #11D432; /* Vert TraceDZ */
  color: white;
  border-color: #2ecc71;
}

/* BANNER */
.info-banner {
  background: #f0fff4;
  border: 1px solid #c6f6d5;
  margin-top: 20px;
  padding: 25px;
  border-radius: 16px;
  display: flex;
  align-items: flex-start;
  gap: 20px;
  color: #2d3748;
}
</style>

<script setup>
import { ref } from 'vue'

const users = ref([
  { id: 'US-2045', name: 'Selmani Salim', initials: 'SS', color: '#81E6D9', email: 'sel.sa@gmail.com', role: 'Éleveur', status: 'Actif' },
  { id: 'US-2046', name: 'Ait Daoud Younes', initials: 'AY', color: '#9AE6B4', email: 'Yns.ad@gmail.com', role: 'Vétérinaire', status: 'Actif' },
  { id: 'US-2047', name: 'El rifai Wassim', initials: 'EW', color: '#FEB2B2', email: 'elrifaiwass@gmail.com', role: 'Admin', status: 'Inactif' }
])
</script>