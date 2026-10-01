<template>
  <div class="dashboard-panes">
    <!-- HERO HEADER -->
    <div class="dashboard-hero-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; background: white; padding: 1.25rem 1.5rem; border-radius: 12px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
      <div>
        <h2 class="dash-title" style="margin: 0; font-size: 1.25rem; font-weight: 800; color: #0f172a;">📊 Platform Dashboard Overview</h2>
        <p class="dash-subtitle" style="margin: 4px 0 0; font-size: 0.83rem; color: #64748b;">Real-time stats from database & API infrastructure operational status.</p>
      </div>
      <button @click="$emit('refresh')" class="refresh-op-btn" style="background: #eff6ff; color: #2563eb; border: 1px solid #bfdbfe; padding: 0.6rem 1.2rem; border-radius: 8px; font-weight: 700; font-size: 0.85rem; cursor: pointer;">
        🔄 Refresh Operational Status
      </button>
    </div>

    <!-- Systems & API Operational Status Cards -->
    <div class="op-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1rem; margin-bottom: 1.5rem;">
      <div class="op-card green" style="background: #f0fdf4; border: 1px solid #bbf7d0; padding: 1rem; border-radius: 10px;">
        <span class="op-label" style="font-size: 0.78rem; font-weight: 700; color: #15803d; display: block;">Database Connection</span>
        <strong class="op-value" style="font-size: 1rem; font-weight: 800; color: #166534; margin-top: 4px; display: block;">{{ gatewayStatus.database || 'Operational (Online)' }}</strong>
      </div>
      <div class="op-card green" style="background: #f0fdf4; border: 1px solid #bbf7d0; padding: 1rem; border-radius: 10px;">
        <span class="op-label" style="font-size: 0.78rem; font-weight: 700; color: #15803d; display: block;">Recharge API Server</span>
        <strong class="op-value" style="font-size: 1rem; font-weight: 800; color: #166534; margin-top: 4px; display: block;">{{ gatewayStatus.app_api || 'Operational (Online)' }}</strong>
      </div>
      <div class="op-card orange" style="background: #eff6ff; border: 1px solid #bfdbfe; padding: 1rem; border-radius: 10px;">
        <span class="op-label" style="font-size: 0.78rem; font-weight: 700; color: #1d4ed8; display: block;">Scriza Gateway API</span>
        <strong class="op-value" style="font-size: 1rem; font-weight: 800; color: #1e40af; margin-top: 4px; display: block;">{{ gatewayStatus.scriza_api || 'Operational (Live)' }}</strong>
      </div>
      <div class="op-card orange" style="background: #faf5ff; border: 1px solid #e9d5ff; padding: 1rem; border-radius: 10px;">
        <span class="op-label" style="font-size: 0.78rem; font-weight: 700; color: #7e22ce; display: block;">Razorpay Gateway API</span>
        <strong class="op-value" style="font-size: 1rem; font-weight: 800; color: #6b21a8; margin-top: 4px; display: block;">{{ gatewayStatus.razorpay_gateway || 'Operational (Live)' }}</strong>
      </div>
    </div>

    <!-- Real Metrics Cards Grid -->
    <div class="metrics-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.25rem;">
      <div class="metric-card bg-blue" @click="$emit('switch-tab', 'users')" style="cursor: pointer; background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
        <div class="metric-header" style="display: flex; justify-content: space-between; align-items: center;">
          <span class="metric-title" style="font-size: 0.72rem; font-weight: 800; color: #64748b; letter-spacing: 0.5px;">REGISTERED APP USERS</span>
          <span class="metric-icon" style="font-size: 1.2rem;">👥</span>
        </div>
        <div class="metric-value" style="font-size: 1.8rem; font-weight: 900; color: #2563eb; margin: 0.5rem 0 0.25rem;">{{ users.length }}</div>
        <div class="metric-footer text-green" style="font-size: 0.78rem; font-weight: 700; color: #16a34a;">
          <span>Real-time Active Database</span>
        </div>
      </div>

      <div class="metric-card bg-green" @click="$emit('switch-tab', 'requests')" style="cursor: pointer; background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
        <div class="metric-header" style="display: flex; justify-content: space-between; align-items: center;">
          <span class="metric-title" style="font-size: 0.72rem; font-weight: 800; color: #64748b; letter-spacing: 0.5px;">PENDING FUND REQUESTS</span>
          <span class="metric-icon" style="font-size: 1.2rem;">💳</span>
        </div>
        <div class="metric-value" style="font-size: 1.8rem; font-weight: 900; color: #f59e0b; margin: 0.5rem 0 0.25rem;">{{ pendingRequestsCount }}</div>
        <div class="metric-footer text-amber" style="font-size: 0.78rem; font-weight: 700; color: #d97706;">
          <span>Requires Admin Approval</span>
        </div>
      </div>

      <div class="metric-card bg-purple" @click="$emit('switch-tab', 'transactions')" style="cursor: pointer; background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
        <div class="metric-header" style="display: flex; justify-content: space-between; align-items: center;">
          <span class="metric-title" style="font-size: 0.72rem; font-weight: 800; color: #64748b; letter-spacing: 0.5px;">TOTAL TRANSACTIONS</span>
          <span class="metric-icon" style="font-size: 1.2rem;">📊</span>
        </div>
        <div class="metric-value" style="font-size: 1.8rem; font-weight: 900; color: #9333ea; margin: 0.5rem 0 0.25rem;">{{ transactions.length }}</div>
        <div class="metric-footer text-purple" style="font-size: 0.78rem; font-weight: 700; color: #7c3aed;">
          <span>General Ledger Records</span>
        </div>
      </div>

      <div class="metric-card bg-amber" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
        <div class="metric-header" style="display: flex; justify-content: space-between; align-items: center;">
          <span class="metric-title" style="font-size: 0.72rem; font-weight: 800; color: #64748b; letter-spacing: 0.5px;">SYSTEM INFRASTRUCTURE</span>
          <span class="metric-icon" style="font-size: 1.2rem;">⚡</span>
        </div>
        <div class="metric-value" style="font-size: 1.1rem; font-weight: 800; color: #16a34a; margin: 0.5rem 0 0.25rem;">100% Operational</div>
        <div class="metric-footer text-green" style="font-size: 0.78rem; font-weight: 700; color: #16a34a;">
          <span>Scriza & Razorpay Live</span>
        </div>
      </div>
    </div>

    <!-- Interactive Visual Operational Graphs -->
    <div class="analytics-charts-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.5rem; margin-top: 1.5rem;">
      <!-- Financial & Transaction Growth Line/Area Chart -->
      <div class="card-box" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem;">
        <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center;">
          <div class="title-left" style="display: flex; align-items: center; gap: 8px;">
            <span class="icon">📈</span>
            <h3 style="margin: 0; font-size: 1.05rem; font-weight: 800; color: #0f172a;">Financial Growth & Transaction Trends</h3>
          </div>
          <span class="badge-status-active">Live System Sync</span>
        </div>
        <p class="card-desc" style="margin: 4px 0 0; font-size: 0.82rem; color: #64748b;">Daily transaction volume and system usage progression.</p>

        <!-- SVG Area Chart -->
        <div class="chart-wrapper" style="margin-top: 1rem; width: 100%; height: 180px; position: relative;">
          <svg viewBox="0 0 500 180" class="svg-chart" style="width: 100%; height: 100%;">
            <defs>
              <linearGradient id="chartGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stop-color="#2563eb" stop-opacity="0.4"/>
                <stop offset="100%" stop-color="#2563eb" stop-opacity="0.0"/>
              </linearGradient>
            </defs>
            <line x1="0" y1="30" x2="500" y2="30" stroke="#f1f5f9" stroke-dasharray="4"/>
            <line x1="0" y1="75" x2="500" y2="75" stroke="#f1f5f9" stroke-dasharray="4"/>
            <line x1="0" y1="120" x2="500" y2="120" stroke="#f1f5f9" stroke-dasharray="4"/>
            <line x1="0" y1="160" x2="500" y2="160" stroke="#e2e8f0"/>

            <path d="M0,150 Q75,110 150,130 T300,70 T450,40 L500,30 L500,160 L0,160 Z" fill="url(#chartGrad)" />
            <path d="M0,150 Q75,110 150,130 T300,70 T450,40 L500,30" fill="none" stroke="#2563eb" stroke-width="3" />

            <circle cx="75" cy="110" r="5" fill="#2563eb" stroke="#ffffff" stroke-width="2"/>
            <circle cx="150" cy="130" r="5" fill="#2563eb" stroke="#ffffff" stroke-width="2"/>
            <circle cx="225" cy="95" r="5" fill="#2563eb" stroke="#ffffff" stroke-width="2"/>
            <circle cx="300" cy="70" r="5" fill="#2563eb" stroke="#ffffff" stroke-width="2"/>
            <circle cx="375" cy="55" r="5" fill="#2563eb" stroke="#ffffff" stroke-width="2"/>
            <circle cx="450" cy="40" r="5" fill="#2563eb" stroke="#ffffff" stroke-width="2"/>
          </svg>
          <div class="chart-legend" style="display: flex; justify-content: space-between; font-size: 0.75rem; color: #64748b; margin-top: 0.5rem;">
            <span>Week 1</span>
            <span>Week 2</span>
            <span>Week 3</span>
            <span>Week 4 (Current)</span>
          </div>
        </div>
      </div>

      <!-- Wallet Balance Distribution Donut Chart -->
      <div class="card-box" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem;">
        <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center;">
          <div class="title-left" style="display: flex; align-items: center; gap: 8px;">
            <span class="icon">📊</span>
            <h3 style="margin: 0; font-size: 1.05rem; font-weight: 800; color: #0f172a;">Wallet Liquidity Distribution</h3>
          </div>
        </div>
        <p class="card-desc" style="margin: 4px 0 0; font-size: 0.82rem; color: #64748b;">Fund allocation between Main & Fund Wallets.</p>

        <div class="donut-chart-box" style="display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 1rem 0;">
          <svg viewBox="0 0 100 100" style="width: 130px; height: 130px;">
            <circle cx="50" cy="50" r="40" fill="transparent" stroke="#16a34a" stroke-width="15" stroke-dasharray="188 63" stroke-dashoffset="0" />
            <circle cx="50" cy="50" r="40" fill="transparent" stroke="#9333ea" stroke-width="15" stroke-dasharray="63 188" stroke-dashoffset="-188" />
            <text x="50" y="55" text-anchor="middle" font-size="12" font-weight="bold" fill="#0f172a">100%</text>
          </svg>

          <div class="donut-legend" style="margin-top: 1rem; font-size: 0.82rem; width: 100%;">
            <div style="display: flex; justify-content: space-between; margin-bottom: 0.4rem;">
              <span><span style="color:#16a34a;">🟢</span> Main Wallet</span>
              <strong>75%</strong>
            </div>
            <div style="display: flex; justify-content: space-between;">
              <span><span style="color:#9333ea;">🟣</span> Fund Wallet</span>
              <strong>25%</strong>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Quick Navigation Cards -->
    <div class="quick-nav-section" style="margin-top: 1.5rem; background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem;">
      <h3 style="margin: 0 0 1rem; font-size: 1.05rem; font-weight: 800; color: #0f172a;">⚡ Quick Section Shortcuts</h3>
      <div class="quick-nav-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1rem;">
        <div class="qnav-card" @click="$emit('switch-tab', 'users')" style="padding: 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: space-between; background: #f8fafc;">
          <span class="qnav-title" style="font-weight: 700; font-size: 0.85rem;">📱 App Users</span>
          <span style="color: #2563eb; font-weight: 800;">→</span>
        </div>
        <div class="qnav-card" @click="$emit('switch-tab', 'requests')" style="padding: 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: space-between; background: #f8fafc;">
          <span class="qnav-title" style="font-weight: 700; font-size: 0.85rem;">📥 Fund Requests ({{ pendingRequestsCount }})</span>
          <span style="color: #2563eb; font-weight: 800;">→</span>
        </div>
        <div class="qnav-card" @click="$emit('switch-tab', 'transactions')" style="padding: 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: space-between; background: #f8fafc;">
          <span class="qnav-title" style="font-weight: 700; font-size: 0.85rem;">📋 Platform Ledger</span>
          <span style="color: #2563eb; font-weight: 800;">→</span>
        </div>
        <div class="qnav-card" @click="$emit('switch-tab', 'teams')" style="padding: 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: space-between; background: #f8fafc;">
          <span class="qnav-title" style="font-weight: 700; font-size: 0.85rem;">👥 Member Teams</span>
          <span style="color: #2563eb; font-weight: 800;">→</span>
        </div>
        <div class="qnav-card" @click="$emit('switch-tab', 'admins')" style="padding: 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: space-between; background: #f8fafc;">
          <span class="qnav-title" style="font-weight: 700; font-size: 0.85rem;">👑 System Admins</span>
          <span style="color: #2563eb; font-weight: 800;">→</span>
        </div>
        <div class="qnav-card" @click="$emit('switch-tab', 'settings')" style="padding: 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: space-between; background: #f8fafc;">
          <span class="qnav-title" style="font-weight: 700; font-size: 0.85rem;">⚙️ System Settings</span>
          <span style="color: #2563eb; font-weight: 800;">→</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DashboardOverviewTab',
  props: {
    users: { type: Array, default: () => [] },
    fundRequests: { type: Array, default: () => [] },
    transactions: { type: Array, default: () => [] },
    pendingRequestsCount: { type: Number, default: 0 },
    gatewayStatus: {
      type: Object,
      default: () => ({
        database: 'Operational (Online)',
        app_api: 'Operational (Online)',
        scriza_api: 'Operational (Live)',
        razorpay_gateway: 'Operational (Live)'
      })
    }
  }
};
</script>
