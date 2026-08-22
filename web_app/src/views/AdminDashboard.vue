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
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="user in users" :key="user.id">
                    <td>#{{ user.id }}</td>
                    <td class="font-bold">{{ user.fullName }}</td>
                    <td>{{ user.email }}</td>
                    <td>{{ user.mobileNumber }}</td>
                    <td>₹ {{ parseFloat(user.main_wallet_balance).toFixed(2) }}</td>
                    <td>₹ {{ parseFloat(user.fund_wallet_balance).toFixed(2) }}</td>
                    <td>
                      <span class="status-badge active">{{ user.status }}</span>
                    </td>
                  </tr>
                  <tr v-if="users.length === 0">
                    <td colspan="7" class="empty-row">No users registered yet.</td>
                  </tr>
                </tbody>
              </table>
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
      </div>
    </main>
  </div>
</template>

<script>
const API_BASE_URL = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1'
  ? 'http://localhost:5000'
  : 'https://api.srdigitalseva.com';

export default {
  name: 'AdminDashboard',
  data() {
    return {
      currentTab: 'dashboard',
      adminEmail: localStorage.getItem('adminEmail') || 'hari@gmail.com',
      stats: {
        totalUsers: 0,
        totalFundWallet: 0,
        totalMainWallet: 0,
        totalTransactions: 0
      },
      users: [],
      transactions: [],
      fundRequests: [],
      userPage: 1,
      loading: true,
      error: ''
    }
  },
  computed: {
    tabTitle() {
      switch (this.currentTab) {
        case 'dashboard': return 'Dashboard Overview';
        case 'users': return 'Registered Users List';
        case 'requests': return 'Fund Deposit Requests';
        default: return 'Dashboard';
      }
    },
    pendingRequestsCount() {
      return this.fundRequests.filter(r => r.status === 'PENDING').length;
    }
  },
  mounted() {
    this.fetchDashboardData();
    this.fetchFundRequests();
  },
  watch: {
    currentTab(newTab) {
      if (newTab === 'users') {
        this.fetchUsers();
      } else if (newTab === 'requests') {
        this.fetchFundRequests();
      } else {
        this.fetchDashboardData();
      }
    }
  },
  methods: {
    async fetchDashboardData() {
      const token = localStorage.getItem('adminToken');
      if (!token) {
        this.$router.push('/admin-login');
        return;
      }
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/dashboard`, {
          headers: {
            'Authorization': `Bearer ${token}`,
            'x-app-token': 'my_secure_app_token_123'
          }
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
          headers: {
            'Authorization': `Bearer ${token}`,
            'x-app-token': 'my_secure_app_token_123'
          }
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
          headers: {
            'Authorization': `Bearer ${token}`,
            'x-app-token': 'my_secure_app_token_123'
          }
        });
        const data = await response.json();
        this.fundRequests = data;
      } catch (err) {
        console.error(err);
      }
    },
    async processRequest(id, approve) {
      const token = localStorage.getItem('adminToken');
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/fund-requests/${id}/approve`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
            'x-app-token': 'my_secure_app_token_123'
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
    changeUserPage(direction) {
      this.userPage += direction;
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
  text-align: left;
  color: #94a3b8;
  padding: 0.75rem 1rem;
  border-radius: 10px;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-weight: 600;
  font-size: 0.95rem;
  cursor: pointer;
  width: 100%;
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

.stats-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1.5rem;
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02), 0 2px 4px -1px rgba(0,0,0,0.02);
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

.table-card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02), 0 2px 4px -1px rgba(0,0,0,0.02);
  border: 1px solid #f1f5f9;
  padding: 1.5rem;
}

.table-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.25rem;
}

.table-header-row h3 {
  margin: 0;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.page-btn {
  background: #f1f5f9;
  border: none;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.8rem;
  color: #475569;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.table-card h3 {
  margin: 0 0 1.25rem 0;
  font-size: 1.1rem;
  font-weight: 750;
  color: #0f172a;
}

.table-container {
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
  font-size: 0.9rem;
}

.data-table th {
  padding: 0.75rem 1rem;
  background: #f8fafc;
  color: #64748b;
  font-weight: 600;
  border-bottom: 1.5px solid #e2e8f0;
}

.data-table td {
  padding: 1rem;
  border-bottom: 1px solid #f1f5f9;
  color: #334155;
}

.font-bold {
  font-weight: 600;
  color: #0f172a;
}

.text-blue {
  color: #0052cc;
}

.badge-wallet {
  display: inline-block;
  padding: 0.15rem 0.4rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 750;
  text-transform: uppercase;
}

.badge-wallet.fund {
  background: #eff6ff;
  color: #2563eb;
}

.badge-wallet.main {
  background: #f0fdf4;
  color: #16a34a;
}

.status-badge {
  display: inline-block;
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 700;
}

.status-badge.active, .status-badge.approved {
  background: #dcfce7;
  color: #15803d;
}

.status-badge.pending {
  background: #fef3c7;
  color: #d97706;
}

.status-badge.rejected {
  background: #fee2e2;
  color: #b91c1c;
}

.empty-row {
  text-align: center;
  color: #94a3b8;
  padding: 2rem !important;
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
}

.approve-btn {
  background: #16a34a;
  color: white;
  border: none;
  padding: 0.35rem 0.7rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.8rem;
}

.reject-btn {
  background: #ef4444;
  color: white;
  border: none;
  padding: 0.35rem 0.7rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.8rem;
}
</style>
