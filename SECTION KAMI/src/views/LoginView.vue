--!HTML--
<template>
  <div class="login-page">
    <div class="login-card">
      <div class="logo">
        <img src="./Imgs/logo.png" alt="Logo" class="logo-img">
        <h2>TraceDZ</h2>
      </div>

      <div v-if="showForgotPassword">
        <div class="subtitle">
          <strong>Récupération de compte</strong><br>
          Saisissez votre email pour réinitialiser votre mot de passe.
        </div>

        <form @submit.prevent="handleResetPassword">
          <div class="form-group">
            <label>Adresse Email</label>
            <input v-model="resetEmail" type="email" placeholder="exemple@domaine.com" required>
          </div>

          <button type="submit">Envoyer le lien de récupération</button>

          <div class="back-to-login">
            <a href="#" @click.prevent="showForgotPassword = false">← Retour à la connexion</a>
          </div>
        </form>
      </div>

      <div v-else>
        <div class="subtitle">
          <strong>Connexion Administrateur</strong><br>
          Gérez votre exploitation en toute simplicité.
        </div>

        <form @submit.prevent="login">
          <div class="form-group">
            <label>ID Utilisateur</label>
            <input v-model="username" type="text" placeholder="admin_1234">
          </div>

          <div class="form-group">
            <label>Mot de passe</label>
            <input v-model="password" type="password" placeholder="********">
          </div>

          <div class="options">
            <label>
              <input type="checkbox"> Rester connecté
            </label>
            <a href="#" @click.prevent="showForgotPassword = true">Mot de passe oublié ?</a>
          </div>

          <button type="submit">Se connecter →</button>
        </form>
      </div>

      <div class="footer-login">
        <div class="Cnx">Connexion sécurisée </div><br>
        <div class="Aide">
         <a href="#"> Aide </a>
         <a href="#"> Confidentialité </a>
         <a href="#"> Condition </a>
        </div>
      </div>
    </div>

    <footer class="page-footer">
      <p>© 2026 TraceDZ inc. Tous droits réservés.</p>
      <p><i class="fas fa-globe"></i> Français (FR)</p>
    </footer>
  </div>
</template>

<script>
export default {
  name: "LoginView",
  data() {
    return {
      username: "",
      password: ""
    }
  },
  methods: {
    login() {
      alert("Connexion avec : " + this.username)
    }
  }
}
</script>

<style scoped>
.login-page {
 /* On force la prise de tout l'écran sans aucune exception */
   position: fixed;
   top: 0;
   left: 0;
   width: 100vw;
   height: 100vh;

   display: flex;
   flex-direction: column;
   justify-content: center; /* Centre la carte verticalement */
   align-items: center;

   /* Image de fond */
   background-image: linear-gradient(rgba(0,0,0,0.15), rgba(0,0,0,0.15)),

                     url("https://lh3.googleusercontent.com/aida-public/AB6AXuDP24LrfFJMK8Rxhya97Wh9BcEn5Jtl9jH3T1aewE6lRRStf5Hzv8bOfJfMjoSs8U7DEA8mW-_r2UpoiIwBacjPYN8uxY3UJoG5g_CkZVCRbpC9G9MoDlmHdL6s-5zN9Jn2tlHxyuzKkjpizEbJenXZwSLnHSax9aU0mfrUtzqbjk5ehLlWfEfX4Bwz4tON8X0WEtyD8_akDdorqWO-o9Bbf2fLfXlCbOHxichkmMEJxP2F1V1XwbntyFdHmV5cPRKBV2NofHcxG1o");; /* Vérifie bien ton chemin */
   background-size: cover;
   background-position: center;
   background-repeat: no-repeat;
   font-family: 'Inter', sans-serif;
   margin: 0;
   padding: 0;
}

.login-card {
 width: 100%;
   max-width: 400px;
   background: rgba(255, 255, 255, 0.98);
   padding: 40px;
   border-radius: 16px;
   box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
   z-index: 2;
}

.logo {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  margin-bottom: 20px;
}

.logo-img {
  width: 30px;
  height: auto;
}

h2 {
  margin: 0;
  color: #2c3e50;
  font-size: 24px;
}

.subtitle {
  text-align: center;
  font-size: 14px;
  color: #6b7280;
  margin-bottom: 25px;
}

.subtitle strong {
 font-size: 18px;
 color:black;
}

.form-group {
  margin-bottom: 18px;
}

.form-group label {
  font-size: 13px;
  font-weight: 500;
  display: block;
  margin-bottom: 6px;
}

input {
  width: 100%;
  padding: 10px;
  border-radius: 8px;
  border: 1px solid #d1d5db;
}

input:focus {
  border-color: #22c55e;
  outline: none;
  box-shadow: 0 0 0 3px rgba(34,197,94,0.2);
}

.options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13px;
  margin-bottom: 18px;
}

.options label {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-weight: normal;
  margin: 0;
}

.options input[type="checkbox"] {
 width: auto; }

.options a {
  color: #11D432;
  text-decoration: none;
}

button {
  width: 100%;
  padding: 12px;
  border: none;
  border-radius: 8px;
  background: #11D432;
  color: white;
  font-weight: 600;
  cursor: pointer;
}

button:hover {
  background: #1FF043;
}

.footer-login {
  margin-top: 35px;
  text-align: center;
  font-size: 11px;
  color: #9ca3af;
}

.Cnx {
 margin-bottom: 1px;
 }

.Aide a {
 margin-right: 5px;
}

.page-footer {
margin-top: 5px;

color: rgba(255, 255, 255, 0.9);

text-align: center;

font-size: 12px;

width: 100%
}

.back-to-login {
  text-align: center;
  margin-top: 20px;
  font-size: 13px;
}

.back-to-login a {
  color: #6b7280;
  text-decoration: none;
  transition: color 0.2s;
}

.back-to-login a:hover {
  color: #11D432;
}
</style>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const username = ref("")
const password = ref("")
const resetEmail = ref("") // Ajouté car il manquait pour le reset
const showForgotPassword = ref(false)

const login = () => {
  const SUPER_ADMIN_USER = "superadmin"
  const SUPER_ADMIN_PASS = "admin123"

  if (username.value === SUPER_ADMIN_USER && password.value === SUPER_ADMIN_PASS) {
    // Utilisation de la même clé que dans le router (index.js)
    localStorage.setItem('isAdminAuthenticated', 'true')
    localStorage.setItem('user_role', 'SUPER_ADMIN')

    // On peut aussi stocker le nom pour l'afficher dans le header plus tard
    localStorage.setItem('user_name', 'Administrateur TraceDZ')

    router.push('/dashboard')
  } else {
    alert("Identifiants incorrects. Accès réservé au Superadmin.")
  }
}

const handleResetPassword = () => {
  if (resetEmail.value) {
    alert("Un email de récupération a été envoyé à : " + resetEmail.value)
    showForgotPassword.value = false
  } else {
    alert("Veuillez saisir une adresse email valide.")
  }
}

</script>


