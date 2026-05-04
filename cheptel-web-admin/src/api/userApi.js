import api from './axios.js'

export const usersApi = {
    getAll: () => api.get('/admin/users'),

    create: (data) => api.post('/admin/users', data),

    update: (id, data) => api.put(`/admin/users/${id}`, data),

    toggle: (id) => api.put(`/admin/users/${id}/toggle`),

    delete: (id) => api.delete(`/admin/users/${id}`)
}