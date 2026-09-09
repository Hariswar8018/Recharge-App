<template>
  <div class="admin-layout">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="sidebar-brand">
        <div class="brand-icon">N</div>
        <span class="brand-text">ADMIN</span>
      </div>
      
      <div class="sidebar-menu">
        <div class="menu-label">PERSONAL</div>
        <button @click="currentTab = 'dashboard'" class="menu-item" :class="{ active: currentTab === 'dashboard' }">
          <span class="icon">📊</span> Dashboards
        </button>
        <button @click="currentTab = 'users'" class="menu-item" :class="{ active: currentTab === 'users' }">
          <span class="icon">👤</span> Users List
        </button>
        <button @click="currentTab = 'requests'" class="menu-item" :class="{ active: currentTab === 'requests' }">
          <span class="icon">📥</span> Fund Requests
          <span v-if="pendingRequestsCount > 0" class="badge-count">{{ pendingRequestsCount }}</span>
        </button>
        <button @click="currentTab = 'transactions'" class="menu-item" :class="{ active: currentTab === 'transactions' }">
          <span class="icon">📈</span> All Transactions
        </button>
        <button @click="currentTab = 'teams'" class="menu-item" :class="{ active: currentTab === 'teams' }">
          <span class="icon">👥</span> User Teams
        </button>

        <div class="menu-label">GLOBAL</div>
        <button @click="currentTab = 'notifications'" class="menu-item" :class="{ active: currentTab === 'notifications' }">
          <span class="icon">📢</span> Send Notification
        </button>
        <button @click="currentTab = 'uiux'" class="menu-item" :class="{ active: currentTab === 'uiux' }">
          <span class="icon">🎨</span> UI / UX
        </button>
        <button @click="currentTab = 'shared_variable'" class="menu-item" :class="{ active: currentTab === 'shared_variable' }">
          <span class="icon">🔗</span> Shared Variable
        </button>
        <button @click="currentTab = 'admins'" class="menu-item" :class="{ active: currentTab === 'admins' }">
          <span class="icon">🛡️</span> System Admins
        </button>
        <button @click="currentTab = 'settings'" class="menu-item" :class="{ active: currentTab === 'settings' }">
          <span class="icon">⚙️</span> Change Password
        </button>
      </div>

      <div class="sidebar-footer">
        <button @click="handleLogout" class="logout-btn">
          Logout &rarr;
        </button>
      </div>
    </aside>

    <!-- Main Section -->
    <div class="main-section">
      <!-- Topbar Header -->
      <header class="topbar">
        <div class="topbar-left-placeholder"></div>
        <div class="topbar-actions">
          <span class="action-icon" @click="currentTab = 'notifications'" title="Send Broadcast Notification">✉️</span>
          
          <div class="admin-profile-badge">
            <div class="avatar">{{ adminEmail[0].toUpperCase() }}</div>
            <span class="profile-name">{{ adminEmail.split('@')[0] }}</span>
          </div>

          <button @click="handleLogout" class="topbar-logout-btn">
            Logout 📤
          </button>
        </div>
      </header>

      <!-- Main Content Container -->
      <main class="content-body">
        <div class="content-header">
          <h2>{{ tabTitle }}</h2>
          <div class="breadcrumbs">Dashboard &gt; {{ tabTitle }}</div>
        </div>

        <!-- Global Warning Banner -->
        <div v-if="isGlobalTab" class="global-warning-banner">
          ⚠️ WARNING: Please perform all modifications in this section with full attention. Changing these global configurations impacts live app behavior and payment gateways immediately.
        </div>

        <!-- System & API Operational Status Cards -->
        <section v-if="currentTab === 'dashboard'" class="op-status-section-new">
          <div class="op-card-header-new">
            <h4>🖥️ Systems & API Operational Status</h4>
            <button @click="checkGatewayStatus" class="refresh-op-btn-new">🔄 Refresh Status</button>
          </div>
          <div class="op-grid-new">
            <div class="op-item-new green-border">
              <span class="op-lbl">Database Connection</span>
              <strong class="op-val">{{ gatewayStatus.database }}</strong>
            </div>
            <div class="op-item-new green-border">
              <span class="op-lbl">Recharge API Server</span>
              <strong class="op-val">{{ gatewayStatus.app_api }}</strong>
            </div>
            <div class="op-item-new orange-border">
              <span class="op-lbl">Scriza Gateway API</span>
              <strong class="op-val">{{ gatewayStatus.scriza_api }}</strong>
            </div>
            <div class="op-item-new orange-border">
              <span class="op-lbl">Razorpay Gateway API</span>
              <strong class="op-val">{{ gatewayStatus.razorpay_gateway }}</strong>
            </div>
          </div>
        </section>

        <div v-if="loading && !['settings', 'notifications', 'uiux', 'shared_variable'].includes(currentTab)" class="loading-box">
          Loading dashboard content...
        </div>

        <div v-else class="tab-content-area">
          <!-- TAB 1: DASHBOARD OVERVIEW (100% REAL DATA) -->
          <div v-if="currentTab === 'dashboard'" class="dashboard-panes">
            <!-- Primary Platform Metrics (Real Database Stats) -->
            <div class="stats-grid" style="margin-bottom: 1.5rem; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;">
              <div class="nice-stat-card border-blue" @click="currentTab = 'users'" style="cursor: pointer;">
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

              <div class="nice-stat-card border-orange" @click="currentTab = 'transactions'" style="cursor: pointer;">
                <div class="stat-body">
                  <div class="stat-left">
                    <span class="icon-indicator">📈</span>
                    <span class="stat-card-title">Total Transactions</span>
                  </div>
                  <span class="stat-card-val">{{ stats.totalTransactions }}</span>
                </div>
                <div class="progress-bar bg-orange"></div>
              </div>

              <div class="nice-stat-card border-red" @click="currentTab = 'requests'" style="cursor: pointer;">
                <div class="stat-body">
                  <div class="stat-left">
                    <span class="icon-indicator">⏳</span>
                    <span class="stat-card-title">Pending Requests</span>
                  </div>
                  <span class="stat-card-val">{{ pendingRequestsCount }}</span>
                </div>
                <div class="progress-bar bg-red" style="background: #ef4444;"></div>
              </div>
            </div>

            <!-- Real Activity & Operational Summary Split Grid -->
            <div class="bottom-analytics" style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.5rem;">
              <!-- Real Transactions Log Table -->
              <div class="anal-card sales-table-card" style="margin: 0;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                  <h3 style="margin: 0;">Recent Real Platform Transactions</h3>
                  <button @click="currentTab = 'transactions'" class="btn-add-img" style="font-size: 0.8rem; padding: 0.35rem 0.75rem;">View All Txns &rarr;</button>
                </div>
                <div class="table-container">
                  <table class="nice-table">
                    <thead>
                      <tr>
                        <th>Txn ID</th>
                        <th>User ID</th>
                        <th>Wallet</th>
                        <th>Amount</th>
                        <th>Date & Time</th>
                        <th>Status</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-if="transactions.length === 0">
                        <td colspan="6" style="text-align: center; color: #94a3b8; padding: 1.5rem;">No transactions recorded in database yet.</td>
                      </tr>
                      <tr v-for="txn in transactions.slice(0, 8)" :key="txn.id">
                        <td class="font-bold">#{{ txn.id }}</td>
                        <td>#{{ txn.user_id }}</td>
                        <td><span class="lbl-wallet" :class="(txn.wallet_type || 'main').toLowerCase()">{{ txn.wallet_type }}</span></td>
                        <td class="font-bold" style="color: #10b981;">{{ txn.amount }}</td>
                        <td style="font-size: 0.8rem; color: #64748b;">{{ txn.date || 'N/A' }}</td>
                        <td>
                          <span :class="txn.status === 'Success' || txn.status === 'APPROVED' ? 'nice-badge-success' : 'nice-badge-pending'">
                            {{ txn.status || 'Success' }}
                          </span>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>

              <!-- Quick Control & Platform Shortcuts -->
              <div class="anal-card" style="margin: 0; display: flex; flex-direction: column; gap: 1rem;">
                <h3 style="margin: 0;">⚡ Quick Operational Panel</h3>
                <div style="display: flex; flex-direction: column; gap: 0.75rem;">
                  <button @click="currentTab = 'requests'" class="menu-item" style="background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; border-radius: 8px; padding: 0.75rem; font-weight: 600; text-align: left; display: flex; justify-content: space-between; align-items: center;">
                    <span>📥 Deposit Requests Approval</span>
                    <span v-if="pendingRequestsCount > 0" class="badge-count" style="background: #dc2626; color: white;">{{ pendingRequestsCount }} Pending</span>
                  </button>

                  <button @click="currentTab = 'users'" class="menu-item" style="background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; border-radius: 8px; padding: 0.75rem; font-weight: 600; text-align: left; display: flex; justify-content: space-between; align-items: center;">
                    <span>👥 Manage Portal Users ({{ stats.totalUsers }})</span>
                    <span>&rarr;</span>
                  </button>

                  <button @click="currentTab = 'notifications'" class="menu-item" style="background: #faf5ff; border: 1px solid #e9d5ff; color: #6b21a8; border-radius: 8px; padding: 0.75rem; font-weight: 600; text-align: left; display: flex; justify-content: space-between; align-items: center;">
                    <span>📢 Send Broadcast Notice</span>
                    <span>&rarr;</span>
                  </button>

                  <button @click="currentTab = 'shared_variable'" class="menu-item" style="background: #fff7ed; border: 1px solid #ffedd5; color: #c2410c; border-radius: 8px; padding: 0.75rem; font-weight: 600; text-align: left; display: flex; justify-content: space-between; align-items: center;">
                    <span>⚙️ Shared System Variables</span>
                    <span>&rarr;</span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- TAB 2: USERS VIEW -->
          <div v-if="currentTab === 'users'" class="users-list-pane">
            <div class="table-card">
              <div class="table-header-row">
                <h3>Registered Mobile App Users</h3>
                <div class="pagination-controls">
                  <button @click="changeUserPage(-1)" :disabled="userPage === 1" class="page-btn page-nav-btn">&larr; Prev</button>
                  <span class="page-num">Page {{ userPage }}</span>
                  <button @click="changeUserPage(1)" :disabled="users.length < 10" class="page-btn page-nav-btn">Next &rarr;</button>
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
                      <th>Details</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="user in users" :key="user.id" class="clickable-row" @click="selectUser(user)">
                      <td>#{{ user.id }}</td>
                      <td class="font-bold">{{ user.fullName }}</td>
                      <td>{{ user.email }}</td>
                      <td>{{ user.mobileNumber }}</td>
                      <td>₹{{ parseFloat(user.main_wallet_balance).toFixed(2) }}</td>
                      <td>₹{{ parseFloat(user.fund_wallet_balance).toFixed(2) }}</td>
                      <td>
                        <button class="action-view-btn">View Profile</button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Slide-Over User details -->
            <div v-if="selectedUser" class="slide-over-backdrop" @click="selectedUser = null">
              <div class="slide-over" @click.stop>
                <div class="slide-header">
                  <h3>User Profile</h3>
                  <button @click="selectedUser = null" class="close-btn">&times;</button>
                </div>
                <div class="slide-body">
                  <div class="profile-avatar-area">
                    <div class="large-avatar">{{ selectedUser.fullName[0].toUpperCase() }}</div>
                    <h4>{{ selectedUser.fullName }}</h4>
                    <span class="status-lbl green">Active Account</span>
                  </div>

                  <div class="wallets-row">
                    <div class="wallet-stat bg-blue-grad">
                      <span>Main Wallet</span>
                      <h4>₹{{ parseFloat(selectedUser.main_wallet_balance).toFixed(2) }}</h4>
                    </div>
                    <div class="wallet-stat bg-purple-grad">
                      <span>Fund Wallet</span>
                      <h4>₹{{ parseFloat(selectedUser.fund_wallet_balance).toFixed(2) }}</h4>
                    </div>
                  </div>

                  <div class="details-list">
                    <div class="item">
                      <span>Email</span>
                      <strong>{{ selectedUser.email }}</strong>
                    </div>
                    <div class="item">
                      <span>Mobile</span>
                      <strong>{{ selectedUser.mobileNumber }}</strong>
                    </div>
                    <div class="item">
                      <span>Device OS Info</span>
                      <strong style="color: #0052cc;">{{ selectedUser.device_model || 'Android / Unknown' }}</strong>
                    </div>
                    <div class="item">
                      <span>App Version</span>
                      <strong>v{{ selectedUser.app_version || '1.0.0' }}</strong>
                    </div>
                    <div class="item">
                      <span>Affiliate Downline</span>
                      <strong>14 Active Members</strong>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- TAB 3: PENDING APPROVALS -->
          <div v-if="currentTab === 'requests'" class="requests-pane">
            <div class="table-card">
              <h3>Pending Fund Requests</h3>
              <div class="table-container">
                <table class="nice-table">
                  <thead>
                    <tr>
                      <th>Req ID</th>
                      <th>User</th>
                      <th>Email</th>
                      <th>Requested Amount</th>
                      <th>Date</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="req in fundRequests" :key="req.id">
                      <td>#{{ req.id }}</td>
                      <td class="font-bold">{{ req.fullName }}</td>
                      <td>{{ req.email }}</td>
                      <td class="font-bold text-blue">₹{{ parseFloat(req.amount).toFixed(2) }}</td>
                      <td>{{ new Date(req.createdAt).toLocaleDateString() }}</td>
                      <td>
                        <div v-if="req.status === 'PENDING'" class="row-actions">
                          <button @click="processRequest(req.id, true)" class="btn-approve">Approve</button>
                          <button @click="processRequest(req.id, false)" class="btn-reject">Reject</button>
                        </div>
                        <span v-else class="txt-processed">{{ req.status }}</span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- TAB 4: SYSTEM ADMINS -->
          <div v-if="currentTab === 'admins'" class="admins-pane">
            <div class="table-card">
              <h3>System Administrators</h3>
              <div class="table-container">
                <table class="nice-table">
                  <thead>
                    <tr>
                      <th>Admin ID</th>
                      <th>Full Name</th>
                      <th>Email Address</th>
                      <th>Mobile</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="admin in adminsList" :key="admin.id">
                      <td>#{{ admin.id }}</td>
                      <td class="font-bold">{{ admin.fullName }}</td>
                      <td>{{ admin.email }}</td>
                      <td>{{ admin.mobileNumber }}</td>
                      <td><span class="nice-badge-success">Active</span></td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- TAB: ALL TRANSACTIONS -->
          <div v-if="currentTab === 'transactions'" class="transactions-pane">
            <div class="table-card">
              <div class="table-header-row">
                <h3>All Portal Transactions</h3>
                <div class="pagination-controls">
                  <button @click="changeTxnPage(-1)" :disabled="txnPage === 1" class="page-btn page-nav-btn">&larr; Prev</button>
                  <span class="page-num">Page {{ txnPage }}</span>
                  <button @click="changeTxnPage(1)" :disabled="allTransactions.length < 15" class="page-btn page-nav-btn">Next &rarr;</button>
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
                      <th>Date</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="txn in allTransactions" :key="txn.id">
                      <td>#{{ txn.id }}</td>
                      <td>#{{ txn.user_id }}</td>
                      <td><span class="lbl-wallet" :class="txn.wallet_type.toLowerCase()">{{ txn.wallet_type }}</span></td>
                      <td class="font-bold">{{ txn.amount }}</td>
                      <td>{{ txn.type }}</td>
                      <td>{{ txn.date }}</td>
                      <td><span class="nice-badge-success">{{ txn.status }}</span></td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- TAB: TEAMS VIEW -->
          <div v-if="currentTab === 'teams'" class="teams-pane">
            <div class="table-card" style="text-align: center; padding: 4rem;">
              <h2>👥 Downline Networks & Teams</h2>
              <p style="color: #94a3b8; margin-top: 1rem;">No active affiliate downline teams registered yet. User networks and downline trees will list here dynamically as users register partners.</p>
            </div>
          </div>

          <!-- TAB: BROADCAST NOTIFICATION -->
          <div v-if="currentTab === 'notifications'" class="notifications-pane">
            <div class="settings-nice-card">
              <h3>📢 Send Push Notification</h3>
              <p class="section-desc">Broadcast a message system-wide. Users will see it in their Android App dashboard.</p>
              
              <form @submit.prevent="handleSendNotification" class="settings-form">
                <div class="form-horizontal-grid">
                  <!-- Left Column -->
                  <div class="form-column">
                    <div class="nice-input-group">
                      <label for="notifTitle">Notification Title</label>
                      <input id="notifTitle" type="text" v-model="notifTitle" placeholder="e.g. Server Maintenance Notice" required />
                    </div>
                    <div style="margin-top: 1.5rem;">
                      <p style="font-size: 0.85rem; color: #64748b; line-height: 1.5;">This message is sent system-wide immediately. Please verify content for grammar and links before broadcasting to prevent user confusion.</p>
                    </div>
                  </div>
                  
                  <!-- Right Column -->
                  <div class="form-column">
                    <div class="nice-input-group">
                      <label for="notifMessage">Message Body</label>
                      <textarea id="notifMessage" v-model="notifMessage" rows="5" placeholder="Enter broadcast details..." style="padding: 0.65rem; border-radius: 6px; border: 1px solid #cbd5e1; background: #f8fafc;" required></textarea>
                    </div>
                    <div v-if="notifError" class="error-msg" style="margin-top: 1rem;">{{ notifError }}</div>
                    <div v-if="notifSuccess" class="success-msg" style="margin-top: 1rem;">{{ notifSuccess }}</div>
                    <button type="submit" :disabled="sendingNotif" class="nice-save-btn bg-blue-btn" style="width: 100%; margin-top: 1rem;">
                      <span v-if="sendingNotif">Broadcasting...</span>
                      <span v-else>Send Broadcast Notification</span>
                    </button>
                  </div>
                </div>
              </form>
            </div>
          </div>

          <!-- TAB: UI/UX MANAGEMENT (HORIZONTAL LAYOUT) -->
          <div v-if="currentTab === 'uiux'" class="uiux-pane">
            <div class="settings-nice-card">
              <h3>🎨 UI / UX Configuration</h3>
              <p class="section-desc">Manage marquee text announcements, landing page infinite banners, popup announcements, and support links.</p>
              
              <form @submit.prevent="handleSaveSystemSettings" class="settings-form">
                <div class="form-horizontal-grid">
                  <!-- Left Column -->
                  <div class="form-column">
                    <div class="nice-input-group">
                      <label for="marqueeText">Homepage Scrolling Marquee Text</label>
                      <textarea id="marqueeText" v-model="systemSettings.marquee_text" rows="4" placeholder="Enter scrolling notice..." style="padding: 0.65rem; border-radius: 6px; border: 1px solid #cbd5e1; background: #f8fafc;" required></textarea>
                    </div>

                    <!-- User Popup Banner Config (Item 33 & 34) -->
                    <div class="nice-input-group" style="margin-top: 1rem;">
                      <label for="popupBannerImg">User Panel Popup Banner Image URL</label>
                      <input id="popupBannerImg" type="text" v-model="systemSettings.popup_banner_image" placeholder="Paste popup banner image URL here..." />
                    </div>
                    <div class="nice-checkbox-group" style="margin-top: 0.5rem;">
                      <input id="popupBannerEnabled" type="checkbox" v-model="systemSettings.popup_banner_enabled_bool" />
                      <label for="popupBannerEnabled">Enable User Panel Popup Banner</label>
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.5rem;">
                      <label for="popupDisplayMode">Popup Display Control Mode</label>
                      <select id="popupDisplayMode" v-model="systemSettings.popup_banner_display_mode">
                        <option value="once">Show Once Per Session</option>
                        <option value="every_time">Show Every Time Screen Opens</option>
                      </select>
                    </div>

                    <!-- WhatsApp Links Config (Item 38 & 39) -->
                    <div class="nice-input-group" style="margin-top: 1rem;">
                      <label for="waSupportLink">WhatsApp Support Direct Link / Number</label>
                      <input id="waSupportLink" type="text" v-model="systemSettings.whatsapp_support_link" placeholder="e.g. https://wa.me/919876543210" />
                    </div>
                    <div class="nice-checkbox-group" style="margin-top: 0.5rem;">
                      <input id="waSupportEnabled" type="checkbox" v-model="systemSettings.whatsapp_support_enabled_bool" />
                      <label for="waSupportEnabled">Enable WhatsApp Support Link</label>
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.75rem;">
                      <label for="waGroupLink">Join Global Team WhatsApp Group Link</label>
                      <input id="waGroupLink" type="text" v-model="systemSettings.whatsapp_group_link" placeholder="e.g. https://chat.whatsapp.com/EarnFarmGlobalTeam" />
                    </div>
                    <div class="nice-checkbox-group" style="margin-top: 0.5rem;">
                      <input id="waGroupEnabled" type="checkbox" v-model="systemSettings.whatsapp_group_enabled_bool" />
                      <label for="waGroupEnabled">Enable Join Global Team WhatsApp Link</label>
                    </div>
                  </div>

                  <!-- Right Column -->
                  <div class="form-column">
                    <!-- Configured Marquee images List representation with delete triggers -->
                    <div class="nice-input-group">
                      <label>Currently Configured Marquee Banner Images</label>
                      <div v-if="marqueeImagesList.length === 0" style="color: #94a3b8; font-size: 0.85rem; padding: 0.5rem; background: #f8fafc; border-radius: 6px; border: 1px dashed #cbd5e1; text-align: center;">
                        No images configured. Queue a new URL below.
                      </div>
                      <div v-else class="marquee-images-config-list">
                        <div v-for="(imgUrl, idx) in marqueeImagesList" :key="idx" class="marquee-image-config-item">
                          <img :src="imgUrl" class="config-thumb" @error="$event.target.src='https://placehold.co/60x30?text=Error'" />
                          <span class="config-url" :title="imgUrl">{{ imgUrl }}</span>
                          <button type="button" @click="removeMarqueeImage(idx)" class="btn-delete-img">&times;</button>
                        </div>
                      </div>
                    </div>

                    <!-- Input block to append single image queue entries -->
                    <div class="nice-input-group" style="margin-top: 1rem;">
                      <label for="newImageUrl">Queue New Marquee Image URL</label>
                      <div style="display: flex; gap: 0.5rem;">
                        <input id="newImageUrl" type="text" v-model="newImageUrl" placeholder="Paste network image URL here..." style="flex: 1;" @keyup.enter="addMarqueeImage" />
                        <button type="button" @click="addMarqueeImage" class="btn-add-img">Add Image</button>
                      </div>
                      <span style="font-size: 0.75rem; color: #94a3b8; margin-top: 0.25rem;">Click 'Add Image' to append, then click 'Save' below to commit changes.</span>
                    </div>

                    <div v-if="systemError" class="error-msg" style="margin-top: 1rem;">{{ systemError }}</div>
                    <div v-if="systemSuccess" class="success-msg" style="margin-top: 1rem;">{{ systemSuccess }}</div>
                    <button type="submit" :disabled="loadingSystem" class="nice-save-btn bg-blue-btn" style="width: 100%; margin-top: 2rem;">
                      <span v-if="loadingSystem">Saving UI/UX Preferences...</span>
                      <span v-else>Save UI/UX Configurations</span>
                    </button>
                  </div>
                </div>
              </form>
            </div>
          </div>

          <!-- TAB: SHARED VARIABLES -->
          <div v-if="currentTab === 'shared_variable'" class="shared-variable-pane">
            <div class="settings-nice-card">
              <h3>🔗 Shared Variables & Global Controls</h3>
              <p class="section-desc">Manage system amounts, gateway keys, wallet rules, and master feature ON/OFF controls.</p>
              
              <form @submit.prevent="handleSaveSystemSettings" class="settings-form">
                <div class="form-horizontal-grid">
                  <!-- Left Column: Master Amounts & Gateway Settings -->
                  <div class="form-column">
                    <h4 style="font-size: 0.95rem; font-weight: 700; color: #1e293b; margin-bottom: 0.75rem;">💰 System Amounts & Parameters</h4>
                    <div class="nice-input-group">
                      <label for="minBalance">Minimum Wallet Balance (₹)</label>
                      <input id="minBalance" type="number" step="0.01" v-model="systemSettings.min_wallet_balance" placeholder="e.g. 50.00" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.75rem;">
                      <label for="joinAmount">Join / Activation Amount (₹)</label>
                      <input id="joinAmount" type="number" v-model="systemSettings.join_amount" placeholder="e.g. 1200" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.75rem;">
                      <label for="topUpAmount">Top-Up Amount (₹)</label>
                      <input id="topUpAmount" type="number" v-model="systemSettings.top_up_amount" placeholder="e.g. 1200" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.75rem;">
                      <label for="directIncome">Direct Sponsor Income (₹)</label>
                      <input id="directIncome" type="number" v-model="systemSettings.direct_income" placeholder="e.g. 300" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.75rem;">
                      <label for="levelPool">Level Pool Collection (₹)</label>
                      <input id="levelPool" type="number" v-model="systemSettings.level_pool" placeholder="e.g. 600" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.75rem;">
                      <label for="companyMaintenance">Company Maintenance (₹)</label>
                      <input id="companyMaintenance" type="number" v-model="systemSettings.company_maintenance" placeholder="e.g. 300" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.75rem;">
                      <label for="cycleSize">Cycle Size (Members)</label>
                      <input id="cycleSize" type="number" v-model="systemSettings.cycle_size" placeholder="e.g. 126" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.75rem;">
                      <label for="withdrawPct">Withdrawal Deduction (%)</label>
                      <input id="withdrawPct" type="number" v-model="systemSettings.withdrawal_percentage" placeholder="e.g. 15" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.75rem;">
                      <label for="minWithdraw">Minimum Withdrawal Amount (₹)</label>
                      <input id="minWithdraw" type="number" v-model="systemSettings.minimum_withdrawal" placeholder="e.g. 500" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.75rem;">
                      <label for="withdrawDays">Allowed Withdrawal Days</label>
                      <input id="withdrawDays" type="text" v-model="systemSettings.withdrawal_days" placeholder="e.g. Mon,Wed,Fri" required />
                    </div>
                  </div>

                  <!-- Right Column: Global ON/OFF Toggles & Payment Gateways -->
                  <div class="form-column">
                    <h4 style="font-size: 0.95rem; font-weight: 700; color: #1e293b; margin-bottom: 0.75rem;">🎛️ Master Global ON/OFF Controls</h4>
                    <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 0.85rem; display: flex; flex-direction: column; gap: 0.5rem; margin-bottom: 1rem;">
                      <div class="nice-checkbox-group">
                        <input id="regEnabled" type="checkbox" v-model="systemSettings.registration_enabled_bool" />
                        <label for="regEnabled">User Registration Flow ON/OFF</label>
                      </div>
                      <div class="nice-checkbox-group">
                        <input id="loginEnabled" type="checkbox" v-model="systemSettings.login_enabled_bool" />
                        <label for="loginEnabled">User Login Flow ON/OFF</label>
                      </div>
                      <div class="nice-checkbox-group">
                        <input id="otpEnabled" type="checkbox" v-model="systemSettings.otp_enabled_bool" />
                        <label for="otpEnabled">OTP & Forgot Password Flow ON/OFF</label>
                      </div>
                      <div class="nice-checkbox-group">
                        <input id="addMoneyEnabled" type="checkbox" v-model="systemSettings.add_money_enabled_bool" />
                        <label for="addMoneyEnabled">Add Money & Fund Request ON/OFF</label>
                      </div>
                      <div class="nice-checkbox-group">
                        <input id="withdrawEnabled" type="checkbox" v-model="systemSettings.withdrawal_enabled_bool" />
                        <label for="withdrawEnabled">Cash Out & Withdrawal Requests ON/OFF</label>
                      </div>
                      <div class="nice-checkbox-group">
                        <input id="captchaEnabled" type="checkbox" v-model="systemSettings.captcha_enabled_bool" />
                        <label for="captchaEnabled">CAPTCHA Verification Requirement ON/OFF</label>
                      </div>
                      <div class="nice-checkbox-group">
                        <input id="maintMode" type="checkbox" v-model="systemSettings.maintenance_mode_bool" />
                        <label for="maintMode">Enable Platform Maintenance Mode</label>
                      </div>
                    </div>

                    <h4 style="font-size: 0.95rem; font-weight: 700; color: #1e293b; margin-bottom: 0.75rem;">💳 Gateways & App Config</h4>
                    <div class="nice-input-group">
                      <label for="forceVersion">Force Android App Version</label>
                      <input id="forceVersion" type="text" v-model="systemSettings.force_update_version" placeholder="e.g. 1.0.0" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.5rem;">
                      <label for="scrizaMode">Scriza API Active Mode</label>
                      <select id="scrizaMode" v-model="systemSettings.scriza_api_mode">
                        <option value="simulation">Simulation Mode</option>
                        <option value="production">Production Live Mode</option>
                      </select>
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.5rem;">
                      <label for="razorpayMode">Razorpay Checkout Gateway</label>
                      <select id="razorpayMode" v-model="systemSettings.razorpay_api_mode">
                        <option value="test">Test Payments Mode</option>
                        <option value="live">Live Payments Mode</option>
                      </select>
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.5rem;">
                      <label for="razorpayKeyId">Razorpay Key ID</label>
                      <input id="razorpayKeyId" type="text" v-model="systemSettings.razorpay_key_id" placeholder="Enter Razorpay Key ID" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.5rem;">
                      <label for="razorpayKeySecret">Razorpay Key Secret</label>
                      <input id="razorpayKeySecret" type="password" v-model="systemSettings.razorpay_key_secret" placeholder="Enter Razorpay Key Secret" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.5rem;">
                      <label for="upiVpaId">Company UPI VPA ID</label>
                      <input id="upiVpaId" type="text" v-model="systemSettings.upi_vpa_id" placeholder="e.g. vp110064@okaxis" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 0.5rem;">
                      <label for="upiPayeeName">Company UPI Payee Name</label>
                      <input id="upiPayeeName" type="text" v-model="systemSettings.upi_payee_name" placeholder="e.g. EarnFarm" required />
                    </div>

                    <div v-if="systemError" class="error-msg" style="margin-top: 1rem;">{{ systemError }}</div>
                    <div v-if="systemSuccess" class="success-msg" style="margin-top: 1rem;">{{ systemSuccess }}</div>
                    <button type="submit" :disabled="loadingSystem" class="nice-save-btn bg-blue-btn" style="width: 100%; margin-top: 1.5rem;">
                      <span v-if="loadingSystem">Saving System Preferences...</span>
                      <span v-else>Save System Preferences</span>
                    </button>
                  </div>
                </div>
              </form>
            </div>
          </div>

          <!-- TAB: CHANGE PASSWORD -->
          <div v-if="currentTab === 'settings'" class="settings-pane">
            <div class="settings-nice-card">
              <h3>Change Admin Password</h3>
              <p class="section-desc">Change the password used to access the administrator dashboard.</p>
              
              <form @submit.prevent="handleChangePassword" class="settings-form">
                <div class="form-horizontal-grid">
                  <!-- Left Column -->
                  <div class="form-column">
                    <div class="nice-input-group">
                      <label for="oldPassword">Current Password</label>
                      <input id="oldPassword" type="password" v-model="oldPassword" placeholder="Enter current password" required />
                    </div>
                    <div class="nice-input-group" style="margin-top: 1rem;">
                      <label for="newPassword">New Password</label>
                      <input id="newPassword" type="password" v-model="newPassword" placeholder="Enter new password" required />
                    </div>
                  </div>

                  <!-- Right Column -->
                  <div class="form-column">
                    <div class="nice-input-group">
                      <label for="confirmPassword">Confirm New Password</label>
                      <input id="confirmPassword" type="password" v-model="confirmPassword" placeholder="Confirm new password" required />
                    </div>
                    <div v-if="passwordError" class="error-msg" style="margin-top: 1rem;">{{ passwordError }}</div>
                    <div v-if="passwordSuccess" class="success-msg" style="margin-top: 1rem;">{{ passwordSuccess }}</div>
                    <button type="submit" :disabled="loadingPassword" class="nice-save-btn" style="width: 100%; margin-top: 2rem;">
                      <span v-if="loadingPassword">Updating password...</span>
                      <span v-else>Update Password</span>
                    </button>
                  </div>
                </div>
              </form>
            </div>
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
      currentTab: 'dashboard',
      adminEmail: localStorage.getItem('adminEmail') || 'haris@gmail.com',
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
      userPage: 1,
      txnPage: 1,
      loading: true,
      error: '',
      gatewayStatus: {
        database: 'Checking...',
        app_api: 'Checking...',
        scriza_api: 'Checking...',
        razorpay_gateway: 'Checking...'
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
      newImageUrl: '',
      marqueeImagesList: [],
      systemSettings: {
        min_wallet_balance: '50.00',
        maintenance_mode: 'false',
        maintenance_mode_bool: false,
        force_update_version: '1.0.0',
        scriza_api_mode: 'simulation',
        razorpay_api_mode: 'test',
        razorpay_key_id: '',
        razorpay_key_secret: '',
        marquee_text: '',
        marquee_images: '',
        join_amount: '1200',
        top_up_amount: '1200',
        direct_income: '300',
        level_pool: '600',
        company_maintenance: '300',
        cycle_size: '126',
        withdrawal_percentage: '15',
        minimum_withdrawal: '500',
        withdrawal_days: 'Mon,Wed,Fri',
        upi_vpa_id: 'vp110064@okaxis',
        upi_payee_name: 'EarnFarm',
        whatsapp_support_link: 'https://wa.me/919876543210',
        whatsapp_support_enabled_bool: true,
        whatsapp_group_link: 'https://chat.whatsapp.com/EarnFarmGlobalTeam',
        whatsapp_group_enabled_bool: true,
        popup_banner_image: 'https://placehold.co/600x400/0052cc/ffffff?text=Special+Promotion+Banner',
        popup_banner_enabled_bool: true,
        popup_banner_display_mode: 'once',
        registration_enabled_bool: true,
        login_enabled_bool: true,
        otp_enabled_bool: true,
        add_money_enabled_bool: true,
        withdrawal_enabled_bool: true,
        captcha_enabled_bool: true
      }
    }
  },
  computed: {
    tabTitle() {
      switch (this.currentTab) {
        case 'dashboard': return 'Dashboard Overview';
        case 'users': return 'Mobile Portal Users';
        case 'requests': return 'Deposit Requests Approval';
        case 'transactions': return 'All Portal Transactions';
        case 'teams': return 'Downline Affiliate Networks';
        case 'notifications': return 'Broadcast Notification';
        case 'uiux': return 'UI / UX Manager';
        case 'shared_variable': return 'Shared System Variables';
        case 'admins': return 'System Administrator Staff';
        case 'settings': return 'Change Password';
        default: return 'Management Console';
      }
    },
    pendingRequestsCount() {
      return this.fundRequests.filter(r => r.status === 'PENDING').length;
    },
    isGlobalTab() {
      return ['notifications', 'uiux', 'shared_variable', 'admins'].includes(this.currentTab);
    }
  },
  watch: {
    currentTab(newTab) {
      if (newTab === 'dashboard') {
        if (this.$route.path !== '/admin-dashboard') this.$router.push('/admin-dashboard');
        this.fetchDashboardData();
        this.checkGatewayStatus();
      } else if (newTab === 'users') {
        if (this.$route.path !== '/admin-dashboard') this.$router.push('/admin-dashboard');
        this.fetchUsers();
      } else if (newTab === 'requests') {
        if (this.$route.path !== '/admin-dashboard') this.$router.push('/admin-dashboard');
        this.fetchFundRequests();
      } else if (newTab === 'transactions') {
        if (this.$route.path !== '/admin-dashboard') this.$router.push('/admin-dashboard');
        this.fetchAllTransactions();
      } else if (newTab === 'admins') {
        if (this.$route.path !== '/admin-dashboard') this.$router.push('/admin-dashboard');
        this.fetchAdminsList();
      } else if (newTab === 'settings') {
        if (this.$route.path !== '/admin-settings') this.$router.push('/admin-settings');
      } else if (newTab === 'uiux' || newTab === 'shared_variable') {
        if (this.$route.path !== '/admin-settings') this.$router.push('/admin-settings');
        this.fetchSystemSettings();
      }
    },
    '$route.path'(newPath) {
      this.syncTabFromPath();
    }
  },
  mounted() {
    this.syncTabFromPath();
    this.fetchDashboardData();
    this.checkGatewayStatus();
    this.fetchFundRequests();
  },
  methods: {
    syncTabFromPath() {
      if (this.$route.path === '/admin-settings' && !['uiux', 'shared_variable'].includes(this.currentTab)) {
        this.currentTab = 'settings';
      }
    },
    addMarqueeImage() {
      if (!this.newImageUrl.trim()) return;
      const urls = this.newImageUrl.split(',').map(s => s.trim()).filter(Boolean);
      this.marqueeImagesList.push(...urls);
      this.newImageUrl = '';
    },
    removeMarqueeImage(index) {
      this.marqueeImagesList.splice(index, 1);
    },
    async checkGatewayStatus() {
      const token = localStorage.getItem('adminToken');
      if (!token) return;
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/gateway-status`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (!response.ok) throw new Error();
        this.gatewayStatus = await response.json();
      } catch (e) {
        this.gatewayStatus = {
          database: 'Offline',
          app_api: 'Offline',
          scriza_api: 'Offline',
          razorpay_gateway: 'Offline'
        };
      }
    },
    async fetchDashboardData() {
      this.loading = true;
      this.error = '';
      const token = localStorage.getItem('adminToken');
      if (!token) {
        this.$router.push('/admin-login');
        return;
      }
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/dashboard`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        const data = await response.json();
        if (!response.ok) {
          throw new Error(data.error || 'Failed to load dashboard data');
        }
        this.stats = data.stats;
        this.transactions = data.transactions;
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },
    async fetchUsers() {
      this.loading = true;
      const token = localStorage.getItem('adminToken');
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/dashboard?page=${this.userPage}&limit=10`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        const data = await response.json();
        this.users = data.users;
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },
    async fetchAllTransactions() {
      this.loading = true;
      const token = localStorage.getItem('adminToken');
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/transactions?page=${this.txnPage}&limit=15`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        this.allTransactions = await response.json();
      } catch (e) {
        console.error(e);
      } finally {
        this.loading = false;
      }
    },
    async fetchFundRequests() {
      const token = localStorage.getItem('adminToken');
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/fund-requests`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        this.fundRequests = await response.json();
      } catch (err) {
        console.error(err);
      }
    },
    async fetchAdminsList() {
      this.loading = true;
      const token = localStorage.getItem('adminToken');
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/list`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        this.adminsList = await response.json();
      } catch (e) {
        console.error(e);
      } finally {
        this.loading = false;
      }
    },
    async fetchSystemSettings() {
      const token = localStorage.getItem('adminToken');
      if (!token) return;
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/settings`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (!response.ok) throw new Error('Failed to load settings');
        const data = await response.json();
        this.systemSettings.min_wallet_balance = data.min_wallet_balance || '50.00';
        this.systemSettings.force_update_version = data.force_update_version || '1.0.0';
        this.systemSettings.scriza_api_mode = data.scriza_api_mode || 'simulation';
        this.systemSettings.razorpay_api_mode = data.razorpay_api_mode || 'test';
        this.systemSettings.razorpay_key_id = data.razorpay_key_id || '';
        this.systemSettings.razorpay_key_secret = data.razorpay_key_secret || '';
        this.systemSettings.marquee_text = data.marquee_text || '';
        this.systemSettings.marquee_images = data.marquee_images || '';
        this.systemSettings.maintenance_mode = data.maintenance_mode || 'false';
        this.systemSettings.maintenance_mode_bool = data.maintenance_mode === 'true';
        this.systemSettings.join_amount = data.join_amount || '1200';
        this.systemSettings.top_up_amount = data.top_up_amount || '1200';
        this.systemSettings.direct_income = data.direct_income || '300';
        this.systemSettings.level_pool = data.level_pool || '600';
        this.systemSettings.company_maintenance = data.company_maintenance || '300';
        this.systemSettings.cycle_size = data.cycle_size || '126';
        this.systemSettings.withdrawal_percentage = data.withdrawal_percentage || '15';
        this.systemSettings.minimum_withdrawal = data.minimum_withdrawal || '500';
        this.systemSettings.withdrawal_days = data.withdrawal_days || 'Mon,Wed,Fri';
        this.systemSettings.upi_vpa_id = data.upi_vpa_id || 'vp110064@okaxis';
        this.systemSettings.upi_payee_name = data.upi_payee_name || 'EarnFarm';

        this.systemSettings.whatsapp_support_link = data.whatsapp_support_link || 'https://wa.me/919876543210';
        this.systemSettings.whatsapp_support_enabled_bool = data.whatsapp_support_enabled !== 'false';
        this.systemSettings.whatsapp_group_link = data.whatsapp_group_link || 'https://chat.whatsapp.com/EarnFarmGlobalTeam';
        this.systemSettings.whatsapp_group_enabled_bool = data.whatsapp_group_enabled !== 'false';
        this.systemSettings.popup_banner_image = data.popup_banner_image || '';
        this.systemSettings.popup_banner_enabled_bool = data.popup_banner_enabled === 'true';
        this.systemSettings.popup_banner_display_mode = data.popup_banner_display_mode || 'once';

        this.systemSettings.registration_enabled_bool = data.registration_enabled !== 'false';
        this.systemSettings.login_enabled_bool = data.login_enabled !== 'false';
        this.systemSettings.otp_enabled_bool = data.otp_enabled !== 'false';
        this.systemSettings.add_money_enabled_bool = data.add_money_enabled !== 'false';
        this.systemSettings.withdrawal_enabled_bool = data.withdrawal_enabled !== 'false';
        this.systemSettings.captcha_enabled_bool = data.captcha_enabled !== 'false';

        this.marqueeImagesList = (data.marquee_images || '').split(',').map(s => s.trim()).filter(Boolean);
      } catch (err) {
        console.error(err);
      }
    },
    async handleSaveSystemSettings() {
      this.systemError = '';
      this.systemSuccess = '';
      this.loadingSystem = true;
      const token = localStorage.getItem('adminToken');
      this.systemSettings.maintenance_mode = this.systemSettings.maintenance_mode_bool ? 'true' : 'false';
      this.systemSettings.marquee_images = this.marqueeImagesList.join(',');

      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/settings`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({
            min_wallet_balance: this.systemSettings.min_wallet_balance,
            maintenance_mode: this.systemSettings.maintenance_mode,
            force_update_version: this.systemSettings.force_update_version,
            scriza_api_mode: this.systemSettings.scriza_api_mode,
            razorpay_api_mode: this.systemSettings.razorpay_api_mode,
            razorpay_key_id: this.systemSettings.razorpay_key_id,
            razorpay_key_secret: this.systemSettings.razorpay_key_secret,
            marquee_text: this.systemSettings.marquee_text,
            marquee_images: this.systemSettings.marquee_images,
            join_amount: this.systemSettings.join_amount,
            top_up_amount: this.systemSettings.top_up_amount,
            direct_income: this.systemSettings.direct_income,
            level_pool: this.systemSettings.level_pool,
            company_maintenance: this.systemSettings.company_maintenance,
            cycle_size: this.systemSettings.cycle_size,
            withdrawal_percentage: this.systemSettings.withdrawal_percentage,
            minimum_withdrawal: this.systemSettings.minimum_withdrawal,
            withdrawal_days: this.systemSettings.withdrawal_days,
            upi_vpa_id: this.systemSettings.upi_vpa_id,
            upi_payee_name: this.systemSettings.upi_payee_name,
            whatsapp_support_link: this.systemSettings.whatsapp_support_link,
            whatsapp_support_enabled: this.systemSettings.whatsapp_support_enabled_bool ? 'true' : 'false',
            whatsapp_group_link: this.systemSettings.whatsapp_group_link,
            whatsapp_group_enabled: this.systemSettings.whatsapp_group_enabled_bool ? 'true' : 'false',
            popup_banner_image: this.systemSettings.popup_banner_image,
            popup_banner_enabled: this.systemSettings.popup_banner_enabled_bool ? 'true' : 'false',
            popup_banner_display_mode: this.systemSettings.popup_banner_display_mode,
            registration_enabled: this.systemSettings.registration_enabled_bool ? 'true' : 'false',
            login_enabled: this.systemSettings.login_enabled_bool ? 'true' : 'false',
            otp_enabled: this.systemSettings.otp_enabled_bool ? 'true' : 'false',
            add_money_enabled: this.systemSettings.add_money_enabled_bool ? 'true' : 'false',
            withdrawal_enabled: this.systemSettings.withdrawal_enabled_bool ? 'true' : 'false',
            captcha_enabled: this.systemSettings.captcha_enabled_bool ? 'true' : 'false'
          })
        });
        const data = await response.json();
        if (!response.ok) throw new Error(data.error || 'Failed to save settings');
        this.systemSuccess = 'System configurations saved successfully.';
      } catch (err) {
        this.systemError = err.message;
      } finally {
        this.loadingSystem = false;
      }
    },
    async handleChangePassword() {
      this.passwordError = '';
      this.passwordSuccess = '';
      if (this.newPassword !== this.confirmPassword) {
        this.passwordError = 'New passwords do not match';
        return;
      }
      this.loadingPassword = true;
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
        if (!response.ok) throw new Error(data.error || 'Failed to update password');
        this.passwordSuccess = 'Admin password has been changed successfully.';
        this.oldPassword = '';
        this.newPassword = '';
        this.confirmPassword = '';
      } catch (err) {
        this.passwordError = err.message;
      } finally {
        this.loadingPassword = false;
      }
    },
    async handleSendNotification() {
      this.notifError = '';
      this.notifSuccess = '';
      this.sendingNotif = true;
      const token = localStorage.getItem('adminToken');
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/notifications`, {
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
    selectUser(user) {
      this.selectedUser = user;
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
          body: JSON.stringify({ approve })
        });
        const data = await response.json();
        if (!response.ok) {
          alert(data.error || 'Failed to update request');
          return;
        }
        alert(data.message);
        this.fetchFundRequests();
        this.fetchDashboardData();
      } catch (err) {
        alert(err.message);
      }
    },
    changeUserPage(delta) {
      this.userPage += delta;
      this.fetchUsers();
    },
    changeTxnPage(delta) {
      this.txnPage += delta;
      this.fetchAllTransactions();
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
.admin-layout {
  display: flex;
  min-height: 100vh;
  background: #f4f6f9;
  font-family: 'Inter', system-ui, sans-serif;
  color: #3e5569;
}

/* Sidebar styling (Classic Dark theme) */
.sidebar {
  width: 250px;
  background: #1e283d;
  color: #a3afc7;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  position: sticky;
  top: 0;
  height: 100vh;
}

.sidebar-brand {
  height: 64px;
  display: flex;
  align-items: center;
  padding: 0 1.5rem;
  background: rgba(0, 0, 0, 0.15);
  gap: 0.75rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.brand-icon {
  background: #2563eb;
  color: white;
  width: 32px;
  height: 32px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 900;
  font-size: 1.2rem;
}

.brand-text {
  font-weight: 800;
  color: white;
  font-size: 1rem;
  letter-spacing: 0.5px;
}

.sidebar-menu {
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  flex: 1;
  overflow-y: auto;
}

.menu-label {
  font-size: 0.7rem;
  font-weight: bold;
  color: #62728c;
  padding: 0.75rem 1rem 0.25rem;
  letter-spacing: 0.5px;
}

.menu-item {
  background: transparent;
  border: none;
  color: #a3afc7;
  padding: 0.7rem 1rem;
  border-radius: 6px;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-weight: 600;
  font-size: 0.9rem;
  cursor: pointer;
  width: 100%;
  text-align: left;
  transition: all 0.2s;
}

.menu-item:hover, .menu-item.active {
  color: white;
  background: rgba(255, 255, 255, 0.05);
}

.sidebar-footer {
  padding: 1.5rem 1rem;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  background: #1e283d;
}

.logout-btn {
  background: rgba(239, 68, 68, 0.1);
  color: #f87171;
  border: 1px solid rgba(239, 68, 68, 0.2);
  width: 100%;
  padding: 0.65rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: bold;
  transition: all 0.2s;
}

.logout-btn:hover {
  background: #ef4444;
  color: white;
}

/* Main Section Content */
.main-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

/* Topbar */
.topbar {
  height: 64px;
  background: white;
  box-shadow: 0 1px 10px rgba(0, 0, 0, 0.03);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 2rem;
  box-sizing: border-box;
}

.topbar-left-placeholder {
  flex: 1;
}

.topbar-actions {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.action-icon {
  font-size: 1.35rem;
  cursor: pointer;
  opacity: 0.85;
  transition: transform 0.2s;
}

.action-icon:hover {
  transform: scale(1.1);
}

.topbar-logout-btn {
  background: transparent;
  border: 1px solid #cbd5e1;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  font-weight: bold;
  font-size: 0.85rem;
  color: #ef4444;
  cursor: pointer;
  transition: all 0.2s;
}

.topbar-logout-btn:hover {
  background: #ef4444;
  color: white;
  border-color: #ef4444;
}

.admin-profile-badge {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #cbd5e1;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
  color: #1e293d;
  font-size: 0.85rem;
}

.profile-name {
  font-size: 0.85rem;
  font-weight: bold;
  color: #3e5569;
}

/* Content Body */
.content-body {
  padding: 2rem;
  overflow-y: auto;
  flex: 1;
}

.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.content-header h2 {
  font-weight: 800;
  font-size: 1.35rem;
  color: #3e5569;
  margin: 0;
}

.breadcrumbs {
  font-size: 0.8rem;
  color: #94a3b8;
}

/* Global Warning Banner */
.global-warning-banner {
  background: #fee2e2;
  border: 1px solid #fca5a5;
  color: #b91c1c;
  padding: 1rem;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 700;
  margin-bottom: 1.5rem;
  line-height: 1.4;
}

/* Upgraded Operational status cards layout */
.op-status-section-new {
  margin-bottom: 2rem;
}

.op-card-header-new {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.op-card-header-new h4 {
  margin: 0;
  font-size: 1rem;
  font-weight: 800;
  color: #3e5569;
}

.refresh-op-btn-new {
  background: #fff;
  border: 1px solid #cbd5e1;
  font-size: 0.75rem;
  font-weight: bold;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.15s;
}

.refresh-op-btn-new:hover {
  background: #f1f5f9;
}

.op-grid-new {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1rem;
}

.op-item-new {
  background: white;
  padding: 1.25rem;
  border-radius: 8px;
  box-shadow: 0 1px 15px rgba(0,0,0,0.02);
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  box-sizing: border-box;
}

.op-item-new.green-border {
  border-left: 4px solid #10b981;
}

.op-item-new.orange-border {
  border-left: 4px solid #f59e0b;
}

.op-lbl {
  font-size: 0.75rem;
  color: #64748b;
  font-weight: bold;
  text-transform: uppercase;
}

.op-val {
  font-size: 0.95rem;
  font-weight: 800;
  color: #3e5569;
}

/* Nice Stats Card (underlined accent style) */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.nice-stat-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 15px rgba(0,0,0,0.02);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.stat-body {
  padding: 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  box-sizing: border-box;
}

.stat-left {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  flex: 1;
}

.stat-card-title {
  font-size: 0.75rem;
  font-weight: bold;
  color: #64748b;
  text-transform: uppercase;
  white-space: nowrap;
}

.icon-indicator {
  font-size: 1.25rem;
}

.stat-card-val {
  font-size: 1.65rem;
  font-weight: 800;
  color: #3e5569;
  text-align: right;
  white-space: nowrap;
  padding-left: 0.5rem;
}

.progress-bar {
  height: 4px;
  width: 100%;
}

.bg-blue { background: #3b82f6; }
.bg-green { background: #10b981; }
.bg-purple { background: #8b5cf6; }
.bg-orange { background: #ff7849; }

.border-blue { border-top: 3px solid #3b82f6; }
.border-green { border-top: 3px solid #10b981; }
.border-purple { border-top: 3px solid #8b5cf6; }
.border-orange { border-top: 3px solid #ff7849; }

/* Analytics grid */
.analytics-grid {
  display: grid;
  grid-template-columns: 0.9fr 1.3fr 0.8fr;
  gap: 1.5rem;
  margin-bottom: 2rem;
}

@media (max-width: 1024px) {
  .analytics-grid {
    grid-template-columns: 1fr;
  }
}

.anal-card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 1px 15px rgba(0,0,0,0.02);
}

.anal-card h3 {
  font-size: 1rem;
  margin: 0 0 1.25rem;
  font-weight: 800;
  color: #3e5569;
}

/* Donut Chart Campaign */
.donut-wrapper {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  height: 120px;
}

.donut-center {
  position: absolute;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.donut-val {
  font-size: 1.25rem;
  font-weight: 900;
  color: #3e5569;
}

.donut-lbl {
  font-size: 0.65rem;
  color: #94a3b8;
  text-transform: uppercase;
}

.donut-labels {
  display: flex;
  justify-content: space-around;
  margin-top: 1.5rem;
  font-size: 0.75rem;
  font-weight: bold;
}

.lbl-item {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  display: inline-block;
}

/* Sales ratio line chart */
.ratio-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.ratio-legends {
  display: flex;
  gap: 1rem;
  font-size: 0.75rem;
  font-weight: bold;
}

.legend {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.line-dot {
  width: 12px;
  height: 3px;
  display: inline-block;
  border-radius: 2px;
}

.bg-grey { background: #cbd5e1; }

.line-chart-wrapper {
  margin-top: 1rem;
}

/* Weather & users widget */
.weather-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #f1f5f9;
  padding-bottom: 1rem;
  margin-bottom: 1rem;
}

.weather-header h4 {
  margin: 0 0 0.15rem;
  font-weight: 800;
}

.weather-header span {
  font-size: 0.75rem;
  color: #94a3b8;
}

.users-rate-box {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.users-rate-header span {
  font-size: 0.75rem;
  color: #94a3b8;
  font-weight: bold;
}

.users-rate-header h3 {
  margin: 0.15rem 0 0;
  font-size: 1.35rem;
  font-weight: 900;
}

.green-text { color: #10b981; }
.blue-text { color: #0052cc; }

.users-splits {
  display: flex;
  justify-content: space-between;
  border-top: 1px solid #f1f5f9;
  padding-top: 0.75rem;
}

.users-splits div {
  display: flex;
  flex-direction: column;
}

.users-splits span {
  font-size: 0.65rem;
  color: #94a3b8;
}

/* Bottom Analytics Grid */
.bottom-analytics {
  display: grid;
  grid-template-columns: 1.3fr 0.7fr;
  gap: 1.5rem;
}

@media (max-width: 1024px) {
  .bottom-analytics {
    grid-template-columns: 1fr;
  }
}

/* Region sales chart */
.bar-chart-container {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.region-stats {
  display: flex;
  justify-content: space-around;
  border-top: 1px solid #f1f5f9;
  padding-top: 0.75rem;
  font-size: 0.8rem;
}

.region-stats div {
  display: flex;
  flex-direction: column;
  align-items: center;
}

/* Nice tables styles */
.table-container {
  width: 100%;
  overflow-x: auto;
}

.nice-table {
  width: 100%;
  border-collapse: collapse;
}

.nice-table th, .nice-table td {
  padding: 0.85rem 1rem;
  border-bottom: 1px solid #f1f5f9;
  font-size: 0.85rem;
}

.nice-table th {
  color: #94a3b8;
  font-weight: bold;
  text-transform: uppercase;
  font-size: 0.75rem;
  text-align: left;
}

.nice-table td {
  color: #3e5569;
}

.clickable-row {
  cursor: pointer;
}

.clickable-row:hover {
  background: #f8fafc;
}

.lbl-wallet {
  padding: 0.2rem 0.4rem;
  border-radius: 4px;
  font-size: 0.7rem;
  font-weight: bold;
}

.lbl-wallet.main {
  background: #e6f0ff;
  color: #0052cc;
}

.lbl-wallet.fund {
  background: #e8f5e9;
  color: #2e7d32;
}

.nice-badge-success {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: bold;
}

/* Slide-Over Drawer with ENABLED Scrolling */
.slide-over-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(15, 23, 42, 0.4);
  backdrop-filter: blur(4px);
  z-index: 1000;
  display: flex;
  justify-content: flex-end;
}

.slide-over {
  width: 100%;
  max-width: 400px;
  background: white;
  height: 100vh;
  box-shadow: -10px 0 30px rgba(0,0,0,0.1);
  display: flex;
  flex-direction: column;
}

.slide-header {
  padding: 1.5rem;
  border-bottom: 1px solid #f1f5f9;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-shrink: 0;
}

.close-btn {
  background: none;
  border: none;
  font-size: 2rem;
  color: #64748b;
  cursor: pointer;
}

.slide-body {
  padding: 2rem 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  flex: 1;
  overflow-y: auto;
}

.profile-avatar-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  flex-shrink: 0;
}

.large-avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: #0052cc;
  color: white;
  font-weight: bold;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
}

.status-lbl {
  padding: 0.2rem 0.6rem;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: bold;
}

.status-lbl.green {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
}

.wallets-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  flex-shrink: 0;
}

.wallet-stat {
  padding: 1rem;
  border-radius: 10px;
  color: white;
}

.wallet-stat span {
  font-size: 0.65rem;
  opacity: 0.8;
}

.wallet-stat h4 {
  margin: 0.25rem 0 0;
  font-size: 1.1rem;
  font-weight: 800;
}

.bg-blue-grad {
  background: linear-gradient(135deg, #0d47a1 0%, #1976d2 100%);
}

.bg-purple-grad {
  background: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 100%);
}

.details-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  border-top: 1px solid #f1f5f9;
  padding-top: 1rem;
}

.details-list .item {
  display: flex;
  justify-content: space-between;
  font-size: 0.85rem;
}

.details-list span {
  color: #94a3b8;
  font-weight: bold;
}

.details-list strong {
  color: #3e5569;
}

.action-view-btn {
  background: #e6f0ff;
  color: #0052cc;
  border: none;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: bold;
  cursor: pointer;
}

/* Visibility enhancements for Pagination controls */
.table-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.page-nav-btn {
  background: #2563eb !important;
  color: white !important;
  border: 1px solid #1d4ed8 !important;
  padding: 0.45rem 1rem !important;
  border-radius: 6px !important;
  font-size: 0.85rem !important;
  font-weight: 800 !important;
  cursor: pointer !important;
  box-shadow: 0 2px 4px rgba(0,0,0,0.08);
  transition: background 0.15s, opacity 0.15s;
}

.page-nav-btn:hover {
  background: #1d4ed8 !important;
}

.page-nav-btn:disabled {
  background: #cbd5e1 !important;
  color: #94a3b8 !important;
  border-color: #e2e8f0 !important;
  cursor: not-allowed !important;
  box-shadow: none;
}

.page-num {
  font-size: 0.85rem;
  font-weight: bold;
  color: #3e5569;
}

.btn-approve {
  background: #10b981;
  color: white;
  border: none;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
}

.btn-reject {
  background: #ef4444;
  color: white;
  border: none;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
}

.loading-box {
  padding: 4rem;
  text-align: center;
  background: white;
  border-radius: 8px;
  font-weight: bold;
}

/* Horizontal Grid forms styling */
.form-horizontal-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2.5rem;
  width: 100%;
}

@media (max-width: 768px) {
  .form-horizontal-grid {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }
}

.form-column {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.settings-nice-card {
  background: white;
  border-radius: 8px;
  padding: 2.5rem;
  box-shadow: 0 1px 15px rgba(0,0,0,0.02);
  border-top: 3px solid #3e5569;
  box-sizing: border-box;
}

.settings-nice-card h3 {
  font-size: 1.15rem;
  font-weight: 800;
  color: #3e5569;
  margin: 0 0 0.5rem;
}

.section-desc {
  color: #94a3b8;
  font-size: 0.85rem;
  margin-bottom: 2rem;
}

.settings-form {
  width: 100%;
}

.nice-input-group {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.nice-input-group label {
  font-size: 0.8rem;
  font-weight: bold;
  color: #64748b;
}

.nice-input-group input,
.nice-input-group select {
  padding: 0.65rem 0.85rem;
  border-radius: 6px;
  border: 1px solid #cbd5e1;
  font-family: inherit;
  font-size: 0.9rem;
  background: #f8fafc;
  color: #3e5569;
}

.nice-checkbox-group {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0.5rem 0;
}

.nice-checkbox-group input {
  width: 16px;
  height: 16px;
  cursor: pointer;
}

.nice-checkbox-group label {
  font-size: 0.85rem;
  font-weight: bold;
  color: #64748b;
  cursor: pointer;
}

.nice-save-btn {
  background: #1e283d;
  color: white;
  border: none;
  padding: 0.75rem;
  border-radius: 6px;
  font-weight: bold;
  cursor: pointer;
  transition: opacity 0.2s;
  font-size: 0.85rem;
}

.nice-save-btn:hover {
  opacity: 0.9;
}

.nice-save-btn.bg-blue-btn {
  background: #2563eb;
}

.error-msg {
  color: #ef4444;
  background: rgba(239, 68, 68, 0.05);
  border: 1px solid rgba(239, 68, 68, 0.1);
  padding: 0.6rem;
  border-radius: 6px;
  font-size: 0.8rem;
  font-weight: bold;
}

.success-msg {
  color: #10b981;
  background: rgba(16, 185, 129, 0.05);
  border: 1px solid rgba(16, 185, 129, 0.1);
  padding: 0.6rem;
  border-radius: 6px;
  font-size: 0.8rem;
  font-weight: bold;
}

/* Custom configured marquee images styling */
.marquee-images-config-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-height: 220px;
  overflow-y: auto;
  border: 1px solid #cbd5e1;
  border-radius: 6px;
  padding: 0.5rem;
  background: #f8fafc;
}

.marquee-image-config-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  background: white;
  padding: 0.4rem 0.6rem;
  border-radius: 4px;
  border: 1px solid #e2e8f0;
}

.config-thumb {
  width: 50px;
  height: 28px;
  object-fit: contain;
  border-radius: 3px;
  background: #f1f5f9;
  border: 1px solid #cbd5e1;
}

.config-url {
  flex: 1;
  font-size: 0.8rem;
  color: #3e5569;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.btn-delete-img {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  border: none;
  border-radius: 4px;
  width: 24px;
  height: 24px;
  font-weight: bold;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.15s;
}

.btn-delete-img:hover {
  background: #ef4444;
  color: white;
}

.btn-add-img {
  background: #2563eb;
  color: white;
  border: none;
  border-radius: 6px;
  padding: 0 1.25rem;
  font-weight: bold;
  font-size: 0.85rem;
  cursor: pointer;
  transition: opacity 0.15s;
}

.btn-add-img:hover {
  opacity: 0.9;
}

@media (max-width: 768px) {
  .admin-layout {
    flex-direction: column;
    width: 100%;
  }
  .sidebar {
    width: 100%;
    height: auto;
    position: relative;
  }
  .sidebar-menu {
    flex-direction: row;
    overflow-x: auto;
    padding: 0.5rem;
    white-space: nowrap;
  }
  .content-body {
    padding: 1rem;
    width: 100%;
    box-sizing: border-box;
  }
  .topbar {
    padding: 0 1rem;
    width: 100%;
    box-sizing: border-box;
  }
}
</style>
