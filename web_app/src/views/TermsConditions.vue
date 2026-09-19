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
          <p>By downloading, installing, or using the SR Digital Seva mobile application or web portal, you agree to be bound by these Terms &amp; Conditions. If you do not agree to all of these terms, please do not use our platform.</p>
        </section>

        <section>
          <h2>2. Platform Scope</h2>
          <p>SR Digital Seva operates exclusively as a CAPTCHA Work platform. All legacy service references (such as telecom recharges, DTH, bill payments, and unrelated commission models) are completely obsolete and disclaimed.</p>
        </section>

        <section>
          <h2>3. User Account</h2>
          <p>Users must provide accurate registration details, including a valid 10-digit mobile number and email address. Users are responsible for keeping account credentials confidential. Each user ID allows only one mobile number, email, and bank account. Users must not share, sell, transfer, or allow unauthorized persons to use their account.</p>
        </section>

        <section>
          <h2>4. Work Requirements</h2>
          <p>Users must perform the available CAPTCHA work themselves and follow the required accuracy, quality, and performance standards. Work that is incomplete, rejected, invalid, or does not meet the applicable requirements will not qualify for earnings.</p>
        </section>

        <section>
          <h2>5. Prohibited Activities</h2>
          <p>Fraudulent activity, manipulation, automated abuse, bot usage, unauthorized access, fake information, duplicate or misleading accounts, or any misuse of the platform is strictly prohibited. Violation of platform rules may result in account restriction, suspension, or immediate termination.</p>
        </section>

        <section>
          <h2>6. Payments &amp; Earnings</h2>
          <p>Where payments or earnings are applicable, they are subject to verification, eligibility, completed and accepted work, applicable platform rules, and required processing procedures.</p>
        </section>

        <section>
          <h2>7. Platform Changes</h2>
          <p>Work availability, work requirements, features, procedures, and policies may be changed, suspended, or discontinued when reasonably required for operational, security, legal, regulatory, or business purposes.</p>
        </section>

        <section>
          <h2>8. User Responsibility</h2>
          <p>Users are responsible for reading and understanding the Terms &amp; Conditions, Privacy Policy, work requirements, and applicable guidelines before participating.</p>
        </section>

        <section>
          <h2>9. No Employment Guarantee</h2>
          <p>Participation in the SR Digital Seva CAPTCHA Work platform does not by itself create an employment relationship or guarantee employment.</p>
        </section>

        <section>
          <h2>10. Acceptance</h2>
          <p>By creating an account and using the platform, the user confirms that they have reviewed and agreed to the applicable Terms &amp; Conditions and Privacy Policy.</p>
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
