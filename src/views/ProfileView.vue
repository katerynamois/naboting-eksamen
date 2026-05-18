<script>
import Profile from '@/components/Profile.vue'
export default {
  components: { Profile },
  computed: {
    welcomeRequest() {
      return this.$route.query.welcome === 'true' ? 1 : 0
    }
  },
  methods: {
    handleGoToPageOne() {
      this.$router.push('/opret-genstand')
    },
    handleGoToItems() {
      this.$router.push('/genstande')
    }
  }
}
</script>

<template>
  <Profile
    :welcomeRequest="welcomeRequest"
    @go-to-page-one="handleGoToPageOne"
    @go-to-items="handleGoToItems"
  />
</template>
