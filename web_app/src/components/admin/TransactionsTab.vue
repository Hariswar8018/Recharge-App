<template>
  <div class="transactions-pane">
    <!-- TOP SUMMARY STATS GRID -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon">📑</div>
        <div class="stat-info">
          <span class="label">Total Records</span>
          <h3 class="value">{{ totalRecords }}</h3>
          <span class="sub-label">General Ledger</span>
        </div>
      </div>

      <div class="stat-card volume">
        <div class="stat-icon">💰</div>
        <div class="stat-info">
          <span class="label">Total Ledger Volume</span>
          <h3 class="value">₹{{ formatAmount(totalVolume) }}</h3>
          <span class="sub-label">Turnover</span>
        </div>
      </div>

      <div class="stat-card credit">
        <div class="stat-icon">📈</div>
        <div class="stat-info">
          <span class="label">Total Credits</span>
          <h3 class="value">₹{{ formatAmount(totalCredits) }}</h3>
          <span class="sub-label">Money In / Rewards</span>
        </div>
      </div>

      <div class="stat-card debit">
        <div class="stat-icon">📉</div>
        <div class="stat-info">
          <span class="label">Total Debits</span>
          <h3 class="value">₹{{ formatAmount(totalDebits) }}</h3>
          <span class="sub-label">Cashouts / Deductions</span>
        </div>
      </div>
    </div>

    <!-- MAIN PANEL CARD -->
    <div class="card panel-card">
      <div class="panel-header">
        <div class="header-title">
          <h2>📋 Platform-Wide Transactions & General Ledger</h2>
          <p>Complete audit log of user recharges, wallet loads, referrals, single-leg pool payouts, and admin fund adjustments.</p>
        </div>
        <div class="header-actions">
          <button @click="downloadExcel" class="btn btn-excel">
            📥 Download Excel Report
          </button>
          <button @click="fetchTransactions" class="btn btn-secondary btn-icon" title="Refresh transactions">
            🔄 Refresh
          </button>
        </div>
      </div>

      <!-- FILTER & SEARCH TOOLBAR -->
      <div class="toolbar">
        <!-- WALLET TABS & SEARCH -->
        <div class="toolbar-top">
          <div class="wallet-tabs">
            <button 
              @click="filterWallet = 'ALL'" 
              class="tab-btn" 
              :class="{ active: filterWallet === 'ALL' }"
            >
              All Wallets
            </button>
            <button 
              @click="filterWallet = 'MAIN'" 
              class="tab-btn main-wallet" 
              :class="{ active: filterWallet === 'MAIN' }"
            >
              Main Wallet
            </button>
            <button 
              @click="filterWallet = 'FUND'" 
              class="tab-btn fund-wallet" 
              :class="{ active: filterWallet === 'FUND' }"
            >
              Fund Wallet
            </button>
          </div>

          <div class="search-box">
            <span class="search-icon">🔍</span>
            <input 
              type="text" 
              v-model="searchQuery" 
              placeholder="Search User ID, Name, Mobile, Email, Txn ID, Type..." 
              class="form-control"
            />
            <button v-if="searchQuery" @click="searchQuery = ''" class="clear-btn">&times;</button>
          </div>
        </div>

        <!-- DROPDOWN & DATE FILTERS -->
        <div class="filter-controls">
          <div class="filter-item">
            <label>Status:</label>
            <select v-model="filterStatus" class="form-control select-input">
              <option value="ALL">All Statuses</option>
              <option value="SUCCESS">Success / Approved</option>
              <option value="PENDING">Pending</option>
              <option value="FAILED">Failed / Rejected</option>
            </select>
          </div>

          <div class="filter-item">
            <label>Category / Type:</label>
            <select v-model="filterType" class="form-control select-input">
              <option value="ALL">All Categories</option>
              <option value="ADMIN">Admin Fund Credit / Debit</option>
              <option value="CASHOUT">Withdrawal / Cashout</option>
              <option value="CAPTCHA">Captcha Solve Reward</option>
              <option value="DEPOSIT">Fund Deposit / Add Money</option>
              <option value="SPONSOR">Direct Sponsor Income</option>
              <option value="SINGLE LEG">Level / Single Leg Pool</option>
              <option value="RECHARGE">Mobile & DTH Recharge</option>
            </select>
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

          <div class="per-page-selector">
            <label>Rows:</label>
            <select v-model="itemsPerPage" class="form-control select-sm">
              <option :value="25">25</option>
              <option :value="50">50</option>
              <option :value="100">100</option>
              <option :value="200">200</option>
            </select>
          </div>
        </div>
      </div>

      <!-- DATA TABLE -->
      <div class="table-responsive">
        <div v-if="loading" class="loading-state">
          <div class="spinner"></div>
          <p>Loading transactions ledger...</p>
        </div>

        <div v-else-if="paginatedTxns.length === 0" class="empty-state">
          <span class="empty-icon">📂</span>
          <h3>No Transactions Found</h3>
          <p>No transactions match your current search query or filter criteria.</p>
        </div>

        <table v-else class="data-table">
          <thead>
            <tr>
              <th>ID & Date</th>
              <th>Member Information</th>
              <th>Wallet</th>
              <th>Type / Description</th>
              <th>Amount</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="tx in paginatedTxns" :key="tx.id">
              <!-- ID & Date -->
              <td>
                <div class="id-badge">#{{ tx.id }}</div>
                <div class="date-text">{{ formatDate(tx.date || tx.createdAt) }}</div>
              </td>

              <!-- Member Information -->
              <td>
                <div class="user-name">{{ tx.fullName || 'Member #' + tx.user_id }}</div>
                <div class="sub-text">User ID: <strong>#{{ tx.user_id }}</strong></div>
                <div class="sub-text">📞 {{ tx.mobileNumber || 'N/A' }}</div>
                <div v-if="tx.email" class="sub-text text-muted">✉️ {{ tx.email }}</div>
              </td>

              <!-- Wallet Type -->
              <td>
                <span :class="['wallet-tag', (tx.wallet_type || 'MAIN').toLowerCase()]">
                  {{ (tx.wallet_type || 'MAIN').toUpperCase() }}
                </span>
              </td>

              <!-- Type / Description -->
              <td>
                <div class="type-desc">{{ tx.type || 'Transaction' }}</div>
              </td>

              <!-- Amount -->
              <td>
                <div :class="['amount-tag', tx.is_debit ? 'debit' : 'credit']">
                  {{ tx.is_debit ? '-' : '+' }} ₹{{ formatAmount(tx.numeric_amount || tx.amount) }}
                </div>
              </td>

              <!-- Status -->
              <td>
                <span :class="['status-badge', getStatusClass(tx.status)]">
                  {{ tx.status || 'Success' }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- PAGINATION BAR -->
      <div class="pagination-bar">
        <div class="page-info">
          Showing <strong>{{ pageStart }}</strong> to <strong>{{ pageEnd }}</strong> of <strong>{{ filteredTxns.length }}</strong> filtered records
        </div>
        <div class="pagination-controls">
          <button 
            @click="currentPage--" 
            :disabled="currentPage === 1"
            class="btn btn-secondary btn-sm"
          >
            ← Previous
          </button>
          <span class="page-indicator">Page <strong>{{ currentPage }}</strong> of {{ totalPages || 1 }}</span>
          <button 
            @click="currentPage++" 
            :disabled="currentPage >= totalPages"
            class="btn btn-primary btn-sm"
          >
            Next →
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import * as XLSX from 'xlsx';

export default {
  name: 'TransactionsTab',
  data() {
    return {
      txnsList: [],
      loading: true,
      searchQuery: '',
      filterWallet: 'ALL',
      filterStatus: 'ALL',
      filterType: 'ALL',
      startDate: '',
      endDate: '',
      currentPage: 1,
      itemsPerPage: 50
    };
  },
  computed: {
    filteredTxns() {
      return this.txnsList.filter(tx => {
        // 1. Wallet Filter
        if (this.filterWallet !== 'ALL' && (tx.wallet_type || 'MAIN').toUpperCase() !== this.filterWallet) {
          return false;
        }

        // 2. Status Filter
        if (this.filterStatus !== 'ALL') {
          const st = (tx.status || '').toUpperCase();
          if (this.filterStatus === 'SUCCESS' && (st !== 'SUCCESS' && st !== 'APPROVED')) return false;
          if (this.filterStatus === 'PENDING' && st !== 'PENDING') return false;
          if (this.filterStatus === 'FAILED' && (st !== 'FAILED' && st !== 'REJECTED')) return false;
        }

        // 3. Category/Type Filter
        if (this.filterType !== 'ALL') {
          const t = (tx.type || '').toUpperCase();
          if (this.filterType === 'ADMIN' && !t.includes('ADMIN')) return false;
          if (this.filterType === 'CASHOUT' && (!t.includes('CASHOUT') && !t.includes('WITHDRAWAL'))) return false;
          if (this.filterType === 'CAPTCHA' && !t.includes('CAPTCHA')) return false;
          if (this.filterType === 'DEPOSIT' && (!t.includes('DEPOSIT') && !t.includes('ADD MONEY'))) return false;
          if (this.filterType === 'SPONSOR' && (!t.includes('SPONSOR') && !t.includes('DIRECT') && !t.includes('REFERRAL'))) return false;
          if (this.filterType === 'SINGLE LEG' && (!t.includes('SINGLE LEG') && !t.includes('LEVEL') && !t.includes('POOL'))) return false;
          if (this.filterType === 'RECHARGE' && !t.includes('RECHARGE')) return false;
        }

        // 4. Search Filter
        if (this.searchQuery.trim() !== '') {
          const q = this.searchQuery.toLowerCase().trim();
          const matchUser = (tx.fullName || '').toLowerCase().includes(q) ||
                            (tx.mobileNumber || '').toLowerCase().includes(q) ||
                            (tx.email || '').toLowerCase().includes(q) ||
                            String(tx.user_id).includes(q);
          const matchBank = (tx.account_no || '').toLowerCase().includes(q) ||
                            (tx.ifsc || '').toLowerCase().includes(q) ||
                            (tx.account_holder || '').toLowerCase().includes(q) ||
                            (tx.bank_name || '').toLowerCase().includes(q);
          const matchType = (tx.type || '').toLowerCase().includes(q);
          const matchAmount = String(tx.amount || '').includes(q);
          const matchId = String(tx.id).includes(q);

          if (!matchUser && !matchBank && !matchType && !matchAmount && !matchId) return false;
        }

        // 5. Date Range Filter
        if (this.startDate) {
          const rawDate = tx.createdAt ? new Date(tx.createdAt).toISOString().split('T')[0] : tx.date;
          if (rawDate && rawDate < this.startDate) return false;
        }
        if (this.endDate) {
          const rawDate = tx.createdAt ? new Date(tx.createdAt).toISOString().split('T')[0] : tx.date;
          if (rawDate && rawDate > this.endDate) return false;
        }

        return true;
      });
    },

    totalRecords() {
      return this.filteredTxns.length;
    },

    totalVolume() {
      return this.filteredTxns.reduce((sum, tx) => sum + (parseFloat(tx.numeric_amount || tx.amount) || 0), 0);
    },

    totalCredits() {
      return this.filteredTxns
        .filter(tx => !tx.is_debit)
        .reduce((sum, tx) => sum + (parseFloat(tx.numeric_amount || tx.amount) || 0), 0);
    },

    totalDebits() {
      return this.filteredTxns
        .filter(tx => tx.is_debit)
        .reduce((sum, tx) => sum + (parseFloat(tx.numeric_amount || tx.amount) || 0), 0);
    },

    totalPages() {
      return Math.ceil(this.filteredTxns.length / this.itemsPerPage) || 1;
    },

    paginatedTxns() {
      const start = (this.currentPage - 1) * this.itemsPerPage;
      return this.filteredTxns.slice(start, start + this.itemsPerPage);
    },

    pageStart() {
      if (this.filteredTxns.length === 0) return 0;
      return (this.currentPage - 1) * this.itemsPerPage + 1;
    },

    pageEnd() {
      const end = this.currentPage * this.itemsPerPage;
      return end > this.filteredTxns.length ? this.filteredTxns.length : end;
    }
  },
  watch: {
    searchQuery() { this.currentPage = 1; },
    filterWallet() { this.currentPage = 1; },
    filterStatus() { this.currentPage = 1; },
    filterType() { this.currentPage = 1; },
    startDate() { this.currentPage = 1; },
    endDate() { this.currentPage = 1; },
    itemsPerPage() { this.currentPage = 1; }
  },
  mounted() {
    this.fetchTransactions();
  },
  methods: {
    async fetchTransactions() {
      this.loading = true;
      try {
        const token = localStorage.getItem('adminToken');
        const res = await fetch('https://api.srdigitalseva.com/api/admin/transactions?limit=2000', {
          headers: {
            'x-app-token': 'srdigitalseva-secret-app-token-2026',
            'Authorization': `Bearer ${token}`
          }
        });
        if (res.ok) {
          const data = await res.json();
          this.txnsList = data || [];
        } else {
          console.error('Failed to load transactions ledger:', await res.text());
        }
      } catch (err) {
        console.error('Error fetching transactions:', err);
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

    getStatusClass(st) {
      const s = (st || '').toUpperCase();
      if (s === 'SUCCESS' || s === 'APPROVED') return 'success';
      if (s === 'PENDING') return 'pending';
      return 'failed';
    },

    clearDates() {
      this.startDate = '';
      this.endDate = '';
    },

    // Native .xlsx Excel Download for FILTERED records only, including Bank details
    downloadExcel() {
      if (this.filteredTxns.length === 0) {
        alert('No transaction records found for the current filters');
        return;
      }

      // Map ONLY the filtered items
      const excelData = this.filteredTxns.map(tx => ({
        'Transaction ID': `TXN-${tx.id}`,
        'Date & Time': this.formatDate(tx.date || tx.createdAt),
        'User ID': `#${tx.user_id}`,
        'Member Name': tx.fullName || '',
        'Mobile Number': tx.mobileNumber || '',
        'Email': tx.email || '',
        'Wallet Type': (tx.wallet_type || 'MAIN').toUpperCase(),
        'Type / Description': tx.type || 'Transaction',
        'Amount (INR)': parseFloat(tx.numeric_amount || tx.amount || 0),
        'Direction': tx.is_debit ? 'DEBIT (-)' : 'CREDIT (+)',
        'Bank Name': tx.bank_name || 'N/A',
        'Account Holder Name': tx.account_holder || 'N/A',
        'Account Number': tx.account_no ? `'${tx.account_no}` : 'N/A',
        'IFSC Code': tx.ifsc || 'N/A',
        'Branch': tx.branch || 'N/A',
        'Account Type': tx.account_type || 'Savings',
        'Status': tx.status || 'Success'
      }));

      const worksheet = XLSX.utils.json_to_sheet(excelData);
      
      // Auto-size column widths
      const colWidths = [
        { wch: 14 }, // Txn ID
        { wch: 22 }, // Date
        { wch: 10 }, // User ID
        { wch: 22 }, // Name
        { wch: 16 }, // Mobile
        { wch: 26 }, // Email
        { wch: 14 }, // Wallet
        { wch: 30 }, // Type
        { wch: 14 }, // Amount
        { wch: 14 }, // Direction
        { wch: 22 }, // Bank Name
        { wch: 22 }, // Account Holder Name
        { wch: 20 }, // Account Number
        { wch: 14 }, // IFSC
        { wch: 18 }, // Branch
        { wch: 14 }, // Account Type
        { wch: 12 }  // Status
      ];
      worksheet['!cols'] = colWidths;

      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, 'Filtered Ledger');

      const dateStr = new Date().toISOString().slice(0, 10);
      XLSX.writeFile(workbook, `Platform_Transactions_Filtered_${dateStr}.xlsx`);
    }
  }
};
</script>

<style scoped>
.transactions-pane {
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
  box-shadow: 0 2px 4px rgba(0,0,0,0.03);
}

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
  font-size: 1.4rem;
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

.toolbar-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}

.wallet-tabs {
  display: flex;
  gap: 0.5rem;
}

.tab-btn {
  padding: 0.5rem 1rem;
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
.tab-btn.main-wallet.active { background: #2563eb; border-color: #2563eb; }
.tab-btn.fund-wallet.active { background: #9333ea; border-color: #9333ea; }

.search-box {
  position: relative;
  flex: 1;
  max-width: 400px;
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

.filter-controls {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  align-items: center;
  background: #f8fafc;
  padding: 0.85rem;
  border-radius: 10px;
  border: 1px solid #e2e8f0;
}

.filter-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.82rem;
  font-weight: 700;
  color: #475569;
}

.select-input {
  padding: 0.4rem 0.6rem;
  font-size: 0.82rem;
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

.per-page-selector {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.82rem;
  font-weight: 700;
  color: #475569;
  margin-left: auto;
}

.select-sm {
  padding: 0.35rem 0.5rem;
  font-size: 0.82rem;
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
  vertical-align: middle;
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

.wallet-tag {
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 800;
  display: inline-block;
}

.wallet-tag.main {
  background: #eff6ff;
  color: #2563eb;
}

.wallet-tag.fund {
  background: #faf5ff;
  color: #9333ea;
}

.type-desc {
  font-weight: 700;
  color: #1e293b;
}

.amount-tag {
  font-size: 0.95rem;
  font-weight: 800;
}

.amount-tag.credit { color: #16a34a; }
.amount-tag.debit { color: #dc2626; }

.status-badge {
  padding: 0.25rem 0.6rem;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 800;
  text-transform: uppercase;
  display: inline-block;
}

.status-badge.success { background: #d1fae5; color: #047857; }
.status-badge.pending { background: #fef3c7; color: #b45309; }
.status-badge.failed { background: #fee2e2; color: #b91c1c; }

/* BUTTONS */
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

.btn-excel { background: #16a34a; color: white; }
.btn-excel:hover { background: #15803d; }

.btn-secondary { background: #e2e8f0; color: #334155; }
.btn-secondary:hover { background: #cbd5e1; }

.btn-primary { background: #2563eb; color: white; }
.btn-primary:hover:not(:disabled) { background: #1d4ed8; }

.btn-ghost { background: transparent; color: #64748b; }
.btn-ghost:hover { background: #f1f5f9; color: #0f172a; }

.btn-sm { padding: 0.4rem 0.7rem; font-size: 0.8rem; }
.btn:disabled { opacity: 0.5; cursor: not-allowed; }

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

/* PAGINATION BAR */
.pagination-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1.25rem;
  padding-top: 1rem;
  border-top: 1px solid #e2e8f0;
  flex-wrap: wrap;
  gap: 1rem;
}

.page-info {
  font-size: 0.88rem;
  color: #64748b;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.page-indicator {
  font-size: 0.88rem;
  color: #475569;
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
