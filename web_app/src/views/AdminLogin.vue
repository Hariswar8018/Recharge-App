<template>
  <div class="login-wrapper">
    <div class="login-box">
      <div class="logo-area">
        <svg viewBox="0 0 100 100" width="50" height="50">
          <circle cx="50" cy="50" r="45" fill="none" stroke="#0052cc" stroke-width="8"/>
          <path d="M 30 50 L 45 65 L 70 35" fill="none" stroke="#e01a22" stroke-width="8" stroke-linecap="round"/>
        </svg>
        <h1>SR DIGITAL SEVA</h1>
        <p class="brand-subtitle">ADMIN CONTROL PORTAL</p>
      </div>

      <form @submit.prevent="handleLogin" class="login-form">
        <div class="input-group">
          <label for="email">Admin Email</label>
          <input
            id="email"
            type="email"
            v-model="email"
            placeholder="enter registered admin email"
            required
          />
        </div>

        <div class="input-group">
          <label for="password">Password</label>
          <input
            id="password"
            type="password"
            v-model="password"
            placeholder="Enter Password"
            required
          />
        </div>

        <div v-if="error" class="error-msg">
          {{ error }}
        </div>

        <button type="submit" :disabled="loading" class="login-btn">
          <span v-if="loading">Verifying...</span>
          <span v-else>Login to Dashboard &rarr;</span>
        </button>
      </form>

      <div class="back-link">
        <router-link to="/">&larr; Back to Landing Page</router-link>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdminLogin',
  data() {
    return {
      email: '',
      password: '',
      error: '',
      loading: false
    }
  },
  methods: {
    async handleLogin() {
      this.error = '';
      this.loading = true;
      try {
        const response = await fetch('http://localhost:5000/api/admin/login', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-app-token': 'my_secure_app_token_123'
          },
          body: JSON.stringify({
            email: this.email,
            password: this.password
          })
        });

        const data = await response.json();
        if (!response.ok) {
          throw new Error(data.error || 'Login failed');
        }

        // Store JWT token & Email
        localStorage.setItem('adminToken', data.token);
        localStorage.setItem('adminEmail', data.email);

        // Redirect to Dashboard
        this.$router.push('/admin-dashboard');
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.login-wrapper {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: radial-gradient(circle, #f0f4ff 0%, #dbeafe 100%);
  padding: 1.5rem;
}

.login-box {
  background: white;
  padding: 2.5rem;
  border-radius: 24px;
  width: 100%;
  max-width: 440px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

.logo-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 2rem;
  text-align: center;
}

.logo-area h1 {
  font-size: 1.5rem;
  font-weight: 850;
  color: #0052cc;
  margin: 0.75rem 0 0.1rem;
}

.brand-subtitle {
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 2px;
  color: #e01a22;
  margin: 0;
}

.login-form {
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

.login-btn {
  background: #0052cc;
  color: white;
  border: none;
  padding: 0.85rem;
  border-radius: 12px;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s;
}

.login-btn:hover:not(:disabled) {
  background: #004099;
  transform: translateY(-1px);
}

.login-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.back-link {
  margin-top: 1.5rem;
  text-align: center;
}

.back-link a {
  color: #64748b;
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 500;
  transition: color 0.2s;
}

.back-link a:hover {
  color: #0052cc;
}
</style>
