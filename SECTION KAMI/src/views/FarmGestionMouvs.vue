<template>

      <main class="page-content">
        <header class="content-header">
          <div class="header-left">
            <h1>Gestion Mouvements</h1>
            <p class="subtitle">Suivi en temps réel et historique des transferts d'animaux.</p>
          </div>
          <div class="header-actions">
            <button class="btn-filter"><i class="fas fa-filter"></i> Filtrer</button>
            <button class="btn-new-transfer"><i class="fas fa-plus"></i> Nouveau Transfert</button>
          </div>
        </header>

        <section class="kpi-row">
          <div class="kpi-card">
            <div class="kpi-icon-wrap bg-light-green">
              <i class="fas fa-exchange-alt"></i>
              <span class="kpi-trend">+12.5%</span>
            </div>
            <div class="kpi-info">
              <span class="kpi-label">Mouvements ce mois</span>
              <span class="kpi-value">124</span>
            </div>
          </div>

          <div class="kpi-card">
            <div class="kpi-icon-wrap bg-light-orange">
              <i class="fas fa-clipboard-list"></i>
              <span class="kpi-status-tag orange">Actif</span>
            </div>
            <div class="kpi-info">
              <span class="kpi-label">Transits en cours</span>
              <span class="kpi-value">12</span>
            </div>
          </div>

          <div class="kpi-card">
            <div class="kpi-icon-wrap bg-light-blue">
              <i class="far fa-check-circle"></i>
              <span class="kpi-status-tag blue">Optimal</span>
            </div>
            <div class="kpi-info">
              <span class="kpi-label">Taux de complétion</span>
              <span class="kpi-value">98%</span>
            </div>
          </div>
        </section>

        <section class="chart-container">
          <div class="chart-header">
            <div class="chart-title">
              <h3>Tendances de Transit Annuel</h3>
              <p>Volume mensuel des entrées et sorties (2023)</p>
            </div>
            <select class="year-select">
              <option>Année 2023</option>
            </select>
          </div>
          <div class="line-chart-area">
            <svg viewBox="0 0 1000 200" class="main-line-chart">
              <path d="M0,150 L100,120 L200,140 L300,90 L400,110 L500,50 L600,70 L700,40 L800,90 L900,60 L1000,80"
                    fill="none" stroke="#11D432" stroke-width="3" />
              <circle cx="100" cy="120" r="4" fill="#11D432" />
              <circle cx="300" cy="90" r="4" fill="#11D432" />
              <circle cx="500" cy="50" r="4" fill="#11D432" />
              <circle cx="700" cy="40" r="4" fill="#11D432" />
            </svg>
            <div class="chart-labels">
              <span>JAN</span><span>FEB</span><span>MAR</span><span>APR</span><span>MAY</span><span>JUN</span>
              <span>JUL</span><span>AUG</span><span>SEP</span><span>OCT</span><span>NOV</span><span>DEC</span>
            </div>
          </div>
        </section>

        <section class="table-card">
          <div class="table-header">
            <h3>Mouvements Récents</h3>
            <div class="table-tools">
              <i class="fas fa-download"></i>
              <i class="fas fa-print"></i>
            </div>
          </div>
          <table class="mouves-table">
            <thead>
              <tr>
                <th>ID ANIMAL</th>
                <th>DE (ORIGINE)</th>
                <th>À (DESTINATION)</th>
                <th>DATE</th>
                <th>MOTIF</th>
                <th>STATUT</th>
                <th>ACTIONS</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td class="id-bold"><span class="dot green"></span> #DZ-2045-88</td>
                <td><i class="fas fa-home"></i> Ma Ferme (Nord)</td>
                <td><i class="fas fa-sign-out-alt"></i> Abattoir Central</td>
                <td>24 Oct 2023</td>
                <td><span class="motif-tag">Vente</span></td>
                <td><span class="status-pill green">● Terminé</span></td>
                <td><i class="far fa-eye"></i></td>
              </tr>
              <tr>
                <td class="id-bold"><span class="dot orange"></span> #DZ-1102-14</td>
                <td>Pâturage Est</td>
                <td><i class="fas fa-home"></i> Ma Ferme (Nord)</td>
                <td>25 Oct 2023</td>
                <td><span class="motif-tag">Rotation</span></td>
                <td><span class="status-pill orange">● En Transit</span></td>
                <td><i class="far fa-eye"></i></td>
              </tr>
              <tr>
                <td class="id-bold"><span class="dot green"></span> #DZ-9923-42</td>
                <td><i class="fas fa-hospital"></i> Clinique Vétérinaire</td>
                <td><i class="fas fa-home"></i> Ma Ferme (Nord)</td>
                <td>23 Oct 2023</td>
                <td><span class="motif-tag">Soins</span></td>
                <td><span class="status-pill green">● Terminé</span></td>
                <td><i class="far fa-eye"></i></td>
              </tr>
              <tr>
                <td class="id-bold"><span class="dot gray"></span> #DZ-5501-09</td>
                <td>Ma Ferme (Nord)</td>
                <td>Marché Local</td>
                <td>21 Oct 2023</td>
                <td><span class="motif-tag">Vente</span></td>
                <td><span class="status-pill gray">● Annulé</span></td>
                <td><i class="far fa-eye"></i></td>
              </tr>
            </tbody>
          </table>
          <div class="table-footer">
            <span class="count">Affichage de 1-4 sur 124 mouvements</span>
            <div class="pagination">
              <button class="pg-btn">Précédent</button>
              <button class="pg-btn active">Suivant</button>
            </div>
          </div>
        </section>
      </main>

</template>

<script setup>
import FarmSidebar from '@/components/FarmSidebar.vue'
import FarmTopbar from '@/components/FarmTopbar.vue'
</script>

<style scoped>
.farm-layout { display: flex; background: #f8fafc; min-height: 100vh; }
.main-wrapper { flex: 1; margin-left: 260px; }
.page-content { padding: 30px 40px; }

/* Header */
.content-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 30px; }
.content-header h1 { font-size: 26px; font-weight: 800; color: #1a202c; margin-bottom: 4px; }
.subtitle { color: #718096; font-size: 14px; }
.header-actions { display: flex; gap: 12px; }
.btn-filter { background: white; border: 1px solid #edf2f7; padding: 10px 18px; border-radius: 8px; font-weight: 600; color: #4a5568; cursor: pointer; }
.btn-new-transfer { background: #11D432; color: white; border: none; padding: 10px 18px; border-radius: 8px; font-weight: 700; cursor: pointer; }

/* KPI Cards */
.kpi-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 30px; }
.kpi-card { background: white; padding: 24px; border-radius: 12px; border: 1px solid #edf2f7; }
.kpi-icon-wrap { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
.kpi-icon-wrap i { font-size: 20px; }
.bg-light-green i { color: #11D432; }
.bg-light-orange i { color: #ed8936; }
.bg-light-blue i { color: #3182ce; }
.kpi-trend { color: #11D432; background: #f0fff4; font-size: 11px; font-weight: 700; padding: 2px 8px; border-radius: 20px; }
.kpi-status-tag { font-size: 10px; font-weight: 700; padding: 2px 10px; border-radius: 20px; }
.kpi-status-tag.orange { background: #fffaf0; color: #ed8936; }
.kpi-status-tag.blue { background: #ebf8ff; color: #3182ce; }
.kpi-label { font-size: 13px; color: #718096; display: block; margin-bottom: 4px; }
.kpi-value { font-size: 28px; font-weight: 800; color: #1a202c; }

/* Chart Section */
.chart-container { background: white; padding: 25px; border-radius: 15px; border: 1px solid #edf2f7; margin-bottom: 30px; }
.chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
.chart-title h3 { font-size: 18px; font-weight: 700; }
.chart-title p { color: #a0aec0; font-size: 12px; }
.year-select { background: #f7fafc; border: 1px solid #edf2f7; padding: 6px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; }
.line-chart-area { padding-top: 10px; }
.chart-labels { display: flex; justify-content: space-between; margin-top: 15px; color: #cbd5e1; font-size: 10px; font-weight: 700; }

/* Table */
.table-card { background: white; border-radius: 15px; border: 1px solid #edf2f7; padding: 25px; }
.table-header { display: flex; justify-content: space-between; margin-bottom: 20px; }
.table-tools i { color: #a0aec0; margin-left: 15px; cursor: pointer; }
.mouves-table { width: 100%; border-collapse: collapse; }
.mouves-table th { text-align: left; padding: 15px; font-size: 11px; color: #a0aec0; text-transform: uppercase; border-bottom: 1px solid #edf2f7; }
.mouves-table td { padding: 18px 15px; font-size: 13px; border-bottom: 1px solid #f7fafc; }
.id-bold { font-weight: 800; color: #2d3748; }
.dot { height: 6px; width: 6px; border-radius: 50%; display: inline-block; margin-right: 8px; vertical-align: middle; }
.dot.green { background: #11D432; }
.dot.orange { background: #ed8936; }
.dot.gray { background: #a0aec0; }
.motif-tag { background: #f1f5f9; color: #475569; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; }
.status-pill { font-size: 11px; font-weight: 700; padding: 4px 12px; border-radius: 20px; }
.status-pill.green { background: #f0fff4; color: #11D432; }
.status-pill.orange { background: #fffaf0; color: #ed8936; }
.status-pill.gray { background: #f8fafc; color: #a0aec0; }

.table-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 25px; }
.count { font-size: 12px; color: #a0aec0; }
.pg-btn { border: 1px solid #edf2f7; background: white; padding: 8px 16px; border-radius: 8px; font-size: 12px; font-weight: 600; cursor: pointer; margin-left: 8px; }
.pg-btn.active { background: #1a202c; color: white; border-color: #1a202c; }
</style>