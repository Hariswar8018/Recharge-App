<template>
  <div v-if="show" class="invoice-modal-backdrop" @click="$emit('close')">
    <div class="invoice-modal-container" @click.stop style="max-width: 850px; width: 95%; padding: 0; overflow: hidden; border-radius: 12px; background: white; max-height: 90vh; display: flex; flex-direction: column;">
      <div style="background: #16a34a; color: white; padding: 1rem 1.25rem; display: flex; align-items: center; justify-content: space-between;">
        <h3 style="margin: 0; font-size: 1.1rem; display: flex; align-items: center; gap: 8px;">
          📊 Direct Referral Affiliates & Income Breakdown
          <span v-if="user" style="font-size: 0.85rem; font-weight: 500; opacity: 0.95;">
            — {{ user.fullName || user.email }} (#{{ user.id || user.mobileNumber }})
          </span>
        </h3>
        <button @click="$emit('close')" style="background: transparent; border: none; color: white; font-size: 1.4rem; cursor: pointer;">&times;</button>
      </div>
      
      <div style="padding: 1.25rem; overflow-y: auto; flex: 1;">
        <div v-if="loading" style="text-align: center; padding: 2.5rem; color: #64748b; font-weight: 700;">
          ⏳ Loading user referral & income records...
        </div>

        <div v-else>
          <!-- DIRECT SPONSORED DOWNLINES SUMMARY (PRIMARY SECTION) -->
          <div style="margin-bottom: 1.5rem;">
            <h4 style="margin: 0 0 0.75rem; font-size: 1rem; font-weight: 800; color: #0f172a; display: flex; align-items: center; justify-content: space-between;">
              <span>👥 Direct Sponsored Downline Affiliates</span>
              <span style="background: #f0fdf4; color: #166534; font-size: 0.8rem; padding: 3px 10px; border-radius: 12px; border: 1px solid #bbf7d0;">
                {{ incomeData.downlines ? incomeData.downlines.length : 0 }} Direct Referrals
              </span>
            </h4>

            <div v-if="!incomeData.downlines || incomeData.downlines.length === 0" style="padding: 1.25rem; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; text-align: center; color: #64748b; font-weight: 600; font-size: 0.88rem;">
              This user has no direct referrals yet.
            </div>
            <div v-else class="table-container" style="max-height: 30vh; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 8px;">
              <table class="nice-table" style="width: 100%; border-collapse: collapse; text-align: left; font-size: 0.85rem;">
                <thead>
                  <tr style="background: #f8fafc; border-bottom: 1px solid #e2e8f0; color: #475569; font-weight: 700;">
                    <th style="padding: 10px 12px;">User ID</th>
                    <th style="padding: 10px 12px;">Member Name</th>
                    <th style="padding: 10px 12px;">Mobile Number</th>
                    <th style="padding: 10px 12px;">Join Date</th>
                    <th style="padding: 10px 12px; text-align: right;">Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="d in incomeData.downlines" :key="d.id" style="border-bottom: 1px solid #f1f5f9;">
                    <td style="padding: 8px 12px; font-weight: 700; color: #2563eb;">#{{ d.id }}</td>
                    <td style="padding: 8px 12px; font-weight: 700; color: #0f172a;">{{ d.fullName }}</td>
                    <td style="padding: 8px 12px; color: #334155; font-weight: 600;">{{ d.mobileNumber }}</td>
                    <td style="padding: 8px 12px; color: #64748b;">{{ d.createdAt ? String(d.createdAt).substring(0,10) : 'N/A' }}</td>
                    <td style="padding: 8px 12px; text-align: right;">
                      <span style="background: #dcfce7; color: #15803d; padding: 2px 8px; border-radius: 12px; font-weight: 800; font-size: 0.75rem;">
                        {{ (d.status || 'ACTIVE').toUpperCase() }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- INCOME & CREDIT TRANSACTIONS LOG TABLE -->
          <div>
            <h4 style="margin: 0 0 0.75rem; font-size: 1rem; font-weight: 800; color: #0f172a;">
              💰 Income & Credit Records
            </h4>
            <div v-if="!incomeData.transactions || incomeData.transactions.length === 0" style="padding: 1.25rem; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; text-align: center; color: #64748b; font-weight: 600; font-size: 0.88rem;">
              No income payout records found for this user yet.
            </div>
            <div v-else class="table-container" style="max-height: 35vh; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 8px;">
              <table class="nice-table" style="width: 100%; border-collapse: collapse; text-align: left; font-size: 0.85rem;">
                <thead>
                  <tr style="background: #f8fafc; border-bottom: 1px solid #e2e8f0; color: #475569; font-weight: 700;">
                    <th style="padding: 10px 12px;">Date & Time</th>
                    <th style="padding: 10px 12px;">Income Type</th>
                    <th style="padding: 10px 12px;">Wallet</th>
                    <th style="padding: 10px 12px; text-align: right;">Amount Credited</th>
                    <th style="padding: 10px 12px; text-align: center;">Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="t in incomeData.transactions" :key="t.id" style="border-bottom: 1px solid #f1f5f9;">
                    <td style="padding: 8px 12px; color: #64748b; white-space: nowrap;">
                      {{ formatTxnDate(t) }}
                    </td>
                    <td style="padding: 8px 12px; font-weight: 700; color: #0f172a;">{{ t.type }}</td>
                    <td style="padding: 8px 12px;">
                      <span style="background: #eff6ff; color: #2563eb; padding: 2px 8px; border-radius: 10px; font-size: 0.75rem; font-weight: 800;">
                        {{ (t.wallet_type || 'MAIN').toUpperCase() }}
                      </span>
                    </td>
                    <td style="padding: 8px 12px; text-align: right; font-weight: 800; color: #16a34a;">
                      + ₹ {{ formatAmount(t.amount) }}
                    </td>
                    <td style="padding: 8px 12px; text-align: center;">
                      <span style="background: #dcfce7; color: #15803d; padding: 2px 8px; border-radius: 12px; font-weight: 800; font-size: 0.75rem;">
                        {{ t.status || 'Success' }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <div style="padding: 0.85rem 1.25rem; background: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end;">
        <button @click="$emit('close')" style="background: #16a34a; color: white; border: none; padding: 0.6rem 1.4rem; border-radius: 8px; font-weight: 700; cursor: pointer;">
          Close
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'UserIncomeModal',
  props: {
    show: { type: Boolean, default: false },
    user: { type: Object, default: null },
    loading: { type: Boolean, default: false },
    incomeData: {
      type: Object,
      default: () => ({
        transactions: [],
        downlines: []
      })
    }
  },
  methods: {
    formatAmount(val) {
      if (val === null || val === undefined) return '0.00';
      if (typeof val === 'number') {
        return isNaN(val) ? '0.00' : val.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
      }
      const cleanStr = String(val).replace(/[^0-9.-]/g, '');
      const num = parseFloat(cleanStr);
      return isNaN(num) ? '0.00' : num.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    },
    formatTxnDate(t) {
      if (!t) return 'N/A';
      if (t.date) return t.date;
      if (t.createdAt) {
        const d = new Date(t.createdAt);
        if (!isNaN(d.getTime())) {
          return d.toLocaleDateString('en-IN') + ' ' + d.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' });
        }
        return String(t.createdAt).substring(0, 19).replace('T', ' ');
      }
      return 'N/A';
    }
  }
};
</script>
