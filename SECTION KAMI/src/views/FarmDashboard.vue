<template>


      <main class="page-content">
        <div class="header-section">
          <p class="breadcrumb">AUJOURD'HUI À FERME DES PLAINES</p>
          <h1 class="welcome-title">Bonjour, Admin_12</h1>
          <p class="subtitle">Voici un résumé de l'activité de votre exploitation pour la journée.</p>
        </div>

        <div class="kpi-grid">
          <div class="kpi-card">
            <div class="kpi-header">
              <div class="icon-circle bg-light-green"><i class="fas fa-users"></i></div>
              <span class="trend positive">+2.4%</span>
            </div>
            <span class="kpi-label">Total Cheptel</span>
            <span class="kpi-value">1,248</span>
          </div>

          <div class="kpi-card">
            <div class="kpi-header">
              <div class="icon-circle bg-light-blue"><i class="far fa-check-circle"></i></div>
              <span class="trend neutral">97%</span>
            </div>
            <span class="kpi-label">Animaux Actifs</span>
            <span class="kpi-value">1,210</span>
          </div>

          <div class="kpi-card">
            <div class="kpi-header">
              <div class="icon-circle bg-light-orange"><i class="fas fa-exchange-alt"></i></div>
              <span class="trend negative">-12%</span>
            </div>
            <span class="kpi-label">Mouvements (30j)</span>
            <span class="kpi-value">42</span>
          </div>

          <div class="kpi-card">
            <div class="kpi-header">
              <div class="icon-circle bg-light-red"><i class="fas fa-exclamation-triangle"></i></div>
              <span class="badge-urgent">Urgent</span>
            </div>
            <span class="kpi-label">Alertes Actives</span>
            <span class="kpi-value">3</span>
          </div>
        </div>

        <div class="middle-grid">
          <div class="chart-card">
            <div class="card-header">
              <div class="title-group">
                <h3>Évolution du Cheptel</h3>
                <span class="small-sub">Nombre d'animaux sur les 6 derniers mois</span>
              </div>
              <div class="toggle-buttons">
                <button class="active">Mensuel</button>
                <button>Annuel</button>
              </div>
            </div>
            <div class="chart-container">
              <svg viewBox="0 0 500 150" class="line-chart">
                <path d="M0,130 C50,120 100,125 150,110 C200,90 250,60 300,90 C350,120 400,80 500,50"
                      fill="none" stroke="#00d432" stroke-width="4" />
              </svg>
              <div class="chart-labels">
                <span>JAN</span><span>FEV</span><span>MAR</span><span>AVR</span><span>MAI</span><span>JUIN</span>
              </div>
            </div>
          </div>

          <div class="activity-card">
            <h3>Mouvements Récents</h3>
            <div class="activity-list">
              <div class="activity-item">
                <div class="act-icon green"><i class="fas fa-arrow-right"></i></div>
                <div class="act-info">
                  <p><strong>Entrée : Vache Bovin</strong></p>
                  <span>ID: DZ-4421-B</span>
                </div>
              </div>
              <div class="activity-item">
                <div class="act-icon red"><i class="fas fa-arrow-left"></i></div>
                <div class="act-info">
                  <p><strong>Sortie : Mouton Ovin</strong></p>
                  <span>Vendu à Marché Sétif</span>
                </div>
              </div>
            </div>
            <button class="btn-all">Voir tout l'historique</button>
          </div>
        </div>

        <div class="table-card">
          <div class="table-header">
            <h3>Liste des Animaux (Derniers ajouts)</h3>
            <span class="filter-link"><i class="fas fa-filter"></i> Filtrer</span>
          </div>
          <table class="data-table">
            <thead>
              <tr>
                <th>ID ANIMAL</th>
                <th>ESPÈCE</th>
                <th>DATE D'ARRIVÉE</th>
                <th>SANTÉ</th>
                <th>STATUT</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td class="id-bold">DZ-5582-B</td>
                <td>Bovin (Vache)</td>
                <td>12 Jan 2024</td>
                <td><span class="dot green"></span> Excellent</td>
                <td><span class="badge-status green">EN FERME</span></td>
                <td><i class="fas fa-ellipsis-v"></i></td>
              </tr>
              <tr>
                <td class="id-bold">DZ-6102-O</td>
                <td>Ovin (Bélier)</td>
                <td>05 Fév 2024</td>
                <td><span class="dot orange"></span> Observation</td>
                <td><span class="badge-status blue">QUARANTAINE</span></td>
                <td><i class="fas fa-ellipsis-v"></i></td>
              </tr>
            </tbody>
          </table>
        </div>

        <footer class="footer">
          <p>© 2026 TRACEDZ PLATFORM - FERME DES PLAINES</p>
          <div class="footer-links"><span>SUPPORT</span><span>CONFIDENTIALITÉ</span></div>
        </footer>
      </main>

</template>

<script setup>
import FarmSidebar from '@/components/FarmSidebar.vue'
import FarmTopbar from '@/components/FarmTopbar.vue'
</script>

<style scoped>
.farm-layout { display: flex; background-color: #f8fafc; min-height: 100vh; }
.main-wrapper { flex: 1; margin-left: 250px; display: flex; flex-direction: column; }
.page-content { padding: 30px 40px; }

/* Typographie & Titres */
.breadcrumb { color: #00d432; font-weight: 800; font-size: 11px; letter-spacing: 0.5px; }
.welcome-title { font-size: 28px; font-weight: 800; color: #1a202c; margin: 5px 0; }
.subtitle { color: #718096; font-size: 14px; margin-bottom: 30px; }

/* Cartes KPI */
.kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
.kpi-card { background: white; padding: 20px; border-radius: 12px; border: 1px solid #edf2f7; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
.kpi-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
.icon-circle { width: 38px; height: 38px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 16px; }
.bg-light-green { background: #f0fff4; color: #00d432; }
.bg-light-blue { background: #ebf8ff; color: #3182ce; }
.bg-light-orange { background: #fffaf0; color: #ed8936; }
.bg-light-red { background: #fff5f5; color: #e53e3e; }
.kpi-label { color: #718096; font-size: 12px; font-weight: 500; }
.kpi-value { display: block; font-size: 24px; font-weight: 800; color: #1a202c; margin-top: 4px; }
.trend { font-size: 11px; font-weight: 700; padding: 2px 6px; border-radius: 4px; }
.positive { color: #00d432; background: #f0fff4; }
.badge-urgent { background: #fff5f5; color: #e53e3e; font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 4px; border: 1px solid #feb2b2; }

/* Graphique & Activités */
.middle-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; margin-bottom: 30px; }
.chart-card, .activity-card, .table-card { background: white; padding: 25px; border-radius: 12px; border: 1px solid #edf2f7; }
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.toggle-buttons { background: #f1f5f9; padding: 4px; border-radius: 8px; }
.toggle-buttons button { border: none; padding: 5px 12px; border-radius: 6px; font-size: 11px; font-weight: 600; cursor: pointer; }
.toggle-buttons button.active { background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
.chart-container { height: 180px; display: flex; flex-direction: column; justify-content: flex-end; }
.chart-labels { display: flex; justify-content: space-between; margin-top: 15px; color: #a0aec0; font-size: 10px; font-weight: 700; }

.activity-item { display: flex; gap: 12px; margin-bottom: 15px; }
.act-icon { width: 30px; height: 30px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; }
.act-icon.green { background: #f0fff4; color: #00d432; }
.act-icon.red { background: #fff5f5; color: #e53e3e; }
.act-info p { font-size: 13px; margin: 0; color: #2d3748; }
.act-info span { font-size: 11px; color: #718096; }
.btn-all { width: 100%; padding: 10px; border: 1px solid #edf2f7; background: white; border-radius: 8px; font-size: 12px; font-weight: 600; color: #718096; cursor: pointer; margin-top: 10px; }

/* Tableau */
.table-header { display: flex; justify-content: space-between; margin-bottom: 20px; }
.filter-link { color: #00d432; font-size: 12px; font-weight: 700; cursor: pointer; }
.data-table { width: 100%; border-collapse: collapse; }
.data-table th { text-align: left; font-size: 11px; color: #a0aec0; padding: 12px; border-bottom: 1px solid #edf2f7; }
.data-table td { padding: 15px 12px; font-size: 13px; border-bottom: 1px solid #f7fafc; }
.id-bold { font-weight: 800; color: #1a202c; }
.dot { height: 8px; width: 8px; border-radius: 50%; display: inline-block; margin-right: 5px; }
.dot.green { background: #00d432; }
.dot.orange { background: #ed8936; }
.badge-status { font-size: 10px; font-weight: 800; padding: 4px 10px; border-radius: 6px; }
.badge-status.green { background: #f0fff4; color: #00d432; }
.badge-status.blue { background: #ebf8ff; color: #3182ce; }

.footer { margin-top: 40px; display: flex; justify-content: space-between; font-size: 10px; color: #a0aec0; font-weight: 700; }
.footer-links { display: flex; gap: 20px; }
</style>