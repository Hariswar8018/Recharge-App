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
      <div class="contact-header">
        <h1>Contact Us</h1>
        <p>Get in touch with the RechargeZap support team. We're here to help you 24/7.</p>
      </div>

      <div class="contact-grid">
        <!-- Info Cards -->
        <div class="info-column">
          <div class="info-card">
            <div class="icon">📍</div>
            <div>
              <h3>Our Location</h3>
              <p>RechargeZap Kendram, Tech Hub Complex, Main Street, Delhi, India</p>
            </div>
          </div>
          <div class="info-card">
            <div class="icon">✉️</div>
            <div>
              <h3>Email Support</h3>
              <p>support@rechargezap.in</p>
            </div>
          </div>
          <div class="info-card">
            <div class="icon">📞</div>
            <div>
              <h3>Phone Hotline</h3>
              <p>+91 98765 43210</p>
            </div>
          </div>
        </div>

        <!-- Form -->
        <form @submit.prevent="handleSubmit" class="contact-form">
          <div class="form-group">
            <label>Name</label>
            <input type="text" v-model="form.name" placeholder="Your Name" required />
          </div>
          <div class="form-group">
            <label>Email Address</label>
            <input type="email" v-model="form.email" placeholder="Your Email Address" required />
          </div>
          <div class="form-group">
            <label>Message</label>
            <textarea rows="5" v-model="form.message" placeholder="Type your message here..." required></textarea>
          </div>
          <button type="submit" class="submit-btn" :disabled="submitted">
            <span v-if="submitted">Thank you! Message Sent.</span>
            <span v-else>Send Message</span>
          </button>
        </form>
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
  name: 'ContactUs',
  data() {
    return {
      form: { name: '', email: '', message: '' },
      submitted: false
    }
  },
  methods: {
    handleSubmit() {
      this.submitted = true;
      setTimeout(() => {
        this.form.name = '';
        this.form.email = '';
        this.form.message = '';
        this.submitted = false;
      }, 3000);
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
  max-width: 1200px;
  margin: 0 auto;
  padding: 4rem 2rem;
  width: 100%;
  box-sizing: border-box;
}
.contact-header {
  text-align: center;
  margin-bottom: 3rem;
}
.contact-header h1 {
  font-size: 2.5rem;
  font-weight: 900;
  color: #0f172a;
  margin-bottom: 0.5rem;
}
.contact-header p {
  color: #64748b;
  font-size: 1.1rem;
}
.contact-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 3rem;
}
@media (max-width: 768px) {
  .contact-grid {
    grid-template-columns: 1fr;
  }
}
.info-column {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}
.info-card {
  display: flex;
  gap: 1rem;
  background: white;
  padding: 1.5rem;
  border-radius: 14px;
  border: 1px solid #e2e8f0;
}
.info-card h3 {
  margin: 0 0 0.25rem;
  color: #0052cc;
}
.info-card p {
  margin: 0;
  color: #64748b;
}
.icon {
  font-size: 1.5rem;
}
.contact-form {
  background: white;
  padding: 2.5rem;
  border-radius: 14px;
  border: 1px solid #e2e8f0;
}
.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1.25rem;
}
.form-group label {
  font-weight: bold;
  font-size: 0.9rem;
}
.form-group input,
.form-group textarea {
  padding: 0.75rem;
  border-radius: 8px;
  border: 1px solid #cbd5e1;
}
.submit-btn {
  background: #0052cc;
  color: white;
  border: none;
  padding: 0.85rem;
  border-radius: 8px;
  font-weight: bold;
  cursor: pointer;
  width: 100%;
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
