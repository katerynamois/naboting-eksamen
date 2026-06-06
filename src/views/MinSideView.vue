<script>
import { getUserId, getSession } from '@/utils/session.js'

const API_BASE_URL = 'http://localhost:3002/api'

export default {
  name: 'MinSideView',
  data() {
    return {
      activeTab: 'ejer',
      ownerLoans: [],
      borrowerLoans: [],
      selectedLoan: null,
      showLoanDialog: false,
      itemQuery: '',
      allItems: [],
      showResults: false,
    }
  },
  computed: {
    firstName() { return getSession()?.firstName || '' },
    pendingOwnerLoans()     { return this.ownerLoans.filter(l => l.status === 'pending') },
    activeOwnerLoans()      { return this.ownerLoans.filter(l => l.status === 'active') },
    pendingBorrowerLoans()  { return this.borrowerLoans.filter(l => l.status === 'pending') },
    activeBorrowerLoans()   { return this.borrowerLoans.filter(l => l.status === 'active') },
    rejectedBorrowerLoans() { return this.borrowerLoans.filter(l => l.status === 'rejected') },
    completedBorrowerLoans(){ return this.borrowerLoans.filter(l => l.status === 'completed') },
    itemResults() {
      const q = this.itemQuery.toLowerCase().trim()
      if (!q) return []
      return this.allItems.filter(i =>
        (i.title || '').toLowerCase().includes(q) ||
        (i.category || '').toLowerCase().includes(q) ||
        (i.brand || '').toLowerCase().includes(q)
      ).slice(0, 6)
    },
  },
  mounted() {
    this.fetchLoans()
    this.fetchAllItems()
  },
  methods: {
    async fetchAllItems() {
      try {
        const res = await fetch(`${API_BASE_URL}/items`)
        if (res.ok) this.allItems = await res.json()
      } catch {}
    },
    hideResults() {
      setTimeout(() => { this.showResults = false }, 150)
    },
    goToItem(item) {
      this.itemQuery = ''
      this.showResults = false
      this.$router.push('/find-genstande?item=' + item.item_id)
    },
    async fetchLoans() {
      const userId = getUserId()
      if (!userId) return
      try {
        const [ownerRes, borrowerRes] = await Promise.all([
          fetch(`${API_BASE_URL}/loans/owner/${userId}`),
          fetch(`${API_BASE_URL}/loans/borrower/${userId}`),
        ])
        if (ownerRes.ok)    this.ownerLoans    = await ownerRes.json()
        if (borrowerRes.ok) this.borrowerLoans = await borrowerRes.json()
      } catch {}
    },
    openLoan(loan) {
      this.selectedLoan = loan
      this.showLoanDialog = true
    },
    async updateLoanStatus(loan, newStatus) {
      try {
        const res = await fetch(`${API_BASE_URL}/loans/${loan.loan_id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ ...loan, status: newStatus }),
        })
        if (res.ok) {
          await this.fetchLoans()
          this.showLoanDialog = false
        }
      } catch {}
    },
  },
}
</script>

<template>
  <main class="minside-page">

    <h1 class="minside-title">{{ firstName }}</h1>

    <div v-if="pendingOwnerLoans.length > 0" class="notify-bar" @click="activeTab = 'ejer'">
      <v-icon size="18" color="white">mdi-bell</v-icon>
      <span>{{ pendingOwnerLoans.length }} {{ pendingOwnerLoans.length === 1 ? 'ny låneforespørgsel' : 'nye låneforespørgsler' }} venter</span>
    </div>

    <div class="search-wrapper">
      <v-icon class="search-icon" size="18">mdi-magnify</v-icon>
      <input
        v-model="itemQuery"
        class="search-input"
        type="text"
        placeholder="Søg efter genstand…"
        @focus="showResults = true"
        @blur="hideResults"
      />
      <div v-if="showResults && itemResults.length" class="search-results">
        <button
          v-for="item in itemResults"
          :key="item.item_id"
          class="search-result"
          @mousedown.prevent="goToItem(item)"
        >
          <span class="result-title">{{ item.title }}</span>
          <span class="result-meta">{{ item.category }}</span>
        </button>
      </div>
      <p v-if="showResults && itemQuery.length > 1 && itemResults.length === 0" class="search-no-results">
        Ingen genstande fundet
      </p>
    </div>

    <div class="tab-toggle" role="tablist">
      <button class="tab-btn" :class="{ 'tab-btn--active': activeTab === 'ejer' }" role="tab" @click="activeTab = 'ejer'">Som ejer</button>
      <button class="tab-btn" :class="{ 'tab-btn--active': activeTab === 'lejer' }" role="tab" @click="activeTab = 'lejer'">Som lejer</button>
    </div>

    <!-- Som ejer -->
    <template v-if="activeTab === 'ejer'">

      <div class="section">
        <div class="section-header">
          <h2 class="section-title">Nye anmodninger</h2>
          <RouterLink v-if="pendingOwnerLoans.length > 3" to="/indbakke" class="see-all">Se alle <v-icon size="14">mdi-chevron-right</v-icon></RouterLink>
        </div>
        <p v-if="pendingOwnerLoans.length === 0" class="empty">Ingen nye anmodninger</p>
        <article v-for="loan in pendingOwnerLoans.slice(0, 3)" :key="loan.loan_id" class="card" @click="openLoan(loan)">
          <span class="card-name">{{ loan.borrower_first_name }} {{ loan.borrower_last_name }}</span>
          <span class="card-meta">{{ loan.item_title }}</span>
        </article>
      </div>

      <div class="section">
        <div class="section-header">
          <h2 class="section-title">Kommende aftaler</h2>
          <RouterLink v-if="activeOwnerLoans.length > 3" to="/indbakke" class="see-all">Se alle <v-icon size="14">mdi-chevron-right</v-icon></RouterLink>
        </div>
        <p v-if="activeOwnerLoans.length === 0" class="empty">Ingen kommende aftaler</p>
        <article v-for="loan in activeOwnerLoans.slice(0, 3)" :key="loan.loan_id" class="card" @click="openLoan(loan)">
          <span class="card-name">{{ loan.item_title }}</span>
          <span class="card-meta">{{ loan.borrower_first_name }} · {{ loan.start_date ? new Date(loan.start_date).toLocaleDateString('da-DK') : '' }}</span>
        </article>
      </div>

    </template>

    <!-- Som lejer -->
    <template v-else>

      <div class="section">
        <div class="section-header">
          <h2 class="section-title">Afventer svar</h2>
          <RouterLink v-if="pendingBorrowerLoans.length > 3" to="/indbakke" class="see-all">Se alle <v-icon size="14">mdi-chevron-right</v-icon></RouterLink>
        </div>
        <p v-if="pendingBorrowerLoans.length === 0" class="empty">Ingen afventende anmodninger</p>
        <article v-for="loan in pendingBorrowerLoans.slice(0, 3)" :key="loan.loan_id" class="card" @click="openLoan(loan)">
          <div class="card-info">
            <span class="card-name">{{ loan.item_title }}</span>
            <span class="card-meta">{{ loan.owner_first_name }} {{ loan.owner_last_name }}</span>
          </div>
          <span class="badge badge--pending">Afventer</span>
        </article>
      </div>

      <div class="section">
        <div class="section-header">
          <h2 class="section-title">Godkendte lån</h2>
          <RouterLink v-if="activeBorrowerLoans.length > 3" to="/indbakke" class="see-all">Se alle <v-icon size="14">mdi-chevron-right</v-icon></RouterLink>
        </div>
        <p v-if="activeBorrowerLoans.length === 0" class="empty">Ingen godkendte lån</p>
        <article v-for="loan in activeBorrowerLoans.slice(0, 3)" :key="loan.loan_id" class="card" @click="openLoan(loan)">
          <div class="card-info">
            <span class="card-name">{{ loan.item_title }}</span>
            <span class="card-meta">{{ loan.start_date ? new Date(loan.start_date).toLocaleDateString('da-DK') : 'Ingen dato' }}</span>
          </div>
          <span class="badge badge--active">Godkendt</span>
        </article>
      </div>

      <div class="section">
        <div class="section-header">
          <h2 class="section-title">Afviste anmodninger</h2>
          <RouterLink v-if="rejectedBorrowerLoans.length > 3" to="/indbakke" class="see-all">Se alle <v-icon size="14">mdi-chevron-right</v-icon></RouterLink>
        </div>
        <p v-if="rejectedBorrowerLoans.length === 0" class="empty">Ingen afviste anmodninger</p>
        <article v-for="loan in rejectedBorrowerLoans.slice(0, 3)" :key="loan.loan_id" class="card" @click="openLoan(loan)">
          <div class="card-info">
            <span class="card-name">{{ loan.item_title }}</span>
            <span class="card-meta">{{ loan.owner_first_name }} {{ loan.owner_last_name }}</span>
          </div>
          <span class="badge badge--rejected">Afvist</span>
        </article>
      </div>

      <div v-if="completedBorrowerLoans.length" class="section">
        <div class="section-header">
          <h2 class="section-title">Afsluttede lån</h2>
          <RouterLink v-if="completedBorrowerLoans.length > 3" to="/indbakke" class="see-all">Se alle <v-icon size="14">mdi-chevron-right</v-icon></RouterLink>
        </div>
        <article v-for="loan in completedBorrowerLoans.slice(0, 3)" :key="loan.loan_id" class="card" @click="openLoan(loan)">
          <div class="card-info">
            <span class="card-name">{{ loan.item_title }}</span>
            <span class="card-meta">{{ loan.owner_first_name }} {{ loan.owner_last_name }}</span>
          </div>
          <span class="badge badge--completed">Afsluttet</span>
        </article>
      </div>

    </template>

    <!-- Lån-dialog -->
    <v-dialog v-model="showLoanDialog" max-width="400" rounded="lg">
      <div v-if="selectedLoan" class="loan-dialog">

        <div class="loan-dialog-header">
          <p class="loan-dialog-category">{{ selectedLoan.status === 'pending' ? 'Ny anmodning' : 'Aktiv aftale' }}</p>
          <h2 class="loan-dialog-title">{{ selectedLoan.item_title }}</h2>
        </div>

        <div class="loan-dialog-body">
          <div v-if="selectedLoan.borrower_first_name" class="loan-dialog-row">
            <span class="loan-dialog-label">Låner</span>
            <span class="loan-dialog-value">{{ selectedLoan.borrower_first_name }} {{ selectedLoan.borrower_last_name }}</span>
          </div>
          <div v-if="selectedLoan.owner_first_name" class="loan-dialog-row">
            <span class="loan-dialog-label">Ejer</span>
            <span class="loan-dialog-value">{{ selectedLoan.owner_first_name }} {{ selectedLoan.owner_last_name }}</span>
          </div>
          <div v-if="selectedLoan.start_date" class="loan-dialog-row">
            <span class="loan-dialog-label">Fra</span>
            <span class="loan-dialog-value">{{ new Date(selectedLoan.start_date).toLocaleDateString('da-DK') }}</span>
          </div>
          <div v-if="selectedLoan.end_date" class="loan-dialog-row">
            <span class="loan-dialog-label">Til</span>
            <span class="loan-dialog-value">{{ new Date(selectedLoan.end_date).toLocaleDateString('da-DK') }}</span>
          </div>
          <div v-if="selectedLoan.message" class="loan-dialog-row loan-dialog-row--message">
            <span class="loan-dialog-label">Besked</span>
            <span class="loan-dialog-value">{{ selectedLoan.message }}</span>
          </div>
        </div>

        <div class="loan-dialog-actions">
          <template v-if="selectedLoan.status === 'pending'">
            <button class="loan-btn loan-btn--reject" @click="updateLoanStatus(selectedLoan, 'rejected')">Afvis</button>
            <button class="loan-btn loan-btn--approve" @click="updateLoanStatus(selectedLoan, 'active')">Godkend</button>
          </template>
          <template v-else-if="selectedLoan.status === 'active'">
            <button class="loan-btn loan-btn--approve" @click="updateLoanStatus(selectedLoan, 'completed')">Afslut lån</button>
          </template>
          <button class="loan-btn loan-btn--close" @click="showLoanDialog = false">Luk</button>
        </div>

      </div>
    </v-dialog>

  </main>
</template>

<style scoped>
.minside-page {
  background: var(--color-bg);
  min-height: 100vh;
  padding: var(--space-4);
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.minside-title {
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 700;
  color: var(--color-neutral);
  text-align: center;
  margin: 0;
}

.notify-bar {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  background: var(--color-primary);
  color: #ffffff;
  border-radius: var(--radius-lg);
  padding: 12px var(--space-4);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 600;
  cursor: pointer;
}

.search-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 14px;
  color: var(--color-secondary) !important;
  pointer-events: none;
}

.search-input {
  width: 100%;
  min-height: 46px;
  padding: 0 var(--space-3) 0 42px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-full);
  font-family: var(--font-body);
  font-size: var(--text-body);
  color: var(--color-neutral);
  outline: none;
  box-sizing: border-box;
}

.search-input::placeholder { color: var(--color-secondary); }
.search-input:focus { border-color: var(--color-primary); }

.search-results {
  position: absolute;
  top: calc(100% + 6px);
  left: 0;
  right: 0;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  box-shadow: 0 4px 16px rgba(0,0,0,0.10);
  z-index: 50;
  overflow: hidden;
}

.search-result {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding: 12px var(--space-4);
  background: transparent;
  border: none;
  border-bottom: 1px solid var(--color-border);
  cursor: pointer;
  text-align: left;
  font-family: var(--font-body);
}

.search-result:last-child { border-bottom: none; }
.search-result:hover { background: var(--color-bg); }

.result-title {
  font-size: var(--text-body);
  font-weight: 600;
  color: var(--color-neutral);
}

.result-meta {
  font-size: var(--text-label);
  color: var(--color-secondary);
}

.search-no-results {
  position: absolute;
  top: calc(100% + 6px);
  left: 0;
  right: 0;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 14px var(--space-4);
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
  text-align: center;
  z-index: 50;
}

.tab-toggle {
  display: grid;
  grid-template-columns: 1fr 1fr;
  background: var(--color-surface);
  border-radius: var(--radius-full);
  padding: 4px;
}

.tab-btn {
  min-height: 44px;
  border: none;
  border-radius: var(--radius-full);
  background: transparent;
  color: var(--color-secondary);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s, color 0.15s;
}

.tab-btn--active {
  background: var(--color-primary);
  color: #ffffff;
}

.section {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.section-title {
  margin: 0;
  font-family: var(--font-display);
  font-size: var(--text-h2);
  font-weight: 700;
  color: var(--color-neutral);
}

.see-all {
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
  text-decoration: none;
}

.empty {
  margin: var(--space-4) auto;
  color: var(--color-secondary);
  font-family: var(--font-body);
  font-size: var(--text-body);
  font-style: italic;
  text-align: center;
}

.card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: var(--space-3) var(--space-4);
  cursor: pointer;
  transition: border-color 0.12s, box-shadow 0.12s;
}

.card:hover {
  border-color: var(--color-primary);
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.card-name {
  font-family: var(--font-body);
  font-size: var(--text-body);
  font-weight: 600;
  color: var(--color-neutral);
}

.card-meta {
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
}

.card-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.badge {
  font-family: var(--font-body);
  font-size: 12px;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: var(--radius-full);
  white-space: nowrap;
}

.badge--pending   { background: #fff3cd; color: #856404; }
.badge--active    { background: #d1e7dd; color: #0a3622; }
.badge--rejected  { background: #f8d7da; color: #842029; }
.badge--completed { background: #e2e8f0; color: #475569; }

.loan-dialog {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.loan-dialog-header {
  background: var(--color-bg);
  padding: 20px 24px 18px;
  border-bottom: 1px solid var(--color-border);
}

.loan-dialog-category {
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 600;
  color: var(--color-primary);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  margin: 0 0 4px;
}

.loan-dialog-title {
  font-family: var(--font-display);
  font-size: var(--text-h2);
  font-weight: 700;
  color: var(--color-neutral);
  margin: 0;
}

.loan-dialog-body {
  padding: 16px 24px;
  display: flex;
  flex-direction: column;
}

.loan-dialog-row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  padding: 10px 0;
  border-bottom: 1px solid var(--color-border);
  font-family: var(--font-body);
  font-size: var(--text-body);
}

.loan-dialog-row:last-child { border-bottom: none; }

.loan-dialog-row--message {
  align-items: flex-start;
  gap: var(--space-4);
}

.loan-dialog-label {
  color: var(--color-secondary);
  font-size: var(--text-label);
  font-weight: 600;
  flex-shrink: 0;
}

.loan-dialog-value {
  color: var(--color-neutral);
  text-align: right;
}

.loan-dialog-actions {
  display: flex;
  gap: var(--space-2);
  padding: 16px 24px;
  border-top: 1px solid var(--color-border);
  justify-content: flex-end;
}

.loan-btn {
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 700;
  padding: 10px 20px;
  border-radius: var(--radius-md);
  border: none;
  cursor: pointer;
  min-height: 44px;
  transition: opacity 0.15s;
}

.loan-btn:hover { opacity: 0.85; }

.loan-btn--approve {
  background: var(--color-primary);
  color: #fff;
}

.loan-btn--reject {
  background: var(--color-bg);
  color: var(--color-accent);
  border: 1.5px solid var(--color-accent);
}

.loan-btn--close {
  background: transparent;
  color: var(--color-secondary);
  margin-left: auto;
}
</style>
