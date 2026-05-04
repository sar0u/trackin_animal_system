<template>
  <AdminLayout page-title="Paramètres Système">

    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h5 class="fw-bold mb-1">Paramètres d'administration</h5>
        <p class="text-muted small mb-0">
          Configuration fonctionnelle de la plateforme DZcheptel.
        </p>
      </div>

      <button class="btn btn-outline-success" @click="loadSettings">
        <i class="bi bi-arrow-clockwise me-2"></i>
        Actualiser
      </button>
    </div>

    <div v-if="loading" class="text-center py-5">
      <div class="spinner-border text-success"></div>
    </div>

    <div v-else>

      <SettingsSection title="Sécurité & sessions" icon="shield-lock">
        <SettingInput
            label="Durée session admin (minutes)"
            description="Durée maximale d'une session administrateur."
            v-model="settings.session_timeout_minutes"
            setting-key="session_timeout_minutes"
            @save="saveSetting"
        />

        <SettingInput
            label="Longueur minimale mot de passe"
            description="Nombre minimum de caractères."
            v-model="settings.password_min_length"
            setting-key="password_min_length"
            @save="saveSetting"
        />

        <SettingInput
            label="Tentatives connexion max"
            description="Nombre d'essais avant blocage temporaire."
            v-model="settings.max_login_attempts"
            setting-key="max_login_attempts"
            @save="saveSetting"
        />
      </SettingsSection>

      <SettingsSection title="Contrôle terrain" icon="clipboard-check">
        <SettingInput
            label="Écart toléré"
            description="Nombre d'animaux manquants tolérés."
            v-model="settings.control_tolerance_count"
            setting-key="control_tolerance_count"
            @save="saveSetting"
        />

        <SettingInput
            label="Pièces jointes min. constat"
            description="Nombre minimum de preuves exigées."
            v-model="settings.constat_min_attachments"
            setting-key="constat_min_attachments"
            @save="saveSetting"
        />

        <SettingInput
            label="Seuil alerte fraude"
            description="Nombre de constats avant signalement fort."
            v-model="settings.fraud_alert_threshold"
            setting-key="fraud_alert_threshold"
            @save="saveSetting"
        />
      </SettingsSection>

      <SettingsSection title="Sanitaire" icon="heart-pulse">
        <SettingInput
            label="Jours avant alerte vaccin"
            description="Délai avant expiration pour déclencher une alerte."
            v-model="settings.vaccination_alert_days"
            setting-key="vaccination_alert_days"
            @save="saveSetting"
        />

        <SettingInput
            label="Rappel visite vétérinaire"
            description="Délai avant prochaine visite vétérinaire."
            v-model="settings.veterinary_visit_alert_days"
            setting-key="veterinary_visit_alert_days"
            @save="saveSetting"
        />
      </SettingsSection>

      <SettingsSection title="Données & exports" icon="database">
        <SettingInput
            label="Rétention audit (jours)"
            description="Durée de conservation du journal d'audit."
            v-model="settings.audit_retention_days"
            setting-key="audit_retention_days"
            @save="saveSetting"
        />

        <SettingInput
            label="Format export par défaut"
            description="Format principal des exports administratifs."
            v-model="settings.export_default_format"
            setting-key="export_default_format"
            @save="saveSetting"
        />

        <SettingInput
            label="Limite API par minute"
            description="Nombre maximal de requêtes par minute."
            v-model="settings.api_rate_limit_per_minute"
            setting-key="api_rate_limit_per_minute"
            @save="saveSetting"
        />
      </SettingsSection>

      <SettingsSection title="Maintenance" icon="tools">
        <SettingInput
            label="Mode maintenance"
            description="0 = désactivé, 1 = activé."
            v-model="settings.maintenance_mode"
            setting-key="maintenance_mode"
            @save="saveSetting"
        />

        <SettingInput
            label="Sauvegarde automatique"
            description="0 = désactivée, 1 = activée."
            v-model="settings.auto_backup_enabled"
            setting-key="auto_backup_enabled"
            @save="saveSetting"
        />
      </SettingsSection>

      <div class="data-table mt-4">
        <div class="data-table-header">
          <span class="data-table-title">
            Paramètres enregistrés
          </span>
        </div>

        <div class="table-responsive">
          <table class="table mb-0">
            <thead>
            <tr>
              <th>CLÉ</th>
              <th>VALEUR</th>
              <th>DESCRIPTION</th>
              <th>MISE À JOUR</th>
            </tr>
            </thead>

            <tbody>
            <tr v-for="s in rawSettings" :key="s.id">
              <td class="fw-semibold">{{ s.settingKey }}</td>
              <td>{{ s.settingValue }}</td>
              <td>{{ s.description || '—' }}</td>
              <td>{{ formatDateTime(s.updatedAt) }}</td>
            </tr>
            </tbody>
          </table>
        </div>
      </div>

    </div>

    <div
        v-if="toast"
        class="position-fixed bottom-0 end-0 p-3"
        style="z-index:9999;"
    >
      <div class="toast show bg-success text-white">
        <div class="toast-body">
          {{ toast }}
        </div>
      </div>
    </div>

  </AdminLayout>
</template>

<script setup>


import {defineComponent, h, onMounted, ref} from "vue";
import {formatDateTime} from "../utils/formatters.js";
import {settingsApi} from "@/api/settingsApi.js";
import AdminLayout from "@/layouts/AdminLayout.vue";

const loading = ref(true)
const rawSettings = ref([])
const toast = ref('')

const settings = ref({
  session_timeout_minutes: '60',
  password_min_length: '6',
  max_login_attempts: '5',
  control_tolerance_count: '0',
  constat_min_attachments: '2',
  fraud_alert_threshold: '3',
  vaccination_alert_days: '30',
  veterinary_visit_alert_days: '7',
  audit_retention_days: '365',
  export_default_format: 'xlsx',
  api_rate_limit_per_minute: '120',
  maintenance_mode: '0',
  auto_backup_enabled: '1'
})

onMounted(() => {
  loadSettings()
})

async function loadSettings() {
  loading.value = true

  try {
    const res = await settingsApi.getAll()
    rawSettings.value = res.data

    res.data.forEach(s => {
      settings.value[s.settingKey] = s.settingValue
    })
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

async function saveSetting(key, value) {
  try {
    await settingsApi.update(key, value)
    toast.value = 'Paramètre mis à jour'
    setTimeout(() => (toast.value = ''), 2500)
    await loadSettings()
  } catch {
    alert('Erreur mise à jour paramètre')
  }
}

const SettingsSection = defineComponent({
  props: {
    title: String,
    icon: String
  },
  setup(props, { slots }) {
    return () =>
        h('div', { class: 'data-table mb-4' }, [
          h('div', { class: 'data-table-header' }, [
            h('span', { class: 'data-table-title' }, [
              h('i', { class: `bi bi-${props.icon} me-2 text-success` }),
              props.title
            ])
          ]),
          h('div', { class: 'p-4' }, [
            h('div', { class: 'row g-4' }, slots.default ? slots.default() : [])
          ])
        ])
  }
})

const SettingInput = defineComponent({
  props: {
    modelValue: String,
    label: String,
    description: String,
    settingKey: String
  },
  emits: ['update:modelValue', 'save'],
  setup(props, { emit }) {
    return () =>
        h('div', { class: 'col-md-4' }, [
          h('label', { class: 'form-label fw-semibold' }, props.label),
          h('div', { class: 'input-group' }, [
            h('input', {
              class: 'form-control',
              value: props.modelValue,
              onInput: e => emit('update:modelValue', e.target.value)
            }),
            h(
                'button',
                {
                  class: 'btn btn-success',
                  onClick: () => emit('save', props.settingKey, props.modelValue)
                },
                'Sauver'
            )
          ]),
          h('small', { class: 'text-muted' }, props.description)
        ])
  }
})
</script>