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
        <router-link to="/admin-dashboard" class="nav-item">
          <span class="icon">📊</span> Dashboard
        </router-link>
        <router-link to="/admin-settings" class="nav-item active">
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
        <h2>Admin Settings</h2>
        <div class="admin-profile">
          <span class="email-badge">{{ adminEmail }}</span>
        </div>
      </header>

      <div class="settings-container">
        <!-- Change Password Card -->
        <div class="settings-card">
          <h3>Change Admin Password</h3>
          <p class="section-desc">Change the password used to access the administrator dashboard.</p>

          <form @submit.prevent="handleChangePassword" class="settings-form">
            <div class="input-group">
              <label for="oldPassword">Current Password</label>
              <input
                id="oldPassword"
                type="password"
                v-model="oldPassword"
                placeholder="Enter current password"
                required
              />
            </div>

            <div class="input-group">
              <label for="newPassword">New Password</label>
              <input
                id="newPassword"
                type="password"
                v-model="newPassword"
                placeholder="Enter new password"
                required
              />
            </div>

            <div class="input-group">
              <label for="confirmPassword">Confirm New Password</label>
              <input
                id="confirmPassword"
                type="password"
                v-model="confirmPassword"
                placeholder="Confirm new password"
                required
              />
            </div>

            <div v-if="passwordError" class="error-msg">
              {{ passwordError }}
            </div>

            <div v-if="passwordSuccess" class="success-msg">
              {{ passwordSuccess }}
            </div>

            <button type="submit" :disabled="loadingPassword" class="save-btn">
              <span v-if="loadingPassword">Updating password...</span>
              <span v-else>Update Password</span>
            </button>
          </form>
        </div>

        <!-- System Controls Card -->
        <div class="settings-card">
          <h3>System & Wallet Configurations</h3>
          <p class="section-desc">Configure parameters, maintenance window modes, and Android updates.</p>

          <form @submit.prevent="handleSaveSystemSettings" class="settings-form">
            <div class="input-group">
              <label for="minBalance">Minimum Wallet Balance (₹)</label>
              <input
                id="minBalance"
                type="number"
                step="0.01"
                v-model="systemSettings.min_wallet_balance"
                placeholder="e.g. 50.00"
                required
              />
            </div>

            <div class="input-group">
              <label for="forceVersion">Force Android App Version</label>
              <input
                id="forceVersion"
                type="text"
                v-model="systemSettings.force_update_version"
                placeholder="e.g. 1.0.0"
                required
              />
            </div>

            <div class="checkbox-group">
              <input
                id="maintenanceMode"
                type="checkbox"
                v-model="systemSettings.maintenance_mode_bool"
              />
              <label for="maintenanceMode">Enable Platform Maintenance Mode</label>
            </div>

            <div class="input-group">
              <label for="scrizaMode">Scriza API Active Mode</label>
              <select id="scrizaMode" v-model="systemSettings.scriza_api_mode">
                <option value="simulation">Simulation Mode (Simulate Callback)</option>
                <option value="production">Production Live Mode</option>
              </select>
            </div>

            <div class="input-group">
              <label for="razorpayMode">Razorpay Checkout Gateway</label>
              <select id="razorpayMode" v-model="systemSettings.razorpay_api_mode">
                <option value="test">Test Payments Mode</option>
                <option value="live">Live Payments Mode</option>
              </select>
            </div>

            <div v-if="systemError" class="error-msg">
              {{ systemError }}
            </div>

            <div v-if="systemSuccess" class="success-msg">
              {{ systemSuccess }}
            </div>

            <button type="submit" :disabled="loadingSystem" class="save-btn primary-bg">
              <span v-if="loadingSystem">Saving configuration...</span>
              <span v-else>Save System Preferences</span>
            </button>
          </form>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
const API_BASE_URL = 'https://api.srdigitalseva.com';

export default {
  name: 'AdminSettings',
  data() {
    return {
      adminEmail: localStorage.getItem('adminEmail') || 'haris@gmail.com',
      // Password states
      oldPassword: '',
      newPassword: '',
      confirmPassword: '',
      passwordError: '',
      passwordSuccess: '',
      loadingPassword: false,
      // System config states
      loadingSystem: false,
      systemError: '',
      systemSuccess: '',
      systemSettings: {
        min_wallet_balance: '50.00',
        maintenance_mode: 'false',
        maintenance_mode_bool: false,
        force_update_version: '1.0.0',
        scriza_api_mode: 'simulation',
        razorpay_api_mode: 'test'
      }
    }
  },
  mounted() {
    this.fetchSystemSettings();
  },
  methods: {
    async fetchSystemSettings() {
      const token = localStorage.getItem('adminToken');
      if (!token) return;
      
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/settings`, {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        });
        if (!response.ok) throw new Error('Failed to load system settings');
        const data = await response.json();
        
        this.systemSettings.min_wallet_balance = data.min_wallet_balance || '50.00';
        this.systemSettings.force_update_version = data.force_update_version || '1.0.0';
        this.systemSettings.scriza_api_mode = data.scriza_api_mode || 'simulation';
        this.systemSettings.razorpay_api_mode = data.razorpay_api_mode || 'test';
        this.systemSettings.maintenance_mode = data.maintenance_mode || 'false';
        this.systemSettings.maintenance_mode_bool = data.maintenance_mode === 'true';
      } catch (err) {
        console.error(err);
      }
    },
    async handleSaveSystemSettings() {
      this.systemError = '';
      this.systemSuccess = '';
      this.loadingSystem = true;
      const token = localStorage.getItem('adminToken');

      // Sync bool to string
      this.systemSettings.maintenance_mode = this.systemSettings.maintenance_mode_bool ? 'true' : 'false';

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
            razorpay_api_mode: this.systemSettings.razorpay_api_mode
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
        if (!response.ok) {
          throw new Error(data.error || 'Failed to update password');
        }

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
}

.email-badge {
  background: #e2e8f0;
  padding: 0.4rem 0.8rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 700;
  color: #475569;
}

.settings-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}

@media (max-width: 1024px) {
  .settings-container {
    grid-template-columns: 1fr;
  }
}

.settings-card {
  background: white;
  border-radius: 16px;
  padding: 2rem;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
}

.settings-card h3 {
  font-size: 1.25rem;
  font-weight: 800;
  color: #0f172a;
  margin: 0 0 0.5rem;
}

.section-desc {
  color: #64748b;
  font-size: 0.9rem;
  margin-bottom: 1.5rem;
}

.settings-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.input-group label {
  font-size: 0.85rem;
  font-weight: 700;
  color: #475569;
}

.input-group input,
.input-group select {
  padding: 0.75rem 1rem;
  border-radius: 10px;
  border: 1px solid #cbd5e1;
  font-family: inherit;
  font-size: 0.95rem;
  background: #f8fafc;
}

.checkbox-group {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin: 0.5rem 0;
}

.checkbox-group input {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.checkbox-group label {
  font-size: 0.9rem;
  font-weight: 600;
  color: #475569;
  cursor: pointer;
}

.save-btn {
  background: #0f172a;
  color: white;
  border: none;
  padding: 0.85rem;
  border-radius: 10px;
  font-weight: 700;
  cursor: pointer;
  transition: opacity 0.2s;
  margin-top: 1rem;
}

.save-btn:hover {
  opacity: 0.9;
}

.save-btn.primary-bg {
  background: #0052cc;
}

.error-msg {
  color: #ef4444;
  background: rgba(239, 68, 68, 0.05);
  border: 1px solid rgba(239, 68, 68, 0.1);
  padding: 0.75rem;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
}

.success-msg {
  color: #10b981;
  background: rgba(16, 185, 129, 0.05);
  border: 1px solid rgba(16, 185, 129, 0.1);
  padding: 0.75rem;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
}
</style>
