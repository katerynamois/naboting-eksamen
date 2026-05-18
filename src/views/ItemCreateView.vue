<script>
import PageOne from '@/components/PageOne.vue'
import AddDetails from '@/components/AddDetails.vue'
import ConfirmItemScreen from '@/components/ConfirmItemScreen.vue'

const API_BASE_URL = 'http://localhost:3001/api'

export default {
  components: { PageOne, AddDetails, ConfirmItemScreen },
  data() {
    return {
      currentStep: 1,
      pageOneData: null,
      addDetailsData: null,
    }
  },
  methods: {
    goToAddDetails(data) {
      this.pageOneData = data
      this.currentStep = 2
    },
    handleSaveDetails(details) {
      this.addDetailsData = details
    },
    goToConfirmItem() {
      this.currentStep = 3
    },
    goBackFromConfirm() {
      this.currentStep = 2
    },
    goBackFromPageOne() {
      this.$router.push('/profil')
    },
    async handleCreateItem() {
      const d1 = this.pageOneData
      const d2 = this.addDetailsData
      const newItem = {
        owner_id: 1,
        title: d1.name,
        category: d1.category,
        brand: d1.brand || null,
        item_condition: d2.condition || null,
        quantity: d2.quantity || 1,
        minimum_loan_period: d2.minimumLoanPeriod || null,
        status: 'available',
        images: d1.images.length ? d1.images : ['https://placehold.co/64x64'],
        accessories: d2.extras || [],
      }

      try {
        const response = await fetch(`${API_BASE_URL}/items`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(newItem),
        })
        if (!response.ok) throw new Error('Kunne ikke oprette genstand')
        this.$router.push('/genstande')
      } catch (error) {
        console.error(error)
      }
    },
  },
}
</script>

<template>
  <div>
    <PageOne
      v-if="currentStep === 1"
      :currentStep="currentStep"
      @go-to-add-details="goToAddDetails"
      @go-back="goBackFromPageOne"
    />

    <AddDetails
      v-if="currentStep === 2"
      :currentStep="currentStep"
      @save-details="handleSaveDetails"
      @go-to-confirm-item="goToConfirmItem"
      @go-to-page-one="currentStep = 1"
    />

    <ConfirmItemScreen
      v-if="currentStep === 3"
      :currentStep="currentStep"
      :itemData="{ ...pageOneData, ...addDetailsData }"
      @goBack="goBackFromConfirm"
      @go-to-genstand-page="handleCreateItem"
    />
  </div>
</template>
