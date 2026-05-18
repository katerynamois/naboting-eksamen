<script>
import LoginModal from '@/components/LoginModal.vue'
export default {
  components: { LoginModal },
  methods: {
    handleClose() {
      this.$router.push('/')
    },
    handleLogin() {
      localStorage.setItem("nabotingSession", "true")
      window.dispatchEvent(new Event("session-changed"))
      this.$router.push('/profil')
    }
  }
}
</script>

<template>
  <LoginModal
    @close="handleClose"
    @login="handleLogin"
    @create-profile="$router.push('/opret-profil')"
  />
</template>
