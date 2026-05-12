import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '../views/LoginView.vue'

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
            path: '/users',
            name: 'users',
            component: () => import('../views/GestionUsers.vue'),
            meta: { requiresAdmin: true }
        },
        {
            path: '/subsidies',
            name: 'subsidies',
            component: () => import('../views/GestionSubventions.vue'),
            meta: { requiresAdmin: true }
        },
        {
            path: '/sub',
            redirect: '/subsidies'
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
            component: () => import('../views/AuditLog.vue'),
            meta: { requiresAdmin: true }
        },
        {
            path: '/fraude',
            name: 'fraude',
            component: () => import('../views/FraudManagement.vue'),
            meta: { requiresAdmin: true }
        },
        {
            path: '/health-records',
            name: 'health-records',
            component: () => import('../views/GestionSante.vue'),
            meta: { requiresAdmin: true }
        },
        {
            path: '/reproductions',
            name: 'reproductions',
            component: () => import('../views/Reproductions.vue'),
            meta: { requiresAdmin: true }
        },
        {
            path: '/sanitary-campaigns',
            name: 'sanitary-campaigns',
            component: () => import('../views/SanitaryCampaigns.vue'),
            meta: { requiresAdmin: true }
        },
    ]
})

// Protège les routes: redirige vers login si pas authentifié admin
router.beforeEach((to) => {
    const requiresAdmin = to.matched.some(record => record.meta.requiresAdmin);

    const isAuthenticated = localStorage.getItem('isAdminAuthenticated') === 'true';
    const role = localStorage.getItem('user_role');
    const isAdmin = role === 'Administrator';

    if (requiresAdmin && (!isAuthenticated || !isAdmin)) {
        return { name: 'login' };
    }
    if (to.name === 'login' && isAuthenticated) {
        return { name: 'dashboard' };
    }
    return true;
});
export default router