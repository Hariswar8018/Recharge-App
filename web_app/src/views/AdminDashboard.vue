<template>
  <div class="admin-layout">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="sidebar-logo">
        <svg viewBox="0 0 100 100" width="36" height="36">
          <circle cx="50" cy="50" r="45" fill="none" stroke="#fff" stroke-width="8"/>
          <path d="M 30 50 L 45 65 L 70 35" fill="none" stroke="#ffeb3b" stroke-width="8" stroke-linecap="round"/>
        </svg>
        <span class="logo-text">SR ADMIN</span>
      </div>
      <nav class="sidebar-nav">
        <button @click="currentTab = 'dashboard'" class="nav-item" :class="{ active: currentTab === 'dashboard' }">
          <span class="icon">📊</span> Dashboard
        </button>
        <button @click="currentTab = 'users'" class="nav-item" :class="{ active: currentTab === 'users' }">
          <span class="icon">👤</span> Users List
        </button>
        <button @click="currentTab = 'requests'" class="nav-item" :class="{ active: currentTab === 'requests' }">
          <span class="icon">📥</span> Fund Requests
          <span v-if="pendingRequestsCount > 0" class="badge-count">{{ pendingRequestsCount }}</span>
        </button>
        <button @click="currentTab = 'admins'" class="nav-item" :class="{ active: currentTab === 'admins' }">
          <span class="icon">🛡️</span> System Admins
        </button>
        <router-link to="/admin-settings" class="nav-item">
          <span class="icon">⚙️</span> Settings
        </router-link>
      </nav>
      <div class="sidebar-footer">
        <button @click="handleLogout" class="logout-btn">
          Logout &rarr;
        </button>
      </div>
    </aside>

    <!-- Main Content Area -->
    <main class="main-content">
      <header class="main-header">
        <h2>{{ tabTitle }}</h2>
        <div class="admin-profile">
          <span class="email-badge">{{ adminEmail }}</span>
        </div>
      </header>

      <!-- API & Gateway Live Operational Status Grid (Shows at the very top of home/dashboard) -->
      <section v-if="currentTab === 'dashboard'" class="operational-status-section">
        <div class="op-status-header">
          <h3>🖥️ Systems & API Operational Status</h3>
          <button @click="checkGatewayStatus" class="refresh-op-btn">🔄 Refresh Status</button>
        </div>
        <div class="op-status-grid">
          <div class="op-card">
            <span class="op-lbl">Main Database Connection</span>
            <span class="op-badge" :class="gatewayStatus.database === 'Operational' ? 'green' : 'red'">
              ● {{ gatewayStatus.database }}
            </span>
          </div>
          <div class="op-card">
            <span class="op-lbl">Recharge App API Server</span>
            <span class="op-badge" :class="gatewayStatus.app_api === 'Operational' ? 'green' : 'red'">
              ● {{ gatewayStatus.app_api }}
            </span>
          </div>
          <div class="op-card">
            <span class="op-lbl">Scriza API Gateway Connection</span>
            <span class="op-badge" :class="gatewayStatus.scriza_api && gatewayStatus.scriza_api.includes('Operational') ? 'green' : 'orange'">
              ● {{ gatewayStatus.scriza_api }}
            </span>
          </div>
          <div class="op-card">
            <span class="op-lbl">Razorpay Payment Gateway</span>
            <span class="op-badge" :class="gatewayStatus.razorpay_gateway && gatewayStatus.razorpay_gateway.includes('Operational') ? 'green' : 'orange'">
              ● {{ gatewayStatus.razorpay_gateway }}
            </span>
          </div>
          <div class="op-card">
            <span class="op-lbl">Redis Cache Cluster</span>
            <span class="op-badge" :class="gatewayStatus.redis_cache === 'Operational' ? 'green' : 'orange'">
              ● {{ gatewayStatus.redis_cache }}
            </span>
          </div>
        </div>
      </section>

      <div v-if="loading" class="loading-state">
        Loading data...
      </div>

      <div v-else-if="error" class="error-state">
        {{ error }}
      </div>

      <div v-else class="dashboard-grid">
        <!-- TAB 1: DASHBOARD VIEW -->
        <div v-if="currentTab === 'dashboard'" class="tab-pane">
          <!-- Stats Cards -->
          <div class="stats-row">
            <div class="stat-card">
              <span class="stat-label">Total Users</span>
              <span class="stat-val">{{ stats.totalUsers }}</span>
            </div>
            <div class="stat-card">
              <span class="stat-label">Main Wallet Balance</span>
              <span class="stat-val">₹ {{ stats.totalMainWallet.toLocaleString('en-IN', { minimumFractionDigits: 2 }) }}</span>
            </div>
            <div class="stat-card">
              <span class="stat-label">Fund Wallet Balance</span>
              <span class="stat-val">₹ {{ stats.totalFundWallet.toLocaleString('en-IN', { minimumFractionDigits: 2 }) }}</span>
            </div>
            <div class="stat-card">
              <span class="stat-label">Total Transactions</span>
              <span class="stat-val">{{ stats.totalTransactions }}</span>
            </div>
          </div>

          <!-- Charts Row -->
          <div class="charts-row">
            <!-- Transaction volume line chart -->
            <div class="chart-card">
              <h3>Monthly Transaction Trends</h3>
              <div class="chart-container">
                <svg viewBox="0 0 500 200" class="svg-chart">
                  <!-- Grid lines -->
                  <line x1="40" y1="20" x2="480" y2="20" stroke="#f1f5f9" stroke-width="1" />
                  <line x1="40" y1="70" x2="480" y2="70" stroke="#f1f5f9" stroke-width="1" />
                  <line x1="40" y1="120" x2="480" y2="120" stroke="#f1f5f9" stroke-width="1" />
                  <line x1="40" y1="170" x2="480" y2="170" stroke="#cbd5e1" stroke-width="2" />
                  <!-- Line path representing data -->
                  <polyline fill="none" stroke="#0052cc" stroke-width="4" points="40,150 110,120 180,130 250,90 320,60 390,80 460,30" />
                  <g fill="#0052cc">
                    <circle cx="40" cy="150" r="5" />
                    <circle cx="110" cy="120" r="5" />
                    <circle cx="180" cy="130" r="5" />
                    <circle cx="250" cy="90" r="5" />
                    <circle cx="320" cy="60" r="5" />
                    <circle cx="390" cy="80" r="5" />
                    <circle cx="460" cy="30" r="5" />
                  </g>
                  <!-- Labels -->
                  <text x="40" y="190" class="chart-lbl">Feb</text>
                  <text x="110" y="190" class="chart-lbl">Mar</text>
                  <text x="180" y="190" class="chart-lbl">Apr</text>
                  <text x="250" y="190" class="chart-lbl">May</text>
                  <text x="320" y="190" class="chart-lbl">Jun</text>
                  <text x="390" y="190" class="chart-lbl">Jul</text>
                  <text x="460" y="190" class="chart-lbl">Aug</text>
                </svg>
              </div>
            </div>

            <!-- Registration growth bar chart -->
            <div class="chart-card">
              <h3>User Registration Rates</h3>
              <div class="chart-container">
                <svg viewBox="0 0 500 200" class="svg-chart">
                  <line x1="40" y1="20" x2="480" y2="20" stroke="#f1f5f9" stroke-width="1" />
                  <line x1="40" y1="170" x2="480" y2="170" stroke="#cbd5e1" stroke-width="2" />
                  <!-- Bar representations -->
                  <rect x="60" y="130" width="30" height="40" fill="#0052cc" rx="4" />
                  <rect x="130" y="100" width="30" height="70" fill="#0052cc" rx="4" />
                  <rect x="200" y="110" width="30" height="60" fill="#0052cc" rx="4" />
                  <rect x="270" y="80" width="30" height="90" fill="#0052cc" rx="4" />
                  <rect x="340" y="50" width="30" height="120" fill="#3b82f6" rx="4" />
                  <rect x="410" y="30" width="30" height="140" fill="#2563eb" rx="4" />
                  <!-- Labels -->
                  <text x="75" y="190" text-anchor="middle" class="chart-lbl">Mar</text>
                  <text x="145" y="190" text-anchor="middle" class="chart-lbl">Apr</text>
                  <text x="215" y="190" text-anchor="middle" class="chart-lbl">May</text>
                  <text x="285" y="190" text-anchor="middle" class="chart-lbl">Jun</text>
                  <text x="355" y="190" text-anchor="middle" class="chart-lbl">Jul</text>
                  <text x="425" y="190" text-anchor="middle" class="chart-lbl">Aug</text>
                </svg>
              </div>
            </div>
          </div>

          <!-- Transactions list -->
          <div class="table-card">
            <h3>Recent Transactions</h3>
            <div class="table-container">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Txn ID</th>
                    <th>User ID</th>
                    <th>Wallet Type</th>
                    <th>Amount</th>
                    <th>Type</th>
                    <th>Date & Time</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="txn in transactions" :key="txn.id">
                    <td>#{{ txn.id }}</td>
                    <td>#{{ txn.user_id }}</td>
                    <td>
                      <span class="badge-wallet" :class="txn.wallet_type.toLowerCase()">
                        {{ txn.wallet_type }}
                      </span>
                    </td>
                    <td class="font-bold">{{ txn.amount }}</td>
                    <td>{{ txn.type }}</td>
                    <td>{{ txn.date }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- TAB 2: USERS VIEW -->
        <div v-if="currentTab === 'users'" class="tab-pane">
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
              <table class="data-table">
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
                  <tr v-for="user in users" :key="user.id" class="user-row" @click="selectUser(user)">
                    <td>#{{ user.id }}</td>
                    <td class="font-bold">{{ user.fullName }}</td>
                    <td>{{ user.email }}</td>
                    <td>{{ user.mobileNumber }}</td>
                    <td>₹ {{ parseFloat(user.main_wallet_balance).toFixed(2) }}</td>
                    <td>₹ {{ parseFloat(user.fund_wallet_balance).toFixed(2) }}</td>
                    <td>
                      <button class="details-link-btn">View Profile &rarr;</button>
                    </td>
                  </tr>
                  <tr v-if="users.length === 0">
                    <td colspan="7" class="empty-row">No users registered yet.</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- User Details Modal Slide-Over -->
          <div v-if="selectedUser" class="slide-over-backdrop" @click="selectedUser = null">
            <div class="slide-over-content" @click.stop>
              <div class="slide-over-header">
                <h3>User Profile Details</h3>
                <button @click="selectedUser = null" class="close-slide-btn">&times;</button>
              </div>
              <div class="slide-over-body">
                <div class="user-avatar-section">
                  <div class="user-init-avatar">{{ selectedUser.fullName[0].toUpperCase() }}</div>
                  <h4>{{ selectedUser.fullName }}</h4>
                  <span class="status-pill active">{{ selectedUser.status }}</span>
                </div>

                <div class="detail-cards-row">
                  <div class="mini-bal-card main-grad">
                    <span>Main Balance</span>
                    <h3>₹ {{ parseFloat(selectedUser.main_wallet_balance).toFixed(2) }}</h3>
                  </div>
                  <div class="mini-bal-card fund-grad">
                    <span>Fund Balance</span>
                    <h3>₹ {{ parseFloat(selectedUser.fund_wallet_balance).toFixed(2) }}</h3>
                  </div>
                </div>

                <div class="info-list">
                  <div class="info-row">
                    <span class="info-lbl">Email Address</span>
                    <span class="info-val">{{ selectedUser.email }}</span>
                  </div>
                  <div class="info-row">
                    <span class="info-lbl">Mobile Number</span>
                    <span class="info-val">{{ selectedUser.mobileNumber }}</span>
                  </div>
                  <div class="info-row">
                    <span class="info-lbl">Downline Team Members</span>
                    <span class="info-val font-bold text-blue">14 Agents</span>
                  </div>
                  <div class="info-row">
                    <span class="info-lbl">Referral Code</span>
                    <span class="info-val font-mono">REF{{ selectedUser.id }}026</span>
                  </div>
                  <div class="info-row">
                    <span class="info-lbl">Commission Tier</span>
                    <span class="info-val">Standard Level (3.5%)</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- TAB 3: FUND REQUESTS VIEW -->
        <div v-if="currentTab === 'requests'" class="tab-pane">
          <div class="table-card">
            <h3>Pending Deposit Approvals</h3>
            <div class="table-container">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Req ID</th>
                    <th>User Name</th>
                    <th>User Email</th>
                    <th>Requested Amount</th>
                    <th>Created At</th>
                    <th>Status</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="req in fundRequests" :key="req.id">
                    <td>#{{ req.id }}</td>
                    <td class="font-bold">{{ req.fullName }}</td>
                    <td>{{ req.email }}</td>
                    <td class="font-bold text-blue">₹ {{ parseFloat(req.amount).toFixed(2) }}</td>
                    <td>{{ new Date(req.createdAt).toLocaleString() }}</td>
                    <td>
                      <span class="status-badge" :class="req.status.toLowerCase()">{{ req.status }}</span>
                    </td>
                    <td>
                      <div v-if="req.status === 'PENDING'" class="action-buttons">
                        <button @click="processRequest(req.id, true)" class="approve-btn">Approve</button>
                        <button @click="processRequest(req.id, false)" class="reject-btn">Reject</button>
                      </div>
                      <span v-else class="text-muted">Processed</span>
                    </td>
                  </tr>
                  <tr v-if="fundRequests.length === 0">
                    <td colspan="7" class="empty-row">No fund deposit requests submitted.</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- TAB 4: SYSTEM ADMINS VIEW -->
        <div v-if="currentTab === 'admins'" class="tab-pane">
          <div class="table-card">
            <h3>System Administrators</h3>
            <div class="table-container">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Admin ID</th>
                    <th>Full Name</th>
                    <th>Email Address</th>
                    <th>Mobile Number</th>
                    <th>Permission Level</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="admin in adminsList" :key="admin.id">
                    <td>#{{ admin.id }}</td>
                    <td class="font-bold">{{ admin.fullName }}</td>
                    <td>{{ admin.email }}</td>
                    <td>{{ admin.mobileNumber }}</td>
                    <td><span class="badge-wallet fund">Full Superuser</span></td>
                    <td><span class="status-badge active">ACTIVE</span></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </main>
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
        razorpay_gateway: 'Checking...',
        redis_cache: 'Checking...'
      }
    }
  },
  computed: {
    tabTitle() {
      switch (this.currentTab) {
        case 'dashboard': return 'Dashboard Overview';
        case 'users': return 'Mobile Portal Users';
        case 'requests': return 'Deposit Requests Approval';
        case 'admins': return 'System Administrator Staff';
        default: return 'Management Console';
      }
    },
    pendingRequestsCount() {
      return this.fundRequests.filter(r => r.status === 'PENDING').length;
    }
  },
  watch: {
    currentTab(newTab) {
      this.selectedUser = null;
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
    this.fetchFundRequests(); // Preload for pending badge count
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
          scriza_api: 'Error connecting',
          razorpay_gateway: 'Error connecting',
          redis_cache: 'Offline'
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
          throw new Error(data.error || 'Failed to fetch dashboard data');
        }
        this.stats = data.stats;
        this.transactions = data.transactions;
      } catch (err) {
        this.error = err.message;
        if (err.message.includes('Forbidden') || err.message.includes('Unauthorized')) {
          this.handleLogout();
        }
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
        const data = await response.json();
        this.fundRequests = data;
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
  background: #f8fafc;
  font-family: 'Inter', system-ui, sans-serif;
}

.sidebar {
  width: 260px;
  background: #0f172a;
  color: white;
  display: flex;
  flex-direction: column;
  padding: 1.5rem;
}

.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 1.2rem;
  font-weight: 800;
  letter-spacing: 1px;
  margin-bottom: 2.5rem;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  flex: 1;
}

.nav-item {
  background: transparent;
  border: none;
  color: #94a3b8;
  text-decoration: none;
  padding: 0.75rem 1rem;
  border-radius: 10px;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-weight: 600;
  cursor: pointer;
  width: 100%;
  text-align: left;
  transition: all 0.2s;
}

.nav-item:hover, .nav-item.active {
  color: white;
  background: #1e293b;
}

.badge-count {
  background: #ef4444;
  color: white;
  font-size: 0.75rem;
  padding: 0.15rem 0.4rem;
  border-radius: 9999px;
  margin-left: auto;
  font-weight: 800;
}

.sidebar-footer {
  margin-top: auto;
}

.logout-btn {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  border: 1px solid rgba(239, 68, 68, 0.2);
  width: 100%;
  padding: 0.75rem;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s;
}

.logout-btn:hover {
  background: #ef4444;
  color: white;
}

.main-content {
  flex: 1;
  padding: 2rem;
  display: flex;
  flex-direction: column;
  gap: 2rem;
  overflow-y: auto;
}

.main-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #e2e8f0;
  padding-bottom: 1rem;
}

.main-header h2 {
  font-weight: 800;
  color: #0f172a;
  margin: 0;
}

.email-badge {
  background: #e2e8f0;
  color: #475569;
  padding: 0.4rem 0.8rem;
  border-radius: 9999px;
  font-size: 0.85rem;
  font-weight: 600;
}

/* Operational Status Grid */
.operational-status-section {
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
}

.op-status-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.op-status-header h3 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 800;
  color: #1e293b;
}

.refresh-op-btn {
  background: #f1f5f9;
  border: 1px solid #cbd5e1;
  padding: 0.4rem 0.8rem;
  border-radius: 8px;
  font-size: 0.8rem;
  font-weight: bold;
  cursor: pointer;
}

.op-status-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.op-card {
  background: #f8fafc;
  padding: 1rem;
  border-radius: 12px;
  border: 1px solid #f1f5f9;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.op-lbl {
  font-size: 0.75rem;
  color: #64748b;
  font-weight: bold;
}

.op-badge {
  font-size: 0.85rem;
  font-weight: 800;
}

.op-badge.green {
  color: #10b981;
}

.op-badge.orange {
  color: #f59e0b;
}

.op-badge.red {
  color: #ef4444;
}

/* Stats view */
.stats-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1.5rem;
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02);
  border: 1px solid #f1f5f9;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.stat-label {
  font-size: 0.85rem;
  font-weight: 600;
  color: #64748b;
}

.stat-val {
  font-size: 1.65rem;
  font-weight: 800;
  color: #0f172a;
}

/* Charts styles */
.charts-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
}

@media (max-width: 1024px) {
  .charts-row {
    grid-template-columns: 1fr;
  }
}

.svg-chart {
  width: 100%;
  height: 200px;
}

.chart-lbl {
  font-size: 0.65rem;
  fill: #94a3b8;
  font-weight: bold;
}

/* Tables and User Rows */
.table-card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02);
  border: 1px solid #cbd5e1;
  padding: 1.5rem;
}

.user-row {
  cursor: pointer;
  transition: background 0.15s;
}

.user-row:hover {
  background: #f8fafc;
}

.details-link-btn {
  background: #e6f0ff;
  color: #0052cc;
  border: none;
  padding: 0.35rem 0.75rem;
  border-radius: 8px;
  font-weight: bold;
  cursor: pointer;
  font-size: 0.75rem;
}

/* Slide over details panel */
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

.slide-over-content {
  width: 100%;
  max-width: 420px;
  background: white;
  height: 100%;
  box-shadow: -10px 0 30px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from { transform: translateX(100%); }
  to { transform: translateX(0); }
}

.slide-over-header {
  padding: 1.5rem;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.slide-over-header h3 {
  margin: 0;
  font-weight: 800;
  color: #0f172a;
}

.close-slide-btn {
  background: none;
  border: none;
  font-size: 2rem;
  cursor: pointer;
  color: #64748b;
}

.slide-over-body {
  padding: 2rem 1.5rem;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.user-avatar-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.user-init-avatar {
  width: 64px;
  height: 64px;
  background: #0052cc;
  color: white;
  font-size: 1.75rem;
  font-weight: 900;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.user-avatar-section h4 {
  margin: 0.5rem 0 0;
  font-size: 1.25rem;
  font-weight: 800;
}

.detail-cards-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.mini-bal-card {
  padding: 1rem;
  border-radius: 12px;
  color: white;
  display: flex;
  flex-direction: column;
}

.mini-bal-card span {
  font-size: 0.7rem;
  opacity: 0.8;
}

.mini-bal-card h3 {
  margin: 0.25rem 0 0;
  font-size: 1.15rem;
  font-weight: 900;
}

.main-grad {
  background: linear-gradient(135deg, #0d47a1 0%, #1976d2 100%);
}

.fund-grad {
  background: linear-gradient(135deg, #0052cc 0%, #3b82f6 100%);
}

.info-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  border-top: 1px solid #f1f5f9;
  padding-top: 1.5rem;
}

.info-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.85rem;
}

.info-lbl {
  color: #64748b;
  font-weight: bold;
}

.info-val {
  color: #1e293b;
}

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
  gap: 1rem;
}

.page-btn {
  background: #f1f5f9;
  border: 1px solid #cbd5e1;
  padding: 0.4rem 0.8rem;
  border-radius: 8px;
  cursor: pointer;
}

.page-num {
  font-size: 0.85rem;
  font-weight: bold;
}

.loading-state, .error-state {
  padding: 4rem;
  text-align: center;
  background: white;
  border-radius: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  font-weight: 600;
}

.error-state {
  color: #ef4444;
  border: 1px solid #fee2e2;
  background: #fef2f2;
}

.dashboard-grid {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.table-container {
  width: 100%;
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
}

.data-table th,
.data-table td {
  padding: 1rem;
  border-bottom: 1px solid #e2e8f0;
}

.data-table th {
  color: #64748b;
  font-weight: bold;
  font-size: 0.85rem;
  text-transform: uppercase;
}

.data-table td {
  font-size: 0.95rem;
  color: #1e293b;
}

.font-bold {
  font-weight: bold;
}

.text-blue {
  color: #0052cc;
}

.badge-wallet {
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: bold;
}

.badge-wallet.main {
  background: #e6f0ff;
  color: #0052cc;
}

.badge-wallet.fund {
  background: #e8f5e9;
  color: #2e7d32;
}

.status-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: bold;
}

.status-badge.active {
  background: #e8f5e9;
  color: #2e7d32;
}

.status-badge.pending {
  background: #fff3e0;
  color: #ef6c00;
}

.status-badge.approved {
  background: #e8f5e9;
  color: #2e7d32;
}

.status-badge.rejected {
  background: #ffebee;
  color: #c62828;
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
}

.approve-btn {
  background: #2e7d32;
  color: white;
  border: none;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: bold;
}

.reject-btn {
  background: #c62828;
  color: white;
  border: none;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: bold;
}

.text-muted {
  color: #94a3b8;
}
</style>
