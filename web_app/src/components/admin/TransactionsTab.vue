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
          <button @click="showBulkMonthlyModal = true" class="btn btn-invoice-bulk" style="background: #15803d; color: white; border: none; padding: 0.55rem 1rem; border-radius: 8px; font-weight: 800; font-size: 0.85rem; cursor: pointer; display: flex; align-items: center; gap: 6px;">
            📦 Monthly Bulk 1200 Invoices
          </button>
          <button @click="openExportModal" class="btn btn-excel">
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
              <th>Bank Account Info</th>
              <th>Status</th>
              <th>Action / Invoice</th>
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

              <!-- Bank Account Info -->
              <td>
                <div v-if="tx.account_no || tx.bank_name" class="bank-info-box">
                  <div class="bank-name">🏛️ {{ tx.bank_name || 'Bank Account' }}</div>
                  <div class="bank-sub">A/C: {{ tx.account_no || 'N/A' }}</div>
                  <div class="bank-sub">IFSC: {{ tx.ifsc || 'N/A' }}</div>
                  <div v-if="tx.account_holder" class="bank-sub">Holder: {{ tx.account_holder }}</div>
                </div>
                <span v-else class="text-muted">—</span>
              </td>

              <!-- Status -->
              <td>
                <span :class="['status-badge', getStatusClass(tx.status)]">
                  {{ tx.status || 'Success' }}
                </span>
              </td>

              <!-- Invoice Action -->
              <td>
                <button 
                  v-if="isEligibleFor1200Invoice(tx)" 
                  @click="openInvoice(tx)" 
                  class="btn-invoice-action"
                  style="background: #15803d; color: white; border: none; padding: 5px 12px; border-radius: 6px; font-weight: 800; font-size: 0.75rem; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; white-space: nowrap;"
                >
                  📄 Invoice
                </button>
                <span v-else style="color: #94a3b8; font-size: 0.8rem;">—</span>
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

    <!-- CUSTOM EXCEL EXPORT OPTIONS DIALOG -->
    <div v-if="showExportModal" class="modal-backdrop" @click="closeExportModal">
      <div class="modal-dialog export-modal" @click.stop>
        <div class="modal-header">
          <h3>📊 Custom Excel Export (.xlsx)</h3>
          <button @click="closeExportModal" class="close-modal-btn">&times;</button>
        </div>

        <div class="modal-body">
          <p class="modal-intro">
            Select custom filters below to generate and download a native <strong>Microsoft Excel (.xlsx)</strong> report.
          </p>

          <!-- 1. DATE RANGE & PRESETS -->
          <div class="export-section">
            <label class="section-title">📅 Date Range</label>
            <div class="preset-chips">
              <button 
                v-for="preset in datePresets" 
                :key="preset.id"
                @click="applyDatePreset(preset.id)"
                type="button" 
                class="chip-btn"
                :class="{ active: activeDatePreset === preset.id }"
              >
                {{ preset.label }}
              </button>
            </div>
            <div class="date-row">
              <div class="date-field">
                <label>From Date:</label>
                <input type="date" v-model="exportStartDate" class="form-control" />
              </div>
              <div class="date-field">
                <label>To Date:</label>
                <input type="date" v-model="exportEndDate" class="form-control" />
              </div>
            </div>
          </div>

          <!-- 2. WALLET SELECTION -->
          <div class="export-section">
            <label class="section-title">💼 Wallet Selection</label>
            <div class="radio-group">
              <label class="radio-label">
                <input type="radio" value="ALL" v-model="exportWallet" />
                Both Wallets (Main & Fund)
              </label>
              <label class="radio-label">
                <input type="radio" value="MAIN" v-model="exportWallet" />
                Main Wallet Only
              </label>
              <label class="radio-label">
                <input type="radio" value="FUND" v-model="exportWallet" />
                Fund Wallet Only
              </label>
            </div>
          </div>

          <!-- 3. STATUS SELECTION -->
          <div class="export-section">
            <label class="section-title">🚦 Transaction Status</label>
            <div class="radio-group">
              <label class="radio-label">
                <input type="radio" value="ALL" v-model="exportStatus" />
                All Statuses
              </label>
              <label class="radio-label">
                <input type="radio" value="SUCCESS" v-model="exportStatus" />
                Success / Approved Only
              </label>
              <label class="radio-label">
                <input type="radio" value="PENDING" v-model="exportStatus" />
                Pending Only
              </label>
              <label class="radio-label">
                <input type="radio" value="FAILED" v-model="exportStatus" />
                Failed / Rejected Only
              </label>
            </div>
          </div>

          <!-- 4. CATEGORIES / TYPES -->
          <div class="export-section">
            <label class="section-title">🏷️ Transaction Category / Type</label>
            <select v-model="exportType" class="form-control">
              <option value="ALL">All Categories & Types</option>
              <option value="CASHOUT">Withdrawal / Cashout Requests</option>
              <option value="ADMIN">Admin Fund Credits & Debits</option>
              <option value="CAPTCHA">Captcha Solve Rewards</option>
              <option value="DEPOSIT">Fund Deposit / Add Money</option>
              <option value="SPONSOR">Direct Sponsor Income</option>
              <option value="SINGLE LEG">Level & Single Leg Pool</option>
              <option value="RECHARGE">Mobile & DTH Recharges</option>
            </select>
          </div>

          <!-- LIVE PREVIEW COUNT SUMMARY BOX -->
          <div class="preview-count-box">
            <div class="count-icon">📥</div>
            <div class="count-details">
              <strong>{{ exportMatchingCount }} Matching Records Found</strong>
              <p>Contains Member Names, Mobile Numbers, Bank Names, Account Numbers, IFSC, and Statuses.</p>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button @click="closeExportModal" class="btn btn-secondary">Cancel</button>
          <button 
            @click="executeExcelDownload" 
            class="btn btn-excel" 
            :disabled="exportMatchingCount === 0"
          >
            📥 Download {{ exportMatchingCount }} Records (.xlsx)
          </button>
        </div>
      </div>
    </div>

    <!-- MONTHLY BULK 1200 INVOICES DOWNLOAD DIALOG -->
    <div v-if="showBulkMonthlyModal" class="modal-backdrop" @click="showBulkMonthlyModal = false">
      <div class="modal-dialog export-modal" @click.stop style="max-width: 480px;">
        <div class="modal-header" style="background: #15803d; color: white;">
          <h3>📦 Monthly Bulk 1,200 ID Activation Invoices</h3>
          <button @click="showBulkMonthlyModal = false" class="close-modal-btn" style="color: white;">&times;</button>
        </div>
        <div class="modal-body" style="padding: 1.25rem;">
          <p style="margin: 0 0 1rem; font-size: 0.88rem; color: #475569;">
            Select a target month below to download all approved <strong>₹1,200 ID Activation Tax Invoices</strong> for that period in a consolidated Microsoft Excel (.xlsx) report.
          </p>
          <div class="export-section">
            <label class="section-title">📅 Select Month & Year</label>
            <input type="month" v-model="bulkMonthSelect" class="form-control" style="padding: 0.65rem 0.85rem; border-radius: 8px; border: 1px solid #cbd5e1; outline: none; font-size: 0.9rem; width: 100%; box-sizing: border-box;" />
          </div>
          <div style="background: #f0fdf4; border: 1px solid #bbf7d0; padding: 0.85rem; border-radius: 8px; margin-top: 1rem; font-size: 0.82rem; color: #166534;">
            <strong>ℹ️ Note:</strong> Only approved ₹1,200 ID activation payments are included. Pending/Rejected payments and non-activation transactions are automatically excluded.
          </div>
        </div>
        <div class="modal-footer">
          <button @click="showBulkMonthlyModal = false" class="btn btn-secondary">Cancel</button>
          <button @click="downloadMonthlyBulkInvoices" class="btn btn-excel" style="background: #15803d;">
            📥 Generate Bulk Invoices Excel
          </button>
        </div>
      </div>
    </div>

    <!-- INDIVIDUAL INVOICE MODAL -->
    <InvoiceModal 
      :show="showInvoiceModal"
      :transaction="selectedInvoiceTx"
      @close="closeInvoiceModal"
    />
  </div>
</template>

<script>
import * as XLSX from 'xlsx';
import InvoiceModal from './InvoiceModal.vue';

export default {
  name: 'TransactionsTab',
  components: {
    InvoiceModal
  },
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
      itemsPerPage: 50,

      // Invoice State
      showInvoiceModal: false,
      selectedInvoiceTx: null,
      showBulkMonthlyModal: false,
      bulkMonthSelect: new Date().toISOString().substring(0, 7),

      // Export Dialog State
      showExportModal: false,
      exportStartDate: '',
      exportEndDate: '',
      exportWallet: 'ALL',
      exportStatus: 'ALL',
      exportType: 'ALL',
      activeDatePreset: 'ALL',
      datePresets: [
        { id: 'ALL', label: 'All Time' },
        { id: 'TODAY', label: 'Today' },
        { id: 'WEEK', label: 'This Week' },
        { id: 'MONTH', label: 'This Month' },
        { id: '30DAYS', label: 'Last 30 Days' }
      ]
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

    exportFilteredTxns() {
      return this.txnsList.filter(tx => {
        // 1. Wallet Filter
        if (this.exportWallet !== 'ALL' && (tx.wallet_type || 'MAIN').toUpperCase() !== this.exportWallet) {
          return false;
        }

        // 2. Status Filter
        if (this.exportStatus !== 'ALL') {
          const st = (tx.status || '').toUpperCase();
          if (this.exportStatus === 'SUCCESS' && (st !== 'SUCCESS' && st !== 'APPROVED')) return false;
          if (this.exportStatus === 'PENDING' && st !== 'PENDING') return false;
          if (this.exportStatus === 'FAILED' && (st !== 'FAILED' && st !== 'REJECTED')) return false;
        }

        // 3. Category/Type Filter
        if (this.exportType !== 'ALL') {
          const t = (tx.type || '').toUpperCase();
          if (this.exportType === 'ADMIN' && !t.includes('ADMIN')) return false;
          if (this.exportType === 'CASHOUT' && (!t.includes('CASHOUT') && !t.includes('WITHDRAWAL'))) return false;
          if (this.exportType === 'CAPTCHA' && !t.includes('CAPTCHA')) return false;
          if (this.exportType === 'DEPOSIT' && (!t.includes('DEPOSIT') && !t.includes('ADD MONEY'))) return false;
          if (this.exportType === 'SPONSOR' && (!t.includes('SPONSOR') && !t.includes('DIRECT') && !t.includes('REFERRAL'))) return false;
          if (this.exportType === 'SINGLE LEG' && (!t.includes('SINGLE LEG') && !t.includes('LEVEL') && !t.includes('POOL'))) return false;
          if (this.exportType === 'RECHARGE' && !t.includes('RECHARGE')) return false;
        }

        // 4. Date Range Filter
        if (this.exportStartDate) {
          const rawDate = tx.createdAt ? new Date(tx.createdAt).toISOString().split('T')[0] : tx.date;
          if (rawDate && rawDate < this.exportStartDate) return false;
        }
        if (this.exportEndDate) {
          const rawDate = tx.createdAt ? new Date(tx.createdAt).toISOString().split('T')[0] : tx.date;
          if (rawDate && rawDate > this.exportEndDate) return false;
        }

        return true;
      });
    },

    exportMatchingCount() {
      return this.exportFilteredTxns.length;
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
    isEligibleFor1200Invoice(tx) {
      if (!tx) return false;
      const amt = parseFloat(tx.numeric_amount || tx.amount || 0);
      const statusStr = String(tx.status || '').toUpperCase();
      const isApproved = statusStr === 'SUCCESS' || statusStr === 'APPROVED';
      
      // Invoice generated ONLY for ₹1,200 ID Activation Payment that is APPROVED
      if (amt !== 1200 || !isApproved) {
        return false;
      }
      
      const typeStr = String(tx.type || '').toUpperCase();
      const walletStr = String(tx.wallet_type || '').toUpperCase();
      
      return typeStr.includes('ACTIVATION') || 
             typeStr.includes('PACKAGE') || 
             typeStr.includes('TOPUP') || 
             typeStr.includes('FUND') || 
             typeStr.includes('DEPOSIT') ||
             typeStr.includes('JOIN') ||
             walletStr === 'FUND';
    },

    openInvoice(tx) {
      this.selectedInvoiceTx = tx;
      this.showInvoiceModal = true;
    },

    closeInvoiceModal() {
      this.showInvoiceModal = false;
      this.selectedInvoiceTx = null;
    },

    downloadMonthlyBulkInvoices() {
      const targetMonth = this.bulkMonthSelect; // e.g. '2026-10'
      const eligibleTxns = this.txnsList.filter(tx => {
        if (!this.isEligibleFor1200Invoice(tx)) return false;
        if (!targetMonth) return true;
        const txDateStr = tx.createdAt ? new Date(tx.createdAt).toISOString().substring(0, 7) : String(tx.date || '').substring(0, 7);
        return txDateStr === targetMonth;
      });

      if (eligibleTxns.length === 0) {
        alert(`No approved ₹1,200 ID activation invoices found for month ${targetMonth || 'selected'}.`);
        return;
      }

      const exportRows = eligibleTxns.map((tx, idx) => ({
        'S.No': idx + 1,
        'Invoice Number': `INV-1200-${tx.id}`,
        'Invoice Date': tx.date || (tx.createdAt ? String(tx.createdAt).substring(0, 10) : 'N/A'),
        'User ID': `#${tx.user_id}`,
        'Member Name': tx.fullName || `Member #${tx.user_id}`,
        'Mobile Number': tx.mobileNumber || 'N/A',
        'Email': tx.email || '',
        'Service Description': '₹1,200 ID Package Activation & Digital Portal Membership',
        'SAC Code': '998439',
        'Base Value (₹)': 1016.95,
        'CGST 9% (₹)': 91.53,
        'SGST 9% (₹)': 91.53,
        'Total Paid (₹)': 1200.00,
        'UTR / Ref No': tx.utr || tx.utr_number || `TXN-${tx.id}`,
        'Payment Status': 'APPROVED'
      }));

      const worksheet = XLSX.utils.json_to_sheet(exportRows);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, '1200 Invoices');
      XLSX.writeFile(workbook, `SR_Digital_Seva_1200_Invoices_Bulk_${targetMonth || 'All'}.xlsx`);
      this.showBulkMonthlyModal = false;
    },

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

    openExportModal() {
      // Pre-fill export options with current active filters
      this.exportStartDate = this.startDate;
      this.exportEndDate = this.endDate;
      this.exportWallet = this.filterWallet;
      this.exportStatus = this.filterStatus;
      this.exportType = this.filterType;
      this.activeDatePreset = (this.startDate || this.endDate) ? 'CUSTOM' : 'ALL';
      this.showExportModal = true;
    },

    closeExportModal() {
      this.showExportModal = false;
    },

    applyDatePreset(presetId) {
      this.activeDatePreset = presetId;
      const today = new Date();

      if (presetId === 'ALL') {
        this.exportStartDate = '';
        this.exportEndDate = '';
      } else if (presetId === 'TODAY') {
        const dStr = today.toISOString().split('T')[0];
        this.exportStartDate = dStr;
        this.exportEndDate = dStr;
      } else if (presetId === 'WEEK') {
        const firstDay = new Date(today.setDate(today.getDate() - today.getDay()));
        this.exportStartDate = firstDay.toISOString().split('T')[0];
        this.exportEndDate = new Date().toISOString().split('T')[0];
      } else if (presetId === 'MONTH') {
        const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
        this.exportStartDate = firstDay.toISOString().split('T')[0];
        this.exportEndDate = new Date().toISOString().split('T')[0];
      } else if (presetId === '30DAYS') {
        const prior30 = new Date(new Date().setDate(new Date().getDate() - 30));
        this.exportStartDate = prior30.toISOString().split('T')[0];
        this.exportEndDate = new Date().toISOString().split('T')[0];
      }
    },

    // Native .xlsx Excel Download for FILTERED records
    executeExcelDownload() {
      if (this.exportFilteredTxns.length === 0) {
        alert('No transaction records match the chosen export options');
        return;
      }

      // Map ONLY the matching items
      const excelData = this.exportFilteredTxns.map(tx => ({
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
      this.closeExportModal();
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

.bank-info-box {
  background: #f8fafc;
  padding: 0.35rem 0.6rem;
  border-radius: 6px;
  border: 1px solid #e2e8f0;
  font-size: 0.75rem;
}

.bank-name { font-weight: 800; color: #1e293b; }
.bank-sub { color: #64748b; }

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
.btn-excel:hover:not(:disabled) { background: #15803d; }

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
  width: 100%;
}
.form-control:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
}

/* EXPORT MODAL */
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(15, 23, 42, 0.65);
  backdrop-filter: blur(4px);
  z-index: 99999;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.export-modal {
  background: white;
  border-radius: 16px;
  width: 100%;
  max-width: 580px;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  overflow: hidden;
}

.modal-header {
  background: #0f172a;
  color: white;
  padding: 1.1rem 1.4rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.15rem;
  font-weight: 800;
}

.close-modal-btn {
  background: transparent;
  border: none;
  color: white;
  font-size: 1.6rem;
  cursor: pointer;
}

.modal-body {
  padding: 1.4rem;
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
  max-height: 75vh;
  overflow-y: auto;
}

.modal-intro {
  font-size: 0.88rem;
  color: #475569;
  margin: 0;
}

.export-section {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  background: #f8fafc;
  padding: 0.85rem 1rem;
  border-radius: 10px;
  border: 1px solid #e2e8f0;
}

.section-title {
  font-size: 0.85rem;
  font-weight: 800;
  color: #0f172a;
}

.preset-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.chip-btn {
  padding: 0.35rem 0.65rem;
  border-radius: 20px;
  border: 1px solid #cbd5e1;
  background: white;
  color: #475569;
  font-size: 0.78rem;
  font-weight: 700;
  cursor: pointer;
}

.chip-btn.active, .chip-btn:hover {
  background: #2563eb;
  color: white;
  border-color: #2563eb;
}

.date-row {
  display: flex;
  gap: 0.75rem;
  margin-top: 0.25rem;
}

.date-field {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  font-size: 0.78rem;
  font-weight: 700;
  color: #475569;
}

.radio-group {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.radio-label {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.85rem;
  font-weight: 700;
  color: #334155;
  cursor: pointer;
}

.preview-count-box {
  background: #ecfdf5;
  border: 1.5px solid #6ee7b7;
  border-radius: 12px;
  padding: 0.85rem 1rem;
  display: flex;
  align-items: center;
  gap: 0.85rem;
}

.count-icon { font-size: 1.8rem; }

.count-details strong {
  display: block;
  font-size: 0.95rem;
  color: #065f46;
}

.count-details p {
  margin: 0.15rem 0 0 0;
  font-size: 0.78rem;
  color: #047857;
}

.modal-footer {
  padding: 1rem 1.4rem;
  background: #f8fafc;
  border-top: 1px solid #e2e8f0;
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
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
