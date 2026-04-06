<template>

      <main class="page-content">
        <header class="content-header">
          <h1>Statistiques de la Ferme</h1>
          <p class="subtitle">Vue d'ensemble des indicateurs de performance clés.</p>
        </header>

        <section class="top-stats-grid">
          <div class="stat-card">
            <div class="stat-info">
              <span class="stat-label">Total Bétail</span>
              <span class="stat-value">1,248</span>
              <span class="stat-trend green">↑ +4.5% <small>v. mois dernier</small></span>
            </div>
            <div class="stat-circle-icon bg-green-light">
              <i class="fas fa-plus"></i>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-info">
              <span class="stat-label">Animaux Actifs</span>
              <span class="stat-value">1,192</span>
              <span class="stat-trend green">95.5% <small>de la capacité</small></span>
            </div>
            <div class="stat-circle-icon bg-blue-light">
              <i class="fas fa-wave-square"></i>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-info">
              <span class="stat-label">Alertes Santé</span>
              <span class="stat-value">12</span>
              <span class="stat-trend orange">3 critiques nécessitent attention</span>
            </div>
            <div class="stat-circle-icon bg-red-light">
              <i class="fas fa-exclamation-triangle"></i>
            </div>
          </div>
        </section>

        <section class="middle-stats-grid">
          <div class="chart-container production-box">
            <div class="chart-header">
              <h3>Évolution de la production</h3>
              <select class="period-select">
                <option>6 derniers mois</option>
              </select>
            </div>
            <div class="line-chart-svg">
              <svg viewBox="0 0 500 150">
                <path d="M0,110 L100,80 L200,100 L300,50 L400,65 L500,30" fill="none" stroke="#11D432" stroke-width="3" />
                <circle cx="100" cy="80" r="4" fill="#11D432" />
                <circle cx="300" cy="50" r="4" fill="#11D432" />
                <circle cx="500" cy="30" r="4" fill="#11D432" />
              </svg>
              <div class="x-axis">
                <span>Jan</span><span>Fév</span><span>Mar</span><span>Avr</span><span>Mai</span><span>Jun</span>
              </div>
            </div>
          </div>

          <div class="chart-container donut-box">
            <h3>Répartition des Espèces</h3>
            <div class="donut-wrap">
              <div class="donut-svg-mock species"></div>
              <div class="donut-legend">
                <span><i class="dot green"></i> Bovins</span>
                <span><i class="dot gray"></i> Ovins</span>
              </div>
            </div>
          </div>
        </section>

        <section class="bottom-stats-grid">
          <div class="chart-container bar-box">
            <h3>Activité Mensuelle</h3>
            <div class="bar-chart-wrap">
              <div class="bar-item"><div class="bar" style="height: 60%"></div><span>Jan</span></div>
              <div class="bar-item"><div class="bar" style="height: 75%"></div><span>Fév</span></div>
              <div class="bar-item"><div class="bar" style="height: 50%"></div><span>Mar</span></div>
              <div class="bar-item"><div class="bar" style="height: 85%"></div><span>Avr</span></div>
              <div class="bar-item"><div class="bar active" style="height: 95%"></div><span>Jun</span></div>
            </div>
          </div>

          <div class="chart-container donut-box">
            <h3>Répartition Santé</h3>
            <div class="donut-wrap">
              <div class="donut-svg-mock health"></div>
              <div class="donut-legend">
                <span><i class="dot green"></i> Excellente</span>
                <span><i class="dot blue"></i> Stable</span>
                <span><i class="dot red"></i> Alerte</span>
              </div>
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
.farm-layout {
  display: flex;
  background: #f8fafc;
  min-height: 100vh;
  }
.main-wrapper {
  flex: 1;
  margin-left: 260px;
  }
.page-content {
  padding: 30px 40px;
  }

.content-header h1 {
  font-size: 24px;
  font-weight: 800;
  color: #1e293b;
  margin-bottom: 5px;
  }
.subtitle {
  color: #64748b;
  font-size: 14px;
  margin-bottom: 30px;
  }

.top-stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-bottom: 30px;
  }
.stat-card {
  background: white;
  padding: 25px;
  border-radius: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border: 1px solid #edf2f7;
  }
.stat-label {
 font-weight: 600;
 font-family: 'Inter', sans-serif;
}
.stat-value {
  display: block;
  font-size: 28px;
  font-weight: 800;
  color: #1e293b;
  }
.stat-trend.green {
  color: #11D432;
  font-size: 12px;
  font-weight: 700;
  }
.stat-trend.orange {
  color: red;
  font-size: 10px;
  font-weight: 700;
}
.stat-circle-icon {
  width: 45px;
  height: 45px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  }
.bg-green-light {
  background: #f0fff4;
  color: #11D432;
  }
.bg-blue-light {
  background: #eff6ff;
  color: #3b82f6;
  }
.bg-red-light {
  background: #fef2f2;
  color: #ef4444;
  }

.middle-stats-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
  margin-bottom: 30px;
  }
.bottom-stats-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  }
.chart-container {
  background: white;
  padding: 25px;
  border-radius: 12px;
  border: 1px solid #edf2f7;
  }

.line-chart-svg {
  margin-top: 10px;
  }
.x-axis {
  display: flex;
  justify-content: space-between;
  margin-top: 10px;
  font-size: 11px;
  color: #94a3b8;
  }

.donut-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 180px;
  justify-content: center;
  }
.donut-svg-mock {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  border: 12px solid #11D432;
  margin-bottom: 15px;
  }
.donut-svg-mock.species {
  border-left-color: #cbd5e1;
  }
.donut-svg-mock.health {
  border-top-color: #3b82f6;
  border-left-color: #ef4444;
  }
.donut-legend {
  display: flex; gap: 10px;
  }
.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  display: inline-block;
  }
.dot.green { background: #11D432; }
.dot.gray { background: #cbd5e1; }
.dot.blue { background: #3b82f6; }
.dot.red { background: #ef4444; }

.bar-chart-wrap {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  height: 150px;
  }
.bar-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 35px;
  gap: 8px;
  }
.bar {
  width: 100%;
  background: #11D432;
  opacity: 0.7;
  border-radius: 4px;
  }
.bar.active { opacity: 1; }
</style>