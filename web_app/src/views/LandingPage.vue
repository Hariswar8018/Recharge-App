<template>
  <div class="landing-page">
    <div class="app-card">
      
      <!-- Top Logo Header -->
      <header v-if="visibility.web_show_header_logo" class="header">
        <div class="logo-container">
          <img src="../assets/sr_logo.png" alt="SR Logo" class="sr-logo-img" />
        </div>
      </header>

      <!-- Hero Artwork Center Section -->
      <main class="main-content">
        <div v-if="visibility.web_show_hero_graphic" class="hero-image-wrapper">
          <img
            src="../assets/home_page.png"
            alt="Download Our App - Google Play"
            class="hero-graphic"
          />
        </div>

        <!-- Captcha -> Cash Headline -->
        <div v-if="visibility.web_show_headline" class="headline-section">
          <div class="dash-decor left-dashes">
            <span class="dash dash-1"></span>
            <span class="dash dash-2"></span>
            <span class="dash dash-3"></span>
          </div>

          <div class="headline-text">
            <span class="text-captcha">Captcha</span>
            <span class="text-arrow">&nbsp;&rarr;&nbsp;</span>
            <span class="text-cash">Cash</span>
            <!-- Red Curved Underline -->
            <svg class="curve-underline" viewBox="0 0 200 20" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M5 12 Q 100 22, 195 8" stroke="#DC2626" stroke-width="4" stroke-linecap="round"/>
            </svg>
          </div>

          <div class="dash-decor right-dashes">
            <span class="dash dash-1"></span>
            <span class="dash dash-2"></span>
            <span class="dash dash-3"></span>
          </div>
        </div>

        <!-- Referral Banner if Sponsor Ref is active -->
        <div v-if="sponsorRef && visibility.web_show_referral_banner" class="referral-banner">
          <span class="ref-icon">🎁</span>
          <span>Referred by Sponsor ID: <strong>{{ sponsorRef }}</strong></span>
        </div>

        <!-- Get It On Google Play Button -->
        <a
          v-if="visibility.web_show_playstore_btn"
          :href="playStoreUrl"
          target="_blank"
          rel="noopener noreferrer"
          class="playstore-btn"
          @click="onPlayStoreClick"
        >
          <div class="btn-left-icon">
            <svg class="google-play-svg" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
              <path fill="#410593" d="M72.6 30.1L273.7 256 72.6 481.9c-4.5-3.6-7.3-9.1-7.3-15.4V45.5c0-6.3 2.8-11.8 7.3-15.4z"/>
              <path fill="#04E061" d="M341.2 188.5L97.7 47.7c-8.2-4.7-17.7-6.2-25.1-17.6L273.7 256l67.5-67.5z"/>
              <path fill="#FF3A44" d="M341.2 323.5L273.7 256l-201.1 225.9c7.4-11.4 16.9-12.9 25.1-17.6l243.5-140.8z"/>
              <path fill="#FFC904" d="M428.5 238.1l-87.3-50.4L273.7 256l67.5 67.5 87.3-50.4c15.2-8.8 15.2-26.2 0-35z"/>
            </svg>
          </div>
          <div class="btn-text">
            <span class="btn-subtitle">GET IT ON</span>
            <span class="btn-title">Google Play</span>
          </div>
          <div class="btn-right-arrow">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="9 18 15 12 9 6"></polyline>
            </svg>
          </div>
        </a>

        <!-- Legal Terms Agreement -->
        <p v-if="visibility.web_show_terms_disclaimer" class="terms-disclaimer">
          By downloading the app, you agree to our<br />
          <router-link to="/about-us" class="legal-link">About Us</router-link>,
          <router-link to="/terms-and-conditions" class="legal-link">Terms &amp; Conditions</router-link>,
          <router-link to="/privacy-policy" class="legal-link">Privacy Policy</router-link>,
          <router-link to="/refund-policy" class="legal-link">Refund Policy</router-link> and
          <router-link to="/delete" class="legal-link">Delete Account</router-link>.
        </p>

      </main>

      <!-- Footer Copyright -->
      <footer v-if="visibility.web_show_footer" class="footer">
        <p class="powered-by">Powered by SR Digital Seva Kendram</p>
        <p class="copyright">&copy; 2026 SR Digital Seva Kendram. All rights reserved.</p>
      </footer>

    </div>
  </div>
</template>

<script>
const getApiBaseUrl = () => {
  if (typeof window !== 'undefined' && (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' || window.location.hostname.startsWith('192.168.'))) {
    return `${window.location.protocol}//${window.location.hostname}:5000`;
  }
  return import.meta.env.VITE_API_BASE_URL || 'https://recharge-app-production-5b63.up.railway.app';
};
const API_BASE_URL = getApiBaseUrl();

export default {
  name: 'LandingPage',
  data() {
    return {
      sponsorRef: '',
      visibility: {
        web_show_header_logo: true,
        web_show_hero_graphic: true,
        web_show_headline: true,
        web_show_referral_banner: true,
        web_show_playstore_btn: true,
        web_show_terms_disclaimer: true,
        web_show_footer: true
      }
    }
  },
  computed: {
    playStoreUrl() {
      const baseUrl = 'https://play.google.com/store/apps/details?id=com.app.earnfarm'
      return this.sponsorRef ? `${baseUrl}&ref=${encodeURIComponent(this.sponsorRef)}` : baseUrl
    }
  },
  async mounted() {
    this.fetchVisibilitySettings();
    const queryRef = this.$route.query.ref || this.$route.query.sponsor || this.$route.query.id
    if (queryRef) {
      this.sponsorRef = String(queryRef).trim()
      localStorage.setItem('sponsor_ref', this.sponsorRef)
      // Auto-redirect to Play Store on mobile devices when clicking deep link
      const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
      if (isMobile) {
        setTimeout(() => {
          window.location.href = this.playStoreUrl
        }, 1200)
      }
    } else if (localStorage.getItem('sponsor_ref')) {
      this.sponsorRef = localStorage.getItem('sponsor_ref')
    }
  },
  methods: {
    async fetchVisibilitySettings() {
      try {
        const res = await fetch(`${API_BASE_URL}/api/visibility`);
        if (res.ok) {
          const data = await res.json();
          this.visibility = {
            web_show_header_logo: data.web_show_header_logo !== false,
            web_show_hero_graphic: data.web_show_hero_graphic !== false,
            web_show_headline: data.web_show_headline !== false,
            web_show_referral_banner: data.web_show_referral_banner !== false,
            web_show_playstore_btn: data.web_show_playstore_btn !== false,
            web_show_terms_disclaimer: data.web_show_terms_disclaimer !== false,
            web_show_footer: data.web_show_footer !== false
          };
        }
      } catch (_) {}
    },
    onPlayStoreClick() {
      if (this.sponsorRef) {
        localStorage.setItem('sponsor_ref', this.sponsorRef)
      }
    }
  }
}
</script>

<style scoped>
.landing-page {
  min-height: 100vh;
  width: 100%;
  background-color: #F8FAFC;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px 12px;
  box-sizing: border-box;
  font-family: 'Outfit', 'Inter', system-ui, -apple-system, sans-serif;
}

/* Centralized Card Layout matching exact mobile/poster ratio */
.app-card {
  width: 100%;
  max-width: 480px;
  background: #FFFFFF;
  border-radius: 24px;
  box-shadow: 0 10px 40px rgba(15, 23, 42, 0.06), 0 1px 3px rgba(0,0,0,0.05);
  padding: 32px 24px 28px 24px;
  display: flex;
  flex-direction: column;
  align-items: center;
  box-sizing: border-box;
  overflow: hidden;
  border: 1px solid #F1F5F9;
}

/* Header & Logo */
.header {
  width: 100%;
  display: flex;
  justify-content: center;
  margin-bottom: 24px;
}

.referral-banner {
  background: #EFF6FF;
  border: 1px solid #BFDBFE;
  color: #1E40AF;
  font-size: 0.85rem;
  font-weight: 600;
  padding: 8px 16px;
  border-radius: 20px;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 12px;
}

.sr-logo-img {
  height: 85px;
  width: auto;
  object-fit: contain;
}

.logo-text {
  display: flex;
  flex-direction: column;
}

.title-blue {
  color: #0A369D;
  font-weight: 900;
  font-size: 1.45rem;
  line-height: 1.1;
  letter-spacing: -0.5px;
}

.title-red {
  color: #DC2626;
  font-weight: 800;
  font-size: 0.95rem;
  letter-spacing: 4px;
  margin-top: 2px;
}

/* Main Hero Graphic */
.main-content {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.hero-image-wrapper {
  width: 100%;
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
}

.hero-graphic {
  width: 100%;
  max-width: 420px;
  height: auto;
  object-fit: contain;
  display: block;
}

/* Captcha -> Cash Headline */
.headline-section {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-bottom: 28px;
  position: relative;
  width: 100%;
}

.headline-text {
  display: inline-flex;
  align-items: center;
  position: relative;
  font-size: 2.3rem;
  font-weight: 900;
}

.text-captcha {
  color: #0A2540;
  letter-spacing: -0.5px;
}

.text-arrow {
  color: #DC2626;
  font-weight: 900;
}

.text-cash {
  color: #DC2626;
  letter-spacing: -0.5px;
}

/* Curved Red Underline SVG */
.curve-underline {
  position: absolute;
  bottom: -14px;
  left: 0;
  width: 100%;
  height: 18px;
}

/* Dash Sparkle Decorations */
.dash-decor {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.dash {
  height: 3.5px;
  border-radius: 2px;
}

.left-dashes .dash {
  background-color: #F59E0B;
}
.left-dashes .dash-1 { width: 14px; transform: rotate(-15deg); }
.left-dashes .dash-2 { width: 20px; transform: rotate(0deg); }
.left-dashes .dash-3 { width: 14px; transform: rotate(15deg); }

.right-dashes .dash-1 { width: 14px; transform: rotate(15deg); background-color: #0052CC; }
.right-dashes .dash-2 { width: 20px; transform: rotate(0deg); background-color: #E01A22; }
.right-dashes .dash-3 { width: 14px; transform: rotate(-15deg); background-color: #0052CC; }

/* Play Store Button */
.playstore-btn {
  width: 100%;
  max-width: 380px;
  height: 64px;
  background: linear-gradient(135deg, #0052CC 0%, #0044B3 50%, #003399 100%);
  border-radius: 50px;
  padding: 6px 12px 6px 8px;
  box-sizing: border-box;
  display: flex;
  align-items: center;
  text-decoration: none;
  box-shadow: 0 10px 25px rgba(0, 82, 204, 0.35);
  transition: all 0.25s ease;
  margin-bottom: 24px;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.playstore-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 14px 30px rgba(0, 82, 204, 0.45);
}

.btn-left-icon {
  width: 48px;
  height: 48px;
  background: #FFFFFF;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.google-play-svg {
  width: 26px;
  height: 26px;
}

.btn-text {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #FFFFFF;
  text-align: center;
  padding: 0 8px;
}

.btn-subtitle {
  font-size: 0.7rem;
  font-weight: 800;
  letter-spacing: 1.5px;
  opacity: 0.95;
  text-transform: uppercase;
}

.btn-title {
  font-size: 1.4rem;
  font-weight: 900;
  line-height: 1.1;
  letter-spacing: -0.3px;
}

.btn-right-arrow {
  width: 38px;
  height: 38px;
  background: #FFFFFF;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  color: #0052CC;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.btn-right-arrow svg {
  width: 20px;
  height: 20px;
}

/* Disclaimer & Legal Links */
.terms-disclaimer {
  font-size: 0.82rem;
  color: #475569;
  text-align: center;
  line-height: 1.5;
  font-weight: 500;
  margin-bottom: 24px;
}

.legal-link {
  color: #E11D48;
  font-weight: 700;
  text-decoration: none;
  transition: color 0.15s ease;
}

.legal-link:hover {
  text-decoration: underline;
  color: #BE123C;
}

/* Footer Section */
.footer {
  width: 100%;
  text-align: center;
  border-top: 1px solid #F1F5F9;
  padding-top: 18px;
}

.powered-by {
  font-size: 0.8rem;
  font-weight: 600;
  color: #64748B;
  margin-bottom: 4px;
}

.copyright {
  font-size: 0.78rem;
  color: #94A3B8;
  font-weight: 500;
}



/* Responsive Scaling for Mobile Screens */
@media (max-width: 600px) {
  .landing-page {
    padding: 0;
    background: #FFFFFF;
    align-items: stretch;
  }
  .app-card {
    max-width: 100%;
    width: 100%;
    border-radius: 0;
    box-shadow: none;
    border: none;
    padding: 24px 16px 24px 16px;
    min-height: 100vh;
    justify-content: space-between;
  }
  .sr-logo-img {
    height: 70px;
  }
  .title-blue {
    font-size: 1.25rem;
  }
  .title-red {
    font-size: 0.85rem;
    letter-spacing: 3px;
  }
  .hero-graphic {
    max-width: 100%;
  }
  .headline-text {
    font-size: 2rem;
  }
  .playstore-btn {
    width: 100%;
    max-width: 100%;
    height: 60px;
  }
  .btn-title {
    font-size: 1.3rem;
  }
}
</style>
