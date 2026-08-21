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
        <router-link to="/admin-dashboard" class="nav-item active">
          <span class="icon">📊</span> Dashboard
        </router-link>
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
        <h2>Dashboard Overview</h2>
        <div class="admin-profile">
          <span class="email-badge">{{ adminEmail }}</span>
        </div>
      </header>

      <div v-if="loading" class="loading-state">
        Loading dashboard metrics...
      </div>

      <div v-else-if="error" class="error-state">
        {{ error }}
      </div>

      <div v-else class="dashboard-grid">
        <!-- Stats Cards -->
        <div class="stats-row">
          <div class="stat-card">
            <span class="stat-label">Total Registered Users</span>
            <span class="stat-val">{{ stats.totalUsers }}</span>
          </div>
          <div class="stat-card">
            <span class="stat-label">Total User Wallets Balance</span>
            <span class="stat-val">₹ {{ stats.totalWalletBalance.toLocaleString('en-IN', { minimumFractionDigits: 2 }) }}</span>
          </div>
          <div class="stat-card">
            <span class="stat-label">Transactions Performed</span>
            <span class="stat-val">{{ stats.totalTransactions }}</span>
          </div>
        </div>

        <!-- Registered Users List -->
        <div class="table-card">
          <h3>Registered Mobile App Users</h3>
          <div class="table-container">
            <table class="data-table">
              <thead>
                <tr>
                  <th>User ID</th>
                  <th>Full Name</th>
                  <th>Email</th>
                  <th>Mobile Number</th>
                  <th>Wallet Balance</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="user in users" :key="user.id">
                  <td>#{{ user.id }}</td>
                  <td class="font-bold">{{ user.fullName }}</td>
                  <td>{{ user.email }}</td>
                  <td>{{ user.mobileNumber }}</td>
                  <td>₹ {{ user.walletBalance.toFixed(2) }}</td>
                  <td>
                    <span class="status-badge active">{{ user.status }}</span>
                  </td>
                </tr>
                <tr v-if="users.length === 0">
                  <td colspan="6" class="empty-row">No users registered yet. Users will appear here after registering on the Flutter app.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Transactions History -->
        <div class="table-card">
          <h3>Recent Transactions</h3>
          <div class="table-container">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Txn ID</th>
                  <th>Type</th>
                  <th>Amount</th>
                  <th>Date & Time</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="txn in transactions" :key="txn.id">
                  <td>#{{ txn.id }}</td>
                  <td>{{ txn.type }}</td>
                  <td>{{ txn.amount }}</td>
                  <td>{{ txn.date }}</td>
                  <td>
                    <span class="status-badge txn-success">{{ txn.status }}</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
export default {
  name: 'AdminDashboard',
  data() {
    return {
      adminEmail: localStorage.getItem('adminEmail') || 'hari@gmail.com',
      stats: {
        totalUsers: 0,
        totalWalletBalance: 0,
        totalTransactions: 0
      },
      users: [],
      transactions: [],
      loading: true,
      error: ''
    }
  },
  mounted() {
    this.fetchDashboardData();
  },
  methods: {
    async fetchDashboardData() {
      const token = localStorage.getItem('adminToken');
      if (!token) {
        this.$router.push('/admin-login');
        return;
      }
      try {
        const response = await fetch('http://localhost:5000/api/admin/dashboard', {
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
        this.users = data.users;
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
  color: #94a3b8;
  text-decoration: none;
  padding: 0.75rem 1rem;
  border-radius: 10px;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-weight: 600;
  transition: all 0.2s;
}

.nav-item:hover, .nav-item.active {
  color: white;
  background: #1e293b;
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
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
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
  font-size: 1.75rem;
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

.status-badge {
  display: inline-block;
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 700;
}

.status-badge.active {
  background: #dcfce7;
  color: #15803d;
}

.status-badge.txn-success {
  background: #dcfce7;
  color: #15803d;
}

.empty-row {
  text-align: center;
  color: #94a3b8;
  padding: 2rem !important;
}
</style>
