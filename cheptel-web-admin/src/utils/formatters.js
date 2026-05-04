export function formatDate(dateStr) {
    if (!dateStr) return '—'

    try {
        const date = new Date(dateStr)
        return date.toLocaleDateString('fr-FR', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        })
    } catch {
        return dateStr
    }
}

export function formatDateTime(dateStr) {
    if (!dateStr) return '—'

    try {
        const date = new Date(dateStr)
        return date.toLocaleString('fr-FR', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        })
    } catch {
        return dateStr
    }
}

export function formatSpecies(species) {
    const map = {
        OVIN: 'Ovin',
        BOVIN: 'Bovin',
        CAPRIN: 'Caprin',
        EQUIN: 'Équin'
    }
    return map[species] || species
}

export function formatRole(role) {
    const map = {
        FERMIER: 'Fermier',
        VETERINAIRE: 'Vétérinaire',
        CONTROLEUR: 'Contrôleur',
        ADMIN: 'Administrateur'
    }
    return map[role] || role
}

export function formatStatus(status) {
    const map = {
        ACTIVE: 'Actif',
        SOLD: 'Vendu',
        DEAD: 'Décédé',
        SLAUGHTERED: 'Abattu',
        QUARANTINED: 'Quarantaine',
        LOST: 'Perdu',
        PENDING: 'En attente',
        IN_REVIEW: 'En cours',
        RESOLVED: 'Résolu',
        REJECTED: 'Rejeté'
    }
    return map[status] || status
}

export function getStatusClass(status) {
    const map = {
        ACTIVE: 'badge-active',
        RESOLVED: 'badge-resolved',
        PENDING: 'badge-pending',
        REJECTED: 'badge-inactive',
        DEAD: 'badge-inactive',
        SOLD: 'badge-info',
        CRITICAL: 'badge-critical',
        WARNING: 'badge-warning',
        INFO: 'badge-info'
    }
    return map[status] || 'badge-info'
}

export function getRoleBadge(role) {
    const map = {
        FERMIER: 'badge bg-success',
        VETERINAIRE: 'badge bg-primary',
        CONTROLEUR: 'badge bg-warning text-dark',
        ADMIN: 'badge bg-danger'
    }
    return map[role] || 'badge bg-secondary'
}