<script>
import Profile from '@/components/Profile.vue'
import { getUserId } from '@/utils/session.js'

const API_BASE_URL = 'http://localhost:3002/api'

export default {
  components: { Profile },
  data() {
    return {
      profileData: null,
    }
  },
  computed: {
    welcomeRequest() {
      return this.$route.query.welcome === 'true' ? 1 : 0
    },
    userId() {
      return getUserId()
    },
  },
  mounted() {
    this.fetchUser()
  },
  methods: {
    async fetchUser() {
      if (!this.userId) return
      try {
        const res = await fetch(`${API_BASE_URL}/users/${this.userId}`)
        if (res.ok) {
          const user = await res.json()
          this.profileData = {
            firstName: user.first_name || '',
            lastName: user.last_name || '',
            email: user.email || '',
            phone: user.phone || '',
            postalCode: user.postal_code || '',
            city: '',
          }
        }
      } catch {}
    },
    async handleUpdateProfile(updated) {
      if (!this.userId) return
      try {
        await fetch(`${API_BASE_URL}/users/${this.userId}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            first_name: updated.firstName,
            last_name: updated.lastName,
            email: updated.email,
            phone: updated.phone,
            postal_code: updated.postalCode,
            user_type: 'private',
          }),
        })
      } catch {}
    },
    handleGoToPageOne() {
      this.$router.push('/opret-genstand')
    },
    handleGoToItems() {
      this.$router.push('/genstande')
    },
  },
}
</script>

<template>
  <Profile
    :welcomeRequest="welcomeRequest"
    :profileData="profileData"
    @go-to-page-one="handleGoToPageOne"
    @go-to-items="handleGoToItems"
    @update-profile="handleUpdateProfile"
  />
</template>
