<template>
  <div v-if="show" class="invoice-modal-backdrop" @click="$emit('close')">
    <div class="invoice-modal-container" @click.stop style="max-width: 850px; width: 95%; padding: 0; overflow: hidden; border-radius: 12px; background: white; max-height: 90vh; display: flex; flex-direction: column;">
      <div style="background: #16a34a; color: white; padding: 1rem 1.25rem; display: flex; align-items: center; justify-content: space-between;">
        <h3 style="margin: 0; font-size: 1.1rem; display: flex; align-items: center; gap: 8px;">
          📊 Income & Earnings Breakdown
          <span v-if="user" style="font-size: 0.85rem; font-weight: 500; opacity: 0.95;">
            — {{ user.fullName || user.email }} (#{{ user.id || user.mobileNumber }})
          </span>
        </h3>
        <button @click="$emit('close')" style="background: transparent; border: none; color: white; font-size: 1.4rem; cursor: pointer;">&times;</button>
      </div>
      
      <div style="padding: 1.25rem; overflow-y: auto; flex: 1;">
        <div v-if="loading" style="text-align: center; padding: 2.5rem; color: #64748b; font-weight: 700;">
          ⏳ Loading user income records...
        </div>

        <div v-else>
          <!-- SUMMARY STAT CARDS -->
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); gap: 1rem; margin-bottom: 1.25rem;">
            <div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 10px; padding: 0.85rem;">
              <div style="font-size: 0.78rem; font-weight: 700; color: #15803d; text-transform: uppercase;">Total Income Earned</div>
              <div style="font-size: 1.3rem; font-weight: 900; color: #16a34a; margin-top: 4px;">₹ {{ parseFloat(incomeData.totalIncome || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</div>
            </div>
            <div style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px; padding: 0.85rem;">
              <div style="font-size: 0.78rem; font-weight: 700; color: #1d4ed8; text-transform: uppercase;">Direct Sponsor Income</div>
              <div style="font-size: 1.3rem; font-weight: 900; color: #2563eb; margin-top: 4px;">₹ {{ parseFloat(incomeData.directIncome || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</div>
            </div>
            <div style="background: #faf5ff; border: 1px solid #e9d5ff; border-radius: 10px; padding: 0.85rem;">
              <div style="font-size: 0.78rem; font-weight: 700; color: #7e22ce; text-transform: uppercase;">Single Leg Level Income</div>
              <div style="font-size: 1.3rem; font-weight: 900; color: #9333ea; margin-top: 4px;">₹ {{ parseFloat(incomeData.singleLegIncome || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</div>
            </div>
            <div style="background: #fff7ed; border: 1px solid #fed7aa; border-radius: 10px; padding: 0.85rem;">
              <div style="font-size: 0.78rem; font-weight: 700; color: #c2410c; text-transform: uppercase;">Captcha Rewards</div>
              <div style="font-size: 1.3rem; font-weight: 900; color: #ea580c; margin-top: 4px;">₹ {{ parseFloat(incomeData.captchaIncome || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</div>
            </div>
          </div>

          <!-- INCOME TRANSACTIONS LOG TABLE -->
          <div style="margin-bottom: 1.5rem;">
            <h4 style="margin: 0 0 0.75rem; font-size: 0.95rem; font-weight: 800; color: #1e293b;">
              💰 Income Credit Records
            </h4>
            <div v-if="!incomeData.transactions || incomeData.transactions.length === 0" style="padding: 1.25rem; background: #f8fafc; border-radius: 8px; text-align: center; color: #64748b; font-weight: 600; font-size: 0.85rem;">
              No income payout records found for this user yet.
            </div>
            <div v-else class="table-container" style="max-height: 35vh; overflow-y: auto;">
              <table class="nice-table" style="width: 100%; border-collapse: collapse;">
                <thead>
                  <tr style="background: #f1f5f9; text-align: left; font-size: 0.8rem; color: #475569;">
                    <th style="padding: 8px 10px;">Date</th>
                    <th style="padding: 8px 10px;">Income Type</th>
                    <th style="padding: 8px 10px;">Wallet</th>
                    <th style="padding: 8px 10px; text-align: right;">Amount Credited</th>
                    <th style="padding: 8px 10px; text-align: center;">Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="t in incomeData.transactions" :key="t.id" style="border-bottom: 1px solid #e2e8f0; font-size: 0.85rem;">
                    <td style="padding: 8px 10px; color: #64748b;">{{ t.date || (t.createdAt ? String(t.createdAt).substring(0, 10) : 'N/A') }}</td>
                    <td style="padding: 8px 10px; font-weight: 700; color: #1e293b;">{{ t.type }}</td>
                    <td style="padding: 8px 10px;"><span style="background: #eff6ff; color: #2563eb; padding: 2px 8px; border-radius: 10px; font-size: 0.75rem; font-weight: 800;">{{ t.wallet_type || 'MAIN' }}</span></td>
                    <td style="padding: 8px 10px; text-align: right; font-weight: 800; color: #16a34a;">+ ₹{{ parseFloat(t.amount || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</td>
                    <td style="padding: 8px 10px; text-align: center;"><span class="badge-status-active">{{ t.status || 'Success' }}</span></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- DIRECT SPONSORED DOWNLINES SUMMARY -->
          <div>
            <h4 style="margin: 0 0 0.75rem; font-size: 0.95rem; font-weight: 800; color: #1e293b;">
              👥 Direct Sponsored Downline Affiliates ({{ incomeData.downlines ? incomeData.downlines.length : 0 }})
            </h4>
            <div v-if="!incomeData.downlines || incomeData.downlines.length === 0" style="padding: 1rem; background: #f8fafc; border-radius: 8px; text-align: center; color: #64748b; font-weight: 600; font-size: 0.85rem;">
              This user has no direct referrals yet.
            </div>
            <div v-else class="table-container" style="max-height: 25vh; overflow-y: auto;">
              <table class="nice-table" style="width: 100%; border-collapse: collapse;">
                <thead>
                  <tr style="background: #f1f5f9; text-align: left; font-size: 0.8rem; color: #475569;">
                    <th style="padding: 8px 10px;">User ID</th>
                    <th style="padding: 8px 10px;">Member Name</th>
                    <th style="padding: 8px 10px;">Mobile Number</th>
                    <th style="padding: 8px 10px;">Join Date</th>
                    <th style="padding: 8px 10px; text-align: center;">Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="d in incomeData.downlines" :key="d.id" style="border-bottom: 1px solid #e2e8f0; font-size: 0.85rem;">
                    <td style="padding: 8px 10px; font-weight: 700;">#{{ d.id }}</td>
                    <td style="padding: 8px 10px; font-weight: 700; color: #1e293b;">{{ d.fullName }}</td>
                    <td style="padding: 8px 10px; color: #64748b;">{{ d.mobileNumber }}</td>
                    <td style="padding: 8px 10px; color: #64748b;">{{ d.createdAt ? String(d.createdAt).substring(0,10) : 'N/A' }}</td>
                    <td style="padding: 8px 10px; text-align: center;"><span class="badge-status-active">{{ d.status || 'ACTIVE' }}</span></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <div style="padding: 0.85rem 1.25rem; background: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end;">
        <button @click="$emit('close')" style="background: #16a34a; color: white; border: none; padding: 0.55rem 1.25rem; border-radius: 8px; font-weight: 700; cursor: pointer;">
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
        totalIncome: '0.00',
        directIncome: '0.00',
        singleLegIncome: '0.00',
        captchaIncome: '0.00',
        transactions: [],
        downlines: []
      })
    }
  }
};
</script>
