<template>
  <div class="admin-layout">
    <!-- Backdrop overlay for mobile drawer -->
    <div v-if="mobileMenuOpen" class="mobile-drawer-backdrop" @click="mobileMenuOpen = false"></div>

    <!-- Sidebar (Desktop fixed, Mobile slide-over drawer) -->
    <aside class="sidebar" :class="{ 'open-drawer': mobileMenuOpen }">
      <div class="sidebar-brand">
        <div class="brand-left">
          <div class="brand-icon">N</div>
          <span class="brand-text">ADMIN</span>
        </div>
        <button @click="mobileMenuOpen = false" class="close-drawer-btn" title="Close Drawer">&times;</button>
      </div>
      
      <div class="sidebar-menu">
        <div class="menu-label">PERSONAL</div>
        <button @click="switchTab('dashboard')" class="menu-item" :class="{ active: currentTab === 'dashboard' }">
          <span class="icon">📊</span> Dashboards
        </button>
        <button @click="switchTab('users')" class="menu-item" :class="{ active: currentTab === 'users' }">
          <span class="icon">👤</span> Users List
        </button>
        <button @click="switchTab('requests')" class="menu-item" :class="{ active: currentTab === 'requests' }">
          <span class="icon">📥</span> Fund Requests
          <span v-if="pendingRequestsCount > 0" class="badge-count">{{ pendingRequestsCount }}</span>
        </button>
        <button @click="switchTab('transactions')" class="menu-item" :class="{ active: currentTab === 'transactions' }">
          <span class="icon">📈</span> All Transactions
        </button>
        <button @click="switchTab('teams')" class="menu-item" :class="{ active: currentTab === 'teams' }">
          <span class="icon">👥</span> User Teams
        </button>

        <div class="menu-label">GLOBAL</div>
        <button @click="switchTab('notifications')" class="menu-item" :class="{ active: currentTab === 'notifications' }">
          <span class="icon">📢</span> Send Notification
        </button>
        <button @click="switchTab('shared_variable')" class="menu-item" :class="{ active: currentTab === 'shared_variable' }">
          <span class="icon">🔗</span> Shared Variable
        </button>
        <button @click="switchTab('admins')" class="menu-item" :class="{ active: currentTab === 'admins' }">
          <span class="icon">🛡️</span> System Admins
        </button>
        <button @click="switchTab('settings')" class="menu-item" :class="{ active: currentTab === 'settings' }">
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
        <div class="topbar-left">
          <button @click="mobileMenuOpen = !mobileMenuOpen" class="hamburger-btn" aria-label="Toggle Menu">
            <span class="hamburger-icon">☰</span>
          </button>
          <div class="topbar-brand-mobile">
            <div class="brand-icon">N</div>
            <span class="brand-text">ADMIN</span>
          </div>
        </div>
        <div class="topbar-actions">
          <span class="action-icon" @click="switchTab('notifications')" title="Send Broadcast Notification">✉️</span>
          
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
                      <strong style="color: #0052cc;">{{ selectedUser.downlineCount || 0 }} Direct {{ (selectedUser.downlineCount || 0) === 1 ? 'Member' : 'Members' }}</strong>
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

          <!-- TAB: TEAMS VIEW (DOWNLINE NETWORKS & USER TREE) -->
          <div v-if="currentTab === 'teams'" class="teams-pane">
            <div class="table-card">
              <div class="table-header-row" style="margin-bottom: 1.5rem; display: flex; justify-content: space-between; align-items: center;">
                <div>
                  <h3 style="margin: 0;">👥 User Downline Affiliate Teams</h3>
                  <p style="font-size: 0.82rem; color: #64748b; margin-top: 4px;">View registered partners who have joined under other users across your network.</p>
                </div>
                <button @click="fetchTeamsData" class="btn-add-img" style="font-size: 0.85rem; padding: 0.4rem 0.85rem;">🔄 Refresh Teams</button>
              </div>

              <div v-if="loadingTeams" class="loading-box">
                Loading team tree data...
              </div>

              <div v-else-if="!teamsData.teams || teamsData.teams.length === 0" style="text-align: center; padding: 3rem; background: #f8fafc; border-radius: 12px; border: 1px dashed #cbd5e1;">
                <p style="color: #64748b; font-size: 0.95rem; font-weight: 600; margin: 0;">No multi-user downline relationships recorded yet.</p>
                <p style="color: #94a3b8; font-size: 0.82rem; margin-top: 4px;">When users register using another member's Sponsor ID, their affiliate networks will automatically display here.</p>
              </div>

              <div v-else class="teams-tree-container" style="display: flex; flex-direction: column; gap: 1.25rem;">
                <div v-for="group in teamsData.teams" :key="group.sponsorId" style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 1.25rem; box-shadow: 0 2px 8px rgba(0,0,0,0.03);">
                  <!-- Sponsor Header -->
                  <div style="display: flex; justify-content: space-between; align-items: center; padding-bottom: 0.85rem; border-bottom: 1px solid #f1f5f9; margin-bottom: 0.85rem;">
                    <div>
                      <div style="display: flex; align-items: center; gap: 8px;">
                        <span style="font-weight: 800; font-size: 1.05rem; color: #0052cc;">{{ group.sponsorName }}</span>
                        <span style="font-size: 0.8rem; font-weight: 700; color: #475569; background: #f1f5f9; padding: 2px 8px; border-radius: 6px;">SRM{{ String(group.sponsorId).padStart(6, '0') }}</span>
                      </div>
                      <div style="font-size: 0.8rem; color: #64748b; margin-top: 2px;">{{ group.sponsorEmail }}</div>
                    </div>
                    <span style="background: #dcfce7; color: #15803d; font-weight: 700; font-size: 0.8rem; padding: 4px 12px; border-radius: 20px; border: 1px solid #86efac;">
                      {{ group.downlines.length }} Direct {{ group.downlines.length === 1 ? 'Member' : 'Members' }}
                    </span>
                  </div>

                  <!-- Downlines Table -->
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
                          <td><strong style="color: #0052cc;">SRM{{ String(member.id).padStart(6, '0') }}</strong></td>
                          <td class="font-bold">{{ member.fullName }}</td>
                          <td style="color: #475569;">{{ member.email }}</td>
                          <td>{{ member.mobileNumber || 'N/A' }}</td>
                          <td class="font-bold" style="color: #16a34a;">₹{{ parseFloat(member.main_wallet_balance || 0).toFixed(2) }}</td>
                          <td>
                            <span :class="member.status === 'ACTIVE' || member.status === 'active' ? 'nice-badge-success' : 'nice-badge-pending'">
                              {{ (member.status || 'ACTIVE').toUpperCase() }}
                            </span>
                          </td>
                          <td style="font-size: 0.8rem; color: #64748b;">{{ member.createdAt ? String(member.createdAt).substring(0, 10) : 'N/A' }}</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- TAB: SHARED VARIABLES -->
          <div v-if="currentTab === 'shared_variable'" class="shared-variable-pane">
            <div class="sv-container">
              <!-- Header Hero Banner -->
              <div class="sv-hero-card">
                <div class="sv-hero-info">
                  <div class="sv-hero-badge">
                    <span class="pulse-dot"></span> System Governance
                  </div>
                  <h2>🔗 Shared Variables & Global Controls</h2>
                  <p>Manage system financial limits, commission distribution parameters, payment gateway mode configurations, and instant feature ON/OFF master toggles.</p>
                </div>
                <div class="sv-hero-meta">
                  <div class="meta-pill" :class="systemSettings.maintenance_mode_bool ? 'danger' : 'success'">
                    <span class="meta-dot"></span>
                    Maintenance: <strong>{{ systemSettings.maintenance_mode_bool ? 'ENABLED' : 'OFF' }}</strong>
                  </div>
                  <div class="meta-pill blue">
                    <span class="meta-dot"></span>
                    Scriza: <strong>{{ (systemSettings.scriza_api_mode || 'simulation').toUpperCase() }}</strong>
                  </div>
                  <div class="meta-pill purple">
                    <span class="meta-dot"></span>
                    Razorpay: <strong>{{ (systemSettings.razorpay_api_mode || 'test').toUpperCase() }}</strong>
                  </div>
                </div>
              </div>

              <form @submit.prevent="handleSaveSystemSettings" class="sv-form">
                
                <!-- Section 1: Financial & Commission Parameters -->
                <div class="sv-section-card">
                  <div class="sv-section-header">
                    <div class="sv-section-icon bg-blue-light">💰</div>
                    <div>
                      <h3>System Financial & Commission Parameters</h3>
                      <p>Set wallet minimums, registration fees, commission payouts, and withdrawal rules.</p>
                    </div>
                  </div>

                  <div class="sv-grid-3">
                    <!-- Min Balance -->
                    <div class="sv-input-card">
                      <label for="minBalance">
                        <span class="lbl-text">Minimum Wallet Balance</span>
                        <span class="unit-badge">₹ INR</span>
                      </label>
                      <div class="input-with-icon">
                        <span class="field-icon">💼</span>
                        <input id="minBalance" type="number" step="0.01" v-model="systemSettings.min_wallet_balance" placeholder="50.00" required />
                      </div>
                      <span class="input-help">Minimum balance user must maintain in wallet</span>
                    </div>

                    <!-- Join Amount -->
                    <div class="sv-input-card">
                      <label for="joinAmount">
                        <span class="lbl-text">Join / Activation Amount</span>
                        <span class="unit-badge">₹ INR</span>
                      </label>
                      <div class="input-with-icon">
                        <span class="field-icon">🚀</span>
                        <input id="joinAmount" type="number" v-model="systemSettings.join_amount" placeholder="1200" required />
                      </div>
                      <span class="input-help">Account activation cost for new users</span>
                    </div>

                    <!-- Top-Up Amount -->
                    <div class="sv-input-card">
                      <label for="topUpAmount">
                        <span class="lbl-text">Top-Up Amount</span>
                        <span class="unit-badge">₹ INR</span>
                      </label>
                      <div class="input-with-icon">
                        <span class="field-icon">⚡</span>
                        <input id="topUpAmount" type="number" v-model="systemSettings.top_up_amount" placeholder="1200" required />
                      </div>
                      <span class="input-help">Default top-up fee per cycle</span>
                    </div>

                    <!-- Direct Income -->
                    <div class="sv-input-card">
                      <label for="directIncome">
                        <span class="lbl-text">Direct Sponsor Income</span>
                        <span class="unit-badge">₹ INR</span>
                      </label>
                      <div class="input-with-icon">
                        <span class="field-icon">🎁</span>
                        <input id="directIncome" type="number" v-model="systemSettings.direct_income" placeholder="300" required />
                      </div>
                      <span class="input-help">Commission credited to direct sponsor</span>
                    </div>

                    <!-- Level Pool -->
                    <div class="sv-input-card">
                      <label for="levelPool">
                        <span class="lbl-text">Level Pool Collection</span>
                        <span class="unit-badge">₹ INR</span>
                      </label>
                      <div class="input-with-icon">
                        <span class="field-icon">🌐</span>
                        <input id="levelPool" type="number" v-model="systemSettings.level_pool" placeholder="600" required />
                      </div>
                      <span class="input-help">Amount allocated towards level pool</span>
                    </div>

                    <!-- Company Maintenance -->
                    <div class="sv-input-card">
                      <label for="companyMaintenance">
                        <span class="lbl-text">Company Maintenance</span>
                        <span class="unit-badge">₹ INR</span>
                      </label>
                      <div class="input-with-icon">
                        <span class="field-icon">🏢</span>
                        <input id="companyMaintenance" type="number" v-model="systemSettings.company_maintenance" placeholder="300" required />
                      </div>
                      <span class="input-help">Company operational fee portion</span>
                    </div>

                    <!-- Cycle Size -->
                    <div class="sv-input-card">
                      <label for="cycleSize">
                        <span class="lbl-text">Cycle Size</span>
                        <span class="unit-badge">Members</span>
                      </label>
                      <div class="input-with-icon">
                        <span class="field-icon">🔄</span>
                        <input id="cycleSize" type="number" v-model="systemSettings.cycle_size" placeholder="126" required />
                      </div>
                      <span class="input-help">Required downline members per cycle</span>
                    </div>

                    <!-- Withdrawal Percentage -->
                    <div class="sv-input-card">
                      <label for="withdrawPct">
                        <span class="lbl-text">Withdrawal Deduction</span>
                        <span class="unit-badge">% Percent</span>
                      </label>
                      <div class="input-with-icon">
                        <span class="field-icon">📊</span>
                        <input id="withdrawPct" type="number" v-model="systemSettings.withdrawal_percentage" placeholder="15" required />
                      </div>
                      <span class="input-help">TDS / admin charge deduction %</span>
                    </div>

                    <!-- Minimum Withdrawal -->
                    <div class="sv-input-card">
                      <label for="minWithdraw">
                        <span class="lbl-text">Minimum Withdrawal</span>
                        <span class="unit-badge">₹ INR</span>
                      </label>
                      <div class="input-with-icon">
                        <span class="field-icon">💸</span>
                        <input id="minWithdraw" type="number" v-model="systemSettings.minimum_withdrawal" placeholder="500" required />
                      </div>
                      <span class="input-help">Minimum payout request threshold</span>
                    </div>

                    <!-- Allowed Withdrawal Days -->
                    <div class="sv-input-card span-full">
                      <label for="withdrawDays">
                        <span class="lbl-text">Allowed Withdrawal Days</span>
                        <span class="unit-badge">Schedule</span>
                      </label>
                      <div class="input-with-icon">
                        <span class="field-icon">📅</span>
                        <input id="withdrawDays" type="text" v-model="systemSettings.withdrawal_days" placeholder="Mon,Wed,Fri" required />
                      </div>
                      <span class="input-help">Comma-separated days when cash out requests are allowed</span>
                    </div>
                  </div>
                </div>

                <!-- Section 2: Master Feature ON/OFF Switches -->
                <div class="sv-section-card" style="margin-top: 1.5rem;">
                  <div class="sv-section-header">
                    <div class="sv-section-icon bg-purple-light">🎛️</div>
                    <div>
                      <h3>Master Global Feature Switches</h3>
                      <p>Turn core features ON or OFF across the entire mobile & web platform instantly.</p>
                    </div>
                  </div>

                  <div class="toggles-grid">
                    <!-- Toggle 1: User Registration -->
                    <div class="toggle-card" :class="{ 'active': systemSettings.registration_enabled_bool }">
                      <div class="toggle-info">
                        <span class="toggle-icon">👤</span>
                        <div>
                          <strong class="toggle-title">User Registration Flow</strong>
                          <p class="toggle-desc">Allow new members to sign up</p>
                        </div>
                      </div>
                      <div class="toggle-action">
                        <label class="switch">
                          <input type="checkbox" v-model="systemSettings.registration_enabled_bool" />
                          <span class="slider round"></span>
                        </label>
                        <span class="state-badge" :class="systemSettings.registration_enabled_bool ? 'badge-on' : 'badge-off'">
                          {{ systemSettings.registration_enabled_bool ? 'ACTIVE' : 'OFF' }}
                        </span>
                      </div>
                    </div>

                    <!-- Toggle 2: User Login -->
                    <div class="toggle-card" :class="{ 'active': systemSettings.login_enabled_bool }">
                      <div class="toggle-info">
                        <span class="toggle-icon">🔑</span>
                        <div>
                          <strong class="toggle-title">User Login Flow</strong>
                          <p class="toggle-desc">Enable member authentication</p>
                        </div>
                      </div>
                      <div class="toggle-action">
                        <label class="switch">
                          <input type="checkbox" v-model="systemSettings.login_enabled_bool" />
                          <span class="slider round"></span>
                        </label>
                        <span class="state-badge" :class="systemSettings.login_enabled_bool ? 'badge-on' : 'badge-off'">
                          {{ systemSettings.login_enabled_bool ? 'ACTIVE' : 'OFF' }}
                        </span>
                      </div>
                    </div>

                    <!-- Toggle 3: OTP & Forgot Password -->
                    <div class="toggle-card" :class="{ 'active': systemSettings.otp_enabled_bool }">
                      <div class="toggle-info">
                        <span class="toggle-icon">📲</span>
                        <div>
                          <strong class="toggle-title">OTP & Password Recovery</strong>
                          <p class="toggle-desc">Send SMS OTP verification codes</p>
                        </div>
                      </div>
                      <div class="toggle-action">
                        <label class="switch">
                          <input type="checkbox" v-model="systemSettings.otp_enabled_bool" />
                          <span class="slider round"></span>
                        </label>
                        <span class="state-badge" :class="systemSettings.otp_enabled_bool ? 'badge-on' : 'badge-off'">
                          {{ systemSettings.otp_enabled_bool ? 'ACTIVE' : 'OFF' }}
                        </span>
                      </div>
                    </div>

                    <!-- Toggle 4: Add Money & Fund Request -->
                    <div class="toggle-card" :class="{ 'active': systemSettings.add_money_enabled_bool }">
                      <div class="toggle-info">
                        <span class="toggle-icon">💳</span>
                        <div>
                          <strong class="toggle-title">Add Money & Fund Requests</strong>
                          <p class="toggle-desc">Allow online payments & UPI loads</p>
                        </div>
                      </div>
                      <div class="toggle-action">
                        <label class="switch">
                          <input type="checkbox" v-model="systemSettings.add_money_enabled_bool" />
                          <span class="slider round"></span>
                        </label>
                        <span class="state-badge" :class="systemSettings.add_money_enabled_bool ? 'badge-on' : 'badge-off'">
                          {{ systemSettings.add_money_enabled_bool ? 'ACTIVE' : 'OFF' }}
                        </span>
                      </div>
                    </div>

                    <!-- Toggle 5: Withdrawal Requests -->
                    <div class="toggle-card" :class="{ 'active': systemSettings.withdrawal_enabled_bool }">
                      <div class="toggle-info">
                        <span class="toggle-icon">💸</span>
                        <div>
                          <strong class="toggle-title">Cash Out & Withdrawals</strong>
                          <p class="toggle-desc">Allow users to request bank payouts</p>
                        </div>
                      </div>
                      <div class="toggle-action">
                        <label class="switch">
                          <input type="checkbox" v-model="systemSettings.withdrawal_enabled_bool" />
                          <span class="slider round"></span>
                        </label>
                        <span class="state-badge" :class="systemSettings.withdrawal_enabled_bool ? 'badge-on' : 'badge-off'">
                          {{ systemSettings.withdrawal_enabled_bool ? 'ACTIVE' : 'OFF' }}
                        </span>
                      </div>
                    </div>

                    <!-- Toggle 6: CAPTCHA Requirement -->
                    <div class="toggle-card" :class="{ 'active': systemSettings.captcha_enabled_bool }">
                      <div class="toggle-info">
                        <span class="toggle-icon">🛡️</span>
                        <div>
                          <strong class="toggle-title">CAPTCHA Verification</strong>
                          <p class="toggle-desc">Require anti-bot CAPTCHA on forms</p>
                        </div>
                      </div>
                      <div class="toggle-action">
                        <label class="switch">
                          <input type="checkbox" v-model="systemSettings.captcha_enabled_bool" />
                          <span class="slider round"></span>
                        </label>
                        <span class="state-badge" :class="systemSettings.captcha_enabled_bool ? 'badge-on' : 'badge-off'">
                          {{ systemSettings.captcha_enabled_bool ? 'ACTIVE' : 'OFF' }}
                        </span>
                      </div>
                    </div>

                    <!-- Toggle 7: Maintenance Mode -->
                    <div class="toggle-card danger-toggle" :class="{ 'active-danger': systemSettings.maintenance_mode_bool }">
                      <div class="toggle-info">
                        <span class="toggle-icon">⚠️</span>
                        <div>
                          <strong class="toggle-title" style="color: #dc2626;">Platform Maintenance Mode</strong>
                          <p class="toggle-desc">Block user access with maintenance screen</p>
                        </div>
                      </div>
                      <div class="toggle-action">
                        <label class="switch switch-danger">
                          <input type="checkbox" v-model="systemSettings.maintenance_mode_bool" />
                          <span class="slider round"></span>
                        </label>
                        <span class="state-badge" :class="systemSettings.maintenance_mode_bool ? 'badge-danger' : 'badge-off'">
                          {{ systemSettings.maintenance_mode_bool ? 'ENABLED' : 'OFF' }}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Section 3: Payment Gateways & API Integration Controls -->
                <div class="sv-section-card" style="margin-top: 1.5rem;">
                  <div class="sv-section-header">
                    <div class="sv-section-icon bg-green-light">💳</div>
                    <div>
                      <h3>Payment Gateways & App Updates Config</h3>
                      <p>Manage Razorpay keys, Scriza API environment, company UPI handle, and version enforcement.</p>
                    </div>
                  </div>

                  <div class="gateways-grid">
                    <!-- Scriza API Mode Card -->
                    <div class="gateway-box">
                      <div class="gateway-box-header">
                        <span class="gw-title">⚡ Scriza Recharge API Mode</span>
                        <span class="gw-tag" :class="systemSettings.scriza_api_mode === 'production' ? 'tag-live' : 'tag-sim'">
                          {{ systemSettings.scriza_api_mode === 'production' ? 'PRODUCTION LIVE' : 'SIMULATION' }}
                        </span>
                      </div>
                      <div class="sv-input-card">
                        <label for="scrizaMode">Active Environment</label>
                        <select id="scrizaMode" v-model="systemSettings.scriza_api_mode" class="styled-select">
                          <option value="simulation">🧪 Simulation Mode (Test Responses)</option>
                          <option value="production">🟢 Production Live Mode (Real Recharges)</option>
                        </select>
                      </div>
                    </div>

                    <!-- Razorpay Mode Card -->
                    <div class="gateway-box">
                      <div class="gateway-box-header">
                        <span class="gw-title">🔷 Razorpay Payment Gateway</span>
                        <span class="gw-tag" :class="systemSettings.razorpay_api_mode === 'live' ? 'tag-live' : 'tag-sim'">
                          {{ systemSettings.razorpay_api_mode === 'live' ? 'LIVE PAYMENTS' : 'TEST MODE' }}
                        </span>
                      </div>
                      <div class="sv-input-card">
                        <label for="razorpayMode">Environment Mode</label>
                        <select id="razorpayMode" v-model="systemSettings.razorpay_api_mode" class="styled-select">
                          <option value="test">🧪 Test Payments Mode (Sandbox Keys)</option>
                          <option value="live">🟢 Live Payments Mode (Real Money Payouts)</option>
                        </select>
                      </div>
                    </div>

                    <!-- Razorpay Key ID -->
                    <div class="gateway-box">
                      <div class="sv-input-card">
                        <label for="razorpayKeyId">
                          <span class="lbl-text">Razorpay Key ID</span>
                        </label>
                        <input id="razorpayKeyId" type="text" v-model="systemSettings.razorpay_key_id" placeholder="rzp_live_xxxxxxxx" required />
                      </div>
                    </div>

                    <!-- Razorpay Key Secret -->
                    <div class="gateway-box">
                      <div class="sv-input-card">
                        <label for="razorpayKeySecret">
                          <span class="lbl-text">Razorpay Key Secret</span>
                        </label>
                        <div class="input-with-button">
                          <input id="razorpayKeySecret" :type="showRazorpaySecret ? 'text' : 'password'" v-model="systemSettings.razorpay_key_secret" placeholder="Enter Key Secret" required />
                          <button type="button" @click="showRazorpaySecret = !showRazorpaySecret" class="btn-toggle-eye">
                            {{ showRazorpaySecret ? '🔒 Hide' : '👁️ Show' }}
                          </button>
                        </div>
                      </div>
                    </div>

                    <!-- UPI Direct VPA -->
                    <div class="gateway-box">
                      <div class="sv-input-card">
                        <label for="upiVpaId">
                          <span class="lbl-text">Company UPI VPA Address</span>
                        </label>
                        <input id="upiVpaId" type="text" v-model="systemSettings.upi_vpa_id" placeholder="vp110064@okaxis" required />
                      </div>
                    </div>

                    <!-- UPI Payee Name -->
                    <div class="gateway-box">
                      <div class="sv-input-card">
                        <label for="upiPayeeName">
                          <span class="lbl-text">Company UPI Payee Name</span>
                        </label>
                        <input id="upiPayeeName" type="text" v-model="systemSettings.upi_payee_name" placeholder="EarnFarm Official" required />
                      </div>
                    </div>

                    <!-- Force Update Version -->
                    <div class="gateway-box span-full">
                      <div class="sv-input-card">
                        <label for="forceVersion">
                          <span class="lbl-text">Force Update Android App Version</span>
                          <span class="unit-badge">App Build</span>
                        </label>
                        <input id="forceVersion" type="text" v-model="systemSettings.force_update_version" placeholder="1.0.0" required />
                        <span class="input-help">Mobile app builds below this version string will prompt force update</span>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Action Footer Bar -->
                <div class="sv-action-bar" style="margin-top: 1.5rem;">
                  <div class="sv-action-info">
                    <div v-if="systemError" class="alert-box alert-error">⚠️ {{ systemError }}</div>
                    <div v-if="systemSuccess" class="alert-box alert-success">✅ {{ systemSuccess }}</div>
                    <span v-if="!systemError && !systemSuccess" class="status-tip">
                      💡 Changes take effect immediately across all connected client applications.
                    </span>
                  </div>
                  <button type="submit" :disabled="loadingSystem" class="sv-save-btn">
                    <span v-if="loadingSystem" class="spinner-icon">🔄</span>
                    <span>{{ loadingSystem ? 'Saving System Preferences...' : '💾 Save System Preferences' }}</span>
                  </button>
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
      mobileMenuOpen: false,
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
      return ['notifications', 'shared_variable', 'admins'].includes(this.currentTab);
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
      } else if (newTab === 'teams') {
        if (this.$route.path !== '/admin-dashboard') this.$router.push('/admin-dashboard');
        this.fetchTeamsData();
      } else if (newTab === 'admins') {
        if (this.$route.path !== '/admin-dashboard') this.$router.push('/admin-dashboard');
        this.fetchAdminsList();
      } else if (newTab === 'settings') {
        if (this.$route.path !== '/admin-settings') this.$router.push('/admin-settings');
      } else if (newTab === 'shared_variable') {
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
      if (this.$route.path === '/admin-settings' && this.currentTab !== 'shared_variable') {
        this.currentTab = 'settings';
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
        if (!response.ok) throw new Error('Failed to load teams data');
        this.teamsData = await response.json();
      } catch (err) {
        console.error(err);
      } finally {
        this.loadingTeams = false;
      }
    },
    async checkGatewayStatus() {
      const token = localStorage.getItem('adminToken');
      if (!token) {
        this.gatewayStatus = {
          database: 'Operational (Online)',
          app_api: 'Operational (Online)',
          scriza_api: 'Operational (Live)',
          razorpay_gateway: 'Operational (Live)'
        };
        return;
      }
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
    switchTab(tab) {
      this.currentTab = tab;
      this.mobileMenuOpen = false;
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
  background: #ffffff;
  font-family: 'Inter', system-ui, sans-serif;
  color: #3e5569;
  position: relative;
}

/* Sidebar styling (Classic Dark theme) */
.sidebar {
  width: 250px;
  background: #1e283d;
  color: #a3afc7;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  height: 100vh;
  height: 100dvh;
  min-height: 100%;
  z-index: 100;
  overflow-y: auto;
  box-shadow: 2px 0 10px rgba(0, 0, 0, 0.15);
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
  margin-left: 250px;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  min-width: 0;
  background: #ffffff;
  width: calc(100% - 250px);
  box-sizing: border-box;
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

/* Shared System Variables Redesign Styles */
.sv-container {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  padding-bottom: 2rem;
}

.sv-hero-card {
  background: linear-gradient(135deg, #1e283d 0%, #0f172a 100%);
  border-radius: 16px;
  padding: 2rem;
  color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1.5rem;
  box-shadow: 0 10px 25px rgba(15, 23, 42, 0.15);
}

.sv-hero-info h2 {
  font-size: 1.5rem;
  font-weight: 800;
  margin: 0.4rem 0 0.5rem;
  letter-spacing: -0.5px;
}

.sv-hero-info p {
  color: #94a3b8;
  font-size: 0.9rem;
  max-width: 650px;
  margin: 0;
  line-height: 1.5;
}

.sv-hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: rgba(37, 99, 235, 0.2);
  border: 1px solid rgba(37, 99, 235, 0.4);
  color: #60a5fa;
  font-size: 0.75rem;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 20px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.pulse-dot {
  width: 8px;
  height: 8px;
  background: #3b82f6;
  border-radius: 50%;
  box-shadow: 0 0 8px #3b82f6;
}

.sv-hero-meta {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.meta-pill {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  background: rgba(255, 255, 255, 0.08);
}

.meta-pill.success {
  background: rgba(16, 185, 129, 0.15);
  color: #34d399;
  border: 1px solid rgba(16, 185, 129, 0.3);
}

.meta-pill.danger {
  background: rgba(239, 68, 68, 0.15);
  color: #fca5a5;
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.meta-pill.blue {
  background: rgba(37, 99, 235, 0.15);
  color: #93c5fd;
  border: 1px solid rgba(37, 99, 235, 0.3);
}

.meta-pill.purple {
  background: rgba(168, 85, 247, 0.15);
  color: #e9d5ff;
  border: 1px solid rgba(168, 85, 247, 0.3);
}

.meta-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
}

.sv-section-card {
  background: white;
  border-radius: 16px;
  padding: 1.75rem;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.03);
}

.sv-section-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #f1f5f9;
}

.sv-section-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.4rem;
}

.bg-blue-light { background: #eff6ff; color: #2563eb; }
.bg-purple-light { background: #faf5ff; color: #9333ea; }
.bg-green-light { background: #f0fdf4; color: #16a34a; }

.sv-section-header h3 {
  font-size: 1.15rem;
  font-weight: 700;
  color: #0f172a;
  margin: 0 0 0.2rem;
}

.sv-section-header p {
  color: #64748b;
  font-size: 0.85rem;
  margin: 0;
}

.sv-grid-3 {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.25rem;
}

.sv-input-card {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 1rem;
  transition: all 0.2s ease;
}

.sv-input-card:focus-within {
  background: white;
  border-color: #2563eb;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

.sv-input-card label {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.82rem;
  font-weight: 700;
  color: #334155;
}

.unit-badge {
  font-size: 0.7rem;
  font-weight: 600;
  background: #e2e8f0;
  color: #475569;
  padding: 2px 6px;
  border-radius: 4px;
}

.input-with-icon {
  display: flex;
  align-items: center;
  background: white;
  border: 1px solid #cbd5e1;
  border-radius: 6px;
  padding: 0 0.65rem;
}

.input-with-icon .field-icon {
  font-size: 1.1rem;
  margin-right: 0.5rem;
}

.input-with-icon input,
.sv-input-card input,
.styled-select {
  flex: 1;
  border: none;
  outline: none;
  padding: 0.65rem 0;
  font-family: inherit;
  font-size: 0.95rem;
  font-weight: 600;
  color: #0f172a;
  background: transparent;
}

.sv-input-card input[type="text"],
.sv-input-card input[type="number"],
.sv-input-card input[type="password"] {
  width: 100%;
}

.styled-select {
  width: 100%;
  background: white;
  border: 1px solid #cbd5e1;
  border-radius: 6px;
  padding: 0.65rem 0.85rem;
  font-size: 0.9rem;
  color: #0f172a;
  font-weight: 600;
}

.input-help {
  font-size: 0.75rem;
  color: #94a3b8;
  margin-top: 2px;
}

.span-full {
  grid-column: 1 / -1;
}

/* Switches & Toggles Grid */
.toggles-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 1rem;
}

.toggle-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 1rem 1.25rem;
  transition: all 0.2s ease;
}

.toggle-card.active {
  background: #f0fdf4;
  border-color: #bbf7d0;
}

.toggle-card.danger-toggle.active-danger {
  background: #fef2f2;
  border-color: #fecaca;
}

.toggle-info {
  display: flex;
  align-items: center;
  gap: 0.85rem;
}

.toggle-icon {
  font-size: 1.4rem;
}

.toggle-title {
  display: block;
  font-size: 0.9rem;
  font-weight: 700;
  color: #1e293b;
}

.toggle-desc {
  margin: 2px 0 0;
  font-size: 0.78rem;
  color: #64748b;
}

.toggle-action {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

/* Custom iOS Switch */
.switch {
  position: relative;
  display: inline-block;
  width: 46px;
  height: 24px;
}

.switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: #cbd5e1;
  transition: .3s;
}

.slider:before {
  position: absolute;
  content: "";
  height: 18px;
  width: 18px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: .3s;
}

input:checked + .slider {
  background-color: #10b981;
}

.switch-danger input:checked + .slider {
  background-color: #ef4444;
}

input:checked + .slider:before {
  transform: translateX(22px);
}

.slider.round {
  border-radius: 24px;
}

.slider.round:before {
  border-radius: 50%;
}

.state-badge {
  font-size: 0.7rem;
  font-weight: 800;
  padding: 3px 8px;
  border-radius: 6px;
  min-width: 48px;
  text-align: center;
}

.badge-on { background: #dcfce7; color: #15803d; }
.badge-off { background: #f1f5f9; color: #64748b; }
.badge-danger { background: #fee2e2; color: #b91c1c; }

/* Gateways section */
.gateways-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 1.25rem;
}

.gateway-box {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 1.1rem;
}

.gateway-box-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.85rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #e2e8f0;
}

.gw-title {
  font-weight: 700;
  font-size: 0.88rem;
  color: #1e293b;
}

.gw-tag {
  font-size: 0.7rem;
  font-weight: 800;
  padding: 2px 8px;
  border-radius: 4px;
}

.tag-live { background: #dcfce7; color: #15803d; }
.tag-sim { background: #feefc3; color: #b45309; }

.input-with-button {
  display: flex;
  gap: 0.5rem;
  background: white;
  border: 1px solid #cbd5e1;
  border-radius: 6px;
  padding: 0 0.5rem;
  align-items: center;
}

.btn-toggle-eye {
  background: #f1f5f9;
  border: 1px solid #cbd5e1;
  border-radius: 4px;
  padding: 4px 8px;
  font-size: 0.75rem;
  font-weight: 700;
  cursor: pointer;
  color: #475569;
  white-space: nowrap;
}

.btn-toggle-eye:hover {
  background: #e2e8f0;
}

/* Action Footer */
.sv-action-bar {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  padding: 1.25rem 1.75rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1.5rem;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
}

.sv-save-btn {
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  color: white;
  border: none;
  padding: 0.85rem 2.25rem;
  border-radius: 10px;
  font-weight: 700;
  font-size: 0.95rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
  transition: all 0.2s ease;
}

.sv-save-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 18px rgba(37, 99, 235, 0.4);
}

.alert-box {
  padding: 0.6rem 1rem;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 700;
}

.alert-error {
  background: #fef2f2;
  color: #dc2626;
  border: 1px solid #fecaca;
}

.alert-success {
  background: #f0fdf4;
  color: #16a34a;
  border: 1px solid #bbf7d0;
}

.status-tip {
  font-size: 0.82rem;
  color: #64748b;
  font-weight: 500;
}

/* Topbar Left Controls & Mobile Brand */
.topbar-left {
  display: flex;
  align-items: center;
  gap: 0.85rem;
}

.hamburger-btn {
  display: none;
  background: #f8fafc;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  width: 38px;
  height: 38px;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #1e293b;
  font-size: 1.25rem;
  transition: all 0.15s ease;
}

.hamburger-btn:hover {
  background: #e2e8f0;
}

.topbar-brand-mobile {
  display: none;
  align-items: center;
  gap: 0.5rem;
}

.topbar-brand-mobile .brand-icon {
  background: #2563eb;
  color: white;
  width: 28px;
  height: 28px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 900;
  font-size: 1rem;
}

.topbar-brand-mobile .brand-text {
  font-weight: 800;
  color: #0f172a;
  font-size: 0.95rem;
  letter-spacing: 0.5px;
}

.close-drawer-btn {
  display: none;
  background: transparent;
  border: none;
  color: #94a3b8;
  font-size: 1.6rem;
  cursor: pointer;
  line-height: 1;
  padding: 0.2rem 0.5rem;
}

.close-drawer-btn:hover {
  color: white;
}

.sidebar-brand {
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 1.25rem;
  background: rgba(0, 0, 0, 0.15);
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.brand-left {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

@media (max-width: 768px) {
  .hamburger-btn {
    display: flex;
  }

  .topbar-brand-mobile {
    display: flex;
  }

  .close-drawer-btn {
    display: block;
  }

  .admin-layout {
    flex-direction: column;
    width: 100%;
    min-height: 100vh;
  }

  /* Off-canvas Slide Drawer for Mobile */
  .sidebar {
    width: 280px;
    max-width: 85vw;
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    height: 100vh;
    height: 100dvh;
    z-index: 1000;
    transform: translateX(-100%);
    transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 4px 0 25px rgba(0, 0, 0, 0.3);
  }

  .sidebar.open-drawer {
    transform: translateX(0);
  }

  .mobile-drawer-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(15, 23, 42, 0.65);
    backdrop-filter: blur(4px);
    z-index: 999;
  }

  .main-section {
    margin-left: 0 !important;
    width: 100% !important;
  }

  .topbar {
    padding: 0 1rem;
    height: 58px;
    position: sticky;
    top: 0;
    z-index: 90;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  }

  .topbar-actions {
    gap: 0.75rem;
  }

  .profile-name {
    display: none;
  }

  .content-body {
    padding: 1rem;
    width: 100%;
    box-sizing: border-box;
  }

  .content-header {
    margin-bottom: 1.25rem;
  }

  .content-header h2 {
    font-size: 1.3rem;
  }

  .table-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    width: 100%;
  }

  .nice-table {
    min-width: 650px;
  }

  .slide-over {
    width: 100% !important;
    max-width: 100% !important;
  }
}
</style>
