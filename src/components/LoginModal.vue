<script>
export default {
  name: "LoginModal",
  emits: ["close", "create-profile", "login"],
  data() {
    return {
      mode: "login",
      email: "",
      password: "",
      loginError: "",
    };
  },
  methods: {
    submitLogin() {
      if (!this.email.trim() || !this.password.trim()) {
        this.loginError = "Udfyld email og password.";
        return;
      }
      this.loginError = "";
      this.$emit("login", {
        email: this.email,
        password: this.password,
      });
    },
    goToLogin() {
      this.mode = "login";
      this.loginError = "";
    },
    sendPasswordReset() {
      this.mode = "resetSent";
    },
  },
};
</script>

<template>
  <div class="login-overlay" role="presentation">
    <section class="login-dialog" role="dialog" aria-modal="true" aria-labelledby="login-title">
      <button class="close-button" aria-label="Luk log ind" @click="$emit('close')">
        ×
      </button>

      <template v-if="mode === 'login'">
        <h1 id="login-title">Velkommen tilbage</h1>

        <p class="signup-text">
          Ny på Naboting?
          <button type="button" class="signup-link" @click="$emit('create-profile')">
            Opret dig her!
          </button>
        </p>

        <form class="login-form" @submit.prevent="submitLogin">
          <input
            v-model="email"
            class="login-input login-input--highlight"
            type="email"
            placeholder="Din email adresse"
            autocomplete="email"
          />

          <input
            v-model="password"
            class="login-input"
            type="password"
            placeholder="Dit password"
            autocomplete="current-password"
          />

          <button class="login-button" type="submit">
            Log ind
          </button>
        </form>

        <p v-if="loginError" class="login-error">{{ loginError }}</p>

        <button type="button" class="forgot-button" @click="mode = 'reset'">
          Har du glemt dit password?
        </button>
      </template>

      <template v-else>
        <h1 id="login-title">Glemt password</h1>

        <form class="login-form reset-form" @submit.prevent="sendPasswordReset">
          <input
            v-model="email"
            class="login-input login-input--highlight"
            type="email"
            placeholder="Din email adresse"
            autocomplete="email"
          />

          <button class="login-button reset-button" type="submit">
            Send
          </button>
        </form>

        <p v-if="mode === 'resetSent'" class="reset-message">
          Tjek din email for et link til at nulstille dit password.
        </p>

        <button type="button" class="forgot-button" @click="goToLogin">
          Tilbage til log ind
        </button>
      </template>
    </section>
  </div>
</template>

<style scoped>
.login-overlay {
  position: fixed;
  inset: 0;
  z-index: 3000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 12px;
  background: color-mix(in srgb, var(--color-neutral) 70%, transparent);
}

.login-dialog {
  position: relative;
  width: min(376px, 100%);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 34px 18px 26px;
  text-align: center;
}

.close-button {
  position: absolute;
  top: -28px;
  left: 50%;
  width: 56px;
  height: 56px;
  border: none;
  border-radius: var(--radius-full);
  background: var(--color-accent);
  color: var(--color-surface);
  font-family: var(--font-body);
  font-size: var(--text-h1);
  font-weight: 400;
  line-height: 1;
  transform: translateX(-50%);
  cursor: pointer;
}

h1 {
  margin: 0 0 16px;
  color: var(--color-neutral);
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 600;
}

.signup-text {
  margin: 0 0 30px;
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-body);
}

.signup-link {
  border: none;
  background: transparent;
  color: var(--color-accent);
  font: inherit;
  font-weight: 500;
  cursor: pointer;
  padding: 0;
}

.login-form {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

.reset-form {
  margin-top: 18px;
}

.login-input {
  width: 100%;
  height: 40px;
  border: 1px solid var(--color-input-border);
  border-radius: 999px;
  padding: 0 14px;
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-label);
  outline: none;
}

.login-input--highlight,
.login-input:focus {
  border-color: var(--color-accent);
}

.login-button {
  min-width: 110px;
  height: 34px;
  margin-top: 14px;
  border: none;
  border-radius: 999px;
  background: var(--color-primary);
  color: var(--color-surface);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 800;
  cursor: pointer;
}

.reset-button {
  margin-top: 2px;
}

.forgot-button {
  margin-top: 24px;
  border: none;
  background: transparent;
  color: var(--color-secondary);
  font-family: var(--font-body);
  font-size: var(--text-body);
  cursor: pointer;
}

.login-error {
  margin: 12px 0 0;
  color: var(--color-accent);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 700;
}

.reset-message {
  margin: 16px 0 0;
  color: var(--color-secondary);
  font-family: var(--font-body);
  font-size: var(--text-label);
}
</style>
