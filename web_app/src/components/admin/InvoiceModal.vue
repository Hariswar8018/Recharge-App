<template>
  <div v-if="show" class="invoice-modal-backdrop" @click="$emit('close')">
    <div class="invoice-modal-container" @click.stop>
      <!-- MODAL ACTION HEADER (NON-PRINTABLE) -->
      <div class="modal-top-bar no-print">
        <div class="top-title">
          <span class="icon">📄</span>
          <h3>₹1,200 ID Activation Tax Invoice</h3>
          <span class="badge-approved">✅ Approved</span>
        </div>
        <div class="top-actions">
          <button @click="printInvoice" class="btn btn-print">
            🖨️ Print / Save PDF
          </button>
          <button @click="downloadExcel" class="btn btn-excel-sm">
            📥 Download Excel
          </button>
          <button @click="$emit('close')" class="btn-close-modal">&times;</button>
        </div>
      </div>

      <!-- INVOICE SHEET (PRINTABLE CONTAINER) -->
      <div class="printable-invoice-paper" id="invoice-paper">
        <!-- COMPANY HEADER -->
        <div class="invoice-header">
          <div class="company-logo-block">
            <h1 class="company-name">SR DIGITAL SEVA</h1>
            <p class="company-sub">Digital Multi-Services & Portal Membership</p>
            <p class="company-address">Official Admin Portal Headquarters • SAC 998439</p>
            <p class="company-contact">Support: srdigitalseva9@gmail.com | GSTIN: 27AABCS1234F1Z1</p>
          </div>
          <div class="invoice-badge-block">
            <div class="tax-invoice-tag">TAX INVOICE</div>
            <div class="inv-meta-row">
              <span class="lbl">Invoice No:</span>
              <strong class="val">INV-1200-{{ transaction ? (transaction.id || transaction.tx_id || 'REF') : '1001' }}</strong>
            </div>
            <div class="inv-meta-row">
              <span class="lbl">Invoice Date:</span>
              <span class="val">{{ formatDate(transaction ? (transaction.date || transaction.createdAt) : null) }}</span>
            </div>
            <div class="inv-meta-row">
              <span class="lbl">Payment Status:</span>
              <span class="val-success">CONFIRMED / APPROVED</span>
            </div>
          </div>
        </div>

        <div class="invoice-divider"></div>

        <!-- BILL TO USER DETAILS -->
        <div class="bill-to-section">
          <div class="bill-box">
            <h4 class="section-label">BILLED TO MEMBER:</h4>
            <h3 class="user-fullname">{{ getMemberName() }}</h3>
            <p class="user-meta"><strong>Member / User ID:</strong> #{{ getUserId() }}</p>
            <p class="user-meta"><strong>Mobile Number:</strong> {{ getMobile() }}</p>
            <p class="user-meta" v-if="getEmail()"><strong>Email:</strong> {{ getEmail() }}</p>
          </div>
          <div class="bill-box right">
            <h4 class="section-label">ACTIVATION DETAILS:</h4>
            <p class="user-meta"><strong>Plan Description:</strong> ₹1,200 ID Package Activation</p>
            <p class="user-meta"><strong>Wallet Credited:</strong> {{ (transaction ? (transaction.wallet_type || 'MAIN') : 'MAIN').toUpperCase() }}</p>
            <p class="user-meta"><strong>Ref / UTR No:</strong> {{ getUtr() }}</p>
            <p class="user-meta"><strong>Approval Status:</strong> Verified & Active</p>
          </div>
        </div>

        <!-- ITEMIZED INVOICE TABLE -->
        <div class="invoice-table-wrapper">
          <table class="invoice-table">
            <thead>
              <tr>
                <th style="width: 8%;">S.No</th>
                <th style="width: 48%;">Service / Item Description</th>
                <th style="width: 12%;">SAC Code</th>
                <th style="width: 16%; text-align: right;">Base Price</th>
                <th style="width: 16%; text-align: right;">Total Amount</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td style="text-align: center;">1</td>
                <td>
                  <strong>₹1,200 ID Package Activation & Digital Portal Membership</strong>
                  <div class="item-desc-sub">Complete digital portal access, member tools, referral tracking & cycle participation.</div>
                </td>
                <td style="text-align: center;">998439</td>
                <td style="text-align: right;">₹ 1,016.95</td>
                <td style="text-align: right; font-weight: 800;">₹ 1,016.95</td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- TAX BREAKDOWN & GRAND TOTAL -->
        <div class="invoice-summary-block">
          <div class="terms-notes">
            <h5 class="notes-heading">Terms & Audit Conditions:</h5>
            <ul class="notes-list">
              <li>1. This is an official computer-generated Tax Invoice issued only upon successful ₹1,200 ID activation.</li>
              <li>2. Generated and maintained strictly within the Admin Control Panel audit ledger.</li>
              <li>3. Non-transferable digital membership receipt.</li>
            </ul>
          </div>

          <div class="calculation-box">
            <div class="calc-row">
              <span>Taxable Base Value:</span>
              <strong>₹ 1,016.95</strong>
            </div>
            <div class="calc-row">
              <span>CGST (9%):</span>
              <strong>₹ 91.53</strong>
            </div>
            <div class="calc-row">
              <span>SGST (9%):</span>
              <strong>₹ 91.53</strong>
            </div>
            <div class="calc-divider"></div>
            <div class="calc-row total">
              <span>TOTAL PAID (INR):</span>
              <strong class="grand-total">₹ 1,200.00</strong>
            </div>
          </div>
        </div>

        <!-- STAMP & FOOTER SIGNATURE -->
        <div class="invoice-footer-signature">
          <div class="stamp-box">
            <div class="stamp-circle">
              <span>OFFICIAL ADMIN</span>
              <span>SEAL & APPROVED</span>
            </div>
          </div>
          <div class="sign-box">
            <div class="sign-line"></div>
            <p class="sign-title">Authorized Signatory</p>
            <p class="sign-sub">SR Digital Seva Admin Portal</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import * as XLSX from 'xlsx';

export default {
  name: 'InvoiceModal',
  props: {
    show: { type: Boolean, default: false },
    transaction: { type: Object, default: null },
    user: { type: Object, default: null }
  },
  methods: {
    formatDate(dStr) {
      if (!dStr) {
        const now = new Date();
        return now.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
      }
      const d = new Date(dStr);
      if (!isNaN(d.getTime())) {
        return d.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
      }
      return String(dStr).substring(0, 10);
    },
    getMemberName() {
      if (this.transaction && this.transaction.fullName) return this.transaction.fullName;
      if (this.user && this.user.fullName) return this.user.fullName;
      return 'Valued Member';
    },
    getUserId() {
      if (this.transaction && (this.transaction.user_id || this.transaction.userId)) {
        return this.transaction.user_id || this.transaction.userId;
      }
      if (this.user && (this.user.id || this.user.mobileNumber)) {
        return this.user.id || this.user.mobileNumber;
      }
      return 'N/A';
    },
    getMobile() {
      if (this.transaction && this.transaction.mobileNumber) return this.transaction.mobileNumber;
      if (this.user && this.user.mobileNumber) return this.user.mobileNumber;
      return 'N/A';
    },
    getEmail() {
      if (this.transaction && this.transaction.email) return this.transaction.email;
      if (this.user && this.user.email) return this.user.email;
      return '';
    },
    getUtr() {
      if (this.transaction && (this.transaction.utr || this.transaction.utr_number)) {
        return this.transaction.utr || this.transaction.utr_number;
      }
      if (this.transaction && this.transaction.id) {
        return 'TXN-' + this.transaction.id;
      }
      return 'APPROVED-ONLINE';
    },
    printInvoice() {
      window.print();
    },
    downloadExcel() {
      const tx = this.transaction || {};
      const row = [{
        'Invoice Number': `INV-1200-${tx.id || '1001'}`,
        'Invoice Date': this.formatDate(tx.date || tx.createdAt),
        'User ID': this.getUserId(),
        'Member Name': this.getMemberName(),
        'Mobile Number': this.getMobile(),
        'Email': this.getEmail(),
        'Service Description': '₹1,200 ID Package Activation & Digital Portal Membership',
        'SAC Code': '998439',
        'Base Amount (₹)': 1016.95,
        'CGST 9% (₹)': 91.53,
        'SGST 9% (₹)': 91.53,
        'Total Amount Paid (₹)': 1200.00,
        'UTR / Ref No': this.getUtr(),
        'Payment Status': 'APPROVED'
      }];
      const worksheet = XLSX.utils.json_to_sheet(row);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, 'Tax Invoice');
      XLSX.writeFile(workbook, `Invoice_1200_User_${this.getUserId()}_${tx.id || '1001'}.xlsx`);
    }
  }
};
</script>

<style scoped>
.invoice-modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(15, 23, 42, 0.75);
  backdrop-filter: blur(4px);
  z-index: 999999;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.invoice-modal-container {
  background: #ffffff;
  border-radius: 12px;
  max-width: 800px;
  width: 100%;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
  overflow: hidden;
}

.modal-top-bar {
  background: #0f172a;
  color: white;
  padding: 0.85rem 1.25rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.top-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.top-title h3 {
  margin: 0;
  font-size: 1rem;
  font-weight: 800;
}

.badge-approved {
  background: #15803d;
  color: white;
  font-size: 0.7rem;
  font-weight: 800;
  padding: 2px 8px;
  border-radius: 12px;
}

.top-actions {
  display: flex;
  align-items: center;
  gap: 0.6rem;
}

.btn-print {
  background: #2563eb;
  color: white;
  border: none;
  padding: 0.45rem 0.85rem;
  border-radius: 6px;
  font-size: 0.82rem;
  font-weight: 700;
  cursor: pointer;
}

.btn-excel-sm {
  background: #16a34a;
  color: white;
  border: none;
  padding: 0.45rem 0.85rem;
  border-radius: 6px;
  font-size: 0.82rem;
  font-weight: 700;
  cursor: pointer;
}

.btn-close-modal {
  background: transparent;
  border: none;
  color: white;
  font-size: 1.4rem;
  cursor: pointer;
}

.printable-invoice-paper {
  padding: 2rem;
  overflow-y: auto;
  font-family: 'Inter', system-ui, sans-serif;
  color: #1e293b;
  background: #ffffff;
}

.invoice-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.company-name {
  font-size: 1.5rem;
  font-weight: 900;
  color: #1e3a8a;
  margin: 0 0 4px 0;
  letter-spacing: 0.5px;
}

.company-sub {
  font-size: 0.85rem;
  font-weight: 700;
  color: #475569;
  margin: 0 0 2px 0;
}

.company-address, .company-contact {
  font-size: 0.75rem;
  color: #64748b;
  margin: 0;
}

.invoice-badge-block {
  text-align: right;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.tax-invoice-tag {
  background: #1e3a8a;
  color: white;
  font-weight: 900;
  font-size: 0.95rem;
  padding: 4px 14px;
  border-radius: 4px;
  letter-spacing: 1px;
  margin-bottom: 0.5rem;
}

.inv-meta-row {
  font-size: 0.8rem;
  margin-bottom: 2px;
}

.inv-meta-row .lbl {
  color: #64748b;
  margin-right: 4px;
}

.val-success {
  color: #16a34a;
  font-weight: 800;
}

.invoice-divider {
  height: 2px;
  background: #e2e8f0;
  margin: 1.25rem 0;
}

.bill-to-section {
  display: flex;
  justify-content: space-between;
  gap: 1.5rem;
  background: #f8fafc;
  padding: 1rem 1.25rem;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  margin-bottom: 1.25rem;
}

.section-label {
  font-size: 0.7rem;
  font-weight: 800;
  color: #64748b;
  margin: 0 0 6px 0;
  letter-spacing: 0.5px;
}

.user-fullname {
  font-size: 1.1rem;
  font-weight: 800;
  color: #0f172a;
  margin: 0 0 6px 0;
}

.user-meta {
  font-size: 0.82rem;
  color: #334155;
  margin: 2px 0;
}

.invoice-table-wrapper {
  margin-bottom: 1.25rem;
}

.invoice-table {
  width: 100%;
  border-collapse: collapse;
  border: 1px solid #cbd5e1;
}

.invoice-table th {
  background: #f1f5f9;
  color: #334155;
  font-size: 0.8rem;
  font-weight: 800;
  padding: 8px 10px;
  border: 1px solid #cbd5e1;
}

.invoice-table td {
  padding: 10px;
  font-size: 0.85rem;
  border: 1px solid #e2e8f0;
}

.item-desc-sub {
  font-size: 0.75rem;
  color: #64748b;
  margin-top: 3px;
}

.invoice-summary-block {
  display: flex;
  justify-content: space-between;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.terms-notes {
  flex: 1;
  background: #fafafa;
  padding: 0.85rem;
  border-radius: 8px;
  border: 1px solid #f1f5f9;
}

.notes-heading {
  font-size: 0.75rem;
  font-weight: 800;
  color: #475569;
  margin: 0 0 4px 0;
}

.notes-list {
  margin: 0;
  padding-left: 1rem;
  font-size: 0.72rem;
  color: #64748b;
}

.notes-list li {
  margin-bottom: 2px;
}

.calculation-box {
  width: 260px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 0.85rem 1rem;
}

.calc-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.82rem;
  margin-bottom: 6px;
  color: #475569;
}

.calc-divider {
  height: 1px;
  background: #cbd5e1;
  margin: 8px 0;
}

.calc-row.total {
  font-size: 0.95rem;
  font-weight: 900;
  color: #0f172a;
}

.grand-total {
  color: #16a34a;
  font-size: 1.1rem;
}

.invoice-footer-signature {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid #e2e8f0;
}

.stamp-circle {
  border: 2px dashed #16a34a;
  color: #16a34a;
  padding: 6px 14px;
  border-radius: 6px;
  font-weight: 900;
  font-size: 0.68rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  letter-spacing: 0.5px;
}

.sign-box {
  text-align: center;
}

.sign-line {
  width: 140px;
  height: 1px;
  background: #94a3b8;
  margin: 0 auto 4px auto;
}

.sign-title {
  font-weight: 800;
  font-size: 0.8rem;
  color: #0f172a;
  margin: 0;
}

.sign-sub {
  font-size: 0.7rem;
  color: #64748b;
  margin: 0;
}

/* PRINT MEDIA STYLES */
@media print {
  body * {
    visibility: hidden;
  }
  .no-print {
    display: none !important;
  }
  #invoice-paper, #invoice-paper * {
    visibility: visible;
  }
  #invoice-paper {
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    padding: 0;
  }
}
</style>
