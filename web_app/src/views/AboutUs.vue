<template>
  <div class="page-container">
    <!-- Header -->
    <header class="header">
      <div class="header-content">
        <router-link to="/" class="logo-area">
          <div class="sr-logo-title">
            <span class="logo-blue">SR DIGITAL SEVA</span>
            <span class="logo-red">KENDRAM</span>
          </div>
        </router-link>
        <router-link to="/" class="back-link">&larr; Back to Home</router-link>
      </div>
    </header>

    <!-- Main Content -->
    <main class="content-body">
      <div class="policy-header">
        <h1>About Us</h1>
        <p>Empowering digital micro-task workers across India</p>
      </div>

      <div class="policy-content">
        <section>
          <h2>Who We Are</h2>
          <p>SR Digital Seva is a premier digital work platform dedicated exclusively to online CAPTCHA entry, verification tasks, and micro-work solutions.</p>
        </section>

        <section>
          <h2>Our Mission</h2>
          <p>Our mission is to provide an accessible, transparent, and highly secure digital work environment. We connect registered users with authentic CAPTCHA work opportunities, enabling individuals to earn rewards based on accuracy, performance, and verified completed work standards.</p>
        </section>

        <section>
          <h2>Why Choose SR Digital Seva?</h2>
          <ul>
            <li><strong>Dedicated CAPTCHA Platform:</strong> 100% focused on genuine micro-task &amp; CAPTCHA work with zero clutter.</li>
            <li><strong>Transparent Earnings:</strong> Clear tracking of work output, wallet earnings, and level progress.</li>
            <li><strong>Bank-Grade Security:</strong> Secure authentication, bank account locking, and safe payout processing.</li>
            <li><strong>Dedicated Support:</strong> Real-time WhatsApp support assistance for registered members.</li>
          </ul>
        </section>
      </div>
    </main>

    <!-- Footer -->
    <footer class="footer">
      <p>&copy; 2026 SR Digital Seva Kendram. All rights reserved.</p>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'AboutUs'
}
</script>

<style scoped>
.page-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: #fafbfc;
  color: #1e293b;
  font-family: 'Outfit', 'Inter', system-ui, sans-serif;
}
.header {
  background: #0052cc;
  padding: 1rem 0;
}
.header-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.logo-area {
  text-decoration: none;
}
.sr-logo-title {
  display: flex;
  flex-direction: column;
}
.logo-blue {
  color: #ffffff;
  font-weight: 900;
  font-size: 1.25rem;
  letter-spacing: 0.5px;
}
.logo-red {
  color: #ff4d4d;
  font-weight: 800;
  font-size: 0.85rem;
  letter-spacing: 2px;
}
.back-link {
  color: white;
  text-decoration: none;
  font-weight: bold;
}
.content-body {
  flex: 1;
  max-width: 800px;
  margin: 0 auto;
  padding: 4rem 2rem;
  width: 100%;
  box-sizing: border-box;
}
.policy-header {
  text-align: center;
  margin-bottom: 3rem;
}
.policy-header h1 {
  font-size: 2.5rem;
  font-weight: 900;
  color: #0f172a;
  margin-bottom: 0.5rem;
}
.policy-header p {
  color: #64748b;
  font-size: 1rem;
}
.policy-content section {
  margin-bottom: 2rem;
}
.policy-content h2 {
  font-size: 1.35rem;
  color: #0052cc;
  margin-bottom: 0.75rem;
}
.policy-content p, .policy-content li {
  color: #475569;
  line-height: 1.6;
}
.policy-content ul {
  padding-left: 1.5rem;
}
.footer {
  background: #002244;
  color: white;
  text-align: center;
  padding: 2rem 0;
}
.footer p {
  margin: 0;
  opacity: 0.7;
}
</style>
