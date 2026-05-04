import api from './axios.js'

export const alertsApi = {
    getAll: () => api.get('/admin/alerts'),
    resolve: (id) => api.put(`/alerts/${id}/resolve`)
}