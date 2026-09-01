<template>
  <div class="landing-page-container">
    <!-- Header -->
    <header class="header">
      <div class="header-content">
        <div class="header-logo-container">
          <img src="../assets/sr_logo.png" alt="SR Digital Seva Kendram" class="logo-image" />
        </div>
        <div class="header-right-container">
          <router-link to="/admin-login" class="admin-login-nav-btn">
            Admin Login
          </router-link>
          <div class="header-notification-container" title="Notifications">
            <div class="notification-bell">
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"></path>
                <path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"></path>
              </svg>
              <span class="notification-dot"></span>
            </div>
          </div>
        </div>
      </div>
    </header>

    <!-- Hero Section -->
    <section class="hero-section">
      <div class="hero-content">
        <!-- Hero Left Text Column -->
        <div class="hero-left">
          <div class="capsule-badge">
            FAST <span class="bullet">•</span> SECURE <span class="bullet">•</span> RELIABLE
          </div>

          <h1 class="hero-title">
            Instant Recharges.<br />
            <span class="highlight-blue">Everytime.</span><br />
            <span class="highlight-blue">Everywhere.</span>
          </h1>

          <p class="hero-subtitle">
            Recharge your Mobile, DTH, Electricity bills and more in just a few clicks. Quick, easy and 100% secure.
          </p>
        </div>

        <!-- Hero Right Visual Column with Woman, Phone Mockup & Floating Cards -->
        <div class="hero-right">
          <!-- Background Ambient Glow Waves -->
          <div class="hero-bg-wave"></div>
          <div class="hero-bg-wave-secondary"></div>

          <div class="visual-wrapper">
            <!-- 1. Flying Card 1: Top Left Lightning -->
            <div class="floating-badge badge-lightning float-anim-1">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" class="badge-icon">
                <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"></path>
              </svg>
            </div>

            <!-- 2. Flying Card 2: Top Right Satellite Dish -->
            <div class="floating-badge badge-dth float-anim-2">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="badge-icon">
                <path d="M6.08 17.5a9 9 0 0 1 11.84 0M3 13.5a13 13 0 0 1 18 0"></path>
                <path d="M12 12v10M12 22h4m-8 0h4"></path>
                <circle cx="12" cy="7" r="2" fill="#0052CC"></circle>
              </svg>
            </div>

            <!-- 3. Flying Card 3: Middle Right Rupee Symbol -->
            <div class="floating-badge badge-rupee float-anim-3">
              <span class="rupee-symbol">₹</span>
            </div>

            <!-- 4. Flying Card 4: Bottom Right Lightbulb -->
            <div class="floating-badge badge-bulb float-anim-4">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#D97706" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" class="badge-icon">
                <path d="M9 18h6M10 22h4M15 14.5A7 7 0 1 0 9 14.5M12 2v2"></path>
              </svg>
            </div>

            <!-- 5. Flying Card 5: Bottom Left Phone Icon -->
            <div class="floating-badge badge-phone float-anim-5">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" class="badge-icon">
                <rect x="5" y="2" width="14" height="20" rx="2" ry="2"></rect>
                <line x1="12" y1="18" x2="12.01" y2="18"></line>
              </svg>
            </div>

            <!-- Smartphone Mockup Displaying App Screen -->
            <div class="mockup-phone">
              <div class="phone-app-header">
                <div class="phone-app-logo">
                  <span class="bold">SR DIGITAL SEVA</span>
                  <span class="sub">KENDRAM</span>
                </div>
                <div class="phone-bell-icon">
                  <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.5">
                    <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"></path>
                  </svg>
                </div>
              </div>

              <!-- Wallet Balance Card inside Phone -->
              <div class="phone-balance-card">
                <span class="lbl">Wallet Balance</span>
                <span class="val">₹ 2,450.00</span>
              </div>

              <!-- Services Section inside Phone -->
              <div class="phone-section-title">Recharge & Pay Bills</div>
              <div class="phone-grid">
                <div class="grid-item">
                  <div class="item-icon blue-bg">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2"><rect x="5" y="2" width="14" height="20" rx="2"></rect></svg>
                  </div>
                  <span>Mobile</span>
                </div>
                <div class="grid-item">
                  <div class="item-icon purple-bg">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#8B5CF6" stroke-width="2"><path d="M6 18a9 9 0 0 1 12 0M3 14a13 13 0 0 1 18 0"></path></svg>
                  </div>
                  <span>DTH</span>
                </div>
                <div class="grid-item">
                  <div class="item-icon orange-bg">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#F97316" stroke-width="2"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"></path></svg>
                  </div>
                  <span>Electricity</span>
                </div>
                <div class="grid-item">
                  <div class="item-icon green-bg">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#10B981" stroke-width="2"><rect x="2" y="14" width="20" height="6" rx="1"></rect><path d="M6 14v-4a4 4 0 0 1 8 0v4"></path></svg>
                  </div>
                  <span>Broadband</span>
                </div>
                <div class="grid-item">
                  <div class="item-icon lightblue-bg">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#06B6D4" stroke-width="2"><path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"></path></svg>
                  </div>
                  <span>Water</span>
                </div>
                <div class="grid-item">
                  <div class="item-icon red-bg">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#EF4444" stroke-width="2"><rect x="6" y="8" width="12" height="13" rx="2"></rect><path d="M9 8V5a2 2 0 0 1 4 0v3"></path></svg>
                  </div>
                  <span>Gas</span>
                </div>
              </div>

              <!-- Recent Transaction Row inside Phone -->
              <div class="phone-section-title">Recent Transaction</div>
              <div class="phone-transaction-row">
                <div class="tx-left">
                  <span class="tx-date">Monday 19th Sept</span>
                  <span class="tx-desc">Successful</span>
                </div>
                <span class="tx-amt">₹ 2,450.00</span>
              </div>
            </div>

            <!-- Smiling Woman Image -->
            <img :src="bannerImg" alt="SR Digital Seva Woman" class="woman-image" @error="handleImageError" />
          </div>
        </div>
      </div>
    </section>

    <!-- Our Services Section -->
    <section class="services-section">
      <div class="services-content">
        <div class="services-divider">
          <span class="line-gradient left"></span>
          <h2 class="services-title">Our Services</h2>
          <span class="line-gradient right"></span>
        </div>
        <p class="services-subtitle">All your recharges and bill payments in one place</p>

        <div class="services-grid">
          <!-- 1. Mobile Recharge -->
          <div class="service-card">
            <div class="card-icon-circle blue-circle">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" class="card-icon">
                <rect x="5" y="2" width="14" height="20" rx="2" ry="2"></rect>
                <line x1="12" y1="18" x2="12.01" y2="18"></line>
              </svg>
            </div>
            <h3 class="card-title">Mobile Recharge</h3>
            <p class="card-desc">Prepaid & Postpaid recharges</p>
          </div>

          <!-- 2. DTH Recharge -->
          <div class="service-card">
            <div class="card-icon-circle purple-circle">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" class="card-icon">
                <path d="M6.08 17.5a9 9 0 0 1 11.84 0M3 13.5a13 13 0 0 1 18 0"></path>
                <path d="M12 12v10M12 22h4m-8 0h4"></path>
                <circle cx="12" cy="7" r="2" fill="currentColor"></circle>
              </svg>
            </div>
            <h3 class="card-title">DTH Recharge</h3>
            <p class="card-desc">Top up your DTH connection</p>
          </div>

          <!-- 3. Electricity Bill -->
          <div class="service-card">
            <div class="card-icon-circle orange-circle">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" class="card-icon">
                <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"></path>
              </svg>
            </div>
            <h3 class="card-title">Electricity Bill</h3>
            <p class="card-desc">Pay your electricity bills instantly</p>
          </div>

          <!-- 4. Broadband -->
          <div class="service-card">
            <div class="card-icon-circle green-circle">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" class="card-icon">
                <rect x="2" y="14" width="20" height="6" rx="1"></rect>
                <path d="M6 14v-4a4 4 0 0 1 8 0v4"></path>
                <circle cx="12" cy="7" r="1" fill="currentColor"></circle>
                <path d="M12 14v-7"></path>
              </svg>
            </div>
            <h3 class="card-title">Broadband</h3>
            <p class="card-desc">Pay your broadband bills easily</p>
          </div>

          <!-- 5. Water Bill -->
          <div class="service-card">
            <div class="card-icon-circle lightblue-circle">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" class="card-icon">
                <path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"></path>
              </svg>
            </div>
            <h3 class="card-title">Water Bill</h3>
            <p class="card-desc">Pay your water bills online</p>
          </div>

          <!-- 6. Gas Bill -->
          <div class="service-card">
            <div class="card-icon-circle red-circle">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" class="card-icon">
                <rect x="6" y="8" width="12" height="13" rx="2"></rect>
                <path d="M9 8V5a2 2 0 0 1 4 0v3"></path>
                <line x1="12" y1="12" x2="12" y2="17"></line>
                <line x1="9" y1="15" x2="15" y2="15"></line>
              </svg>
            </div>
            <h3 class="card-title">Gas Bill</h3>
            <p class="card-desc">Pay your gas bills securely</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Download Our App Section -->
    <section class="download-section">
      <div class="download-content">
        <div class="download-card">
          <div class="download-phone-left">
            <div class="mini-app-phone">
              <div class="mini-app-screen">
                <div class="mini-app-logo-content">
                  <span class="bold">SR DIGITAL</span>
                  <span class="sub">SEVA KENDRAM</span>
                </div>
              </div>
            </div>
          </div>

          <div class="download-info-center">
            <h2 class="download-title">Download Our App</h2>
            <p class="download-desc">Faster recharges, better experience and exclusive offers on our app.</p>
          </div>

          <div class="download-button-right">
            <a href="https://play.google.com/store/apps/details?id=com.app.earnfarm" target="_blank" rel="noopener noreferrer" class="google-play-badge">
              <svg class="play-svg" viewBox="0 0 24 24" width="24" height="24">
                <path d="M3,5.27V18.73c0,0.89,0.97,1.44,1.73,0.99l11.45-6.73a1.15,1.15,0,0,0,0-1.98L4.73,4.28C3.97,3.83,3,4.38,3,5.27Z" fill="#ffffff"/>
              </svg>
              <div class="badge-text">
                <span class="get-it">GET IT ON</span>
                <span class="google-play">Google Play</span>
              </div>
            </a>
          </div>
        </div>
      </div>
    </section>

    <!-- Contact Info Bar -->
    <section class="footer-contacts">
      <div class="contacts-content">
        <div class="contact-item">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2" class="contact-icon">
            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
          </svg>
          <span>9988494936</span>
        </div>

        <span class="vertical-divider"></span>

        <div class="contact-item">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2" class="contact-icon">
            <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
            <polyline points="22,6 12,13 2,6"></polyline>
          </svg>
          <span>info@srdigitalseva.com</span>
        </div>

        <span class="vertical-divider"></span>

        <div class="contact-item">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2" class="contact-icon">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
            <circle cx="12" cy="10" r="3"></circle>
          </svg>
          <span>Telangana, Warangal 506005</span>
        </div>
      </div>
    </section>

    <!-- Main Footer -->
    <footer class="main-footer">
      <div class="footer-content">
        <div class="footer-links">
          <a href="#about" class="footer-link">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="link-icon">
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
              <circle cx="12" cy="7" r="4"></circle>
            </svg>
            About Us
          </a>

          <span class="footer-dot">|</span>

          <a href="#terms" class="footer-link">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="link-icon">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
              <polyline points="14 2 14 8 20 8"></polyline>
              <line x1="16" y1="13" x2="8" y2="13"></line>
              <line x1="16" y1="17" x2="8" y2="17"></line>
            </svg>
            Terms & Conditions
          </a>

          <span class="footer-dot">|</span>

          <router-link to="/privacy-policy" class="footer-link">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="link-icon">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
            </svg>
            Privacy Policy
          </router-link>

          <span class="footer-dot">|</span>

          <a href="#refund" class="footer-link">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="link-icon">
              <path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"></path>
            </svg>
            Refund Policy
          </a>
        </div>
        <p class="copyright">&copy; 2026 SR Digital Seva Kendram. All Right Reserved.</p>
      </div>
    </footer>
  </div>
</template>

<script>
import bannerImg from '../assets/rr.png';

export default {
  name: 'LandingPage',
  data() {
    return {
      bannerImg,
    };
  },
  methods: {
    handleImageError(e) {
      e.target.src = 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?auto=format&fit=crop&q=80&w=600';
    }
  }
}
</script>

<style scoped>
.landing-page-container {
  min-height: 100vh;
  width: 100%;
  background-color: #FFFFFF;
  color: #1F2937;
  font-family: 'Outfit', 'Inter', system-ui, sans-serif;
  overflow-x: hidden;
  display: flex;
  flex-direction: column;
}

/* Header */
.header {
  width: 100%;
  background-color: #FFFFFF;
  border-bottom: 1px solid #F3F4F6;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.02);
}

.header-content {
  max-width: 1320px;
  margin: 0 auto;
  padding: 1.1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.logo-image {
  height: 52px;
  object-fit: contain;
}

.header-right-container {
  display: flex;
  align-items: center;
  gap: 1.25rem;
}

.admin-login-nav-btn {
  background-color: #0B132B;
  color: #FFFFFF;
  padding: 0.55rem 1.3rem;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 700;
  text-decoration: none;
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  box-shadow: 0 4px 12px rgba(11, 19, 43, 0.15);
}

.admin-login-nav-btn:hover {
  background-color: #0052CC;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(0, 82, 204, 0.25);
}

.notification-bell {
  position: relative;
  cursor: pointer;
  padding: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: background-color 0.2s ease;
}

.notification-bell:hover {
  background-color: #F3F4F6;
}

.notification-dot {
  position: absolute;
  top: 4px;
  right: 4px;
  width: 9px;
  height: 9px;
  background-color: #EF4444;
  border-radius: 50%;
  border: 1.5px solid #FFFFFF;
}

/* Hero Section */
.hero-section {
  width: 100%;
  background: linear-gradient(180deg, #FFFFFF 0%, #F8FAFC 100%);
  padding: 3rem 0 4.5rem;
  position: relative;
  overflow: hidden;
}

.hero-content {
  max-width: 1320px;
  margin: 0 auto;
  padding: 0 2rem;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  gap: 3rem;
  width: 100%;
}

.hero-left {
  flex: 1;
  max-width: 580px;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  z-index: 2;
}

.capsule-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.5rem 1.3rem;
  background-color: #F0F6FF;
  border: 1.5px solid #D0E2FF;
  border-radius: 9999px;
  color: #0052CC;
  font-size: 0.75rem;
  font-weight: 800;
  letter-spacing: 0.08em;
  margin-bottom: 2rem;
  box-shadow: 0 2px 8px rgba(0, 82, 204, 0.06);
}

.capsule-badge .bullet {
  margin: 0 0.5rem;
  color: #93C5FD;
}

.hero-title {
  font-size: 3.2rem;
  line-height: 1.15;
  font-weight: 900;
  color: #0B132B;
  margin-bottom: 1.5rem;
  letter-spacing: -0.02em;
}

.highlight-blue {
  color: #0052CC;
}

.hero-subtitle {
  font-size: 1.15rem;
  line-height: 1.6;
  color: #4B5563;
  max-width: 480px;
  font-weight: 400;
}

/* Hero Right Visual Column */
.hero-right {
  flex: 1.1;
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 520px;
  z-index: 1;
}

.hero-bg-wave {
  position: absolute;
  top: -60px;
  right: -40px;
  width: 460px;
  height: 460px;
  background: radial-gradient(circle, rgba(0,82,204,0.08) 0%, rgba(255,255,255,0) 70%);
  border-radius: 50%;
  z-index: -1;
}

.hero-bg-wave-secondary {
  position: absolute;
  bottom: -40px;
  left: -20px;
  width: 340px;
  height: 340px;
  background: radial-gradient(circle, rgba(0,82,204,0.05) 0%, rgba(255,255,255,0) 70%);
  border-radius: 50%;
  z-index: -1;
}

.visual-wrapper {
  position: relative;
  width: 100%;
  max-width: 540px;
  height: 520px;
  display: flex;
  justify-content: flex-end;
  align-items: flex-end;
}

.woman-image {
  height: 100%;
  max-height: 510px;
  width: auto;
  object-fit: contain;
  z-index: 2;
  pointer-events: none;
  filter: drop-shadow(0 15px 30px rgba(0, 0, 0, 0.08));
}

/* Mockup Phone overlay inside Hero */
.mockup-phone {
  position: absolute;
  left: 10px;
  top: 50%;
  transform: translateY(-50%);
  width: 215px;
  height: 410px;
  background-color: #FFFFFF;
  border-radius: 26px;
  box-shadow: 0 20px 45px rgba(0, 0, 0, 0.14);
  border: 5.5px solid #1F2937;
  z-index: 4;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  padding: 10px;
  font-family: 'Outfit', sans-serif;
}

.phone-app-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  padding: 0 2px;
}

.phone-app-logo {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  font-size: 8px;
  line-height: 1;
}

.phone-app-logo .bold {
  font-weight: 900;
  color: #0052CC;
}

.phone-app-logo .sub {
  font-size: 6px;
  color: #EF4444;
  font-weight: 800;
}

.phone-balance-card {
  background: linear-gradient(135deg, #0052CC 0%, #1D4ED8 100%);
  border-radius: 10px;
  padding: 9px 10px;
  color: #FFFFFF;
  display: flex;
  flex-direction: column;
  position: relative;
  overflow: hidden;
  margin-bottom: 10px;
  box-shadow: 0 4px 12px rgba(0, 82, 204, 0.25);
}

.phone-balance-card .lbl {
  font-size: 6.5px;
  opacity: 0.85;
}

.phone-balance-card .val {
  font-size: 13.5px;
  font-weight: 800;
  margin-top: 2px;
}

.phone-section-title {
  font-size: 7px;
  font-weight: 800;
  color: #374151;
  margin-bottom: 6px;
  letter-spacing: 0.01em;
}

.phone-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 6px;
  margin-bottom: 12px;
}

.grid-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-size: 6.5px;
  font-weight: 600;
  color: #4B5563;
}

.item-icon {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 3px;
}

.item-icon svg {
  width: 12px;
  height: 12px;
}

.blue-bg { background-color: #EFF6FF; }
.green-bg { background-color: #F0FDF4; }
.orange-bg { background-color: #FFF7ED; }
.red-bg { background-color: #FEF2F2; }
.lightblue-bg { background-color: #F0F9FF; }
.purple-bg { background-color: #FAF5FF; }

.phone-transaction-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #F9FAFB;
  border: 1px solid #F3F4F6;
  border-radius: 8px;
  padding: 6px 8px;
}

.tx-left {
  display: flex;
  flex-direction: column;
}

.tx-date {
  font-size: 6.5px;
  font-weight: 700;
  color: #1F2937;
}

.tx-desc {
  font-size: 5.5px;
  color: #9CA3AF;
}

.tx-amt {
  font-size: 7.5px;
  font-weight: 800;
  color: #10B981;
}

/* Flying Floating Badges / Cards around Girl & Phone */
.floating-badge {
  position: absolute;
  width: 48px;
  height: 48px;
  background-color: #FFFFFF;
  border-radius: 50%;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.12);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 5;
  border: 1px solid rgba(255, 255, 255, 0.8);
}

.badge-icon {
  width: 22px;
  height: 22px;
}

.rupee-symbol {
  color: #0052CC;
  font-weight: 800;
  font-size: 1.3rem;
}

/* Badge Absolute Positioning */
.badge-lightning {
  top: 25px;
  left: 170px;
}

.badge-dth {
  top: 40px;
  right: 15px;
}

.badge-rupee {
  top: 180px;
  right: -15px;
}

.badge-bulb {
  bottom: 85px;
  right: 10px;
  background-color: #FFFBEB;
}

.badge-phone {
  bottom: 50px;
  left: -15px;
  background-color: #F0F6FF;
}

/* Keyframe Animations for Floating/Flying Badges */
.float-anim-1 {
  animation: floatOne 4s ease-in-out infinite;
}

.float-anim-2 {
  animation: floatTwo 4.8s ease-in-out infinite 0.5s;
}

.float-anim-3 {
  animation: floatThree 5.2s ease-in-out infinite 1s;
}

.float-anim-4 {
  animation: floatFour 4.2s ease-in-out infinite 0.3s;
}

.float-anim-5 {
  animation: floatFive 4.5s ease-in-out infinite 0.8s;
}

@keyframes floatOne {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-12px) rotate(4deg); }
}

@keyframes floatTwo {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-15px) rotate(-5deg); }
}

@keyframes floatThree {
  0%, 100% { transform: translateY(0px) scale(1); }
  50% { transform: translateY(-10px) scale(1.08); }
}

@keyframes floatFour {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-14px) rotate(4deg); }
}

@keyframes floatFive {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-11px) rotate(-4deg); }
}

/* Services Section */
.services-section {
  width: 100%;
  padding: 4.5rem 0;
  background-color: #FFFFFF;
}

.services-content {
  max-width: 1320px;
  margin: 0 auto;
  padding: 0 2rem;
  text-align: center;
  width: 100%;
}

.services-divider {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1.5rem;
  margin-bottom: 0.5rem;
}

.services-divider .line-gradient {
  height: 2px;
  width: 90px;
  display: inline-block;
}

.services-divider .line-gradient.left {
  background: linear-gradient(90deg, rgba(0, 82, 204, 0) 0%, rgba(0, 82, 204, 0.4) 100%);
}

.services-divider .line-gradient.right {
  background: linear-gradient(90deg, rgba(0, 82, 204, 0.4) 0%, rgba(0, 82, 204, 0) 100%);
}

.services-title {
  font-size: 2rem;
  font-weight: 800;
  color: #0B132B;
}

.services-subtitle {
  font-size: 1.05rem;
  color: #6B7280;
  margin-bottom: 3.5rem;
}

.services-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2.2rem;
  max-width: 1100px;
  margin: 0 auto;
}

.service-card {
  background-color: #FFFFFF;
  border-radius: 16px;
  padding: 2.4rem 1.6rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
  border: 1px solid #F3F4F6;
  display: flex;
  flex-direction: column;
  align-items: center;
  transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.3s cubic-bezier(0.16, 1, 0.3, 1), border-color 0.3s ease;
}

.service-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 14px 30px rgba(0, 82, 204, 0.08);
  border-color: #E2E8F0;
}

.card-icon-circle {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.3rem;
  box-shadow: 0 8px 18px rgba(0, 0, 0, 0.06);
}

.card-icon {
  width: 28px;
  height: 28px;
}

.blue-circle {
  background-color: #3B82F6;
  color: #FFFFFF;
}

.purple-circle {
  background-color: #8B5CF6;
  color: #FFFFFF;
}

.orange-circle {
  background-color: #F97316;
  color: #FFFFFF;
}

.green-circle {
  background-color: #10B981;
  color: #FFFFFF;
}

.lightblue-circle {
  background-color: #06B6D4;
  color: #FFFFFF;
}

.red-circle {
  background-color: #EF4444;
  color: #FFFFFF;
}

.card-title {
  font-size: 1.2rem;
  font-weight: 700;
  color: #1F2937;
  margin-bottom: 0.5rem;
}

.card-desc {
  font-size: 0.92rem;
  color: #6B7280;
  line-height: 1.45;
}

/* Download App Section */
.download-section {
  width: 100%;
  padding: 1.5rem 0 2rem;
  background-color: #FFFFFF;
}

.download-content {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 2rem;
  width: 100%;
}

.download-card {
  background-color: #F3F8FF;
  border: 1px solid #E0EDFF;
  border-radius: 20px;
  padding: 2.2rem 3rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 2.5rem;
}

.download-phone-left {
  display: flex;
  align-items: center;
}

.mini-app-phone {
  width: 68px;
  height: 108px;
  background-color: #FFFFFF;
  border-radius: 12px;
  border: 3.5px solid #1F2937;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 4px;
  box-shadow: 0 6px 15px rgba(0, 0, 0, 0.06);
}

.mini-app-screen {
  width: 100%;
  height: 100%;
  background-color: #F9FAFB;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 7px;
}

.mini-app-logo-content {
  display: flex;
  flex-direction: column;
  font-size: 6.5px;
  font-weight: 900;
  color: #0052CC;
  line-height: 1.1;
  text-align: center;
}

.mini-app-logo-content .sub {
  color: #EF4444;
  font-size: 5.5px;
}

.download-info-center {
  flex: 1;
}

.download-title {
  font-size: 1.6rem;
  font-weight: 800;
  color: #0B132B;
  margin-bottom: 0.5rem;
}

.download-desc {
  font-size: 0.98rem;
  color: #4B5563;
  line-height: 1.45;
}

.google-play-badge {
  display: inline-flex;
  align-items: center;
  background-color: #000000;
  border-radius: 10px;
  padding: 0.65rem 1.5rem;
  text-decoration: none;
  color: #FFFFFF;
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.google-play-badge:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 22px rgba(0, 0, 0, 0.25);
}

.play-svg {
  margin-right: 0.7rem;
}

.badge-text {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  line-height: 1.2;
}

.get-it {
  font-size: 0.62rem;
  opacity: 0.85;
  font-weight: 600;
  letter-spacing: 0.06em;
}

.google-play {
  font-size: 0.98rem;
  font-weight: 700;
}

/* Footer Contacts */
.footer-contacts {
  width: 100%;
  border-top: 1px solid #F3F4F6;
  background-color: #FFFFFF;
  padding: 1.2rem 0;
}

.contacts-content {
  max-width: 1320px;
  margin: 0 auto;
  padding: 0 2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 2.5rem;
  flex-wrap: wrap;
  width: 100%;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 0.65rem;
  color: #4B5563;
  font-size: 0.92rem;
  font-weight: 600;
}

.vertical-divider {
  width: 1px;
  height: 22px;
  background-color: #E5E7EB;
}

/* Main Footer */
.main-footer {
  width: 100%;
  background-color: #0B132B;
  color: #FFFFFF;
  padding: 1.6rem 0 1.4rem;
}

.footer-content {
  max-width: 1320px;
  margin: 0 auto;
  padding: 0 2rem;
  text-align: center;
  width: 100%;
}

.footer-links {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1.2rem;
  margin-bottom: 1.2rem;
  flex-wrap: wrap;
}

.footer-link {
  color: #9CA3AF;
  text-decoration: none;
  font-size: 0.88rem;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
  transition: color 0.2s ease;
}

.footer-link:hover {
  color: #FFFFFF;
}

.footer-dot {
  color: #374151;
  font-size: 0.85rem;
}

.copyright {
  font-size: 0.82rem;
  color: #6B7280;
}

/* Responsive Adjustments */
@media (max-width: 1024px) {
  .hero-content {
    flex-direction: column;
    text-align: left;
    padding-top: 1rem;
    padding-left: 2rem;
    padding-right: 2rem;
    gap: 2rem;
  }
  
  .hero-left {
    align-items: flex-start;
    max-width: 100%;
    margin-bottom: 1.5rem;
    width: 100%;
  }
  
  .hero-title {
    font-size: 2.6rem;
    text-align: left;
  }

  .hero-subtitle {
    text-align: left;
    max-width: 100%;
  }

  .services-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .hero-content {
    padding-left: 1.5rem;
    padding-right: 1.5rem;
  }

  .hero-title {
    font-size: 2.3rem;
  }

  .hero-right {
    min-height: 420px;
  }
  .visual-wrapper {
    height: 420px;
  }
  .woman-image {
    max-height: 410px;
  }
  .mockup-phone {
    width: 185px;
    height: 360px;
    left: 0px;
  }
  .download-card {
    flex-direction: column;
    text-align: center;
    padding: 2rem 1.5rem;
  }

  .download-phone-left {
    justify-content: center;
  }
  
  .footer-contacts .contacts-content {
    flex-direction: column;
    gap: 1rem;
  }
  
  .vertical-divider {
    display: none;
  }
}

@media (max-width: 600px) {
  .header-content {
    padding: 0.9rem 1.25rem;
  }
  .logo-image {
    height: 42px;
  }
  .hero-section {
    padding: 1.5rem 0 2.5rem;
  }
  .hero-content {
    padding: 0 1.5rem;
    width: 100%;
    box-sizing: border-box;
  }
  .hero-left {
    width: 100%;
    box-sizing: border-box;
    align-items: flex-start;
    text-align: left;
    padding: 0;
  }
  .capsule-badge {
    font-size: 0.72rem;
    padding: 0.45rem 1.1rem;
    margin-bottom: 1.2rem;
  }
  .hero-title {
    font-size: 2.1rem;
    line-height: 1.2;
    margin-bottom: 1rem;
    text-align: left;
    word-break: break-word;
  }
  .hero-subtitle {
    font-size: 1rem;
    line-height: 1.55;
    margin-bottom: 1.5rem;
    text-align: left;
  }
  .services-grid {
    grid-template-columns: 1fr;
    gap: 1.2rem;
  }
}
</style>
