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
      activeCategory: 'Alle',
    }
  },
  computed: {
    categories() {
      const cats = this.items.map(i => i.category).filter(Boolean)
      return ['Alle', ...new Set(cats)]
    },
    filteredItems() {
      if (this.activeCategory === 'Alle') return this.items
      return this.items.filter(i => i.category === this.activeCategory)
    },
  },
  mounted() {
    this.loadItems().then(async () => {
      const itemId = Number(this.$route.query.item)
      if (!itemId) return
      let found = this.items.find(i => i.id === itemId)
      if (!found) {
        try {
          const res = await fetch(`${API_BASE_URL}/items/${itemId}`)
          if (res.ok) {
            const item = await res.json()
            found = {
              id: item.item_id,
              userId: item.owner_id,
              title: item.title,
              category: item.category,
              brand: item.brand,
              status: item.status,
              images: [getImageUrl(item.image_url)],
              condition: item.item_condition,
              quantity: item.quantity,
              minimumLoanPeriod: item.minimum_loan_period,
              accessories: item.accessories || [],
            }
          }
        } catch {}
      }
      if (found) {
        found._isOwner = found.userId === getUserId()
        this.selectedItem = found
      }
    })
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
          .filter(item => userId === null || item.owner_id !== userId)
          .map(item => ({
            id: item.item_id,
            userId: item.owner_id,
            title: item.title,
            category: item.category,
            brand: item.brand,
            status: item.status,
            images: [getImageUrl(item.image_url)],
            condition: item.item_condition,
            quantity: item.quantity,
            minimumLoanPeriod: item.minimum_loan_period,
            accessories: item.accessories || [],
          }))
      } catch {}
    },
    selectItem(id) {
      const item = this.items.find(i => i.id === id)
      if (item) item._isOwner = false
      this.selectedItem = item
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
      :is-owner="selectedItem._isOwner || false"
      @gåTilbage="selectedItem = null"
    />

    <div v-else>
      <button class="back-btn" @click="$router.back()">
        <v-icon size="18">mdi-arrow-left</v-icon>
        Tilbage
      </button>
      <h1 class="browse-title">Find genstande</h1>

      <div class="filter-bar">
        <button
          v-for="cat in categories"
          :key="cat"
          class="filter-tab"
          :class="{ 'filter-tab--active': activeCategory === cat }"
          @click="activeCategory = cat"
        >
          {{ cat }}
        </button>
      </div>

      <p v-if="filteredItems.length === 0" class="browse-empty">Ingen tilgængelige genstande.</p>

      <div class="browse-list">
        <GenstandCard
          v-for="item in filteredItems"
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

.back-btn {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  background: none;
  border: none;
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 600;
  color: var(--color-neutral);
  cursor: pointer;
  padding: var(--space-2) 0;
  margin-bottom: var(--space-4);
}

.back-btn:hover {
  color: var(--color-primary);
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

.filter-bar {
  display: flex;
  gap: var(--space-2);
  overflow-x: auto;
  padding-bottom: var(--space-2);
  margin-bottom: var(--space-4);
  scrollbar-width: none;
}

.filter-bar::-webkit-scrollbar {
  display: none;
}

.filter-tab {
  flex-shrink: 0;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-full);
  padding: 6px 16px;
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 500;
  color: var(--color-secondary);
  cursor: pointer;
  white-space: nowrap;
}

.filter-tab--active {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: #ffffff;
  font-weight: 600;
}

.browse-empty {
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
  text-align: center;
  margin-top: var(--space-8);
}
</style>
