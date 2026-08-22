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

            <div v-if="error" class="error-msg">
              {{ error }}
            </div>

            <div v-if="success" class="success-msg">
              {{ success }}
            </div>

            <button type="submit" :disabled="loading" class="save-btn">
              <span v-if="loading">Updating password...</span>
              <span v-else>Update Password</span>
            </button>
          </form>
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
  name: 'AdminSettings',
  data() {
    return {
      adminEmail: localStorage.getItem('adminEmail') || 'hari@gmail.com',
      oldPassword: '',
      newPassword: '',
      confirmPassword: '',
      error: '',
      success: '',
      loading: false
    }
  },
  methods: {
    async handleChangePassword() {
      this.error = '';
      this.success = '';

      if (this.newPassword !== this.confirmPassword) {
        this.error = 'New passwords do not match';
        return;
      }

      this.loading = true;
      const token = localStorage.getItem('adminToken');

      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/change-password`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
            'x-app-token': import.meta.env.VITE_APP_TOKEN || '495cd158fe203c3a19b2a60bdaa3c3ae29581042247c56aec2c1ee3d2bd82f01'
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

        this.success = 'Admin password has been changed successfully.';
        this.oldPassword = '';
        this.newPassword = '';
        this.confirmPassword = '';
      } catch (err) {
        this.error = err.message;
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

.settings-container {
  display: flex;
  justify-content: flex-start;
}

.settings-card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02), 0 2px 4px -1px rgba(0,0,0,0.02);
  border: 1px solid #f1f5f9;
  padding: 2rem;
  width: 100%;
  max-width: 500px;
}

.settings-card h3 {
  margin: 0;
  font-size: 1.2rem;
  font-weight: 750;
  color: #0f172a;
}

.section-desc {
  font-size: 0.85rem;
  color: #64748b;
  margin: 0.5rem 0 1.5rem;
}

.settings-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.input-group label {
  font-size: 0.85rem;
  font-weight: 600;
  color: #475569;
}

.input-group input {
  padding: 0.75rem 1rem;
  border-radius: 10px;
  border: 1.5px solid #e2e8f0;
  font-size: 0.95rem;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.input-group input:focus {
  outline: none;
  border-color: #0052cc;
  box-shadow: 0 0 0 3px rgba(0, 82, 204, 0.1);
}

.error-msg {
  background: #fef2f2;
  color: #ef4444;
  border: 1px solid #fee2e2;
  padding: 0.75rem;
  border-radius: 10px;
  font-size: 0.85rem;
  font-weight: 500;
}

.success-msg {
  background: #f0fdf4;
  color: #16a34a;
  border: 1px solid #dcfce7;
  padding: 0.75rem;
  border-radius: 10px;
  font-size: 0.85rem;
  font-weight: 500;
}

.save-btn {
  background: #0052cc;
  color: white;
  border: none;
  padding: 0.85rem;
  border-radius: 10px;
  font-weight: 600;
  font-size: 0.95rem;
  cursor: pointer;
  transition: all 0.2s;
  margin-top: 0.5rem;
}

.save-btn:hover:not(:disabled) {
  background: #004099;
}

.save-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}
</style>
