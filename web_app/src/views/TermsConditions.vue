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
        <h1>Terms &amp; Conditions</h1>
        <p>Last updated: September 2026</p>
      </div>

      <div class="policy-content">
        <section>
          <h2>1. Agreement to Terms</h2>
          <p>By downloading, installing, or using the SR Digital Seva Kendram mobile application or web portal, you agree to be bound by these Terms &amp; Conditions. If you do not agree to all of these terms, please do not use our services.</p>
        </section>

        <section>
          <h2>2. User Account &amp; Registration</h2>
          <p>Users must provide accurate, complete registration details including a valid 10-digit mobile number and registered email address. Each user is responsible for maintaining the confidentiality of their account credentials.</p>
        </section>

        <section>
          <h2>3. Fund Wallet &amp; Transactions</h2>
          <p>Deposits made to the Fund Wallet require verification of a 12-digit UTR payment transaction number. Deposits are subject to admin approval prior to credit. All transactions are logged securely and irreversibly.</p>
        </section>

        <section>
          <h2>4. Income Pools &amp; Withdrawals</h2>
          <p>Earnings from Captcha solving, Direct Referrals, and Global Pool cycles are credited to the user's Main Wallet. Cashouts are permitted for verified Active accounts on designated withdrawal days as set by system administrators.</p>
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
  name: 'TermsConditions'
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
