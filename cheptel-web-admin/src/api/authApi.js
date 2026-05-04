import api from './axios.js'

export const authApi = {
    login: (identifier, password) =>
        api.post('/auth/login', { identifier, password }),

    health: () =>
        api.get('/auth/health')
}