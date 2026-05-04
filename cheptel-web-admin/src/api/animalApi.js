import api from './axios.js'

export const animalsApi = {
    getAll: (params = {}) =>
        api.get('/admin/animal-management/animals', { params }),

    getHistory: (id) =>
        api.get(`/admin/animal-management/history/${id}`)
}