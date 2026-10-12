<template>
  <div class="admin-portal-wrapper">
    <AdminDashboard v-if="isAuthenticated" @logout="handleLogout" />
    <AdminLogin v-else @login-success="handleLoginSuccess" />
  </div>
</template>

<script>
import AdminLogin from './AdminLogin.vue'
import AdminDashboard from './AdminDashboard.vue'

export default {
  name: 'AdminPortal',
  components: {
    AdminLogin,
    AdminDashboard
  },
  data() {
    return {
      isAuthenticated: !!localStorage.getItem('adminToken')
    }
  },
  methods: {
    handleLoginSuccess() {
      this.isAuthenticated = true
    },
    handleLogout() {
      this.isAuthenticated = false
    }
  }
}
</script>

<style scoped>
.admin-portal-wrapper {
  min-height: 100vh;
  width: 100%;
}
</style>
