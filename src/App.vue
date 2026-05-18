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
    handleLogin() {
      localStorage.setItem("nabotingSession", "true")
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
      <v-btn icon variant="text" class="naboting-menu-icon" @click="drawer = true">
        <v-icon>mdi-menu</v-icon>
      </v-btn>
    </v-app-bar>

    <v-navigation-drawer v-model="drawer" location="right" temporary width="280">
      <v-list class="pa-0">
  <template v-if="loggedIn">
    <v-list-item class="menu-item" to="/profil">Min profil</v-list-item>
    <v-list-item class="menu-item" to="/opret-genstand">Opret genstand</v-list-item>
    <v-list-item class="menu-item" to="/genstande">Mine genstande</v-list-item>
    <v-list-item class="menu-item" to="/indbakke">Indbakke</v-list-item>
    <v-list-item class="menu-item" @click="logout">Log ud</v-list-item>
  </template>

  <template v-else>
    <v-list-item class="menu-item" to="/opret-profil">Opret profil</v-list-item>
    <v-list-item class="menu-item" to="/login">Log ind</v-list-item>
  </template>
</v-list>

      <v-divider />

      
      <template #append>
        <div class="support-box ma-4">
          <v-icon class="mr-3 support-icon">mdi-send-outline</v-icon>
          <span class="font-weight-bold">Kontakt support</span>
        </div>
      </template>
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

.naboting-menu-icon {
  color: var(--color-surface) !important;
  background: transparent !important;
  box-shadow: none !important;
}

.menu-item {
  font-size: 16px;
  font-weight: 500;
  padding: 14px 20px;
  cursor: pointer;
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
