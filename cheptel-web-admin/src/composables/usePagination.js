import { ref, computed } from 'vue'

export function usePagination(items, defaultPerPage = 10) {
    const currentPage = ref(1)
    const perPage = ref(defaultPerPage)

    const totalPages = computed(() =>
        Math.max(1, Math.ceil(items.value.length / perPage.value))
    )

    const paginatedItems = computed(() => {
        const start = (currentPage.value - 1) * perPage.value
        return items.value.slice(start, start + perPage.value)
    })

    const from = computed(() => {
        if (items.value.length === 0) return 0
        return (currentPage.value - 1) * perPage.value + 1
    })

    const to = computed(() =>
        Math.min(currentPage.value * perPage.value, items.value.length)
    )

    const visiblePages = computed(() => {
        const pages = []
        const start = Math.max(1, currentPage.value - 2)
        const end = Math.min(totalPages.value, currentPage.value + 2)
        for (let i = start; i <= end; i++) {
            pages.push(i)
        }
        return pages
    })

    function goToPage(page) {
        if (page >= 1 && page <= totalPages.value) {
            currentPage.value = page
        }
    }

    function changePerPage(newPerPage) {
        perPage.value = newPerPage
        currentPage.value = 1
    }

    return {
        currentPage,
        perPage,
        totalPages,
        paginatedItems,
        from,
        to,
        visiblePages,
        goToPage,
        changePerPage
    }
}