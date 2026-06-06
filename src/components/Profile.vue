<script>
import { getUserId } from "@/utils/session.js";

const API_BASE_URL = "http://localhost:3002/api";

export default {
  name: "Profile",
  props: {
    editRequest:    { type: Number, default: 0 },
    viewRequest:    { type: Number, default: 0 },
    welcomeRequest: { type: Number, default: 0 },
    profileData:    { type: Object, default: null },
  },
  emits: ["go-to-page-one", "go-to-items", "update-profile"],
  data() {
    return {
      activeTab: "ejer",
      activeSection: "aftaler",
      ownerLoans: [],
      borrowerLoans: [],
      selectedLoan: null,
      showLoanDialog: false,
      loanSearch: '',
      welcomeTimer: null,
      profile: {
        firstName: "", lastName: "", email: "",
        phone: "", postalCode: "", city: "", password: "",
      },
      profileDraft: {
        firstName: "", lastName: "", email: "",
        phone: "", postalCode: "", city: "",
        currentPassword: "", newPassword: "", repeatNewPassword: "",
      },
      profileMessage: "",
      profileError: "",
      showWelcomeSnackbar: false,
    };
  },
  computed: {
    filteredOwnerLoans() {
      const q = this.loanSearch.toLowerCase().trim();
      if (!q) return this.ownerLoans;
      return this.ownerLoans.filter(l =>
        (l.item_title || '').toLowerCase().includes(q) ||
        (`${l.borrower_first_name} ${l.borrower_last_name}`).toLowerCase().includes(q)
      );
    },
    filteredBorrowerLoans() {
      const q = this.loanSearch.toLowerCase().trim();
      if (!q) return this.borrowerLoans;
      return this.borrowerLoans.filter(l =>
        (l.item_title || '').toLowerCase().includes(q) ||
        (`${l.owner_first_name} ${l.owner_last_name}`).toLowerCase().includes(q)
      );
    },
    pendingOwnerLoans()    { return this.filteredOwnerLoans.filter(l => l.status === "pending"); },
    activeOwnerLoans()     { return this.filteredOwnerLoans.filter(l => l.status === "active"); },
    pendingBorrowerLoans() { return this.filteredBorrowerLoans.filter(l => l.status === "pending"); },
    activeBorrowerLoans()  { return this.filteredBorrowerLoans.filter(l => l.status === "active"); },
    rejectedBorrowerLoans(){ return this.filteredBorrowerLoans.filter(l => l.status === "rejected"); },
    completedBorrowerLoans(){ return this.filteredBorrowerLoans.filter(l => l.status === "completed"); },
    profileName() {
      return [this.profile.firstName, this.profile.lastName].filter(Boolean).join(" ") || "Din profil";
    },
  },
  methods: {
    isValidEmail(v)           { return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(v.trim()); },
    isValidDanishPhone(v)     { return /^(\+45)?\d{8}$/.test(v.replace(/\s/g, "")); },
    isValidDanishPostalCode(v){ return /^\d{4}$/.test(v.trim()); },
    isValidCity(v)            { return /^[A-Za-zÆØÅæøå .'-]{2,}$/.test(v.trim()); },

    async fetchLoans() {
      const userId = getUserId();
      if (!userId) return;
      try {
        const [ownerRes, borrowerRes] = await Promise.all([
          fetch(`${API_BASE_URL}/loans/owner/${userId}`),
          fetch(`${API_BASE_URL}/loans/borrower/${userId}`),
        ]);
        if (ownerRes.ok)   this.ownerLoans    = await ownerRes.json();
        if (borrowerRes.ok) this.borrowerLoans = await borrowerRes.json();
      } catch {}
    },

    applyProfileData(data) {
      if (!data) return;
      this.profile = {
        ...this.profile,
        firstName: data.userType === "business" ? data.contactPerson || "" : data.firstName || "",
        lastName:  data.userType === "business" ? data.companyName   || "" : data.lastName  || "",
        email: data.email || "", phone: data.phone || "",
        postalCode: data.postalCode || data.citySearch || "",
        city: data.city || "",
        password: data.password || this.profile.password,
      };
    },

    openKonto() {
      this.profileDraft = {
        firstName: this.profile.firstName, lastName: this.profile.lastName,
        email: this.profile.email, phone: this.profile.phone,
        postalCode: this.profile.postalCode, city: this.profile.city,
        currentPassword: "", newPassword: "", repeatNewPassword: "",
      };
      this.profileMessage = "";
      this.profileError = "";
      this.activeSection = "konto";
    },

    saveProfileEdit() {
      if (!this.profileDraft.firstName.trim() || !this.profileDraft.lastName.trim()) {
        this.profileError = "Indtast både fornavn og efternavn."; return;
      }
      if (!this.isValidDanishPostalCode(this.profileDraft.postalCode)) {
        this.profileError = "Indtast et gyldigt postnummer på 4 cifre."; return;
      }
      if (this.profileDraft.city.trim() && !this.isValidCity(this.profileDraft.city)) {
        this.profileError = "Indtast en gyldig by."; return;
      }
      if (!this.isValidEmail(this.profileDraft.email)) {
        this.profileError = "Indtast en gyldig email adresse."; return;
      }
      if (!this.isValidDanishPhone(this.profileDraft.phone)) {
        this.profileError = "Indtast et gyldigt dansk telefonnummer på 8 cifre."; return;
      }
      if (this.profileDraft.newPassword || this.profileDraft.repeatNewPassword) {
        if (!this.profileDraft.currentPassword) {
          this.profileError = "Indtast din nuværende adgangskode for at skifte."; return;
        }
        if (this.profileDraft.currentPassword !== this.profile.password) {
          this.profileError = "Den nuværende adgangskode er forkert."; return;
        }
        if (this.profileDraft.newPassword !== this.profileDraft.repeatNewPassword) {
          this.profileError = "De nye adgangskoder matcher ikke."; return;
        }
        if (this.profileDraft.newPassword.length < 6) {
          this.profileError = "Den nye adgangskode skal være mindst 6 tegn."; return;
        }
      }
      this.profile = {
        ...this.profile,
        firstName: this.profileDraft.firstName.trim(),
        lastName:  this.profileDraft.lastName.trim(),
        email:     this.profileDraft.email.trim(),
        phone:     this.profileDraft.phone.trim(),
        postalCode:this.profileDraft.postalCode.trim(),
        city:      this.profileDraft.city.trim(),
        password:  this.profileDraft.newPassword || this.profile.password,
      };
      this.profileMessage = this.profileDraft.newPassword ? "Profil og adgangskode er gemt." : "Profilen er gemt.";
      this.profileError = "";
      this.$emit("update-profile", { ...this.profile });
    },

    openLoan(loan) {
      this.selectedLoan = loan;
      this.showLoanDialog = true;
    },
    async updateLoanStatus(loan, newStatus) {
      try {
        const res = await fetch(`${API_BASE_URL}/loans/${loan.loan_id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ ...loan, status: newStatus }),
        });
        if (res.ok) {
          await this.fetchLoans();
          this.showLoanDialog = false;
        }
      } catch {}
    },

    showTemporaryWelcome() {
      window.clearTimeout(this.welcomeTimer);
      this.showWelcomeSnackbar = true;
    },
  },

  mounted() {
    this.applyProfileData(this.profileData);
    this.fetchLoans();
    if (this.welcomeRequest > 0) this.showTemporaryWelcome();
  },
  beforeUnmount() {
    window.clearTimeout(this.welcomeTimer);
  },
  watch: {
    editRequest(n, o)    { if (n !== o) this.openKonto(); },
    viewRequest(n, o)    { if (n !== o) this.activeSection = "aftaler"; },
    welcomeRequest(n, o) { if (n !== o) this.showTemporaryWelcome(); },
    profileData: { handler(v) { this.applyProfileData(v); }, deep: true },
  },
};
</script>

<template>
  <div class="profile-page">
    <v-container class="profile-container">

      <v-snackbar v-model="showWelcomeSnackbar" :timeout="2000" color="primary" location="top" rounded="lg" elevation="4">
        Velkommen til Naboting! Din profil er oprettet.
      </v-snackbar>

      <div class="profile-layout">

        <!-- ── Left sidebar ── -->
        <aside class="profile-sidebar">

          <div class="sidebar-card profile-card">
            <div class="profile-avatar-wrap">
              <div class="profile-avatar-large">{{ profileName.charAt(0).toUpperCase() }}</div>
              <button class="avatar-edit-btn" type="button" @click="openKonto" aria-label="Rediger profil">
                <v-icon size="14">mdi-pencil</v-icon>
              </button>
            </div>
            <p class="sidebar-name">{{ profileName }}</p>
          </div>

          <nav class="sidebar-card sidebar-nav" aria-label="Profil navigation">
            <button class="sidebar-nav-item" :class="{ 'sidebar-nav-item--active': activeSection === 'produkter' }" type="button" @click="$emit('go-to-items')">
              <v-icon class="nav-icon">mdi-cube-outline</v-icon>
              Mine produkter
            </button>
            <button class="sidebar-nav-item" :class="{ 'sidebar-nav-item--active': activeSection === 'konto' }" type="button" @click="openKonto">
              <v-icon class="nav-icon">mdi-account-outline</v-icon>
              Konto
            </button>
            <button class="sidebar-nav-item" :class="{ 'sidebar-nav-item--active': activeSection === 'aftaler' }" type="button" @click="activeSection = 'aftaler'; fetchLoans()">
              <v-icon class="nav-icon">mdi-swap-vertical</v-icon>
              Aftaler
            </button>
            <button class="sidebar-nav-item" type="button" @click="$router.push('/indbakke')">
              <v-icon class="nav-icon">mdi-bell-outline</v-icon>
              Notifikationer
            </button>
            <button class="sidebar-nav-item sidebar-nav-item--disabled" type="button" disabled>
              <v-icon class="nav-icon">mdi-file-document-outline</v-icon>
              Hent lejekontrakt
            </button>
            <button class="sidebar-nav-item" type="button" @click="$emit('go-to-page-one')">
              <v-icon class="nav-icon">mdi-plus-circle-outline</v-icon>
              Opret genstand
            </button>
          </nav>

        </aside>

        <!-- ── Right main content ── -->
        <main class="profile-main">

          <!-- AFTALER -->
          <template v-if="activeSection === 'aftaler'">

            <div class="loan-search-wrapper">
              <v-icon class="loan-search-icon" size="18">mdi-magnify</v-icon>
              <input
                v-model="loanSearch"
                class="loan-search-input"
                type="search"
                placeholder="Søg efter genstand eller person…"
              />
            </div>

            <div class="tab-toggle" role="tablist">
              <button class="tab-btn" :class="{ 'tab-btn--active': activeTab === 'ejer' }" role="tab" @click="activeTab = 'ejer'">Som ejer</button>
              <button class="tab-btn" :class="{ 'tab-btn--active': activeTab === 'lejer' }" role="tab" @click="activeTab = 'lejer'">Som lejer</button>
            </div>

            <template v-if="activeTab === 'ejer'">
              <div class="dashboard-section">
                <div class="dashboard-section-header">
                  <h2 class="dashboard-section-title">Nye anmodninger</h2>
                  <RouterLink v-if="pendingOwnerLoans.length > 3" to="/indbakke" class="see-all-link">
                    Se alle <v-icon size="14">mdi-chevron-right</v-icon>
                  </RouterLink>
                </div>
                <p v-if="pendingOwnerLoans.length === 0" class="dashboard-empty">Ingen nye anmodninger</p>
                <article v-for="loan in pendingOwnerLoans.slice(0, 3)" :key="loan.loan_id" class="dashboard-card dashboard-card--clickable" @click="openLoan(loan)">
                  <span class="dashboard-card-name">{{ loan.borrower_first_name }} {{ loan.borrower_last_name }}</span>
                  <span class="dashboard-card-meta">{{ loan.item_title }}</span>
                </article>
              </div>

              <div class="dashboard-section">
                <div class="dashboard-section-header">
                  <h2 class="dashboard-section-title">Kommende aftaler</h2>
                  <RouterLink v-if="activeOwnerLoans.length > 3" to="/indbakke" class="see-all-link">
                    Se alle <v-icon size="14">mdi-chevron-right</v-icon>
                  </RouterLink>
                </div>
                <p v-if="activeOwnerLoans.length === 0" class="dashboard-empty">Ingen kommende aftaler</p>
                <article v-for="loan in activeOwnerLoans.slice(0, 3)" :key="loan.loan_id" class="dashboard-card dashboard-card--clickable" @click="openLoan(loan)">
                  <span class="dashboard-card-name">{{ loan.item_title }}</span>
                  <span class="dashboard-card-meta">{{ loan.borrower_first_name }} · {{ loan.start_date ? new Date(loan.start_date).toLocaleDateString('da-DK') : '' }}</span>
                </article>
              </div>

            </template>

            <template v-else>
              <div class="dashboard-section">
                <div class="dashboard-section-header">
                  <h2 class="dashboard-section-title">Afventer svar</h2>
                  <RouterLink v-if="pendingBorrowerLoans.length > 3" to="/indbakke" class="see-all-link">
                    Se alle <v-icon size="14">mdi-chevron-right</v-icon>
                  </RouterLink>
                </div>
                <p v-if="pendingBorrowerLoans.length === 0" class="dashboard-empty">Ingen afventende anmodninger</p>
                <article v-for="loan in pendingBorrowerLoans.slice(0, 3)" :key="loan.loan_id" class="dashboard-card dashboard-card--clickable" @click="openLoan(loan)">
                  <div class="dashboard-card-info">
                    <span class="dashboard-card-name">{{ loan.item_title }}</span>
                    <span class="dashboard-card-meta">{{ loan.owner_first_name }} {{ loan.owner_last_name }}</span>
                  </div>
                  <span class="loan-badge loan-badge--pending">Afventer</span>
                </article>
              </div>

              <div class="dashboard-section">
                <div class="dashboard-section-header">
                  <h2 class="dashboard-section-title">Godkendte lån</h2>
                  <RouterLink v-if="activeBorrowerLoans.length > 3" to="/indbakke" class="see-all-link">
                    Se alle <v-icon size="14">mdi-chevron-right</v-icon>
                  </RouterLink>
                </div>
                <p v-if="activeBorrowerLoans.length === 0" class="dashboard-empty">Ingen godkendte lån</p>
                <article v-for="loan in activeBorrowerLoans.slice(0, 3)" :key="loan.loan_id" class="dashboard-card dashboard-card--clickable" @click="openLoan(loan)">
                  <div class="dashboard-card-info">
                    <span class="dashboard-card-name">{{ loan.item_title }}</span>
                    <span class="dashboard-card-meta">{{ loan.start_date ? new Date(loan.start_date).toLocaleDateString('da-DK') : 'Ingen dato' }}</span>
                  </div>
                  <span class="loan-badge loan-badge--active">Godkendt</span>
                </article>
              </div>

              <div class="dashboard-section">
                <div class="dashboard-section-header">
                  <h2 class="dashboard-section-title">Afviste anmodninger</h2>
                  <RouterLink v-if="rejectedBorrowerLoans.length > 3" to="/indbakke" class="see-all-link">
                    Se alle <v-icon size="14">mdi-chevron-right</v-icon>
                  </RouterLink>
                </div>
                <p v-if="rejectedBorrowerLoans.length === 0" class="dashboard-empty">Ingen afviste anmodninger</p>
                <article v-for="loan in rejectedBorrowerLoans.slice(0, 3)" :key="loan.loan_id" class="dashboard-card dashboard-card--clickable" @click="openLoan(loan)">
                  <div class="dashboard-card-info">
                    <span class="dashboard-card-name">{{ loan.item_title }}</span>
                    <span class="dashboard-card-meta">{{ loan.owner_first_name }} {{ loan.owner_last_name }}</span>
                  </div>
                  <span class="loan-badge loan-badge--rejected">Afvist</span>
                </article>
              </div>

              <div v-if="completedBorrowerLoans.length" class="dashboard-section">
                <div class="dashboard-section-header">
                  <h2 class="dashboard-section-title">Afsluttede lån</h2>
                  <RouterLink v-if="completedBorrowerLoans.length > 3" to="/indbakke" class="see-all-link">
                    Se alle <v-icon size="14">mdi-chevron-right</v-icon>
                  </RouterLink>
                </div>
                <article v-for="loan in completedBorrowerLoans.slice(0, 3)" :key="loan.loan_id" class="dashboard-card dashboard-card--clickable" @click="openLoan(loan)">
                  <div class="dashboard-card-info">
                    <span class="dashboard-card-name">{{ loan.item_title }}</span>
                    <span class="dashboard-card-meta">{{ loan.owner_first_name }} {{ loan.owner_last_name }}</span>
                  </div>
                  <span class="loan-badge loan-badge--completed">Afsluttet</span>
                </article>
              </div>
            </template>
          </template>

          <!-- KONTO -->
          <template v-else-if="activeSection === 'konto'">
            <h2 class="section-heading">Konto</h2>

            <p v-if="profileMessage" class="profile-message">{{ profileMessage }}</p>
            <p v-if="profileError"   class="profile-error">{{ profileError }}</p>

            <div class="konto-form">
              <div class="profile-input-grid">
                <v-text-field v-model="profileDraft.firstName" class="profile-field" type="text" placeholder="Fornavn" variant="solo" density="comfortable" rounded="lg" flat hide-details />
                <v-text-field v-model="profileDraft.lastName"  class="profile-field" type="text" placeholder="Efternavn" variant="solo" density="comfortable" rounded="lg" flat hide-details />
              </div>
              <div class="profile-input-grid">
                <v-text-field v-model="profileDraft.postalCode" class="profile-field" type="text" inputmode="numeric" maxlength="4" placeholder="Postnummer" variant="solo" density="comfortable" rounded="lg" flat hide-details />
                <v-text-field v-model="profileDraft.city"       class="profile-field" type="text" placeholder="By" variant="solo" density="comfortable" rounded="lg" flat hide-details />
              </div>
              <v-text-field v-model="profileDraft.email" class="profile-field" type="email" placeholder="Email" autocomplete="email" variant="solo" density="comfortable" rounded="lg" flat hide-details />
              <v-text-field v-model="profileDraft.phone" class="profile-field" type="tel" inputmode="tel" placeholder="Telefonnummer" autocomplete="tel" variant="solo" density="comfortable" rounded="lg" flat hide-details />

              <p class="edit-section-title">Skift adgangskode</p>
              <v-text-field v-model="profileDraft.currentPassword"   class="profile-field" type="password" placeholder="Nuværende adgangskode"  autocomplete="current-password" variant="solo" density="comfortable" rounded="lg" flat hide-details />
              <v-text-field v-model="profileDraft.newPassword"        class="profile-field" type="password" placeholder="Ny adgangskode"          autocomplete="new-password"     variant="solo" density="comfortable" rounded="lg" flat hide-details />
              <v-text-field v-model="profileDraft.repeatNewPassword"  class="profile-field" type="password" placeholder="Gentag ny adgangskode"   autocomplete="new-password"     variant="solo" density="comfortable" rounded="lg" flat hide-details />

              <div class="edit-profile-actions">
                <v-btn class="edit-profile-button" variant="flat" color="surface" rounded="md" elevation="0" @click="activeSection = 'aftaler'">Annuller</v-btn>
                <v-btn class="edit-profile-button" color="primary" rounded="md" elevation="0" @click="saveProfileEdit">Gem</v-btn>
              </div>
            </div>
          </template>

        </main>
      </div>

    </v-container>

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

  </div>
</template>

<style scoped>
.profile-page {
  background: var(--color-bg);
  min-height: 100vh;
  padding: var(--space-6) var(--space-4);
}

.profile-container {
  max-width: 900px;
}

/* ── Two-column layout ── */
.profile-layout {
  display: grid;
  grid-template-columns: 260px 1fr;
  gap: var(--space-6);
  align-items: start;
}

/* ── Sidebar ── */
.profile-sidebar {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.sidebar-card {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

/* Profile card */
.profile-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-2);
  padding: 40px var(--space-4) var(--space-5);
  text-align: center;
}

.profile-avatar-wrap {
  position: relative;
  display: inline-block;
  margin-top: 16px;
}

.profile-avatar-large {
  width: 80px;
  height: 80px;
  border-radius: var(--radius-full);
  background: var(--color-primary);
  color: #ffffff;
  font-family: var(--font-body);
  font-size: 36px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-edit-btn {
  position: absolute;
  bottom: 2px;
  right: 2px;
  width: 24px;
  height: 24px;
  border-radius: var(--radius-full);
  background: var(--color-accent);
  color: #ffffff;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.sidebar-name {
  margin: 0;
  font-family: var(--font-display);
  font-size: var(--text-h2);
  font-weight: 700;
  color: var(--color-neutral);
}

.sidebar-rating {
  margin: 0;
  display: flex;
  align-items: center;
  gap: 4px;
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
}

/* Sidebar nav */
.sidebar-nav {
  display: flex;
  flex-direction: column;
}

.sidebar-nav-item {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: 14px var(--space-4);
  background: transparent;
  border: none;
  border-left: 3px solid transparent;
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 500;
  color: var(--color-neutral);
  cursor: pointer;
  text-align: left;
  transition: background 0.12s;
}

.sidebar-nav-item:hover {
  background: var(--color-bg);
}

.sidebar-nav-item--active {
  border-left-color: var(--color-primary);
  color: var(--color-primary);
  font-weight: 700;
  background: color-mix(in srgb, var(--color-primary) 6%, transparent);
}

.sidebar-nav-item--active .nav-icon {
  color: var(--color-primary) !important;
}

.sidebar-nav-item--disabled {
  opacity: 0.4;
  cursor: default;
}

.nav-icon {
  color: var(--color-secondary) !important;
  flex-shrink: 0;
}

/* ── Main content ── */
.profile-main {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.section-heading {
  margin: 0;
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 700;
  color: var(--color-neutral);
}

/* Loan search */
.loan-search-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.loan-search-icon {
  position: absolute;
  left: 14px;
  color: var(--color-secondary) !important;
  pointer-events: none;
}

.loan-search-input {
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

.loan-search-input::placeholder {
  color: var(--color-secondary);
}

.loan-search-input:focus {
  border-color: var(--color-primary);
}

/* Tab toggle */
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

/* Dashboard */
.dashboard-section {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.dashboard-section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.dashboard-section-title {
  margin: 0;
  font-family: var(--font-display);
  font-size: var(--text-h2);
  font-weight: 700;
  color: var(--color-neutral);
}

.see-all-link {
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
  text-decoration: none;
  cursor: pointer;
}

.dashboard-empty {
  margin: var(--space-4) auto;
  color: var(--color-secondary);
  font-family: var(--font-body);
  font-size: var(--text-body);
  font-style: italic;
  text-align: center;
}

.dashboard-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: var(--space-3) var(--space-4);
}

.dashboard-card--clickable {
  cursor: pointer;
  transition: border-color 0.12s, box-shadow 0.12s;
}

.dashboard-card--clickable:hover {
  border-color: var(--color-primary);
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

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
  gap: 0;
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

.loan-dialog-row:last-child {
  border-bottom: none;
}

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
  min-height: var(--touch-target);
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

.dashboard-card-name {
  font-family: var(--font-body);
  font-size: var(--text-body);
  font-weight: 600;
  color: var(--color-neutral);
}

.dashboard-card-meta {
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
}

.dashboard-card-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

/* Konto form */
.konto-form {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.profile-input-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-3);
}

.profile-field :deep(.v-field) {
  background: var(--color-surface);
  box-shadow: none;
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-body);
}

.profile-field :deep(input::placeholder) {
  color: var(--color-secondary);
  opacity: 0.75;
}

.edit-section-title {
  margin: var(--space-2) 0 0;
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 800;
}

.edit-profile-actions {
  display: flex;
  gap: var(--space-3);
  margin-top: var(--space-2);
}

.edit-profile-button {
  flex: 1;
  min-height: 42px;
  text-transform: none;
  font-weight: 800;
}

.profile-error   { margin: 0; color: var(--color-accent);   font-family: var(--font-body); font-size: var(--text-label); font-weight: 700; }
.profile-message { margin: 0; color: var(--color-primary);  font-family: var(--font-body); font-size: var(--text-label); font-weight: 700; }

/* Loan badges */
.loan-badge {
  font-family: var(--font-body);
  font-size: 12px;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: var(--radius-full);
  white-space: nowrap;
}
.loan-badge--pending   { background: #fff3cd; color: #856404; }
.loan-badge--active    { background: #d1e7dd; color: #0a3622; }
.loan-badge--rejected  { background: #f8d7da; color: #842029; }
.loan-badge--completed { background: #e2e8f0; color: #475569; }

/* ── Mobile ── */
@media (max-width: 640px) {
  .profile-layout {
    grid-template-columns: 1fr;
  }
  .profile-sidebar {
    order: 2;
  }
  .profile-main {
    order: 1;
  }
  .profile-input-grid {
    grid-template-columns: 1fr;
  }
}
</style>
