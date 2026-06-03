<script>
import { getUserId } from '@/utils/session.js'

const API_BASE_URL = 'http://localhost:3002/api'

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
    pendingLoans() {
      return this.loans.filter(l => l.status === 'pending')
    },
    activeLoans() {
      return this.loans.filter(l => l.status === 'active')
    },
    closedLoans() {
      return this.loans.filter(l => l.status === 'rejected' || l.status === 'completed')
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
      if (status === 'completed') return 'Afsluttet'
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
          if (index !== -1) this.loans.splice(index, 1, updated)
        }
      } catch {
        this.error = 'Kunne ikke opdatere status.'
      }
    },
    approve(loan) { this.updateStatus(loan, 'active') },
    reject(loan) { this.updateStatus(loan, 'rejected') },
    complete(loan) { this.updateStatus(loan, 'completed') },
  },
}
</script>

<template>
  <main class="inbox-page">
    <h1 class="inbox-title">Indbakke</h1>

    <p v-if="!ownerId" class="inbox-empty">Du skal være logget ind for at se din indbakke.</p>
    <p v-else-if="loading" class="inbox-empty">Henter anmodninger...</p>
    <p v-else-if="error" class="inbox-error">{{ error }}</p>
    <p v-else-if="loans.length === 0" class="inbox-empty">Ingen anmodninger endnu.</p>

    <template v-else>

      <section v-if="pendingLoans.length" class="inbox-section">
        <h2 class="inbox-section-title">Nye anmodninger</h2>
        <div class="inbox-list">
          <article v-for="loan in pendingLoans" :key="loan.loan_id" class="inbox-card">
            <div class="inbox-card-top">
              <div class="inbox-card-avatar">{{ (loan.borrower_first_name || '?').charAt(0).toUpperCase() }}</div>
              <div class="inbox-card-info">
                <p class="inbox-card-name">{{ loan.borrower_first_name }} {{ loan.borrower_last_name }}</p>
                <p class="inbox-card-item">{{ loan.item_title }}</p>
              </div>
              <span class="inbox-badge inbox-badge--pending">Afventer</span>
            </div>
            <div class="inbox-card-dates">
              <span class="inbox-date-label">Periode</span>
              <span class="inbox-date-value">
                {{ loan.start_date ? new Date(loan.start_date).toLocaleDateString('da-DK') : '—' }}
                –
                {{ loan.end_date ? new Date(loan.end_date).toLocaleDateString('da-DK') : '—' }}
              </span>
            </div>
            <p v-if="loan.message" class="inbox-message">{{ loan.message }}</p>
            <div class="inbox-actions">
              <button class="inbox-btn inbox-btn--reject" @click="reject(loan)">Afvis</button>
              <button class="inbox-btn inbox-btn--approve" @click="approve(loan)">Godkend</button>
            </div>
          </article>
        </div>
      </section>

      <section v-if="activeLoans.length" class="inbox-section">
        <h2 class="inbox-section-title">Aktive lån</h2>
        <div class="inbox-list">
          <article v-for="loan in activeLoans" :key="loan.loan_id" class="inbox-card">
            <div class="inbox-card-top">
              <div class="inbox-card-avatar">{{ (loan.borrower_first_name || '?').charAt(0).toUpperCase() }}</div>
              <div class="inbox-card-info">
                <p class="inbox-card-name">{{ loan.borrower_first_name }} {{ loan.borrower_last_name }}</p>
                <p class="inbox-card-item">{{ loan.item_title }}</p>
              </div>
              <span class="inbox-badge inbox-badge--active">Godkendt</span>
            </div>
            <div class="inbox-card-dates">
              <span class="inbox-date-label">Periode</span>
              <span class="inbox-date-value">
                {{ loan.start_date ? new Date(loan.start_date).toLocaleDateString('da-DK') : '—' }}
                –
                {{ loan.end_date ? new Date(loan.end_date).toLocaleDateString('da-DK') : '—' }}
              </span>
            </div>
            <p v-if="loan.message" class="inbox-message">{{ loan.message }}</p>
            <div class="inbox-actions">
              <button class="inbox-btn inbox-btn--complete" @click="complete(loan)">Afslut lån</button>
            </div>
          </article>
        </div>
      </section>

      <section v-if="closedLoans.length" class="inbox-section">
        <h2 class="inbox-section-title">Afsluttede</h2>
        <div class="inbox-list">
          <article v-for="loan in closedLoans" :key="loan.loan_id" class="inbox-card inbox-card--closed">
            <div class="inbox-card-top">
              <div class="inbox-card-avatar">{{ (loan.borrower_first_name || '?').charAt(0).toUpperCase() }}</div>
              <div class="inbox-card-info">
                <p class="inbox-card-name">{{ loan.borrower_first_name }} {{ loan.borrower_last_name }}</p>
                <p class="inbox-card-item">{{ loan.item_title }}</p>
              </div>
              <span class="inbox-badge" :class="loan.status === 'rejected' ? 'inbox-badge--rejected' : 'inbox-badge--completed'">
                {{ statusLabel(loan.status) }}
              </span>
            </div>
          </article>
        </div>
      </section>

    </template>
  </main>
</template>

<style scoped>
.inbox-page {
  background: var(--color-bg);
  min-height: 100vh;
  padding: var(--space-6) var(--space-4);
  max-width: 620px;
  margin: 0 auto;
  box-sizing: border-box;
}

.inbox-title {
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 700;
  color: var(--color-neutral);
  margin: 0 0 var(--space-6);
}

.inbox-empty {
  color: var(--color-secondary);
  font-family: var(--font-body);
  font-size: var(--text-body);
  font-style: italic;
  text-align: center;
  margin-top: var(--space-8);
}

.inbox-error {
  color: var(--color-accent);
  font-family: var(--font-body);
  font-size: var(--text-body);
  font-weight: 700;
}

.inbox-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.inbox-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: var(--space-4);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.inbox-card-top {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.inbox-card-avatar {
  width: 44px;
  height: 44px;
  border-radius: var(--radius-full);
  background: var(--color-primary);
  color: #ffffff;
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.inbox-card-info {
  flex: 1;
  min-width: 0;
}

.inbox-card-name {
  margin: 0 0 2px 0;
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 600;
  color: var(--color-neutral);
}

.inbox-card-item {
  margin: 0;
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
}

.inbox-badge {
  font-family: var(--font-body);
  font-size: 12px;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: var(--radius-full);
  white-space: nowrap;
  flex-shrink: 0;
}

.inbox-badge--pending { background: #fff3cd; color: #856404; }
.inbox-badge--active  { background: #d1e7dd; color: #0a3622; }
.inbox-badge--rejected { background: #f8d7da; color: #842029; }

.inbox-card-dates {
  display: flex;
  justify-content: space-between;
  background: var(--color-bg);
  border-radius: var(--radius-md);
  padding: var(--space-3) var(--space-4);
}

.inbox-date-label {
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 600;
  color: var(--color-secondary);
}

.inbox-date-value {
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-neutral);
}

.inbox-message {
  margin: 0;
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-neutral);
  background: var(--color-bg);
  border-radius: var(--radius-md);
  padding: var(--space-3) var(--space-4);
  line-height: 1.5;
}

.inbox-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-3);
  margin-top: var(--space-1);
}

.inbox-btn {
  min-height: 44px;
  border: none;
  border-radius: var(--radius-md);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 700;
  cursor: pointer;
}

.inbox-btn--approve {
  background: var(--color-primary);
  color: #ffffff;
}

.inbox-btn--reject {
  background: var(--color-surface);
  color: var(--color-accent);
  border: 1px solid var(--color-accent);
}

.inbox-btn--complete {
  background: var(--color-surface);
  color: var(--color-neutral);
  border: 1px solid var(--color-border);
}

.inbox-badge--completed {
  background: #e2e8f0;
  color: #475569;
}

.inbox-section {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  margin-bottom: var(--space-6);
}

.inbox-section-title {
  margin: 0;
  font-family: var(--font-display);
  font-size: var(--text-h2);
  font-weight: 700;
  color: var(--color-neutral);
}

.inbox-card--closed {
  opacity: 0.65;
}
</style>
