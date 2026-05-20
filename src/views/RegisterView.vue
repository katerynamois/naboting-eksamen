<script>
import RegisterProfile from '@/components/RegisterProfile.vue'
export default {
  components: { RegisterProfile },
  data() {
    return {
      serverError: "",
    }
  },
  methods: {
    async handleProfileCreated(data) {
      this.serverError = ""
      try {
        const res = await fetch("http://localhost:3001/api/users", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            email: data.email,
            phone: data.phone,
            password: data.password,
            user_type: data.userType,
            first_name: data.firstName || data.contactPerson || data.companyName || null,
            last_name: data.lastName || null,
            postal_code: data.citySearch || null,
          }),
        })
        if (!res.ok) {
          const err = await res.json()
          this.serverError = err.message || "Der skete en fejl. Prøv igen."
          return
        }
        const user = await res.json()
        localStorage.setItem("nabotingSession", JSON.stringify({ userId: user.user_id, firstName: user.first_name }))
        window.dispatchEvent(new Event("session-changed"))
        this.$router.push('/profil?welcome=true')
      } catch {
        this.serverError = "Kunne ikke forbinde til serveren."
      }
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
    :server-error="serverError"
    @profile-created="handleProfileCreated"
    @go-back="handleGoBack"
    @show-login="handleShowLogin"
  />
</template>
