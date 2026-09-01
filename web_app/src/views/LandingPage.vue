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

          <div class="hero-cta-group">
            <a href="#contact" class="btn-primary">Get Started Now</a>
            <a href="#services" class="btn-secondary">Explore Services</a>
          </div>
        </div>

        <!-- Hero Right Visual Column with Girl Image & Floating Badges -->
        <div class="hero-right">
          <!-- Background Ambient Glow Waves -->
          <div class="hero-bg-wave"></div>
          <div class="hero-bg-wave-secondary"></div>

          <div class="visual-wrapper">
            <!-- 1. Flying Card 1: Top Left Lightning -->
            <div class="floating-badge badge-lightning float-anim-1" title="Instant Recharges">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" class="badge-icon">
                <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"></path>
              </svg>
            </div>

            <!-- 2. Flying Card 2: Top Right Satellite Dish -->
            <div class="floating-badge badge-dth float-anim-2" title="DTH Topup">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="badge-icon">
                <path d="M6.08 17.5a9 9 0 0 1 11.84 0M3 13.5a13 13 0 0 1 18 0"></path>
                <path d="M12 12v10M12 22h4m-8 0h4"></path>
                <circle cx="12" cy="7" r="2" fill="#0052CC"></circle>
              </svg>
            </div>

            <!-- 3. Flying Card 3: Middle Right Rupee Symbol -->
            <div class="floating-badge badge-rupee float-anim-3" title="Best Rates & Cashback">
              <span class="rupee-symbol">₹</span>
            </div>

            <!-- 4. Flying Card 4: Bottom Right Lightbulb -->
            <div class="floating-badge badge-bulb float-anim-4" title="Electricity Bills">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#D97706" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" class="badge-icon">
                <path d="M9 18h6M10 22h4M15 14.5A7 7 0 1 0 9 14.5M12 2v2"></path>
              </svg>
            </div>

            <!-- 5. Flying Card 5: Bottom Left Mobile Icon -->
            <div class="floating-badge badge-phone float-anim-5" title="Mobile Recharge">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" class="badge-icon">
                <rect x="5" y="2" width="14" height="20" rx="2" ry="2"></rect>
                <line x1="12" y1="18" x2="12.01" y2="18"></line>
              </svg>
            </div>

            <!-- Smiling Woman Image holding Phone -->
            <img :src="bannerImg" alt="SR Digital Seva Woman holding phone" class="woman-image" @error="handleImageError" />
          </div>
        </div>
      </div>
    </section>

    <!-- Services Section -->
    <section class="services-section" id="services">
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

    <!-- Why Choose Us Feature Info Section (Pic | Title | Description & Features) -->
    <section class="why-us-section">
      <div class="why-us-content">
        <div class="why-us-grid">
          <!-- Left Column: Visual Security Card & Stats -->
          <div class="why-us-visual-col">
            <div class="visual-card">
              <div class="card-badge">TRUSTED PAYMENT PLATFORM</div>
              <h3 class="visual-title">Fast, Safe & Transparent Digital Transactions</h3>
              <p class="visual-desc">SR Digital Seva Kendram powers over 100,000+ daily recharges across Telangana with bank-grade encryption and 99.9% uptime.</p>
              
              <div class="stats-row">
                <div class="stat-box">
                  <span class="stat-num">99.9%</span>
                  <span class="stat-lbl">Success Rate</span>
                </div>
                <div class="stat-box">
                  <span class="stat-num">24/7</span>
                  <span class="stat-lbl">Instant Support</span>
                </div>
                <div class="stat-box">
                  <span class="stat-num">100%</span>
                  <span class="stat-lbl">Secure SSL</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Right Column: 4 Feature Items -->
          <div class="why-us-info-col">
            <div class="section-tag">WHY CHOOSE US</div>
            <h2 class="why-us-heading">Empowering Your Daily Digital Payments</h2>
            <p class="why-us-subtext">We provide a seamless platform for customers and retailers with maximum convenience and instant automated settlements.</p>

            <div class="features-list">
              <div class="feature-item">
                <div class="feature-icon-wrapper blue-light">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2" class="f-icon"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"></path></svg>
                </div>
                <div class="feature-text">
                  <h4>Instant Processing</h4>
                  <p>Recharges and bill payments are processed within seconds with direct provider connectivity.</p>
                </div>
              </div>

              <div class="feature-item">
                <div class="feature-icon-wrapper green-light">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#10B981" stroke-width="2.2" class="f-icon"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                </div>
                <div class="feature-text">
                  <h4>Bank-Grade Security</h4>
                  <p>Encrypted multi-layer security keeps your personal information and transaction credentials safe.</p>
                </div>
              </div>

              <div class="feature-item">
                <div class="feature-icon-wrapper purple-light">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#8B5CF6" stroke-width="2.2" class="f-icon"><circle cx="12" cy="12" r="10"></circle><path d="M12 8v4l3 3"></path></svg>
                </div>
                <div class="feature-text">
                  <h4>24/7 Continuous Service</h4>
                  <p>Our automated systems operate non-stop 365 days a year so you never miss a bill due date.</p>
                </div>
              </div>

              <div class="feature-item">
                <div class="feature-icon-wrapper orange-light">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#F97316" stroke-width="2.2" class="f-icon"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path></svg>
                </div>
                <div class="feature-text">
                  <h4>Exclusive Commission & Offers</h4>
                  <p>Enjoy attractive cashbacks, partner commissions, and special discounts on every payment.</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- How It Works 3-Step Process Section -->
    <section class="how-it-works-section">
      <div class="how-it-works-content">
        <div class="section-center-head">
          <span class="pill-tag">SIMPLE STEPS</span>
          <h2 class="section-title-dark">How It Works</h2>
          <p class="section-desc-gray">Complete your recharge in 3 quick and easy steps</p>
        </div>

        <div class="steps-grid">
          <div class="step-card">
            <div class="step-num">01</div>
            <div class="step-icon-bg">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2"><rect x="3" y="3" width="18" height="18" rx="2"></rect><path d="M9 12h6M12 9v6"></path></svg>
            </div>
            <h3 class="step-title">Select Service</h3>
            <p class="step-text">Choose Mobile, DTH, Electricity, Broadband or Gas bill payment service.</p>
          </div>

          <div class="step-card">
            <div class="step-num">02</div>
            <div class="step-icon-bg">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2"><rect x="2" y="4" width="20" height="16" rx="2"></rect><path d="M6 10h12M6 14h8"></path></svg>
            </div>
            <h3 class="step-title">Enter Details & Amount</h3>
            <p class="step-text">Input your mobile number, consumer ID, or operator details with plan amount.</p>
          </div>

          <div class="step-card">
            <div class="step-num">03</div>
            <div class="step-icon-bg">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#10B981" stroke-width="2.2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
            </div>
            <h3 class="step-title">Instant Success</h3>
            <p class="step-text">Pay securely and receive immediate confirmation with digital payment receipt.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Retailer Partnership Opportunity Banner -->
    <section class="partner-banner-section">
      <div class="partner-banner-content">
        <div class="banner-box">
          <div class="banner-left">
            <span class="banner-pill">RETAILER & AGENT OPPORTUNITY</span>
            <h2 class="banner-title">Start Your Own Recharge Business Today</h2>
            <p class="banner-text">Join SR Digital Seva Kendram network as an authorized retailer or agent. Earn high commissions on every transaction with instant wallet top-ups.</p>
          </div>
          <div class="banner-right">
            <a href="#contact" class="btn-banner-action">Become an Agent</a>
          </div>
        </div>
      </div>
    </section>

    <!-- Contact Form Section (Placed right before Download Section) -->
    <section class="contact-section" id="contact">
      <div class="contact-content">
        <div class="contact-header-center">
          <span class="contact-tag">GET IN TOUCH</span>
          <h2 class="contact-main-title">Send Us a Message</h2>
          <p class="contact-sub-title">Have a question, feedback, or need help with a transaction? Fill out the form below and our team will respond promptly.</p>
        </div>

        <div class="contact-grid-wrapper">
          <!-- Left Column: Contact Details Card -->
          <div class="contact-info-card">
            <h3 class="info-card-heading">Contact Information</h3>
            <p class="info-card-desc">Reach out to us directly through any of the following channels or visit our Warangal kendram.</p>

            <div class="info-items-list">
              <div class="info-item">
                <div class="info-icon">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path></svg>
                </div>
                <div class="info-text">
                  <span class="label">Phone Support</span>
                  <span class="value">+91 9988494936</span>
                </div>
              </div>

              <div class="info-item">
                <div class="info-icon">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                </div>
                <div class="info-text">
                  <span class="label">Email Address</span>
                  <span class="value">info@srdigitalseva.com</span>
                </div>
              </div>

              <div class="info-item">
                <div class="info-icon">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                </div>
                <div class="info-text">
                  <span class="label">Office Address</span>
                  <span class="value">Warangal, Telangana 506005</span>
                </div>
              </div>

              <div class="info-item">
                <div class="info-icon">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#0052CC" stroke-width="2.2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                </div>
                <div class="info-text">
                  <span class="label">Working Hours</span>
                  <span class="value">Mon - Sat: 9:00 AM - 8:00 PM</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Right Column: Interactive Form -->
          <div class="contact-form-card">
            <form @submit.prevent="submitContactForm" class="contact-form">
              <div v-if="formSubmitted" class="form-success-alert">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#10B981" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                <span>Thank you! Your message has been sent successfully. We will get back to you shortly.</span>
              </div>

              <div class="form-row">
                <div class="form-group">
                  <label for="c-name" class="form-label">Full Name <span class="required">*</span></label>
                  <input type="text" id="c-name" v-model="contactForm.name" placeholder="Enter your full name" required class="form-input" />
                </div>

                <div class="form-group">
                  <label for="c-phone" class="form-label">Mobile Number <span class="required">*</span></label>
                  <input type="tel" id="c-phone" v-model="contactForm.phone" placeholder="Enter 10-digit mobile number" required class="form-input" />
                </div>
              </div>

              <div class="form-group">
                <label for="c-service" class="form-label">Select Service / Inquiry Type</label>
                <select id="c-service" v-model="contactForm.service" class="form-select">
                  <option value="General Query">General Inquiry</option>
                  <option value="Mobile Recharge">Mobile Recharge Issue</option>
                  <option value="DTH Recharge">DTH Connection Inquiry</option>
                  <option value="Electricity Bill">Electricity Bill Payment</option>
                  <option value="Retailer Registration">Become a Retailer / Agent</option>
                  <option value="Payment Support">Transaction / Refund Support</option>
                </select>
              </div>

              <div class="form-group">
                <label for="c-message" class="form-label">Message / Details</label>
                <textarea id="c-message" v-model="contactForm.message" rows="4" placeholder="Write your message or inquiry details here..." class="form-textarea"></textarea>
              </div>

              <button type="submit" class="form-submit-btn">
                <span>Send Message</span>
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                  <line x1="22" y1="2" x2="11" y2="13"></line>
                  <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
                </svg>
              </button>
            </form>
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
      contactForm: {
        name: '',
        phone: '',
        service: 'General Query',
        message: ''
      },
      formSubmitted: false
    };
  },
  methods: {
    handleImageError(e) {
      e.target.src = 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?auto=format&fit=crop&q=80&w=600';
    },
    submitContactForm() {
      if (this.contactForm.name && this.contactForm.phone) {
        this.formSubmitted = true;
        setTimeout(() => {
          this.formSubmitted = false;
          this.contactForm = {
            name: '',
            phone: '',
            service: 'General Query',
            message: ''
          };
        }, 5000);
      }
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
  margin-bottom: 2rem;
}

.hero-cta-group {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.btn-primary {
  background-color: #0052CC;
  color: #FFFFFF;
  padding: 0.85rem 1.8rem;
  border-radius: 10px;
  font-weight: 700;
  font-size: 0.95rem;
  text-decoration: none;
  box-shadow: 0 6px 20px rgba(0, 82, 204, 0.3);
  transition: all 0.25s ease;
}

.btn-primary:hover {
  background-color: #0040A8;
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 82, 204, 0.4);
}

.btn-secondary {
  background-color: #FFFFFF;
  color: #1F2937;
  padding: 0.85rem 1.8rem;
  border-radius: 10px;
  font-weight: 700;
  font-size: 0.95rem;
  text-decoration: none;
  border: 1.5px solid #E5E7EB;
  transition: all 0.25s ease;
}

.btn-secondary:hover {
  background-color: #F9FAFB;
  border-color: #D1D5DB;
  transform: translateY(-2px);
}

/* Hero Right Visual Column */
.hero-right {
  flex: 1;
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 500px;
  z-index: 1;
}

.hero-bg-wave {
  position: absolute;
  top: -40px;
  right: -20px;
  width: 480px;
  height: 480px;
  background: radial-gradient(circle, rgba(0,82,204,0.09) 0%, rgba(255,255,255,0) 70%);
  border-radius: 50%;
  z-index: -1;
}

.hero-bg-wave-secondary {
  position: absolute;
  bottom: -40px;
  left: -20px;
  width: 360px;
  height: 360px;
  background: radial-gradient(circle, rgba(0,82,204,0.06) 0%, rgba(255,255,255,0) 70%);
  border-radius: 50%;
  z-index: -1;
}

.visual-wrapper {
  position: relative;
  width: 100%;
  max-width: 480px;
  height: 500px;
  display: flex;
  justify-content: center;
  align-items: flex-end;
}

.woman-image {
  height: 100%;
  max-height: 490px;
  width: auto;
  object-fit: contain;
  z-index: 2;
  pointer-events: none;
  filter: drop-shadow(0 15px 30px rgba(0, 0, 0, 0.08));
}

/* Flying Floating Badges around Girl Image */
.floating-badge {
  position: absolute;
  width: 52px;
  height: 52px;
  background-color: #FFFFFF;
  border-radius: 50%;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.12);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 5;
  border: 1.5px solid rgba(255, 255, 255, 0.9);
  cursor: pointer;
  transition: transform 0.2s ease;
}

.floating-badge:hover {
  transform: scale(1.15) !important;
}

.badge-icon {
  width: 24px;
  height: 24px;
}

.rupee-symbol {
  color: #0052CC;
  font-weight: 800;
  font-size: 1.4rem;
}

/* Badge Absolute Positioning surrounding Girl Image */
.badge-lightning {
  top: 40px;
  left: 20px;
}

.badge-dth {
  top: 50px;
  right: 20px;
}

.badge-rupee {
  top: 210px;
  right: -10px;
}

.badge-bulb {
  bottom: 80px;
  right: 30px;
  background-color: #FFFBEB;
}

.badge-phone {
  bottom: 90px;
  left: 10px;
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
  50% { transform: translateY(-14px) rotate(5deg); }
}

@keyframes floatTwo {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-16px) rotate(-6deg); }
}

@keyframes floatThree {
  0%, 100% { transform: translateY(0px) scale(1); }
  50% { transform: translateY(-12px) scale(1.08); }
}

@keyframes floatFour {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-15px) rotate(5deg); }
}

@keyframes floatFive {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-13px) rotate(-5deg); }
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

/* Why Choose Us Feature Info Section */
.why-us-section {
  width: 100%;
  padding: 5rem 0;
  background-color: #F8FAFC;
  border-top: 1px solid #F1F5F9;
  border-bottom: 1px solid #F1F5F9;
}

.why-us-content {
  max-width: 1320px;
  margin: 0 auto;
  padding: 0 2rem;
  width: 100%;
}

.why-us-grid {
  display: grid;
  grid-template-columns: 1fr 1.15fr;
  gap: 3.5rem;
  align-items: center;
}

.visual-card {
  background: linear-gradient(135deg, #0B132B 0%, #1E293B 100%);
  border-radius: 24px;
  padding: 3rem 2.5rem;
  color: #FFFFFF;
  box-shadow: 0 20px 40px rgba(11, 19, 43, 0.15);
  position: relative;
  overflow: hidden;
}

.visual-card::after {
  content: '';
  position: absolute;
  top: -80px;
  right: -80px;
  width: 250px;
  height: 250px;
  background: radial-gradient(circle, rgba(0,82,204,0.3) 0%, rgba(0,0,0,0) 70%);
  border-radius: 50%;
}

.card-badge {
  display: inline-block;
  background: rgba(0, 82, 204, 0.35);
  border: 1px solid rgba(0, 82, 204, 0.6);
  color: #60A5FA;
  font-size: 0.72rem;
  font-weight: 800;
  letter-spacing: 0.08em;
  padding: 0.4rem 1rem;
  border-radius: 999px;
  margin-bottom: 1.5rem;
}

.visual-title {
  font-size: 1.8rem;
  font-weight: 800;
  line-height: 1.3;
  margin-bottom: 1rem;
  color: #FFFFFF;
}

.visual-desc {
  font-size: 0.95rem;
  line-height: 1.6;
  color: #94A3B8;
  margin-bottom: 2.2rem;
}

.stats-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  padding-top: 1.5rem;
}

.stat-box {
  display: flex;
  flex-direction: column;
}

.stat-num {
  font-size: 1.5rem;
  font-weight: 900;
  color: #60A5FA;
}

.stat-lbl {
  font-size: 0.75rem;
  color: #94A3B8;
  font-weight: 600;
}

.section-tag {
  color: #0052CC;
  font-size: 0.78rem;
  font-weight: 800;
  letter-spacing: 0.08em;
  margin-bottom: 0.5rem;
}

.why-us-heading {
  font-size: 2.2rem;
  font-weight: 800;
  color: #0B132B;
  margin-bottom: 0.8rem;
  line-height: 1.25;
}

.why-us-subtext {
  font-size: 1.02rem;
  color: #4B5563;
  margin-bottom: 2.2rem;
  line-height: 1.55;
}

.features-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.feature-item {
  display: flex;
  align-items: flex-start;
  gap: 1.2rem;
  background: #FFFFFF;
  padding: 1.2rem 1.4rem;
  border-radius: 14px;
  border: 1px solid #E2E8F0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
  transition: transform 0.2s ease, border-color 0.2s ease;
}

.feature-item:hover {
  transform: translateX(4px);
  border-color: #CBD5E1;
}

.feature-icon-wrapper {
  width: 46px;
  height: 46px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.blue-light { background-color: #EFF6FF; }
.green-light { background-color: #F0FDF4; }
.purple-light { background-color: #FAF5FF; }
.orange-light { background-color: #FFF7ED; }

.f-icon {
  width: 22px;
  height: 22px;
}

.feature-text h4 {
  font-size: 1.05rem;
  font-weight: 700;
  color: #1E2937;
  margin-bottom: 0.25rem;
}

.feature-text p {
  font-size: 0.88rem;
  color: #6B7280;
  line-height: 1.45;
}

/* How It Works Section */
.how-it-works-section {
  width: 100%;
  padding: 5rem 0;
  background-color: #FFFFFF;
}

.how-it-works-content {
  max-width: 1320px;
  margin: 0 auto;
  padding: 0 2rem;
  width: 100%;
}

.section-center-head {
  text-align: center;
  max-width: 600px;
  margin: 0 auto 3.5rem;
}

.pill-tag {
  display: inline-block;
  background: #F0F6FF;
  color: #0052CC;
  font-size: 0.75rem;
  font-weight: 800;
  letter-spacing: 0.08em;
  padding: 0.4rem 1.1rem;
  border-radius: 999px;
  margin-bottom: 0.8rem;
}

.section-title-dark {
  font-size: 2.1rem;
  font-weight: 800;
  color: #0B132B;
  margin-bottom: 0.5rem;
}

.section-desc-gray {
  font-size: 1rem;
  color: #6B7280;
}

.steps-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2rem;
  max-width: 1100px;
  margin: 0 auto;
}

.step-card {
  background: #FFFFFF;
  border: 1px solid #F1F5F9;
  border-radius: 18px;
  padding: 2.5rem 1.8rem;
  position: relative;
  text-align: center;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.03);
  transition: transform 0.3s ease;
}

.step-card:hover {
  transform: translateY(-5px);
}

.step-num {
  position: absolute;
  top: 16px;
  right: 20px;
  font-size: 1.8rem;
  font-weight: 900;
  color: #E2E8F0;
}

.step-icon-bg {
  width: 60px;
  height: 60px;
  background-color: #F0F6FF;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1.5rem;
}

.step-icon-bg svg {
  width: 26px;
  height: 26px;
}

.step-title {
  font-size: 1.2rem;
  font-weight: 700;
  color: #1F2937;
  margin-bottom: 0.6rem;
}

.step-text {
  font-size: 0.9rem;
  color: #6B7280;
  line-height: 1.5;
}

/* Retailer Partner Opportunity Banner */
.partner-banner-section {
  width: 100%;
  padding: 1.5rem 0 3rem;
  background-color: #FFFFFF;
}

.partner-banner-content {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 2rem;
  width: 100%;
}

.banner-box {
  background: linear-gradient(135deg, #0052CC 0%, #1D4ED8 100%);
  border-radius: 20px;
  padding: 3rem;
  color: #FFFFFF;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 2rem;
  box-shadow: 0 15px 35px rgba(0, 82, 204, 0.25);
}

.banner-pill {
  font-size: 0.72rem;
  font-weight: 800;
  letter-spacing: 0.08em;
  background: rgba(255, 255, 255, 0.2);
  padding: 0.35rem 0.9rem;
  border-radius: 999px;
  display: inline-block;
  margin-bottom: 0.8rem;
}

.banner-title {
  font-size: 1.8rem;
  font-weight: 800;
  margin-bottom: 0.6rem;
  color: #FFFFFF;
}

.banner-text {
  font-size: 0.95rem;
  opacity: 0.9;
  max-width: 600px;
  line-height: 1.5;
}

.btn-banner-action {
  background-color: #FFFFFF;
  color: #0052CC;
  padding: 0.9rem 2rem;
  border-radius: 10px;
  font-weight: 800;
  font-size: 0.95rem;
  text-decoration: none;
  white-space: nowrap;
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
  transition: transform 0.2s ease, background-color 0.2s ease;
  display: inline-block;
}

.btn-banner-action:hover {
  background-color: #F8FAFC;
  transform: translateY(-2px);
}

/* Contact Section (Before Download Section) */
.contact-section {
  width: 100%;
  padding: 5rem 0;
  background-color: #F8FAFC;
  border-top: 1px solid #F1F5F9;
}

.contact-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
  width: 100%;
}

.contact-header-center {
  text-align: center;
  max-width: 650px;
  margin: 0 auto 3.5rem;
}

.contact-tag {
  color: #0052CC;
  font-size: 0.78rem;
  font-weight: 800;
  letter-spacing: 0.08em;
  display: inline-block;
  margin-bottom: 0.5rem;
}

.contact-main-title {
  font-size: 2.2rem;
  font-weight: 800;
  color: #0B132B;
  margin-bottom: 0.6rem;
}

.contact-sub-title {
  font-size: 1rem;
  color: #6B7280;
  line-height: 1.5;
}

.contact-grid-wrapper {
  display: grid;
  grid-template-columns: 1fr 1.4fr;
  gap: 2.5rem;
  align-items: stretch;
}

.contact-info-card {
  background-color: #0B132B;
  border-radius: 20px;
  padding: 2.5rem 2rem;
  color: #FFFFFF;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  box-shadow: 0 15px 35px rgba(11, 19, 43, 0.15);
}

.info-card-heading {
  font-size: 1.5rem;
  font-weight: 800;
  margin-bottom: 0.6rem;
  color: #FFFFFF;
}

.info-card-desc {
  font-size: 0.9rem;
  color: #94A3B8;
  margin-bottom: 2.5rem;
  line-height: 1.5;
}

.info-items-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.info-icon {
  width: 44px;
  height: 44px;
  background-color: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.info-icon svg {
  width: 20px;
  height: 20px;
}

.info-text {
  display: flex;
  flex-direction: column;
}

.info-text .label {
  font-size: 0.75rem;
  color: #94A3B8;
  font-weight: 600;
}

.info-text .value {
  font-size: 0.95rem;
  color: #FFFFFF;
  font-weight: 700;
}

.contact-form-card {
  background-color: #FFFFFF;
  border-radius: 20px;
  padding: 2.5rem 2.2rem;
  border: 1px solid #E2E8F0;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
}

.contact-form {
  display: flex;
  flex-direction: column;
  gap: 1.3rem;
}

.form-success-alert {
  background-color: #ECFDF5;
  border: 1px solid #A7F3D0;
  color: #065F46;
  padding: 1rem;
  border-radius: 10px;
  font-size: 0.9rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.8rem;
  line-height: 1.4;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.2rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.form-label {
  font-size: 0.88rem;
  font-weight: 700;
  color: #374151;
}

.form-label .required {
  color: #EF4444;
}

.form-input, .form-select, .form-textarea {
  width: 100%;
  padding: 0.75rem 1rem;
  border-radius: 10px;
  border: 1.5px solid #E5E7EB;
  font-family: inherit;
  font-size: 0.92rem;
  color: #1F2937;
  background-color: #FFFFFF;
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
  outline: none;
}

.form-input:focus, .form-select:focus, .form-textarea:focus {
  border-color: #0052CC;
  box-shadow: 0 0 0 3px rgba(0, 82, 204, 0.12);
}

.form-textarea {
  resize: vertical;
}

.form-submit-btn {
  background-color: #0052CC;
  color: #FFFFFF;
  border: none;
  padding: 0.9rem 1.8rem;
  border-radius: 10px;
  font-weight: 700;
  font-size: 0.95rem;
  font-family: inherit;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.6rem;
  box-shadow: 0 6px 20px rgba(0, 82, 204, 0.25);
  transition: all 0.2s ease;
  margin-top: 0.5rem;
}

.form-submit-btn:hover {
  background-color: #0040A8;
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 82, 204, 0.35);
}

/* Download App Section */
.download-section {
  width: 100%;
  padding: 4rem 0 3rem;
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

  .hero-cta-group {
    width: 100%;
    justify-content: flex-start;
  }

  .why-us-grid {
    grid-template-columns: 1fr;
    gap: 2.5rem;
  }

  .contact-grid-wrapper {
    grid-template-columns: 1fr;
  }
  
  .services-grid, .steps-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .banner-box {
    flex-direction: column;
    text-align: center;
    padding: 2.2rem;
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
  .form-row {
    grid-template-columns: 1fr;
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
  .hero-cta-group {
    flex-direction: column;
    width: 100%;
    gap: 0.8rem;
  }
  .btn-primary, .btn-secondary {
    width: 100%;
    text-align: center;
    box-sizing: border-box;
    padding: 0.85rem 1rem;
  }
  .services-grid, .steps-grid {
    grid-template-columns: 1fr;
    gap: 1.2rem;
  }
  .stats-row {
    grid-template-columns: 1fr;
    gap: 0.8rem;
  }
  .visual-card {
    padding: 2rem 1.5rem;
  }
  .contact-form-card {
    padding: 1.8rem 1.2rem;
  }
}
</style>

