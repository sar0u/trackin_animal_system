<template>
  <div class="chart-container">
    <h6 class="fw-bold mb-3">
      <i class="bi bi-geo-alt-fill me-2 text-success"></i>
      Localisation des Fermes
    </h6>

    <div
        ref="mapEl"
        style="height:400px;border-radius:14px;overflow:hidden;"
    ></div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick } from 'vue'

const props = defineProps({
  farms: {
    type: Array,
    default: () => []
  }
})

const mapEl = ref(null)
let map = null
let L = null

onMounted(async () => {
  try {
    L = await import('leaflet')
    await import('leaflet/dist/leaflet.css')
    await nextTick()
    initMap()
  } catch (e) {
    console.error('Erreur Leaflet :', e)
  }
})

watch(
    () => props.farms,
    () => {
      if (map && L) addMarkers()
    },
    { deep: true }
)

function initMap() {
  if (!mapEl.value || !L) return

  map = L.default.map(mapEl.value).setView([28.0, 2.0], 5)

  L.default.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap'
  }).addTo(map)

  addMarkers()

  setTimeout(() => {
    if (map) map.invalidateSize()
  }, 300)
}

function addMarkers() {
  if (!map || !L) return

  map.eachLayer(layer => {
    if (layer instanceof L.default.Marker) {
      map.removeLayer(layer)
    }
  })

  const valid = (props.farms || []).filter(
      f => f.latitude != null && f.longitude != null &&
          !isNaN(f.latitude) && !isNaN(f.longitude)
  )

  valid.forEach(farm => {
    const icon = L.default.divIcon({
      className: '',
      html: `<div style="background:#0B5D1E;color:white;width:32px;height:32px;
        border-radius:50%;display:flex;align-items:center;justify-content:center;
        border:2px solid white;box-shadow:0 2px 6px rgba(0,0,0,0.3);font-size:15px;">
        <i class="bi bi-house-fill"></i></div>`,
      iconSize: [32, 32],
      iconAnchor: [16, 32],
      popupAnchor: [0, -34]
    })

    L.default.marker([Number(farm.latitude), Number(farm.longitude)], { icon })
        .addTo(map)
        .bindPopup(`
        <div style="min-width:180px;">
          <strong style="color:#0B5D1E;">${farm.name || ''}</strong><br>
          <span>Propriétaire : ${farm.ownerName || '—'}</span><br>
          <span>Wilaya : ${farm.wilaya || '—'}</span><br>
          <span>Animaux : ${farm.totalAnimaux || 0}</span>
        </div>
      `)
  })

  if (valid.length > 0) {
    const bounds = L.default.latLngBounds(
        valid.map(f => [Number(f.latitude), Number(f.longitude)])
    )
    map.fitBounds(bounds, { padding: [30, 30] })
  }
}
</script>