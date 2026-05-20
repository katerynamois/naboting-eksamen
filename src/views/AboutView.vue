<template>
  <div class="about-page">
    <div class="content-wrapper">
      <h1>Om Naboting</h1>
      <p>Naboting er en platform til at dele og låne genstande inden for dit netværk.</p>
      <p>Her kan du oprette genstande, se dine egne annoncer, og håndtere forespørgsler i indbakken.</p>
      <p>Log ind for at få adgang til din profil, oprette genstande og administrere dine lån.</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AboutView',
}
</script>

<style scoped>
.about-page {
  padding: 24px;
}
.content-wrapper {
  max-width: 760px;
  margin: 0 auto;
}
h1 {
  margin-bottom: 18px;
  font-size: 32px;
  font-weight: 700;
}
p {
  margin-bottom: 14px;
  line-height: 1.7;
}
</style>
