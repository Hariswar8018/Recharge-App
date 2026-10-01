<template>
  <div class="withdrawals-management">
    <!-- TOP METRICS STATS BAR -->
    <div class="stats-grid">
      <div class="stat-card total" @click="filterStatus = 'ALL'" :class="{ active: filterStatus === 'ALL' }">
        <div class="stat-icon">📋</div>
        <div class="stat-info">
          <span class="label">Total Cashout Requests</span>
          <h3 class="value">{{ requests.length }}</h3>
          <span class="sub-label">₹{{ formatAmount(totalAmount) }} Total</span>
        </div>
      </div>

      <div class="stat-card pending" @click="filterStatus = 'PENDING'" :class="{ active: filterStatus === 'PENDING' }">
        <div class="stat-icon">⏳</div>
        <div class="stat-info">
          <span class="label">Pending Payouts</span>
          <h3 class="value">{{ pendingCount }}</h3>
          <span class="sub-label">₹{{ formatAmount(pendingAmount) }} Awaiting</span>
        </div>
      </div>

      <div class="stat-card approved" @click="filterStatus = 'APPROVED'" :class="{ active: filterStatus === 'APPROVED' }">
        <div class="stat-icon">✅</div>
        <div class="stat-info">
          <span class="label">Approved Payouts</span>
          <h3 class="value">{{ approvedCount }}</h3>
          <span class="sub-label">₹{{ formatAmount(approvedAmount) }} Settled</span>
        </div>
      </div>

      <div class="stat-card rejected" @click="filterStatus = 'REJECTED'" :class="{ active: filterStatus === 'REJECTED' }">
        <div class="stat-icon">❌</div>
        <div class="stat-info">
          <span class="label">Rejected Payouts</span>
          <h3 class="value">{{ rejectedCount }}</h3>
          <span class="sub-label">₹{{ formatAmount(rejectedAmount) }} Refunded</span>
        </div>
      </div>
    </div>

    <!-- MAIN CONTROL PANEL HEADER -->
    <div class="card panel-card">
      <div class="panel-header">
        <div class="header-title">
          <h2>🏦 Payout / Withdrawal Management</h2>
          <p>Manage, review, approve, reject, and export member cashout requests.</p>
        </div>
        <div class="header-actions">
          <button @click="downloadExcel" class="btn btn-excel">
            📥 Download Excel Report
          </button>
          <button @click="fetchWithdrawals" class="btn btn-secondary btn-icon" title="Refresh list">
            🔄 Refresh
          </button>
        </div>
      </div>

      <!-- FILTER & SEARCH TOOLBAR -->
      <div class="toolbar">
        <!-- STATUS TABS -->
        <div class="status-tabs">
          <button 
            @click="filterStatus = 'ALL'" 
            class="tab-btn" 
            :class="{ active: filterStatus === 'ALL' }"
          >
            All Requests ({{ requests.length }})
          </button>
          <button 
            @click="filterStatus = 'PENDING'" 
            class="tab-btn pending" 
            :class="{ active: filterStatus === 'PENDING' }"
          >
            Pending ({{ pendingCount }})
          </button>
          <button 
            @click="filterStatus = 'APPROVED'" 
            class="tab-btn approved" 
            :class="{ active: filterStatus === 'APPROVED' }"
          >
            Approved ({{ approvedCount }})
          </button>
          <button 
            @click="filterStatus = 'REJECTED'" 
            class="tab-btn rejected" 
            :class="{ active: filterStatus === 'REJECTED' }"
          >
            Rejected ({{ rejectedCount }})
          </button>
        </div>

        <!-- SEARCH BAR & DATE FILTERS -->
        <div class="filter-controls">
          <div class="search-box">
            <span class="search-icon">🔍</span>
            <input 
              type="text" 
              v-model="searchQuery" 
              placeholder="Search User ID, Name, Mobile, A/C No, IFSC..." 
              class="form-control"
            />
            <button v-if="searchQuery" @click="searchQuery = ''" class="clear-btn">&times;</button>
          </div>

          <div class="date-filter-group">
            <div class="date-input-wrap">
              <label>From:</label>
              <input type="date" v-model="startDate" class="form-control date-input" />
            </div>
            <div class="date-input-wrap">
              <label>To:</label>
              <input type="date" v-model="endDate" class="form-control date-input" />
            </div>
            <button v-if="startDate || endDate" @click="clearDates" class="btn btn-sm btn-ghost">
              Clear Dates
            </button>
          </div>
        </div>

        <!-- BULK ACTIONS TOOLBAR -->
        <div class="bulk-action-bar">
          <div class="select-info">
            <label class="checkbox-container">
              <input 
                type="checkbox" 
                :checked="isAllSelected" 
                @change="toggleSelectAll" 
                :disabled="filteredRequests.length === 0"
              />
              <span class="checkmark"></span>
              <strong>Select All</strong> ({{ selectedIds.length }} / {{ filteredRequests.length }} selected)
            </label>
          </div>

          <div class="bulk-buttons">
            <button 
              @click="handleBulkApprove" 
              class="btn btn-success btn-sm" 
              :disabled="selectedIds.length === 0 || processingAction"
            >
              ✅ Bulk Approve Selected ({{ selectedIds.length }})
            </button>
            <button 
              @click="openRejectModal(selectedIds)" 
              class="btn btn-danger btn-sm" 
              :disabled="selectedIds.length === 0 || processingAction"
            >
              ❌ Bulk Reject Selected ({{ selectedIds.length }})
            </button>
            <button 
              @click="handleApproveAllPending" 
              class="btn btn-warning btn-sm" 
              :disabled="pendingCount === 0 || processingAction"
            >
              ⚡ Approve All Pending ({{ pendingCount }})
            </button>
          </div>
        </div>
      </div>

      <!-- DATA TABLE -->
      <div class="table-responsive">
        <div v-if="loading" class="loading-state">
          <div class="spinner"></div>
          <p>Loading withdrawal requests...</p>
        </div>

        <div v-else-if="filteredRequests.length === 0" class="empty-state">
          <span class="empty-icon">📂</span>
          <h3>No Withdrawal Requests Found</h3>
          <p>There are no cashout requests matching your current filters or search query.</p>
        </div>

        <table v-else class="data-table">
          <thead>
            <tr>
              <th class="col-checkbox">
                <input 
                  type="checkbox" 
                  :checked="isAllSelected" 
                  @change="toggleSelectAll"
                />
              </th>
              <th>Request ID & Date</th>
              <th>User Information</th>
              <th>Available Balance</th>
              <th>Withdrawal Amount</th>
              <th>Bank Details</th>
              <th>Status</th>
              <th>Rejection Reason</th>
              <th class="col-actions">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr 
              v-for="req in filteredRequests" 
              :key="req.id"
              :class="{ 'selected-row': selectedIds.includes(req.id) }"
            >
              <td class="col-checkbox">
                <input 
                  type="checkbox" 
                  :value="req.id" 
                  v-model="selectedIds"
                />
              </td>

              <!-- Request ID & Date -->
              <td>
                <div class="id-badge">#REQ-{{ req.id }}</div>
                <div class="date-text">{{ formatDate(req.createdAt) }}</div>
              </td>

              <!-- User Information -->
              <td>
                <div class="user-name">{{ req.fullName || 'Member #' + req.user_id }}</div>
                <div class="sub-text">ID: <strong>#{{ req.user_id }}</strong></div>
                <div class="sub-text">📞 {{ req.mobileNumber || 'N/A' }}</div>
                <div v-if="req.email" class="sub-text text-muted">✉️ {{ req.email }}</div>
              </td>

              <!-- Available Balance -->
              <td>
                <span class="balance-tag">
                  ₹{{ formatAmount(req.available_balance) }}
                </span>
              </td>

              <!-- Withdrawal Amount -->
              <td>
                <div class="amount-main">₹{{ formatAmount(req.amount) }}</div>
                <div class="fee-text">- ₹{{ formatAmount(req.deduction_fee) }} (15% Fee)</div>
                <div class="net-text">Net: <strong>₹{{ formatAmount(req.net_amount) }}</strong></div>
              </td>

              <!-- Bank Details -->
              <td>
                <div class="bank-box">
                  <div class="bank-name">🏛️ {{ req.bank_name || 'Bank Not Set' }}</div>
                  <div class="bank-acc"><strong>A/C:</strong> {{ req.account_no || 'N/A' }}</div>
                  <div class="bank-ifsc"><strong>IFSC:</strong> {{ req.ifsc || 'N/A' }}</div>
                  <div class="bank-holder"><strong>Holder:</strong> {{ req.account_holder || 'N/A' }}</div>
                  <div v-if="req.branch" class="bank-branch">Branch: {{ req.branch }}</div>
                </div>
              </td>

              <!-- Status -->
              <td>
                <span :class="['status-badge', req.status.toLowerCase()]">
                  {{ req.status }}
                </span>
                <div v-if="req.processed_at" class="processed-date">
                  {{ formatDate(req.processed_at) }}
                </div>
              </td>

              <!-- Rejection Reason -->
              <td>
                <span v-if="req.rejection_reason" class="reason-tag">
                  ⚠️ {{ req.rejection_reason }}
                </span>
                <span v-else class="text-muted">—</span>
              </td>

              <!-- Actions -->
              <td class="col-actions">
                <div v-if="req.status === 'PENDING'" class="action-buttons">
                  <button 
                    @click="handleSingleApprove(req.id)" 
                    class="btn btn-success btn-xs"
                    :disabled="processingAction"
                  >
                    Approve
                  </button>
                  <button 
                    @click="openRejectModal([req.id])" 
                    class="btn btn-danger btn-xs"
                    :disabled="processingAction"
                  >
                    Reject
                  </button>
                </div>
                <div v-else class="completed-tag">
                  {{ req.status === 'APPROVED' ? 'Settled' : 'Closed' }}
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- REJECTION REASON MODAL -->
    <div v-if="showRejectModal" class="modal-backdrop" @click="closeRejectModal">
      <div class="modal-dialog" @click.stop>
        <div class="modal-header">
          <h3>❌ Reject Withdrawal Request(s)</h3>
          <button @click="closeRejectModal" class="close-modal-btn">&times;</button>
        </div>

        <div class="modal-body">
          <p class="modal-intro">
            You are rejecting <strong>{{ targetRejectIds.length }}</strong> withdrawal request(s). 
            The requested withdrawal amount will be <strong>refunded back to the user's Main Wallet</strong>.
          </p>

          <label class="field-label">Quick Reason Presets:</label>
          <div class="preset-chips">
            <button 
              v-for="preset in rejectPresets" 
              :key="preset"
              @click="rejectionReason = preset"
              type="button" 
              class="chip-btn"
              :class="{ active: rejectionReason === preset }"
            >
              {{ preset }}
            </button>
          </div>

          <label class="field-label" style="margin-top: 1rem;">Rejection Reason (Visible to User):</label>
          <textarea 
            v-model="rejectionReason" 
            rows="3" 
            placeholder="Enter reason for rejecting this cashout request..." 
            class="form-control"
          ></textarea>
        </div>

        <div class="modal-footer">
          <button @click="closeRejectModal" class="btn btn-secondary">Cancel</button>
          <button 
            @click="submitRejection" 
            class="btn btn-danger" 
            :disabled="!rejectionReason.trim() || processingAction"
          >
            Confirm Rejection & Refund Wallet
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'WithdrawalsTab',
  emits: ['trigger-toast'],
  data() {
    return {
      requests: [],
      loading: true,
      filterStatus: 'ALL',
      searchQuery: '',
      startDate: '',
      endDate: '',
      selectedIds: [],
      processingAction: false,

      // Reject Modal State
      showRejectModal: false,
      targetRejectIds: [],
      rejectionReason: 'Invalid Bank Account Details',
      rejectPresets: [
        'Invalid Bank Account Details',
        'IFSC Code Mismatch',
        'Account Holder Name Mismatch',
        'Bank Account Not Verified',
        'Duplicate Withdrawal Request'
      ]
    };
  },
  computed: {
    filteredRequests() {
      return this.requests.filter(req => {
        // 1. Status Filter
        if (this.filterStatus !== 'ALL' && (req.status || '').toUpperCase() !== this.filterStatus) {
          return false;
        }

        // 2. Search Query Filter
        if (this.searchQuery.trim() !== '') {
          const q = this.searchQuery.toLowerCase().trim();
          const matchUser = (req.fullName || '').toLowerCase().includes(q) ||
                            (req.mobileNumber || '').toLowerCase().includes(q) ||
                            (req.email || '').toLowerCase().includes(q) ||
                            String(req.user_id).includes(q);
          const matchBank = (req.account_no || '').toLowerCase().includes(q) ||
                            (req.ifsc || '').toLowerCase().includes(q) ||
                            (req.account_holder || '').toLowerCase().includes(q) ||
                            (req.bank_name || '').toLowerCase().includes(q);
          const matchReq = String(req.id).includes(q);

          if (!matchUser && !matchBank && !matchReq) return false;
        }

        // 3. Date Range Filter
        if (this.startDate) {
          const reqDate = new Date(req.createdAt).toISOString().split('T')[0];
          if (reqDate < this.startDate) return false;
        }
        if (this.endDate) {
          const reqDate = new Date(req.createdAt).toISOString().split('T')[0];
          if (reqDate > this.endDate) return false;
        }

        return true;
      });
    },

    totalAmount() {
      return this.requests.reduce((sum, r) => sum + parseFloat(r.amount || 0), 0);
    },

    pendingCount() {
      return this.requests.filter(r => (r.status || '').toUpperCase() === 'PENDING').length;
    },
    pendingAmount() {
      return this.requests
        .filter(r => (r.status || '').toUpperCase() === 'PENDING')
        .reduce((sum, r) => sum + parseFloat(r.amount || 0), 0);
    },

    approvedCount() {
      return this.requests.filter(r => (r.status || '').toUpperCase() === 'APPROVED').length;
    },
    approvedAmount() {
      return this.requests
        .filter(r => (r.status || '').toUpperCase() === 'APPROVED')
        .reduce((sum, r) => sum + parseFloat(r.amount || 0), 0);
    },

    rejectedCount() {
      return this.requests.filter(r => (r.status || '').toUpperCase() === 'REJECTED').length;
    },
    rejectedAmount() {
      return this.requests
        .filter(r => (r.status || '').toUpperCase() === 'REJECTED')
        .reduce((sum, r) => sum + parseFloat(r.amount || 0), 0);
    },

    isAllSelected() {
      if (this.filteredRequests.length === 0) return false;
      return this.filteredRequests.every(r => this.selectedIds.includes(r.id));
    }
  },
  mounted() {
    this.fetchWithdrawals();
  },
  methods: {
    async fetchWithdrawals() {
      this.loading = true;
      try {
        const token = localStorage.getItem('adminToken');
        const res = await fetch('https://api.srdigitalseva.com/api/admin/withdrawals', {
          headers: {
            'x-app-token': 'srdigitalseva-secret-app-token-2026',
            'Authorization': `Bearer ${token}`
          }
        });
        if (res.ok) {
          const data = await res.json();
          this.requests = data || [];
        } else {
          console.error('Failed to load withdrawals:', await res.text());
        }
      } catch (err) {
        console.error('Error fetching withdrawal requests:', err);
      } finally {
        this.loading = false;
      }
    },

    formatAmount(val) {
      const num = parseFloat(val || 0);
      return isNaN(num) ? '0.00' : num.toFixed(2);
    },

    formatDate(dateStr) {
      if (!dateStr) return 'N/A';
      try {
        const d = new Date(dateStr);
        if (isNaN(d.getTime())) return dateStr;
        return d.toLocaleString('en-IN', {
          day: '2-digit',
          month: 'short',
          year: 'numeric',
          hour: '2-digit',
          minute: '2-digit',
          hour12: true
        });
      } catch (e) {
        return dateStr;
      }
    },

    toggleSelectAll(e) {
      if (e.target.checked) {
        this.selectedIds = this.filteredRequests.map(r => r.id);
      } else {
        this.selectedIds = [];
      }
    },

    clearDates() {
      this.startDate = '';
      this.endDate = '';
    },

    async handleSingleApprove(reqId) {
      await this.approveRequests([reqId]);
    },

    async handleBulkApprove() {
      if (this.selectedIds.length === 0) return;
      await this.approveRequests(this.selectedIds);
    },

    async handleApproveAllPending() {
      if (this.pendingCount === 0) return;
      await this.approveRequests([], true);
    },

    async approveRequests(ids, approveAllPending = false) {
      this.processingAction = true;
      try {
        const token = localStorage.getItem('adminToken');
        const res = await fetch('https://api.srdigitalseva.com/api/admin/withdrawals/approve', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-app-token': 'srdigitalseva-secret-app-token-2026',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({ ids, approveAllPending })
        });
        const data = await res.json();
        if (res.ok) {
          this.$emit('trigger-toast', data.message || 'Withdrawal request(s) approved successfully!');
          this.selectedIds = [];
          await this.fetchWithdrawals();
        } else {
          alert(data.error || 'Failed to approve withdrawal request');
        }
      } catch (err) {
        console.error('Error approving withdrawals:', err);
        alert('Server error while approving withdrawal request');
      } finally {
        this.processingAction = false;
      }
    },

    openRejectModal(ids) {
      if (!ids || ids.length === 0) return;
      this.targetRejectIds = ids;
      this.rejectionReason = 'Invalid Bank Account Details';
      this.showRejectModal = true;
    },

    closeRejectModal() {
      this.showRejectModal = false;
      this.targetRejectIds = [];
    },

    async submitRejection() {
      if (this.targetRejectIds.length === 0 || !this.rejectionReason.trim()) return;

      this.processingAction = true;
      try {
        const token = localStorage.getItem('adminToken');
        const res = await fetch('https://api.srdigitalseva.com/api/admin/withdrawals/reject', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-app-token': 'srdigitalseva-secret-app-token-2026',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({
            ids: this.targetRejectIds,
            rejection_reason: this.rejectionReason.trim()
          })
        });
        const data = await res.json();
        if (res.ok) {
          this.$emit('trigger-toast', data.message || 'Withdrawal request(s) rejected and funds refunded.');
          this.closeRejectModal();
          this.selectedIds = [];
          await this.fetchWithdrawals();
        } else {
          alert(data.error || 'Failed to reject withdrawal request');
        }
      } catch (err) {
        console.error('Error rejecting withdrawals:', err);
        alert('Server error while rejecting withdrawal request');
      } finally {
        this.processingAction = false;
      }
    },

    // Excel Export Feature
    downloadExcel() {
      if (this.filteredRequests.length === 0) {
        alert('No withdrawal data to export');
        return;
      }

      const headers = [
        'Request ID',
        'Date & Time',
        'User ID',
        'Full Name',
        'Mobile Number',
        'Email',
        'Available Balance (INR)',
        'Requested Amount (INR)',
        '15% Deduction Fee (INR)',
        'Net Amount Payable (INR)',
        'Bank Name',
        'Account Holder Name',
        'Account Number',
        'IFSC Code',
        'Branch',
        'Account Type',
        'Status',
        'Rejection Reason',
        'Processed At'
      ];

      const rows = this.filteredRequests.map(r => [
        `"REQ-${r.id}"`,
        `"${this.formatDate(r.createdAt)}"`,
        `"#${r.user_id}"`,
        `"${(r.fullName || '').replace(/"/g, '""')}"`,
        `"${r.mobileNumber || ''}"`,
        `"${r.email || ''}"`,
        `"${this.formatAmount(r.available_balance)}"`,
        `"${this.formatAmount(r.amount)}"`,
        `"${this.formatAmount(r.deduction_fee)}"`,
        `"${this.formatAmount(r.net_amount)}"`,
        `"${(r.bank_name || '').replace(/"/g, '""')}"`,
        `"${(r.account_holder || '').replace(/"/g, '""')}"`,
        `"'${r.account_no || ''}"`, // apostrophe prevents excel scientific notation
        `"${r.ifsc || ''}"`,
        `"${(r.branch || '').replace(/"/g, '""')}"`,
        `"${r.account_type || 'Savings'}"`,
        `"${r.status || 'PENDING'}"`,
        `"${(r.rejection_reason || '').replace(/"/g, '""')}"`,
        `"${this.formatDate(r.processed_at)}"`
      ]);

      const csvContent = '\uFEFF' + [headers.join(','), ...rows.map(row => row.join(','))].join('\n');
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      const filename = `Payout_Withdrawal_Requests_${new Date().toISOString().slice(0,10)}.csv`;

      link.setAttribute('href', url);
      link.setAttribute('download', filename);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      this.$emit('trigger-toast', 'Excel report downloaded successfully!');
    }
  }
};
</script>

<style scoped>
.withdrawals-management {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

/* STATS GRID */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1rem;
}

.stat-card {
  background: white;
  padding: 1.25rem;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  display: flex;
  align-items: center;
  gap: 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 2px 4px rgba(0,0,0,0.03);
}

.stat-card:hover, .stat-card.active {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0,0,0,0.08);
}

.stat-card.total.active { border-color: #3b82f6; background: #eff6ff; }
.stat-card.pending.active { border-color: #f59e0b; background: #fffbebfb; }
.stat-card.approved.active { border-color: #10b981; background: #ecfdf5; }
.stat-card.rejected.active { border-color: #ef4444; background: #fef2f2; }

.stat-icon {
  font-size: 2rem;
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 10px;
  background: #f8fafc;
}

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-info .label {
  font-size: 0.78rem;
  color: #64748b;
  font-weight: 600;
  text-transform: uppercase;
}

.stat-info .value {
  font-size: 1.5rem;
  font-weight: 800;
  color: #0f172a;
  margin: 0.15rem 0;
}

.stat-info .sub-label {
  font-size: 0.78rem;
  color: #475569;
  font-weight: 700;
}

/* PANEL CARD */
.panel-card {
  background: white;
  border-radius: 14px;
  border: 1px solid #e2e8f0;
  padding: 1.25rem;
  box-shadow: 0 4px 12px rgba(0,0,0,0.04);
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 1rem;
  border-bottom: 1px solid #f1f5f9;
}

.header-title h2 {
  margin: 0;
  font-size: 1.25rem;
  color: #0f172a;
  font-weight: 800;
}

.header-title p {
  margin: 0.2rem 0 0 0;
  font-size: 0.85rem;
  color: #64748b;
}

.header-actions {
  display: flex;
  gap: 0.75rem;
}

/* TOOLBAR & FILTERS */
.toolbar {
  margin-top: 1rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.status-tabs {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.tab-btn {
  padding: 0.55rem 1rem;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  background: #f8fafc;
  color: #475569;
  font-weight: 700;
  font-size: 0.85rem;
  cursor: pointer;
  transition: all 0.2s;
}

.tab-btn:hover { background: #e2e8f0; }

.tab-btn.active {
  background: #0f172a;
  color: white;
  border-color: #0f172a;
}
.tab-btn.pending.active { background: #d97706; border-color: #d97706; }
.tab-btn.approved.active { background: #16a34a; border-color: #16a34a; }
.tab-btn.rejected.active { background: #dc2626; border-color: #dc2626; }

.filter-controls {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  background: #f8fafc;
  padding: 0.85rem;
  border-radius: 10px;
  border: 1px solid #e2e8f0;
}

.search-box {
  position: relative;
  flex: 1;
  min-width: 260px;
  display: flex;
  align-items: center;
}

.search-box .search-icon {
  position: absolute;
  left: 10px;
  color: #94a3b8;
}

.search-box input {
  padding-left: 32px;
  width: 100%;
}

.clear-btn {
  position: absolute;
  right: 10px;
  background: transparent;
  border: none;
  font-size: 1.2rem;
  color: #64748b;
  cursor: pointer;
}

.date-filter-group {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.date-input-wrap {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.82rem;
  font-weight: 600;
  color: #475569;
}

.date-input {
  padding: 0.35rem 0.6rem;
  font-size: 0.82rem;
}

/* BULK ACTION BAR */
.bulk-action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #eff6ff;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  border: 1px solid #bfdbfe;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.select-info {
  font-size: 0.88rem;
  color: #1e40af;
}

.bulk-buttons {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

/* TABLE */
.table-responsive {
  margin-top: 1rem;
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.88rem;
}

.data-table th {
  background: #f8fafc;
  padding: 0.75rem 0.85rem;
  text-align: left;
  font-weight: 700;
  color: #475569;
  border-bottom: 2px solid #e2e8f0;
  white-space: nowrap;
}

.data-table td {
  padding: 0.85rem;
  border-bottom: 1px solid #f1f5f9;
  vertical-align: top;
}

.selected-row {
  background: #f0f9ff !important;
}

.id-badge {
  font-weight: 800;
  color: #0f172a;
}

.date-text {
  font-size: 0.75rem;
  color: #64748b;
  margin-top: 2px;
}

.user-name {
  font-weight: 700;
  color: #1e293b;
}

.sub-text {
  font-size: 0.78rem;
  color: #64748b;
}

.balance-tag {
  background: #dcfce7;
  color: #15803d;
  font-weight: 800;
  padding: 0.25rem 0.55rem;
  border-radius: 6px;
  font-size: 0.82rem;
  display: inline-block;
}

.amount-main {
  font-weight: 800;
  color: #0f172a;
  font-size: 0.95rem;
}

.fee-text {
  font-size: 0.75rem;
  color: #dc2626;
}

.net-text {
  font-size: 0.8rem;
  color: #16a34a;
  margin-top: 2px;
}

.bank-box {
  background: #f8fafc;
  padding: 0.5rem 0.75rem;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  font-size: 0.78rem;
}

.bank-name {
  font-weight: 800;
  color: #1e293b;
  margin-bottom: 2px;
}

.status-badge {
  padding: 0.25rem 0.6rem;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 800;
  text-transform: uppercase;
  display: inline-block;
}

.status-badge.pending { background: #fef3c7; color: #b45309; }
.status-badge.approved { background: #d1fae5; color: #047857; }
.status-badge.rejected { background: #fee2e2; color: #b91c1c; }

.processed-date {
  font-size: 0.7rem;
  color: #64748b;
  margin-top: 3px;
}

.reason-tag {
  background: #fef2f2;
  color: #991b1b;
  font-size: 0.78rem;
  padding: 0.3rem 0.5rem;
  border-radius: 6px;
  border: 1px solid #fecaca;
  display: inline-block;
}

.action-buttons {
  display: flex;
  gap: 0.35rem;
}

.completed-tag {
  font-size: 0.78rem;
  font-weight: 700;
  color: #94a3b8;
}

/* BUTTON STYLES */
.btn {
  padding: 0.5rem 0.85rem;
  border-radius: 8px;
  border: none;
  font-weight: 700;
  font-size: 0.85rem;
  cursor: pointer;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-excel { background: #16a34a; color: white; }
.btn-excel:hover:not(:disabled) { background: #15803d; }

.btn-secondary { background: #e2e8f0; color: #334155; }
.btn-secondary:hover:not(:disabled) { background: #cbd5e1; }

.btn-success { background: #22c55e; color: white; }
.btn-success:hover:not(:disabled) { background: #16a34a; }

.btn-danger { background: #ef4444; color: white; }
.btn-danger:hover:not(:disabled) { background: #dc2626; }

.btn-warning { background: #f59e0b; color: white; }
.btn-warning:hover:not(:disabled) { background: #d97706; }

.btn-ghost { background: transparent; color: #64748b; }
.btn-ghost:hover { background: #f1f5f9; color: #0f172a; }

.btn-sm { padding: 0.4rem 0.7rem; font-size: 0.8rem; }
.btn-xs { padding: 0.25rem 0.5rem; font-size: 0.75rem; }

/* FORM CONTROLS */
.form-control {
  padding: 0.5rem 0.75rem;
  border-radius: 8px;
  border: 1px solid #cbd5e1;
  font-size: 0.88rem;
}
.form-control:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
}

/* CHECKBOX */
.checkbox-container {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  user-select: none;
}

/* MODAL */
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(15, 23, 42, 0.6);
  backdrop-filter: blur(4px);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.modal-dialog {
  background: white;
  border-radius: 16px;
  width: 100%;
  max-width: 520px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

.modal-header {
  background: #0f172a;
  color: white;
  padding: 1rem 1.25rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.1rem;
}

.close-modal-btn {
  background: transparent;
  border: none;
  color: white;
  font-size: 1.5rem;
  cursor: pointer;
}

.modal-body {
  padding: 1.25rem;
}

.modal-intro {
  font-size: 0.88rem;
  color: #475569;
  margin-bottom: 1rem;
  line-height: 1.4;
}

.field-label {
  display: block;
  font-size: 0.82rem;
  font-weight: 700;
  color: #334155;
  margin-bottom: 0.4rem;
}

.preset-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.chip-btn {
  padding: 0.3rem 0.6rem;
  border-radius: 20px;
  border: 1px solid #cbd5e1;
  background: #f8fafc;
  color: #475569;
  font-size: 0.78rem;
  font-weight: 600;
  cursor: pointer;
}

.chip-btn.active, .chip-btn:hover {
  background: #dc2626;
  color: white;
  border-color: #dc2626;
}

.modal-footer {
  padding: 1rem 1.25rem;
  background: #f8fafc;
  border-top: 1px solid #e2e8f0;
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
}

/* LOADING & EMPTY STATES */
.loading-state, .empty-state {
  text-align: center;
  padding: 3rem 1rem;
  color: #64748b;
}

.spinner {
  width: 36px;
  height: 36px;
  border: 4px solid #e2e8f0;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 1rem auto;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.empty-icon {
  font-size: 3rem;
  display: block;
  margin-bottom: 0.5rem;
}
</style>
