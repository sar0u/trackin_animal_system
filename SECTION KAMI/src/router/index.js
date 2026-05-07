import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '../views/LoginView.vue'
import DashboardView from '../views/DashboardView.vue'
import GestionUsers from '../views/GestionUsers.vue'
import GestionSubventions from '../views/GestionSubventions.vue'
import GestionFermes from '../views/GestionFermes.vue'
import GestionAnimals from '../views/GestionAnimals.vue'
import GestionMouvsStats from '../views/GestionMouvements.vue'
import FraudManagement from '../views/FraudManagement.vue'

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
              path: '/sub',
              name: 'sub',
              component: () => import('../views/GestionSubventions.vue'),
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
          path: '/movements', // Positionnée ici entre animaux et fraude
          name: 'movements',
          component: () => import('../views/GestionMouvements.vue'),
          meta: { requiresAdmin: true }
    },
    {
              path: '/audit',
              name: 'audit',
              component: () => import('../views/GestionMouvsStats.vue'),
              meta: { requiresAdmin: true }
    },
    {
      path: '/fraude',
      name: 'fraude',
      component: () => import('../views/FraudManagement.vue'),
      meta: { requiresAdmin: true }
    }
  ]
})

// LE VERROU : Navigation Guard
router.beforeEach((to, from, next) => {
  // On vérifie si la route demande une authentification
  const requiresAdmin = to.matched.some(record => record.meta.requiresAdmin);

  // On récupère l'état de connexion (stocké dans le localStorage lors du login)
  const isAuthenticated = localStorage.getItem('isAdminAuthenticated') === 'true';

  if (requiresAdmin && !isAuthenticated) {
    // Si pas admin et page protégée -> Retour au login
    next({ name: 'login' });
  } else if (to.name === 'login' && isAuthenticated) {
    // Si déjà connecté et essaie d'aller sur login -> Go dashboard
    next({ name: 'dashboard' });
  } else {
    // Sinon, on laisse passer
    next();
  }
});
export default router
