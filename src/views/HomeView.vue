<script>
import Home from '@/components/Home.vue'
export default {
  components: { Home },
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
