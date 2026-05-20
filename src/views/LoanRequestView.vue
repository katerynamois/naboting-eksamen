<script>
import { getUserId } from '@/utils/session.js'

const API_BASE_URL = 'http://localhost:3002/api'

export default {
  name: 'LoanRequestView',
  data() {
    return {
      currentStep: 1,
      startDate: '',
      endDate: '',
      message: '',
      itemTitle: '',
      submitted: false,
      submitting: false,
      error: '',
    }
  },
  computed: {
    itemId() {
      return this.$route.params.itemId
    },
    borrowerId() {
      return getUserId()
    },
  },
  mounted() {
    if (this.itemId) {
      this.fetchItemTitle()
    }
  },
  methods: {
    async fetchItemTitle() {
      try {
        const res = await fetch(`${API_BASE_URL}/items/${this.itemId}`)
        if (res.ok) {
          const item = await res.json()
          this.itemTitle = item.title
        }
      } catch {}
    },
    async submitRequest() {
      if (!this.borrowerId) {
        this.error = 'Du skal være logget ind for at sende en anmodning.'
        return
      }
      this.submitting = true
      this.error = ''
      try {
        const res = await fetch(`${API_BASE_URL}/loans`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            item_id: this.itemId,
            borrower_id: this.borrowerId,
            start_date: this.startDate || null,
            end_date: this.endDate || null,
            message: this.message,
            status: 'pending',
          }),
        })
        if (!res.ok) {
          this.error = 'Noget gik galt. Prøv igen.'
          return
        }
        this.submitted = true
      } catch {
        this.error = 'Kunne ikke forbinde til serveren.'
      } finally {
        this.submitting = false
      }
    },
  },
}
</script>

<template>
  <main>
    <h2>Anmodning om lån<span v-if="itemTitle"> — {{ itemTitle }}</span></h2>

    <div v-if="submitted">
      <p>Din anmodning er sendt! Ejeren vil kontakte dig.</p>
      <button @click="$router.push('/genstande')">Tilbage til genstande</button>
    </div>

    <template v-else>
      <section v-if="currentStep === 1">
        <h3>Vælg datoer</h3>
        <label for="start-date">Startdato:</label>
        <input type="date" id="start-date" v-model="startDate" />
        <label for="end-date">Slutdato:</label>
        <input type="date" id="end-date" v-model="endDate" />
        <button @click="currentStep = 2">Næste</button>
      </section>

      <section v-else-if="currentStep === 2">
        <h3>Tilføj en besked</h3>
        <textarea v-model="message" placeholder="Skriv en besked til ejeren..."></textarea>
        <button @click="currentStep = 1">Tilbage</button>
        <button @click="currentStep = 3">Næste</button>
      </section>

      <section v-else-if="currentStep === 3">
        <h3>Bekræft anmodning</h3>
        <p>Datoer: {{ startDate }} - {{ endDate }}</p>
        <p v-if="message">Besked: {{ message }}</p>
        <p v-if="error" style="color: red;">{{ error }}</p>
        <button @click="currentStep = 2">Tilbage</button>
        <button @click="submitRequest" :disabled="submitting">
          {{ submitting ? 'Sender...' : 'Send anmodning' }}
        </button>
      </section>
    </template>
  </main>
</template>

<style scoped>
</style>
