import api from './axios.js'

export const searchApi = {
    global: (q) => api.get('/admin/search', { params: { q } })
}