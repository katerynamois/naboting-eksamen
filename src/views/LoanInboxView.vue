<script>

export default {
  name: '',
  components: {
  },
  data() {
    return {
      requests: [
        {
              id: 1,
              borrower: 'John Doe',
              itemTitle: 'Cykel',
              startDate: '2024-07-01',
              endDate: '2024-07-07',
              message: 'Hej, jeg vil gerne låne din cykel til en uge. Jeg passer godt på den!',
              status: 'Afventer'
        }
      ]
    }
  },
  props: {
  },
  computed: {
  },
  methods: {
    approve(req) {
      req.status = 'Godkendt';
    },  
    reject(req) {
      req.status = 'Afvist';
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
    <h2>Indkomme anmodninger</h2>
    <article v-for="req in requests" :key="req.id">
      <h3>{{ req.borrower }}</h3>
      <p><strong>Genstand:</strong> {{ req.itemTitle }}</p>
      <p><strong>Periode:</strong> {{ req.startDate }} - {{ req.endDate }}</p>
      <p><strong>Status:</strong> {{ req.status }}</p>
      <button @click="approve(req)">Godkend</button>
      <button @click="reject(req)">Afvist</button>
    </article>
  </main>
</template>

<style scoped>
</style>