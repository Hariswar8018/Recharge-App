<template>
  <div class="landing-container">
    <!-- Header -->
    <header class="header">
      <div class="header-content">
        <div class="logo-area" @click="scrollTo('hero')">
          <svg class="logo-svg" viewBox="0 0 100 100" width="40" height="40">
            <circle cx="50" cy="50" r="45" fill="none" stroke="#0052cc" stroke-width="8"/>
            <path d="M 30 50 L 45 65 L 70 35" fill="none" stroke="#e01a22" stroke-width="8" stroke-linecap="round"/>
          </svg>
          <span class="brand-name">SR DIGITAL SEVA <span class="brand-sub">KENDRAM</span></span>
        </div>
        <nav class="nav-links">
          <a href="#about" @click.prevent="scrollTo('about')">About Us</a>
          <a href="#steps" @click.prevent="scrollTo('steps')">How It Works</a>
          <a href="#contact" @click.prevent="scrollTo('contact')">Contact Us</a>
          <router-link to="/admin-login" class="nav-btn admin-login-btn">Admin Portal</router-link>
        </nav>
      </div>
    </header>

    <!-- Hero Section -->
    <section id="hero" class="hero-section">
      <div class="hero-content">
        <div class="badge">🚀 ALL-IN-ONE DIGITAL WALLET</div>
        <h1 class="hero-title">Your Ultimate Platform for <span class="highlight">Smart Payments</span></h1>
        <p class="hero-subtitle">
          Recharge mobile connections, settle electricity invoices, pay DTH subscriptions, manage FastTag, and complete water bill payments instantly with our ultra-secure gateway.
        </p>

        <div class="cta-buttons">
          <!-- Download Button -->
          <a href="#" class="cta-btn download-btn">
            <svg class="playstore-icon" viewBox="0 0 24 24" width="24" height="24">
              <path d="M3,5.27V18.73c0,0.89,0.97,1.44,1.73,0.99l11.45-6.73a1.15,1.15,0,0,0,0-1.98L4.73,4.28C3.97,3.83,3,4.38,3,5.27Z" fill="#00e676"/>
              <path d="M17.15,11.3,14.65,9.83l-3.32,3.32,3.32,3.32,2.5-1.47A1.15,1.15,0,0,0,17.15,11.3Z" fill="#ffeb3b"/>
              <path d="M3.24,4.41l8.09,8.09L3.24,20.59a1,1,0,0,1-.24-.69V5.1A1,1,0,0,1,3.24,4.41Z" fill="#2196f3"/>
              <path d="M11.33,12.5l8.09,8.09a1,1,0,0,1-.69.24H5.1a1,1,0,0,1-.69-.24Z" fill="#f44336"/>
            </svg>
            <div class="btn-text">
              <span class="small-text">GET IT ON</span>
              <span class="large-text">Google Play</span>
            </div>
          </a>

          <!-- Admin Portal Button -->
          <router-link to="/admin-login" class="cta-btn portal-btn">
            <svg class="portal-icon" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
              <path d="M12 8v4"/>
              <path d="M12 16h.01"/>
            </svg>
            <div class="btn-text">
              <span class="small-text">MANAGEMENT CONTROL</span>
              <span class="large-text">Admin Panel</span>
            </div>
          </router-link>
        </div>
      </div>

      <!-- Hero Visual -->
      <div class="hero-visual">
        <div class="mockup-container">
          <div class="phone-mockup">
            <div class="screen-content">
              <div class="mockup-header">
                <span class="mockup-logo">SR DIGITAL SEVA</span>
                <span class="mockup-bell">🔔</span>
              </div>
              <div class="mockup-balance">
                <span class="bal-label">Your Wallet Balance</span>
                <span class="bal-amount">₹ 6,700.00</span>
              </div>
              <div class="mockup-actions">
                <div class="action-item">Add Money</div>
                <div class="action-item active">Subscribe</div>
                <div class="action-item">Cashout</div>
              </div>
              <div class="mockup-grid">
                <div class="grid-item">📱<br>Prepaid</div>
                <div class="grid-item">⚡<br>Electricity</div>
                <div class="grid-item">📡<br>DTH</div>
                <div class="grid-item">🚗<br>FastTag</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- About Section -->
    <section id="about" class="about-section">
      <div class="section-header">
        <h2>Why Choose SR Digital Seva?</h2>
        <p>Providing the most reliable digital payment experience across the nation.</p>
      </div>
      <div class="features-grid">
        <div class="feature-card">
          <div class="feature-icon">🛡️</div>
          <h3>Bank-Grade Security</h3>
          <p>Every transaction is protected by end-to-end encryption, multi-factor authorization, and real-time fraud monitoring.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">⚡</div>
          <h3>Lightning Fast Settlement</h3>
          <p>Get instant recharges and automatic receipt generation. Zero delays, 100% confirmation rate.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">💸</div>
          <h3>Affiliate Earnings</h3>
          <p>Grow your income by inviting team members. Earn commissions on every bill payment made within your group.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">☎️</div>
          <h3>24/7 Dedicated Support</h3>
          <p>Our global assistance team is always online to help resolve payment inquiries and account issues.</p>
        </div>
      </div>
    </section>

    <!-- Steps Section -->
    <section id="steps" class="steps-section">
      <div class="section-header">
        <h2>Start Recharging in 3 Simple Steps</h2>
        <p>Download our Android application and configure your secure account today.</p>
      </div>
      <div class="steps-container">
        <div class="step-card">
          <div class="step-num">01</div>
          <h3>Create an Account</h3>
          <p>Download our official Android app from the Google Play Store, sign up with your email, mobile number, and set up your password.</p>
        </div>
        <div class="step-arrow">➔</div>
        <div class="step-card">
          <div class="step-num">02</div>
          <h3>Load Wallet Balance</h3>
          <p>Easily top up your digital wallet using various payment methods including UPI, cards, and net banking.</p>
        </div>
        <div class="step-arrow">➔</div>
        <div class="step-card">
          <div class="step-num">03</div>
          <h3>Recharge & Pay Bills</h3>
          <p>Select your service, fill in the consumer details, and settle the payment instantly from your wallet balance.</p>
        </div>
      </div>
    </section>

    <!-- Contact Us Section -->
    <section id="contact" class="contact-section">
      <div class="section-header">
        <h2>Get in Touch with Us</h2>
        <p>Have questions about transactions or team membership? Drop us a line.</p>
      </div>
      <div class="contact-grid">
        <!-- Contact Information -->
        <div class="contact-info">
          <div class="info-item">
            <span class="info-icon">📍</span>
            <div>
              <h4>Our Location</h4>
              <p>SR Digital Seva Kendram, Tech Hub Complex, Main Street, Delhi, India</p>
            </div>
          </div>
          <div class="info-item">
            <span class="info-icon">✉️</span>
            <div>
              <h4>Email Address</h4>
              <p>support@srdigitalseva.com</p>
            </div>
          </div>
          <div class="info-item">
            <span class="info-icon">📞</span>
            <div>
              <h4>Phone Number</h4>
              <p>+91 98765 43210</p>
            </div>
          </div>
          <div class="info-item">
            <span class="info-icon">💬</span>
            <div>
              <h4>Support Hours</h4>
              <p>Monday - Sunday (24/7 Assistance)</p>
            </div>
          </div>
        </div>

        <!-- Contact Form -->
        <form @submit.prevent="handleContactSubmit" class="contact-form">
          <div class="form-row">
            <div class="form-group">
              <label>Your Name</label>
              <input type="text" v-model="contactForm.name" placeholder="Enter Full Name" required />
            </div>
            <div class="form-group">
              <label>Email Address</label>
              <input type="email" v-model="contactForm.email" placeholder="Enter Email" required />
            </div>
          </div>
          <div class="form-group">
            <label>Subject</label>
            <input type="text" v-model="contactForm.subject" placeholder="What is this about?" required />
          </div>
          <div class="form-group">
            <label>Message</label>
            <textarea rows="5" v-model="contactForm.message" placeholder="Type your message here..." required></textarea>
          </div>
          <button type="submit" class="submit-btn" :disabled="formSubmitted">
            <span v-if="formSubmitted">Message Sent Successfully! ✓</span>
            <span v-else>Send Message &rarr;</span>
          </button>
        </form>
      </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
      <div class="footer-content">
        <div class="footer-brand">
          <svg class="logo-svg" viewBox="0 0 100 100" width="30" height="30">
            <circle cx="50" cy="50" r="45" fill="none" stroke="#fff" stroke-width="8"/>
            <path d="M 30 50 L 45 65 L 70 35" fill="none" stroke="#ffeb3b" stroke-width="8" stroke-linecap="round"/>
          </svg>
          <span>SR DIGITAL SEVA</span>
        </div>
        <p class="copyright">&copy; 2026 SR Digital Seva Kendram. All rights reserved.</p>
        <div class="footer-links">
          <a href="#">Privacy Policy</a>
          <a href="#">Terms of Service</a>
          <a href="#">Support</a>
        </div>
      </div>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'LandingPage',
  data() {
    return {
      contactForm: {
        name: '',
        email: '',
        subject: '',
        message: ''
      },
      formSubmitted: false
    }
  },
  methods: {
    scrollTo(id) {
      const element = document.getElementById(id);
      if (element) {
        element.scrollIntoView({ behavior: 'smooth' });
      }
    },
    handleContactSubmit() {
      this.formSubmitted = true;
      setTimeout(() => {
        this.contactForm.name = '';
        this.contactForm.email = '';
        this.contactForm.subject = '';
        this.contactForm.message = '';
        this.formSubmitted = false;
      }, 3000);
    }
  }
}
</script>

<style scoped>
.landing-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  width: 100%;
  background: linear-gradient(135deg, #f3f6ff 0%, #ffffff 50%, #ebf1ff 100%);
  color: #1e293b;
  font-family: 'Inter', system-ui, sans-serif;
  overflow-x: hidden;
}

.header {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(16px);
  border-bottom: 1px solid rgba(0, 82, 204, 0.08);
  position: sticky;
  top: 0;
  z-index: 100;
  width: 100%;
}

.header-content {
  width: 100%;
  max-width: 1440px;
  margin: 0 auto;
  padding: 1.2rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-sizing: border-box;
}

.logo-area {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
}

.brand-name {
  font-weight: 900;
  font-size: 1.35rem;
  letter-spacing: 0.5px;
  color: #0052cc;
}

.brand-sub {
  color: #e01a22;
}

.nav-links {
  display: flex;
  align-items: center;
  gap: 2.25rem;
}

.nav-links a {
  color: #475569;
  text-decoration: none;
  font-weight: 600;
  font-size: 0.95rem;
  transition: color 0.2s;
}

.nav-links a:hover {
  color: #0052cc;
}

.nav-btn {
  padding: 0.65rem 1.4rem;
  border-radius: 10px;
  font-weight: 700;
  font-size: 0.9rem;
  text-decoration: none;
  transition: all 0.3s ease;
}

.admin-login-btn {
  background: #0052cc;
  color: white !important;
  border: 1px solid transparent;
}

.admin-login-btn:hover {
  background: #004099;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 82, 204, 0.2);
}

/* Sections Common */
section {
  width: 100%;
  max-width: 1440px;
  margin: 0 auto;
  padding: 6rem 2rem;
  box-sizing: border-box;
}

.section-header {
  text-align: center;
  margin-bottom: 4rem;
  max-width: 700px;
  margin-left: auto;
  margin-right: auto;
}

.section-header h2 {
  font-size: 2.5rem;
  font-weight: 850;
  color: #0f172a;
  letter-spacing: -0.75px;
  margin: 0 0 1rem;
}

.section-header p {
  font-size: 1.1rem;
  color: #64748b;
  line-height: 1.5;
}

/* Hero Section */
.hero-section {
  display: grid;
  grid-template-columns: 1.1fr 0.9fr;
  align-items: center;
  gap: 5rem;
  padding-top: 4rem;
  padding-bottom: 4rem;
}

@media (max-width: 960px) {
  .hero-section {
    grid-template-columns: 1fr;
    text-align: center;
    gap: 3.5rem;
  }
}

.hero-content {
  display: flex;
  flex-direction: column;
  gap: 1.75rem;
  align-items: flex-start;
}

@media (max-width: 960px) {
  .hero-content {
    align-items: center;
  }
}

.badge {
  background: rgba(0, 82, 204, 0.08);
  color: #0052cc;
  padding: 0.5rem 1rem;
  border-radius: 999px;
  font-size: 0.8rem;
  font-weight: 750;
  letter-spacing: 1px;
}

.hero-title {
  font-size: 4rem;
  font-weight: 900;
  line-height: 1.1;
  letter-spacing: -1.5px;
  color: #0f172a;
  margin: 0;
}

.hero-title .highlight {
  background: linear-gradient(120deg, #0052cc, #0080ff);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.hero-subtitle {
  font-size: 1.25rem;
  line-height: 1.6;
  color: #475569;
  margin: 0;
}

.cta-buttons {
  display: flex;
  gap: 1.25rem;
}

@media (max-width: 600px) {
  .cta-buttons {
    flex-direction: column;
    width: 100%;
  }
}

.cta-btn {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  padding: 0.85rem 1.75rem;
  border-radius: 14px;
  text-decoration: none;
  font-weight: 700;
  transition: all 0.3s ease;
  min-width: 220px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.04);
  box-sizing: border-box;
}

.download-btn {
  background: #0f172a;
  color: white;
}

.download-btn:hover {
  background: #000;
  transform: translateY(-3px);
  box-shadow: 0 12px 20px rgba(0, 0, 0, 0.15);
}

.portal-btn {
  background: white;
  color: #0052cc;
  border: 2px solid #0052cc;
}

.portal-btn:hover {
  background: #f0f4ff;
  transform: translateY(-3px);
  box-shadow: 0 12px 20px rgba(0, 82, 204, 0.1);
}

.btn-text {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  text-align: left;
}

.small-text {
  font-size: 0.7rem;
  opacity: 0.85;
}

.large-text {
  font-size: 1.15rem;
  line-height: 1.1;
}

.hero-visual {
  display: flex;
  justify-content: center;
}

.mockup-container {
  background: linear-gradient(135deg, rgba(0, 82, 204, 0.08) 0%, rgba(224, 26, 34, 0.04) 100%);
  padding: 2.5rem;
  border-radius: 40px;
  border: 1px solid rgba(255, 255, 255, 0.7);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.03);
}

.phone-mockup {
  width: 280px;
  height: 560px;
  background: #ffffff;
  border: 10px solid #0f172a;
  border-radius: 44px;
  box-shadow: 0 25px 60px rgba(0, 0, 0, 0.18);
  overflow: hidden;
  position: relative;
}

.screen-content {
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  height: 100%;
  gap: 1.5rem;
  box-sizing: border-box;
}

.mockup-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1.5px solid #f1f5f9;
  padding-bottom: 0.75rem;
}

.mockup-logo {
  font-weight: 900;
  color: #0052cc;
  font-size: 0.85rem;
}

.mockup-balance {
  background: #0052cc;
  color: white;
  padding: 1.2rem;
  border-radius: 18px;
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.bal-label {
  font-size: 0.75rem;
  opacity: 0.9;
}

.bal-amount {
  font-size: 1.5rem;
  font-weight: 800;
}

.mockup-actions {
  display: flex;
  gap: 0.4rem;
  background: #f1f5f9;
  padding: 0.3rem;
  border-radius: 10px;
}

.action-item {
  flex: 1;
  text-align: center;
  font-size: 0.65rem;
  font-weight: 700;
  padding: 0.4rem 0;
  border-radius: 6px;
  color: #64748b;
}

.action-item.active {
  background: white;
  color: #0052cc;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.mockup-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.85rem;
}

.grid-item {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
  height: 80px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  font-weight: 700;
  color: #334155;
  gap: 0.25rem;
}

/* About Section */
.about-section {
  background: white;
  border-top: 1px solid rgba(0, 82, 204, 0.05);
  border-bottom: 1px solid rgba(0, 82, 204, 0.05);
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2.5rem;
}

.feature-card {
  padding: 2.5rem;
  border-radius: 20px;
  background: #f8fafc;
  border: 1px solid #f1f5f9;
  transition: all 0.3s;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 15px 30px rgba(0, 82, 204, 0.06);
  border-color: rgba(0, 82, 204, 0.1);
  background: white;
}

.feature-icon {
  font-size: 2.5rem;
  margin-bottom: 1.5rem;
}

.feature-card h3 {
  font-size: 1.25rem;
  font-weight: 800;
  color: #0f172a;
  margin: 0 0 0.75rem;
}

.feature-card p {
  color: #64748b;
  font-size: 0.95rem;
  line-height: 1.6;
  margin: 0;
}

/* Steps Section */
.steps-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 2rem;
}

@media (max-width: 900px) {
  .steps-container {
    flex-direction: column;
    gap: 3rem;
  }
  .step-arrow {
    transform: rotate(90deg);
  }
}

.step-card {
  flex: 1;
  text-align: center;
  padding: 2rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.step-num {
  font-size: 3.5rem;
  font-weight: 900;
  color: rgba(0, 82, 204, 0.15);
  line-height: 1;
}

.step-card h3 {
  font-size: 1.35rem;
  font-weight: 800;
  color: #0f172a;
  margin: 0;
}

.step-card p {
  color: #64748b;
  font-size: 0.95rem;
  line-height: 1.6;
  margin: 0;
}

.step-arrow {
  font-size: 2rem;
  color: #0052cc;
  font-weight: 900;
}

/* Contact Section */
.contact-section {
  background: white;
}

.contact-grid {
  display: grid;
  grid-template-columns: 0.8fr 1.2fr;
  gap: 4rem;
}

@media (max-width: 900px) {
  .contact-grid {
    grid-template-columns: 1fr;
    gap: 3rem;
  }
}

.contact-info {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.info-item {
  display: flex;
  gap: 1.25rem;
}

.info-icon {
  font-size: 1.75rem;
  background: #f0f4ff;
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.info-item h4 {
  margin: 0 0 0.25rem;
  font-size: 1.05rem;
  font-weight: 750;
  color: #0f172a;
}

.info-item p {
  margin: 0;
  color: #64748b;
  font-size: 0.95rem;
}

.contact-form {
  background: #f8fafc;
  padding: 2.5rem;
  border-radius: 24px;
  border: 1px solid #f1f5f9;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
}

@media (max-width: 600px) {
  .form-row {
    grid-template-columns: 1fr;
  }
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  font-size: 0.85rem;
  font-weight: 700;
  color: #475569;
}

.form-group input, .form-group textarea {
  padding: 0.85rem 1.1rem;
  border-radius: 12px;
  border: 1.5px solid #e2e8f0;
  font-family: inherit;
  font-size: 0.95rem;
  background: white;
  transition: all 0.2s;
}

.form-group input:focus, .form-group textarea:focus {
  outline: none;
  border-color: #0052cc;
  box-shadow: 0 0 0 4px rgba(0, 82, 204, 0.08);
}

.submit-btn {
  background: #0052cc;
  color: white;
  font-weight: 700;
  font-size: 1rem;
  border: none;
  padding: 1rem;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s;
}

.submit-btn:hover:not(:disabled) {
  background: #004099;
}

.submit-btn:disabled {
  background: #16a34a;
  cursor: not-allowed;
}

/* Footer */
.footer {
  background: #0f172a;
  color: white;
  padding: 4rem 2rem;
  width: 100%;
}

.footer-content {
  max-width: 1440px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-sizing: border-box;
}

@media (max-width: 768px) {
  .footer-content {
    flex-direction: column;
    gap: 1.5rem;
    text-align: center;
  }
}

.footer-brand {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-weight: 900;
  letter-spacing: 0.5px;
}

.copyright {
  font-size: 0.9rem;
  color: #94a3b8;
  margin: 0;
}

.footer-links {
  display: flex;
  gap: 2rem;
}

.footer-links a {
  color: #94a3b8;
  text-decoration: none;
  font-size: 0.9rem;
  transition: color 0.2s;
}

.footer-links a:hover {
  color: white;
}
</style>
