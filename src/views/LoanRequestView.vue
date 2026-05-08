<script>
export default {
  name: '',
  components: {
  },
  data() {
    return {
        currentStep: 1,
        startDate: '',
        endDate: '',    
        message: '',
        submitted: false,
    }
  },
  props: {
  },
  computed: {
  },
  methods: {
    submitRequest() {
        this.submitted = true;
        // Nulstil formularen
        this.currentStep = 1;
        this.startDate = '';
        this.endDate = '';
        this.message = '';
    }
  },
  watch: {
  },
  emits: [
  ]
}
</script>

<template>
    <main>
        <h2>Anmodning om lån</h2>
                    <p v-if="submitted">Din anmodning er sendt!</p>

        <section v-if="currentStep === 1">
            <h3>Vælg datoer</h3>
            <label for="start-date">Startdato:</label>
            <input type="date" id="start-date" v-model="startDate">
            <label for="end-date">Slutdato:</label>
            <input type="date" id="end-date" v-model="endDate">
            <button @click="currentStep = 2">Næste</button>
        </section>
        <section v-else-if="currentStep === 2">
            <h3>Tilføj en besked</h3>
            <textarea v-model="message" placeholder="Skriv en besked til udlejeren..."></textarea>
           <button @click="currentStep = 1">Tilbage</button>
           <button @click="currentStep = 3">Næste</button>
        </section>
        <section v-else-if="currentStep === 3">
            <h3> Bekræft anmodning</h3>
            <p>Datoer: {{ startDate }} - {{ endDate }}</p>
            <p>Besked: {{ message }}</p>
            <button @click="currentStep = 2">Tilbage</button>
            <button @click="submitRequest">Send anmodning</button>

        </section>
    </main>
</template>

<style scoped>
</style>