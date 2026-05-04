<template>
  <div class="d-flex align-items-center justify-content-center vh-100">
    <div class="text-center">
      <h1 class="display-1 fw-bold" style="color:#0B5D1E">404</h1>
      <h5 class="mb-3">Page introuvable</h5>
      <RouterLink to="/dashboard" class="btn btn-success">
        Retour au tableau de bord
      </RouterLink>
    </div>
  </div>
</template>

<script setup>
import { RouterLink } from 'vue-router'
</script>