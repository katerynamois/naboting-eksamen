<script>
import Home from '@/components/Home.vue'
import { getSession } from '@/utils/session.js'

export default {
  components: { Home },
  mounted() {
    if (getSession()) {
      this.$router.replace('/profil')
    }
  },
  methods: {
    handleGoToProfile() {
      this.$router.push('/opret-profil')
    },
    handleShowLogin() {
      this.$router.push('/login')
    }
  }
}
</script>

<template>
  <Home
    @go-to-profile="handleGoToProfile"
    @show-login="handleShowLogin"
  />
</template>
