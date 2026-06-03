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
      minimumLoanPeriod: null,
      submitted: false,
      submitting: false,
      error: '',
      dateError: '',
    }
  },
  computed: {
    itemId() {
      return this.$route.params.itemId
    },
    borrowerId() {
      return getUserId()
    },
    today() {
      return new Date().toISOString().slice(0, 10)
    },
    selectedDays() {
      if (!this.startDate || !this.endDate) return null
      const start = new Date(this.startDate)
      const end = new Date(this.endDate)
      return Math.round((end - start) / (1000 * 60 * 60 * 24))
    },
    periodText() {
      if (this.selectedDays === null) return null
      return this.selectedDays === 1 ? '1 dag' : `${this.selectedDays} dage`
    },
    minPeriodText() {
      if (!this.minimumLoanPeriod) return null
      return this.minimumLoanPeriod === 1 ? '1 dag' : `${this.minimumLoanPeriod} dage`
    },
  },
  mounted() {
    if (this.itemId) {
      this.fetchItem()
    }
  },
  methods: {
    async fetchItem() {
      try {
        const res = await fetch(`${API_BASE_URL}/items/${this.itemId}`)
        if (res.ok) {
          const item = await res.json()
          this.itemTitle = item.title
          this.minimumLoanPeriod = item.minimum_loan_period || null
        }
      } catch {}
    },
    validateDates() {
      this.dateError = ''
      if (!this.startDate || !this.endDate) {
        this.dateError = 'Vælg både start- og slutdato.'
        return false
      }
      if (this.startDate < this.today) {
        this.dateError = 'Startdatoen kan ikke ligge i fortiden.'
        return false
      }
      if (this.endDate < this.startDate) {
        this.dateError = 'Slutdatoen skal være efter startdatoen.'
        return false
      }
      if (this.minimumLoanPeriod && this.selectedDays < this.minimumLoanPeriod) {
        this.dateError = `Minimum låneperiode er ${this.minPeriodText}. Du har valgt ${this.periodText}.`
        return false
      }
      return true
    },
    goToStep2() {
      if (this.validateDates()) this.currentStep = 2
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
            start_date: this.startDate,
            end_date: this.endDate,
            message: this.message,
            status: 'pending',
          }),
        })
        if (!res.ok) {
          const err = await res.json()
          this.error = err.message || 'Noget gik galt. Prøv igen.'
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
  <div class="loan-page">

    <header class="loan-header">
      <button class="back-btn" type="button" @click="$router.back()">Tilbage</button>
      <p class="step-label" v-if="!submitted">STEP {{ currentStep }} AF 3</p>
    </header>

    <div v-if="submitted" class="submitted-box">
      <div class="submitted-icon">
        <v-icon size="48" color="white">mdi-check</v-icon>
      </div>
      <p class="submitted-title">Anmodning sendt!</p>
      <p class="submitted-sub">Ejeren af <strong>{{ itemTitle }}</strong> vil snart svare dig.</p>
      <button class="btn-primary submitted-btn" @click="$router.push('/find-genstande')">Find flere genstande</button>
    </div>

    <template v-else>
      <h1 class="loan-title">{{ itemTitle || 'Anmodning om lån' }}</h1>

      <section v-if="currentStep === 1" class="loan-section">
        <h2 class="loan-step-title">Vælg datoer</h2>

        <p v-if="minPeriodText" class="min-period-hint">
          Minimum låneperiode: <strong>{{ minPeriodText }}</strong>
        </p>

        <div class="date-fields">
          <div class="date-field">
            <label class="field-label" for="start-date">Startdato</label>
            <input class="field-input" type="date" id="start-date" v-model="startDate" :min="today" />
          </div>
          <div class="date-field">
            <label class="field-label" for="end-date">Slutdato</label>
            <input class="field-input" type="date" id="end-date" v-model="endDate" :min="startDate || today" />
          </div>
        </div>

        <p v-if="periodText && !dateError" class="period-display">Valgt periode: <strong>{{ periodText }}</strong></p>
        <p v-if="dateError" class="loan-error">{{ dateError }}</p>

        <div class="loan-actions">
          <button class="btn-primary" @click="goToStep2">Næste</button>
        </div>
      </section>

      <section v-else-if="currentStep === 2" class="loan-section">
        <h2 class="loan-step-title">Tilføj en besked</h2>
        <textarea
          class="loan-textarea"
          v-model="message"
          placeholder="Skriv en besked til ejeren... (valgfri)"
          rows="5"
        ></textarea>
        <div class="loan-actions">
          <button class="btn-secondary" @click="currentStep = 1">Tilbage</button>
          <button class="btn-primary" @click="currentStep = 3">Næste</button>
        </div>
      </section>

      <section v-else-if="currentStep === 3" class="loan-section">
        <h2 class="loan-step-title">Bekræft anmodning</h2>
        <div class="confirm-box">
          <div class="confirm-row">
            <span class="confirm-label">Startdato</span>
            <span class="confirm-value">{{ new Date(startDate).toLocaleDateString('da-DK') }}</span>
          </div>
          <div class="confirm-row">
            <span class="confirm-label">Slutdato</span>
            <span class="confirm-value">{{ new Date(endDate).toLocaleDateString('da-DK') }}</span>
          </div>
          <div class="confirm-row">
            <span class="confirm-label">Periode</span>
            <span class="confirm-value">{{ periodText }}</span>
          </div>
          <div v-if="message" class="confirm-row">
            <span class="confirm-label">Besked</span>
            <span class="confirm-value">{{ message }}</span>
          </div>
        </div>
        <p v-if="error" class="loan-error">{{ error }}</p>
        <div class="loan-actions">
          <button class="btn-secondary" @click="currentStep = 2">Tilbage</button>
          <button class="btn-primary" @click="submitRequest" :disabled="submitting">
            {{ submitting ? 'Sender...' : 'Send anmodning' }}
          </button>
        </div>
      </section>
    </template>

  </div>
</template>

<style scoped>
.loan-page {
  background: var(--color-bg);
  min-height: 100vh;
  padding: var(--space-4);
  box-sizing: border-box;
  max-width: 620px;
  margin: 0 auto;
}

.loan-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-6);
}

.back-btn {
  background: transparent;
  border: none;
  font-family: var(--font-body);
  font-size: var(--text-body);
  font-weight: 500;
  color: var(--color-neutral);
  cursor: pointer;
  padding: var(--space-3) 0;
  min-height: 44px;
}

.step-label {
  margin: 0;
  color: var(--color-accent);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 800;
}

.loan-title {
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 700;
  color: var(--color-neutral);
  margin: 0 0 var(--space-6);
}

.loan-section {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.loan-step-title {
  font-family: var(--font-body);
  font-size: var(--text-body);
  font-weight: 700;
  color: var(--color-neutral);
  margin: 0;
}

.min-period-hint {
  margin: 0;
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
  background: var(--color-surface);
  border-radius: var(--radius-md);
  padding: var(--space-3) var(--space-4);
}

.date-fields {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.date-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field-label {
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 600;
  color: var(--color-secondary);
}

.field-input {
  height: 48px;
  border: none;
  border-radius: var(--radius-full);
  background: var(--color-surface);
  padding: 0 var(--space-4);
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-neutral);
  outline: none;
  width: 100%;
  box-sizing: border-box;
}

.period-display {
  margin: 0;
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
  text-align: center;
}

.loan-textarea {
  width: 100%;
  border: none;
  border-radius: var(--radius-lg);
  background: var(--color-surface);
  padding: var(--space-4);
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-neutral);
  outline: none;
  resize: none;
  box-sizing: border-box;
}

.confirm-box {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  padding: var(--space-4);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.confirm-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: var(--space-4);
}

.confirm-label {
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
  font-weight: 600;
  white-space: nowrap;
}

.confirm-value {
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-neutral);
  text-align: right;
}

.loan-actions {
  display: flex;
  gap: var(--space-3);
  margin-top: var(--space-2);
}

.btn-primary,
.btn-secondary {
  flex: 1;
  min-height: 48px;
  border: none;
  border-radius: var(--radius-full);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 800;
  cursor: pointer;
}

.btn-primary {
  background: var(--color-primary);
  color: #ffffff;
}

.btn-primary:disabled {
  background: var(--color-border);
  cursor: default;
}

.btn-secondary {
  background: var(--color-surface);
  color: var(--color-neutral);
}

.loan-error {
  margin: 0;
  color: var(--color-accent);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 700;
}

.submitted-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-3);
  text-align: center;
  padding: var(--space-6) var(--space-4);
}

.submitted-icon {
  width: 88px;
  height: 88px;
  border-radius: var(--radius-full);
  background: var(--color-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: var(--space-2);
}

.submitted-title {
  font-family: var(--font-display);
  font-size: 28px;
  font-weight: 700;
  color: var(--color-neutral);
  margin: 0;
}

.submitted-sub {
  font-family: var(--font-body);
  font-size: var(--text-body);
  color: var(--color-secondary);
  margin: 0;
  line-height: 1.6;
}

.submitted-btn {
  min-width: 200px;
  flex: none;
  background: var(--color-accent) !important;
  color: #ffffff;
  padding: 0 var(--space-8);
}
</style>
