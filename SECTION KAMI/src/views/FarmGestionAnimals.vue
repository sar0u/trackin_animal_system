<template>

      <main class="page-content">
        <header class="content-header">
          <h1>Gestion des Animaux</h1>
          <p class="subtitle">
            <i class="fas fa-map-marker-alt"></i> Ferme El-Amel - Inventaire et Santé du Cheptel
          </p>
        </header>

        <section class="kpi-grid">
          <div class="kpi-card">
            <div class="kpi-header">
              <div class="kpi-icon icon-blue"><i class="fas fa-paw"></i></div>
              <span class="trend-up">+2.4%</span>
            </div>
            <span class="kpi-label">Cheptel Total</span>
            <span class="kpi-value">1,240</span>
          </div>

          <div class="kpi-card">
            <div class="kpi-header">
              <div class="kpi-icon icon-orange"><i class="fas fa-cow"></i></div>
            </div>
            <span class="kpi-label">Mix Espèces</span>
            <span class="kpi-value">60% Bovins</span>
            <div class="progress-container">
              <div class="progress-bar" style="width: 60%"></div>
            </div>
          </div>

          <div class="kpi-card">
            <div class="kpi-header">
              <div class="kpi-icon icon-purple"><i class="fas fa-vial"></i></div>
            </div>
            <span class="kpi-label">Vaccinations Dues</span>
            <span class="kpi-value">42</span>
          </div>

          <div class="kpi-card">
            <div class="kpi-header">
              <div class="kpi-icon icon-red"><i class="fas fa-exclamation-triangle"></i></div>
              <span class="trend-down">-5%</span>
            </div>
            <span class="kpi-label">Alertes Sanitaires</span>
            <span class="kpi-value">3</span>
          </div>
        </section>

        <section class="charts-grid">
          <div class="chart-container main-chart">
            <div class="chart-header">
              <h3>Évolution de la Croissance & Santé</h3>
              <span class="period-tag">Derniers 6 mois</span>
            </div>
            <div class="bar-chart">
              <div class="bar-group"><div class="bar" style="height: 40%"></div><span>JAN</span></div>
              <div class="bar-group"><div class="bar" style="height: 55%"></div><span>FEV</span></div>
              <div class="bar-group"><div class="bar" style="height: 70%"></div><span>MAR</span></div>
              <div class="bar-group"><div class="bar" style="height: 85%"></div><span>AVR</span></div>
              <div class="bar-group"><div class="bar" style="height: 90%"></div><span>MAI</span></div>
              <div class="bar-group"><div class="bar active" style="height: 100%"></div><span>JUIN</span></div>
            </div>
          </div>

          <div class="chart-container donut-chart">
            <h3>Répartition Santé</h3>
            <div class="donut-stats">
              <div class="legend">
                <div class="leg-item"><span class="dot green"></span> Excellent <strong>82%</strong></div>
                <div class="leg-item"><span class="dot orange"></span> Stable <strong>15%</strong></div>
                <div class="leg-item"><span class="dot red"></span> En alerte <strong>3%</strong></div>
              </div>
              <div class="donut-visual">
                <div class="donut-ring">
                  <div class="donut-center">
                    <span class="big-percent">82%</span>
                    <span class="sub-text">SAINS</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section class="table-section">
          <div class="table-header">
            <h3>Inventaire détaillé</h3>
            <div class="table-actions">
              <button class="btn-add"><i class="fas fa-plus"></i> Ajouter un animal</button>
              <div class="tools">
                <i class="fas fa-filter"></i>
                <i class="fas fa-download"></i>
              </div>
            </div>
          </div>

          <table class="animal-table">
            <thead>
              <tr>
                <th>TAG NUMBER</th>
                <th>ID / FERME</th>
                <th>ESPÈCE</th>
                <th>SEXE</th>
                <th>POIDS</th>
                <th>NAISSANCE</th>
                <th>SANTÉ</th>
                <th>REPRODUCTION</th>
                <th>VACCIN</th>
                <th>ACTIONS</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td class="tag-num">#DZ-8842</td>
                <td>Ferme El-Amel</td>
                <td class="bold">Bovin (Holstein)</td>
                <td>Femelle</td>
                <td class="bold">540 kg</td>
                <td>12/04/2021 <br><small>Batna, Algérie</small></td>
                <td><span class="badge b-green">Sain</span></td>
                <td>Gestation</td>
                <td><span class="badge b-blue">À jour</span></td>
                <td><i class="fas fa-edit edit-icon"></i></td>
              </tr>
              <tr>
                <td class="tag-num">#DZ-8901</td>
                <td>Ferme El-Amel</td>
                <td class="bold">Ovin (Ouled Djellal)</td>
                <td>Mâle</td>
                <td class="bold">65 kg</td>
                <td>28/05/2022 <br><small>Sétif, Algérie</small></td>
                <td><span class="badge b-orange">Observé</span></td>
                <td>-</td>
                <td><span class="badge b-red">Urgent</span></td>
                <td><i class="fas fa-edit edit-icon"></i></td>
              </tr>
              <tr>
                <td class="tag-num">#DZ-9012</td>
                <td>Ferme El-Amel</td>
                <td class="bold">Bovin (Holstein)</td>
                <td>Femelle</td>
                <td class="bold">490 kg</td>
                <td>10/01/2022 <br><small>Local</small></td>
                <td><span class="badge b-green">Sain</span></td>
                <td>Prêt</td>
                <td><span class="badge b-blue">À jour</span></td>
                <td><i class="fas fa-edit edit-icon"></i></td>
              </tr>
            </tbody>
          </table>

          <div class="table-footer">
            <span>Affichage de 1 à 10 sur 1,240 animaux</span>
            <div class="pagination">
              <button class="btn-pg">Précédent</button>
              <button class="btn-pg active">Suivant</button>
            </div>
          </div>
        </section>
      </main>

</template>

<style scoped>
.farm-layout { display: flex; background: #f8fafc; min-height: 100vh; }
.main-wrapper { flex: 1; margin-left: 260px; }
.page-content { padding: 30px; }

/* Header */
.content-header h1 { font-size: 24px; color: #1a202c; font-weight: 800; margin-bottom: 5px; }
.subtitle { color: #718096; font-size: 13px; margin-bottom: 25px; }
.subtitle i { color: #a0aec0; margin-right: 5px; }

/* KPI Grid */
.kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
.kpi-card { background: white; padding: 20px; border-radius: 12px; border: 1px solid #edf2f7; }
.kpi-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
.kpi-icon { width: 40px; height: 40px; border-radius: 8px; display: flex; align-items: center; justify-content: center; }
.icon-blue { background: #eff6ff; color: #3b82f6; }
.icon-orange { background: #fff7ed; color: #f97316; }
.icon-purple { background: #f5f3ff; color: #8b5cf6; }
.icon-red { background: #fef2f2; color: #ef4444; }
.trend-up { color: #11D432; font-size: 11px; font-weight: 700; }
.trend-down { color: #ef4444; font-size: 11px; font-weight: 700; }
.kpi-label { color: #718096; font-size: 12px; display: block; margin-bottom: 4px; }
.kpi-value { font-size: 22px; font-weight: 800; color: #1a202c; }
.progress-container { height: 6px; background: #edf2f7; border-radius: 10px; margin-top: 10px; overflow: hidden; }
.progress-bar { height: 100%; background: #11D432; border-radius: 10px; }

/* Charts */
.charts-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; margin-bottom: 30px; }
.chart-container { background: white; padding: 25px; border-radius: 12px; border: 1px solid #edf2f7; }
.chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
.period-tag { font-size: 11px; background: #f7fafc; padding: 4px 10px; border-radius: 6px; color: #4a5568; font-weight: 600; }
.bar-chart { display: flex; justify-content: space-between; align-items: flex-end; height: 200px; padding-bottom: 20px; }
.bar-group { display: flex; flex-direction: column; align-items: center; gap: 10px; width: 40px; }
.bar { width: 100%; background: #c6f6d5; border-radius: 4px; transition: 0.3s; }
.bar.active { background: #11D432; }
.bar-group span { font-size: 10px; color: #a0aec0; font-weight: 700; }

.donut-stats { display: flex; flex-direction: column; gap: 20px; }
.legend { display: flex; flex-direction: column; gap: 8px; }
.leg-item { font-size: 12px; color: #4a5568; display: flex; align-items: center; gap: 8px; }
.dot { width: 8px; height: 8px; border-radius: 50%; }
.green { background: #11D432; }
.orange { background: #f97316; }
.red { background: #ef4444; }
.donut-visual { display: flex; justify-content: center; padding: 10px; }
.donut-ring { width: 120px; height: 120px; border-radius: 50%; border: 12px solid #11D432; border-top-color: #ef4444; border-right-color: #f97316; display: flex; align-items: center; justify-content: center; }
.donut-center { text-align: center; }
.big-percent { display: block; font-size: 20px; font-weight: 800; color: #1a202c; }
.sub-text { font-size: 9px; color: #a0aec0; font-weight: 700; }

/* Table */
.table-section { background: white; padding: 25px; border-radius: 12px; border: 1px solid #edf2f7; }
.table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
.table-actions {
  display: flex;
  align-items: center; /* Aligne verticalement le bouton et les icônes */
  gap: 20px;           /* Espace entre le bouton vert et les outils */
}
.btn-add { background: #11D432; color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 700; cursor: pointer; }
.tools { display: flex; gap: 15px; color: #a0aec0; }
.animal-table { width: 100%; border-collapse: collapse; }
.animal-table th { text-align: left; padding: 12px; font-size: 10px; color: #a0aec0; text-transform: uppercase; border-bottom: 1px solid #edf2f7; }
.animal-table td { padding: 15px 12px; font-size: 13px; border-bottom: 1px solid #f7fafc; color: #4a5568; }
.tag-num { font-weight: 700; color: #2d3748; }
.bold { font-weight: 700; color: #1a202c; }
.badge { padding: 4px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; }
.b-green { background: #f0fff4; color: #11D432; }
.b-orange { background: #fff7ed; color: #f97316; }
.b-red { background: #fef2f2; color: #ef4444; }
.b-blue { background: #eff6ff; color: #3b82f6; }
.edit-icon { color: #cbd5e0; cursor: pointer; }

.table-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; color: #a0aec0; font-size: 12px; }
.btn-pg { padding: 8px 15px; border: 1px solid #edf2f7; background: white; border-radius: 6px; cursor: pointer; margin-left: 5px; }
.btn-pg.active { background: #1a202c; color: white; border-color: #1a202c; }
</style>

<script setup>
import FarmSidebar from '@/components/FarmSidebar.vue'
import FarmTopbar from '@/components/FarmTopbar.vue'
</script>

