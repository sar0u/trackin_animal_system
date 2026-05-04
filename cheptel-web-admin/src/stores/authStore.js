import { defineStore } from 'pinia'
import api from '../api/axios.js'

export const useAuthStore = defineStore('auth', {
    state: () => ({
        token: sessionStorage.getItem('access_token') || null,
        username: sessionStorage.getItem('username') || null,
        role: sessionStorage.getItem('user_role') || null,
        isLoading: false,
        error: null
    }),

    getters: {
        isLoggedIn: (state) => !!state.token,

        isAdmin: (state) => {
            return state.role === 'ADMIN' || state.role === 'ROLE_ADMIN'
        },

        userInitials: (state) => {
            if (!state.username) return 'AD'
            return state.username.substring(0, 2).toUpperCase()
        }
    },

    actions: {
        restoreSession() {
            this.token = sessionStorage.getItem('access_token')
            this.username = sessionStorage.getItem('username')
            this.role = sessionStorage.getItem('user_role')
        },

        async login(identifier, password) {
            this.isLoading = true
            this.error = null

            try {
                const response = await api.post('/auth/login', {
                    identifier,
                    password
                })

                const data = response.data

                console.log('LOGIN RESPONSE:', data)

                if (!data.token) {
                    throw new Error('Token manquant dans la réponse serveur')
                }

                const role = data.role?.toString()

                if (role !== 'ADMIN' && role !== 'ROLE_ADMIN') {
                    throw new Error('Accès réservé aux administrateurs.')
                }

                this.token = data.token
                this.username = data.username
                this.role = role === 'ROLE_ADMIN' ? 'ADMIN' : role

                sessionStorage.setItem('access_token', this.token)
                sessionStorage.setItem('username', this.username)
                sessionStorage.setItem('user_role', this.role)

                return true
            } catch (error) {
                console.error('LOGIN ERROR:', error)

                if (error.response?.data?.message) {
                    this.error = error.response.data.message
                } else {
                    this.error = error.message || 'Erreur de connexion'
                }

                this.logout()
                return false
            } finally {
                this.isLoading = false
            }
        },

        logout() {
            this.token = null
            this.username = null
            this.role = null

            sessionStorage.removeItem('access_token')
            sessionStorage.removeItem('username')
            sessionStorage.removeItem('user_role')

            localStorage.removeItem('access_token')
            localStorage.removeItem('username')
            localStorage.removeItem('user_role')
        }
    }
})