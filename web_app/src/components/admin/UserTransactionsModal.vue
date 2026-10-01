<template>
  <div v-if="show" class="invoice-modal-backdrop" @click="$emit('close')">
    <div class="invoice-modal-container" @click.stop style="max-width: 850px; width: 95%; padding: 0; overflow: hidden; border-radius: 12px; background: white; max-height: 90vh; display: flex; flex-direction: column;">
      <div style="background: #1e3a8a; color: white; padding: 1rem 1.25rem; display: flex; align-items: center; justify-content: space-between;">
        <h3 style="margin: 0; font-size: 1.1rem; display: flex; align-items: center; gap: 8px;">
          📋 Transaction History & Ledger
          <span v-if="user" style="font-size: 0.85rem; font-weight: 500; opacity: 0.9;">
            — {{ user.fullName || user.email }} (#{{ user.id || user.mobileNumber }})
          </span>
        </h3>
        <button @click="$emit('close')" style="background: transparent; border: none; color: white; font-size: 1.4rem; cursor: pointer;">&times;</button>
      </div>
      
      <div style="padding: 1rem 1.25rem; overflow-y: auto; flex: 1;">
        <div style="display: flex; gap: 1rem; margin-bottom: 1rem; justify-content: space-between; align-items: center; flex-wrap: wrap;">
          <input 
            type="text" 
            v-model="searchQueryLocal" 
            @input="$emit('update:searchQuery', searchQueryLocal)"
            placeholder="🔍 Search by Type, Wallet, Status, or Date..." 
            style="flex: 1; min-width: 200px; padding: 0.55rem 0.85rem; border-radius: 8px; border: 1px solid #cbd5e1; outline: none; font-size: 0.85rem;"
          />
          <span style="font-size: 0.82rem; font-weight: 700; color: #475569;">
            Total Records: {{ filteredTxnList.length }}
          </span>
        </div>

        <div v-if="loading" style="text-align: center; padding: 2rem; color: #64748b; font-weight: 700;">
          ⏳ Loading user transactions...
        </div>

        <div v-else-if="filteredTxnList.length === 0" style="text-align: center; padding: 2rem; background: #f8fafc; border-radius: 8px; color: #64748b; font-weight: 600;">
          No transactions found for this user.
        </div>

        <div v-else class="table-container" style="max-height: 55vh; overflow-y: auto;">
          <table class="nice-table" style="width: 100%; border-collapse: collapse;">
            <thead>
              <tr style="background: #f1f5f9; text-align: left; font-size: 0.8rem; color: #475569;">
                <th style="padding: 10px;">ID</th>
                <th style="padding: 10px;">Date</th>
                <th style="padding: 10px;">Wallet</th>
                <th style="padding: 10px;">Type / Description</th>
                <th style="padding: 10px; text-align: right;">Amount</th>
                <th style="padding: 10px; text-align: center;">Status</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="tx in filteredTxnList" :key="tx.id" style="border-bottom: 1px solid #e2e8f0; font-size: 0.85rem;">
                <td style="padding: 10px; font-weight: 700; color: #334155;">#{{ tx.id }}</td>
                <td style="padding: 10px; color: #64748b; white-space: nowrap;">
                  {{ tx.date || (tx.createdAt ? String(tx.createdAt).substring(0, 10) : 'N/A') }}
                </td>
                <td style="padding: 10px;">
                  <span :style="{ background: tx.wallet_type === 'FUND' ? '#faf5ff' : '#eff6ff', color: tx.wallet_type === 'FUND' ? '#9333ea' : '#2563eb', padding: '2px 8px', borderRadius: '12px', fontSize: '0.75rem', fontWeight: '800' }">
                    {{ tx.wallet_type || 'MAIN' }}
                  </span>
                </td>
                <td style="padding: 10px; font-weight: 600; color: #1e293b;">
                  {{ tx.type || 'Transaction' }}
                </td>
                <td style="padding: 10px; text-align: right; font-weight: 800;" :style="{ color: String(tx.type || '').toLowerCase().includes('debit') || String(tx.type || '').toLowerCase().includes('deduct') ? '#dc2626' : '#16a34a' }">
                  {{ String(tx.type || '').toLowerCase().includes('debit') || String(tx.type || '').toLowerCase().includes('deduct') ? '-' : '+' }} ₹{{ parseFloat(tx.amount || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}
                </td>
                <td style="padding: 10px; text-align: center;">
                  <span :class="tx.status === 'Success' || tx.status === 'SUCCESS' || tx.status === 'APPROVED' ? 'badge-status-active' : 'badge-status-pending'">
                    {{ tx.status || 'Success' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div style="padding: 0.85rem 1.25rem; background: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end;">
        <button @click="$emit('close')" style="background: #2563eb; color: white; border: none; padding: 0.55rem 1.25rem; border-radius: 8px; font-weight: 700; cursor: pointer;">
          Close
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'UserTransactionsModal',
  props: {
    show: { type: Boolean, default: false },
    user: { type: Object, default: null },
    loading: { type: Boolean, default: false },
    searchQuery: { type: String, default: '' },
    filteredTxnList: { type: Array, default: () => [] }
  },
  data() {
    return {
      searchQueryLocal: this.searchQuery
    };
  },
  watch: {
    searchQuery(newVal) { this.searchQueryLocal = newVal; }
  }
};
</script>
