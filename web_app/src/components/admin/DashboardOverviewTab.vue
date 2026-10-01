<template>
  <div class="dashboard-panes">
    <!-- METRICS GRID -->
    <div class="metrics-grid">
      <div class="metric-card bg-blue">
        <div class="metric-header">
          <span class="metric-title">TOTAL REGISTERED USERS</span>
          <span class="metric-icon">👥</span>
        </div>
        <div class="metric-value">{{ users.length }}</div>
        <div class="metric-footer text-green">
          <span>Real-time Active Database</span>
        </div>
      </div>

      <div class="metric-card bg-green">
        <div class="metric-header">
          <span class="metric-title">PENDING FUND REQUESTS</span>
          <span class="metric-icon">💳</span>
        </div>
        <div class="metric-value">{{ pendingRequestsCount }}</div>
        <div class="metric-footer text-amber">
          <span>Requires Admin Approval</span>
        </div>
      </div>

      <div class="metric-card bg-purple">
        <div class="metric-header">
          <span class="metric-title">TOTAL PLATFORM TRANSACTIONS</span>
          <span class="metric-icon">📊</span>
        </div>
        <div class="metric-value">{{ transactions.length }}</div>
        <div class="metric-footer text-purple">
          <span>Ledger Records</span>
        </div>
      </div>

      <div class="metric-card bg-amber">
        <div class="metric-header">
          <span class="metric-title">SYSTEM GATEWAY STATUS</span>
          <span class="metric-icon">⚡</span>
        </div>
        <div class="metric-value" style="font-size: 1.1rem; color: #16a34a;">Operational (Online)</div>
        <div class="metric-footer text-green">
          <span>Scriza & Razorpay Live</span>
        </div>
      </div>
    </div>

    <!-- GATEWAY API HEALTH STATUS -->
    <div class="card-box" style="margin-top: 1.5rem;">
      <div class="card-title-row">
        <h3>⚡ System API Gateways & Service Connectors</h3>
        <span class="badge-status-active">100% Operational</span>
      </div>
      <div class="gateway-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1rem; margin-top: 1rem;">
        <div style="background: #f8fafc; padding: 1rem; border-radius: 8px; border: 1px solid #e2e8f0;">
          <div style="font-weight: 700; color: #475569; font-size: 0.85rem;">MySQL Database Server</div>
          <div style="font-weight: 800; color: #16a34a; margin-top: 4px; display: flex; align-items: center; gap: 6px;">
            <span style="height: 8px; width: 8px; background: #16a34a; border-radius: 50%; display: inline-block;"></span>
            {{ gatewayStatus.database }}
          </div>
        </div>
        <div style="background: #f8fafc; padding: 1rem; border-radius: 8px; border: 1px solid #e2e8f0;">
          <div style="font-weight: 700; color: #475569; font-size: 0.85rem;">App API Engine</div>
          <div style="font-weight: 800; color: #16a34a; margin-top: 4px; display: flex; align-items: center; gap: 6px;">
            <span style="height: 8px; width: 8px; background: #16a34a; border-radius: 50%; display: inline-block;"></span>
            {{ gatewayStatus.app_api }}
          </div>
        </div>
        <div style="background: #f8fafc; padding: 1rem; border-radius: 8px; border: 1px solid #e2e8f0;">
          <div style="font-weight: 700; color: #475569; font-size: 0.85rem;">Scriza Recharge API</div>
          <div style="font-weight: 800; color: #2563eb; margin-top: 4px; display: flex; align-items: center; gap: 6px;">
            <span style="height: 8px; width: 8px; background: #2563eb; border-radius: 50%; display: inline-block;"></span>
            {{ gatewayStatus.scriza_api }}
          </div>
        </div>
        <div style="background: #f8fafc; padding: 1rem; border-radius: 8px; border: 1px solid #e2e8f0;">
          <div style="font-weight: 700; color: #475569; font-size: 0.85rem;">Razorpay Payment Gateway</div>
          <div style="font-weight: 800; color: #9333ea; margin-top: 4px; display: flex; align-items: center; gap: 6px;">
            <span style="height: 8px; width: 8px; background: #9333ea; border-radius: 50%; display: inline-block;"></span>
            {{ gatewayStatus.razorpay_gateway }}
          </div>
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
