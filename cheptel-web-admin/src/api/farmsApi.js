import api from './axios.js'

export const farmsApi = {
    getAll: () => api.get('/admin/farms'),
    getById: (id) => api.get(`/admin/farms/${id}`)
}