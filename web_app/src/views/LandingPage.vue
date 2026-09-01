<template>
  <div class="landing-page-wrapper">
    <main class="page">
      <img
        src="../assets/sr_landing.png"
        alt="SR Digital Seva Kendram Landing Page"
      />
    </main>
  </div>
</template>

<script>
export default {
  name: 'LandingPage'
}
</script>

<style scoped>
.landing-page-wrapper {
  width: 100%;
  min-height: 100vh;
  background: #ffffff;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  overflow-x: hidden;
  margin: 0;
  padding: 0;
}

.page {
  width: 100%;
  max-width: 683px;
  line-height: 0;
}

.page img {
  display: block;
  width: 100%;
  height: auto;
  border: 0;
}
</style>
