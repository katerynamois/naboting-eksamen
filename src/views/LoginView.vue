<script>
import LoginModal from '@/components/LoginModal.vue'
export default {
  components: { LoginModal },
  methods: {
    handleClose() {
      this.$router.push('/')
    },
    handleLogin() {
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
