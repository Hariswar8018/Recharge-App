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
        <span class="delete-icon-badge">🗑️</span>
        <h1>Account &amp; Data Deletion Request</h1>
        <p>Google Play Policy Compliant Account Deletion Portal</p>
      </div>

      <div class="email-action-box">
        <div class="action-box-header">
          <span class="action-icon">📩</span>
          <div>
            <h2>Request Account Deletion via Email</h2>
            <p>Fill in your registered details below to send an automated deletion request to our support team.</p>
          </div>
        </div>

        <form @submit.prevent="sendDeletionEmail" class="deletion-form">
          <div class="form-group">
            <label for="regMobile">Registered Mobile Number (10 digits) *</label>
            <input
              id="regMobile"
              v-model="mobileNumber"
              type="tel"
              placeholder="e.g. 9876543210"
              pattern="[0-9]{10}"
              required
            />
          </div>

          <div class="form-group">
            <label for="regEmail">Registered Email Address *</label>
            <input
              id="regEmail"
              v-model="emailAddress"
              type="email"
              placeholder="e.g. user@gmail.com"
              required
            />
          </div>

          <div class="form-group">
            <label for="deletionReason">Reason for Deletion (Optional)</label>

            <textarea
              id="deletionReason"
              v-model="deletionReason"
              rows="3"
              placeholder="Tell us why you wish to delete your account..."
            ></textarea>
          </div>

          <button type="submit" class="email-btn">
            <span>✉️ Send Deletion Request Email</span>
          </button>
        </form>

        <div class="direct-mailto-link">
          <span>Or email us directly at: </span>
          <a :href="directMailtoUrl" class="mailto-link">support@srdigitalseva.com</a>
        </div>
      </div>

      <div class="policy-content">
        <section>
          <h2>1. Overview of Account Deletion</h2>
          <p>
            In compliance with Google Play Data Safety requirements, SR Digital Seva allows all registered users to request the permanent deletion of their account and associated personal data. When an account deletion request is processed, your user profile, authentication credentials, and data associations are permanently erased from our primary databases.
          </p>
        </section>

        <section>
          <h2>2. Data That Will Be Permanently Deleted</h2>
          <p>Upon verifying your request, the following information will be permanently purged:</p>
          <ul>
            <li><strong>Personal Credentials:</strong> Your Full Name, Email Address, and 10-digit Mobile Number.</li>
            <li><strong>Authentication Data:</strong> Password hashes, login tokens, and device identifiers.</li>
            <li><strong>Wallet &amp; Earnings Data:</strong> Main Wallet ledger records, Fund Wallet balances, and CAPTCHA work history.</li>
            <li><strong>Network &amp; Referral Links:</strong> Sponsor ID ties, team tree registrations, and referral reward logs.</li>
            <li><strong>KYC &amp; Bank Details:</strong> Verified bank account details and UPI addresses associated with your account.</li>
          </ul>
        </section>

        <section>
          <h2>3. Data Retention Policy &amp; Timelines</h2>
          <p>
            Account deletion requests are processed manually by our privacy team within <strong>48 to 72 hours</strong> after email verification. Once deleted, this action is irreversible, and your account cannot be recovered.
          </p>
          <p>
            <em>Note: Certain financial ledger records may be retained in anonymized format for accounting, legal, and anti-fraud auditing compliance as mandated by regulatory guidelines.</em>
          </p>
        </section>

        <section>
          <h2>4. Important Notice Before Requesting Deletion</h2>
          <div class="warning-alert-card">
            ⚠️ <strong>Warning:</strong> Deleting your account will forfeit any remaining unwithdrawn wallet balance. Please ensure you withdraw all active funds before submitting your account deletion request.
          </div>
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
  name: 'DeleteAccount',
  data() {
    return {
      mobileNumber: '',
      emailAddress: '',
      deletionReason: ''
    }
  },
  computed: {
    directMailtoUrl() {
      const subject = encodeURIComponent('Account Deletion Request - SR Digital Seva')
      const body = encodeURIComponent(
        `Hello SR Digital Seva Support Team,\n\nI would like to request the permanent deletion of my account and all associated data.\n\n` +
        `Account Details:\n` +
        `- Registered Mobile: ${this.mobileNumber || '[Enter Mobile]'}\n` +
        `- Registered Email: ${this.emailAddress || '[Enter Email]'}\n` +
        `- Reason: ${this.deletionReason || 'N/A'}\n\n` +
        `Thank you.`
      )
      return `mailto:support@srdigitalseva.com?subject=${subject}&body=${body}`
    }
  },
  methods: {
    sendDeletionEmail() {
      window.location.href = this.directMailtoUrl
    }
  }
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
  padding: 3rem 1.5rem;
  width: 100%;
  box-sizing: border-box;
}

.policy-header {
  text-align: center;
  margin-bottom: 2.5rem;
}

.delete-icon-badge {
  font-size: 3rem;
  display: block;
  margin-bottom: 0.5rem;
}

.policy-header h1 {
  font-size: 2.2rem;
  font-weight: 900;
  color: #0f172a;
  margin: 0 0 0.5rem;
}

.policy-header p {
  color: #64748b;
  font-size: 1rem;
  margin: 0;
}

.email-action-box {
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  padding: 1.75rem;
  box-shadow: 0 10px 25px rgba(0, 82, 204, 0.06);
  margin-bottom: 3rem;
}

.action-box-header {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.action-icon {
  font-size: 2rem;
}

.action-box-header h2 {
  font-size: 1.25rem;
  font-weight: 800;
  color: #0f172a;
  margin: 0 0 0.25rem;
}

.action-box-header p {
  font-size: 0.88rem;
  color: #64748b;
  margin: 0;
}

.deletion-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.form-group label {
  font-size: 0.88rem;
  font-weight: 700;
  color: #334155;
}

.form-group input,
.form-group textarea {
  width: 100%;
  box-sizing: border-box;
  padding: 0.75rem 1rem;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  font-size: 0.92rem;
  font-family: inherit;
  background: #f8fafc;
  color: #0f172a;
  outline: none;
  transition: all 0.2s ease;
}

.form-group input:focus,
.form-group textarea:focus {
  background: white;
  border-color: #0052cc;
  box-shadow: 0 0 0 3px rgba(0, 82, 204, 0.15);
}

.email-btn {
  background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
  color: white;
  border: none;
  border-radius: 10px;
  padding: 0.9rem 1.5rem;
  font-size: 1rem;
  font-weight: 800;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 14px rgba(220, 38, 38, 0.3);
}

.email-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 18px rgba(220, 38, 38, 0.4);
}

.direct-mailto-link {
  text-align: center;
  margin-top: 1.25rem;
  font-size: 0.88rem;
  color: #64748b;
}

.mailto-link {
  color: #0052cc;
  font-weight: 700;
  text-decoration: none;
}

.mailto-link:hover {
  text-decoration: underline;
}

.policy-content section {
  margin-bottom: 2rem;
}

.policy-content h2 {
  font-size: 1.35rem;
  color: #0052cc;
  margin-bottom: 0.75rem;
  font-weight: 800;
}

.policy-content p,
.policy-content li {
  color: #475569;
  line-height: 1.6;
}

.policy-content ul {
  padding-left: 1.5rem;
}

.warning-alert-card {
  background: #fef2f2;
  border: 1px solid #fecaca;
  color: #991b1b;
  padding: 1rem 1.25rem;
  border-radius: 10px;
  font-size: 0.9rem;
  line-height: 1.5;
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

@media (max-width: 600px) {
  .content-body {
    padding: 2rem 1rem;
  }
  .policy-header h1 {
    font-size: 1.75rem;
  }
  .email-action-box {
    padding: 1.25rem;
  }
}
</style>
