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
        <h1>Refund Policy</h1>
        <p>Last updated: September 2026</p>
      </div>

      <div class="policy-content">
        <section>
          <h2>1. Overview</h2>
          <p>At SR Digital Seva Kendram, we prioritize customer satisfaction and transparent operations. This Refund Policy outlines the terms governing deposits, ID activations, and wallet balance adjustments.</p>
        </section>

        <section>
          <h2>2. Fund Wallet Deposits</h2>
          <p>Fund Wallet deposits submitted with valid 12-digit UTR payment receipts are processed after verification. In cases where a deposit request is rejected due to invalid UTR or missing funds, no wallet credit is issued.</p>
        </section>

        <section>
          <h2>3. ID Activation &amp; Top-Ups</h2>
          <p>ID activations and subscription plan top-ups (₹1,200) are immediate digital service purchases. Once activated, subscription fees are non-refundable as digital network benefits and commission allocations take effect instantly.</p>
        </section>

        <section>
          <h2>4. Help &amp; Support</h2>
          <p>If you experience any billing discrepancies or technical transaction issues, please contact our 24/7 Support Team via WhatsApp or email for prompt resolution.</p>
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
  name: 'RefundPolicy'
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
.policy-content p {
  color: #475569;
  line-height: 1.6;
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
