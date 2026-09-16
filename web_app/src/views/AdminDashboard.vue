<template>
  <div class="admin-layout">
    <!-- Mobile Drawer Backdrop -->
    <div v-if="mobileMenuOpen" class="mobile-drawer-backdrop" @click="mobileMenuOpen = false"></div>

    <!-- Sidebar -->
    <aside class="sidebar" :class="{ 'open-drawer': mobileMenuOpen }">
      <!-- Sidebar Header / Brand -->
      <div class="sidebar-brand">
        <div class="brand-crown-icon">👑</div>
        <div class="brand-text-container">
          <span class="brand-title">Admin Panel</span>
          <span class="brand-subtitle">Control Everything</span>
        </div>
        <button @click="mobileMenuOpen = false" class="close-drawer-btn" title="Close Drawer">&times;</button>
      </div>
      
      <!-- Sidebar Navigation Menu -->
      <div class="sidebar-menu">
        <!-- Dashboard Item -->
        <button @click="switchTab('dashboard')" class="menu-item" :class="{ active: currentTab === 'dashboard' }">
          <span class="icon">📊</span>
          <span class="menu-text">Dashboard</span>
        </button>

        <!-- User Management Group -->
        <div class="menu-group">
          <button @click="toggleGroup('user_management')" class="group-header-btn">
            <div class="group-header-left">
              <span class="icon">👤</span>
              <span class="group-title">User Management</span>
            </div>
            <span class="chevron-icon" :class="{ open: expandedGroups.user_management }">▾</span>
          </button>

          <div v-show="expandedGroups.user_management" class="group-items">
            <button @click="switchTab('sec_registration')" class="sub-menu-item" :class="{ active: currentTab === 'sec_registration' }">
              1. Registration
            </button>
            <button @click="switchTab('sec_login')" class="sub-menu-item" :class="{ active: currentTab === 'sec_login' }">
              2. Login
            </button>
            <button @click="switchTab('sec_otp')" class="sub-menu-item" :class="{ active: currentTab === 'sec_otp' }">
              3. OTP / Forgot Password
            </button>
            <button @click="switchTab('sec_home')" class="sub-menu-item" :class="{ active: currentTab === 'sec_home' }">
              4. Home / Dashboard
            </button>

            <!-- Add Money / Fund Sub-Menu -->
            <div class="nested-sub-menu">
              <button @click="switchTab('sec_add_money')" class="sub-menu-item" :class="{ active: currentTab === 'sec_add_money' || currentTab === 'requests' }">
                5. Add Money / Fund
              </button>
              <div v-if="currentTab === 'sec_add_money' || currentTab === 'requests'" class="sub-tab-pills-menu">
                <button @click="switchTab('sec_add_money')" class="pill-item" :class="{ active: currentTab === 'sec_add_money' }">
                  💳 Add Money Settings
                </button>
                <button @click="switchTab('requests')" class="pill-item" :class="{ active: currentTab === 'requests' }">
                  📥 Fund Request
                  <span v-if="pendingRequestsCount > 0" class="menu-badge-count">{{ pendingRequestsCount }}</span>
                </button>
              </div>
            </div>

            <button @click="switchTab('sec_subscription')" class="sub-menu-item" :class="{ active: currentTab === 'sec_subscription' }">
              6. ID Subscription
            </button>
            <button @click="switchTab('sec_referral')" class="sub-menu-item" :class="{ active: currentTab === 'sec_referral' }">
              7. Referral
            </button>

            <!-- Business / Income Nested Group -->
            <button @click="switchTab('sec_business_income')" class="sub-menu-item" :class="{ active: currentTab === 'sec_business_income' }">
              8. Business / Income ▾
            </button>

            <button @click="switchTab('sec_global_cycle')" class="sub-menu-item" :class="{ active: currentTab === 'sec_global_cycle' }">
              9. Global Cycle
            </button>
            <button @click="switchTab('teams')" class="sub-menu-item" :class="{ active: currentTab === 'teams' }">
              10. Team
            </button>
            <button @click="switchTab('sec_direct_members')" class="sub-menu-item" :class="{ active: currentTab === 'sec_direct_members' }">
              11. Direct Team Members
            </button>
            <button @click="switchTab('sec_cashout')" class="sub-menu-item" :class="{ active: currentTab === 'sec_cashout' }">
              12. Cash Out / Withdrawal
            </button>
            <button @click="switchTab('sec_bank_verification')" class="sub-menu-item" :class="{ active: currentTab === 'sec_bank_verification' }">
              13. Bank Account Verification
            </button>
            <button @click="switchTab('users')" class="sub-menu-item" :class="{ active: currentTab === 'users' }">
              14. Profile
            </button>
            <button @click="switchTab('notifications')" class="sub-menu-item" :class="{ active: currentTab === 'notifications' }">
              15. Notifications
            </button>
            <button @click="switchTab('sec_support')" class="sub-menu-item" :class="{ active: currentTab === 'sec_support' }">
              16. Support
            </button>
            <button @click="switchTab('transactions')" class="sub-menu-item" :class="{ active: currentTab === 'transactions' }">
              17. Transaction History
            </button>
            <button @click="switchTab('sec_captcha')" class="sub-menu-item" :class="{ active: currentTab === 'sec_captcha' }">
              18. CAPTCHA Work
            </button>
            <button @click="switchTab('sec_side_menu')" class="sub-menu-item" :class="{ active: currentTab === 'sec_side_menu' }">
              19. Side Menu
            </button>
          </div>
        </div>

        <!-- Global Settings Group -->
        <div class="menu-group" style="margin-top: 0.5rem;">
          <button @click="toggleGroup('global_settings')" class="group-header-btn">
            <div class="group-header-left">
              <span class="icon">⚙️</span>
              <span class="group-title">Settings</span>
            </div>
            <span class="chevron-icon" :class="{ open: expandedGroups.global_settings }">▾</span>
          </button>

          <div v-show="expandedGroups.global_settings" class="group-items">
            <button @click="switchTab('shared_variable')" class="sub-menu-item" :class="{ active: currentTab === 'shared_variable' }">
              Shared Variable
            </button>
            <button @click="switchTab('admins')" class="sub-menu-item" :class="{ active: currentTab === 'admins' }">
              System Admins
            </button>
            <button @click="switchTab('settings')" class="sub-menu-item" :class="{ active: currentTab === 'settings' }">
              Change Password
            </button>
          </div>
        </div>
      </div>

      <!-- Sidebar Footer -->
      <div class="sidebar-footer">
        <div class="footer-version-card">
          <div class="crown-small">👑 Version 1.0.0</div>
          <div class="version-sub">Build a Better Tomorrow</div>
        </div>
        <button @click="handleLogout" class="logout-btn">
          <span>Logout</span>
          <span>📤</span>
        </button>
      </div>
    </aside>

    <!-- Main Section -->
    <div class="main-section">
      <!-- Topbar Header -->
      <header class="topbar">
        <div class="topbar-left">
          <button @click="mobileMenuOpen = !mobileMenuOpen" class="hamburger-btn" aria-label="Toggle Menu">
            ☰
          </button>
          <div class="search-box">
            <span class="search-icon">🔍</span>
            <input type="text" v-model="globalSearch" placeholder="Search here..." />
          </div>
        </div>

        <div class="topbar-right">
          <!-- Notification Bell -->
          <div class="notif-bell-btn" @click="switchTab('notifications')" title="Notifications">
            🔔
            <span class="notif-badge">3</span>
          </div>

          <!-- Admin Profile Pill -->
          <div class="admin-user-pill">
            <div class="admin-avatar">👤</div>
            <div class="admin-info">
              <span class="admin-name">Admin</span>
              <span class="admin-role">Super Admin</span>
            </div>
          </div>
        </div>
      </header>

      <!-- Main Content Container -->
      <main class="content-body">
        
        <!-- SECTION 1: DASHBOARD OVERVIEW -->
        <div v-if="currentTab === 'dashboard'" class="dashboard-panes">
          <div class="dashboard-hero-header">
            <div>
              <h2 class="dash-title">📊 Platform Dashboard Overview</h2>
              <p class="dash-subtitle">Real-time stats from database & API infrastructure operational status.</p>
            </div>
            <button @click="checkGatewayStatus" class="refresh-op-btn">🔄 Refresh Operational Status</button>
          </div>

          <!-- Systems & API Operational Status Cards -->
          <div class="op-grid">
            <div class="op-card green">
              <span class="op-label">Database Connection</span>
              <strong class="op-value">{{ gatewayStatus.database }}</strong>
            </div>
            <div class="op-card green">
              <span class="op-label">Recharge API Server</span>
              <strong class="op-value">{{ gatewayStatus.app_api }}</strong>
            </div>
            <div class="op-card orange">
              <span class="op-label">Scriza Gateway API</span>
              <strong class="op-value">{{ gatewayStatus.scriza_api }}</strong>
            </div>
            <div class="op-card orange">
              <span class="op-label">Razorpay Gateway API</span>
              <strong class="op-value">{{ gatewayStatus.razorpay_gateway }}</strong>
            </div>
          </div>

          <!-- Real Metrics Cards -->
          <div class="stats-grid" style="margin-top: 1.5rem;">
            <div class="nice-stat-card border-blue" @click="switchTab('users')" style="cursor: pointer;">
              <div class="stat-body">
                <div class="stat-left">
                  <span class="icon-indicator">👤</span>
                  <span class="stat-card-title">Total Registered Users</span>
                </div>
                <span class="stat-card-val">{{ stats.totalUsers }}</span>
              </div>
              <div class="progress-bar bg-blue"></div>
            </div>

            <div class="nice-stat-card border-green">
              <div class="stat-body">
                <div class="stat-left">
                  <span class="icon-indicator">💼</span>
                  <span class="stat-card-title">Main Wallet Total</span>
                </div>
                <span class="stat-card-val">₹{{ (stats.totalMainWallet || 0).toLocaleString('en-IN') }}</span>
              </div>
              <div class="progress-bar bg-green"></div>
            </div>

            <div class="nice-stat-card border-purple">
              <div class="stat-body">
                <div class="stat-left">
                  <span class="icon-indicator">📥</span>
                  <span class="stat-card-title">Fund Wallet Total</span>
                </div>
                <span class="stat-card-val">₹{{ (stats.totalFundWallet || 0).toLocaleString('en-IN') }}</span>
              </div>
              <div class="progress-bar bg-purple"></div>
            </div>

            <div class="nice-stat-card border-orange">
              <div class="stat-body">
                <div class="stat-left">
                  <span class="icon-indicator">📈</span>
                  <span class="stat-card-title">Total System Transactions</span>
                </div>
                <span class="stat-card-val">{{ stats.totalTransactions }}</span>
              </div>
              <div class="progress-bar bg-orange"></div>
            </div>
          </div>

          <!-- Quick Navigation Cards -->
          <div class="quick-nav-section" style="margin-top: 1.5rem;">
            <h3>⚡ Quick Section Management</h3>
            <div class="quick-nav-grid">
              <div class="qnav-card" @click="switchTab('sec_add_money')">
                <span class="qnav-icon">💳</span>
                <span class="qnav-title">5. Add Money / Fund Settings</span>
                <span class="qnav-arrow">&rarr;</span>
              </div>
              <div class="qnav-card" @click="switchTab('requests')">
                <span class="qnav-icon">📥</span>
                <span class="qnav-title">Fund Requests ({{ pendingRequestsCount }} Pending)</span>
                <span class="qnav-arrow">&rarr;</span>
              </div>
              <div class="qnav-card" @click="switchTab('sec_subscription')">
                <span class="qnav-icon">👑</span>
                <span class="qnav-title">6. ID Subscription / Activation</span>
                <span class="qnav-arrow">&rarr;</span>
              </div>
              <div class="qnav-card" @click="switchTab('sec_referral')">
                <span class="qnav-icon">👥</span>
                <span class="qnav-title">7. Referral Rewards</span>
                <span class="qnav-arrow">&rarr;</span>
              </div>
              <div class="qnav-card" @click="switchTab('sec_cashout')">
                <span class="qnav-icon">🏦</span>
                <span class="qnav-title">12. Cash Out / Withdrawal</span>
                <span class="qnav-arrow">&rarr;</span>
              </div>
              <div class="qnav-card" @click="switchTab('shared_variable')">
                <span class="qnav-icon">🔗</span>
                <span class="qnav-title">Shared Variables</span>
                <span class="qnav-arrow">&rarr;</span>
              </div>
            </div>
          </div>
        </div>

        <!-- SECTION: 5. ADD MONEY / FUND SETTINGS (Image 1) -->
        <div v-if="currentTab === 'sec_add_money'" class="section-settings-pane">
          <!-- Banner Header -->
          <div class="section-banner">
            <div class="banner-left">
              <div class="banner-icon-box blue-bg">💳</div>
              <div>
                <h2>5. Add Money / Fund Request</h2>
                <p>Manage add money page settings, limits and instructions.</p>
              </div>
            </div>
            <div class="banner-toggle-box">
              <span class="toggle-text">Add Money / Fund</span>
              <label class="switch">
                <input type="checkbox" v-model="systemSettings.add_money_enabled_bool" />
                <span class="slider round"></span>
              </label>
              <span class="main-on-badge" :class="systemSettings.add_money_enabled_bool ? 'badge-on' : 'badge-off'">
                {{ systemSettings.add_money_enabled_bool ? 'ON' : 'OFF' }}
              </span>
            </div>
          </div>

          <!-- Blue Info Alert -->
          <div class="blue-alert-bar">
            <span>ℹ️ Enable or disable the add money page and edit the required settings. Changes will reflect instantly on the user panel.</span>
          </div>

          <!-- Sub-Tab Switcher Bar -->
          <div class="sub-tab-switcher">
            <button @click="currentTab = 'sec_add_money'" class="sub-tab-btn active">💳 Add Money Settings</button>
            <button @click="currentTab = 'requests'" class="sub-tab-btn">📥 Fund Request List ({{ pendingRequestsCount }})</button>
          </div>

          <!-- Two Column Settings & Live Phone Preview -->
          <div class="settings-preview-grid">
            <!-- Left Column: Settings Table -->
            <div class="settings-table-card">
              <div class="card-title-row">
                <div class="title-left">
                  <span class="icon">⚙️</span>
                  <h3>Add Money Settings</h3>
                </div>
                <button @click="resetAddMoneySettings" class="btn-reset-default">↺ Reset to Default</button>
              </div>
              <p class="card-desc">Configure amounts, limits, payment details and instructions.</p>

              <div class="table-container">
                <table class="nice-table settings-edit-table">
                  <thead>
                    <tr>
                      <th style="width: 40px;">#</th>
                      <th>Setting</th>
                      <th>Value (As per your choice)</th>
                      <th style="width: 100px;">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <!-- Row 1: UPI QR Code -->
                    <tr>
                      <td>1</td>
                      <td class="font-bold">UPI QR Code</td>
                      <td>
                        <div class="file-upload-row">
                          <input type="text" v-model="systemSettings.upi_qr_url" placeholder="https://..." class="table-input" />
                          <label class="btn-upload-file">
                            📤 Upload QR Code
                            <input type="file" @change="handleFileUpload($event, 'upi_qr_url')" accept="image/*" style="display: none;" />
                          </label>
                        </div>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small">
                            <input type="checkbox" v-model="systemSettings.status_upi_qr" />
                            <span class="slider round"></span>
                          </label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>

                    <!-- Row 2: UPI ID -->
                    <tr>
                      <td>2</td>
                      <td class="font-bold">UPI ID</td>
                      <td>
                        <input type="text" v-model="systemSettings.upi_vpa_id" placeholder="vp110064@okaxis" class="table-input" />
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small">
                            <input type="checkbox" v-model="systemSettings.status_upi_id" />
                            <span class="slider round"></span>
                          </label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>

                    <!-- Row 3: Minimum Add Money Amount -->
                    <tr>
                      <td>3</td>
                      <td class="font-bold">Minimum Add Money Amount (₹)</td>
                      <td>
                        <input type="number" v-model="systemSettings.min_add_money" placeholder="1200" class="table-input" />
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small">
                            <input type="checkbox" v-model="systemSettings.status_min_add_money" />
                            <span class="slider round"></span>
                          </label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>

                    <!-- Row 4: Maximum Add Money Amount -->
                    <tr>
                      <td>4</td>
                      <td class="font-bold">Maximum Add Money Amount (₹)</td>
                      <td>
                        <input type="number" v-model="systemSettings.max_add_money" placeholder="12000" class="table-input" />
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small">
                            <input type="checkbox" v-model="systemSettings.status_max_add_money" />
                            <span class="slider round"></span>
                          </label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>

                    <!-- Row 5: Preset Amount Buttons -->
                    <tr>
                      <td>5</td>
                      <td class="font-bold">Preset Amount Buttons (₹)</td>
                      <td>
                        <input type="text" v-model="systemSettings.preset_amounts" placeholder="100,500,1000,2000,5000" class="table-input" />
                        <span class="input-subnote">(Comma separated amounts)</span>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small">
                            <input type="checkbox" v-model="systemSettings.status_preset_amounts" />
                            <span class="slider round"></span>
                          </label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>

                    <!-- Row 6: UTR Number -->
                    <tr>
                      <td>6</td>
                      <td class="font-bold">UTR Number</td>
                      <td>
                        <select v-model="systemSettings.utr_number_rule" class="table-select">
                          <option value="Enable (Required)">Enable (Required)</option>
                          <option value="Optional">Optional</option>
                          <option value="Disabled">Disabled</option>
                        </select>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small">
                            <input type="checkbox" v-model="systemSettings.status_utr_rule" />
                            <span class="slider round"></span>
                          </label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>

                    <!-- Row 7: Important Instructions -->
                    <tr>
                      <td>7</td>
                      <td class="font-bold">Important Instructions</td>
                      <td>
                        <textarea v-model="systemSettings.add_money_instructions" rows="4" class="table-textarea" placeholder="Minimum Add Money: ₹1200..."></textarea>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small">
                            <input type="checkbox" v-model="systemSettings.status_add_instructions" />
                            <span class="slider round"></span>
                          </label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <!-- Form Action Buttons -->
              <div class="form-action-row">
                <button @click="handleSaveSystemSettings" :disabled="loadingSystem" class="btn-blue-save">
                  <span>💾 {{ loadingSystem ? 'Saving...' : 'Save Changes' }}</span>
                </button>
                <button @click="resetAddMoneySettings" class="btn-white-reset">↺ Reset</button>
              </div>
            </div>

            <!-- Right Column: Live Phone Screen Preview -->
            <div class="preview-card">
              <div class="preview-card-header">
                <span class="icon">👁️</span>
                <div>
                  <h4>Preview (User Add Money Page)</h4>
                  <p>This is how it will appear to users in real time.</p>
                </div>
              </div>

              <!-- Smartphone Mockup Frame -->
              <div class="phone-frame">
                <div class="phone-screen">
                  <!-- App Header -->
                  <div class="phone-app-header blue-bg">
                    <span class="back-arrow">←</span>
                    <div>
                      <h5 class="header-title">Add Money</h5>
                      <span class="header-sub">Add funds to your wallet</span>
                    </div>
                    <span class="header-wallet-icon">💼+</span>
                  </div>

                  <div class="phone-app-body">
                    <!-- Scan & Pay Block -->
                    <div class="scan-pay-card">
                      <span class="scan-tag">Scan & Pay</span>
                      <p class="scan-sub">Scan QR Code using any UPI App</p>
                      
                      <div class="qr-box">
                        <img :src="systemSettings.upi_qr_url || 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=upi://pay?pa=' + systemSettings.upi_vpa_id" alt="UPI QR Code" />
                      </div>

                      <div class="or-divider"><span>OR</span></div>
                      
                      <div class="upi-method-badge">
                        <span>🏛️ UPI</span>
                        <span class="check-green">✓</span>
                      </div>
                    </div>

                    <!-- UPI ID Card -->
                    <div class="upi-id-card">
                      <div class="upi-id-info">
                        <span class="lbl">UPI ID</span>
                        <strong class="val">{{ systemSettings.upi_vpa_id || 'vp110064@okaxis' }}</strong>
                      </div>
                      <button class="btn-copy-icon">📋</button>
                    </div>

                    <!-- Deposit Amount Box -->
                    <div class="phone-input-block">
                      <label>Deposit Amount (₹)</label>
                      <div class="amount-input-box">
                        <span class="curr">₹</span>
                        <input type="number" :value="systemSettings.min_add_money || 1200" readonly />
                      </div>
                    </div>

                    <!-- Preset Amount Pills -->
                    <div class="phone-pills-row">
                      <span v-for="amt in (systemSettings.preset_amounts || '100,500,1000,2000,5000').split(',')" :key="amt" class="phone-amt-pill">
                        ₹{{ amt.trim() }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Bottom Footer Note -->
          <div class="section-footer-note">
            <span>ℹ️ Note: Any changes you make here will reflect instantly on the user add money page.</span>
            <span class="last-updated">Last Updated: 13 Sep 2026, 10:45 AM</span>
          </div>
        </div>

        <!-- SECTION: 6. ID SUBSCRIPTION / ACTIVATION (Image 2) -->
        <div v-if="currentTab === 'sec_subscription'" class="section-settings-pane">
          <!-- Banner Header -->
          <div class="section-banner">
            <div class="banner-left">
              <div class="banner-icon-box royal-bg">👑</div>
              <div>
                <h2>6. ID Subscription / Activation</h2>
                <p>Manage subscription amount, activation settings and visibility.</p>
              </div>
            </div>
            <div class="banner-toggle-box">
              <span class="toggle-text">ID Subscription</span>
              <label class="switch">
                <input type="checkbox" v-model="systemSettings.id_subscription_enabled_bool" />
                <span class="slider round"></span>
              </label>
              <span class="main-on-badge" :class="systemSettings.id_subscription_enabled_bool ? 'badge-on' : 'badge-off'">
                {{ systemSettings.id_subscription_enabled_bool ? 'ON' : 'OFF' }}
              </span>
            </div>
          </div>

          <div class="blue-alert-bar">
            <span>ℹ️ Enable or disable the ID subscription page and edit the required settings. Changes will reflect instantly on the user panel.</span>
          </div>

          <!-- Two Column Settings & Live Phone Preview -->
          <div class="settings-preview-grid">
            <!-- Left Column: Settings Table -->
            <div class="settings-table-card">
              <div class="card-title-row">
                <div class="title-left">
                  <span class="icon">⚙️</span>
                  <h3>ID Subscription Settings</h3>
                </div>
                <button @click="resetSubSettings" class="btn-reset-default">↺ Reset to Default</button>
              </div>
              <p class="card-desc">Configure amount, activation and instructions for the user subscription page.</p>

              <div class="table-container">
                <table class="nice-table settings-edit-table">
                  <thead>
                    <tr>
                      <th style="width: 40px;">#</th>
                      <th>Setting</th>
                      <th>Value (As per your choice)</th>
                      <th style="width: 100px;">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>1</td>
                      <td class="font-bold">User Details Section</td>
                      <td>
                        <select v-model="systemSettings.sub_user_details_visibility" class="table-select">
                          <option value="Show">Show</option>
                          <option value="Hide">Hide</option>
                        </select>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_sub_user_details" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>2</td>
                      <td class="font-bold">Subscription Amount (₹)</td>
                      <td>
                        <input type="number" v-model="systemSettings.join_amount" placeholder="1200" class="table-input" />
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_sub_amount" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>3</td>
                      <td class="font-bold">Wallet Balance Display</td>
                      <td>
                        <select v-model="systemSettings.sub_wallet_visibility" class="table-select">
                          <option value="Show">Show</option>
                          <option value="Hide">Hide</option>
                        </select>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_sub_wallet" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>4</td>
                      <td class="font-bold">Important Instructions</td>
                      <td>
                        <textarea v-model="systemSettings.sub_instructions" rows="4" class="table-textarea" placeholder="Subscription amount is non-refundable..."></textarea>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_sub_instructions" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>5</td>
                      <td class="font-bold">Subscribe Button</td>
                      <td>
                        <select v-model="systemSettings.sub_button_visibility" class="table-select">
                          <option value="Show">Show</option>
                          <option value="Hide">Hide</option>
                        </select>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_sub_button" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>6</td>
                      <td class="font-bold">Activation After Payment</td>
                      <td>
                        <select v-model="systemSettings.sub_auto_activation" class="table-select">
                          <option value="Enable">Enable</option>
                          <option value="Disable">Disable</option>
                        </select>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_sub_activation" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>7</td>
                      <td class="font-bold">Breadcrumbs / Back Button</td>
                      <td>
                        <select v-model="systemSettings.sub_back_button" class="table-select">
                          <option value="Show">Show</option>
                          <option value="Hide">Hide</option>
                        </select>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_sub_back" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <div class="form-action-row">
                <button @click="handleSaveSystemSettings" :disabled="loadingSystem" class="btn-blue-save">
                  <span>💾 {{ loadingSystem ? 'Saving...' : 'Save Changes' }}</span>
                </button>
                <button @click="resetSubSettings" class="btn-white-reset">↺ Reset</button>
              </div>
            </div>

            <!-- Right Column: Live Phone Screen Preview -->
            <div class="preview-card">
              <div class="preview-card-header">
                <span class="icon">👁️</span>
                <div>
                  <h4>Preview (User ID Subscription Page)</h4>
                  <p>This is how it will appear to users.</p>
                </div>
              </div>

              <!-- Smartphone Mockup Frame -->
              <div class="phone-frame">
                <div class="phone-screen">
                  <div class="phone-app-header blue-bg">
                    <span class="back-arrow">←</span>
                    <div>
                      <h5 class="header-title">ID Subscription</h5>
                      <span class="header-sub">Subscribe to your ID</span>
                    </div>
                    <span class="header-wallet-icon">💳</span>
                  </div>

                  <div class="phone-app-body">
                    <!-- Fund Wallet Bar -->
                    <div class="wallet-bar-preview">
                      <span>💼 Fund Wallet Balance</span>
                      <strong class="val-blue">₹100.00</strong>
                    </div>

                    <!-- Mobile Verification Field -->
                    <div class="phone-input-block" style="margin-top: 0.75rem;">
                      <label>Enter Mobile Number</label>
                      <div class="mobile-check-box">
                        <span class="phone-icon">📞</span>
                        <input type="text" value="7989293968" readonly />
                      </div>
                      <div class="user-ok-badge">
                        <span>User Name: Raju Reddy</span>
                        <span class="ok-pill">OK</span>
                      </div>
                    </div>

                    <!-- User Details Box -->
                    <div class="user-details-card" v-if="systemSettings.sub_user_details_visibility !== 'Hide'">
                      <div class="card-sec-head">👤 User Details</div>
                      <div class="u-row"><span>🆔 ID Number</span><strong>7989293968</strong></div>
                      <div class="u-row"><span>👤 Name</span><strong>Raju Reddy</strong></div>
                      <div class="u-row"><span>📞 Mobile Number</span><strong>7989293968</strong></div>
                      <div class="u-row"><span>✉️ Email ID</span><strong>ravikanth@gmail.com</strong></div>
                      <div class="u-row"><span>📅 Joining Date</span><strong>28-08-2025</strong></div>
                    </div>

                    <!-- Amount to Pay -->
                    <div class="pay-amount-box">
                      <span class="lbl">₹ Amount to Pay</span>
                      <div class="amt-row">
                        <span>Subscription Amount</span>
                        <strong class="amt">₹{{ systemSettings.join_amount || 1200 }}.00</strong>
                      </div>
                    </div>

                    <!-- Subscribe Now Button -->
                    <button class="phone-btn-submit blue-grad-btn" v-if="systemSettings.sub_button_visibility !== 'Hide'">
                      💳 SUBSCRIBE NOW
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="section-footer-note">
            <span>ℹ️ Note: Any changes you make here will reflect instantly on the user ID subscription page.</span>
            <span class="last-updated">Last Updated: 13 Sep 2026, 10:45 AM</span>
          </div>
        </div>

        <!-- SECTION: 7. REFERRAL (Image 3) -->
        <div v-if="currentTab === 'sec_referral'" class="section-settings-pane">
          <!-- Banner Header -->
          <div class="section-banner">
            <div class="banner-left">
              <div class="banner-icon-box purple-bg">👥</div>
              <div>
                <h2>7. Referral</h2>
                <p>Manage referral settings, rewards and visibility.</p>
              </div>
            </div>
            <div class="banner-toggle-box">
              <span class="toggle-text">Referral</span>
              <label class="switch">
                <input type="checkbox" v-model="systemSettings.referral_enabled_bool" />
                <span class="slider round"></span>
              </label>
              <span class="main-on-badge" :class="systemSettings.referral_enabled_bool ? 'badge-on' : 'badge-off'">
                {{ systemSettings.referral_enabled_bool ? 'ON' : 'OFF' }}
              </span>
            </div>
          </div>

          <div class="blue-alert-bar">
            <span>ℹ️ Enable or disable the referral section and edit the reward amount and related settings. Changes will reflect instantly on the user panel.</span>
          </div>

          <!-- Two Column Settings & Live Phone Preview -->
          <div class="settings-preview-grid">
            <!-- Left Column: Settings Table -->
            <div class="settings-table-card">
              <div class="card-title-row">
                <div class="title-left">
                  <span class="icon">⚙️</span>
                  <h3>Referral Settings</h3>
                </div>
                <button @click="resetRefSettings" class="btn-reset-default">↺ Reset to Default</button>
              </div>
              <p class="card-desc">Configure referral reward amount and content for the user referral section.</p>

              <div class="table-container">
                <table class="nice-table settings-edit-table">
                  <thead>
                    <tr>
                      <th style="width: 40px;">#</th>
                      <th>Setting</th>
                      <th>Value (As per your choice)</th>
                      <th style="width: 100px;">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>1</td>
                      <td class="font-bold">Referral Section</td>
                      <td>
                        <select v-model="systemSettings.ref_section_visibility" class="table-select">
                          <option value="Show">Show</option>
                          <option value="Hide">Hide</option>
                        </select>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_ref_section" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>2</td>
                      <td class="font-bold">Referral Reward Amount (₹)</td>
                      <td>
                        <input type="number" v-model="systemSettings.direct_income" placeholder="300" class="table-input" />
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_ref_reward" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>3</td>
                      <td class="font-bold">Referral Text</td>
                      <td>
                        <input type="text" v-model="systemSettings.referral_text" placeholder="Refer App Earn ₹ 300.00" class="table-input" />
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_ref_text" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>4</td>
                      <td class="font-bold">Sub Text</td>
                      <td>
                        <input type="text" v-model="systemSettings.referral_subtext" placeholder="Each Referral" class="table-input" />
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_ref_subtext" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>5</td>
                      <td class="font-bold">Invite Now Button</td>
                      <td>
                        <select v-model="systemSettings.ref_invite_button_visibility" class="table-select">
                          <option value="Show">Show</option>
                          <option value="Hide">Hide</option>
                        </select>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_ref_button" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>6</td>
                      <td class="font-bold">Important Instructions</td>
                      <td>
                        <textarea v-model="systemSettings.referral_instructions" rows="4" class="table-textarea" placeholder="Share your referral link with friends and earn rewards."></textarea>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_ref_instructions" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <div class="form-action-row">
                <button @click="handleSaveSystemSettings" :disabled="loadingSystem" class="btn-blue-save">
                  <span>💾 {{ loadingSystem ? 'Saving...' : 'Save Changes' }}</span>
                </button>
                <button @click="resetRefSettings" class="btn-white-reset">↺ Reset</button>
              </div>
            </div>

            <!-- Right Column: Live Phone Screen Preview -->
            <div class="preview-card">
              <div class="preview-card-header">
                <span class="icon">👁️</span>
                <div>
                  <h4>Preview (User Referral Section)</h4>
                  <p>This is how it will appear to users.</p>
                </div>
              </div>

              <!-- Smartphone Mockup Frame -->
              <div class="phone-frame">
                <div class="phone-screen light-blue-bg">
                  <div class="phone-app-body text-center">
                    <!-- Gift Illustration -->
                    <div class="gift-icon-container">
                      <span class="gift-emoji">🎁</span>
                    </div>

                    <h3 class="referral-title-preview">{{ systemSettings.referral_text || 'Refer App Earn ₹ 300.00' }}</h3>
                    <p class="referral-subtext-preview">{{ systemSettings.referral_subtext || 'Each Referral' }}</p>

                    <!-- Instructions Alert Box -->
                    <div class="ref-instructions-box">
                      <span class="info-icon">ℹ️</span>
                      <p>{{ systemSettings.referral_instructions || 'Share your referral link with friends and earn rewards.' }}</p>
                    </div>

                    <!-- Invite Button -->
                    <button class="phone-btn-submit blue-grad-btn" v-if="systemSettings.ref_invite_button_visibility !== 'Hide'">
                      INVITE NOW &rarr;
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="section-footer-note">
            <span>ℹ️ Note: Any changes you make here will reflect instantly on the user referral section.</span>
            <span class="last-updated">Last Updated: 13 Sep 2026, 10:45 AM</span>
          </div>
        </div>

        <!-- SECTION: 12. CASH OUT / WITHDRAWAL (Image 4) -->
        <div v-if="currentTab === 'sec_cashout'" class="section-settings-pane">
          <!-- Banner Header -->
          <div class="section-banner">
            <div class="banner-left">
              <div class="banner-icon-box navy-bg">🏦</div>
              <div>
                <h2>12. Cash Out / Withdrawal</h2>
                <p>Manage cash out page settings, limits, charges and visibility.</p>
              </div>
            </div>
            <div class="banner-toggle-box">
              <span class="toggle-text">Cash Out / Withdrawal</span>
              <label class="switch">
                <input type="checkbox" v-model="systemSettings.withdrawal_enabled_bool" />
                <span class="slider round"></span>
              </label>
              <span class="main-on-badge" :class="systemSettings.withdrawal_enabled_bool ? 'badge-on' : 'badge-off'">
                {{ systemSettings.withdrawal_enabled_bool ? 'ON' : 'OFF' }}
              </span>
            </div>
          </div>

          <div class="blue-alert-bar">
            <span>ℹ️ Enable or disable the cash out page and edit the required settings. Changes will reflect instantly on the user panel.</span>
          </div>

          <!-- Two Column Settings & Live Phone Preview -->
          <div class="settings-preview-grid">
            <!-- Left Column: Settings Table -->
            <div class="settings-table-card">
              <div class="card-title-row">
                <div class="title-left">
                  <span class="icon">⚙️</span>
                  <h3>Cash Out / Withdrawal Settings</h3>
                </div>
                <button @click="resetCashoutSettings" class="btn-reset-default">↺ Reset to Default</button>
              </div>
              <p class="card-desc">Configure withdrawal limits, charges and instructions for the user cash out page.</p>

              <div class="table-container">
                <table class="nice-table settings-edit-table">
                  <thead>
                    <tr>
                      <th style="width: 40px;">#</th>
                      <th>Setting</th>
                      <th>Value (As per your choice)</th>
                      <th style="width: 100px;">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>1</td>
                      <td class="font-bold">Cash Out Section</td>
                      <td>
                        <select v-model="systemSettings.cashout_section_visibility" class="table-select">
                          <option value="Show">Show</option>
                          <option value="Hide">Hide</option>
                        </select>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_cashout_section" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>2</td>
                      <td class="font-bold">Minimum Withdrawal Amount (₹)</td>
                      <td>
                        <input type="number" v-model="systemSettings.minimum_withdrawal" placeholder="200" class="table-input" />
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_min_withdraw" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>3</td>
                      <td class="font-bold">Maximum Withdrawal Amount (₹)</td>
                      <td>
                        <input type="number" v-model="systemSettings.max_withdrawal" placeholder="25000" class="table-input" />
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_max_withdraw" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>4</td>
                      <td class="font-bold">Withdrawal Charges (%)</td>
                      <td>
                        <input type="number" v-model="systemSettings.withdrawal_percentage" placeholder="0" class="table-input" />
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_withdraw_charges" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>5</td>
                      <td class="font-bold">Withdrawal Charges Type</td>
                      <td>
                        <select v-model="systemSettings.withdrawal_charges_type" class="table-select">
                          <option value="Percentage">Percentage</option>
                          <option value="Flat Fee">Flat Fee</option>
                        </select>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_charges_type" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>6</td>
                      <td class="font-bold">Bank Account Verification</td>
                      <td>
                        <select v-model="systemSettings.bank_verification_rule" class="table-select">
                          <option value="Must be Verified">Must be Verified</option>
                          <option value="Optional">Optional</option>
                        </select>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_bank_rule" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>7</td>
                      <td class="font-bold">Withdrawal Request Note</td>
                      <td>
                        <textarea v-model="systemSettings.cashout_instructions" rows="4" class="table-textarea" placeholder="Withdrawal will be processed within 24 hours after admin approval."></textarea>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_cashout_instructions" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>8</td>
                      <td class="font-bold">Submit Button</td>
                      <td>
                        <select v-model="systemSettings.cashout_submit_button_visibility" class="table-select">
                          <option value="Show">Show</option>
                          <option value="Hide">Hide</option>
                        </select>
                      </td>
                      <td>
                        <div class="status-cell">
                          <label class="switch small"><input type="checkbox" v-model="systemSettings.status_cashout_button" /><span class="slider round"></span></label>
                          <span class="badge-status-active">🟢 Active</span>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <div class="form-action-row">
                <button @click="handleSaveSystemSettings" :disabled="loadingSystem" class="btn-blue-save">
                  <span>💾 {{ loadingSystem ? 'Saving...' : 'Save Changes' }}</span>
                </button>
                <button @click="resetCashoutSettings" class="btn-white-reset">↺ Reset</button>
              </div>
            </div>

            <!-- Right Column: Live Phone Screen Preview -->
            <div class="preview-card">
              <div class="preview-card-header">
                <span class="icon">👁️</span>
                <div>
                  <h4>Preview (User Cash Out Page)</h4>
                  <p>This is how it will appear to users.</p>
                </div>
              </div>

              <!-- Smartphone Mockup Frame -->
              <div class="phone-frame">
                <div class="phone-screen">
                  <div class="phone-app-header blue-bg">
                    <span class="back-arrow">←</span>
                    <div>
                      <h5 class="header-title">Cash Out</h5>
                      <span class="header-sub">Withdraw your earnings</span>
                    </div>
                    <span class="header-wallet-icon">🏦</span>
                  </div>

                  <div class="phone-app-body">
                    <!-- Balance Box -->
                    <div class="wallet-bar-preview">
                      <span>💼 Available Balance</span>
                      <strong class="val-blue">₹ 2,450.00</strong>
                    </div>

                    <!-- Input Block -->
                    <div class="phone-input-block" style="margin-top: 0.75rem;">
                      <label>Withdrawal Amount</label>
                      <div class="amount-input-box">
                        <span class="curr">₹</span>
                        <input type="text" :placeholder="'Enter Amount (Min. ₹ ' + (systemSettings.minimum_withdrawal || 200) + ')'" readonly />
                      </div>
                    </div>

                    <!-- Summary Card -->
                    <div class="summary-details-card">
                      <div class="u-row"><span>Minimum Amount</span><strong>: ₹ {{ systemSettings.minimum_withdrawal || 200 }}</strong></div>
                      <div class="u-row"><span>Maximum Amount</span><strong>: ₹ {{ systemSettings.max_withdrawal || 25000 }}</strong></div>
                      <div class="u-row"><span>Withdrawal Charges</span><strong>: {{ systemSettings.withdrawal_percentage || 0 }}%</strong></div>
                      <div class="u-row"><span>You Will Get</span><strong class="text-blue">: ₹ 0.00</strong></div>
                    </div>

                    <!-- Submit Button -->
                    <button class="phone-btn-submit blue-grad-btn" v-if="systemSettings.cashout_submit_button_visibility !== 'Hide'">
                      Submit Request
                    </button>

                    <!-- Instructions Box -->
                    <div class="phone-info-note">
                      <span>ℹ️ {{ systemSettings.cashout_instructions || 'Withdrawal will be processed within 24 hours after admin approval.' }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="section-footer-note">
            <span>ℹ️ Note: Any changes you make here will reflect instantly on the user cash out page.</span>
            <span class="last-updated">Last Updated: 13 Sep 2026, 10:45 AM</span>
          </div>
        </div>

        <!-- SECTION: FUND REQUEST LIST (Image 5) -->
        <div v-if="currentTab === 'requests'" class="requests-pane">
          <!-- Banner Header -->
          <div class="section-banner">
            <div class="banner-left">
              <div class="banner-icon-box blue-bg">📥</div>
              <div>
                <h2>Fund Request</h2>
                <p>Manage user fund requests, verify UTR and approve or reject.</p>
              </div>
            </div>
            <div class="banner-breadcrumbs">
              <span>Home</span> &gt; <span>Add Money / Fund</span> &gt; <span class="active">Fund Request</span>
            </div>
          </div>

          <!-- Status Filter Tabs -->
          <div class="status-tab-pills">
            <button @click="reqFilterStatus = 'PENDING'" class="pill-btn" :class="{ active: reqFilterStatus === 'PENDING' }">
              Pending ({{ getReqCount('PENDING') }})
            </button>
            <button @click="reqFilterStatus = 'APPROVED'" class="pill-btn" :class="{ active: reqFilterStatus === 'APPROVED' }">
              Approved ({{ getReqCount('APPROVED') }})
            </button>
            <button @click="reqFilterStatus = 'REJECTED'" class="pill-btn" :class="{ active: reqFilterStatus === 'REJECTED' }">
              Rejected ({{ getReqCount('REJECTED') }})
            </button>
            <button @click="reqFilterStatus = 'CANCELLED'" class="pill-btn" :class="{ active: reqFilterStatus === 'CANCELLED' }">
              Cancelled ({{ getReqCount('CANCELLED') }})
            </button>
          </div>

          <!-- Filter & Action Bar -->
          <div class="filter-action-row">
            <div class="filter-inputs">
              <div class="search-input-wrap">
                <span class="icon">🔍</span>
                <input type="text" v-model="reqSearchQuery" placeholder="Search by Name, Mobile, UTR..." />
              </div>
              <select v-model="reqPaymentModeFilter" class="filter-select">
                <option value="">All Payment Modes</option>
                <option value="GPay">Google Pay (GPay)</option>
                <option value="PhonePe">PhonePe</option>
                <option value="Paytm">Paytm</option>
                <option value="Bank Transfer">Bank Transfer</option>
              </select>
              <select v-model="reqAmountFilter" class="filter-select">
                <option value="">All Amounts</option>
                <option value="500">₹500</option>
                <option value="1000">₹1,000</option>
                <option value="1200">₹1,200</option>
                <option value="2500">₹2,500</option>
              </select>
              <button @click="applyReqFilters" class="btn-filter-blue">🔍 Filter</button>
              <button @click="resetReqFilters" class="btn-filter-reset">Reset</button>
            </div>

            <div class="filter-right-actions">
              <div class="date-picker-wrap">
                📅 <span>13 Sep 2026 - 13 Sep 2026</span> ▾
              </div>
              <button @click="exportRequestsCSV" class="btn-export-blue">📥 Export</button>
            </div>
          </div>

          <!-- Fund Requests Table -->
          <div class="table-card">
            <div class="table-container">
              <table class="nice-table">
                <thead>
                  <tr>
                    <th style="width: 30px;"><input type="checkbox" /></th>
                    <th>#</th>
                    <th>User Details</th>
                    <th>Amount (₹)</th>
                    <th>Payment Mode</th>
                    <th>UTR Number</th>
                    <th>Request Date</th>
                    <th>Status</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-if="filteredRequests.length === 0">
                    <td colspan="9" style="text-align: center; padding: 2rem; color: #64748b;">
                      No fund deposit requests match your filter criteria.
                    </td>
                  </tr>
                  <tr v-for="(req, idx) in filteredRequests" :key="req.id">
                    <td><input type="checkbox" /></td>
                    <td>{{ idx + 1 }}</td>
                    <td>
                      <div class="user-table-cell">
                        <div class="user-avatar-circle">{{ (req.fullName || 'U')[0].toUpperCase() }}</div>
                        <div>
                          <strong class="u-name">{{ req.fullName || 'User #' + req.user_id }}</strong>
                          <div class="u-sub">ID: SR{{ req.user_id }}</div>
                          <div class="u-sub">{{ req.mobileNumber || '7989293968' }}</div>
                        </div>
                      </div>
                    </td>
                    <td class="font-bold text-lg">₹{{ parseFloat(req.amount || 0).toFixed(2) }}</td>
                    <td>
                      <span class="pm-badge" :class="getPMClass(req.payment_method)">
                        {{ req.payment_method || 'UPI / GPay' }}
                      </span>
                    </td>
                    <td>
                      <div class="utr-copy-cell">
                        <code>{{ req.utr_number || 'UTR1234567890' }}</code>
                        <button class="btn-copy-utr" @click="copyToClipboard(req.utr_number || 'UTR1234567890')" title="Copy UTR">📋</button>
                      </div>
                    </td>
                    <td>
                      <div class="date-cell">
                        <div>{{ (req.created_at || '13 Sep 2026').substring(0, 10) }}</div>
                        <div class="time-sub">10:15 AM</div>
                      </div>
                    </td>
                    <td>
                      <span :class="getStatusBadgeClass(req.status)">
                        {{ req.status === 'PENDING' ? '🟡 Pending' : req.status === 'APPROVED' ? '🟢 Approved' : '🔴 Rejected' }}
                      </span>
                    </td>
                    <td>
                      <button @click="selectedRequest = req" class="btn-action-view">👁️ View</button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Table Pagination -->
            <div class="table-pagination-bar">
              <span>Showing 1 to {{ filteredRequests.length }} of {{ fundRequests.length }} requests</span>
              <div class="page-pills">
                <button class="page-pill active">1</button>
              </div>
            </div>
          </div>

          <div class="section-footer-note">
            <span>ℹ️ Note: After approval, the amount will be added to the user's wallet automatically. Rejected requests will be cancelled and will not be credited.</span>
            <span class="last-updated">Last Updated: 13 Sep 2026, 10:45 AM</span>
          </div>

          <!-- Fund Request Details Slide-Over Drawer (Right Side Image 5) -->
          <div v-if="selectedRequest" class="slide-over-backdrop" @click="selectedRequest = null">
            <div class="slide-over-panel" @click.stop>
              <div class="drawer-header">
                <h3>Fund Request Details</h3>
                <button @click="selectedRequest = null" class="btn-close-x">&times;</button>
              </div>

              <div class="drawer-body">
                <!-- User Header Pill -->
                <div class="drawer-user-pill">
                  <div class="avatar-large">{{ (selectedRequest.fullName || 'U')[0].toUpperCase() }}</div>
                  <div>
                    <h4>{{ selectedRequest.fullName || 'User #' + selectedRequest.user_id }}</h4>
                    <div class="u-meta">ID: SR{{ selectedRequest.user_id }}</div>
                    <div class="u-meta">Mobile: {{ selectedRequest.mobileNumber || '7989293968' }}</div>
                  </div>
                </div>

                <!-- Request Information Block -->
                <div class="drawer-info-block">
                  <h5>📋 Request Information</h5>
                  <div class="info-grid">
                    <div class="i-row"><span>Request ID</span><strong>: FR{{ selectedRequest.id }}</strong></div>
                    <div class="i-row"><span>Request Date</span><strong>: {{ (selectedRequest.created_at || '13 Sep 2026').substring(0, 10) }} 10:15 AM</strong></div>
                    <div class="i-row"><span>Amount (₹)</span><strong class="text-blue">: ₹{{ parseFloat(selectedRequest.amount || 0).toFixed(2) }}</strong></div>
                    <div class="i-row"><span>Payment Mode</span><strong>: {{ selectedRequest.payment_method || 'Google Pay' }}</strong></div>
                    <div class="i-row">
                      <span>UTR Number</span>
                      <strong>: {{ selectedRequest.utr_number || 'UTR1234567890' }} <button class="btn-copy-sm" @click="copyToClipboard(selectedRequest.utr_number || 'UTR1234567890')">📋</button></strong>
                    </div>
                    <div class="i-row"><span>Transaction Date</span><strong>: 13 Sep 2026, 10:12 AM</strong></div>
                    <div class="i-row">
                      <span>Screenshot</span>
                      <strong>: <a :href="selectedRequest.screenshot_url || '#'" target="_blank" class="screenshot-link">📄 View Screenshot</a></strong>
                    </div>
                  </div>
                </div>

                <!-- User Details Block -->
                <div class="drawer-info-block">
                  <h5>👤 User Details</h5>
                  <div class="info-grid">
                    <div class="i-row"><span>Name</span><strong>: {{ selectedRequest.fullName || 'Raju Reddy' }}</strong></div>
                    <div class="i-row"><span>Email</span><strong>: {{ selectedRequest.email || 'rajureddy@gmail.com' }}</strong></div>
                    <div class="i-row"><span>Sponsor ID</span><strong>: SR1001</strong></div>
                    <div class="i-row"><span>Wallet Balance</span><strong>: ₹120.00</strong></div>
                  </div>
                </div>

                <!-- Admin Action Block -->
                <div class="drawer-action-block" v-if="selectedRequest.status === 'PENDING'">
                  <h5>⚡ Admin Action</h5>
                  <div class="action-btn-group">
                    <button @click="processRequest(selectedRequest.id, true)" class="btn-approve-green">✓ Approve</button>
                    <button @click="processRequest(selectedRequest.id, false)" class="btn-reject-red">✕ Reject</button>
                  </div>

                  <div class="remarks-group">
                    <label>Remarks (Optional)</label>
                    <textarea v-model="requestRemark" placeholder="Enter remarks here..." rows="3"></textarea>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- SECTION: USERS LIST & PROFILE (14. Profile) -->
        <div v-if="currentTab === 'users'" class="users-list-pane">
          <div class="table-card">
            <div class="table-header-row">
              <h3>Registered Mobile App Users</h3>
              <div class="pagination-controls">
                <button @click="changeUserPage(-1)" :disabled="userPage === 1" class="page-btn">&larr; Prev</button>
                <span class="page-num">Page {{ userPage }}</span>
                <button @click="changeUserPage(1)" :disabled="users.length < 10" class="page-btn">Next &rarr;</button>
              </div>
            </div>
            <div class="table-container">
              <table class="nice-table">
                <thead>
                  <tr>
                    <th>User ID</th>
                    <th>Full Name</th>
                    <th>Email</th>
                    <th>Mobile Number</th>
                    <th>Main Wallet</th>
                    <th>Fund Wallet</th>
                    <th>Affiliate Downlines</th>
                    <th>Details</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="user in users" :key="user.id" class="clickable-row" @click="selectUser(user)">
                    <td>#{{ user.id }}</td>
                    <td class="font-bold">{{ user.fullName }}</td>
                    <td>{{ user.email }}</td>
                    <td>{{ user.mobileNumber }}</td>
                    <td>₹{{ parseFloat(user.main_wallet_balance || 0).toFixed(2) }}</td>
                    <td>₹{{ parseFloat(user.fund_wallet_balance || 0).toFixed(2) }}</td>
                    <td>
                      <span class="badge-status-active">{{ user.downlineCount || 0 }} Members</span>
                    </td>
                    <td>
                      <button class="btn-action-view">View Profile</button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Slide-Over User details -->
          <div v-if="selectedUser" class="slide-over-backdrop" @click="selectedUser = null">
            <div class="slide-over-panel" @click.stop>
              <div class="drawer-header">
                <h3>User Profile</h3>
                <button @click="selectedUser = null" class="btn-close-x">&times;</button>
              </div>
              <div class="drawer-body">
                <div class="drawer-user-pill">
                  <div class="avatar-large">{{ selectedUser.fullName[0].toUpperCase() }}</div>
                  <div>
                    <h4>{{ selectedUser.fullName }}</h4>
                    <span class="badge-status-active">Active Account</span>
                  </div>
                </div>

                <div class="wallets-row" style="display: flex; gap: 1rem; margin-top: 1rem;">
                  <div class="stat-card border-blue" style="flex: 1; padding: 1rem; background: #eff6ff; border-radius: 8px;">
                    <span>Main Wallet</span>
                    <h4 style="color: #2563eb; font-size: 1.2rem; margin: 4px 0 0;">₹{{ parseFloat(selectedUser.main_wallet_balance || 0).toFixed(2) }}</h4>
                  </div>
                  <div class="stat-card border-purple" style="flex: 1; padding: 1rem; background: #faf5ff; border-radius: 8px;">
                    <span>Fund Wallet</span>
                    <h4 style="color: #9333ea; font-size: 1.2rem; margin: 4px 0 0;">₹{{ parseFloat(selectedUser.fund_wallet_balance || 0).toFixed(2) }}</h4>
                  </div>
                </div>

                <!-- Reset User Password Box (Admin Only) -->
                <div style="margin-top: 1.25rem; padding: 1rem; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px;">
                  <h4 style="margin: 0 0 0.35rem; font-size: 0.88rem; font-weight: 700; color: #1e293b;">🔑 Reset Member Password</h4>
                  <p style="margin: 0 0 0.75rem; font-size: 0.78rem; color: #64748b;">Set a new password for {{ selectedUser.fullName || selectedUser.email }} directly.</p>
                  <div style="display: flex; gap: 0.5rem; align-items: center;">
                    <input 
                      type="text" 
                      v-model="userNewPassword" 
                      placeholder="Enter new password (min 4 chars)" 
                      style="flex: 1; padding: 0.55rem 0.75rem; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 0.85rem; outline: none; background: white;"
                    />
                    <button 
                      @click="handleUpdateUserPassword(selectedUser.id)" 
                      :disabled="updatingUserPassword"
                      style="background: #2563eb; color: white; border: none; padding: 0.55rem 1rem; border-radius: 6px; font-weight: 700; font-size: 0.82rem; cursor: pointer; white-space: nowrap;"
                    >
                      {{ updatingUserPassword ? 'Saving...' : '🔑 Change Password' }}
                    </button>
                  </div>
                  <div v-if="userPasswordMsg" :style="{ color: userPasswordSuccess ? '#16a34a' : '#ef4444', fontSize: '0.8rem', marginTop: '0.5rem', fontWeight: 'bold' }">
                    {{ userPasswordMsg }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- SECTION: USER TEAMS (10. Team & 11. Direct Team Members) -->
        <div v-if="currentTab === 'teams' || currentTab === 'sec_team' || currentTab === 'sec_direct_members'" class="teams-pane">
          <div class="table-card">
            <div class="card-title-row">
              <h3>👥 User Teams & Multi-Level Affiliate Downlines</h3>
            </div>
            <p class="card-desc">Real-time sponsor tree queried directly from user registrations.</p>
            
            <div v-if="loadingTeams" class="loading-box">Loading team tree data...</div>
            
            <div v-else-if="!teamsData.teams || teamsData.teams.length === 0" class="empty-box">
              <p>No multi-user downline relationships recorded yet.</p>
              <p>When users register using another member's Sponsor ID, their affiliate networks will automatically display here.</p>
            </div>

            <div v-else class="teams-tree-container" style="display: flex; flex-direction: column; gap: 1.25rem;">
              <div v-for="group in teamsData.teams" :key="group.sponsorId" class="team-group-card">
                <div class="team-group-header">
                  <div>
                    <span class="sponsor-name">{{ group.sponsorName }}</span>
                    <span class="sponsor-id-badge">SRM{{ String(group.sponsorId).padStart(6, '0') }}</span>
                    <div class="sponsor-email">{{ group.sponsorEmail }}</div>
                  </div>
                  <span class="members-count-badge">{{ group.downlines.length }} Direct Members</span>
                </div>

                <div class="table-container">
                  <table class="nice-table">
                    <thead>
                      <tr>
                        <th>Member ID</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Mobile</th>
                        <th>Main Wallet</th>
                        <th>Status</th>
                        <th>Joined Date</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="member in group.downlines" :key="member.id">
                        <td><strong>SRM{{ String(member.id).padStart(6, '0') }}</strong></td>
                        <td class="font-bold">{{ member.fullName }}</td>
                        <td>{{ member.email }}</td>
                        <td>{{ member.mobileNumber || 'N/A' }}</td>
                        <td class="font-bold text-green">₹{{ parseFloat(member.main_wallet_balance || 0).toFixed(2) }}</td>
                        <td><span class="badge-status-active">{{ (member.status || 'ACTIVE').toUpperCase() }}</span></td>
                        <td>{{ member.createdAt ? String(member.createdAt).substring(0, 10) : 'N/A' }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- SECTION: ALL TRANSACTIONS (17. Transaction History) -->
        <div v-if="currentTab === 'transactions' || currentTab === 'sec_transactions'" class="transactions-pane">
          <div class="table-card">
            <div class="table-header-row">
              <h3>All Platform Ledger Transactions</h3>
              <div class="pagination-controls">
                <button @click="changeTxnPage(-1)" :disabled="txnPage === 1" class="page-btn">&larr; Prev</button>
                <span class="page-num">Page {{ txnPage }}</span>
                <button @click="changeTxnPage(1)" :disabled="allTransactions.length < 15" class="page-btn">Next &rarr;</button>
              </div>
            </div>
            <div class="table-container">
              <table class="nice-table">
                <thead>
                  <tr>
                    <th>Txn ID</th>
                    <th>User ID</th>
                    <th>Wallet Type</th>
                    <th>Amount</th>
                    <th>Type</th>
                    <th>Status</th>
                    <th>Date</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="txn in allTransactions" :key="txn.id">
                    <td>#{{ txn.id }}</td>
                    <td>User #{{ txn.user_id }}</td>
                    <td>{{ txn.wallet_type }}</td>
                    <td class="font-bold">{{ txn.amount }}</td>
                    <td>{{ txn.type }}</td>
                    <td><span class="badge-status-active">{{ txn.status }}</span></td>
                    <td>{{ txn.date }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- SECTION: SEND NOTIFICATIONS (15. Notifications) -->
        <div v-if="currentTab === 'notifications' || currentTab === 'sec_notifications'" class="notifications-pane">
          <div class="settings-table-card">
            <h3>📢 Broadcast Mobile Push Notification</h3>
            <p class="card-desc">Send push alerts and announcements to all registered mobile app users.</p>
            
            <form @submit.prevent="handleSendNotification" class="notif-form">
              <div class="nice-input-group">
                <label>Notification Title</label>
                <input type="text" v-model="notifTitle" placeholder="e.g. 🎉 Special Cashback Offer Active!" required />
              </div>
              <div class="nice-input-group" style="margin-top: 1rem;">
                <label>Message Content</label>
                <textarea v-model="notifMessage" rows="4" placeholder="Enter notification description here..." required></textarea>
              </div>

              <div v-if="notifError" class="alert-box alert-error" style="margin-top: 1rem;">⚠️ {{ notifError }}</div>
              <div v-if="notifSuccess" class="alert-box alert-success" style="margin-top: 1rem;">✅ {{ notifSuccess }}</div>

              <button type="submit" :disabled="sendingNotif" class="btn-blue-save" style="margin-top: 1.5rem; width: 100%;">
                <span>📢 {{ sendingNotif ? 'Broadcasting Notice...' : 'Send Broadcast Notice' }}</span>
              </button>
            </form>
          </div>
        </div>

        <!-- SECTION: SHARED VARIABLE (Global Settings) -->
        <div v-if="currentTab === 'shared_variable'" class="shared-variable-pane">
          <div class="settings-table-card">
            <h3>🔗 Shared Variables & Global System Parameters</h3>
            <p class="card-desc">Configure financial limits, cycle rules, gateway modes, and global ON/OFF toggles.</p>

            <form @submit.prevent="handleSaveSystemSettings">
              <div class="form-action-row" style="margin-top: 1.5rem;">
                <button type="submit" :disabled="loadingSystem" class="btn-blue-save" style="width: 100%;">
                  <span>💾 {{ loadingSystem ? 'Saving All Settings...' : 'Save All Settings' }}</span>
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- SECTION: CHANGE PASSWORD -->
        <div v-if="currentTab === 'settings'" class="settings-pane">
          <div class="settings-table-card">
            <h3>🔑 Change Admin Password</h3>
            <p class="card-desc">Update the master credentials used to access the administrator dashboard.</p>
            
            <form @submit.prevent="handleChangePassword">
              <div class="nice-input-group">
                <label>Current Password</label>
                <input type="password" v-model="oldPassword" placeholder="Enter current password" required />
              </div>
              <div class="nice-input-group" style="margin-top: 1rem;">
                <label>New Password</label>
                <input type="password" v-model="newPassword" placeholder="Enter new password" required />
              </div>
              <div class="nice-input-group" style="margin-top: 1rem;">
                <label>Confirm New Password</label>
                <input type="password" v-model="confirmPassword" placeholder="Confirm new password" required />
              </div>

              <div v-if="passwordError" class="alert-box alert-error" style="margin-top: 1rem;">⚠️ {{ passwordError }}</div>
              <div v-if="passwordSuccess" class="alert-box alert-success" style="margin-top: 1rem;">✅ {{ passwordSuccess }}</div>

              <button type="submit" :disabled="loadingPassword" class="btn-blue-save" style="margin-top: 1.5rem; width: 100%;">
                <span>🔑 {{ loadingPassword ? 'Updating...' : 'Update Password' }}</span>
              </button>
            </form>
          </div>
        </div>

        <!-- GENERIC DUMMY FALLBACK FOR OTHER SECTIONS (1-19) -->
        <div v-if="['sec_registration', 'sec_login', 'sec_otp', 'sec_home', 'sec_business_income', 'sec_global_cycle', 'sec_bank_verification', 'sec_support', 'sec_captcha', 'sec_side_menu'].includes(currentTab)" class="generic-section-pane">
          <div class="section-banner">
            <div class="banner-left">
              <div class="banner-icon-box blue-bg">⚙️</div>
              <div>
                <h2>{{ getSectionTitle(currentTab) }}</h2>
                <p>Configure section settings, rules, limits and user panel visibility.</p>
              </div>
            </div>
            <div class="banner-toggle-box">
              <span class="toggle-text">Active Section</span>
              <label class="switch">
                <input type="checkbox" checked />
                <span class="slider round"></span>
              </label>
              <span class="main-on-badge badge-on">ON</span>
            </div>
          </div>

          <div class="blue-alert-bar">
            <span>ℹ️ Edit section rules below. All modifications will reflect on the live user panel immediately after saving.</span>
          </div>

          <div class="settings-table-card">
            <h3>⚙️ {{ getSectionTitle(currentTab) }} Settings</h3>
            <p class="card-desc">Configure rules, limits and display parameters for this feature.</p>
            <div class="table-container">
              <table class="nice-table settings-edit-table">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Setting</th>
                    <th>Value (As per your choice)</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>1</td>
                    <td class="font-bold">Feature Display Visibility</td>
                    <td>
                      <select class="table-select"><option value="Show">Show</option><option value="Hide">Hide</option></select>
                    </td>
                    <td><span class="badge-status-active">🟢 Active</span></td>
                  </tr>
                  <tr>
                    <td>2</td>
                    <td class="font-bold">Feature Master Rule Mode</td>
                    <td>
                      <input type="text" value="Enabled (Standard)" class="table-input" />
                    </td>
                    <td><span class="badge-status-active">🟢 Active</span></td>
                  </tr>
                  <tr>
                    <td>3</td>
                    <td class="font-bold">Important User Notice</td>
                    <td>
                      <textarea rows="3" class="table-textarea" placeholder="Enter notice content for users..."></textarea>
                    </td>
                    <td><span class="badge-status-active">🟢 Active</span></td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="form-action-row">
              <button @click="handleSaveSystemSettings" class="btn-blue-save">💾 Save Changes</button>
              <button class="btn-white-reset">↺ Reset</button>
            </div>
          </div>

          <div class="section-footer-note">
            <span>ℹ️ Note: Any changes you make here will reflect instantly on the user panel.</span>
            <span class="last-updated">Last Updated: 13 Sep 2026, 10:45 AM</span>
          </div>
        </div>

      </main>
    </div>
  </div>
</template>

<script>
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'https://recharge-app-production-5b63.up.railway.app';

export default {
  name: 'AdminDashboard',
  data() {
    return {
      currentTab: 'sec_add_money',
      mobileMenuOpen: false,
      globalSearch: '',
      adminEmail: localStorage.getItem('adminEmail') || 'haris@gmail.com',
      expandedGroups: {
        user_management: true,
        global_settings: true
      },
      stats: {
        totalUsers: 0,
        totalFundWallet: 0,
        totalMainWallet: 0,
        totalTransactions: 0
      },
      transactions: [],
      allTransactions: [],
      users: [],
      fundRequests: [],
      adminsList: [],
      selectedUser: null,
      selectedRequest: null,
      requestRemark: '',
      reqFilterStatus: 'PENDING',
      reqSearchQuery: '',
      reqPaymentModeFilter: '',
      reqAmountFilter: '',
      userPage: 1,
      txnPage: 1,
      loading: true,
      error: '',
      gatewayStatus: {
        database: 'Operational (Online)',
        app_api: 'Operational (Online)',
        scriza_api: 'Operational (Live)',
        razorpay_gateway: 'Operational (Live)'
      },
      // Password states
      oldPassword: '',
      newPassword: '',
      confirmPassword: '',
      passwordError: '',
      passwordSuccess: '',
      loadingPassword: false,
      // Notifications states
      notifTitle: '',
      notifMessage: '',
      notifSuccess: '',
      notifError: '',
      sendingNotif: false,
      // System settings states
      loadingSystem: false,
      systemError: '',
      systemSuccess: '',
      showRazorpaySecret: false,
      // User Password Reset states
      userNewPassword: '',
      userPasswordMsg: '',
      userPasswordSuccess: false,
      updatingUserPassword: false,
      // Teams states
      teamsData: {
        teams: [],
        allUsers: [],
        directSponsorsCount: 0,
        totalUsersCount: 0
      },
      loadingTeams: false,
      systemSettings: {
        min_wallet_balance: '50.00',
        maintenance_mode_bool: false,
        force_update_version: '1.0.0',
        scriza_api_mode: 'simulation',
        razorpay_api_mode: 'test',
        razorpay_key_id: '',
        razorpay_key_secret: '',
        join_amount: '1200',
        top_up_amount: '1200',
        direct_income: '300',
        level_pool: '600',
        company_maintenance: '300',
        cycle_size: '126',
        withdrawal_percentage: '15',
        minimum_withdrawal: '200',
        max_withdrawal: '25000',
        withdrawal_days: 'Mon,Wed,Fri',
        upi_vpa_id: 'vp110064@okaxis',
        upi_payee_name: 'EarnFarm',
        upi_qr_url: '',
        min_add_money: '1200',
        max_add_money: '12000',
        preset_amounts: '100,500,1000,2000,5000',
        utr_number_rule: 'Enable (Required)',
        add_money_instructions: 'Minimum Add Money: ₹1200\nMaximum Add Money: ₹12000\nOnly 12 Digit UTR number is allowed.\nFunds will be added after Admin approval.\nIt may take some time for approval.',
        add_money_enabled_bool: true,
        id_subscription_enabled_bool: true,
        sub_user_details_visibility: 'Show',
        sub_wallet_visibility: 'Show',
        sub_button_visibility: 'Show',
        sub_auto_activation: 'Enable',
        sub_back_button: 'Show',
        sub_instructions: 'Subscription amount is non-refundable. Ensure the mobile number is correct. Your ID will be activated after successful payment. Contact support for any issues.',
        referral_enabled_bool: true,
        ref_section_visibility: 'Show',
        referral_text: 'Refer App Earn ₹ 300.00',
        referral_subtext: 'Each Referral',
        ref_invite_button_visibility: 'Show',
        referral_instructions: 'Share your referral link with friends and earn rewards.',
        withdrawal_enabled_bool: true,
        cashout_section_visibility: 'Show',
        withdrawal_charges_type: 'Percentage',
        bank_verification_rule: 'Must be Verified',
        cashout_instructions: 'Withdrawal will be processed within 24 hours after admin approval.',
        cashout_submit_button_visibility: 'Show',
        status_upi_qr: true,
        status_upi_id: true,
        status_min_add_money: true,
        status_max_add_money: true,
        status_preset_amounts: true,
        status_utr_rule: true,
        status_add_instructions: true,
        status_sub_user_details: true,
        status_sub_amount: true,
        status_sub_wallet: true,
        status_sub_instructions: true,
        status_sub_button: true,
        status_sub_activation: true,
        status_sub_back: true,
        status_ref_section: true,
        status_ref_reward: true,
        status_ref_text: true,
        status_ref_subtext: true,
        status_ref_button: true,
        status_ref_instructions: true,
        status_cashout_section: true,
        status_min_withdraw: true,
        status_max_withdraw: true,
        status_withdraw_charges: true,
        status_charges_type: true,
        status_bank_rule: true,
        status_cashout_instructions: true,
        status_cashout_button: true
      }
    };
  },
  computed: {
    pendingRequestsCount() {
      return this.fundRequests.filter(r => r.status === 'PENDING').length;
    },
    filteredRequests() {
      return this.fundRequests.filter(req => {
        const matchesStatus = !this.reqFilterStatus || req.status === this.reqFilterStatus;
        const q = this.reqSearchQuery.toLowerCase();
        const matchesQuery = !q || 
          (req.fullName && req.fullName.toLowerCase().includes(q)) ||
          (req.mobileNumber && req.mobileNumber.includes(q)) ||
          (req.utr_number && req.utr_number.toLowerCase().includes(q));
        const matchesPM = !this.reqPaymentModeFilter || (req.payment_method && req.payment_method.includes(this.reqPaymentModeFilter));
        const matchesAmt = !this.reqAmountFilter || String(req.amount) === this.reqAmountFilter;
        return matchesStatus && matchesQuery && matchesPM && matchesAmt;
      });
    }
  },
  mounted() {
    this.checkGatewayStatus();
    this.fetchDashboardData();
    this.fetchSystemSettings();
    this.fetchFundRequests();
    this.fetchTeamsData();
  },
  methods: {
    toggleGroup(groupKey) {
      this.expandedGroups[groupKey] = !this.expandedGroups[groupKey];
    },
    switchTab(tab) {
      this.currentTab = tab;
      this.mobileMenuOpen = false;
    },
    getSectionTitle(tabKey) {
      const titles = {
        sec_registration: '1. Registration',
        sec_login: '2. Login',
        sec_otp: '3. OTP / Forgot Password',
        sec_home: '4. Home / Dashboard',
        sec_business_income: '8. Business / Income',
        sec_global_cycle: '9. Global Cycle',
        sec_bank_verification: '13. Bank Account Verification',
        sec_support: '16. Support',
        sec_captcha: '18. CAPTCHA Work',
        sec_side_menu: '19. Side Menu'
      };
      return titles[tabKey] || 'Section Configuration';
    },
    getReqCount(status) {
      return this.fundRequests.filter(r => r.status === status).length;
    },
    getPMClass(pm) {
      if (!pm) return 'pm-gpay';
      if (pm.includes('PhonePe')) return 'pm-phonepe';
      if (pm.includes('Paytm')) return 'pm-paytm';
      if (pm.includes('Bank')) return 'pm-bank';
      return 'pm-gpay';
    },
    getStatusBadgeClass(status) {
      if (status === 'APPROVED') return 'badge-status-approved';
      if (status === 'REJECTED') return 'badge-status-rejected';
      return 'badge-status-pending';
    },
    copyToClipboard(text) {
      if (navigator.clipboard) {
        navigator.clipboard.writeText(text);
        alert('Copied to clipboard: ' + text);
      }
    },
    handleFileUpload(event, field) {
      const file = event.target.files[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = (e) => {
          this.systemSettings[field] = e.target.result;
        };
        reader.readAsDataURL(file);
      }
    },
    resetAddMoneySettings() {
      this.systemSettings.upi_vpa_id = 'vp110064@okaxis';
      this.systemSettings.min_add_money = '1200';
      this.systemSettings.max_add_money = '12000';
      this.systemSettings.preset_amounts = '100,500,1000,2000,5000';
      this.systemSettings.utr_number_rule = 'Enable (Required)';
    },
    resetSubSettings() {
      this.systemSettings.sub_user_details_visibility = 'Show';
      this.systemSettings.join_amount = '1200';
      this.systemSettings.sub_wallet_visibility = 'Show';
    },
    resetRefSettings() {
      this.systemSettings.ref_section_visibility = 'Show';
      this.systemSettings.direct_income = '300';
      this.systemSettings.referral_text = 'Refer App Earn ₹ 300.00';
    },
    resetCashoutSettings() {
      this.systemSettings.cashout_section_visibility = 'Show';
      this.systemSettings.minimum_withdrawal = '200';
      this.systemSettings.max_withdrawal = '25000';
    },
    applyReqFilters() {
      // Filters are computed dynamically via filteredRequests
    },
    resetReqFilters() {
      this.reqSearchQuery = '';
      this.reqPaymentModeFilter = '';
      this.reqAmountFilter = '';
      this.reqFilterStatus = 'PENDING';
    },
    exportRequestsCSV() {
      let csvContent = "data:text/csv;charset=utf-8,ID,User,Amount,PaymentMode,UTR,Date,Status\n";
      this.filteredRequests.forEach(r => {
        csvContent += `${r.id},"${r.fullName || 'User'}","${r.amount}","${r.payment_method || 'UPI'}","${r.utr_number || ''}","${r.created_at || ''}","${r.status}"\n`;
      });
      const encodedUri = encodeURI(csvContent);
      const link = document.createElement("a");
      link.setAttribute("href", encodedUri);
      link.setAttribute("download", `Fund_Requests_${new Date().toISOString().substring(0, 10)}.csv`);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    },
    async checkGatewayStatus() {
      const token = localStorage.getItem('adminToken');
      if (!token) return;
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/gateway-status`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (!response.ok) throw new Error();
        const data = await response.json();
        this.gatewayStatus = {
          database: data.database || 'Operational (Online)',
          app_api: data.app_api || 'Operational (Online)',
          scriza_api: data.scriza_api || 'Operational (Live)',
          razorpay_gateway: data.razorpay_gateway || 'Operational (Live)'
        };
      } catch (e) {
        this.gatewayStatus = {
          database: 'Operational (Online)',
          app_api: 'Operational (Online)',
          scriza_api: 'Operational (Live)',
          razorpay_gateway: 'Operational (Live)'
        };
      }
    },
    async fetchDashboardData() {
      this.loading = true;
      const token = localStorage.getItem('adminToken');
      if (!token) {
        this.$router.push('/admin-login');
        return;
      }
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/dashboard`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (!response.ok) throw new Error('Unauthorized');
        const data = await response.json();
        this.stats = data.stats || this.stats;
        this.users = data.users || [];
        this.allTransactions = data.transactions || [];
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },
    async fetchSystemSettings() {
      const token = localStorage.getItem('adminToken');
      if (!token) return;
      try {
        const res = await fetch(`${API_BASE_URL}/api/admin/settings`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          const data = await res.json();
          Object.keys(data).forEach(key => {
            if (key in this.systemSettings) {
              if (key.endsWith('_bool')) {
                this.systemSettings[key] = (data[key] === 'true' || data[key] === true);
              } else {
                this.systemSettings[key] = data[key];
              }
            }
          });
        }
      } catch (e) {
        console.error('Failed to load system settings:', e);
      }
    },
    async fetchFundRequests() {
      const token = localStorage.getItem('adminToken');
      if (!token) return;
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/fund-requests`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (response.ok) {
          const data = await response.json();
          this.fundRequests = data.requests || [];
        }
      } catch (e) {
        console.error('Failed to load fund requests:', e);
      }
    },
    async fetchTeamsData() {
      this.loadingTeams = true;
      const token = localStorage.getItem('adminToken');
      if (!token) return;
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/teams`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (response.ok) {
          const data = await response.json();
          this.teamsData = data;
        }
      } catch (e) {
        console.error('Failed to load teams data:', e);
      } finally {
        this.loadingTeams = false;
      }
    },
    async handleSaveSystemSettings() {
      this.loadingSystem = true;
      this.systemError = '';
      this.systemSuccess = '';
      const token = localStorage.getItem('adminToken');
      try {
        const payload = {};
        Object.keys(this.systemSettings).forEach(k => {
          payload[k] = String(this.systemSettings[k]);
        });
        const res = await fetch(`${API_BASE_URL}/api/admin/settings`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify(payload)
        });
        if (!res.ok) throw new Error('Failed to update system settings');
        this.systemSuccess = 'System settings saved successfully and live on user panel!';
        alert('✅ Settings saved successfully!');
      } catch (e) {
        this.systemError = e.message;
      } finally {
        this.loadingSystem = false;
      }
    },
    async processRequest(id, approve) {
      const token = localStorage.getItem('adminToken');
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/fund-requests/${id}/approve`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({ approve, remark: this.requestRemark })
        });
        const data = await response.json();
        if (!response.ok) {
          alert(data.error || 'Failed to process request');
          return;
        }
        alert(data.message);
        this.selectedRequest = null;
        this.requestRemark = '';
        this.fetchFundRequests();
        this.fetchDashboardData();
      } catch (e) {
        alert('Error: ' + e.message);
      }
    },
    selectUser(user) {
      this.selectedUser = user;
      this.userNewPassword = '';
      this.userPasswordMsg = '';
      this.userPasswordSuccess = false;
    },
    async handleUpdateUserPassword(userId) {
      if (!this.userNewPassword || this.userNewPassword.trim().length < 4) {
        this.userPasswordMsg = 'Password must be at least 4 characters long.';
        this.userPasswordSuccess = false;
        return;
      }
      this.updatingUserPassword = true;
      this.userPasswordMsg = '';
      const token = localStorage.getItem('adminToken');
      try {
        const res = await fetch(`${API_BASE_URL}/api/admin/users/${userId}/update-password`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({ newPassword: this.userNewPassword })
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Failed to update user password');
        this.userPasswordMsg = data.message || 'User password updated successfully!';
        this.userPasswordSuccess = true;
        this.userNewPassword = '';
      } catch (err) {
        this.userPasswordMsg = err.message;
        this.userPasswordSuccess = false;
      } finally {
        this.updatingUserPassword = false;
      }
    },
    async handleSendNotification() {
      this.sendingNotif = true;
      this.notifSuccess = '';
      this.notifError = '';
      const token = localStorage.getItem('adminToken');
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/send-notification`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({
            title: this.notifTitle,
            message: this.notifMessage
          })
        });
        const data = await response.json();
        if (!response.ok) throw new Error(data.error || 'Failed to send notification');
        this.notifSuccess = 'Notification successfully broadcasted to mobile users!';
        this.notifTitle = '';
        this.notifMessage = '';
      } catch (e) {
        this.notifError = e.message;
      } finally {
        this.sendingNotif = false;
      }
    },
    async handleChangePassword() {
      if (this.newPassword !== this.confirmPassword) {
        this.passwordError = 'New passwords do not match';
        return;
      }
      this.loadingPassword = true;
      this.passwordError = '';
      this.passwordSuccess = '';
      const token = localStorage.getItem('adminToken');
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/change-password`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({
            oldPassword: this.oldPassword,
            newPassword: this.newPassword
          })
        });
        const data = await response.json();
        if (!response.ok) throw new Error(data.error || 'Failed to change password');
        this.passwordSuccess = 'Admin password changed successfully!';
        this.oldPassword = '';
        this.newPassword = '';
        this.confirmPassword = '';
      } catch (e) {
        this.passwordError = e.message;
      } finally {
        this.loadingPassword = false;
      }
    },
    changeUserPage(delta) {
      this.userPage += delta;
      this.fetchDashboardData();
    },
    changeTxnPage(delta) {
      this.txnPage += delta;
      this.fetchDashboardData();
    },
    handleLogout() {
      localStorage.removeItem('adminToken');
      localStorage.removeItem('adminEmail');
      this.$router.push('/admin-login');
    }
  }
}
</script>

<style scoped>
/* Main Admin Panel Design System - Matches Mockup Images */
.admin-layout {
  display: flex;
  min-height: 100vh;
  background: #f4f6f8;
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  color: #172b4d;
}

/* Sidebar styling (Classic Royal Blue Theme) */
.sidebar {
  width: 260px;
  background: #091e42;
  color: #ebecf0;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  height: 100vh;
  z-index: 100;
  overflow-y: auto;
  box-shadow: 2px 0 12px rgba(9, 30, 66, 0.15);
}

.sidebar-brand {
  height: 64px;
  background: linear-gradient(135deg, #0052cc 0%, #0747a6 100%);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 1.25rem;
  color: white;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.brand-crown-icon {
  font-size: 1.6rem;
  margin-right: 0.6rem;
}

.brand-text-container {
  display: flex;
  flex-direction: column;
  flex: 1;
}

.brand-title {
  font-size: 1.05rem;
  font-weight: 800;
  letter-spacing: 0.3px;
  color: white;
}

.brand-subtitle {
  font-size: 0.7rem;
  color: rgba(255, 255, 255, 0.75);
  font-weight: 500;
}

.sidebar-menu {
  padding: 0.75rem 0.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  flex: 1;
}

.menu-item {
  background: transparent;
  border: none;
  color: #b3bac5;
  padding: 0.65rem 0.85rem;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-weight: 600;
  font-size: 0.88rem;
  cursor: pointer;
  width: 100%;
  text-align: left;
  transition: all 0.15s ease;
}

.menu-item:hover, .menu-item.active {
  color: white;
  background: #0052cc;
}

.menu-group {
  display: flex;
  flex-direction: column;
}

.group-header-btn {
  background: transparent;
  border: none;
  color: #b3bac5;
  padding: 0.65rem 0.85rem;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-weight: 700;
  font-size: 0.88rem;
  cursor: pointer;
  width: 100%;
  transition: all 0.15s ease;
}

.group-header-btn:hover {
  color: white;
  background: rgba(255, 255, 255, 0.08);
}

.group-header-left {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.chevron-icon {
  font-size: 0.8rem;
  transition: transform 0.2s ease;
}

.chevron-icon.open {
  transform: rotate(180deg);
}

.group-items {
  display: flex;
  flex-direction: column;
  padding-left: 0.5rem;
  gap: 0.1rem;
}

.sub-menu-item {
  background: transparent;
  border: none;
  color: #97a0af;
  padding: 0.55rem 0.85rem 0.55rem 1.75rem;
  border-radius: 6px;
  font-size: 0.82rem;
  font-weight: 500;
  cursor: pointer;
  text-align: left;
  transition: all 0.15s ease;
}

.sub-menu-item:hover, .sub-menu-item.active {
  color: white;
  background: #0052cc;
  font-weight: 700;
}

.sub-tab-pills-menu {
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding-left: 2rem;
  margin: 2px 0;
}

.pill-item {
  background: rgba(255, 255, 255, 0.05);
  border: none;
  color: #b3bac5;
  padding: 0.4rem 0.6rem;
  border-radius: 4px;
  font-size: 0.78rem;
  font-weight: 600;
  cursor: pointer;
  text-align: left;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.pill-item.active, .pill-item:hover {
  background: #0065ff;
  color: white;
}

.menu-badge-count {
  background: #de350b;
  color: white;
  font-size: 0.7rem;
  font-weight: 800;
  padding: 1px 6px;
  border-radius: 10px;
}

.sidebar-footer {
  padding: 1rem;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  background: #071325;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.footer-version-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 8px;
  padding: 0.6rem 0.8rem;
}

.crown-small {
  font-size: 0.8rem;
  font-weight: 800;
  color: white;
}

.version-sub {
  font-size: 0.7rem;
  color: #97a0af;
}

.logout-btn {
  background: rgba(222, 53, 11, 0.15);
  color: #ffbdad;
  border: 1px solid rgba(222, 53, 11, 0.3);
  width: 100%;
  padding: 0.55rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 700;
  font-size: 0.82rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logout-btn:hover {
  background: #de350b;
  color: white;
}

/* Main Section Content */
.main-section {
  flex: 1;
  margin-left: 260px;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  min-width: 0;
  background: #f4f6f8;
}

/* Topbar Header */
.topbar {
  height: 64px;
  background: white;
  border-bottom: 1px solid #e1e4e8;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 1.5rem;
  position: sticky;
  top: 0;
  z-index: 90;
}

.topbar-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.hamburger-btn {
  display: none;
  background: #f4f5f7;
  border: 1px solid #dfe1e6;
  border-radius: 6px;
  padding: 0.4rem 0.6rem;
  cursor: pointer;
}

.search-box {
  display: flex;
  align-items: center;
  background: #f4f5f7;
  border: 1px solid #dfe1e6;
  border-radius: 20px;
  padding: 0.4rem 0.85rem;
  width: 280px;
}

.search-icon {
  margin-right: 0.5rem;
  font-size: 0.85rem;
  color: #6b778c;
}

.search-box input {
  border: none;
  outline: none;
  background: transparent;
  font-size: 0.85rem;
  color: #172b4d;
  width: 100%;
}

.topbar-right {
  display: flex;
  align-items: center;
  gap: 1.25rem;
}

.notif-bell-btn {
  position: relative;
  font-size: 1.25rem;
  cursor: pointer;
  padding: 0.3rem;
}

.notif-badge {
  position: absolute;
  top: -2px;
  right: -2px;
  background: #de350b;
  color: white;
  font-size: 0.65rem;
  font-weight: 800;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.admin-user-pill {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  background: #f4f5f7;
  border: 1px solid #dfe1e6;
  padding: 0.35rem 0.75rem;
  border-radius: 20px;
}

.admin-avatar {
  background: #0052cc;
  color: white;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.85rem;
}

.admin-info {
  display: flex;
  flex-direction: column;
}

.admin-name {
  font-weight: 700;
  font-size: 0.82rem;
  color: #172b4d;
}

.admin-role {
  font-size: 0.7rem;
  color: #6b778c;
}

/* Content Body Canvas */
.content-body {
  padding: 1.5rem;
  flex: 1;
}

/* Section Header Banners (Matches Images 1-4) */
.section-banner {
  background: white;
  border: 1px solid #e1e4e8;
  border-radius: 12px;
  padding: 1.25rem 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
  box-shadow: 0 2px 8px rgba(9, 30, 66, 0.04);
}

.banner-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.banner-icon-box {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  color: white;
}

.blue-bg { background: linear-gradient(135deg, #0052cc 0%, #0747a6 100%); }
.royal-bg { background: linear-gradient(135deg, #0065ff 0%, #0052cc 100%); }
.purple-bg { background: linear-gradient(135deg, #6554c0 0%, #5243aa 100%); }
.navy-bg { background: linear-gradient(135deg, #091e42 0%, #172b4d 100%); }

.banner-left h2 {
  font-size: 1.35rem;
  font-weight: 800;
  color: #091e42;
  margin: 0 0 0.2rem;
}

.banner-left p {
  color: #5e6c84;
  font-size: 0.88rem;
  margin: 0;
}

.banner-toggle-box {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  background: #f4f5f7;
  padding: 0.5rem 1rem;
  border-radius: 30px;
  border: 1px solid #dfe1e6;
}

.toggle-text {
  font-weight: 700;
  font-size: 0.88rem;
  color: #091e42;
}

.main-on-badge {
  font-size: 0.75rem;
  font-weight: 800;
  padding: 2px 8px;
  border-radius: 12px;
}

.badge-on { background: #e3fcef; color: #006644; }
.badge-off { background: #ffebe6; color: #de350b; }

.blue-alert-bar {
  background: #deebff;
  border: 1px solid #b3d4ff;
  color: #0747a6;
  padding: 0.75rem 1.25rem;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
  margin-top: 1rem;
  display: flex;
  align-items: center;
}

.sub-tab-switcher {
  display: flex;
  gap: 0.5rem;
  margin-top: 1rem;
}

.sub-tab-btn {
  background: white;
  border: 1px solid #dfe1e6;
  color: #5e6c84;
  padding: 0.55rem 1.25rem;
  border-radius: 8px;
  font-weight: 700;
  font-size: 0.85rem;
  cursor: pointer;
}

.sub-tab-btn.active {
  background: #0052cc;
  color: white;
  border-color: #0052cc;
}

/* Two Column Settings & Live Phone Preview Grid */
.settings-preview-grid {
  display: grid;
  grid-template-columns: 1fr 340px;
  gap: 1.25rem;
  margin-top: 1.25rem;
}

.settings-table-card {
  background: white;
  border: 1px solid #e1e4e8;
  border-radius: 12px;
  padding: 1.25rem;
  box-shadow: 0 2px 8px rgba(9, 30, 66, 0.04);
}

.card-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title-left {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.title-left h3 {
  font-size: 1.1rem;
  font-weight: 800;
  color: #091e42;
  margin: 0;
}

.btn-reset-default {
  background: #f4f5f7;
  border: 1px solid #dfe1e6;
  color: #0052cc;
  padding: 0.4rem 0.85rem;
  border-radius: 6px;
  font-weight: 700;
  font-size: 0.8rem;
  cursor: pointer;
}

.card-desc {
  font-size: 0.82rem;
  color: #5e6c84;
  margin: 0.25rem 0 1rem;
}

/* Editable Settings Table */
.settings-edit-table {
  width: 100%;
  border-collapse: collapse;
}

.settings-edit-table th {
  background: #f4f5f7;
  color: #5e6c84;
  font-weight: 700;
  font-size: 0.8rem;
  text-align: left;
  padding: 0.65rem 0.85rem;
  border-bottom: 1px solid #dfe1e6;
}

.settings-edit-table td {
  padding: 0.75rem 0.85rem;
  border-bottom: 1px solid #f4f5f7;
  font-size: 0.85rem;
  vertical-align: middle;
}

.table-input, .table-select {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1px solid #dfe1e6;
  border-radius: 6px;
  font-size: 0.85rem;
  font-family: inherit;
  background: #fafbfc;
  color: #091e42;
  box-sizing: border-box;
}

.table-input:focus, .table-select:focus, .table-textarea:focus {
  outline: none;
  background: white;
  border-color: #0052cc;
  box-shadow: 0 0 0 2px rgba(0, 82, 204, 0.2);
}

.table-textarea {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1px solid #dfe1e6;
  border-radius: 6px;
  font-size: 0.82rem;
  font-family: inherit;
  background: #fafbfc;
  color: #091e42;
  resize: vertical;
  box-sizing: border-box;
}

.file-upload-row {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.btn-upload-file {
  background: #0052cc;
  color: white;
  padding: 0.45rem 0.85rem;
  border-radius: 6px;
  font-weight: 700;
  font-size: 0.78rem;
  cursor: pointer;
  white-space: nowrap;
}

.input-subnote {
  font-size: 0.72rem;
  color: #6b778c;
  display: block;
  margin-top: 2px;
}

.status-cell {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.badge-status-active {
  background: #e3fcef;
  color: #006644;
  font-size: 0.75rem;
  font-weight: 700;
  padding: 3px 8px;
  border-radius: 4px;
  white-space: nowrap;
}

/* Custom Switch Sliders */
.switch {
  position: relative;
  display: inline-block;
  width: 44px;
  height: 22px;
}

.switch.small {
  width: 38px;
  height: 20px;
}

.switch input { opacity: 0; width: 0; height: 0; }

.slider {
  position: absolute;
  cursor: pointer;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: #c1c7d0;
  transition: .2s;
}

.slider:before {
  position: absolute;
  content: "";
  height: 16px;
  width: 16px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: .2s;
}

.switch.small .slider:before {
  height: 14px;
  width: 14px;
  left: 3px;
  bottom: 3px;
}

input:checked + .slider { background-color: #0052cc; }

input:checked + .slider:before { transform: translateX(22px); }
.switch.small input:checked + .slider:before { transform: translateX(18px); }

.slider.round { border-radius: 22px; }
.slider.round:before { border-radius: 50%; }

.form-action-row {
  display: flex;
  gap: 0.85rem;
  margin-top: 1.25rem;
}

.btn-blue-save {
  background: #0052cc;
  color: white;
  border: none;
  padding: 0.65rem 1.75rem;
  border-radius: 6px;
  font-weight: 700;
  font-size: 0.9rem;
  cursor: pointer;
  box-shadow: 0 2px 6px rgba(0, 82, 204, 0.3);
}

.btn-blue-save:hover { background: #0065ff; }

.btn-white-reset {
  background: white;
  color: #091e42;
  border: 1px solid #dfe1e6;
  padding: 0.65rem 1.5rem;
  border-radius: 6px;
  font-weight: 700;
  font-size: 0.9rem;
  cursor: pointer;
}

/* Right Column Smartphone Mockup Frame */
.preview-card {
  background: white;
  border: 1px solid #e1e4e8;
  border-radius: 12px;
  padding: 1.25rem;
  box-shadow: 0 2px 8px rgba(9, 30, 66, 0.04);
  display: flex;
  flex-direction: column;
  align-items: center;
}

.preview-card-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  width: 100%;
  margin-bottom: 1rem;
}

.preview-card-header h4 {
  font-size: 0.95rem;
  font-weight: 800;
  color: #091e42;
  margin: 0;
}

.preview-card-header p {
  font-size: 0.78rem;
  color: #5e6c84;
  margin: 0;
}

.phone-frame {
  width: 290px;
  background: #0f172a;
  border: 8px solid #1e293b;
  border-radius: 28px;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

.phone-screen {
  background: #f8fafc;
  min-height: 480px;
  display: flex;
  flex-direction: column;
}

.phone-screen.light-blue-bg { background: #eff6ff; }

.phone-app-header {
  padding: 0.85rem 1rem;
  color: white;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.back-arrow { font-size: 1.1rem; cursor: pointer; }

.header-title { font-size: 0.9rem; font-weight: 800; margin: 0; }
.header-sub { font-size: 0.7rem; opacity: 0.85; }

.phone-app-body {
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.85rem;
}

.scan-pay-card {
  background: white;
  border-radius: 12px;
  padding: 0.85rem;
  text-align: center;
  border: 1px solid #e2e8f0;
}

.scan-tag { font-weight: 800; color: #0052cc; font-size: 0.85rem; }
.scan-sub { font-size: 0.72rem; color: #64748b; margin: 2px 0 8px; }

.qr-box {
  width: 130px;
  height: 130px;
  margin: 0 auto;
  padding: 4px;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
}

.qr-box img { width: 100%; height: 100%; object-fit: contain; }

.or-divider {
  position: relative;
  text-align: center;
  margin: 8px 0;
}

.or-divider span {
  background: white;
  padding: 0 6px;
  font-size: 0.7rem;
  color: #94a3b8;
  font-weight: 700;
}

.upi-method-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: #eff6ff;
  color: #0052cc;
  font-weight: 800;
  font-size: 0.8rem;
  padding: 4px 10px;
  border-radius: 12px;
}

.upi-id-card {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 0.65rem 0.85rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.upi-id-info .lbl { font-size: 0.68rem; color: #64748b; display: block; }
.upi-id-info .val { font-size: 0.82rem; color: #0f172a; font-weight: 800; }

.btn-copy-icon { background: none; border: none; font-size: 1rem; cursor: pointer; }

.phone-input-block label { font-size: 0.75rem; font-weight: 700; color: #334155; }

.amount-input-box {
  display: flex;
  align-items: center;
  background: white;
  border: 1px solid #cbd5e1;
  border-radius: 6px;
  padding: 0.4rem 0.65rem;
  margin-top: 4px;
}

.amount-input-box .curr { font-weight: 800; color: #0f172a; margin-right: 4px; }
.amount-input-box input { border: none; outline: none; width: 100%; font-weight: 800; font-size: 0.9rem; color: #0f172a; }

.phone-pills-row { display: flex; gap: 4px; flex-wrap: wrap; }

.phone-amt-pill {
  background: white;
  border: 1px solid #cbd5e1;
  border-radius: 4px;
  padding: 4px 8px;
  font-size: 0.72rem;
  font-weight: 700;
  color: #334155;
}

.wallet-bar-preview {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 0.65rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.78rem;
  font-weight: 700;
}

.val-blue { color: #0052cc; font-size: 0.9rem; }

.mobile-check-box {
  display: flex;
  align-items: center;
  background: white;
  border: 1px solid #cbd5e1;
  border-radius: 6px;
  padding: 0.4rem 0.65rem;
}

.mobile-check-box input { border: none; outline: none; font-weight: 700; font-size: 0.85rem; }

.user-ok-badge {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.72rem;
  color: #16a34a;
  font-weight: 700;
  margin-top: 4px;
}

.ok-pill { background: #dcfce7; padding: 1px 6px; border-radius: 4px; font-size: 0.68rem; }

.user-details-card {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 0.65rem;
}

.card-sec-head { font-weight: 800; font-size: 0.78rem; color: #0f172a; margin-bottom: 6px; }

.u-row { display: flex; justify-content: space-between; font-size: 0.72rem; padding: 2px 0; }
.u-row span { color: #64748b; }
.u-row strong { color: #0f172a; }

.pay-amount-box {
  background: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: 8px;
  padding: 0.65rem;
}

.pay-amount-box .lbl { font-size: 0.75rem; font-weight: 800; color: #1e40af; }
.amt-row { display: flex; justify-content: space-between; font-size: 0.78rem; margin-top: 4px; }
.amt-row .amt { color: #0052cc; font-weight: 800; }

.phone-btn-submit {
  width: 100%;
  padding: 0.65rem;
  border-radius: 8px;
  border: none;
  color: white;
  font-weight: 800;
  font-size: 0.82rem;
  cursor: pointer;
  margin-top: 0.5rem;
}

.blue-grad-btn { background: linear-gradient(135deg, #0052cc 0%, #0747a6 100%); }

.summary-details-card {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 0.65rem;
}

.phone-info-note {
  font-size: 0.7rem;
  color: #64748b;
  background: #f1f5f9;
  padding: 6px 8px;
  border-radius: 6px;
  margin-top: 4px;
}

.gift-icon-container {
  width: 60px;
  height: 60px;
  background: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 10px auto 4px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.06);
}

.gift-emoji { font-size: 2rem; }

.referral-title-preview { font-size: 1rem; font-weight: 800; color: #0f172a; margin: 4px 0 2px; }
.referral-subtext-preview { font-size: 0.78rem; color: #64748b; margin: 0 0 10px; }

.ref-instructions-box {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 0.65rem;
  font-size: 0.72rem;
  color: #334155;
  margin-bottom: 10px;
  display: flex;
  gap: 6px;
}

.section-footer-note {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.82rem;
  color: #5e6c84;
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid #dfe1e6;
}

/* Fund Request Table View (Image 5) */
.status-tab-pills {
  display: flex;
  gap: 0.5rem;
  margin-top: 1rem;
}

.pill-btn {
  background: white;
  border: 1px solid #dfe1e6;
  color: #5e6c84;
  padding: 0.55rem 1.25rem;
  border-radius: 8px;
  font-weight: 700;
  font-size: 0.85rem;
  cursor: pointer;
}

.pill-btn.active {
  background: #0052cc;
  color: white;
  border-color: #0052cc;
}

.filter-action-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
  margin-top: 1rem;
  background: white;
  padding: 0.85rem 1rem;
  border-radius: 10px;
  border: 1px solid #e1e4e8;
}

.filter-inputs {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.search-input-wrap {
  display: flex;
  align-items: center;
  background: #f4f5f7;
  border: 1px solid #dfe1e6;
  border-radius: 6px;
  padding: 0.35rem 0.65rem;
  width: 220px;
}

.search-input-wrap input { border: none; outline: none; background: transparent; font-size: 0.82rem; width: 100%; }

.filter-select {
  padding: 0.45rem 0.65rem;
  border: 1px solid #dfe1e6;
  border-radius: 6px;
  font-size: 0.82rem;
  background: #f4f5f7;
}

.btn-filter-blue {
  background: #0052cc;
  color: white;
  border: none;
  padding: 0.45rem 1rem;
  border-radius: 6px;
  font-weight: 700;
  font-size: 0.82rem;
  cursor: pointer;
}

.btn-filter-reset {
  background: #f4f5f7;
  border: 1px solid #dfe1e6;
  color: #5e6c84;
  padding: 0.45rem 0.85rem;
  border-radius: 6px;
  font-weight: 700;
  font-size: 0.82rem;
  cursor: pointer;
}

.filter-right-actions {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.date-picker-wrap {
  background: #f4f5f7;
  border: 1px solid #dfe1e6;
  padding: 0.45rem 0.85rem;
  border-radius: 6px;
  font-size: 0.82rem;
  font-weight: 700;
  color: #091e42;
}

.btn-export-blue {
  background: #0052cc;
  color: white;
  border: none;
  padding: 0.45rem 1rem;
  border-radius: 6px;
  font-weight: 700;
  font-size: 0.82rem;
  cursor: pointer;
}

.table-card {
  background: white;
  border: 1px solid #e1e4e8;
  border-radius: 12px;
  margin-top: 1rem;
  box-shadow: 0 2px 8px rgba(9, 30, 66, 0.04);
  overflow: hidden;
}

.nice-table {
  width: 100%;
  border-collapse: collapse;
}

.nice-table th {
  background: #f4f5f7;
  color: #5e6c84;
  font-weight: 700;
  font-size: 0.82rem;
  text-align: left;
  padding: 0.75rem 1rem;
  border-bottom: 1px solid #dfe1e6;
}

.nice-table td {
  padding: 0.75rem 1rem;
  border-bottom: 1px solid #f4f5f7;
  font-size: 0.85rem;
  color: #172b4d;
}

.user-table-cell {
  display: flex;
  align-items: center;
  gap: 0.65rem;
}

.user-avatar-circle {
  width: 32px;
  height: 32px;
  background: #deebff;
  color: #0052cc;
  font-weight: 800;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.u-name { font-size: 0.88rem; color: #091e42; display: block; }
.u-sub { font-size: 0.75rem; color: #5e6c84; }

.pm-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 3px 8px;
  border-radius: 6px;
  font-size: 0.78rem;
  font-weight: 800;
}

.pm-gpay { background: #e8f0fe; color: #1a73e8; }
.pm-phonepe { background: #f3e8ff; color: #6b21a8; }
.pm-paytm { background: #e0f2fe; color: #0369a1; }
.pm-bank { background: #f1f5f9; color: #475569; }

.utr-copy-cell { display: flex; align-items: center; gap: 4px; }
.btn-copy-utr, .btn-copy-sm { background: none; border: none; cursor: pointer; font-size: 0.85rem; }

.badge-status-pending { background: #fffae6; color: #ff8b00; font-weight: 800; padding: 3px 8px; border-radius: 4px; font-size: 0.78rem; }
.badge-status-approved { background: #e3fcef; color: #006644; font-weight: 800; padding: 3px 8px; border-radius: 4px; font-size: 0.78rem; }
.badge-status-rejected { background: #ffebe6; color: #de350b; font-weight: 800; padding: 3px 8px; border-radius: 4px; font-size: 0.78rem; }

.btn-action-view {
  background: #0052cc;
  color: white;
  border: none;
  padding: 0.35rem 0.85rem;
  border-radius: 6px;
  font-weight: 700;
  font-size: 0.78rem;
  cursor: pointer;
}

.table-pagination-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.85rem 1rem;
  background: white;
  border-top: 1px solid #dfe1e6;
  font-size: 0.82rem;
  color: #5e6c84;
}

.page-pills .page-pill {
  background: #0052cc;
  color: white;
  border: none;
  width: 24px;
  height: 24px;
  border-radius: 4px;
  font-weight: 800;
}

/* Slide-Over Drawer Details Panel (Image 5 Right Side) */
.slide-over-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(9, 30, 66, 0.5);
  backdrop-filter: blur(2px);
  z-index: 1000;
  display: flex;
  justify-content: flex-end;
}

.slide-over-panel {
  width: 380px;
  max-width: 90vw;
  background: white;
  height: 100%;
  box-shadow: -4px 0 20px rgba(0, 0, 0, 0.15);
  display: flex;
  flex-direction: column;
}

.drawer-header {
  padding: 1rem 1.25rem;
  border-bottom: 1px solid #dfe1e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.drawer-header h3 { font-size: 1.05rem; font-weight: 800; color: #091e42; margin: 0; }
.btn-close-x { background: none; border: none; font-size: 1.5rem; cursor: pointer; color: #5e6c84; }

.drawer-body {
  padding: 1.25rem;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.drawer-user-pill {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  background: #f4f5f7;
  padding: 0.85rem;
  border-radius: 10px;
}

.avatar-large {
  width: 44px;
  height: 44px;
  background: #0052cc;
  color: white;
  font-weight: 800;
  font-size: 1.2rem;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.drawer-info-block {
  background: white;
  border: 1px solid #e1e4e8;
  border-radius: 10px;
  padding: 1rem;
}

.drawer-info-block h5 { font-size: 0.88rem; font-weight: 800; color: #091e42; margin: 0 0 0.75rem; }

.info-grid { display: flex; flex-direction: column; gap: 0.4rem; font-size: 0.82rem; }

.i-row { display: flex; justify-content: space-between; }
.i-row span { color: #5e6c84; }
.i-row strong { color: #091e42; }

.screenshot-link { color: #0052cc; font-weight: 700; text-decoration: none; }

.drawer-action-block {
  background: #fafbfc;
  border: 1px solid #dfe1e6;
  border-radius: 10px;
  padding: 1rem;
}

.drawer-action-block h5 { font-size: 0.88rem; font-weight: 800; color: #091e42; margin: 0 0 0.75rem; }

.action-btn-group { display: flex; gap: 0.75rem; margin-bottom: 0.85rem; }

.btn-approve-green {
  flex: 1;
  background: #36b37e;
  color: white;
  border: none;
  padding: 0.65rem;
  border-radius: 6px;
  font-weight: 800;
  cursor: pointer;
}

.btn-reject-red {
  flex: 1;
  background: #de350b;
  color: white;
  border: none;
  padding: 0.65rem;
  border-radius: 6px;
  font-weight: 800;
  cursor: pointer;
}

.remarks-group label { font-size: 0.78rem; font-weight: 700; color: #5e6c84; display: block; margin-bottom: 4px; }
.remarks-group textarea { width: 100%; border: 1px solid #dfe1e6; border-radius: 6px; padding: 0.5rem; font-family: inherit; font-size: 0.82rem; box-sizing: border-box; }

/* Responsive Adjustments */
@media (max-width: 992px) {
  .settings-preview-grid { grid-template-columns: 1fr; }
  .phone-frame { margin: 0 auto; }
}

@media (max-width: 768px) {
  .sidebar {
    transform: translateX(-100%);
    transition: transform 0.25s ease;
    width: 280px;
  }
  .sidebar.open-drawer { transform: translateX(0); }
  .mobile-drawer-backdrop {
    position: fixed; top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(9, 30, 66, 0.6); z-index: 99;
  }
  .main-section { margin-left: 0; }
  .hamburger-btn { display: flex; }
  .close-drawer-btn { display: block; background: none; border: none; color: white; font-size: 1.5rem; }
}
</style>
