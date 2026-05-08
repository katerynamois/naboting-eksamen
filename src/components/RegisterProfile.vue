<script>
export default {
  name: "RegisterProfile",
  emits: ["show-login", "profile-created", "go-back"],
  data() {
    return {
      currentRegisterStep: 1,
      email: "",
      phone: "",
      password: "",
      repeatPassword: "",
      acceptedTerms: false,
      userType: "private",
      firstName: "",
      lastName: "",
      gender: "",
      birthYear: "",
      companyName: "",
      cvr: "",
      contactPerson: "",
      industry: "",
      openDropdown: null,
      citySearch: "",
      profileImage: null,
      profileImagePreview: null,
      registerError: "",
    };
  },
  computed: {
    genderOptions() {
      return ["Kvinde", "Mand", "Andet", "Vil ikke oplyse"];
    },
    birthYearOptions() {
      return Array.from({ length: 90 }, (_, index) => 2026 - index - 1);
    },
    industryOptions() {
      return ["Byggeri", "Have og udeliv", "Transport", "Event", "IT og elektronik", "Andet"];
    },
    profileInitial() {
      return (this.firstName || this.contactPerson || this.companyName || "K")
        .trim()
        .charAt(0)
        .toUpperCase() || "K";
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
    normalizePostalCode() {
      this.citySearch = this.citySearch.replace(/\D/g, "").slice(0, 4);
    },
    isValidCvr(value) {
      return /^\d{8}$/.test(value.replace(/\s/g, ""));
    },
    goToAboutStep() {
      this.registerError = "";
      if (!this.email || !this.phone || !this.password || !this.repeatPassword) {
        this.registerError = "Udfyld venligst alle felter.";
        return;
      }
      if (!this.isValidEmail(this.email)) {
        this.registerError = "Indtast en gyldig email adresse.";
        return;
      }
      if (!this.isValidDanishPhone(this.phone)) {
        this.registerError = "Indtast et gyldigt dansk telefonnummer på 8 cifre.";
        return;
      }
      if (this.password !== this.repeatPassword) {
        this.registerError = "Adgangskoderne matcher ikke.";
        return;
      }
      if (this.password.length < 6) {
        this.registerError = "Adgangskoden skal være mindst 6 tegn.";
        return;
      }
      if (!this.acceptedTerms) {
        this.registerError = "Du skal acceptere brugsvilkårene for at fortsætte.";
        return;
      }
      this.currentRegisterStep = 2;
    },
    goToPostcodeStep() {
      this.registerError = "";

      if (this.userType === "private") {
        if (!this.firstName.trim() || !this.lastName.trim()) {
          this.registerError = "Indtast både fornavn og efternavn.";
          return;
        }
      }

      if (this.userType === "business") {
        if (!this.companyName.trim() || !this.contactPerson.trim() || !this.industry) {
          this.registerError = "Udfyld firmanavn, kontaktperson og branche.";
          return;
        }
        if (!this.isValidCvr(this.cvr)) {
          this.registerError = "Indtast et gyldigt CVR-nummer på 8 cifre.";
          return;
        }
      }

      if (!this.isValidDanishPostalCode(this.citySearch)) {
        this.registerError = "Indtast et gyldigt postnummer på 4 cifre.";
        return;
      }

      this.currentRegisterStep = 3;
    },
    goBack() {
      if (this.currentRegisterStep === 1) {
        this.$emit("go-back");
        return;
      }

      this.currentRegisterStep -= 1;
    },
    toggleDropdown(name) {
      this.openDropdown = this.openDropdown === name ? null : name;
    },
    selectDropdownValue(name, value) {
      this[name] = value;
      this.openDropdown = null;
    },
    closeDropdown(event) {
      if (!event.currentTarget.contains(event.relatedTarget)) {
        this.openDropdown = null;
      }
    },
    updateProfileImage(event) {
      const file = event.target.files && event.target.files[0];
      this.profileImage = file || null;
      if (file) {
        const reader = new FileReader();
        reader.onload = (e) => {
          this.profileImagePreview = e.target.result;
        };
        reader.readAsDataURL(file);
      } else {
        this.profileImagePreview = null;
      }
    },
    submitProfileCreated() {
      if (!this.isValidEmail(this.email) || !this.isValidDanishPhone(this.phone)) {
        this.registerError = "Tjek email og telefonnummer igen.";
        this.currentRegisterStep = 1;
        return;
      }

      this.$emit("profile-created", {
        email: this.email,
        phone: this.phone,
        password: this.password,
        userType: this.userType,
        firstName: this.firstName,
        lastName: this.lastName,
        gender: this.gender,
        birthYear: this.birthYear,
        companyName: this.companyName,
        cvr: this.cvr,
        contactPerson: this.contactPerson,
        industry: this.industry,
        citySearch: this.citySearch,
        profileImage: this.profileImage,
      });
    },
  },
};
</script>

<template>
  <div class="register-page">
    <v-container class="register-container">
      <header v-if="currentRegisterStep === 1" class="register-header">
        <p class="step-label">STEP 1 AF 3</p>
        <h1>Opret bruger</h1>
        <p class="login-text">
          Allerede medlem?
          <button type="button" class="text-button" @click="$emit('show-login')">
            Log ind
          </button>
        </p>
      </header>

      <form
        v-if="currentRegisterStep === 1"
        class="register-form"
        @submit.prevent="goToAboutStep"
      >
        <input
          v-model="email"
          class="register-input"
          type="email"
          placeholder="Din email adresse"
          autocomplete="email"
        />

        <div class="phone-field">
          <div class="country-code" aria-label="Landekode Danmark">
            <span class="flag" aria-hidden="true">
              <span class="flag-cross flag-cross--vertical"></span>
              <span class="flag-cross flag-cross--horizontal"></span>
            </span>
            <span>+45</span>
          </div>

          <input
            v-model="phone"
            class="phone-input"
            type="tel"
            inputmode="tel"
            placeholder="Dit telefonnummer"
            autocomplete="tel"
          />
        </div>

        <input
          v-model="password"
          class="register-input"
          type="password"
          placeholder="Dit password"
          autocomplete="new-password"
        />

        <input
          v-model="repeatPassword"
          class="register-input"
          type="password"
          placeholder="Gentag password"
          autocomplete="new-password"
        />

        <label class="terms-row">
          <input v-model="acceptedTerms" type="checkbox" />
          <span>
            Ved at checke denne boks accepterer du vores
            <button type="button" class="text-button">Brugsvilkår</button>
            og
            <button type="button" class="text-button">Privatlivspolitik</button>
          </span>
        </label>

        <p v-if="registerError" class="register-error">{{ registerError }}</p>

        <div class="register-actions">
          <button class="back-button" type="button" @click="goBack">
            Tilbage
          </button>

          <button class="continue-button" type="submit">
            Fortsæt
          </button>
        </div>
      </form>

      <header v-if="currentRegisterStep === 2" class="register-header register-header--about">
        <p class="step-label">STEP 2 AF 3</p>
        <h1>Mere om dig</h1>
        <p class="login-text">
          Du kan både oprette dig som erhverv eller som privatperson
        </p>
      </header>

      <form
        v-if="currentRegisterStep === 2"
        class="register-form"
        @submit.prevent="goToPostcodeStep"
      >
        <div class="account-type-toggle" aria-label="Vælg brugertype">
          <button
            type="button"
            class="toggle-button"
            :class="{ 'toggle-button--active': userType === 'private' }"
            @click="userType = 'private'"
          >
            Privat
          </button>

          <button
            type="button"
            class="toggle-button"
            :class="{ 'toggle-button--active': userType === 'business' }"
            @click="userType = 'business'"
          >
            Erhverv
          </button>
        </div>

        <input
          v-if="userType === 'private'"
          v-model="firstName"
          class="register-input"
          type="text"
          placeholder="Fornavn"
          autocomplete="given-name"
        />

        <input
          v-if="userType === 'private'"
          v-model="lastName"
          class="register-input"
          type="text"
          placeholder="Efternavn"
          autocomplete="family-name"
        />

        <div v-if="userType === 'private'" class="select-shell" tabindex="-1" @focusout="closeDropdown">
          <button
            type="button"
            class="register-select"
            :class="{ 'register-select--placeholder': !gender }"
            aria-label="Køn"
            :aria-expanded="openDropdown === 'gender'"
            @click="toggleDropdown('gender')"
          >
            <span>{{ gender || "Køn" }}</span>
            <v-icon size="18">mdi-chevron-down</v-icon>
          </button>

          <div v-if="openDropdown === 'gender'" class="select-menu">
            <button
              v-for="option in genderOptions"
              :key="option"
              type="button"
              class="select-option"
              :class="{ 'select-option--active': gender === option }"
              @click="selectDropdownValue('gender', option)"
            >
              {{ option }}
            </button>
          </div>
        </div>

        <div v-if="userType === 'private'" class="select-shell" tabindex="-1" @focusout="closeDropdown">
          <button
            type="button"
            class="register-select"
            :class="{ 'register-select--placeholder': !birthYear }"
            aria-label="Fødselsår"
            :aria-expanded="openDropdown === 'birthYear'"
            @click="toggleDropdown('birthYear')"
          >
            <span>{{ birthYear || "Fødselsår" }}</span>
            <v-icon size="18">mdi-chevron-down</v-icon>
          </button>

          <div v-if="openDropdown === 'birthYear'" class="select-menu select-menu--scroll">
            <button
              v-for="year in birthYearOptions"
              :key="year"
              type="button"
              class="select-option"
              :class="{ 'select-option--active': birthYear === year }"
              @click="selectDropdownValue('birthYear', year)"
            >
              {{ year }}
            </button>
          </div>
        </div>

        <template v-if="userType === 'business'">
          <input
            v-model="companyName"
            class="register-input"
            type="text"
            placeholder="Firmanavn"
            autocomplete="organization"
          />

          <input
            v-model="cvr"
            class="register-input"
            type="text"
            inputmode="numeric"
            maxlength="8"
            placeholder="CVR"
            autocomplete="off"
          />

          <input
            v-model="contactPerson"
            class="register-input"
            type="text"
            placeholder="Kontaktperson"
            autocomplete="name"
          />

          <div class="select-shell" tabindex="-1" @focusout="closeDropdown">
            <button
              type="button"
              class="register-select"
              :class="{ 'register-select--placeholder': !industry }"
              aria-label="Branche"
              :aria-expanded="openDropdown === 'industry'"
              @click="toggleDropdown('industry')"
            >
              <span>{{ industry || "Branche" }}</span>
              <v-icon size="18">mdi-chevron-down</v-icon>
            </button>

            <div v-if="openDropdown === 'industry'" class="select-menu">
              <button
                v-for="option in industryOptions"
                :key="option"
                type="button"
                class="select-option"
                :class="{ 'select-option--active': industry === option }"
                @click="selectDropdownValue('industry', option)"
              >
                {{ option }}
              </button>
            </div>
          </div>
        </template>

        <input
          v-model="citySearch"
          class="register-input"
          type="text"
          inputmode="numeric"
          maxlength="4"
          placeholder="Postnummer"
          autocomplete="postal-code"
          @input="normalizePostalCode"
        />

        <p v-if="registerError" class="register-error">{{ registerError }}</p>

        <div class="register-actions">
          <button class="back-button" type="button" @click="goBack">
            Tilbage
          </button>

          <button class="continue-button" type="submit" :disabled="!isValidDanishPostalCode(citySearch)">
            Fortsæt
          </button>
        </div>
      </form>

      <section v-if="currentRegisterStep === 3" class="profile-image-step">
        <header class="register-header profile-image-header">
          <p class="step-label">STEP 3 AF 3</p>
          <h1>Tilføj profilbillede</h1>
        </header>

        <form class="profile-image-form" @submit.prevent="submitProfileCreated">
          <div class="avatar-picker">
            <img
              v-if="profileImagePreview"
              :src="profileImagePreview"
              class="profile-avatar profile-avatar--img"
              alt="Profilbillede preview"
            />
            <div v-else class="profile-avatar" aria-hidden="true">
              {{ profileInitial }}
            </div>

            <label class="edit-avatar-button" aria-label="Tilføj profilbillede">
              <v-icon size="18">mdi-pencil</v-icon>
              <input
                class="avatar-input"
                type="file"
                accept="image/*"
                @change="updateProfileImage"
              />
            </label>
          </div>

          <div class="register-actions profile-image-actions">
            <button class="back-button" type="button" @click="goBack">
              Tilbage
            </button>

            <button class="continue-button" type="submit">
            Fortsæt
          </button>
          </div>
        </form>
      </section>
    </v-container>
  </div>
</template>

<style scoped>
.register-page {
  background: var(--color-bg);
  min-height: 100vh;
  padding: var(--space-4) 0 var(--space-8);
}

.register-container {
  max-width: 620px;
}

.register-header {
  text-align: center;
  margin-bottom: var(--space-4);
}

.register-header--about {
  margin-bottom: var(--space-3);
}

.step-label {
  margin: 0 0 var(--space-2);
  color: var(--color-accent);
  font-family: var(--font-body);
  font-size: var(--text-body);
  font-weight: 800;
}

h1 {
  margin: 0 0 var(--space-2);
  color: var(--color-neutral);
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 700;
}

.login-text {
  margin: 0;
  color: var(--color-secondary);
  font-family: var(--font-body);
  font-size: var(--text-label);
}

.text-button {
  border: none;
  background: transparent;
  color: var(--color-accent);
  font: inherit;
  cursor: pointer;
  padding: 0;
}

.register-form {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.register-input,
.phone-field,
.select-shell {
  width: 100%;
  min-height: 44px;
  border: none;
  border-radius: var(--radius-full);
  background: var(--color-surface);
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-label);
}

.register-input {
  padding: 0 var(--space-4);
  outline: none;
}

.profile-image-step {
  min-height: calc(100vh - 80px);
  display: flex;
  flex-direction: column;
}

.profile-image-header {
  margin-top: var(--space-12);
  margin-bottom: var(--space-12);
}

.profile-image-form {
  display: flex;
  flex: 1;
  flex-direction: column;
  align-items: center;
}

.avatar-picker {
  position: relative;
  width: 154px;
  height: 154px;
  margin-top: var(--space-4);
}

.profile-avatar {
  width: 154px;
  height: 154px;
  border-radius: var(--radius-full);
  background: var(--color-primary);
  color: var(--color-surface);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: var(--font-body);
  font-size: 64px;
  font-weight: 400;
}

.profile-avatar--img {
  object-fit: cover;
  background: none;
}

.edit-avatar-button {
  position: absolute;
  right: var(--space-2);
  bottom: var(--space-2);
  width: 32px;
  height: 32px;
  border-radius: var(--radius-full);
  background: var(--color-accent);
  color: var(--color-surface);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.avatar-input {
  position: absolute;
  width: 1px;
  height: 1px;
  opacity: 0;
}

.profile-image-actions {
  margin-top: var(--space-8);
}

.account-type-toggle {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-12);
  max-width: 335px;
  width: 100%;
  margin: 0 auto var(--space-1);
}

.toggle-button {
  min-height: 34px;
  border: none;
  border-radius: var(--radius-full);
  background: var(--color-surface);
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 800;
  cursor: pointer;
}

.toggle-button--active {
  background: var(--color-accent);
  color: var(--color-surface);
}

.phone-field {
  display: flex;
  overflow: hidden;
}

.country-code {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  min-width: 136px;
  padding: 0 var(--space-4);
  border-right: 1px solid var(--color-input-border);
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-label);
}

.flag {
  position: relative;
  width: 26px;
  height: 18px;
  background: var(--color-accent);
  flex-shrink: 0;
}

.flag-cross {
  position: absolute;
  background: var(--color-surface);
}

.flag-cross--vertical {
  top: 0;
  bottom: 0;
  left: 9px;
  width: 4px;
}

.flag-cross--horizontal {
  left: 0;
  right: 0;
  top: 7px;
  height: 4px;
}

.phone-input {
  flex: 1;
  min-width: 0;
  border: none;
  background: transparent;
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-label);
  outline: none;
  padding: 0 var(--space-4);
}

.select-shell {
  position: relative;
}

.register-select {
  width: 100%;
  min-height: 44px;
  border: none;
  border-radius: var(--radius-full);
  background: transparent;
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-label);
  outline: none;
  padding: 0 var(--space-4);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: space-between;
  text-align: left;
}

.register-select--placeholder {
  color: var(--color-secondary);
}

.select-menu {
  position: absolute;
  z-index: 10;
  top: calc(100% + 6px);
  left: 0;
  right: 0;
  overflow: hidden;
  border: 1px solid var(--color-border);
  border-radius: 18px;
  background: var(--color-surface);
  box-shadow: 0 12px 28px rgba(0, 0, 0, 0.08);
}

.select-menu--scroll {
  max-height: 220px;
  overflow-y: auto;
}

.select-option {
  width: 100%;
  min-height: 38px;
  border: none;
  background: var(--color-surface);
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-label);
  text-align: left;
  padding: 0 var(--space-4);
  cursor: pointer;
}

.select-option:hover,
.select-option--active {
  background: var(--color-image-bg);
}

.terms-row {
  display: grid;
  grid-template-columns: 32px 1fr;
  align-items: start;
  gap: var(--space-3);
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-label);
  line-height: 1.2;
  margin-top: var(--space-1);
}

.terms-row input {
  width: 28px;
  height: 28px;
  accent-color: var(--color-primary);
}

.register-actions {
  align-self: center;
  display: flex;
  align-items: center;
  gap: var(--space-3);
  margin-top: var(--space-3);
}

.back-button,
.continue-button {
  min-width: 108px;
  min-height: 38px;
  border: none;
  border-radius: var(--radius-full);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 800;
  cursor: pointer;
}

.back-button {
  background: var(--color-surface);
  color: var(--color-neutral);
}

.continue-button {
  background: var(--color-primary);
  color: var(--color-surface);
}

.continue-button:disabled {
  background: var(--color-border);
  cursor: default;
}

.register-error {
  margin: 0;
  color: var(--color-accent);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 700;
  text-align: center;
}
</style>
