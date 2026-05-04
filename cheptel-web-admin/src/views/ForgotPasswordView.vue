<template>
  <div class="login-page">
    <div class="login-card">

      <div class="text-center mb-4">
        <div class="login-logo">
          <i class="bi bi-lock-fill"></i>
        </div>
        <h4 class="fw-bold mb-1">Réinitialisation</h4>
        <p class="text-muted small mb-0">
          Récupération du mot de passe
        </p>
      </div>

      <div class="mb-3">
        <div class="d-flex justify-content-between">
          <div
              v-for="n in 3"
              :key="n"
              class="rounded-pill me-1"
              :style="{
              flex: 1,
              height: '5px',
              background: n <= step ? '#0B5D1E' : '#e5e7eb'
            }"
          ></div>
        </div>
      </div>

      <!-- Étape 1 -->
      <div v-if="step === 1">
        <p class="text-muted small mb-3">
          Entrez votre email. Un code vous sera envoyé.
        </p>

        <div class="mb-3">
          <label class="form-label fw-semibold small text-muted">
            EMAIL DU COMPTE
          </label>
          <div class="input-group">
            <span class="input-group-text">
              <i class="bi bi-envelope"></i>
            </span>
            <input
                v-model="contact"
                type="email"
                class="form-control"
                placeholder="admin@email.com"
            />
          </div>
        </div>

        <button
            class="btn w-100 py-2 fw-bold text-white"
            style="background:#0B5D1E;"
            :disabled="loading"
            @click="sendCode"
        >
          <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
          ENVOYER LE CODE
        </button>
      </div>

      <!-- Étape 2 -->
      <div v-if="step === 2">
        <div class="alert alert-info small py-2 mb-3">
          <i class="bi bi-info-circle me-1"></i>
          Un code à 6 chiffres vous a été envoyé.
          En développement, regardez aussi la console backend.
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold small text-muted">
            CODE DE VÉRIFICATION
          </label>
          <input
              v-model="code"
              type="text"
              maxlength="6"
              class="form-control text-center fw-bold"
              style="font-size:22px;letter-spacing:8px;"
              placeholder="000000"
          />
        </div>

        <button
            class="btn w-100 py-2 fw-bold text-white mb-2"
            style="background:#0B5D1E;"
            :disabled="loading"
            @click="verifyCode"
        >
          <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
          VALIDER LE CODE
        </button>

        <button
            class="btn btn-link w-100"
            @click="sendCode"
            :disabled="loading"
        >
          Renvoyer le code
        </button>
      </div>

      <!-- Étape 3 -->
      <div v-if="step === 3">
        <p class="text-muted small mb-3">
          Choisissez un nouveau mot de passe.
        </p>

        <div class="mb-3">
          <label class="form-label fw-semibold small text-muted">
            NOUVEAU MOT DE PASSE
          </label>
          <input
              v-model="newPassword"
              type="password"
              class="form-control"
              placeholder="Minimum 6 caractères"
          />
        </div>

        <div class="mb-3">
          <label class="form-label fw-semibold small text-muted">
            CONFIRMER LE MOT DE PASSE
          </label>
          <input
              v-model="confirmPassword"
              type="password"
              class="form-control"
              placeholder="Confirmer"
          />
        </div>

        <button
            class="btn w-100 py-2 fw-bold text-white"
            style="background:#0B5D1E;"
            :disabled="loading"
            @click="resetPassword"
        >
          <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
          RÉINITIALISER
        </button>
      </div>

      <div v-if="error" class="alert alert-danger py-2 small mt-3">
        {{ error }}
      </div>

      <div v-if="successMsg" class="alert alert-success py-2 small mt-3">
        {{ successMsg }}
      </div>

      <div class="text-center mt-4">
        <RouterLink
            to="/login"
            class="small fw-semibold"
            style="color:#0B5D1E;text-decoration:underline;"
        >
          Retour à la connexion
        </RouterLink>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import {useRouter} from "vue-router";
import api from "@/api/axios.js";

const router = useRouter()

const step = ref(1)
const contact = ref('')
const code = ref('')
const newPassword = ref('')
const confirmPassword = ref('')
const loading = ref(false)
const error = ref('')
const successMsg = ref('')

async function sendCode() {
  error.value = ''
  successMsg.value = ''

  if (!contact.value.trim()) {
    error.value = 'Veuillez saisir votre email.'
    return
  }

  loading.value = true

  try {
    await api.post('/auth/forgot-password', {
      contact: contact.value.trim()
    })

    successMsg.value = 'Code envoyé. Vérifiez votre email.'
    step.value = 2
  } catch (e) {
    error.value = e.response?.data?.message || 'Erreur envoi du code'
  } finally {
    loading.value = false
  }
}

async function verifyCode() {
  error.value = ''
  successMsg.value = ''

  if (code.value.trim().length !== 6) {
    error.value = 'Le code doit contenir 6 chiffres.'
    return
  }

  loading.value = true

  try {
    await api.post('/auth/verify-reset-code', {
      contact: contact.value.trim(),
      code: code.value.trim()
    })

    successMsg.value = 'Code valide !'
    step.value = 3
  } catch (e) {
    error.value = e.response?.data?.message || 'Code invalide ou expiré'
  } finally {
    loading.value = false
  }
}

async function resetPassword() {
  error.value = ''
  successMsg.value = ''

  if (newPassword.value.length < 6) {
    error.value = 'Mot de passe minimum 6 caractères.'
    return
  }

  if (newPassword.value !== confirmPassword.value) {
    error.value = 'Les mots de passe ne correspondent pas.'
    return
  }

  loading.value = true

  try {
    await api.post('/auth/reset-password', {
      contact: contact.value.trim(),
      code: code.value.trim(),
      newPassword: newPassword.value
    })

    successMsg.value = 'Mot de passe réinitialisé avec succès !'

    setTimeout(() => {
      router.push('/login')
    }, 1500)

  } catch (e) {
    error.value = e.response?.data?.message || 'Erreur réinitialisation'
  } finally {
    loading.value = false
  }
}
</script>