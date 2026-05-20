<script>
import { getUserId } from '@/utils/session.js'

const API_BASE_URL = 'http://localhost:3001/api'

export default {
  name: 'LoanInboxView',
  data() {
    return {
      loans: [],
      loading: true,
      error: '',
    }
  },
  computed: {
    ownerId() {
      return getUserId()
    },
  },
  mounted() {
    this.fetchLoans()
  },
  methods: {
    async fetchLoans() {
      if (!this.ownerId) {
        this.loading = false
        return
      }
      try {
        const res = await fetch(`${API_BASE_URL}/loans/owner/${this.ownerId}`)
        if (res.ok) {
          this.loans = await res.json()
        }
      } catch {
        this.error = 'Kunne ikke hente anmodninger.'
      } finally {
        this.loading = false
      }
    },
    statusLabel(status) {
      if (status === 'pending') return 'Afventer'
      if (status === 'active') return 'Godkendt'
      if (status === 'rejected') return 'Afvist'
      return status
    },
    async updateStatus(loan, newStatus) {
      try {
        const res = await fetch(`${API_BASE_URL}/loans/${loan.loan_id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ ...loan, status: newStatus }),
        })
        if (res.ok) {
          const updated = await res.json()
          const index = this.loans.findIndex(l => l.loan_id === loan.loan_id)
          if (index !== -1) this.loans[index] = updated
        }
      } catch {
        this.error = 'Kunne ikke opdatere status.'
      }
    },
    approve(loan) {
      this.updateStatus(loan, 'active')
    },
    reject(loan) {
      this.updateStatus(loan, 'rejected')
    },
  },
}
</script>

<template>
  <main>
    <h2>Indkomne anmodninger</h2>

    <p v-if="!ownerId">Du skal være logget ind for at se din indbakke.</p>
    <p v-else-if="loading">Henter anmodninger...</p>
    <p v-else-if="error">{{ error }}</p>
    <p v-else-if="loans.length === 0">Ingen anmodninger endnu.</p>

    <article v-for="loan in loans" :key="loan.loan_id">
      <h3>{{ loan.borrower_first_name }} {{ loan.borrower_last_name }}</h3>
      <p><strong>Genstand:</strong> {{ loan.item_title }}</p>
      <p><strong>Periode:</strong> {{ loan.start_date }} - {{ loan.end_date }}</p>
      <p v-if="loan.message"><strong>Besked:</strong> {{ loan.message }}</p>
      <p><strong>Status:</strong> {{ statusLabel(loan.status) }}</p>
      <template v-if="loan.status === 'pending'">
        <button @click="approve(loan)">Godkend</button>
        <button @click="reject(loan)">Afvis</button>
      </template>
    </article>
  </main>
</template>

<style scoped>
</style>
