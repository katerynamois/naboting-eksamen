<script>
import GenstandCard from '@/components/Genstand/GenstandCard.vue'
import GenstandDetail from '@/components/Genstand/GenstandDetail.vue'
import { getUserId } from '@/utils/session.js'

const API_BASE_URL = 'http://localhost:3002/api'

function getImageUrl(url) {
  if (url && url.startsWith('/uploads')) return `http://localhost:3002${url}`
  return 'https://placehold.co/300x200?text=Ingen+billede'
}

export default {
  name: 'BrowseView',
  components: { GenstandCard, GenstandDetail },
  data() {
    return {
      items: [],
      selectedItem: null,
    }
  },
  mounted() {
    this.loadItems()
  },
  methods: {
    async loadItems() {
      try {
        const res = await fetch(`${API_BASE_URL}/items`)
        if (!res.ok) return
        const data = await res.json()
        const userId = getUserId()
        this.items = data
          .filter(item => item.status === 'available')
          .filter(item => item.owner_id !== userId)
          .map(item => ({
            id: item.item_id,
            userId: item.owner_id,
            title: item.title,
            category: item.category,
            brand: item.brand,
            status: item.status,
            images: [item.image_url || 'https://placehold.co/64x64'],
            condition: item.item_condition,
            quantity: item.quantity,
            minimumLoanPeriod: item.minimum_loan_period,
            accessories: item.accessories || [],
          }))
      } catch {}
    },
    selectItem(id) {
      this.selectedItem = this.items.find(i => i.id === id)
    },
  },
}
</script>

<template>
  <main class="browse-page">

    <GenstandDetail
      v-if="selectedItem"
      :id="selectedItem.id"
      :title="selectedItem.title"
      :category="selectedItem.category"
      :brand="selectedItem.brand"
      :status="selectedItem.status"
      :image="selectedItem.images[0]"
      :condition="selectedItem.condition"
      :minimumLoanPeriod="selectedItem.minimumLoanPeriod"
      :quantity="selectedItem.quantity"
      :accessories="selectedItem.accessories"
      :is-owner="false"
      @gåTilbage="selectedItem = null"
    />

    <div v-else>
      <h1 class="browse-title">Find genstande</h1>

      <p v-if="items.length === 0" class="browse-empty">Ingen tilgængelige genstande.</p>

      <div class="browse-list">
        <GenstandCard
          v-for="item in items"
          :key="item.id"
          :id="item.id"
          :title="item.title"
          :category="item.category"
          :brand="item.brand"
          :status="'Tilgængelig'"
          :image="item.images[0]"
          @cardClicked="selectItem"
        />
      </div>
    </div>

  </main>
</template>

<style scoped>
.browse-page {
  background: var(--color-bg);
  min-height: 100vh;
  padding: var(--space-4);
}

.browse-title {
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 600;
  color: var(--color-neutral);
  margin-bottom: var(--space-4);
  text-align: center;
}

.browse-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.browse-empty {
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
  text-align: center;
  margin-top: var(--space-8);
}
</style>
