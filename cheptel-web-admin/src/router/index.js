import { createRouter, createWebHistory } from 'vue-router'
import CampaignsView from "@/views/CampaignsView.vue";

function isAdmin(role) {
    return role === 'ADMIN' || role === 'ROLE_ADMIN'
}

const routes = [
    {
        path: '/',
        redirect: '/login'
    },
    {
        path: '/login',
        name: 'Login',
        component: () => import('../views/LoginView.vue'),
        meta: { public: true }
    },
    {
        path: '/forgot-password',
        name: 'ForgotPassword',
        component: () => import('../views/ForgotPasswordView.vue'),
        meta: { public: true }
    },
    {
        path: '/dashboard',
        name: 'Dashboard',
        component: () => import('../views/DashboardView.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/users',
        name: 'Users',
        component: () => import('../views/UsersView.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/farms',
        name: 'Farms',
        component: () => import('../views/FarmsView.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/animals',
        name: 'Animals',
        component: () => import('../views/AnimalsView.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/animals/:id',
        name: 'AnimalDetail',
        component: () => import('../views/AnimalsDetailView.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/subventions',
        name: 'Subventions',
        component: () => import('../views/SubventionsView.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/constats',
        name: 'Constats',
        component: () => import('../views/ConstatsView.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/fraud',
        name: 'Fraud',
        component: () => import('../views/FraudView.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/audit',
        name: 'Audit',
        component: () => import('../views/AuditView.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/exports',
        name: 'Exports',
        component: () => import('../views/ExportsView.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/settings',
        name: 'Settings',
        component: () => import('../views/SettingsView.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/:pathMatch(.*)*',
        name: 'NotFound',
        component: () => import('../views/NotFoundView.vue')
    },

    {
        path: '/campaigns',
        name: 'Campaigns',
        component: CampaignsView,
        meta: { requiresAuth: true }
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

router.beforeEach((to, from, next) => {
    const token = sessionStorage.getItem('access_token')
    const role = sessionStorage.getItem('user_role')

    if (to.meta.requiresAuth) {
        if (!token || !isAdmin(role)) {
            sessionStorage.clear()
            return next('/login')
        }
    }

    next()
})

export default router