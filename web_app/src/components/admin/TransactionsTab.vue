<template>
  <div class="transactions-pane">
    <div class="table-card">
      <div class="card-title-row">
        <h3>📋 Platform-Wide Transactions & General Ledger</h3>
        <span class="count-pill">{{ transactions.length }} Total Loaded</span>
      </div>
      <p class="card-desc">All user recharges, wallet topups, referrals, payouts, and admin fund adjustments.</p>
      
      <div class="table-container">
        <table class="nice-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Date</th>
              <th>Member Name</th>
              <th>Email</th>
              <th>Wallet Type</th>
              <th>Type / Description</th>
              <th>Amount</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="transactions.length === 0">
              <td colspan="8" style="text-align: center; padding: 2rem; color: #64748b; font-weight: 600;">
                No transactions recorded in system database.
              </td>
            </tr>
            <tr v-for="tx in transactions" :key="tx.id">
              <td>#{{ tx.id }}</td>
              <td style="white-space: nowrap;">{{ tx.date || (tx.createdAt ? String(tx.createdAt).substring(0, 16) : 'N/A') }}</td>
              <td class="font-bold">{{ tx.fullName || 'User #' + tx.user_id }}</td>
              <td>{{ tx.email || 'N/A' }}</td>
              <td>
                <span :style="{ background: tx.wallet_type === 'FUND' ? '#faf5ff' : '#eff6ff', color: tx.wallet_type === 'FUND' ? '#9333ea' : '#2563eb', padding: '2px 8px', borderRadius: '12px', fontSize: '0.75rem', fontWeight: '800' }">
                  {{ tx.wallet_type || 'MAIN' }}
                </span>
              </td>
              <td class="font-semibold">{{ tx.type || 'Transaction' }}</td>
              <td class="font-bold" :style="{ color: String(tx.type || '').toLowerCase().includes('debit') || String(tx.type || '').toLowerCase().includes('deduct') ? '#dc2626' : '#16a34a' }">
                {{ String(tx.type || '').toLowerCase().includes('debit') || String(tx.type || '').toLowerCase().includes('deduct') ? '-' : '+' }} ₹{{ parseFloat(tx.amount || 0).toFixed(2) }}
              </td>
              <td>
                <span :class="tx.status === 'Success' || tx.status === 'SUCCESS' || tx.status === 'APPROVED' ? 'badge-status-active' : 'badge-status-pending'">
                  {{ tx.status || 'Success' }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- PAGINATION -->
      <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 1rem; padding-top: 1rem; border-top: 1px solid #e2e8f0;">
        <button 
          @click="$emit('prev-page')" 
          :disabled="txnPage === 1"
          style="background: #f1f5f9; border: 1px solid #cbd5e1; padding: 0.5rem 1rem; border-radius: 6px; font-weight: 700; cursor: pointer;"
        >
          ← Previous
        </button>
        <span style="font-weight: 700; font-size: 0.88rem; color: #475569;">Page {{ txnPage }}</span>
        <button 
          @click="$emit('next-page')"
          style="background: #2563eb; color: white; border: none; padding: 0.5rem 1rem; border-radius: 6px; font-weight: 700; cursor: pointer;"
        >
          Next →
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TransactionsTab',
  props: {
    transactions: { type: Array, default: () => [] },
    txnPage: { type: Number, default: 1 }
  }
};
</script>
