<template>
  <div class="admin-layout">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="sidebar-brand">
        <div class="brand-icon">N</div>
        <span class="brand-text">NICE ADMIN</span>
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
        <button @click="currentTab = 'admins'" class="menu-item" :class="{ active: currentTab === 'admins' }">
          <span class="icon">🛡️</span> System Admins
        </button>
        <router-link to="/admin-settings" class="menu-item">
          <span class="icon">⚙️</span> Settings
        </router-link>
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
        <div class="topbar-search">
          <span class="search-icon">🔍</span>
          <input type="text" placeholder="Search..." />
        </div>
        <div class="topbar-actions">
          <span class="action-icon">🇺🇸</span>
          <span class="action-icon">✉️</span>
          <div class="notification-bell">
            <span class="action-icon">🔔</span>
            <span class="bell-badge">3</span>
          </div>
          <div class="admin-profile-badge">
            <div class="avatar">{{ adminEmail[0].toUpperCase() }}</div>
            <span class="profile-name">{{ adminEmail.split('@')[0] }}</span>
          </div>
        </div>
      </header>

      <!-- Main Content Container -->
      <main class="content-body">
        <div class="content-header">
          <h2>Classic Dashboard</h2>
          <div class="breadcrumbs">Dashboard &gt; Classic Dashboard</div>
        </div>

        <!-- System & API Operational Status Banner -->
        <section v-if="currentTab === 'dashboard'" class="op-status-card">
          <div class="op-card-header">
            <h4>🖥️ Systems & API Operational Status</h4>
            <button @click="checkGatewayStatus" class="refresh-op-btn">Refresh</button>
          </div>
          <div class="op-grid">
            <div class="op-item">
              <span class="op-lbl">Database Connection</span>
              <span class="op-status-tag" :class="gatewayStatus.database === 'Operational' ? 'green' : 'red'">
                {{ gatewayStatus.database }}
              </span>
            </div>
            <div class="op-item">
              <span class="op-lbl">Recharge API</span>
              <span class="op-status-tag" :class="gatewayStatus.app_api === 'Operational' ? 'green' : 'red'">
                {{ gatewayStatus.app_api }}
              </span>
            </div>
            <div class="op-item">
              <span class="op-lbl">Scriza Gateway</span>
              <span class="op-status-tag" :class="gatewayStatus.scriza_api && gatewayStatus.scriza_api.includes('Operational') ? 'green' : 'orange'">
                {{ gatewayStatus.scriza_api }}
              </span>
            </div>
            <div class="op-item">
              <span class="op-lbl">Razorpay Gateway</span>
              <span class="op-status-tag" :class="gatewayStatus.razorpay_gateway && gatewayStatus.razorpay_gateway.includes('Operational') ? 'green' : 'orange'">
                {{ gatewayStatus.razorpay_gateway }}
              </span>
            </div>
          </div>
        </section>

        <div v-if="loading" class="loading-box">
          Loading dashboard content...
        </div>

        <div v-else class="tab-content-area">
          <!-- TAB 1: DASHBOARD -->
          <div v-if="currentTab === 'dashboard'" class="dashboard-panes">
            <!-- Top Stats Grid -->
            <div class="stats-grid">
              <!-- Total Users -->
              <div class="nice-stat-card border-blue">
                <div class="stat-body">
                  <div class="stat-left">
                    <span class="icon-indicator">👤</span>
                    <span class="stat-card-title">Total Users</span>
                  </div>
                  <span class="stat-card-val">{{ stats.totalUsers }}</span>
                </div>
                <div class="progress-bar bg-blue"></div>
              </div>

              <!-- Main Wallet -->
              <div class="nice-stat-card border-green">
                <div class="stat-body">
                  <div class="stat-left">
                    <span class="icon-indicator">💼</span>
                    <span class="stat-card-title">Main Wallet Balance</span>
                  </div>
                  <span class="stat-card-val">₹{{ stats.totalMainWallet.toLocaleString('en-IN') }}</span>
                </div>
                <div class="progress-bar bg-green"></div>
              </div>

              <!-- Fund Wallet -->
              <div class="nice-stat-card border-purple">
                <div class="stat-body">
                  <div class="stat-left">
                    <span class="icon-indicator">📥</span>
                    <span class="stat-card-title">Fund Wallet Balance</span>
                  </div>
                  <span class="stat-card-val">₹{{ stats.totalFundWallet.toLocaleString('en-IN') }}</span>
                </div>
                <div class="progress-bar bg-purple"></div>
              </div>

              <!-- Total Transactions -->
              <div class="nice-stat-card border-orange">
                <div class="stat-body">
                  <div class="stat-left">
                    <span class="icon-indicator">📈</span>
                    <span class="stat-card-title">Total Transactions</span>
                  </div>
                  <span class="stat-card-val">{{ stats.totalTransactions }}</span>
                </div>
                <div class="progress-bar bg-orange"></div>
              </div>
            </div>

            <!-- Dashboard Analytics Grid -->
            <div class="analytics-grid">
              <!-- Left: Campaign Donut -->
              <div class="anal-card campaign-card">
                <h3>Campaign</h3>
                <div class="donut-wrapper">
                  <svg viewBox="0 0 100 100" width="120" height="120" class="donut-svg">
                    <circle cx="50" cy="50" r="40" fill="transparent" stroke="#f1f5f9" stroke-width="10" />
                    <!-- 60% Open -->
                    <circle cx="50" cy="50" r="40" fill="transparent" stroke="#0052cc" stroke-width="10" stroke-dasharray="251.2" stroke-dashoffset="100.4" />
                    <!-- 26% Click -->
                    <circle cx="50" cy="50" r="40" fill="transparent" stroke="#10b981" stroke-width="10" stroke-dasharray="251.2" stroke-dashoffset="165.8" transform="rotate(216 50 50)" />
                    <!-- 14% Bounced -->
                    <circle cx="50" cy="50" r="40" fill="transparent" stroke="#ffab00" stroke-width="10" stroke-dasharray="251.2" stroke-dashoffset="216.0" transform="rotate(310 50 50)" />
                  </svg>
                  <div class="donut-center">
                    <span class="donut-val">₹769</span>
                    <span class="donut-lbl">Earnings</span>
                  </div>
                </div>
                <div class="donut-labels">
                  <div class="lbl-item"><span class="dot bg-blue"></span> 60% Open</div>
                  <div class="lbl-item"><span class="dot bg-green"></span> 26% Click</div>
                  <div class="lbl-item"><span class="dot bg-orange"></span> 18% Bounce</div>
                </div>
              </div>

              <!-- Middle: Line Chart -->
              <div class="anal-card ratio-card">
                <div class="ratio-header">
                  <h3>Sales Ratio</h3>
                  <div class="ratio-legends">
                    <span class="legend"><span class="line-dot bg-blue"></span> This Week</span>
                    <span class="legend"><span class="line-dot bg-grey"></span> Last Week</span>
                  </div>
                </div>
                <div class="line-chart-wrapper">
                  <svg viewBox="0 0 500 200" class="svg-chart">
                    <!-- Grid Lines -->
                    <line x1="30" y1="20" x2="480" y2="20" stroke="#f1f5f9" stroke-width="1" />
                    <line x1="30" y1="60" x2="480" y2="60" stroke="#f1f5f9" stroke-width="1" />
                    <line x1="30" y1="100" x2="480" y2="100" stroke="#f1f5f9" stroke-width="1" />
                    <line x1="30" y1="140" x2="480" y2="140" stroke="#f1f5f9" stroke-width="1" />
                    <line x1="30" y1="170" x2="480" y2="170" stroke="#cbd5e1" stroke-width="2" />
                    <!-- Two Polylines representing two lines -->
                    <polyline fill="none" stroke="#e2e8f0" stroke-width="3" points="30,150 100,140 170,135 240,110 310,130 380,95 450,110" />
                    <polyline fill="none" stroke="#0052cc" stroke-width="4" points="30,120 100,105 170,115 240,80 310,65 380,90 450,45" />
                    <!-- Points -->
                    <circle cx="240" cy="80" r="4" fill="#0052cc" />
                    <circle cx="310" cy="65" r="4" fill="#0052cc" />
                  </svg>
                </div>
              </div>

              <!-- Right: Weather & User rates -->
              <div class="anal-card weather-card">
                <div class="weather-header">
                  <div>
                    <h4>Thursday</h4>
                    <span>12th April, 2026</span>
                  </div>
                  <h3>☀️ 35°</h3>
                </div>
                <div class="users-rate-box">
                  <div class="users-rate-header">
                    <span>Users</span>
                    <h3>35,658 <span class="green-text">+23%</span></h3>
                  </div>
                  <div class="users-splits">
                    <div>
                      <strong>58%</strong>
                      <span>New Users</span>
                    </div>
                    <div>
                      <strong>42%</strong>
                      <span>Repeat Users</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Bottom Analytics Grid -->
            <div class="bottom-analytics">
              <!-- Left: Sales Table -->
              <div class="anal-card sales-table-card">
                <h3>Latest Transactions</h3>
                <div class="table-container">
                  <table class="nice-table">
                    <thead>
                      <tr>
                        <th>Txn ID</th>
                        <th>User ID</th>
                        <th>Wallet</th>
                        <th>Amount</th>
                        <th>Status</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="txn in transactions.slice(0, 5)" :key="txn.id">
                        <td>#{{ txn.id }}</td>
                        <td>#{{ txn.user_id }}</td>
                        <td><span class="lbl-wallet" :class="txn.wallet_type.toLowerCase()">{{ txn.wallet_type }}</span></td>
                        <td class="font-bold">{{ txn.amount }}</td>
                        <td><span class="nice-badge-success">Success</span></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>

              <!-- Right: Region Sales Bar Chart -->
              <div class="anal-card region-card">
                <h3>Top Region Sales</h3>
                <div class="bar-chart-container">
                  <svg viewBox="0 0 400 150" class="svg-chart">
                    <line x1="20" y1="120" x2="380" y2="120" stroke="#cbd5e1" stroke-width="2" />
                    <!-- Color Bars -->
                    <rect x="40" y="40" width="18" height="80" fill="#3b82f6" rx="3" />
                    <rect x="90" y="20" width="18" height="100" fill="#f59e0b" rx="3" />
                    <rect x="140" y="50" width="18" height="70" fill="#8b5cf6" rx="3" />
                    <rect x="190" y="60" width="18" height="60" fill="#ef4444" rx="3" />
                    <rect x="240" y="70" width="18" height="50" fill="#10b981" rx="3" />
                    <rect x="290" y="30" width="18" height="90" fill="#3b82f6" rx="3" />
                  </svg>
                  <div class="region-stats">
                    <div>
                      <span class="green-text font-bold">+23%</span>
                      <strong>United States</strong>
                    </div>
                    <div>
                      <span class="blue-text font-bold">+0.5%</span>
                      <strong>Europe</strong>
                    </div>
                  </div>
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
        </div>
      </main>
    </div>
  </div>
</template>

<script>
const API_BASE_URL = 'https://api.srdigitalseva.com';

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
      users: [],
      fundRequests: [],
      adminsList: [],
      selectedUser: null,
      userPage: 1,
      loading: true,
      error: '',
      gatewayStatus: {
        database: 'Checking...',
        app_api: 'Checking...',
        scriza_api: 'Checking...',
        razorpay_gateway: 'Checking...'
      }
    }
  },
  computed: {
    pendingRequestsCount() {
      return this.fundRequests.filter(r => r.status === 'PENDING').length;
    }
  },
  watch: {
    currentTab(newTab) {
      if (newTab === 'dashboard') {
        this.fetchDashboardData();
        this.checkGatewayStatus();
      } else if (newTab === 'users') {
        this.fetchUsers();
      } else if (newTab === 'requests') {
        this.fetchFundRequests();
      } else if (newTab === 'admins') {
        this.fetchAdminsList();
      }
    }
  },
  mounted() {
    this.fetchDashboardData();
    this.checkGatewayStatus();
    this.fetchFundRequests();
  },
  methods: {
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
  padding: 1.5rem 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.menu-label {
  font-size: 0.7rem;
  font-weight: bold;
  color: #62728c;
  padding: 0.5rem 1rem;
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
  margin-top: auto;
  padding: 1.5rem 1rem;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

.logout-btn {
  background: rgba(239, 68, 68, 0.1);
  color: #f87171;
  border: 1px solid rgba(239, 68, 68, 0.2);
  width: 100%;
  padding: 0.6rem;
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

.topbar-search {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.topbar-search input {
  border: none;
  outline: none;
  font-size: 0.9rem;
  color: #3e5569;
}

.topbar-actions {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.action-icon {
  font-size: 1.15rem;
  cursor: pointer;
  opacity: 0.8;
}

.notification-bell {
  position: relative;
  cursor: pointer;
}

.bell-badge {
  background: #3b82f6;
  color: white;
  font-size: 0.6rem;
  font-weight: bold;
  padding: 0.1rem 0.35rem;
  border-radius: 99px;
  position: absolute;
  top: -5px;
  right: -5px;
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
  background: #e2e8f0;
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

/* Operational status */
.op-status-card {
  background: white;
  border-radius: 10px;
  padding: 1.25rem;
  box-shadow: 0 1px 15px rgba(0,0,0,0.03);
  margin-bottom: 2rem;
}

.op-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.op-card-header h4 {
  margin: 0;
  font-weight: 700;
}

.refresh-op-btn {
  background: #f8fafc;
  border: 1px solid #cbd5e1;
  font-size: 0.75rem;
  font-weight: bold;
  padding: 0.25rem 0.6rem;
  border-radius: 6px;
  cursor: pointer;
}

.op-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
}

.op-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.8rem;
}

.op-lbl {
  color: #64748b;
  font-weight: bold;
}

.op-status-tag {
  font-weight: bold;
}

.op-status-tag.green {
  color: #10b981;
}

.op-status-tag.orange {
  color: #f59e0b;
}

.op-status-tag.red {
  color: #ef4444;
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
}

.stat-left {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.stat-card-title {
  font-size: 0.75rem;
  font-weight: bold;
  color: #64748b;
  text-transform: uppercase;
}

.icon-indicator {
  font-size: 1.25rem;
}

.stat-card-val {
  font-size: 1.75rem;
  font-weight: 800;
  color: #3e5569;
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

/* User Profile Drawer slide over */
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
  height: 100%;
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
}

.profile-avatar-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
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
</style>
