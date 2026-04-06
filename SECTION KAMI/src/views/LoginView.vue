--!HTML--
<template>
  <div class="login-page">
    <div class="login-card">

      <div class="logo">
        <img src="./Imgs/logo.png" alt="Logo" class="logo-img">
        <h2>TraceDZ</h2>
      </div>

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
            <input type="checkbox">
            Rester connecté
          </label>
          <a href="#">Mot de passe oublié ?</a>
        </div>

        <button type="submit">Se connecter →</button>
      </form>

      <div class="footer-login">
        <div class="Cnx">Connexion sécurisée par cryptage 256-bit</div><br>
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

</style>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const username = ref("")
const password = ref("")

const login = () => {
  // 1. Définition des utilisateurs de test
  const users = {
    super: { user: "superadmin", pass: "admin123", role: "SUPER_ADMIN" },
    ferme: { user: "adminferme", pass: "ferme123", role: "FARM_ADMIN" }
  }

  // 2. Logique de vérification
  if (username.value === users.super.user && password.value === users.super.pass) {
    // Sauvegarder le rôle pour que l'interface sache quoi afficher
    localStorage.setItem('user_role', 'SUPER_ADMIN');
    localStorage.setItem('user_name', 'Super Administrateur');

    alert("Bienvenue Super Admin ! Redirection vers la supervision nationale.");
    router.push('/dashboard');

  } else if (username.value === users.ferme.user && password.value === users.ferme.pass) {
    localStorage.setItem('user_role', 'FARM_ADMIN');
    localStorage.setItem('user_name', 'Admin Oran');

    alert("Connexion réussie : Gestion de ferme activée.");
    router.push('/farm-dashboard');

  } else {
    alert("Identifiants incorrects. Essayez 'superadmin' ou 'adminferme'.");
  }
}
</script>


