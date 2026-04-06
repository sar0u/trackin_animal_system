import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '../views/LoginView.vue'
import DashboardView from '../views/DashboardView.vue' // On va créer ce fichier juste après
import GestionUsers from '../views/GestionUsers.vue'
import GestionFermes from '../views/GestionFermes.vue'
import GestionAnimals from '../views/GestionAnimals.vue'
import GestionMouvsStats from '../views/GestionMouvsStats.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'login',
      component: LoginView
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: () => import('../views/DashboardView.vue'),
      meta: { requiresAdmin: true }
    },
    {
          path: '/users', // Nouvelle route pour les utilisateurs
          name: 'users',
          component: () => import('../views/GestionUsers.vue'),
          meta: { requiresAdmin: true }
    },
    {
          path: '/farms',
          name: 'farms',
          component: () => import('../views/GestionFermes.vue'),
          meta: { requiresAdmin: true }
    },
    {
              path: '/animals',
              name: 'animals',
              component: () => import('../views/GestionAnimals.vue'),
              meta: { requiresAdmin: true }
    },
    {
              path: '/mouves',
              name: 'mouves',
              component: () => import('../views/GestionMouvsStats.vue'),
              meta: { requiresAdmin: true }
    },
    {
      path: '/farm-dashboard',
      name: 'farm-dashboard',
      component: () => import('../views/FarmDashboard.vue'),
       meta: { requiresAdmin: false }
    },
    {
      path: '/farm-animals',
      name:'farm-animals',
      component: () => import('../views/FarmGestionAnimals.vue'),
      meta: { requiresAdmin: false }
    },
    {
      path: '/farm-mouves',
      name: 'farm-mouves',
      component: () => import('../views/FarmGestionMouvs.vue'),
      meta: { requiresAdmin: false }
    },
    {
          path: '/farm-stats',
          name: 'farm-stats',
          component: () => import('../views/FarmStats.vue'),
          meta: { requiresAdmin: false }
    }
  ]
})

export default router
