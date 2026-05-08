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
/* ==========================================================================
   1. BASE
   ========================================================================== */
.audit-container {
  font-family: 'Inter', sans-serif;
  background-color: #f4f7f6;
  min-height: 100vh;
  padding: 30px;
  color: #1e293b;
  position: relative;
}

/* ==========================================================================
   2. HEADER
   ========================================================================== */
.header-section {
  margin-bottom: 25px;
}

.breadcrumb {
  font-size: 12px;
  color: #64748b;
  font-weight: 600;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.header-section h1 {
  font-size: 26px;
  font-weight: 900;
  margin: 0;
  color: #0f172a;
  letter-spacing: -0.5px;
}

.subtitle {
  color: #64748b;
  font-size: 14px;
  margin-top: 5px;
}

.api-error-banner {
  background: rgba(244, 67, 54, 0.08);
  border: 1px solid rgba(244, 67, 54, 0.2);
  color: #F44336;
  padding: 12px 16px;
  border-radius: 8px;
  margin-bottom: 16px;
  font-size: 14px;
  font-weight: 600;
}

/* ==========================================================================
   3. FILTRES
   ========================================================================== */
.filters-card {
  background: white;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  margin-bottom: 25px;
  border: 1px solid rgba(11, 93, 30, 0.08);
}

.filters-grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 25px;
  margin-bottom: 25px;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-group label {
  font-size: 10px;
  font-weight: 800;
  color: #0B5D1E;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.input-with-icon {
  position: relative;
}

.input-with-icon i {
  position: absolute;
  left: 14px;
  top: 50%;
  transform: translateY(-50%);
  color: #0B5D1E;
  opacity: 0.6;
  font-size: 14px;
}

.input-with-icon input {
  width: 100%;
  padding: 10px 14px 10px 42px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  background: rgba(11, 93, 30, 0.03);
  outline: none;
  font-size: 14px;
  font-family: inherit;
  color: #063B16;
  height: 44px;
  box-sizing: border-box;
}

.input-with-icon input::placeholder {
  color: #0B5D1E;
  opacity: 0.5;
}

.input-with-icon input:focus {
  border-color: #0B5D1E;
  background: white;
  box-shadow: 0 0 0 3px rgba(11, 93, 30, 0.1);
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
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  background: white;
  font-size: 13px;
  color: #063B16;
  font-family: inherit;
  height: 44px;
  box-sizing: border-box;
}

.filter-date:focus {
  outline: none;
  border-color: #0B5D1E;
  background: #fff;
}

.filter-group select {
  padding: 10px 14px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  background: white;
  outline: none;
  font-size: 13px;
  color: #063B16;
  font-weight: 500;
  height: 44px;
  box-sizing: border-box;
}

.filter-group select:focus {
  border-color: #0B5D1E;
}

/* ==========================================================================
   4. ONGLETS
   ========================================================================== */
.filters-actions {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  flex-wrap: wrap;
  gap: 20px;
}

.tabs {
  display: flex;
  background: white;
  border: 1px solid rgba(11, 93, 30, 0.2);
  border-radius: 8px;
  overflow: hidden;
}

.tabs button {
  padding: 10px 20px;
  border: none;
  background: transparent;
  font-size: 12px;
  font-weight: 700;
  color: #64748b;
  cursor: pointer;
  transition: 0.2s;
  border-right: 1px solid rgba(11, 93, 30, 0.1);
}

.tabs button:last-child {
  border-right: none;
}

.tabs button:hover {
  background: rgba(11, 93, 30, 0.05);
  color: #0B5D1E;
}

.tabs button.active {
  background: #0B5D1E;
  color: white;
}

/* ==========================================================================
   5. BOUTON RÉINITIALISER
   ========================================================================== */
.btn-reset {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 9px 16px;
  background: #fff;
  border: 1px solid rgba(244, 67, 54, 0.3);
  color: #F44336;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  margin-left: auto;
}

.btn-reset:hover {
  background: rgba(244, 67, 54, 0.05);
  border-color: #F44336;
}

/* ==========================================================================
   6. TABLEAU
   ========================================================================== */
.audit-table-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.02);
  overflow: hidden;
  border: 1px solid rgba(11, 93, 30, 0.08);
  overflow-x: auto;
}

.card-header {
  padding: 20px 25px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-left i {
  font-size: 18px;
  color: #0B5D1E;
  opacity: 0.6;
}

.header-left h2 {
  margin: 0;
  font-size: 16px;
  font-weight: 800;
  color: #0f172a;
}

.system-status {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 10px;
  font-weight: 800;
  color: #4CAF50;
  letter-spacing: 0.5px;
  background: rgba(76, 175, 80, 0.1);
  padding: 6px 12px;
  border-radius: 20px;
}

.pulse-dot {
  width: 8px;
  height: 8px;
  background: #4CAF50;
  border-radius: 50%;
  animation: blink 1.5s infinite;
}

@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 1100px;
}

.data-table th {
  text-align: left;
  padding: 14px 20px;
  font-size: 11px;
  font-weight: 800;
  color: #0B5D1E;
  text-transform: uppercase;
  border-bottom: 1px solid rgba(11, 93, 30, 0.08);
  letter-spacing: 0.5px;
  background: rgba(11, 93, 30, 0.03);
}

.data-table td {
  padding: 16px 20px;
  border-bottom: 1px solid rgba(11, 93, 30, 0.05);
  vertical-align: middle;
}

.data-table tr:hover {
  background-color: rgba(11, 93, 30, 0.02);
}

.text-center { text-align: center; }
.empty-row { padding: 24px; color: #64748b; font-style: italic; }

.log-id {
  font-weight: 800;
  color: #063B16;
  font-size: 13px;
  font-family: 'JetBrains Mono', monospace;
}

.user-info, .action-info, .date-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.u-name {
  font-weight: 800;
  color: #0f172a;
  font-size: 14px;
}

.u-id {
  font-size: 11px;
  color: #64748b;
  font-weight: 600;
}

.entity-name {
  font-weight: 700;
  color: #063B16;
  font-size: 13px;
  margin-top: 4px;
}

/* ==========================================================================
   7. BADGES D'ACTION
   ========================================================================== */
.badge-action {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 10px;
  font-weight: 900;
  letter-spacing: 0.5px;
  display: inline-block;
  width: max-content;
  text-transform: uppercase;
}

.badge-green {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

.badge-blue {
  background: rgba(33, 150, 243, 0.1);
  color: #2196F3;
}

.badge-red {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

.badge-gray {
  background: rgba(11, 93, 30, 0.05);
  color: #64748b;
}

.date {
  font-weight: 600;
  color: #063B16;
  font-size: 13px;
}

.time {
  font-size: 12px;
  color: #64748b;
}

/* ==========================================================================
   8. CELLULES JSON
   ========================================================================== */
.json-cell {
  width: 20%;
}

.json-block {
  background: rgba(11, 93, 30, 0.03);
  border: 1px solid rgba(11, 93, 30, 0.08);
  padding: 10px 12px;
  border-radius: 6px;
  font-family: 'JetBrains Mono', 'Courier New', monospace;
  font-size: 11px;
  color: #64748b;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 250px;
}

.is-null {
  color: #94a3b8;
}

.is-new-green {
  background: rgba(76, 175, 80, 0.05);
  border-color: rgba(76, 175, 80, 0.2);
  color: #4CAF50;
}

.is-null-red {
  background: rgba(244, 67, 54, 0.05);
  border-color: rgba(244, 67, 54, 0.2);
  color: #F44336;
}

/* ==========================================================================
   9. MORE INFO
   ========================================================================== */
.more-info {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.entity-tag {
  font-size: 11px;
  font-weight: 700;
  color: #0B5D1E;
  background: rgba(11, 93, 30, 0.08);
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

/* ==========================================================================
   10. PAGINATION
   ========================================================================== */
.table-footer {
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(11, 93, 30, 0.02);
  border-top: 1px solid rgba(11, 93, 30, 0.08);
}

.showing-text {
  font-size: 13px;
  color: #64748b;
  font-weight: 600;
}

.pagination {
  display: flex;
  gap: 5px;
}

.pagination button, .page-btn {
  width: 35px;
  height: 35px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  background: white;
  border-radius: 8px;
  cursor: pointer;
  color: #063B16;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: 0.2s;
  font-size: 12px;
  font-weight: 700;
}

.pagination button:hover:not(:disabled) {
  background: rgba(11, 93, 30, 0.1);
}

.pagination button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination button.active {
  background: #0B5D1E;
  color: white;
  border-color: #0B5D1E;
}

.page-ellipsis {
  width: 35px;
  height: 35px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  color: #94a3b8;
  user-select: none;
}

/* ==========================================================================
   11. LOADING
   ========================================================================== */
.loading-state {
  text-align: center;
  padding: 50px;
  font-size: 14px;
  color: #64748b;
  font-weight: 600;
}

/* ==========================================================================
   12. MODALE JSON
   ========================================================================== */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(6, 59, 22, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  backdrop-filter: blur(4px);
}

.json-modal-content {
  background: #063B16;
  border-radius: 12px;
  width: 90%;
  max-width: 750px;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 25px 60px rgba(0,0,0,0.5);
}

.json-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  border-bottom: 1px solid rgba(255,255,255,0.1);
}

.json-modal-header h2 {
  margin: 0;
  font-size: 15px;
  font-weight: 700;
  color: #e2e8f0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.json-modal-header h2 i {
  color: #4CAF50;
}

.btn-close-json {
  background: rgba(255,255,255,0.1);
  border: none;
  color: #94a3b8;
  font-size: 18px;
  cursor: pointer;
  width: 35px;
  height: 35px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.btn-close-json:hover {
  background: rgba(244, 67, 54, 0.2);
  color: #F44336;
}

.json-modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
  margin: 0;
  font-family: 'JetBrains Mono', 'Courier New', monospace;
  font-size: 13px;
  line-height: 1.7;
  color: #4CAF50;
  white-space: pre-wrap;
  word-break: break-all;
}

/* ==========================================================================
   13. RESPONSIVE
   ========================================================================== */
@media (max-width: 1024px) {
  .filters-grid {
    grid-template-columns: 1fr;
  }
  .filters-actions {
    flex-direction: column;
    align-items: flex-start;
    gap: 20px;
  }
  .json-block {
    max-width: 150px;
  }
}
</style>