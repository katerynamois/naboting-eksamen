<script>
import LoginModal from "@/components/LoginModal.vue";

export default {
  components: {
    LoginModal,
  },
  data() {
    return {
      drawer: false,
      showLogin: false,
      loggedIn: false,
    }
  },
  mounted() {
    this.loggedIn = Boolean(localStorage.getItem("nabotingSession"))
    window.addEventListener("session-changed", this.refreshSession)
  },
  beforeUnmount() {
    window.removeEventListener("session-changed", this.refreshSession)
  },
  watch: {
    drawer(val) {
      if (val) this.refreshSession()
    },
  },
  methods: {
    openLogin() {
      this.showLogin = true
      this.drawer = false
    },
    closeLogin() {
      this.showLogin = false
    },
    refreshSession() {
      this.loggedIn = Boolean(localStorage.getItem("nabotingSession"))
    },
    handleLogin(user) {
      localStorage.setItem("nabotingSession", JSON.stringify({ userId: user.user_id, firstName: user.first_name }))
      this.loggedIn = true
      this.showLogin = false
    },
    logout() {
      this.showLogin = false
      this.drawer = false
      this.loggedIn = false
      localStorage.removeItem("nabotingSession")
      this.$router.push('/')
    },
  },
};
</script>

<template>
  <v-app>

    <v-app-bar flat class="naboting-bar">
      <RouterLink to="/" class="naboting-logo">NABOTING</RouterLink>
      <v-spacer />
      <RouterLink to="/find-genstande" class="naboting-browse-link">Find genstande</RouterLink>
      <v-btn icon variant="text" class="naboting-menu-icon" @click="drawer = true">
        <v-icon>mdi-menu</v-icon>
      </v-btn>
    </v-app-bar>

    <v-navigation-drawer v-model="drawer" location="right" temporary width="280">
      <nav class="drawer-nav">
        <template v-if="loggedIn">
          <RouterLink class="drawer-item" to="/profil" @click="drawer = false">Min profil</RouterLink>
          <RouterLink class="drawer-item" to="/find-genstande" @click="drawer = false">Find genstande</RouterLink>
          <RouterLink class="drawer-item" to="/opret-genstand" @click="drawer = false">Opret genstand</RouterLink>
          <RouterLink class="drawer-item" to="/genstande" @click="drawer = false">Mine genstande</RouterLink>
          <RouterLink class="drawer-item" to="/indbakke" @click="drawer = false">Indbakke</RouterLink>
          <button class="drawer-item drawer-item--btn" @click="logout">Log ud</button>
        </template>
        <template v-else>
          <RouterLink class="drawer-item" to="/find-genstande" @click="drawer = false">Find genstande</RouterLink>
          <RouterLink class="drawer-item" to="/opret-profil" @click="drawer = false">Opret dig</RouterLink>
          <RouterLink class="drawer-item" to="/login" @click="drawer = false">Log ind</RouterLink>
          <hr class="drawer-divider" />
          <RouterLink class="drawer-item" to="/om-naboting" @click="drawer = false">Om Naboting</RouterLink>
          <span class="drawer-item drawer-item--muted">Sådan virker det</span>
          <span class="drawer-item drawer-item--muted">FAQ</span>
          <span class="drawer-item drawer-item--muted">Cookiepolitik</span>
          <span class="drawer-item drawer-item--muted">Brugervilkår</span>
        </template>
      </nav>

      <div class="drawer-support">
        <v-icon class="mr-3 support-icon">mdi-send-outline</v-icon>
        <span class="font-weight-bold">Kontakt support</span>
      </div>
    </v-navigation-drawer>

    <v-main>
      <RouterView />

      <LoginModal
        v-if="showLogin"
        @close="closeLogin"
        @login="handleLogin"
      />
    </v-main>

  </v-app>
</template>

<style>
.naboting-bar {
  background-color: var(--color-primary);
  padding: 0 16px;
}

.naboting-logo {
  font-size: 22px;
  font-weight: 800;
  letter-spacing: -0.5px;
  color: var(--color-surface);
  cursor: pointer;
  user-select: none;
  text-decoration: none;
}

.naboting-browse-link {
  color: var(--color-primary);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-weight: 700;
  text-decoration: none;
  padding: 6px 14px;
  background: var(--color-surface);
  border-radius: var(--radius-full);
  margin-right: 8px;
  white-space: nowrap;
}

.naboting-menu-icon {
  color: var(--color-surface) !important;
  background: transparent !important;
  box-shadow: none !important;
}

.drawer-nav {
  display: flex;
  flex-direction: column;
  padding: 8px 0;
}

.drawer-item {
  display: block;
  padding: 14px 20px;
  font-size: 16px;
  font-weight: 500;
  color: #111111;
  text-decoration: none;
  cursor: pointer;
  background: transparent;
  border: none;
  text-align: left;
  width: 100%;
  font-family: inherit;
}

.drawer-item:hover {
  background: rgba(0,0,0,0.04);
}

.drawer-item--btn {
  color: #c0392b;
}

.drawer-item--muted {
  color: #888;
  cursor: default;
}

.drawer-divider {
  border: none;
  border-top: 1px solid rgba(0,0,0,0.1);
  margin: 8px 0;
}

.drawer-support {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  align-items: center;
  background-color: var(--color-image-bg);
  border-radius: 12px;
  margin: 16px;
  padding: 16px;
  font-size: 15px;
}

.support-box {
  display: flex;
  align-items: center;
  background-color: var(--color-image-bg);
  border-radius: 12px;
  padding: 16px;
  font-size: 15px;
}

.support-icon {
  color: var(--color-accent);
}
</style>
