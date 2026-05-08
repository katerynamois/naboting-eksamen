<script>
export default {
  name: "Home",
  components: {},
  data() {
    return {};
  },
  computed: {},
  methods: {},
  watch: {},
};
</script>

<template>
  <div class="page-bg">
    <v-container fluid class="text-center mx-auto">
      <h1 class="justify-content-center">Velkommen til dit lokale fællesskab</h1>
       <v-img
        src="@/assets/LandingImg.jpg"
        alt="Velkomstbillede"
        class="welcome-image mb-4 mx-auto"
        max-width="500"
        contain
      />

      <div class="flex-grow-1"></div>

      <v-row>
        <v-col cols="12">
          <v-btn
            class="items_button mt-10"
            size="large"
            @click="$emit('go-to-profile')"
          >
            Opret profil
          </v-btn>
        </v-col>

        <v-col cols="12">
          <v-btn
            class="loans_button"
            size="large"
            @click="$emit('show-login')"
          >
            Log ind
          </v-btn>
        </v-col>
      </v-row>

    </v-container>
  </div>
</template>

<style scoped>
.items_button,
.loans_button {
  background-color: var(--color-primary);
  color: var(--color-surface);
  font-weight: 700;
  min-width: 200px;
  border-radius: var(--radius-md);
  box-shadow: none !important;
  transition: background-color 0.2s ease;
}

.items_button:hover,
.loans_button:hover {
  background-color: var(--color-primary-dark) !important;
}


.page-bg {
  background-color: var(--color-bg);
  min-height: 100vh;
}
</style>
