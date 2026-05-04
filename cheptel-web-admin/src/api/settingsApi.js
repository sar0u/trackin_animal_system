import api from './axios.js'

export const settingsApi = {
    getAll: () => api.get('/admin/settings'),

    update: (key, value) =>
        api.put(`/admin/settings/${key}`, { value })
}