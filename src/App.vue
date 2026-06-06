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
      pendingCount: 0,
    }
  },
  mounted() {
    this.refreshSession()
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
      const session = localStorage.getItem("nabotingSession")
      this.loggedIn = Boolean(session)
      if (session) this.fetchPendingCount(JSON.parse(session).userId)
      else this.pendingCount = 0
    },
    async fetchPendingCount(userId) {
      try {
        const res = await fetch(`http://localhost:3002/api/loans/owner/${userId}`)
        if (!res.ok) return
        const loans = await res.json()
        this.pendingCount = loans.filter(l => l.status === 'pending').length
      } catch {}
    },
    handleLogin(user) {
      localStorage.setItem("nabotingSession", JSON.stringify({ userId: user.user_id, firstName: user.first_name }))
      this.loggedIn = true
      this.showLogin = false
      this.fetchPendingCount(user.user_id)
      this.$router.push('/min-side')
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
      <RouterLink :to="loggedIn ? '/min-side' : '/'" class="naboting-logo">NABOTING</RouterLink>
      <v-spacer />
      <button class="naboting-menu-btn" @click="drawer = true" aria-label="Menu">
        <v-icon color="white">mdi-menu</v-icon>
      </button>
    </v-app-bar>

    <v-navigation-drawer v-model="drawer" location="right" temporary width="280">
      <nav class="drawer-nav">
        <template v-if="loggedIn">
          <RouterLink class="drawer-item" to="/find-genstande" @click="drawer = false">Find genstande</RouterLink>
          <RouterLink class="drawer-item drawer-item--notify" to="/min-side" @click="drawer = false">
            Min side
            <span v-if="pendingCount > 0" class="drawer-badge">{{ pendingCount }}</span>
          </RouterLink>
          <RouterLink class="drawer-item" to="/profil" @click="drawer = false">Min profil</RouterLink>
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

.naboting-menu-btn {
  position: relative;
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.menu-badge {
  position: absolute;
  top: 4px;
  right: 4px;
  background: var(--color-accent);
  width: 10px;
  height: 10px;
  border-radius: 50%;
  pointer-events: none;
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

.drawer-item--notify {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.drawer-badge {
  background: var(--color-accent);
  color: #ffffff;
  font-size: 12px;
  font-weight: 700;
  min-width: 22px;
  height: 22px;
  border-radius: 11px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 6px;
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
