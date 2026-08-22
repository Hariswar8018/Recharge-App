<template>
  <div class="page-container">
    <!-- Header -->
    <header class="header">
      <div class="header-content">
        <router-link to="/" class="logo-area">
          <div class="zap-logo">
            <span class="logo-bold">RECHARGE</span>
            <span class="logo-italic">ZAP</span>
          </div>
        </router-link>
        <router-link to="/" class="back-link">&larr; Back to Home</router-link>
      </div>
    </header>

    <!-- Main Content -->
    <main class="content-body">
      <div class="policy-header">
        <h1>Privacy Policy</h1>
        <p>Last updated: August 2026</p>
      </div>

      <div class="policy-content">
        <section>
          <h2>1. Introduction</h2>
          <p>Welcome to RechargeZap. We value your privacy and are committed to protecting your personal data. This privacy policy describes how we collect, use, and share information when you use our mobile application and web services.</p>
        </section>

        <section>
          <h2>2. Data We Collect</h2>
          <p>We collect information to provide better services to all our users. This includes:</p>
          <ul>
            <li>Personal identification details (Name, Email, Mobile Number).</li>
            <li>Wallet activity and transaction logs.</li>
            <li>Device configuration details when using the mobile application.</li>
          </ul>
        </section>

        <section>
          <h2>3. How We Use Data</h2>
          <p>We utilize the collected information to manage user accounts, process telecom activations and bill payments, verify transactions via Razorpay payment gateway, and secure the network downlines.</p>
        </section>

        <section>
          <h2>4. Security</h2>
          <p>We implement bank-grade secure socket layers (SSL), end-to-end encryption protocols, and MySQL connection pooling to protect all data against unauthorized access, alterations, or destructions.</p>
        </section>
      </div>
    </main>

    <!-- Footer -->
    <footer class="footer">
      <p>&copy; 2026 RechargeZap. All rights reserved.</p>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'PrivacyPolicy'
}
</script>

<style scoped>
.page-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: #fafbfc;
  color: #1e293b;
  font-family: 'Inter', system-ui, sans-serif;
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
.zap-logo {
  display: flex;
  align-items: center;
  font-size: 1.5rem;
  color: #ffffff;
}
.logo-bold {
  font-weight: 900;
}
.logo-italic {
  font-weight: 300;
  font-style: italic;
  margin-left: 2px;
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
