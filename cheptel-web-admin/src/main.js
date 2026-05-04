import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router/index.js'
import App from './App.vue'

import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap/dist/js/bootstrap.bundle.min.js'
import 'bootstrap-icons/font/bootstrap-icons.css'
import './assets/main.css'

sessionStorage.removeItem('access_token')
sessionStorage.removeItem('username')
sessionStorage.removeItem('user_role')
localStorage.removeItem('access_token')
localStorage.removeItem('username')
localStorage.removeItem('user_role')

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.mount('#app')