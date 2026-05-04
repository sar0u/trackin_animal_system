import api from './axios.js'

export const subventionsApi = {
    getAll: () => api.get('/admin/subventions'),

    create: (data) => api.post('/admin/subventions', data),

    updateStatus: (id, status, reason = '') =>
        api.put(`/admin/subventions/${id}/status`, {
            status,
            reason
        }),

    delete: (id) => api.delete(`/admin/subventions/${id}`)
}