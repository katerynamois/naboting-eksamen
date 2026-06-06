<script>
import LoginModal from '@/components/LoginModal.vue'
export default {
  components: { LoginModal },
  methods: {
    handleClose() {
      this.$router.push('/')
    },
    handleLogin(user) {
      localStorage.setItem("nabotingSession", JSON.stringify({ userId: user.user_id, firstName: user.first_name }))
      window.dispatchEvent(new Event("session-changed"))
      this.$router.push('/min-side')
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
