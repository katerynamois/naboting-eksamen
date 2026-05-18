<script>
import RegisterProfile from '@/components/RegisterProfile.vue'
export default {
  components: { RegisterProfile },
  methods: {
    handleProfileCreated() {
      localStorage.setItem("nabotingSession", "true")
      window.dispatchEvent(new Event("session-changed"))
      this.$router.push('/profil?welcome=true')
    },
    handleGoBack() {
      this.$router.push('/')
    },
    handleShowLogin() {
      this.$router.push('/login')
    }
  }
}
</script>

<template>
  <RegisterProfile
    @profile-created="handleProfileCreated"
    @go-back="handleGoBack"
    @show-login="handleShowLogin"
  />
</template>
