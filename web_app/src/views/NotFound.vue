<template>
  <div class="not-found-container">
    <div class="error-card">
      <div class="brand-logo-area">
        <img src="../assets/sr_logo.png" alt="SR Digital Seva" class="error-logo" />
      </div>
      <div class="error-badge">404 ERROR</div>
      <h1 class="error-code">404</h1>
      <h2 class="error-title">Page Not Found</h2>
      <p class="error-desc">
        Oops! The page or administrative resource you are looking for does not exist, has been removed, or is temporarily unavailable.
      </p>

      <div class="action-buttons">
        <router-link to="/" class="btn btn-primary">
          &larr; Back to Home
        </router-link>
        <router-link to="/admin-dashboard" class="btn btn-secondary">
          🛡️ Admin Dashboard
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'NotFound'
}
</script>

<style scoped>
.not-found-container {
  min-height: 100vh;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: radial-gradient(circle at top center, #eff6ff 0%, #f8fafc 100%);
  padding: 1.5rem;
  box-sizing: border-box;
  font-family: 'Outfit', 'Inter', system-ui, sans-serif;
}

.error-card {
  background: #ffffff;
  padding: 3rem 2.5rem;
  border-radius: 20px;
  box-shadow: 0 20px 40px rgba(0, 82, 204, 0.08), 0 4px 12px rgba(0, 0, 0, 0.03);
  max-width: 480px;
  width: 100%;
  text-align: center;
  border: 1px solid #e2e8f0;
}

.error-logo {
  height: 48px;
  object-fit: contain;
  margin-bottom: 1.5rem;
}

.error-badge {
  display: inline-block;
  padding: 0.35rem 0.9rem;
  background-color: #fee2e2;
  color: #ef4444;
  font-size: 0.75rem;
  font-weight: 800;
  border-radius: 9999px;
  letter-spacing: 0.05em;
  margin-bottom: 1rem;
}

.error-code {
  font-size: 4.5rem;
  font-weight: 900;
  color: #0052cc;
  margin: 0;
  line-height: 1;
  letter-spacing: -0.04em;
}

.error-title {
  font-size: 1.5rem;
  font-weight: 800;
  color: #0f172a;
  margin: 0.5rem 0 1rem;
}

.error-desc {
  font-size: 0.95rem;
  color: #64748b;
  line-height: 1.6;
  margin-bottom: 2rem;
}

.action-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.btn {
  padding: 0.75rem 1.4rem;
  border-radius: 10px;
  font-size: 0.9rem;
  font-weight: 700;
  text-decoration: none;
  transition: transform 0.2s, box-shadow 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.btn:hover {
  transform: translateY(-2px);
}

.btn-primary {
  background-color: #0052cc;
  color: #ffffff;
  box-shadow: 0 4px 14px rgba(0, 82, 204, 0.25);
}

.btn-secondary {
  background-color: #000000;
  color: #ffffff;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.15);
}

@media (max-width: 480px) {
  .error-card {
    padding: 2rem 1.5rem;
  }
  .error-code {
    font-size: 3.5rem;
  }
  .action-buttons {
    flex-direction: column;
  }
  .btn {
    width: 100%;
    justify-content: center;
    box-sizing: border-box;
  }
}
</style>
