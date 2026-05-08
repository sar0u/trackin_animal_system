<template>
  <div class="login-page">
    <div class="login-card">

      <div class="logo">
        <img src="./Imgs/logo.png" alt="Logo" class="logo-img" @error="$event.target.src='https://via.placeholder.com/30/22c55e/ffffff?text=TD'">
        <h2>DZCheptel</h2>
      </div>

      <div v-if="currentStep === 'login'" class="step-container">
        <div class="subtitle">
          <strong>Connexion Administrateur</strong><br>
          Gérez votre exploitation en toute simplicité.
        </div>

        <form @submit.prevent="login">
          <div class="form-group">
            <label>Nom D'Utilisateur ou Email</label>
            <input v-model="username" type="text" placeholder="Votre nom d'utilisateur ou email" required>
          </div>

          <div class="form-group">
            <label>Mot de passe</label>
            <input v-model="password" type="password" placeholder="********" required>
          </div>

          <div class="options">
            <label>
              <input type="checkbox" v-model="rememberMe">
              Rester connecté
            </label>
            <a href="#" @click.prevent="goToStep('email')">Mot de passe oublié ?</a>
          </div>

          <p v-if="errorMessage" class="error-msg"><i class="fas fa-exclamation-circle"></i> {{ errorMessage }}</p>
          <p v-if="successMessage" class="success-msg"><i class="fas fa-check-circle"></i> {{ successMessage }}</p>

          <button type="submit" :disabled="isLoading">
            {{ isLoading ? 'Connexion...' : 'Se connecter →' }}
          </button>
        </form>
      </div>

      <div v-else-if="currentStep === 'email'" class="step-container fade-in">
        <div class="subtitle">
          <strong>Mot de passe oublié</strong><br>
          Entrez votre email pour recevoir un code de sécurité.
        </div>

        <form @submit.prevent="sendVerificationCode">
          <div class="form-group">
            <label>Adresse Email</label>
            <input v-model="resetEmail" type="email" placeholder="admin@DZCheptel.dz" required>
          </div>

          <p v-if="errorMessage" class="error-msg"><i class="fas fa-exclamation-circle"></i> {{ errorMessage }}</p>

          <button type="submit" :disabled="isLoading">
            {{ isLoading ? 'Envoi en cours...' : 'Envoyer le code' }}
          </button>

          <div class="back-link">
            <a href="#" @click.prevent="goToStep('login')"><i class="fas fa-arrow-left"></i> Retour à la connexion</a>
          </div>
        </form>
      </div>

      <div v-else-if="currentStep === 'code'" class="step-container fade-in">
        <div class="subtitle">
          <strong>Vérification de sécurité</strong><br>
          Un code à 6 chiffres a été envoyé à <br><span class="highlight">{{ resetEmail }}</span>
        </div>

        <form @submit.prevent="verifyCode">
          <div class="form-group">
            <label>Code de vérification</label>
            <input v-model="resetCode" type="text" placeholder="ex: 123456" maxlength="6" class="code-input" required>
          </div>

          <p v-if="errorMessage" class="error-msg"><i class="fas fa-exclamation-circle"></i> {{ errorMessage }}</p>

          <button type="submit" :disabled="isLoading">
            {{ isLoading ? 'Vérification...' : 'Valider le code' }}
          </button>

          <div class="back-link">
            <a href="#" @click.prevent="goToStep('email')">Je n'ai rien reçu (Renvoyer)</a>
          </div>
        </form>
      </div>

      <div v-else-if="currentStep === 'reset'" class="step-container fade-in">
        <div class="subtitle">
          <strong>Nouveau mot de passe</strong><br>
          Veuillez créer un mot de passe sécurisé.
        </div>

        <form @submit.prevent="updatePassword">
          <div class="form-group">
            <label>Nouveau mot de passe</label>
            <input v-model="newPassword" type="password" placeholder="Min. 8 caractères" minlength="8" required>
          </div>

          <div class="form-group">
            <label>Confirmer le mot de passe</label>
            <input v-model="confirmPassword" type="password" placeholder="Répétez le mot de passe" minlength="8" required>
          </div>

          <p v-if="errorMessage" class="error-msg"><i class="fas fa-exclamation-circle"></i> {{ errorMessage }}</p>

          <button type="submit" :disabled="isLoading">
            {{ isLoading ? 'Mise à jour...' : 'Mettre à jour le mot de passe' }}
          </button>
        </form>
      </div>


      <div class="footer-login">
        <div class="Cnx">Connexion sécurisée par cryptage 256-bit</div><br>
        <div class="Aide">
          <a href="#"> Aide </a>
          <a href="#"> Confidentialité </a>
          <a href="#"> Condition </a>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import api from '../services/api';

const router = useRouter();

// États de la page de connexion
const username = ref("");
const password = ref("");
const rememberMe = ref(false);
const errorMessage = ref("");
const successMessage = ref("");
const isLoading = ref(false);

// États de la réinitialisation de mot de passe
const currentStep = ref('login');
const resetEmail = ref("");
const resetCode = ref("");
const newPassword = ref("");
const confirmPassword = ref("");

// Change l'étape du flux (login → email → code → reset)
const goToStep = (step) => {
  errorMessage.value = "";
  successMessage.value = "";
  currentStep.value = step;
};

// Authentification: envoie les identifiants au serveur et stocke le token
const login = async () => {
  errorMessage.value = "";
  isLoading.value = true;

  try {
    const response = await api.post('/auth/login', {
      username: username.value,
      password: password.value,
      rememberMe: rememberMe.value
    });

    // Vérifie que l'utilisateur a le rôle Administrator
    if (response.data.role !== 'Administrator') {
      errorMessage.value = "Accès refusé : cet espace est strictement réservé aux administrateurs.";
      return;
    }

    // Sauvegarde les données de l'utilisateur dans localStorage
    localStorage.setItem('token', response.data.token);
    localStorage.setItem('user_role', response.data.role);
    localStorage.setItem('user_name', response.data.username || '');
    localStorage.setItem('user_email', response.data.email || '');
    localStorage.setItem('isAdminAuthenticated', 'true');

    // Redirige vers le dashboard
    router.push('/dashboard');

  } catch (error) {
    if (error.response && error.response.status === 401) {
      errorMessage.value = "Identifiant ou mot de passe incorrect.";
    } else {
      errorMessage.value = "Impossible de joindre le serveur.";
    }
  } finally {
    isLoading.value = false;
  }
};

// Envoie un code de vérification par email pour la réinitialisation du mot de passe
const sendVerificationCode = async () => {
  errorMessage.value = "";
  isLoading.value = true;
  try {
    await api.post('/auth/forgot-password', { email: resetEmail.value });
    goToStep('code');
  } catch (error) {
    errorMessage.value = "Aucun compte associé à cette adresse email.";
  } finally { isLoading.value = false; }
};

// Valide le code 6 chiffres reçu par email
const verifyCode = async () => {
  errorMessage.value = "";
  isLoading.value = true;
  try {
    await api.post('/auth/verify-code', { email: resetEmail.value, code: resetCode.value });
    goToStep('reset');
  } catch (error) {
    errorMessage.value = "Le code est incorrect ou a expiré.";
  } finally { isLoading.value = false; }
};

// Réinitialise le mot de passe avec le nouveau mot de passe saisi
const updatePassword = async () => {
  errorMessage.value = "";
  if (newPassword.value !== confirmPassword.value) {
    errorMessage.value = "Les mots de passe ne correspondent pas."; return;
  }
  isLoading.value = true;
  try {
    await api.post('/auth/reset-password', {
      email: resetEmail.value,
      code: resetCode.value,
      newPassword: newPassword.value
    });

    resetEmail.value = ""; resetCode.value = ""; newPassword.value = ""; confirmPassword.value = "";
    successMessage.value = "Mot de passe mis à jour ! Vous pouvez vous connecter.";
    goToStep('login');
  } catch (error) {
    errorMessage.value = "Erreur lors de la mise à jour.";
  } finally { isLoading.value = false; }
};
</script>

<style scoped>
.login-page {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background-image: linear-gradient(rgba(6, 59, 22, 0.75), rgba(11, 93, 30, 0.65)),
                    url("https://images.unsplash.com/photo-1500076656116-558758c991c1?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80");
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  font-family: 'Inter', sans-serif;
  margin: 0;
  padding: 0;
}

.login-card {
  width: 100%;
  max-width: 420px;
  background: rgba(255, 255, 255, 0.97);
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 20px 40px rgba(6, 59, 22, 0.3);
  z-index: 2;
  position: relative;
  overflow: hidden;
}

.login-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #0B5D1E, #4CAF50, #0B5D1E);
}

.fade-in {
  animation: fadeIn 0.4s ease-out forwards;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateX(10px); }
  to { opacity: 1; transform: translateX(0); }
}

.logo {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  margin-bottom: 20px;
}

.logo-img {
  width: 36px;
  height: auto;
}

h2 {
  margin: 0;
  color: #0f172a;
  font-size: 24px;
  font-weight: 800;
  letter-spacing: -0.5px;
}

.subtitle {
  text-align: center;
  font-size: 14px;
  color: #64748b;
  margin-bottom: 25px;
  line-height: 1.5;
}

.subtitle strong {
  font-size: 18px;
  color: #0f172a;
  font-weight: 800;
}

.highlight {
  color: #0B5D1E;
  font-weight: 700;
}

.form-group {
  margin-bottom: 18px;
}

.form-group label {
  font-size: 13px;
  font-weight: 600;
  color: #063B16;
  display: block;
  margin-bottom: 6px;
}

input {
  width: 100%;
  padding: 12px 15px;
  border-radius: 8px;
  border: 1px solid rgba(11, 93, 30, 0.2);
  background-color: rgba(11, 93, 30, 0.03);
  font-family: inherit;
  font-size: 14px;
  transition: all 0.2s;
  box-sizing: border-box;
  color: #063B16;
}

input::placeholder {
  color: #0B5D1E;
  opacity: 0.5;
}

input:focus {
  border-color: #0B5D1E;
  background-color: white;
  outline: none;
  box-shadow: 0 0 0 3px rgba(11, 93, 30, 0.12);
}

.code-input {
  font-size: 20px;
  text-align: center;
  letter-spacing: 5px;
  font-weight: 700;
  color: #0f172a;
}

.options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13px;
  margin-bottom: 20px;
}

.options label {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-weight: 500;
  color: #475569;
  margin: 0;
  cursor: pointer;
}

.options input[type="checkbox"] {
  width: auto;
  accent-color: #0B5D1E;
}

.options a {
  color: #0B5D1E;
  text-decoration: none;
  font-weight: 600;
  transition: color 0.2s;
}

.options a:hover {
  color: #063B16;
  text-decoration: underline;
}

button {
  width: 100%;
  padding: 14px;
  border: none;
  border-radius: 8px;
  background: #0B5D1E;
  color: white;
  font-weight: 700;
  font-size: 15px;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 6px rgba(11, 93, 30, 0.2);
}

button:hover:not(:disabled) {
  background: #063B16;
  transform: translateY(-1px);
  box-shadow: 0 6px 12px rgba(11, 93, 30, 0.3);
}

button:disabled {
  background: rgba(11, 93, 30, 0.5);
  cursor: not-allowed;
  box-shadow: none;
  transform: none;
}

.error-msg {
  color: #F44336;
  background: rgba(244, 67, 54, 0.08);
  padding: 10px;
  border-radius: 6px;
  border: 1px solid rgba(244, 67, 54, 0.2);
  font-size: 12px;
  text-align: center;
  margin-bottom: 15px;
  font-weight: 600;
}

.success-msg {
  color: #4CAF50;
  background: rgba(76, 175, 80, 0.08);
  padding: 10px;
  border-radius: 6px;
  border: 1px solid rgba(76, 175, 80, 0.2);
  font-size: 12px;
  text-align: center;
  margin-bottom: 15px;
  font-weight: 600;
}

.back-link {
  text-align: center;
  margin-top: 20px;
}

.back-link a {
  color: #64748b;
  font-size: 13px;
  font-weight: 600;
  text-decoration: none;
  transition: color 0.2s;
}

.back-link a:hover {
  color: #0B5D1E;
}

.footer-login {
  margin-top: 35px;
  text-align: center;
  font-size: 11px;
  color: #94a3b8;
  border-top: 1px solid rgba(11, 93, 30, 0.1);
  padding-top: 20px;
}

.Cnx {
  margin-bottom: 8px;
  font-weight: 500;
  color: #64748b;
}

.Aide a {
  margin: 0 5px;
  color: #94a3b8;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s;
}

.Aide a:hover {
  color: #0B5D1E;
}

.page-footer {
  margin-top: 20px;
  color: rgba(255, 255, 255, 0.8);
  text-align: center;
  font-size: 12px;
  width: 100%;
}

.page-footer p {
  margin: 5px 0;
}
</style>