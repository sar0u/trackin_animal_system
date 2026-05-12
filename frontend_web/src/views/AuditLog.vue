<template>
  <div class="audit-container">

    <div class="header-section">
      <div class="breadcrumb">Admin Console &rsaquo; Journal de traçabilité</div>
      <h1>Journal de traçabilité</h1>
      <p class="subtitle">Registre des opérations sur la plateforme (qui, quoi, quand).</p>
    </div>

    <p v-if="loadError" class="api-error-banner">{{ loadError }}</p>

    <div class="filters-card">
      <div class="filters-grid">
        <div class="filter-group">
          <label>RECHERCHE</label>
          <div class="input-with-icon">
            <i class="fas fa-search"></i>
            <input type="text" v-model="searchQuery" placeholder="Nom, action, entité, IP, ID...">
          </div>
        </div>

        <div class="filter-group">
          <label>TYPE D'ACTION</label>
          <div class="tabs">
            <button :class="{ active: filterAction === '' }" @click="filterAction = ''">TOUS</button>
            <button :class="{ active: filterAction === 'CREATE' }" @click="filterAction = 'CREATE'">CRÉER</button>
            <button :class="{ active: filterAction === 'UPDATE' }" @click="filterAction = 'UPDATE'">MODIFIER</button>
            <button :class="{ active: filterAction === 'DELETE' }" @click="filterAction = 'DELETE'">SUPPRIMER</button>
          </div>
        </div>

        <div class="filter-group">
          <label>PÉRIODE (DU / AU)</label>
          <div class="period-row">
            <input type="date" v-model="startDate" class="filter-date" aria-label="Date de début">
            <input type="date" v-model="endDate" class="filter-date" aria-label="Date de fin">
          </div>
        </div>
      </div>

      <div class="filters-actions">
        <div class="filter-group">
          <label>TYPE D'ENTITÉ</label>
          <select v-model="filterEntityType">
            <option value="">Toutes les entités</option>
            <option v-for="et in entityTypes" :key="et" :value="et">{{ et }}</option>
          </select>
        </div>

        <button v-if="hasActiveFilters" class="btn-reset" @click="resetFilters">
          <i class="fas fa-times"></i> Réinitialiser les filtres
        </button>
      </div>
    </div>

    <div class="audit-table-card">
      <div class="card-header">
        <div class="header-left">
          <i class="fas fa-list-alt text-gray"></i>
          <h2>Historique des événements</h2>
        </div>
        <div class="system-status">
          <span class="pulse-dot"></span>
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
          <td colspan="7" class="text-center empty-row">Aucune entrée à afficher (ou filtres trop restrictifs).</td>
        </tr>
        <tr v-for="log in paginatedLogs" :key="log.id">
          <td class="log-id">#{{ log.id }}</td>

          <td>
            <div class="user-info">
              <span class="u-name">{{ getUserName(log.userId) }}</span>
              <span class="u-id" v-if="log.userId">ID User : {{ log.userId }}</span>
            </div>
          </td>

          <td>
            <div class="action-info">
              <span class="badge-action" :class="getActionClass(log.action)">{{ log.action }}</span>
              <span class="entity-name">{{ log.entityType }}</span>
            </div>
          </td>

          <td>
            <div class="more-info">
              <div class="entity-tag">
                <i class="fas fa-fingerprint"></i>
                <span>{{ log.entityType }} #{{ log.entityId }}</span>
              </div>
              <div class="ip-address">
                <i class="fas fa-network-wired"></i> {{ log.ipAddress || '—' }}
              </div>
              <div v-if="log.details" class="log-detail-text" :title="log.details">
                {{ log.details }}
              </div>
            </div>
          </td>

          <td>
            <div class="date-info">
              <span class="date">{{ formatDate(log.createdAt) }}</span>
              <span class="time">{{ formatTime(log.createdAt) }}</span>
            </div>
          </td>

          <td class="json-cell" @click="log.action !== 'CREATE' && openJsonModal('Anciennes données', log.oldValues)" :style="log.action !== 'CREATE' ? 'cursor:pointer' : 'cursor:default'" :title="log.action !== 'CREATE' ? 'Cliquer pour voir le JSON complet' : ''">
            <div class="json-block" :class="getOldJsonClass(log.action, log.oldValues)">
              {{ log.action === 'CREATE' ? '— (création)' : formatJsonSnippet(log.oldValues) }}
            </div>
          </td>

          <td class="json-cell" @click="log.action !== 'DELETE' && openJsonModal('Nouvelles données', log.newValues)" :style="log.action !== 'DELETE' ? 'cursor:pointer' : 'cursor:default'" :title="log.action !== 'DELETE' ? 'Cliquer pour voir le JSON complet' : ''">
            <div class="json-block" :class="getNewJsonClass(log.action, log.newValues)">
              {{ log.action === 'DELETE' ? '— (suppression)' : formatJsonSnippet(log.newValues) }}
            </div>
          </td>
        </tr>
        </tbody>
      </table>

      <div class="table-footer">
        <span class="showing-text">Affichage de {{ filteredLogs.length > 0 ? (currentPage - 1) * itemsPerPage + 1 : 0 }}-{{ Math.min(currentPage * itemsPerPage, filteredLogs.length) }} sur {{ filteredLogs.length }} entrées</span>
        <div class="pagination">
          <button :disabled="currentPage === 1" @click="currentPage--"><i class="fas fa-chevron-left"></i></button>
          <template v-for="(page, idx) in visiblePages" :key="idx">
            <span v-if="page === '...'" class="page-ellipsis">…</span>
            <button v-else class="page-btn" :class="{ active: currentPage === page }" @click="goToPage(page)">{{ page }}</button>
          </template>
          <button :disabled="currentPage === totalPages || totalPages === 0" @click="currentPage++"><i class="fas fa-chevron-right"></i></button>
        </div>
      </div>
    </div>

  </div>

  <!-- Modal JSON viewer -->
  <div v-if="showJsonModal" class="modal-overlay" @click.self="showJsonModal = false">
    <div class="json-modal-content">
      <div class="json-modal-header">
        <h2><i class="fas fa-code"></i> {{ jsonModalTitle }}</h2>
        <button class="btn-close-json" @click="showJsonModal = false"><i class="fas fa-times"></i></button>
      </div>
      <pre class="json-modal-body">{{ jsonModalContent }}</pre>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import api from '../services/api';

const auditLogs = ref([]);
const usersDict = ref({});
const isLoading = ref(true);
const loadError = ref('');

const showJsonModal = ref(false);
const jsonModalTitle = ref('');
const jsonModalContent = ref('');

const openJsonModal = (title, jsonStr) => {
  if (!jsonStr || jsonStr === 'null') return;
  jsonModalTitle.value = title;
  try {
    jsonModalContent.value = JSON.stringify(JSON.parse(jsonStr), null, 2);
  } catch {
    jsonModalContent.value = jsonStr;
  }
  showJsonModal.value = true;
};

const searchQuery = ref('');
const filterAction = ref('');
const filterEntityType = ref('');
const startDate = ref('');
const endDate = ref('');

const currentPage = ref(1);
const itemsPerPage = 10;

const fetchAuditData = async () => {
  loadError.value = '';
  try {
    isLoading.value = true;

    const [logsRes, usersRes] = await Promise.all([
      api.get('/audit-logs'),
      api.get('/users').catch(() => ({ data: [] }))
    ]);

    const rows = logsRes.data;
    auditLogs.value = Array.isArray(rows) ? rows : [];
    if (!Array.isArray(rows)) {
      loadError.value = 'Réponse API inattendue pour /audit-logs (tableau attendu).';
    }

    const users = Array.isArray(usersRes?.data) ? usersRes.data : [];
    const uDict = {};
    users.forEach((u) => {
      if (u && u.id != null) uDict[u.id] = u;
    });
    usersDict.value = uDict;
  } catch (error) {
    console.error('Erreur récupération journal de traçabilité:', error);
    auditLogs.value = [];
    usersDict.value = {};
    const msg = error.response?.data;
    loadError.value =
        typeof msg === 'string' ? msg
        : msg?.message || error.message || 'Impossible de charger le journal de traçabilité.';
  } finally {
    isLoading.value = false;
  }
};

onMounted(fetchAuditData);

// Compute distinct entity types from loaded data
const entityTypes = computed(() => {
  const types = new Set();
  auditLogs.value.forEach((log) => {
    if (log.entityType) types.add(log.entityType);
  });
  return Array.from(types).sort();
});

// Retour à la première page quand un filtre change
watch([searchQuery, filterAction, filterEntityType, startDate, endDate], () => {
  currentPage.value = 1;
});

// Check if any filter is active
const hasActiveFilters = computed(() => {
  return searchQuery.value !== '' || filterAction.value !== '' ||
      filterEntityType.value !== '' || startDate.value !== '' || endDate.value !== '';
});

const resetFilters = () => {
  searchQuery.value = '';
  filterAction.value = '';
  filterEntityType.value = '';
  startDate.value = '';
  endDate.value = '';
};

const filteredLogs = computed(() => {
  const filtered = auditLogs.value.filter((log) => {
    const q = searchQuery.value.toLowerCase().trim();

    // Build searchable strings including user name and action
    const logIdStr = log.id?.toString() || '';
    const userIdStr = log.userId?.toString() || '';
    const entityTypeStr = log.entityType?.toLowerCase() || '';
    const detailsStr = log.details?.toLowerCase() || '';
    const ipStr = log.ipAddress?.toLowerCase() || '';
    const entityIdStr = log.entityId?.toString() || '';
    const actionStr = log.action?.toLowerCase() || '';

    // Resolve user name for search
    const user = log.userId ? usersDict.value[log.userId] : null;
    const userNameStr = user
        ? `${user.lastName || ''} ${user.firstName || ''} ${user.username || ''}`.toLowerCase()
        : '';

    const matchesSearch = q === '' ||
        logIdStr.includes(q) ||
        userIdStr.includes(q) ||
        userNameStr.includes(q) ||
        entityTypeStr.includes(q) ||
        detailsStr.includes(q) ||
        ipStr.includes(q) ||
        entityIdStr.includes(q) ||
        actionStr.includes(q);

    const actionMatch = filterAction.value === '' || (log.action || '').toUpperCase() === filterAction.value;
    const entityTypeMatch = filterEntityType.value === '' || log.entityType === filterEntityType.value;

    const logDate = log.createdAt ? new Date(log.createdAt).setHours(0, 0, 0, 0) : null;
    const start = startDate.value ? new Date(startDate.value).setHours(0, 0, 0, 0) : null;
    const end = endDate.value ? new Date(endDate.value).setHours(0, 0, 0, 0) : null;
    let matchesDate = true;
    if (start && logDate && logDate < start) matchesDate = false;
    if (end && logDate && logDate > end) matchesDate = false;

    return matchesSearch && actionMatch && entityTypeMatch && matchesDate;
  });

  filtered.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  return filtered;
});

const totalPages = computed(() => Math.ceil(filteredLogs.value.length / itemsPerPage));

const paginatedLogs = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredLogs.value.slice(start, start + itemsPerPage);
});

// Visible page numbers for pagination
const visiblePages = computed(() => {
  const total = totalPages.value;
  const current = currentPage.value;
  const pages = [];
  if (total <= 7) {
    for (let i = 1; i <= total; i++) pages.push(i);
  } else {
    pages.push(1);
    if (current > 3) pages.push('...');
    const rangeStart = Math.max(2, current - 1);
    const rangeEnd = Math.min(total - 1, current + 1);
    for (let i = rangeStart; i <= rangeEnd; i++) pages.push(i);
    if (current < total - 2) pages.push('...');
    pages.push(total);
  }
  return pages;
});

const goToPage = (page) => {
  if (typeof page === 'number' && page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
  }
};

// --- HELPERS ---
const getUserName = (id) => {
  if (!id || !usersDict.value[id]) return "Système";
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
  const content = typeof jsonStr === 'string' ? jsonStr : JSON.stringify(jsonStr);
  if (content === '{}') return '{}';
  if (content.length > 55) return content.substring(0, 55) + '...';
  return content;
};

const getActionClass = (type) => {
  if (type === 'CREATE') return 'badge-green';
  if (type === 'UPDATE') return 'badge-blue';
  if (type === 'DELETE') return 'badge-red';
  return 'badge-gray';
};

const getOldJsonClass = (action, jsonStr) => {
  if (action === 'CREATE') return 'is-null';
  if (!jsonStr || jsonStr === 'null' || jsonStr === '{}') return 'is-null';
  return '';
};

const getNewJsonClass = (action, jsonStr) => {
  if (action === 'DELETE') return 'is-null-red';
  if (!jsonStr || jsonStr === 'null' || jsonStr === '{}') return 'is-null';
  if (action === 'CREATE' || action === 'UPDATE') return 'is-new-green';
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

.api-error-banner {
  background: #fef2f2;
  border: 1px solid #fecaca;
  color: #991b1b;
  padding: 12px 16px;
  border-radius: 8px;
  margin-bottom: 16px;
  font-size: 14px;
  font-weight: 600;
}

.period-row {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  align-items: center;
}

.filter-date {
  flex: 1;
  min-width: 120px;
  padding: 10px 12px;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  background: #f8fafc;
  font-size: 13px;
  color: #334155;
  font-family: inherit;
}

.filter-date:focus {
  outline: none;
  border-color: #0f172a;
  background: #fff;
}

.text-center { text-align: center; }
.empty-row { padding: 24px; color: #64748b; font-style: italic; }

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

.system-status { display: flex; align-items: center; gap: 8px; font-size: 10px; font-weight: 800; color: #063B16; letter-spacing: 0.5px;}
.pulse-dot { width: 8px; height: 8px; background: #0B5D1E; border-radius: 50%; }

.data-table { width: 100%; border-collapse: collapse; }
.data-table th { text-align: left; padding: 15px 25px; font-size: 10px; font-weight: 800; color: #64748b; text-transform: uppercase; border-bottom: 1px solid #f1f5f9; letter-spacing: 0.5px;}
.data-table td { padding: 20px 25px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }

.log-id { font-weight: 800; color: #0f172a; font-size: 13px; }

.user-info, .action-info, .date-info { display: flex; flex-direction: column; gap: 4px; }
.u-name { font-weight: 800; color: #0f172a; font-size: 14px; }
.u-id { font-size: 11px; color: #64748b; font-weight: 600;}

.entity-name { font-weight: 700; color: #334155; font-size: 13px; margin-top: 4px;}
.badge-action { padding: 4px 8px; border-radius: 4px; font-size: 10px; font-weight: 900; letter-spacing: 0.5px; display: inline-block; width: max-content;}
.badge-green { background: #dcfce3; color: #063B16; }
.badge-blue { background: #dbeafe; color: #1e40af; }
.badge-red { background: #fee2e2; color: #991b1b; }
.badge-gray { background: #f1f5f9; color: #475569; }

.date { font-weight: 600; color: #334155; font-size: 13px; }
.time { font-size: 12px; color: #64748b; }

.json-cell { width: 25%; }
.json-block { background: #f8fafc; border: 1px solid #f1f5f9; padding: 10px 12px; border-radius: 6px; font-family: 'JetBrains Mono', 'Courier New', monospace; font-size: 11px; color: #64748b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 250px;}
.is-null { color: #cbd5e1; }
.is-new-green { background: #f0fdf4; border-color: #dcfce3; color: #063B16; }
.is-null-red { background: #fef2f2; border-color: #fee2e2; color: #dc2626; }

/* FOOTER & PAGINATION */
.table-footer { padding: 20px 25px; display: flex; justify-content: space-between; align-items: center; background: white;}
.showing-text { font-size: 12px; color: #64748b; font-weight: 500; }
.pagination { display: flex; gap: 5px; }
.pagination button { width: 32px; height: 32px; border: 1px solid #e2e8f0; background: white; border-radius: 6px; cursor: pointer; color: #475569; display: flex; align-items: center; justify-content: center; transition: 0.2s; font-size: 12px;}
.pagination button:hover:not(:disabled) { border-color: #cbd5e1; background: #f8fafc;}
.pagination button:disabled { opacity: 0.5; cursor: not-allowed; }
.pagination button.active { background: #0f172a; color: white; border-color: #0f172a; font-weight: 700;}

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

/* JSON Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(15,23,42,0.7); display: flex; align-items: center; justify-content: center; z-index: 9999; backdrop-filter: blur(4px); }
.json-modal-content { background: #1e293b; border-radius: 12px; width: 90%; max-width: 750px; max-height: 80vh; display: flex; flex-direction: column; overflow: hidden; box-shadow: 0 25px 60px rgba(0,0,0,0.5); }
.json-modal-header { display: flex; justify-content: space-between; align-items: center; padding: 16px 24px; border-bottom: 1px solid #334155; }
.json-modal-header h2 { margin: 0; font-size: 15px; font-weight: 700; color: #e2e8f0; display: flex; align-items: center; gap: 10px; }
.json-modal-header h2 i { color: #38bdf8; }
.btn-close-json { background: none; border: none; color: #64748b; font-size: 18px; cursor: pointer; transition: color 0.2s; }
.btn-close-json:hover { color: #f87171; }
.json-modal-body { flex: 1; overflow-y: auto; padding: 24px; margin: 0; font-family: 'JetBrains Mono', 'Courier New', monospace; font-size: 13px; line-height: 1.7; color: #86efac; white-space: pre-wrap; word-break: break-all; }

/* Filters actions row — flex-wrap so entity type + reset button wrap cleanly */
.filters-actions {
  display: flex;
  align-items: flex-end;
  gap: 20px;
  flex-wrap: wrap;
}

/* Reset button */
.btn-reset {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 9px 16px;
  background: #fff;
  border: 1px solid #fca5a5;
  color: #dc2626;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.2s, border-color 0.2s;
  margin-left: auto;
}
.btn-reset:hover { background: #fef2f2; border-color: #ef4444; }

/* Pagination ellipsis */
.page-ellipsis {
  width: 32px;
  height: 32px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  color: #94a3b8;
  user-select: none;
}
</style>