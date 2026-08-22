<template>
  <div class="landing-container">
    <!-- Header -->
    <header class="header">
      <div class="header-content">
        <div class="logo-area" @click="scrollTo('hero')">
          <div class="zap-logo">
            <span class="logo-bold">SR DIGITAL SEVA</span>
            <span class="logo-italic">KENDRAM</span>
          </div>
        </div>
        <nav class="nav-links">
          <a href="#services" @click.prevent="scrollTo('services')">Services</a>
          <a href="#commissions" @click.prevent="scrollTo('commissions')">Commissions</a>
          <a href="#about" @click.prevent="scrollTo('about')">About Us</a>
          <a href="#steps" @click.prevent="scrollTo('steps')">How It Works</a>
          <a href="#faq" @click.prevent="scrollTo('faq')">FAQs</a>
          <a href="#contact" @click.prevent="scrollTo('contact')">Contact Us</a>
          <router-link to="/admin-login" class="nav-btn admin-login-btn">Admin Portal</router-link>
        </nav>
      </div>
    </header>

    <!-- Top Action bar (Very top right below header) -->
    <div class="top-action-bar">
      <div class="top-action-content">
        <div class="playstore-download-info">
          <svg class="playstore-mini-icon" viewBox="0 0 24 24" width="24" height="24">
            <path d="M3,5.27V18.73c0,0.89,0.97,1.44,1.73,0.99l11.45-6.73a1.15,1.15,0,0,0,0-1.98L4.73,4.28C3.97,3.83,3,4.38,3,5.27Z" fill="#00e676"/>
            <path d="M17.15,11.3,14.65,9.83l-3.32,3.32,3.32,3.32,2.5-1.47A1.15,1.15,0,0,0,17.15,11.3Z" fill="#ffeb3b"/>
            <path d="M3.24,4.41l8.09,8.09L3.24,20.59a1,1,0,0,1-.24-.69V5.1A1,1,0,0,1,3.24,4.41Z" fill="#2196f3"/>
            <path d="M11.33,12.5l8.09,8.09a1,1,0,0,1-.69.24H5.1a1,1,0,0,1-.69-.24Z" fill="#f44336"/>
          </svg>
          <span class="download-text">Get our mobile application directly from Google Play Store!</span>
          <a href="#" class="top-mini-btn download-link">Download Now</a>
        </div>
        <div class="admin-portal-access">
          <span class="portal-text font-bold">Authorized Personnel:</span>
          <router-link to="/admin-login" class="top-mini-btn portal-link">Access Panel &rarr;</router-link>
        </div>
      </div>
    </div>

    <!-- Main Hero Section (Action-packed) -->
    <section class="hero-section" id="hero">
      <div class="hero-content">
        <div class="hero-badge">⚡ INSTANT ACTIVATIONS & BEST COMMISSION RATES</div>
        <h1 class="hero-title">
          India's Leading Platform for <span class="blue-highlight">Smart Payments</span> & Commissions
        </h1>
        <p class="hero-desc">
          Empowering retailers, distributors, and individuals to recharge mobile lines, settle utility bills, and manage local customer payments with unmatched commission margins.
        </p>

        <div class="hero-cta-buttons">
          <!-- Play Store Link -->
          <a href="#" class="hero-cta-btn playstore-btn">
            <svg class="playstore-svg" viewBox="0 0 24 24" width="28" height="28">
              <path d="M3,5.27V18.73c0,0.89,0.97,1.44,1.73,0.99l11.45-6.73a1.15,1.15,0,0,0,0-1.98L4.73,4.28C3.97,3.83,3,4.38,3,5.27Z" fill="#fff"/>
            </svg>
            <div class="btn-lbl">
              <span class="lbl-small">GET THE ANDROID APP</span>
              <span class="lbl-large">Google Play</span>
            </div>
          </a>

          <!-- Admin Login link -->
          <router-link to="/admin-login" class="hero-cta-btn admin-btn">
            <span class="admin-icon">⚙️</span>
            <div class="btn-lbl">
              <span class="lbl-small">PARTNER GATEWAY</span>
              <span class="lbl-large">Admin Dashboard</span>
            </div>
          </router-link>
        </div>

        <div class="hero-stats-mini">
          <div class="mini-stat">
            <span class="stat-num">8 Lakh+</span>
            <span class="stat-lbl">Active Users</span>
          </div>
          <div class="mini-stat">
            <span class="stat-num">99.99%</span>
            <span class="stat-lbl">Success Rate</span>
          </div>
          <div class="mini-stat">
            <span class="stat-num">Instant</span>
            <span class="stat-lbl">Settlements</span>
          </div>
        </div>
      </div>

      <!-- Hero Visual (Interactive Device Mockup) -->
      <div class="hero-visual">
        <div class="phone-frame">
          <div class="phone-screen">
            <div class="app-header">
              <div class="app-logo">SR DIGITAL SEVA</div>
              <div class="notification-dot">🔔</div>
            </div>
            
            <div class="app-balance-card">
              <div class="card-glow"></div>
              <span class="bal-title">Available Income Wallet</span>
              <span class="bal-value">₹ 14,850.50</span>
              <div class="card-footer">
                <span>Distributor Account</span>
                <span class="status-active">● Verified</span>
              </div>
            </div>

            <div class="app-quick-actions">
              <div class="quick-btn">➕ Fund Wallet</div>
              <div class="quick-btn active">⚡ Recharge</div>
              <div class="quick-btn">💸 Transfer</div>
            </div>

            <div class="app-services-grid">
              <div class="app-service-item">📱<span>Mobile</span></div>
              <div class="app-service-item">📡<span>DTH</span></div>
              <div class="app-service-item">⚡<span>Electricity</span></div>
              <div class="app-service-item">🚗<span>FASTag</span></div>
              <div class="app-service-item">💧<span>Water</span></div>
              <div class="app-service-item">🌐<span>Broadband</span></div>
            </div>

            <div class="app-recent-txn">
              <span class="txn-title">Recent Commission payout</span>
              <div class="txn-row">
                <span class="txn-op">Jio Recharge +4.5%</span>
                <span class="txn-amt text-green">+ ₹ 22.50</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Main Content Area -->
    <main class="main-content">
      <!-- Exciting Deals Banner -->
      <section class="banner-section">
        <div class="deals-banner">
          <div class="deals-icon-container">
            <svg class="ticket-icon" viewBox="0 0 64 64" width="60" height="60">
              <path d="M12 20h40v24H12z" fill="#ffe0b2"/>
              <path d="M16 16h32a4 4 0 0 1 4 4v4a4 4 0 0 0-4 4 4 4 0 0 0 4 4v4a4 4 0 0 1-4 4H16a4 4 0 0 1-4-4v-4a4 4 0 0 0 4-4 4 4 0 0 0-4-4v-4a4 4 0 0 1 4-4z" fill="#ffb74d" stroke="#f57c00" stroke-width="3"/>
              <line x1="24" y1="22" x2="24" y2="42" stroke="#f57c00" stroke-width="2" stroke-dasharray="4 4"/>
            </svg>
          </div>
          <div class="deals-text">
            <span class="deals-tag">EXCITING</span>
            <h2 class="deals-title">DEALS</h2>
            <p class="deals-desc">
              Discover exclusive deals and special promotions tailored for you. Act now to enjoy amazing savings and rewards on every purchase!
            </p>
          </div>
        </div>
      </section>

      <!-- Security Banner (Using image.png as background) -->
      <section class="banner-section">
        <div class="security-banner">
          <div class="security-content">
            <h2 class="security-title">Your Money, Always Secure.</h2>
            <p class="security-desc">
              Our platform offers secure, fast, and easy transactions for businesses and individuals, giving you peace of mind with every payment.
            </p>
          </div>
        </div>
      </section>

      <!-- NEW: Supported Services Grid Section -->
      <section id="services" class="services-showcase">
        <div class="section-header">
          <h2>Services We Support</h2>
          <p>Settle all primary consumer utility services instantly under one unified portal.</p>
        </div>
        <div class="services-showcase-grid">
          <div class="service-show-card">
            <div class="service-show-icon">📱</div>
            <h3>Prepaid Recharges</h3>
            <p>Instant activation for Jio, Airtel, Vi, and BSNL with operator plan lookups.</p>
          </div>
          <div class="service-show-card">
            <div class="service-show-icon">📡</div>
            <h3>DTH Activations</h3>
            <p>Fast renewals for Tata Play, Airtel Digital TV, Dish TV, and Sun Direct.</p>
          </div>
          <div class="service-show-card">
            <div class="service-show-icon">⚡</div>
            <h3>Electricity Bills</h3>
            <p>Check consumer bills and pay all state power boards instantly.</p>
          </div>
          <div class="service-show-card">
            <div class="service-show-icon">🚗</div>
            <h3>FASTag Top-ups</h3>
            <p>Recharge highway tags instantly for NHAI, SBI, HDFC, and Paytm FASTags.</p>
          </div>
          <div class="service-show-card">
            <div class="service-show-icon">💧</div>
            <h3>Water Bill Payments</h3>
            <p>Settle municipal water bills securely through BBPS integrations.</p>
          </div>
          <div class="service-show-card">
            <div class="service-show-icon">🌐</div>
            <h3>Broadband Services</h3>
            <p>Pay fiber and broadband bills for ACT, Airtel, JioFiber, and Hathaway.</p>
          </div>
        </div>
      </section>

      <!-- NEW: Distributor & Retailer Commission Section -->
      <section id="commissions" class="commission-section">
        <div class="section-header">
          <h2>Earn High Commissions on Recharges</h2>
          <p>Boost your retail margins by partnering with India's highest paying commission provider.</p>
        </div>
        <div class="commission-card-wrapper">
          <div class="commission-intro-card">
            <span class="card-accent">PARTNER BENEFIT</span>
            <h3>Highest Payout Rates</h3>
            <p>Whether you are a retailer or running a downline team of agents, SR Digital Seva Kendram guarantees maximum margins on every single transaction.</p>
            <div class="perks-list">
              <div class="perk-row">✓ Real-time commission credits</div>
              <div class="perk-row">✓ Fully separate Main and Fund Wallets</div>
              <div class="perk-row">✓ Downline agent tracking and reports</div>
            </div>
          </div>
          
          <div class="commission-table-card">
            <h3>Standard Commission Structure</h3>
            <div class="table-container">
              <table class="com-table">
                <thead>
                  <tr>
                    <th>Service Operator</th>
                    <th>Retailer Margin</th>
                    <th>Distributor Margin</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Jio Prepaid</td>
                    <td class="text-green font-bold">3.5%</td>
                    <td class="text-green font-bold">4.2%</td>
                  </tr>
                  <tr>
                    <td>Airtel Prepaid</td>
                    <td class="text-green font-bold">2.8%</td>
                    <td class="text-green font-bold">3.5%</td>
                  </tr>
                  <tr>
                    <td>Vi (Vodafone Idea)</td>
                    <td class="text-green font-bold">3.8%</td>
                    <td class="text-green font-bold">4.5%</td>
                  </tr>
                  <tr>
                    <td>DTH Recharges</td>
                    <td class="text-green font-bold">4.0%</td>
                    <td class="text-green font-bold">4.8%</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </section>

      <!-- Trust Badges & Customer Banner -->
      <section class="trust-section">
        <div class="brand-logos">
          <!-- Mastercard -->
          <div class="brand-logo-card">
            <div class="mastercard-circles">
              <span class="circle red"></span>
              <span class="circle yellow"></span>
            </div>
            <span class="brand-text font-bold">mastercard</span>
          </div>
          <!-- BHIM -->
          <div class="brand-logo-card">
            <span class="bhim-logo">BHIM <span class="bhim-sub">UPI</span></span>
          </div>
          <!-- VISA -->
          <div class="brand-logo-card">
            <span class="visa-logo font-bold">VISA</span>
          </div>
          <!-- RuPay -->
          <div class="brand-logo-card">
            <span class="rupay-logo italic">RuPay&gt;</span>
          </div>
        </div>

        <div class="customer-trust">
          <h2 class="trust-title">Trusted by 8 Lakh+ happy customers</h2>
          <div class="trust-underline"></div>
          <button class="cta-primary-btn" @click="scrollTo('contact')">
            Get in Touch &rarr;
          </button>
        </div>
      </section>

      <!-- Features Section -->
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

      <!-- QR Download Section -->
      <section class="download-section">
        <div class="download-grid">
          <!-- QR Area -->
          <div class="qr-panel">
            <div class="qr-container">
              <!-- Simulated QR Code -->
              <div class="qr-code">
                <div class="qr-pattern"></div>
              </div>
              <p class="qr-caption">Scan the QR code to Download our app now</p>
              <!-- Google Play Badge -->
              <a href="#" class="play-badge">
                <svg class="play-icon" viewBox="0 0 24 24" width="20" height="20">
                  <path d="M3,5.27V18.73c0,0.89,0.97,1.44,1.73,0.99l11.45-6.73a1.15,1.15,0,0,0,0-1.98L4.73,4.28C3.97,3.83,3,4.38,3,5.27Z" fill="#fff"/>
                </svg>
                <div class="badge-text">
                  <span class="get-it">GET IT ON</span>
                  <span class="g-play">Google Play</span>
                </div>
              </a>
            </div>
          </div>

          <!-- Bullet Points -->
          <div class="features-panel">
            <div class="feature-bullet">
              <div class="bullet-icon">📱</div>
              <div class="bullet-text">
                <h3>Scan the QR</h3>
                <p>Download the app instantly by scanning the QR code and start unlocking exclusive rewards!</p>
              </div>
            </div>
            <div class="feature-bullet">
              <div class="bullet-icon">🎁</div>
              <div class="bullet-text">
                <h3>Exclusive App offers</h3>
                <p>Unlock exciting deals and exclusive offers available only through our app.</p>
              </div>
            </div>
            <div class="feature-bullet">
              <div class="bullet-icon">🛡️</div>
              <div class="bullet-text">
                <h3>Safe and Secure</h3>
                <p>Your trust is our top priority—secure payments and peace of mind guaranteed with every transaction.</p>
              </div>
            </div>
            <div class="feature-bullet">
              <div class="bullet-icon">⚡</div>
              <div class="bullet-text">
                <h3>Faster, Smoother Experience</h3>
                <p>Enjoy a seamless, enriched app experience designed for speed and convenience.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- FAQ Section -->
      <section class="faq-section" id="faq">
        <h2 class="faq-section-title">Frequently asked questions</h2>
        <div class="faq-grid">
          <!-- Contact card -->
          <div class="faq-contact-card">
            <div class="chat-bubble-icon">💬</div>
            <h3>You have a different question?</h3>
            <p>If our FAQs don't cover your query, our customer service team is here to help.</p>
            <button class="faq-btn-contact" @click="scrollTo('contact')">Get in Touch</button>
          </div>

          <!-- FAQ Accordion -->
          <div class="faq-accordion">
            <div 
              v-for="(faq, index) in faqs" 
              :key="index" 
              class="faq-item"
              :class="{ active: activeFaq === index }"
            >
              <div class="faq-question" @click="toggleFaq(index)">
                <span>{{ faq.question }}</span>
                <span class="faq-toggle-icon">{{ activeFaq === index ? '−' : '+' }}</span>
              </div>
              <div class="faq-answer" v-show="activeFaq === index">
                <p>{{ faq.answer }}</p>
              </div>
            </div>
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
              <span v-else>Submit &rarr;</span>
            </button>
          </form>
        </div>
      </section>
    </main>

    <!-- Footer -->
    <footer class="footer">
      <div class="footer-content">
        <div class="footer-top">
          <div class="footer-left">
            <div class="zap-logo white-text">
              <span class="logo-bold">SR DIGITAL SEVA</span>
              <span class="logo-italic">KENDRAM</span>
            </div>
            <a href="#" class="play-badge footer-badge">
              <svg class="play-icon" viewBox="0 0 24 24" width="20" height="20">
                <path d="M3,5.27V18.73c0,0.89,0.97,1.44,1.73,0.99l11.45-6.73a1.15,1.15,0,0,0,0-1.98L4.73,4.28C3.97,3.83,3,4.38,3,5.27Z" fill="#fff"/>
              </svg>
              <div class="badge-text">
                <span class="get-it">GET IT ON</span>
                <span class="g-play">Google Play</span>
              </div>
            </a>
          </div>

          <div class="footer-links-grid">
            <div class="footer-col">
              <a href="#">ABOUT US</a>
              <router-link to="/contact">CONTACT US</router-link>
              <a href="#">REFUND POLICY</a>
            </div>
            <div class="footer-col">
              <a href="#">FAQs</a>
              <router-link to="/privacy-policy">PRIVACY POLICY</router-link>
              <a href="#">TERMS & CONDITIONS</a>
            </div>
          </div>
        </div>

        <div class="footer-divider"></div>

        <div class="footer-bottom">
          <p class="copyright">&copy; 2026 SR Digital Seva Kendram, All Rights Reserved</p>
          <div class="security-badges">
            <div class="sec-badge">🔒 SSL Secure</div>
            <div class="sec-badge">Verified by VISA</div>
            <div class="sec-badge">Mastercard SecureCode</div>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script>
import bannerImg from '../assets/image.png';

export default {
  name: 'LandingPage',
  data() {
    return {
      bannerImg,
      contactForm: {
        name: '',
        email: '',
        subject: '',
        message: ''
      },
      formSubmitted: false,
      activeFaq: null,
      faqs: [
        {
          question: 'What Payment Methods Are Available for Mobile Recharges on SR Digital Seva?',
          answer: 'We support all major payment networks including Credit/Debit Cards (Visa, Mastercard, RuPay), UPI (BHIM, Google Pay, PhonePe, Paytm), and major Net Banking providers to guarantee a seamless transaction experience.'
        },
        {
          question: 'How Can I Find and Choose the Best Recharge Plan for My Mobile Number?',
          answer: 'Our mobile application automatically fetches plans from your network operator (Jio, Airtel, Vi, BSNL) based on your circle and category choice, such as Unlimited, Data boosters, or Talktime packs.'
        },
        {
          question: 'What Should I Do If I Accidentally Recharge the Wrong Number?',
          answer: 'Recharges are processed instantly with telecom operators. We recommend double-checking the consumer ID/mobile number on our confirmation receipt sheet before completing the payment process.'
        },
        {
          question: 'How Can I Ensure My Mobile Recharge Is Successful and Safe?',
          answer: 'All payments are processed via highly secure payment gateway connections with real-time operator callbacks. You can verify the transaction status instantly in the app using the Check Status tool.'
        }
      ]
    }
  },
  methods: {
    scrollTo(id) {
      const element = document.getElementById(id);
      if (element) {
        element.scrollIntoView({ behavior: 'smooth' });
      }
    },
    toggleFaq(index) {
      this.activeFaq = this.activeFaq === index ? null : index;
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
  background-color: #fafbfc;
  color: #1e293b;
  font-family: 'Inter', system-ui, sans-serif;
  overflow-x: hidden;
}

/* Header */
.header {
  background: #0052cc;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  position: sticky;
  top: 0;
  z-index: 100;
  width: 100%;
}

.header-content {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-sizing: border-box;
}

.logo-area {
  cursor: pointer;
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
  opacity: 0.9;
  margin-left: 2px;
}

.nav-links {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.nav-links a {
  color: rgba(255, 255, 255, 0.85);
  text-decoration: none;
  font-weight: 600;
  font-size: 0.9rem;
  transition: color 0.2s;
}

.nav-links a:hover {
  color: #ffffff;
}

.nav-btn {
  padding: 0.5rem 1.25rem;
  border-radius: 20px;
  font-weight: 700;
  font-size: 0.85rem;
  text-decoration: none;
  transition: all 0.3s ease;
}

.admin-login-btn {
  background: #ffffff;
  color: #0052cc !important;
}

.admin-login-btn:hover {
  background: rgba(255, 255, 255, 0.9);
  transform: translateY(-1px);
}

/* Top Action Bar */
.top-action-bar {
  background: #ffab00;
  color: #002244;
  padding: 0.75rem 2rem;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.top-action-content {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
}

.playstore-download-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.download-text {
  font-weight: 700;
  font-size: 0.9rem;
}

.top-mini-btn {
  padding: 0.35rem 0.85rem;
  border-radius: 6px;
  font-weight: 800;
  font-size: 0.8rem;
  text-decoration: none;
  display: inline-block;
  transition: all 0.2s ease;
}

.download-link {
  background: #002244;
  color: #ffffff;
}

.download-link:hover {
  background: #001122;
}

.portal-link {
  background: #0052cc;
  color: #ffffff;
}

.portal-link:hover {
  background: #004099;
}

.admin-portal-access {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.portal-text {
  font-size: 0.9rem;
}

/* Hero Section (Action-Full) */
.hero-section {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 4rem 2rem;
  display: grid;
  grid-template-columns: 1.1fr 0.9fr;
  align-items: center;
  gap: 4rem;
  box-sizing: border-box;
}

.hero-content {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.hero-badge {
  background: #e6f0ff;
  color: #0052cc;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 800;
  margin-bottom: 1.5rem;
  letter-spacing: 0.5px;
}

.hero-title {
  font-size: 3rem;
  font-weight: 900;
  color: #0f172a;
  line-height: 1.15;
  margin: 0 0 1.5rem;
  letter-spacing: -1px;
}

.blue-highlight {
  color: #0052cc;
}

.hero-desc {
  font-size: 1.15rem;
  color: #475569;
  line-height: 1.6;
  margin: 0 0 2.5rem;
}

.hero-cta-buttons {
  display: flex;
  gap: 1.5rem;
  margin-bottom: 3rem;
  width: 100%;
  flex-wrap: wrap;
}

.hero-cta-btn {
  flex: 1;
  min-width: 200px;
  padding: 0.75rem 1.5rem;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  text-decoration: none;
  transition: all 0.2s ease;
}

.playstore-btn {
  background: #1e293b;
  color: white;
}

.playstore-btn:hover {
  background: #0f172a;
  transform: translateY(-2px);
}

.admin-btn {
  background: #0052cc;
  color: white;
}

.admin-btn:hover {
  background: #004099;
  transform: translateY(-2px);
}

.admin-icon {
  font-size: 1.75rem;
}

.btn-lbl {
  display: flex;
  flex-direction: column;
}

.lbl-small {
  font-size: 0.65rem;
  opacity: 0.75;
  font-weight: 700;
}

.lbl-large {
  font-size: 1.1rem;
  font-weight: 900;
}

.hero-stats-mini {
  display: flex;
  gap: 3rem;
  border-top: 1px solid #e2e8f0;
  padding-top: 2rem;
  width: 100%;
}

.mini-stat {
  display: flex;
  flex-direction: column;
}

.stat-num {
  font-size: 1.75rem;
  font-weight: 900;
  color: #0052cc;
}

.stat-lbl {
  font-size: 0.85rem;
  color: #64748b;
  font-weight: 600;
}

/* Device Mockup Visuals */
.phone-frame {
  background: #0f172a;
  padding: 12px;
  border-radius: 40px;
  box-shadow: 0 25px 50px -12px rgba(0, 82, 204, 0.25);
  max-width: 320px;
  margin: 0 auto;
  border: 4px solid #334155;
}

.phone-screen {
  background: #f8fafc;
  border-radius: 32px;
  overflow: hidden;
  height: 520px;
  display: flex;
  flex-direction: column;
  font-family: inherit;
  font-size: 0.85rem;
}

.app-header {
  background: #0052cc;
  color: white;
  padding: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}

.app-balance-card {
  background: linear-gradient(135deg, #0d47a1 0%, #1565c0 100%);
  color: white;
  margin: 1rem;
  padding: 1.25rem;
  border-radius: 16px;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.card-glow {
  position: absolute;
  top: -20px;
  right: -20px;
  width: 80px;
  height: 80px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
}

.bal-title {
  opacity: 0.8;
  font-size: 0.75rem;
  margin-bottom: 0.25rem;
}

.bal-value {
  font-size: 1.5rem;
  font-weight: 900;
  margin-bottom: 1rem;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  font-size: 0.7rem;
  opacity: 0.9;
}

.status-active {
  color: #00e676;
  font-weight: bold;
}

.app-quick-actions {
  display: flex;
  gap: 0.5rem;
  padding: 0 1rem;
}

.quick-btn {
  flex: 1;
  background: white;
  padding: 0.5rem;
  border-radius: 8px;
  text-align: center;
  font-size: 0.7rem;
  font-weight: bold;
  border: 1px solid #e2e8f0;
}

.quick-btn.active {
  background: #e6f0ff;
  color: #0052cc;
  border-color: #bfdbfe;
}

.app-services-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 0.75rem;
  padding: 1rem;
}

.app-service-item {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 0.75rem 0.25rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  font-size: 0.7rem;
  font-weight: bold;
  gap: 0.25rem;
}

.app-service-item span {
  color: #475569;
}

.app-recent-txn {
  margin-top: auto;
  background: white;
  padding: 1rem;
  border-top: 1px solid #e2e8f0;
}

.txn-title {
  font-size: 0.7rem;
  font-weight: bold;
  color: #64748b;
  display: block;
  margin-bottom: 0.5rem;
}

.txn-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.75rem;
  font-weight: bold;
}

.text-green {
  color: #2e7d32;
}

/* Services Showcase */
.services-showcase {
  padding: 5rem 0;
  border-top: 1px solid #e2e8f0;
  width: 100%;
}

.services-showcase-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
}

.service-show-card {
  background: white;
  padding: 2.5rem 2rem;
  border-radius: 20px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
  transition: all 0.2s ease;
}

.service-show-card:hover {
  transform: translateY(-4px);
  border-color: #0052cc;
  box-shadow: 0 10px 15px -3px rgba(0, 82, 204, 0.05);
}

.service-show-icon {
  font-size: 2.5rem;
  margin-bottom: 1.5rem;
}

.service-show-card h3 {
  font-size: 1.35rem;
  font-weight: 800;
  color: #0f172a;
  margin: 0 0 0.75rem;
}

.service-show-card p {
  margin: 0;
  color: #64748b;
  font-size: 0.95rem;
  line-height: 1.5;
}

/* Commission Section */
.commission-section {
  padding: 5rem 0;
  border-top: 1px solid #e2e8f0;
  width: 100%;
}

.commission-card-wrapper {
  display: grid;
  grid-template-columns: 1fr 1.1fr;
  gap: 3rem;
}

.commission-intro-card {
  background: #002244;
  color: white;
  padding: 3rem 2.5rem;
  border-radius: 24px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.card-accent {
  color: #ffab00;
  font-weight: 900;
  letter-spacing: 1.5px;
  font-size: 0.8rem;
  margin-bottom: 0.5rem;
}

.commission-intro-card h3 {
  font-size: 1.85rem;
  font-weight: 900;
  margin: 0 0 1rem;
}

.commission-intro-card p {
  opacity: 0.85;
  font-size: 1.05rem;
  line-height: 1.6;
  margin: 0 0 2rem;
}

.perks-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.perk-row {
  font-weight: bold;
  color: #ffab00;
}

.commission-table-card {
  background: white;
  padding: 2.5rem;
  border-radius: 24px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
}

.commission-table-card h3 {
  font-size: 1.35rem;
  margin: 0 0 1.5rem;
  color: #0f172a;
}

.table-container {
  width: 100%;
  overflow-x: auto;
}

.com-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
}

.com-table th,
.com-table td {
  padding: 1rem;
  border-bottom: 1px solid #e2e8f0;
}

.com-table th {
  color: #64748b;
  font-weight: bold;
  font-size: 0.85rem;
  text-transform: uppercase;
}

.com-table td {
  font-size: 0.95rem;
  color: #1e293b;
}

/* Main Content elements */
.main-content {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  box-sizing: border-box;
}

/* Banners common */
.banner-section {
  width: 100%;
  margin-bottom: 2rem;
}

.deals-banner {
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 24px;
  padding: 3rem 2rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  box-sizing: border-box;
}

.deals-icon-container {
  margin-bottom: 1.5rem;
}

.deals-tag {
  color: #f57c00;
  font-weight: 800;
  font-size: 1rem;
  letter-spacing: 2px;
}

.deals-title {
  font-size: 2.5rem;
  font-weight: 900;
  color: #0052cc;
  margin: 0.25rem 0 1rem;
}

.deals-desc {
  color: #64748b;
  max-width: 600px;
  font-size: 1.1rem;
  line-height: 1.6;
}

/* Security Banner styling */
.security-banner {
  background-image: url('../assets/image.png');
  background-size: cover;
  background-position: center;
  border-radius: 24px;
  padding: 4rem 3rem;
  color: #ffffff;
  min-height: 240px;
  display: flex;
  align-items: center;
  box-sizing: border-box;
}

.security-content {
  max-width: 550px;
  margin-left: 20%;
}

.security-title {
  font-size: 2rem;
  font-weight: 900;
  margin-bottom: 1rem;
  line-height: 1.2;
}

.security-desc {
  font-size: 1.05rem;
  opacity: 0.9;
  line-height: 1.5;
}

/* Trust Section */
.trust-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 3rem 0;
  width: 100%;
}

.brand-logos {
  display: flex;
  justify-content: center;
  align-items: center;
  flex-wrap: wrap;
  gap: 2rem;
  margin-bottom: 3rem;
}

.brand-logo-card {
  background: white;
  padding: 0.75rem 1.5rem;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 120px;
  justify-content: center;
}

.mastercard-circles {
  display: flex;
}

.circle {
  width: 16px;
  height: 16px;
  border-radius: 50%;
}

.circle.red {
  background: #eb001b;
}

.circle.yellow {
  background: #ff5f00;
  margin-left: -6px;
}

.font-bold {
  font-weight: bold;
}

.brand-text {
  font-size: 0.95rem;
  color: #222;
}

.bhim-logo {
  font-weight: 800;
  color: #ff6f00;
}

.bhim-sub {
  color: #0052cc;
}

.visa-logo {
  color: #1a1f71;
  font-style: italic;
  font-size: 1.25rem;
}

.rupay-logo {
  color: #0d47a1;
  font-weight: 700;
  font-size: 1.1rem;
}

.customer-trust {
  text-align: center;
}

.trust-title {
  font-size: 1.75rem;
  font-weight: 800;
  color: #0052cc;
  margin: 0;
}

.trust-underline {
  height: 4px;
  width: 180px;
  background: #0052cc;
  margin: 10px auto 20px;
  border-radius: 2px;
}

.cta-primary-btn {
  background: #0052cc;
  color: white;
  border: none;
  padding: 0.75rem 2rem;
  border-radius: 8px;
  font-weight: bold;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.2s;
}

.cta-primary-btn:hover {
  background: #004099;
}

/* Features Section */
.about-section {
  padding: 5rem 0;
  border-top: 1px solid #e2e8f0;
  width: 100%;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 2rem;
}

.feature-card {
  background: white;
  padding: 2rem;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  transition: transform 0.2s;
}

.feature-card:hover {
  transform: translateY(-2px);
}

.feature-icon {
  font-size: 2.25rem;
  margin-bottom: 1.25rem;
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
  line-height: 1.5;
  margin: 0;
}

/* Steps Section */
.steps-section {
  padding: 5rem 0;
  border-top: 1px solid #e2e8f0;
  width: 100%;
}

.section-header {
  text-align: center;
  margin-bottom: 4rem;
  max-width: 700px;
  margin-left: auto;
  margin-right: auto;
}

.section-header h2 {
  font-size: 2.25rem;
  font-weight: 900;
  color: #0f172a;
  margin: 0 0 1rem;
}

.section-header p {
  font-size: 1.1rem;
  color: #64748b;
}

.steps-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1.5rem;
  flex-wrap: wrap;
}

.step-card {
  background: white;
  padding: 2.5rem 2rem;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  flex: 1;
  min-width: 250px;
  position: relative;
  text-align: center;
}

.step-num {
  font-size: 3rem;
  font-weight: 900;
  color: rgba(0, 82, 204, 0.1);
  position: absolute;
  top: 10px;
  right: 15px;
}

.step-card h3 {
  font-size: 1.25rem;
  font-weight: 800;
  color: #0f172a;
  margin-top: 1rem;
}

.step-card p {
  color: #64748b;
  font-size: 0.95rem;
  line-height: 1.5;
}

.step-arrow {
  font-size: 1.5rem;
  color: #0052cc;
}

/* Download App Section */
.download-section {
  background: #102a5c;
  border-radius: 24px;
  padding: 4rem 3rem;
  color: white;
  margin-bottom: 4rem;
  width: 100%;
  box-sizing: border-box;
}

.download-grid {
  display: grid;
  grid-template-columns: 0.9fr 1.1fr;
  gap: 3rem;
  align-items: center;
}

.qr-panel {
  display: flex;
  justify-content: center;
}

.qr-container {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 2rem;
  border-radius: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  max-width: 300px;
}

.qr-code {
  width: 160px;
  height: 160px;
  background: white;
  border-radius: 12px;
  padding: 10px;
  box-sizing: border-box;
}

.qr-pattern {
  width: 100%;
  height: 100%;
  background-image: radial-gradient(black 30%, transparent 30%), radial-gradient(black 30%, transparent 30%);
  background-size: 8px 8px;
  background-position: 0 0, 4px 4px;
}

.qr-caption {
  font-size: 0.85rem;
  margin: 1.25rem 0;
  text-align: center;
  opacity: 0.9;
}

.play-badge {
  background: #000000;
  border: 1px solid #333;
  border-radius: 8px;
  padding: 0.4rem 1rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
  color: white;
}

.features-panel {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.feature-bullet {
  display: flex;
  gap: 1.25rem;
  align-items: flex-start;
}

.bullet-icon {
  background: #ffab00;
  font-size: 1.5rem;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.bullet-text h3 {
  margin: 0 0 0.25rem;
  font-size: 1.15rem;
  font-weight: 700;
}

.bullet-text p {
  margin: 0;
  font-size: 0.95rem;
  opacity: 0.85;
  line-height: 1.4;
}

/* FAQ Section */
.faq-section {
  padding: 4rem 0;
  width: 100%;
}

.faq-section-title {
  font-size: 2.25rem;
  font-weight: 900;
  color: #0f172a;
  text-align: center;
  margin-bottom: 3rem;
}

.faq-grid {
  display: grid;
  grid-template-columns: 0.7fr 1.3fr;
  gap: 3rem;
}

.faq-contact-card {
  background: #e6f0ff;
  border-radius: 20px;
  padding: 2.5rem 2rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  box-sizing: border-box;
}

.chat-bubble-icon {
  font-size: 3.5rem;
  margin-bottom: 1.5rem;
}

.faq-contact-card h3 {
  font-size: 1.35rem;
  font-weight: 800;
  color: #0052cc;
  margin: 0 0 0.75rem;
}

.faq-contact-card p {
  color: #475569;
  font-size: 0.95rem;
  line-height: 1.5;
  margin: 0 0 1.5rem;
}

.faq-btn-contact {
  background: #0052cc;
  color: white;
  border: none;
  padding: 0.65rem 1.5rem;
  border-radius: 8px;
  font-weight: bold;
  cursor: pointer;
  width: 100%;
}

.faq-accordion {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.faq-item {
  background: white;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  overflow: hidden;
  transition: all 0.2s ease;
}

.faq-item.active {
  border-color: #0052cc;
  box-shadow: 0 4px 12px rgba(0, 82, 204, 0.05);
}

.faq-question {
  padding: 1.25rem 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 700;
  color: #1e293b;
  cursor: pointer;
  user-select: none;
}

.faq-toggle-icon {
  font-size: 1.25rem;
  color: #0052cc;
}

.faq-answer {
  padding: 0 1.5rem 1.25rem;
  color: #64748b;
  font-size: 0.95rem;
  line-height: 1.5;
}

/* Contact Us Section */
.contact-section {
  padding: 5rem 0;
  border-top: 1px solid #e2e8f0;
  width: 100%;
}

.contact-grid {
  display: grid;
  grid-template-columns: 0.8fr 1.2fr;
  gap: 3rem;
}

.contact-info {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.info-item {
  display: flex;
  gap: 1rem;
  background: white;
  padding: 1.5rem;
  border-radius: 14px;
  border: 1px solid #e2e8f0;
}

.info-icon {
  font-size: 1.5rem;
}

.info-item h4 {
  margin: 0 0 0.25rem;
  color: #0f172a;
}

.info-item p {
  margin: 0;
  color: #64748b;
  font-size: 0.9rem;
}

.contact-form {
  background: white;
  padding: 2.5rem;
  border-radius: 20px;
  border: 1px solid #e2e8f0;
  box-sizing: border-box;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.form-group label {
  font-weight: 700;
  font-size: 0.85rem;
}

.form-group input,
.form-group textarea {
  padding: 0.75rem;
  border-radius: 8px;
  border: 1px solid #cbd5e1;
  font-family: inherit;
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
  margin-top: 1rem;
}

/* Footer Section */
.footer {
  background: #002244;
  color: white;
  width: 100%;
  padding: 4rem 2rem 2rem;
  box-sizing: border-box;
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
}

.footer-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  flex-wrap: wrap;
  gap: 3rem;
}

.footer-left {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.white-text {
  color: white !important;
}

.footer-badge {
  width: 140px;
}

.footer-links-grid {
  display: flex;
  gap: 4rem;
}

.footer-col {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.footer-col a {
  color: rgba(255, 255, 255, 0.7);
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: bold;
  letter-spacing: 0.5px;
  transition: color 0.2s;
}

.footer-col a:hover {
  color: white;
}

.footer-divider {
  height: 1px;
  background: rgba(255, 255, 255, 0.1);
  margin: 3rem 0 2rem;
}

.footer-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1.5rem;
}

.copyright {
  font-size: 0.85rem;
  opacity: 0.7;
  margin: 0;
}

.security-badges {
  display: flex;
  gap: 1.5rem;
  font-size: 0.8rem;
  opacity: 0.8;
}

/* Responsive Grid layouts */
@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    gap: 1rem;
  }
  .nav-links {
    flex-wrap: wrap;
    justify-content: center;
    gap: 1rem;
  }
  .top-action-content {
    flex-direction: column;
    text-align: center;
    gap: 0.75rem;
  }
  .playstore-download-info,
  .admin-portal-access {
    justify-content: center;
  }
  .hero-section {
    grid-template-columns: 1fr;
    text-align: center;
    gap: 3rem;
  }
  .hero-content {
    align-items: center;
  }
  .hero-cta-buttons {
    justify-content: center;
  }
  .hero-stats-mini {
    justify-content: center;
    gap: 1.5rem;
  }
  .security-banner {
    padding: 3rem 1.5rem;
  }
  .security-content {
    margin-left: 0;
    text-align: center;
    background: rgba(0, 34, 68, 0.65);
    padding: 1.5rem;
    border-radius: 16px;
  }
  .commission-card-wrapper {
    grid-template-columns: 1fr;
  }
  .steps-container {
    flex-direction: column;
  }
  .step-arrow {
    transform: rotate(90deg);
  }
  .download-grid,
  .faq-grid,
  .contact-grid {
    grid-template-columns: 1fr;
  }
  .footer-top {
    flex-direction: column;
  }
}
</style>
