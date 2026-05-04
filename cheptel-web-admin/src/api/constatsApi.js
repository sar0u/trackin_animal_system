import api from './axios.js'

export const constatsApi = {
    getAll: () => api.get('/admin/constats'),
    updateStatus: (id, status) =>
        api.put(`/admin/constats/${id}/status`, { status })
}