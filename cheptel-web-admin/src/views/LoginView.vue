<template>
  <div class="login-page">

    <!-- Fond image -->
    <div class="login-bg"></div>

    <!-- Overlay vert -->
    <div class="login-overlay"></div>

    <!-- Card -->
    <div class="login-card">

      <div class="text-center mb-4">
        <!-- Logo application -->
        <img
            src="/logo.png"
            alt="DZcheptel"
            class="login-logo-img"
            @error="showFallbackIcon = true"
            v-if="!showFallbackIcon"
        />

        <div v-else class="login-logo-fallback">
          <i class="bi bi-diagram-3-fill"></i>
        </div>

        <h3 class="fw-bold mb-1 mt-2">DZcheptel</h3>
        <p class="text-muted mb-0">Portail d'administration</p>
      </div>

      <!-- Form Login ou Register -->
      <form v-if="!showRegister" @submit.prevent="handleLogin">

        <div class="mb-3">
          <label class="form-label fw-semibold small text-muted">
            IDENTIFIANT OU EMAIL
          </label>
          <div class="input-group">
            <span class="input-group-text bg-white border-end-0">
              <i class="bi bi-person text-muted"></i>
            </span>
            <input
                v-model="identifier"
                type="text"
                class="form-control border-start-0"
                placeholder="admin1"
                required
                :disabled="loading"
            />
          </div>
        </div>

        <div class="mb-2">
          <label class="form-label fw-semibold small text-muted">
            MOT DE PASSE
          </label>
          <div class="input-group">
            <span class="input-group-text bg-white border-end-0">
              <i class="bi bi-lock text-muted"></i>
            </span>
            <input
                v-model="password"
                :type="showPwd ? 'text' : 'password'"
                class="form-control border-start-0 border-end-0"
                placeholder="••••••••"
                required
                :disabled="loading"
            />
            <button
                type="button"
                class="input-group-text bg-white border-start-0"
                @click="showPwd = !showPwd"
            >
              <i :class="showPwd ? 'bi bi-eye-slash text-muted' : 'bi bi-eye text-muted'"></i>
            </button>
          </div>
        </div>

        <div class="d-flex justify-content-end mb-3">
          <RouterLink
              to="/forgot-password"
              class="small fw-semibold"
              style="color:#0B5D1E;text-decoration:underline;"
          >
            Mot de passe oublié ?
          </RouterLink>
        </div>

        <div v-if="error" class="alert alert-danger py-2 small mb-3">
          <i class="bi bi-exclamation-triangle me-1"></i>
          {{ error }}
        </div>

        <button
            class="btn w-100 py-2 fw-bold text-white mb-3"
            style="background:#0B5D1E;border-radius:10px;"
            type="submit"
            :disabled="loading"
        >
          <span v-if="loading">
            <span class="spinner-border spinner-border-sm me-2"></span>
            Connexion...
          </span>
          <span v-else>
            <i class="bi bi-shield-lock me-2"></i>
            SE CONNECTER
          </span>
        </button>

        <hr class="my-3" />

        <button
            type="button"
            class="btn w-100 py-2 fw-bold btn-outline-success"
            style="border-radius:10px;"
            @click="showRegister = true"
        >
          <i class="bi bi-person-plus me-2"></i>
          Créer un compte administrateur
        </button>

      </form>

      <!-- Formulaire Register -->
      <form v-else @submit.prevent="handleRegister">

        <div class="d-flex align-items-center mb-4 gap-2">
          <button
              type="button"
              class="btn btn-sm btn-outline-secondary"
              @click="showRegister = false"
          >
            <i class="bi bi-arrow-left"></i>
          </button>
          <h5 class="fw-bold mb-0">Créer un compte Admin</h5>
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold small text-muted">NOM D'UTILISATEUR *</label>
          <input v-model="reg.username" type="text" class="form-control" placeholder="admin_xyz" required />
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold small text-muted">EMAIL *</label>
          <input v-model="reg.email" type="email" class="form-control" placeholder="admin@cheptel.dz" required />
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold small text-muted">TÉLÉPHONE</label>
          <input v-model="reg.phoneNumber" type="text" class="form-control" placeholder="0555000000" />
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold small text-muted">MOT DE PASSE *</label>
          <input v-model="reg.password" type="text" class="form-control" placeholder="Minimum 6 caractères" required />
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold small text-muted">CONFIRMER *</label>
          <input v-model="reg.confirmPassword" type="text" class="form-control" placeholder="Répéter le mot de passe" required />
        </div>

        <div class="alert alert-info small py-2 mb-3" style="background:#EAF5E8;color:#0B5D1E;border:none;">
          <i class="bi bi-info-circle me-1"></i>
          Ce compte aura un accès complet à l'interface d'administration.
        </div>

        <div v-if="regError" class="alert alert-danger py-2 small mb-3">{{ regError }}</div>
        <div v-if="regSuccess" class="alert alert-success py-2 small mb-3">{{ regSuccess }}</div>

        <button
            class="btn w-100 py-2 fw-bold text-white mb-2"
            style="background:#0B5D1E;border-radius:10px;"
            type="submit"
            :disabled="regLoading"
        >
          <span v-if="regLoading" class="spinner-border spinner-border-sm me-2"></span>
          <i v-else class="bi bi-person-check me-2"></i>
          CRÉER LE COMPTE ADMIN
        </button>

        <button type="button" class="btn w-100 btn-outline-secondary" style="border-radius:10px;" @click="showRegister = false">
          Annuler
        </button>

      </form>

      <div class="text-center mt-4">
        <small class="text-muted">
          Ministère de l'Agriculture — Accès réservé
        </small>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import api from "@/api/axios.js";


const router = useRouter()

const identifier = ref('')
const password = ref('')
const showPwd = ref(false)
const loading = ref(false)
const error = ref('')
const showFallbackIcon = ref(false)
const showRegister = ref(false)

const reg = ref({
  username: '',
  email: '',
  phoneNumber: '',
  password: '',
  confirmPassword: ''
})

const regLoading = ref(false)
const regError = ref('')
const regSuccess = ref('')

async function handleLogin() {
  loading.value = true
  error.value = ''

  try {
    const res = await api.post('/auth/login', {
      identifier: identifier.value,
      password: password.value
    })

    const data = res.data
    const role = (data.role || '').toString()

    if (role !== 'ADMIN' && role !== 'ROLE_ADMIN') {
      error.value = 'Accès réservé aux administrateurs.'
      return
    }

    sessionStorage.setItem('access_token', data.token)
    sessionStorage.setItem('username', data.username)
    sessionStorage.setItem('user_role', 'ADMIN')

    await router.push('/dashboard')

  } catch (e) {
    error.value = e.response?.data?.message || 'Erreur de connexion'
  } finally {
    loading.value = false
  }
}

async function handleRegister() {
  regError.value = ''
  regSuccess.value = ''

  if (!reg.value.username || !reg.value.email || !reg.value.password) {
    regError.value = 'Nom, email et mot de passe sont obligatoires.'
    return
  }

  if (reg.value.password.length < 6) {
    regError.value = 'Mot de passe minimum 6 caractères.'
    return
  }

  if (reg.value.password !== reg.value.confirmPassword) {
    regError.value = 'Les mots de passe ne correspondent pas.'
    return
  }

  regLoading.value = true

  try {
    await api.post('/auth/register-admin', {
      username: reg.value.username,
      email: reg.value.email,
      phoneNumber: reg.value.phoneNumber,
      password: reg.value.password
    })

    regSuccess.value = 'Compte administrateur créé avec succès !'

    reg.value = { username: '', email: '', phoneNumber: '', password: '', confirmPassword: '' }

    setTimeout(() => {
      showRegister.value = false
      regSuccess.value = ''
    }, 2000)

  } catch (e) {
    regError.value = e.response?.data?.message || 'Erreur lors de la création'
  } finally {
    regLoading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}

.login-bg {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: url('/bg-login.png');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  z-index: 0;
}

.login-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(
      135deg,
      rgba(25, 69, 25, 0.8) 0%,
      rgba(11, 93, 30, 0.70) 100%
  );
  z-index: 1;
}

.login-card {
  position: relative;
  z-index: 2;
  background: white;
  border-radius: 24px;
  width: 100%;
  max-width: 420px;
  padding: 40px 36px;
  box-shadow: 0 30px 60px rgba(0,0,0,0.35);
}

.login-logo-img {
  width: 80px;
  height: 80px;
  border-radius: 20px;
  object-fit: contain;
}

.login-logo-fallback {
  width: 80px;
  height: 80px;
  border-radius: 20px;
  background: #0B5D1E;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 38px;
  margin: 0 auto;
}
</style>