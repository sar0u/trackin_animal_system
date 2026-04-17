import axios from 'axios';

// 1. Création de l'instance de base
const api = axios.create({
    // URL de ton backend Spring Boot (d'après ta console, il est sur le port 8080)
    baseURL: 'http://localhost:8080/api',
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    },
    timeout: 10000 // Optionnel : annule la requête si le serveur met plus de 10 secondes à répondre
});

// 2. Intercepteur de REQUÊTE (Avant que la requête parte au serveur)
api.interceptors.request.use(
    (config) => {
        // On va chercher le token de connexion (JWT) sauvegardé lors du login
        const token = localStorage.getItem('token');

        // Si l'utilisateur est connecté (token présent), on attache le badge de sécurité à la requête
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }

        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// 3. Intercepteur de RÉPONSE (Quand le serveur te répond)
api.interceptors.response.use(
    (response) => {
        // Si tout se passe bien (Code 200), on renvoie directement les données
        return response;
    },
    (error) => {
        // Gestion globale des erreurs fréquentes
        if (error.response) {
            // Erreur 401 : Non Autorisé (Le token a expiré ou est invalide)
            if (error.response.status === 401) {
                console.warn("Session invalide ou expirée. Déconnexion automatique.");

                // On nettoie les traces de l'ancienne session
                localStorage.removeItem('token');
                localStorage.removeItem('user');

                // On renvoie l'utilisateur vers la page de connexion
                // (Décommente la ligne ci-dessous si tu veux forcer le retour au login)
                // window.location.href = '/login';
            }

            // Erreur 500 : Erreur interne du serveur (Spring Boot a crashé)
            if (error.response.status === 500) {
                console.error("Erreur 500 critique sur le backend Spring Boot.");
            }
        } else {
            console.error("Impossible de joindre le serveur. Spring Boot est-il lancé ?");
        }

        return Promise.reject(error);
    }
);

export default api;