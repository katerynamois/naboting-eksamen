<script>
import toolsImage from "@/assets/tools.png";
import { getUserId } from "@/utils/session.js";

const API_BASE_URL = "http://localhost:3002/api";

export default {
  name: "Profile",
  props: {
    editRequest: {
      type: Number,
      default: 0,
    },
    viewRequest: {
      type: Number,
      default: 0,
    },
    welcomeRequest: {
      type: Number,
      default: 0,
    },
    profileData: {
      type: Object,
      default: null,
    },
  },
  emits: ["go-to-page-one", "go-to-items", "update-profile"],
  data() {
    return {
      toolsImage,
      activeTab: "ejer",
      ownerLoans: [],
      borrowerLoans: [],
      welcomeTimer: null,
      isEditingProfile: false,
      profile: {
        firstName: "",
        lastName: "",
        email: "",
        phone: "",
        postalCode: "",
        city: "",
        password: "",
      },
      profileDraft: {
        firstName: "",
        lastName: "",
        email: "",
        phone: "",
        postalCode: "",
        city: "",
        currentPassword: "",
        newPassword: "",
        repeatNewPassword: "",
      },
      profileMessage: "",
      profileError: "",
      showWelcomeSnackbar: false,
    };
  },
  computed: {
    pendingOwnerLoans() {
      return this.ownerLoans.filter(l => l.status === "pending");
    },
    activeOwnerLoans() {
      return this.ownerLoans.filter(l => l.status === "active");
    },
    pendingBorrowerLoans() {
      return this.borrowerLoans.filter(l => l.status === "pending");
    },
    activeBorrowerLoans() {
      return this.borrowerLoans.filter(l => l.status === "active");
    },
    rejectedBorrowerLoans() {
      return this.borrowerLoans.filter(l => l.status === "rejected");
    },
    locationText() {
      return [this.profile.postalCode, this.profile.city].filter(Boolean).join(" ");
    },
    profileName() {
      return [this.profile.firstName, this.profile.lastName].filter(Boolean).join(" ") || "Din profil";
    },
  },
  methods: {
    isValidEmail(value) {
      return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(value.trim());
    },
    isValidDanishPhone(value) {
      const normalizedPhone = value.replace(/\s/g, "");
      return /^(\+45)?\d{8}$/.test(normalizedPhone);
    },
    isValidDanishPostalCode(value) {
      return /^\d{4}$/.test(value.trim());
    },
    isValidCity(value) {
      return /^[A-Za-zÆØÅæøå .'-]{2,}$/.test(value.trim());
    },
    async fetchLoans() {
      const userId = getUserId();
      if (!userId) return;
      try {
        const [ownerRes, borrowerRes] = await Promise.all([
          fetch(`${API_BASE_URL}/loans/owner/${userId}`),
          fetch(`${API_BASE_URL}/loans/borrower/${userId}`),
        ]);
        if (ownerRes.ok) this.ownerLoans = await ownerRes.json();
        if (borrowerRes.ok) this.borrowerLoans = await borrowerRes.json();
      } catch {}
    },
    applyProfileData(data) {
      if (!data) return;

      this.profile = {
        ...this.profile,
        firstName: data.userType === "business" ? data.contactPerson || "" : data.firstName || "",
        lastName: data.userType === "business" ? data.companyName || "" : data.lastName || "",
        email: data.email || "",
        phone: data.phone || "",
        postalCode: data.postalCode || data.citySearch || "",
        city: data.city || "",
        password: data.password || this.profile.password,
      };
    },
    showTemporaryWelcome() {
      window.clearTimeout(this.welcomeTimer);
      this.showWelcomeSnackbar = true;
    },
    startProfileEdit() {
      window.clearTimeout(this.welcomeTimer);
      this.profileDraft = {
        firstName: this.profile.firstName,
        lastName: this.profile.lastName,
        email: this.profile.email,
        phone: this.profile.phone,
        postalCode: this.profile.postalCode,
        city: this.profile.city,
        currentPassword: "",
        newPassword: "",
        repeatNewPassword: "",
      };
      this.profileMessage = "";
      this.profileError = "";
      this.isEditingProfile = true;
    },
    cancelProfileEdit() {
      this.isEditingProfile = false;
      this.profileError = "";
    },
    showProfileView() {
      this.isEditingProfile = false;
      this.profileError = "";
      this.profileMessage = "";
    },
    saveProfileEdit() {
      if (!this.profileDraft.firstName.trim() || !this.profileDraft.lastName.trim()) {
        this.profileError = "Indtast både fornavn og efternavn.";
        return;
      }

      if (!this.isValidDanishPostalCode(this.profileDraft.postalCode)) {
        this.profileError = "Indtast et gyldigt postnummer på 4 cifre.";
        return;
      }

      if (this.profileDraft.city.trim() && !this.isValidCity(this.profileDraft.city)) {
        this.profileError = "Indtast en gyldig by.";
        return;
      }

      if (!this.isValidEmail(this.profileDraft.email)) {
        this.profileError = "Indtast en gyldig email adresse.";
        return;
      }

      if (!this.isValidDanishPhone(this.profileDraft.phone)) {
        this.profileError = "Indtast et gyldigt dansk telefonnummer på 8 cifre.";
        return;
      }

      if (this.profileDraft.newPassword || this.profileDraft.repeatNewPassword) {
        if (!this.profileDraft.currentPassword) {
          this.profileError = "Indtast din nuværende adgangskode for at skifte.";
          return;
        }

        if (this.profileDraft.currentPassword !== this.profile.password) {
          this.profileError = "Den nuværende adgangskode er forkert.";
          return;
        }

        if (this.profileDraft.newPassword !== this.profileDraft.repeatNewPassword) {
          this.profileError = "De nye adgangskoder matcher ikke.";
          return;
        }

        if (this.profileDraft.newPassword.length < 6) {
          this.profileError = "Den nye adgangskode skal være mindst 6 tegn.";
          return;
        }
      }

      this.profile = {
        ...this.profile,
        firstName: this.profileDraft.firstName.trim(),
        lastName: this.profileDraft.lastName.trim(),
        email: this.profileDraft.email.trim(),
        phone: this.profileDraft.phone.trim(),
        postalCode: this.profileDraft.postalCode.trim(),
        city: this.profileDraft.city.trim(),
        password: this.profileDraft.newPassword || this.profile.password,
      };
      this.profileMessage = this.profileDraft.newPassword
        ? "Profil og adgangskode er gemt."
        : "Profilen er gemt.";
      this.profileError = "";
      this.isEditingProfile = false;
      this.$emit("update-profile", { ...this.profile });
    },
  },
  mounted() {
    this.applyProfileData(this.profileData);
    this.fetchLoans();
    if (this.editRequest > 0) {
      this.startProfileEdit();
    } else if (this.welcomeRequest > 0) {
      this.showTemporaryWelcome();
    }
  },
  beforeUnmount() {
    window.clearTimeout(this.welcomeTimer);
  },
  watch: {
    editRequest(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.startProfileEdit();
      }
    },
    viewRequest(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.showProfileView();
      }
    },
    welcomeRequest(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.showTemporaryWelcome();
      }
    },
    profileData: {
      handler(newValue) {
        this.applyProfileData(newValue);
      },
      deep: true,
    },
  },
};
</script>

<template>
  <div class="profile-page">
    <v-container class="profile-container">
      <section v-if="isEditingProfile" class="edit-profile-section" aria-label="Rediger profil">
        <v-text-field
          v-model="profileDraft.firstName"
          class="profile-field"
          type="text"
          placeholder="Fornavn"
          variant="solo"
          density="comfortable"
          rounded="lg"
          flat
          hide-details
        />

        <v-text-field
          v-model="profileDraft.lastName"
          class="profile-field"
          type="text"
          placeholder="Efternavn"
          variant="solo"
          density="comfortable"
          rounded="lg"
          flat
          hide-details
        />

        <div class="profile-input-grid">
          <v-text-field
            v-model="profileDraft.postalCode"
            class="profile-field"
            type="text"
            inputmode="numeric"
            maxlength="4"
            placeholder="Postnummer"
            variant="solo"
            density="comfortable"
            rounded="lg"
            flat
            hide-details
          />

          <v-text-field
            v-model="profileDraft.city"
            class="profile-field"
            type="text"
            placeholder="By"
            variant="solo"
            density="comfortable"
            rounded="lg"
            flat
            hide-details
          />
        </div>

        <v-text-field
          v-model="profileDraft.email"
          class="profile-field"
          type="email"
          placeholder="Email"
          autocomplete="email"
          variant="solo"
          density="comfortable"
          rounded="lg"
          flat
          hide-details
        />

        <v-text-field
          v-model="profileDraft.phone"
          class="profile-field"
          type="tel"
          inputmode="tel"
          placeholder="Telefonnummer"
          autocomplete="tel"
          variant="solo"
          density="comfortable"
          rounded="lg"
          flat
          hide-details
        />

        <div class="password-edit-group">
          <p class="edit-section-title">Skift adgangskode</p>

          <v-text-field
            v-model="profileDraft.currentPassword"
            class="profile-field"
            type="password"
            placeholder="Nuv&aelig;rende adgangskode"
            autocomplete="current-password"
            variant="solo"
            density="comfortable"
            rounded="lg"
            flat
            hide-details
          />

          <v-text-field
            v-model="profileDraft.newPassword"
            class="profile-field"
            type="password"
            placeholder="Ny adgangskode"
            autocomplete="new-password"
            variant="solo"
            density="comfortable"
            rounded="lg"
            flat
            hide-details
          />

          <v-text-field
            v-model="profileDraft.repeatNewPassword"
            class="profile-field"
            type="password"
            placeholder="Gentag ny adgangskode"
            autocomplete="new-password"
            variant="solo"
            density="comfortable"
            rounded="lg"
            flat
            hide-details
          />
        </div>

        <p v-if="profileError" class="profile-error">{{ profileError }}</p>

        <div class="edit-profile-actions">
          <v-btn
            class="edit-profile-button"
            variant="flat"
            color="surface"
            rounded="md"
            elevation="0"
            @click="cancelProfileEdit"
          >
            Annuller
          </v-btn>

          <v-btn
            class="edit-profile-button"
            color="primary"
            rounded="md"
            elevation="0"
            @click="saveProfileEdit"
          >
            Gem
          </v-btn>
        </div>
      </section>

      <p v-if="profileMessage && !showWelcomeSnackbar" class="profile-message">{{ profileMessage }}</p>

      <v-snackbar
        v-model="showWelcomeSnackbar"
        :timeout="2000"
        color="primary"
        location="top"
        rounded="lg"
        elevation="4"
      >
        Velkommen til Naboting! Din profil er oprettet.
      </v-snackbar>

      <section v-if="!isEditingProfile" class="profile-header-display" aria-label="Profil">
        <div class="profile-avatar-large">{{ profileName.charAt(0).toUpperCase() }}</div>
        <h1 class="profile-display-name">{{ profileName }}</h1>
        <button class="profile-edit-link" type="button" @click="startProfileEdit">Rediger profil</button>
      </section>

      <section v-if="!isEditingProfile" class="profile-dashboard">

        <div class="profile-quick-actions">
          <button class="quick-action-btn" type="button" @click="$emit('go-to-page-one')">Opret genstand</button>
          <button class="quick-action-btn quick-action-btn--outline" type="button" @click="$emit('go-to-items')">Mine genstande</button>
        </div>

        <div class="tab-toggle" role="tablist">
          <button
            class="tab-btn"
            :class="{ 'tab-btn--active': activeTab === 'ejer' }"
            role="tab"
            @click="activeTab = 'ejer'"
          >Som ejer</button>
          <button
            class="tab-btn"
            :class="{ 'tab-btn--active': activeTab === 'lejer' }"
            role="tab"
            @click="activeTab = 'lejer'"
          >Som lejer</button>
        </div>

        <template v-if="activeTab === 'ejer'">
          <div class="dashboard-section">
            <div class="dashboard-section-header">
              <h2 class="dashboard-section-title">Nye anmodninger</h2>
              <RouterLink to="/indbakke" class="see-all-link">Se alle</RouterLink>
            </div>
            <p v-if="pendingOwnerLoans.length === 0" class="dashboard-empty">Ingen nye anmodninger</p>
            <article v-for="loan in pendingOwnerLoans" :key="loan.loan_id" class="dashboard-card">
              <span class="dashboard-card-name">{{ loan.borrower_first_name }} {{ loan.borrower_last_name }}</span>
              <span class="dashboard-card-meta">{{ loan.item_title }}</span>
            </article>
          </div>

          <div class="dashboard-section">
            <div class="dashboard-section-header">
              <h2 class="dashboard-section-title">Kommende aftaler</h2>
              <RouterLink to="/indbakke" class="see-all-link">Se alle</RouterLink>
            </div>
            <p v-if="activeOwnerLoans.length === 0" class="dashboard-empty">Ingen kommende aftaler</p>
            <article v-for="loan in activeOwnerLoans" :key="loan.loan_id" class="dashboard-card">
              <span class="dashboard-card-name">{{ loan.item_title }}</span>
              <span class="dashboard-card-meta">{{ loan.borrower_first_name }} · {{ loan.start_date ? new Date(loan.start_date).toLocaleDateString('da-DK') : '' }}</span>
            </article>
          </div>

          <div class="dashboard-section">
            <div class="dashboard-section-header">
              <h2 class="dashboard-section-title">Mangler review</h2>
              <span class="see-all-link">Se alle</span>
            </div>
            <p class="dashboard-empty">Ingen reviews</p>
          </div>
        </template>

        <template v-else>
          <div class="dashboard-section">
            <h2 class="dashboard-section-title">Afventer svar</h2>
            <p v-if="pendingBorrowerLoans.length === 0" class="dashboard-empty">Ingen afventende anmodninger</p>
            <article v-for="loan in pendingBorrowerLoans" :key="loan.loan_id" class="dashboard-card">
              <div class="dashboard-card-info">
                <span class="dashboard-card-name">{{ loan.item_title }}</span>
                <span class="dashboard-card-meta">{{ loan.owner_first_name }} {{ loan.owner_last_name }}</span>
              </div>
              <span class="loan-badge loan-badge--pending">Afventer</span>
            </article>
          </div>

          <div class="dashboard-section">
            <h2 class="dashboard-section-title">Godkendte lån</h2>
            <p v-if="activeBorrowerLoans.length === 0" class="dashboard-empty">Ingen godkendte lån</p>
            <article v-for="loan in activeBorrowerLoans" :key="loan.loan_id" class="dashboard-card">
              <div class="dashboard-card-info">
                <span class="dashboard-card-name">{{ loan.item_title }}</span>
                <span class="dashboard-card-meta">{{ loan.start_date ? new Date(loan.start_date).toLocaleDateString('da-DK') : 'Ingen dato' }}</span>
              </div>
              <span class="loan-badge loan-badge--active">Godkendt</span>
            </article>
          </div>

          <div class="dashboard-section">
            <h2 class="dashboard-section-title">Afviste anmodninger</h2>
            <p v-if="rejectedBorrowerLoans.length === 0" class="dashboard-empty">Ingen afviste anmodninger</p>
            <article v-for="loan in rejectedBorrowerLoans" :key="loan.loan_id" class="dashboard-card">
              <div class="dashboard-card-info">
                <span class="dashboard-card-name">{{ loan.item_title }}</span>
                <span class="dashboard-card-meta">{{ loan.owner_first_name }} {{ loan.owner_last_name }}</span>
              </div>
              <span class="loan-badge loan-badge--rejected">Afvist</span>
            </article>
          </div>
        </template>

      </section>
    </v-container>
  </div>
</template>

<style scoped>
.profile-page {
  background: var(--color-bg);
  min-height: 100vh;
  padding: var(--space-6) var(--space-4);
}

.profile-container {
  max-width: 620px;
}

.profile-header-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-2);
  margin-bottom: var(--space-6);
  text-align: center;
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
  margin-bottom: var(--space-2);
}

.profile-display-name {
  margin: 0;
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 700;
  color: var(--color-neutral);
}

.profile-display-meta {
  margin: 0;
  font-family: var(--font-body);
  font-size: var(--text-label);
  color: var(--color-secondary);
}

.profile-edit-link {
  margin-top: var(--space-1);
  border: none;
  background: transparent;
  color: var(--color-accent);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 600;
  cursor: pointer;
  padding: 0;
}

.edit-profile-section {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  margin-bottom: var(--space-6);
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

.profile-input-grid {
  display: grid;
  grid-template-columns: 1fr 1.4fr;
  gap: var(--space-3);
}

.password-edit-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  margin-top: var(--space-2);
}

.edit-section-title {
  margin: 0;
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 800;
}

.profile-error,
.profile-message {
  margin: 0;
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 700;
}

.profile-error {
  color: var(--color-accent);
}

.profile-message {
  margin-bottom: var(--space-4);
  color: var(--color-primary);
}

.edit-profile-actions {
  display: flex;
  gap: var(--space-3);
}

.edit-profile-button {
  flex: 1;
  min-height: 42px;
  text-transform: none;
  font-weight: 800;
}

.profile-quick-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-3);
}

.quick-action-btn {
  min-height: 44px;
  border: none;
  border-radius: var(--radius-md);
  background: var(--color-primary);
  color: #ffffff;
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 700;
  cursor: pointer;
}

.quick-action-btn--outline {
  background: var(--color-surface);
  color: var(--color-primary);
  border: 1px solid var(--color-primary);
}

.profile-dashboard {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
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

.loan-badge {
  font-family: var(--font-body);
  font-size: 12px;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: var(--radius-full);
  white-space: nowrap;
}

.loan-badge--pending {
  background: #fff3cd;
  color: #856404;
}

.loan-badge--active {
  background: #d1e7dd;
  color: #0a3622;
}

.loan-badge--rejected {
  background: #f8d7da;
  color: #842029;
}

@media (max-width: 520px) {
  .profile-input-grid {
    grid-template-columns: 1fr;
  }
}
</style>
