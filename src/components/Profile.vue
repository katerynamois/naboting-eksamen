<script>
import toolsImage from "@/assets/tools.png";

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
      showLoans: false,
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
    };
  },
  computed: {
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

      <p v-if="profileMessage" class="profile-message">{{ profileMessage }}</p>

      <section v-if="!isEditingProfile" class="profile-actions" aria-label="Profil handlinger">
        <img
          :src="toolsImage"
          alt="V&aelig;rkt&oslash;j til at oprette genstande"
          class="profile-tools-image"
        />

        <v-btn
          color="primary"
          rounded="lg"
          size="large"
          elevation="0"
          class="profile-button"
          @click="$emit('go-to-page-one')"
        >
          Opret genstand
        </v-btn>

        <v-btn
          variant="tonal"
          color="primary"
          rounded="lg"
          size="large"
          elevation="0"
          class="profile-button"
          @click="$emit('go-to-items')"
        >
          Mine genstande
        </v-btn>

        <v-btn
          variant="outlined"
          color="primary"
          rounded="lg"
          size="large"
          elevation="0"
          class="profile-button"
          @click="showLoans = !showLoans"
        >
          Mine l&aring;n
        </v-btn>

      </section>

      <section v-if="!isEditingProfile && showLoans" class="loan-section" aria-live="polite">
        <h2>Mine l&aring;n</h2>
        <p>Du har ingen aktive l&aring;n endnu.</p>
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

.profile-actions {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.profile-tools-image {
  display: block;
  width: min(320px, 90%);
  height: auto;
  margin: 0 auto var(--space-3);
}

.profile-button {
  min-height: 52px;
  text-transform: none;
  font-weight: 700;
  box-shadow: none !important;
}

.profile-link-button {
  min-height: 42px;
  background: transparent !important;
}

.profile-details-toggle {
  border: none;
  background: transparent;
  color: var(--color-secondary);
  font-family: var(--font-body);
  font-size: var(--text-label);
  cursor: pointer;
  padding: 0;
  text-align: center;
}

.loan-section {
  margin-top: var(--space-6);
  padding: var(--space-4);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
}

.loan-section h2 {
  margin: 0 0 6px;
  font-family: var(--font-display);
  font-size: var(--text-h2);
  color: var(--color-neutral);
}

.loan-section p {
  margin: 0;
  font-family: var(--font-body);
  font-size: var(--text-body);
  color: var(--color-secondary);
}

@media (max-width: 520px) {
  .profile-input-grid {
    grid-template-columns: 1fr;
  }
}
</style>
