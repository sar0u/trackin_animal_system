import axios from 'axios';

// 1. Création de l'instance de base
const api = axios.create({
    baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api',
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    },
    timeout: 10000
});

// Ajoute le JWT à chaque requête sortante
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('token');

        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }

        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// Traite les erreurs de réponse du serveur
api.interceptors.response.use(
    (response) => {
        return response;
    },
    (error) => {
        if (error.response) {
            // Session expirée: nettoie localStorage et redirige au login
            if (error.response.status === 401 || error.response.status === 403) {
                console.warn("Session invalide ou expirée.");

                localStorage.removeItem('token');
                localStorage.removeItem('user');
                localStorage.removeItem('isAdminAuthenticated');
                localStorage.removeItem('user_role');
                localStorage.removeItem('user_name');
                localStorage.removeItem('user_email');

                if (window.location.pathname !== '/') {
                    window.location.href = '/';
                }
            }

            if (error.response.status === 500) {
                console.error("Erreur 500 du serveur.");
            }
        } else {
            console.error("Impossible de contacter le serveur.");
        }

        return Promise.reject(error);
    }
);

export default api;