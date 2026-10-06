<template>
  <div v-if="user" class="slide-over-backdrop" @click="$emit('close')">
    <div class="slide-over-panel" @click.stop style="box-sizing: border-box; overflow-x: hidden; max-width: 100vw;">
      <div class="drawer-header">
        <h3>User Profile</h3>
        <button @click="$emit('close')" class="btn-close-x">&times;</button>
      </div>
      <div class="drawer-body" style="word-break: break-word; overflow-x: hidden;">
        <div class="drawer-user-pill">
          <div class="avatar-large">{{ user.fullName ? user.fullName[0].toUpperCase() : 'U' }}</div>
          <div>
            <h4 style="word-break: break-word; margin: 0 0 2px;">{{ user.fullName }}</h4>
            <div style="font-size: 0.8rem; color: #64748b; margin-bottom: 4px;">ID / Mobile: <strong>{{ user.mobileNumber || 'N/A' }}</strong></div>
            <span :style="{
              background: (user.status || '').toUpperCase() === 'ACTIVE' ? '#dcfce7' : '#fef3c7',
              color: (user.status || '').toUpperCase() === 'ACTIVE' ? '#15803d' : '#b45309',
              padding: '2px 8px',
              borderRadius: '12px',
              fontWeight: '800',
              fontSize: '0.75rem',
              border: (user.status || '').toUpperCase() === 'ACTIVE' ? '1px solid #86efac' : '1px solid #fde68a'
            }">
              {{ (user.status || 'PENDING').toUpperCase() === 'ACTIVE' ? '🟢 Active Account' : '🟡 Pending / Unactivated' }}
            </span>
          </div>
        </div>

        <div class="wallets-row" style="display: flex; gap: 1rem; margin-top: 1rem; flex-wrap: wrap;">
          <div class="stat-card border-blue" style="flex: 1; min-width: 120px; padding: 1rem; background: #eff6ff; border-radius: 8px;">
            <span>Main Wallet</span>
            <h4 style="color: #2563eb; font-size: 1.2rem; margin: 4px 0 0;">₹{{ parseFloat(user.main_wallet_balance || 0).toFixed(2) }}</h4>
          </div>
          <div class="stat-card border-purple" style="flex: 1; min-width: 120px; padding: 1rem; background: #faf5ff; border-radius: 8px;">
            <span>Fund Wallet</span>
            <h4 style="color: #9333ea; font-size: 1.2rem; margin: 4px 0 0;">₹{{ parseFloat(user.fund_wallet_balance || 0).toFixed(2) }}</h4>
          </div>
        </div>

        <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 1rem;">
          <button @click="$emit('open-edit-user', user)" style="background: #2563eb; color: white; border: none; padding: 0.6rem 1rem; border-radius: 8px; font-weight: 700; cursor: pointer; width: 100%;">
            ✏️ Edit Full User Details
          </button>
          <button @click="$emit('open-add-funds', user)" style="background: #10b981; color: white; border: none; padding: 0.6rem 1rem; border-radius: 8px; font-weight: 700; cursor: pointer; width: 100%;">
            ➕ Add / Deduct Funds
          </button>
          <button @click="$emit('view-user-transactions', user)" style="background: #0284c7; color: white; border: none; padding: 0.6rem 1rem; border-radius: 8px; font-weight: 700; cursor: pointer; width: 100%;">
            📋 View User Transactions
          </button>
          <button @click="$emit('view-user-income', user)" style="background: #7c3aed; color: white; border: none; padding: 0.6rem 1rem; border-radius: 8px; font-weight: 700; cursor: pointer; width: 100%;">
            📊 View Income Details
          </button>
        </div>

        <!-- Reset User Password Box (Admin Only) -->
        <div style="margin-top: 1.25rem; padding: 1rem; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px;">
          <h4 style="margin: 0 0 0.35rem; font-size: 0.88rem; font-weight: 700; color: #1e293b;">🔑 Reset Member Password</h4>
          <p style="margin: 0 0 0.75rem; font-size: 0.78rem; color: #64748b;">Set a new password for {{ user.fullName || user.email }} directly.</p>
          <div style="display: flex; gap: 0.5rem; align-items: center; flex-wrap: wrap;">
            <input 
              type="text" 
              :value="password"
              @input="$emit('update:password', $event.target.value)"
              placeholder="Enter new password (min 4 chars)" 
              style="flex: 1; min-width: 160px; padding: 0.55rem 0.75rem; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 0.85rem; outline: none; background: white;"
            />
            <button 
              @click="$emit('update-password', user.id)" 
              :disabled="updatingPassword"
              style="background: #2563eb; color: white; border: none; padding: 0.55rem 1rem; border-radius: 6px; font-weight: 700; font-size: 0.82rem; cursor: pointer; white-space: nowrap;"
            >
              {{ updatingPassword ? 'Saving...' : '🔑 Change Password' }}
            </button>
          </div>
          <div v-if="msg" :style="{ color: success ? '#16a34a' : '#ef4444', fontSize: '0.8rem', marginTop: '0.5rem', fontWeight: 'bold' }">
            {{ msg }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'UserProfileDrawer',
  props: {
    user: { type: Object, default: null },
    password: { type: String, default: '' },
    updatingPassword: { type: Boolean, default: false },
    msg: { type: String, default: '' },
    success: { type: Boolean, default: false }
  }
};
</script>
