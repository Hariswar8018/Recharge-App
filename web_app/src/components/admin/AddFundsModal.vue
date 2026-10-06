<template>
  <div v-if="show" class="invoice-modal-backdrop" @click="$emit('close')">
    <div class="invoice-modal-container" @click.stop style="max-width: 480px; width: 95%; padding: 0; overflow: hidden; border-radius: 12px; background: white;">
      <div style="background: #2563eb; color: white; padding: 1rem 1.25rem; display: flex; align-items: center; justify-content: space-between;">
        <h3 style="margin: 0; font-size: 1.1rem; display: flex; align-items: center; gap: 8px;">
          💳 Add / Adjust Funds to User Wallet
        </h3>
        <button @click="$emit('close')" style="background: transparent; border: none; color: white; font-size: 1.4rem; cursor: pointer;">&times;</button>
      </div>
      
      <div style="padding: 1.25rem;">
        <div v-if="user" style="background: #f1f5f9; padding: 0.75rem 1rem; border-radius: 8px; margin-bottom: 1.25rem; display: flex; align-items: center; justify-content: space-between;">
          <div>
            <div style="font-weight: 800; color: #0f172a;">{{ user.fullName || 'User #' + user.id }}</div>
            <div style="font-size: 0.8rem; color: #64748b;">Mobile: {{ user.mobileNumber || 'N/A' }} | ID: #{{ user.id }}</div>
          </div>
          <span :style="{
            background: (user.status || '').toUpperCase() === 'ACTIVE' ? '#dcfce7' : '#fef3c7',
            color: (user.status || '').toUpperCase() === 'ACTIVE' ? '#15803d' : '#b45309',
            padding: '2px 8px',
            borderRadius: '12px',
            fontWeight: '800',
            fontSize: '0.75rem',
            border: (user.status || '').toUpperCase() === 'ACTIVE' ? '1px solid #86efac' : '1px solid #fde68a'
          }">
            {{ (user.status || 'PENDING').toUpperCase() === 'ACTIVE' ? '🟢 Active' : '🟡 Pending' }}
          </span>
        </div>

        <div class="form-group" style="margin-bottom: 1rem;">
          <label style="font-weight: 700; font-size: 0.85rem; color: #334155; margin-bottom: 4px; display: block;">Select Target Wallet</label>
          <div style="display: flex; gap: 10px;">
            <button type="button" @click="$emit('update:walletType', 'MAIN')" :style="{ flex: 1, padding: '0.6rem', border: walletType === 'MAIN' ? '2px solid #2563eb' : '1px solid #cbd5e1', background: walletType === 'MAIN' ? '#eff6ff' : 'white', color: walletType === 'MAIN' ? '#1e40af' : '#475569', borderRadius: '8px', fontWeight: '800', cursor: 'pointer' }">
              Main Wallet (₹{{ parseFloat(user?.main_wallet_balance || 0).toFixed(2) }})
            </button>
            <button type="button" @click="$emit('update:walletType', 'FUND')" :style="{ flex: 1, padding: '0.6rem', border: walletType === 'FUND' ? '2px solid #9333ea' : '1px solid #cbd5e1', background: walletType === 'FUND' ? '#faf5ff' : 'white', color: walletType === 'FUND' ? '#6b21a8' : '#475569', borderRadius: '8px', fontWeight: '800', cursor: 'pointer' }">
              Fund Wallet (₹{{ parseFloat(user?.fund_wallet_balance || 0).toFixed(2) }})
            </button>
          </div>
        </div>

        <div class="form-group" style="margin-bottom: 1rem;">
          <label style="font-weight: 700; font-size: 0.85rem; color: #334155; margin-bottom: 4px; display: block;">Action Type</label>
          <div style="display: flex; gap: 10px;">
            <button type="button" @click="$emit('update:actionType', 'CREDIT')" :style="{ flex: 1, padding: '0.55rem', border: actionType === 'CREDIT' ? '2px solid #16a34a' : '1px solid #cbd5e1', background: actionType === 'CREDIT' ? '#f0fdf4' : 'white', color: actionType === 'CREDIT' ? '#15803d' : '#475569', borderRadius: '8px', fontWeight: '800', cursor: 'pointer' }">
              ➕ Add Funds (Credit)
            </button>
            <button type="button" @click="$emit('update:actionType', 'DEBIT')" :style="{ flex: 1, padding: '0.55rem', border: actionType === 'DEBIT' ? '2px solid #dc2626' : '1px solid #cbd5e1', background: actionType === 'DEBIT' ? '#fef2f2' : 'white', color: actionType === 'DEBIT' ? '#b91c1c' : '#475569', borderRadius: '8px', fontWeight: '800', cursor: 'pointer' }">
              ➖ Deduct Funds (Debit)
            </button>
          </div>
        </div>

        <div class="form-group" style="margin-bottom: 1rem;">
          <label style="font-weight: 700; font-size: 0.85rem; color: #334155; margin-bottom: 4px; display: block;">Amount (₹) <span style="color:red">*</span></label>
          <div style="position: relative;">
            <span style="position: absolute; left: 12px; top: 10px; font-weight: 800; color: #475569;">₹</span>
            <input type="number" :value="amount" @input="$emit('update:amount', $event.target.value)" placeholder="Enter amount (e.g. 1200)" style="width: 100%; padding: 0.6rem 0.75rem 0.6rem 28px; border-radius: 8px; border: 1px solid #cbd5e1; outline: none; font-weight: 800; font-size: 1rem; box-sizing: border-box;" />
          </div>
        </div>

        <div class="form-group" style="margin-bottom: 1.25rem;">
          <label style="font-weight: 700; font-size: 0.85rem; color: #334155; margin-bottom: 4px; display: block;">Remark / Note (Optional)</label>
          <input type="text" :value="remark" @input="$emit('update:remark', $event.target.value)" placeholder="e.g. Admin Approval, Reward Credit" style="width: 100%; padding: 0.6rem 0.75rem; border-radius: 8px; border: 1px solid #cbd5e1; outline: none; box-sizing: border-box;" />
        </div>

        <div v-if="msg" :style="{ color: success ? '#16a34a' : '#ef4444', fontSize: '0.85rem', marginBottom: '1rem', fontWeight: 'bold' }">
          {{ msg }}
        </div>

        <div style="display: flex; gap: 10px; justify-content: flex-end;">
          <button type="button" @click="$emit('close')" style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 0.6rem 1.25rem; border-radius: 8px; font-weight: 700; cursor: pointer;">
            Cancel
          </button>
          <button type="button" @click="$emit('submit')" :disabled="submitting" style="background: #2563eb; color: white; border: none; padding: 0.6rem 1.5rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            {{ submitting ? 'Processing...' : 'Submit Adjustment' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AddFundsModal',
  props: {
    show: { type: Boolean, default: false },
    user: { type: Object, default: null },
    walletType: { type: String, default: 'MAIN' },
    actionType: { type: String, default: 'CREDIT' },
    amount: { type: [String, Number], default: '' },
    remark: { type: String, default: '' },
    submitting: { type: Boolean, default: false },
    msg: { type: String, default: '' },
    success: { type: Boolean, default: false }
  }
};
</script>
