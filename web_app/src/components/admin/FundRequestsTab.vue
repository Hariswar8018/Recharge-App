<template>
  <div class="requests-pane">
    <div class="table-card">
      <div class="card-title-row">
        <h3>💳 Manage User Add Money / Fund Deposit Requests</h3>
        <span class="count-pill">{{ pendingRequestsCount }} Pending Requests</span>
      </div>

      <!-- STATUS FILTER TAB PILLS (Image 5 Style) -->
      <div class="status-tab-pills" style="display: flex; gap: 0.5rem; margin-bottom: 1rem; border-bottom: 2px solid #e2e8f0; padding-bottom: 0.5rem; overflow-x: auto;">
        <button 
          @click="$emit('update:reqFilterStatus', '')" 
          :class="['tab-pill', { active: !reqFilterStatus }]"
          style="padding: 0.5rem 1rem; border: none; border-radius: 20px; font-weight: 700; font-size: 0.85rem; cursor: pointer;"
          :style="{ background: !reqFilterStatus ? '#2563eb' : '#f1f5f9', color: !reqFilterStatus ? 'white' : '#475569' }"
        >
          All Requests ({{ fundRequests.length }})
        </button>
        <button 
          @click="$emit('update:reqFilterStatus', 'PENDING')" 
          :class="['tab-pill', { active: reqFilterStatus === 'PENDING' }]"
          style="padding: 0.5rem 1rem; border: none; border-radius: 20px; font-weight: 700; font-size: 0.85rem; cursor: pointer;"
          :style="{ background: reqFilterStatus === 'PENDING' ? '#f59e0b' : '#f1f5f9', color: reqFilterStatus === 'PENDING' ? 'white' : '#475569' }"
        >
          🟡 Pending Approval ({{ pendingRequestsCount }})
        </button>
        <button 
          @click="$emit('update:reqFilterStatus', 'APPROVED')" 
          :class="['tab-pill', { active: reqFilterStatus === 'APPROVED' }]"
          style="padding: 0.5rem 1rem; border: none; border-radius: 20px; font-weight: 700; font-size: 0.85rem; cursor: pointer;"
          :style="{ background: reqFilterStatus === 'APPROVED' ? '#10b981' : '#f1f5f9', color: reqFilterStatus === 'APPROVED' ? 'white' : '#475569' }"
        >
          🟢 Approved Credit
        </button>
        <button 
          @click="$emit('update:reqFilterStatus', 'REJECTED')" 
          :class="['tab-pill', { active: reqFilterStatus === 'REJECTED' }]"
          style="padding: 0.5rem 1rem; border: none; border-radius: 20px; font-weight: 700; font-size: 0.85rem; cursor: pointer;"
          :style="{ background: reqFilterStatus === 'REJECTED' ? '#ef4444' : '#f1f5f9', color: reqFilterStatus === 'REJECTED' ? 'white' : '#475569' }"
        >
          🔴 Rejected
        </button>
      </div>

      <!-- ADVANCED FILTER BAR -->
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 0.75rem; margin-bottom: 1.25rem; background: #f8fafc; padding: 1rem; border-radius: 10px; border: 1px solid #e2e8f0;">
        <!-- Search Query Input -->
        <div>
          <label style="font-size: 0.78rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">Search User / Mobile / UTR</label>
          <input 
            type="text" 
            v-model="reqSearchQueryLocal" 
            @input="$emit('update:reqSearchQuery', reqSearchQueryLocal)"
            placeholder="Search Member Name, Mobile, or UTR..." 
            style="width: 100%; padding: 0.55rem 0.75rem; border-radius: 6px; border: 1px solid #cbd5e1; outline: none; font-size: 0.85rem; box-sizing: border-box;"
          />
        </div>

        <!-- Filter Mode -->
        <div>
          <label style="font-size: 0.78rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">Filter Rule Mode</label>
          <select 
            v-model="reqFilterModeLocal" 
            @change="$emit('update:reqFilterMode', reqFilterModeLocal)"
            style="width: 100%; padding: 0.55rem 0.75rem; border-radius: 6px; border: 1px solid #cbd5e1; outline: none; font-size: 0.85rem; background: white;"
          >
            <option value="ALL">All Modes / Combined</option>
            <option value="UPI">UPI Direct / QR</option>
            <option value="MANUAL">Manual Bank Transfer</option>
          </select>
        </div>

        <!-- Payment Method -->
        <div>
          <label style="font-size: 0.78rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">Payment Method</label>
          <select 
            v-model="reqPaymentModeFilterLocal" 
            @change="$emit('update:reqPaymentModeFilter', reqPaymentModeFilterLocal)"
            style="width: 100%; padding: 0.55rem 0.75rem; border-radius: 6px; border: 1px solid #cbd5e1; outline: none; font-size: 0.85rem; background: white;"
          >
            <option value="">All Payment Modes</option>
            <option value="PhonePe">PhonePe / GPay UPI</option>
            <option value="QR">UPI QR Scanner</option>
            <option value="Bank Transfer">IMPS / NEFT Direct Bank</option>
          </select>
        </div>

        <!-- Amount Filter -->
        <div>
          <label style="font-size: 0.78rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">Filter by Amount</label>
          <select 
            v-model="reqAmountFilterLocal" 
            @change="$emit('update:reqAmountFilter', reqAmountFilterLocal)"
            style="width: 100%; padding: 0.55rem 0.75rem; border-radius: 6px; border: 1px solid #cbd5e1; outline: none; font-size: 0.85rem; background: white;"
          >
            <option value="">All Amounts</option>
            <option value="1200">₹ 1,200 (Package TopUp)</option>
            <option value="500">₹ 500</option>
            <option value="2000">₹ 2,000</option>
            <option value="5000">₹ 5,000</option>
          </select>
        </div>
      </div>

      <!-- TABLE CONTAINER -->
      <div class="table-container">
        <table class="nice-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Date & Time</th>
              <th>Member Name</th>
              <th>Mobile Number</th>
              <th>Payment Method</th>
              <th>UTR / Ref Number</th>
              <th>Amount</th>
              <th>Receipt</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="filteredRequests.length === 0">
              <td colspan="10" style="text-align: center; padding: 2rem; color: #64748b; font-weight: 600;">
                No fund requests found matching filters.
              </td>
            </tr>
            <tr v-for="req in filteredRequests" :key="req.id">
              <td>#{{ req.id }}</td>
              <td style="white-space: nowrap;">{{ req.createdAt ? String(req.createdAt).substring(0,16) : 'N/A' }}</td>
              <td class="font-bold">{{ req.fullName || 'User #' + req.user_id }}</td>
              <td>{{ req.mobileNumber || 'N/A' }}</td>
              <td>
                <span class="badge-payment">{{ req.payment_method || 'UPI / QR' }}</span>
              </td>
              <td class="font-mono">{{ req.utr_number || req.utr || 'N/A' }}</td>
              <td class="font-bold text-green">₹{{ parseFloat(req.amount).toFixed(2) }}</td>
              <td>
                <button v-if="req.payment_proof_url" @click="$emit('view-receipt', req)" class="btn-receipt-link">
                  📷 View Proof
                </button>
                <span v-else class="text-muted">No File</span>
              </td>
              <td>
                <span :class="req.status === 'APPROVED' ? 'badge-status-active' : (req.status === 'REJECTED' ? 'badge-status-blocked' : 'badge-status-pending')">
                  {{ req.status }}
                </span>
              </td>
              <td style="white-space: nowrap;">
                <div v-if="req.status === 'PENDING'" style="display: flex; gap: 4px;">
                  <button @click="$emit('approve-request', req.id)" class="btn-action-approve" style="background: #10b981; color: white; border: none; padding: 4px 8px; border-radius: 4px; font-weight: 700; font-size: 11px; cursor: pointer;">
                    ✓ Approve
                  </button>
                  <button @click="$emit('reject-request', req.id)" class="btn-action-reject" style="background: #ef4444; color: white; border: none; padding: 4px 8px; border-radius: 4px; font-weight: 700; font-size: 11px; cursor: pointer;">
                    ✗ Reject
                  </button>
                </div>
                <span v-else class="text-muted" style="font-size: 0.8rem;">Completed</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FundRequestsTab',
  props: {
    fundRequests: { type: Array, default: () => [] },
    filteredRequests: { type: Array, default: () => [] },
    pendingRequestsCount: { type: Number, default: 0 },
    reqFilterStatus: { type: String, default: '' },
    reqSearchQuery: { type: String, default: '' },
    reqFilterMode: { type: String, default: 'ALL' },
    reqPaymentModeFilter: { type: String, default: '' },
    reqAmountFilter: { type: String, default: '' }
  },
  data() {
    return {
      reqSearchQueryLocal: this.reqSearchQuery,
      reqFilterModeLocal: this.reqFilterMode,
      reqPaymentModeFilterLocal: this.reqPaymentModeFilter,
      reqAmountFilterLocal: this.reqAmountFilter
    };
  },
  watch: {
    reqSearchQuery(newVal) { this.reqSearchQueryLocal = newVal; },
    reqFilterMode(newVal) { this.reqFilterModeLocal = newVal; },
    reqPaymentModeFilter(newVal) { this.reqPaymentModeFilterLocal = newVal; },
    reqAmountFilter(newVal) { this.reqAmountFilterLocal = newVal; }
  }
};
</script>
