import api from './axios.js'

export const dashboardApi = {
    getStats: () => api.get('/admin/dashboard'),
    getStatsByWilaya: () => api.get('/admin/stats/by-wilaya'),
    getStatsBySpecies: () => api.get('/admin/stats/by-species')
}