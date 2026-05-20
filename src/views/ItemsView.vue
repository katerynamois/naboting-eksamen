<script>
import GenstandPage from '@/components/Genstand/GenstandPage.vue'
import { getUserId } from '@/utils/session.js'

const API_BASE_URL = 'http://localhost:3002/api'

function getImageUrl(url) {
  if (url && url.startsWith('/uploads')) return `http://localhost:3002${url}`
  return 'https://placehold.co/300x200?text=Ingen+billede'
}

function toDisplayStatus(status) {
  if (status === 'available') return 'Tilgængelig'
  if (status === 'loaned') return 'Udlånt'
  if (status === 'inactive') return 'Inaktiv'
  return status
}

function toApiStatus(status) {
  if (status === 'Tilgængelig' || status === 'available') return 'available'
  if (status === 'Udlånt' || status === 'loaned') return 'loaned'
  if (status === 'Inaktiv' || status === 'inactive') return 'inactive'
  return status
}

export default {
  components: { GenstandPage },
  data() {
    return {
      items: [],
    }
  },
  mounted() {
    this.loadItems()
  },
  methods: {
    async loadItems() {
      try {
        const userId = getUserId()
        const response = await fetch(`${API_BASE_URL}/items?owner_id=${userId}`)
        if (!response.ok) throw new Error('Kunne ikke hente genstande')
        const data = await response.json()
        this.items = data.map(item => ({
          id: item.item_id,
          userId: item.owner_id,
          title: item.title,
          category: item.category,
          brand: item.brand,
          status: toDisplayStatus(item.status),
          images: [getImageUrl(item.image_url)],
          condition: item.item_condition,
          quantity: item.quantity,
          minimumLoanPeriod: item.minimum_loan_period,
          accessories: item.accessories || [],
        }))
      } catch (error) {
        console.error(error)
      }
    },
    async handleUpdateStatus({ id, status }) {
      try {
        const item = this.items.find(i => i.id === id)
        if (!item) return
        await fetch(`${API_BASE_URL}/items/${id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ ...item, status: toApiStatus(status) }),
        })
        await this.loadItems()
      } catch (error) {
        console.error(error)
      }
    },
    async handleDeleteItem(id) {
      try {
        await fetch(`${API_BASE_URL}/items/${id}`, { method: 'DELETE' })
        await this.loadItems()
      } catch (error) {
        console.error(error)
      }
    },
    async handleEditItem(updated) {
      try {
        await fetch(`${API_BASE_URL}/items/${updated.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(updated),
        })
        await this.loadItems()
      } catch (error) {
        console.error(error)
      }
    },
  },
}
</script>

<template>
  <GenstandPage
    :items="items"
    @go-to-page-one="$router.push('/opret-genstand')"
    @update-status="handleUpdateStatus"
    @delete-item="handleDeleteItem"
    @edit-item="handleEditItem"
  />
</template>
