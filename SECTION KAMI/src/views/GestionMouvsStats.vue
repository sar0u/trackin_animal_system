<template>
  <div class="audit-container">

    <div class="header-section">
      <div class="breadcrumb">Admin Console &rsaquo; Système d'Audit</div>
      <h1>Journal d'Audit & Intégrité Système</h1>
      <p class="subtitle">Registre immuable de toutes les opérations effectuées sur la plateforme.</p>
    </div>

    <div class="filters-card">
      <div class="filters-grid">
        <div class="filter-group">
          <label>RECHERCHE</label>
          <div class="input-with-icon">
            <i class="fas fa-search"></i>
            <input type="text" v-model="searchQuery" placeholder="Ex: 284, 5, Utilisateur...">
          </div>
        </div>

        <div class="filter-group">
          <label>FILTRER PAR UTILISATEUR EXACT</label>
          <select v-model="filterUser">
            <option value="">Tous les utilisateurs</option>
            <option v-for="user in usersList" :key="user.id" :value="user.id">
              {{ user.lastName }} {{ user.firstName }} (ID: {{ user.id }})
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label>PÉRIODE D'AUDIT</label>
          <div class="input-with-icon">
            <i class="far fa-calendar-alt"></i>
            <input type="text" placeholder="Toutes les dates">
          </div>
        </div>
      </div>

      <div class="filters-actions">
        <div class="filter-group action-type-group">
          <label>TYPE D'ACTION</label>
          <div class="tabs">
            <button :class="{ active: filterAction === '' }" @click="filterAction = ''">TOUT</button>
            <button :class="{ active: filterAction === 'CREATE' }" @click="filterAction = 'CREATE'">CREATE</button>
            <button :class="{ active: filterAction === 'UPDATE' }" @click="filterAction = 'UPDATE'">UPDATE</button>
            <button :class="{ active: filterAction === 'DELETE' }" @click="filterAction = 'DELETE'">DELETE</button>
          </div>
        </div>

      </div>
    </div>

    <div class="audit-table-card">
      <div class="card-header">
        <div class="header-left">
          <i class="fas fa-list-alt text-gray"></i>
          <h2>Flux d'Audit Temps Réel</h2>
        </div>
        <div class="system-status">
          <span class="pulse-dot"></span> CONNECTÉ
        </div>
      </div>

      <div v-if="isLoading" class="loading-state">
        <i class="fas fa-circle-notch fa-spin"></i> Synchronisation avec la base de données...
      </div>

      <table v-else class="data-table">
        <thead>
        <tr>
          <th>ID LOG</th>
          <th>UTILISATEUR</th>
          <th>ACTION / CIBLE</th>
          <th>PLUS D'INFOS</th>
          <th>HORODATAGE</th>
          <th>ANCIENNES DONNÉES</th>
          <th>NOUVELLES DONNÉES</th>
        </tr>
        </thead>
        <tbody>
        <tr v-if="paginatedLogs.length === 0">
          <td colspan="6" class="text-center">Aucun journal d'audit trouvé.</td>
        </tr>
        <tr v-for="log in paginatedLogs" :key="log.id">
          <td class="log-id">#{{ log.id }}</td>

          <td>
            <div class="user-info">
              <span class="u-name">{{ getUserName(log.userId) }}</span>
              <span class="u-id">ID User : {{ log.userId }}</span>
            </div>
          </td>

          <td>
            <div class="action-info">
              <span class="badge-action" :class="getActionClass(log.actionType)">{{ log.actionType }}</span>
              <span class="entity-name">{{ log.entityName }}</span>
            </div>
          </td>

          <td>
            <div class="date-info">
              <span class="date">{{ formatDate(log.eventTimestamp) }}</span>
              <span class="time">{{ formatTime(log.eventTimestamp) }}</span>
            </div>
          </td>

          <td class="json-cell">
            <div class="json-block" :class="{ 'is-null': !log.oldValues || log.oldValues === 'null' }">
              {{ formatJsonSnippet(log.oldValues) }}
            </div>
          </td>

          <td class="json-cell">
            <div class="json-block" :class="getNewJsonClass(log.actionType)">
              {{ formatJsonSnippet(log.newValues) }}
            </div>
          </td>

          <td>
            <div class="more-info">
              <div class="entity-tag">
                <i class="fas fa-fingerprint"></i>
                <span>{{ log.entityType }} #{{ log.entityId }}</span>
              </div>
              <div class="ip-address">
                <i class="fas fa-network-wired"></i> {{ log.ipAddress || '0.0.0.0' }}
              </div>
              <div v-if="log.details" class="log-detail-text" :title="log.details">
                {{ log.details }}
              </div>
            </div>
          </td>
        </tr>
        </tbody>
      </table>

      <div class="table-footer">
        <span class="showing-text">Affichage de {{ filteredLogs.length > 0 ? (currentPage - 1) * itemsPerPage + 1 : 0 }}-{{ Math.min(currentPage * itemsPerPage, filteredLogs.length) }} sur {{ filteredLogs.length }} logs d'audit</span>
        <div class="pagination">
          <button :disabled="currentPage === 1" @click="currentPage--"><i class="fas fa-chevron-left"></i></button>
          <button class="page-btn active">{{ currentPage }}</button>
          <button class="page-btn" v-if="currentPage < totalPages" @click="currentPage++">{{ currentPage + 1 }}</button>
          <button :disabled="currentPage === totalPages || totalPages === 0" @click="currentPage++"><i class="fas fa-chevron-right"></i></button>
        </div>
      </div>
    </div>

    <button class="floating-btn"><i class="fas fa-shield-alt"></i></button>

  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import api from '../services/api';

const auditLogs = ref([]);
const usersList = ref([]);
const usersDict = ref({});
const isLoading = ref(true);

const searchQuery = ref('');
const filterUser = ref('');
const filterAction = ref('');

const currentPage = ref(1);
const itemsPerPage = 10;

const fetchAuditData = async () => {
  try {
    isLoading.value = true;

    // 🟢 SANS LES ROULETTES : On interroge directement l'API
    const [logsRes, usersRes] = await Promise.all([
      api.get('/audit-logs'),
      api.get('/users').catch(() => ({ data: [] }))
    ]);

    // On assigne 100% des vraies données
    auditLogs.value = logsRes.data || [];
    usersList.value = usersRes.data || [];

    const uDict = {};
    usersRes.data.forEach(u => { uDict[u.id] = u; });
    usersDict.value = uDict;

  } catch (error) {
    console.error("Erreur récupération Audit:", error);
  } finally {
    isLoading.value = false;
  }
};

onMounted(fetchAuditData);

// --- 🟢 FILTRES (CORRIGÉS POUR CHERCHER PAR ID) ---
const filteredLogs = computed(() => {
  let filtered = auditLogs.value.filter(log => {
    const q = searchQuery.value.toLowerCase().trim();

    const logIdStr = log.id?.toString() || '';
    const userIdStr = log.userId?.toString() || '';
    const entityNameStr = log.entityName?.toLowerCase() || '';
    const entityTypeStr = log.entityType?.toLowerCase() || ''; // Ajout
    const ipStr = log.ipAddress?.toLowerCase() || '';         // Ajout

    const matchesSearch = q === '' ||
        logIdStr.includes(q) ||
        userIdStr.includes(q) ||
        entityNameStr.includes(q) ||
        entityTypeStr.includes(q) ||
        ipStr.includes(q);

    const userMatch = filterUser.value === '' || log.userId === filterUser.value;
    const actionMatch = filterAction.value === '' || log.actionType === filterAction.value;

    return matchesSearch && userMatch && actionMatch;
  });

  filtered.sort((a, b) => new Date(b.eventTimestamp) - new Date(a.eventTimestamp));
  return filtered;
});

const totalPages = computed(() => Math.ceil(filteredLogs.value.length / itemsPerPage));

const paginatedLogs = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredLogs.value.slice(start, start + itemsPerPage);
});

// --- HELPERS ---
const getUserName = (id) => {
  if (!id || !usersDict.value[id]) return "Système / Inconnu";
  const u = usersDict.value[id];
  return `${u.lastName} ${u.firstName}`;
};

const formatDate = (dateStr) => {
  if (!dateStr) return '--/--/----';
  return new Date(dateStr).toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' });
};

const formatTime = (dateStr) => {
  if (!dateStr) return '--:--:--';
  return new Date(dateStr).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
};

const formatJsonSnippet = (jsonStr) => {
  if (!jsonStr || jsonStr === 'null') return 'null';
  if (jsonStr.length > 55) return jsonStr.substring(0, 55) + '...';
  return jsonStr;
};

const getActionClass = (type) => {
  if (type === 'CREATE') return 'badge-green';
  if (type === 'UPDATE') return 'badge-blue';
  if (type === 'DELETE') return 'badge-red';
  return 'badge-gray';
};

const getNewJsonClass = (type) => {
  if (type === 'DELETE') return 'is-null-red';
  if (type === 'CREATE' || type === 'UPDATE') return 'is-new-green';
  return '';
};
</script>

<style scoped>
/* BASE */
.audit-container { font-family: 'Inter', sans-serif; background-color: #f8fafc; min-height: 100vh; padding: 40px; color: #0f172a; position: relative;}

/* HEADER */
.header-section { margin-bottom: 30px; }
.breadcrumb { font-size: 12px; color: #64748b; font-weight: 600; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px;}
.header-section h1 { font-size: 28px; font-weight: 900; margin: 0; color: #0f172a; letter-spacing: -0.5px; }
.subtitle { color: #475569; font-size: 15px; margin-top: 8px; }

/* FILTRES (Carte Supérieure) */
.filters-card { background: white; border-radius: 12px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); margin-bottom: 30px; border: 1px solid #e2e8f0;}
.filters-grid { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; margin-bottom: 25px;}

.filter-group { display: flex; flex-direction: column; gap: 8px; margin-right: 40px; }
.filter-group label { font-size: 11px; font-weight: 800; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px;}

.input-with-icon { position: relative; }
.input-with-icon i { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #94a3b8; }
.input-with-icon input { width: 100%; padding: 12px 15px 12px 40px; border: 1px solid #cbd5e1; border-radius: 8px; background: #f8fafc; outline: none; font-size: 13px; font-family: inherit; color: #334155;}
.input-with-icon input:focus { border-color: #0f172a; background: white;}

.filter-group select { padding: 12px 15px; border: 1px solid #cbd5e1; border-radius: 8px; background: #f8fafc; outline: none; font-size: 13px; color: #334155; font-weight: 500;}

/* Actions Filtres (Onglets et Bouton) */
.filters-actions { display: flex; justify-content: space-between; align-items: flex-end; }
.tabs { display: flex; background: white; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; }
.tabs button { padding: 10px 20px; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #64748b; cursor: pointer; transition: 0.2s; border-right: 1px solid #e2e8f0;}
.tabs button:last-child { border-right: none; }
.tabs button:hover { background: #f1f5f9; }
.tabs button.active { background: white; color: #0f172a; border-bottom: 2px solid #0f172a; }

/* TABLEAU D'AUDIT */
.audit-table-card { background: white; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); overflow: hidden; border: 1px solid #e2e8f0; }
.card-header { padding: 20px 25px; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; }
.header-left { display: flex; align-items: center; gap: 12px; }
.header-left i { font-size: 18px; color: #64748b; }
.header-left h2 { margin: 0; font-size: 16px; font-weight: 800; color: #0f172a; }

.system-status { display: flex; align-items: center; gap: 8px; font-size: 10px; font-weight: 800; color: #16a34a; letter-spacing: 0.5px;}
.pulse-dot { width: 8px; height: 8px; background: #22c55e; border-radius: 50%; }

.data-table { width: 100%; border-collapse: collapse; }
.data-table th { text-align: left; padding: 15px 25px; font-size: 10px; font-weight: 800; color: #64748b; text-transform: uppercase; border-bottom: 1px solid #f1f5f9; letter-spacing: 0.5px;}
.data-table td { padding: 20px 25px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }

.log-id { font-weight: 800; color: #0f172a; font-size: 13px; }

.user-info, .action-info, .date-info { display: flex; flex-direction: column; gap: 4px; }
.u-name { font-weight: 800; color: #0f172a; font-size: 14px; }
.u-id { font-size: 11px; color: #64748b; font-weight: 600;}

.entity-name { font-weight: 700; color: #334155; font-size: 13px; margin-top: 4px;}
.badge-action { padding: 4px 8px; border-radius: 4px; font-size: 10px; font-weight: 900; letter-spacing: 0.5px; display: inline-block; width: max-content;}
.badge-green { background: #dcfce3; color: #166534; }
.badge-blue { background: #dbeafe; color: #1e40af; }
.badge-red { background: #fee2e2; color: #991b1b; }
.badge-gray { background: #f1f5f9; color: #475569; }

.date { font-weight: 600; color: #334155; font-size: 13px; }
.time { font-size: 12px; color: #64748b; }

.json-cell { width: 25%; }
.json-block { background: #f8fafc; border: 1px solid #f1f5f9; padding: 10px 12px; border-radius: 6px; font-family: 'JetBrains Mono', 'Courier New', monospace; font-size: 11px; color: #64748b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 250px;}
.is-null { color: #cbd5e1; }
.is-new-green { background: #f0fdf4; border-color: #dcfce3; color: #16a34a; }
.is-null-red { background: #fef2f2; border-color: #fee2e2; color: #dc2626; }

/* FOOTER & PAGINATION */
.table-footer { padding: 20px 25px; display: flex; justify-content: space-between; align-items: center; background: white;}
.showing-text { font-size: 12px; color: #64748b; font-weight: 500; }
.pagination { display: flex; gap: 5px; }
.pagination button { width: 32px; height: 32px; border: 1px solid #e2e8f0; background: white; border-radius: 6px; cursor: pointer; color: #475569; display: flex; align-items: center; justify-content: center; transition: 0.2s; font-size: 12px;}
.pagination button:hover:not(:disabled) { border-color: #cbd5e1; background: #f8fafc;}
.pagination button:disabled { opacity: 0.5; cursor: not-allowed; }
.pagination button.active { background: #0f172a; color: white; border-color: #0f172a; font-weight: 700;}

/* BOUTON FLOTTANT */
.floating-btn { position: fixed; bottom: 30px; right: 30px; width: 50px; height: 50px; background: #0f172a; color: white; border: none; border-radius: 12px; font-size: 20px; box-shadow: 0 10px 25px rgba(15, 23, 42, 0.3); cursor: pointer; display: flex; justify-content: center; align-items: center; transition: 0.2s;}
.floating-btn:hover { transform: translateY(-3px); box-shadow: 0 15px 30px rgba(15, 23, 42, 0.4);}
.loading-state { text-align: center; padding: 50px; font-size: 14px; color: #64748b; font-weight: 600; }


.more-info {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.entity-tag {
  font-size: 11px;
  font-weight: 700;
  color: #1e3a8a;
  background: #eff6ff;
  padding: 2px 6px;
  border-radius: 4px;
  width: max-content;
  display: flex;
  align-items: center;
  gap: 5px;
}

.ip-address {
  font-size: 11px;
  font-family: 'JetBrains Mono', monospace;
  color: #64748b;
  display: flex;
  align-items: center;
  gap: 5px;
}

.log-detail-text {
  font-size: 11px;
  font-style: italic;
  color: #94a3b8;
  max-width: 180px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* On ajuste la largeur des cellules JSON pour faire de la place */
.json-cell { width: 20%; }

/* Optionnel : Ajustement du tableau pour le scroll si trop de colonnes */
.audit-table-card {
  overflow-x: auto;
}
.data-table {
  min-width: 1100px; /* Force un scroll horizontal propre sur petit écran */
}

@media (max-width: 1024px) {
  .filters-grid { grid-template-columns: 1fr; }
  .filters-actions { flex-direction: column; align-items: flex-start; gap: 20px;}
  .json-block { max-width: 150px; }
}
</style>