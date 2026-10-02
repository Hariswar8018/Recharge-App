<template>
  <div class="requests-pane">
    <div class="table-card">
      <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem; margin-bottom: 1rem;">
        <div>
          <h3 style="margin: 0; font-size: 1.2rem; font-weight: 800; color: #0f172a;">💳 Manage User Add Money / Fund Deposit Requests</h3>
          <span class="count-pill" style="background: #f59e0b; color: white; padding: 2px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: 800;">{{ pendingRequestsCount }} Pending Requests</span>
        </div>
        
        <!-- BULK MONTHLY INVOICE DOWNLOAD BUTTON -->
        <button 
          @click="showBulkModal = true" 
          class="btn-bulk-zip" 
          style="background: #0047BA; color: white; border: none; padding: 0.6rem 1.1rem; border-radius: 8px; font-weight: 800; font-size: 0.88rem; cursor: pointer; display: flex; align-items: center; gap: 6px; box-shadow: 0 4px 6px -1px rgba(0, 71, 186, 0.25);"
        >
          📦 Bulk Download Monthly Invoices (ZIP)
        </button>
      </div>

      <!-- STATUS FILTER TAB PILLS -->
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
          <label style="font-size: 0.78rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">Search Mobile Number / Member / UTR</label>
          <input 
            type="text" 
            v-model="reqSearchQueryLocal" 
            @input="$emit('update:reqSearchQuery', reqSearchQueryLocal)"
            placeholder="Enter Mobile Number, Name, UTR..." 
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
              <th>Invoice (Approved Only)</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="filteredRequests.length === 0">
              <td colspan="11" style="text-align: center; padding: 2rem; color: #64748b; font-weight: 600;">
                No fund requests found matching filters.
              </td>
            </tr>
            <tr v-for="req in filteredRequests" :key="req.id">
              <td>#{{ req.id }}</td>
              <td style="white-space: nowrap;">{{ req.createdAt ? String(req.createdAt).substring(0,16) : 'N/A' }}</td>
              <td class="font-bold">{{ req.fullName || 'User #' + req.user_id }}</td>
              <td class="font-mono">{{ req.mobileNumber || 'N/A' }}</td>
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
              
              <!-- INVOICE COLUMN: ONLY FOR APPROVED REQUESTS -->
              <td>
                <button 
                  v-if="req.status === 'APPROVED'" 
                  @click="openInvoiceModal(req)" 
                  class="btn-inv-download"
                  style="background: #0047BA; color: white; border: none; padding: 4px 10px; border-radius: 6px; font-weight: 800; font-size: 0.78rem; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;"
                >
                  📄 Download PDF
                </button>
                <span v-else class="text-muted" style="font-size: 0.78rem; color: #94a3b8; font-style: italic;">
                  No Invoice (Unapproved)
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

    <!-- BULK MONTHLY DOWNLOAD MODAL -->
    <div v-if="showBulkModal" class="modal-backdrop" @click="showBulkModal = false">
      <div class="modal-dialog" @click.stop style="max-width: 480px; background: white; border-radius: 12px; overflow: hidden;">
        <div class="modal-header" style="background: #0047BA; color: white; padding: 1rem; display: flex; justify-content: space-between; align-items: center;">
          <h3 style="margin: 0; font-size: 1.05rem; font-weight: 800;">📦 Bulk Download Monthly PDF Invoices (ZIP)</h3>
          <button @click="showBulkModal = false" style="background: none; border: none; color: white; font-size: 1.4rem; cursor: pointer;">&times;</button>
        </div>
        <div class="modal-body" style="padding: 1.25rem;">
          <p style="margin: 0 0 1rem; font-size: 0.85rem; color: #475569; line-height: 1.4;">
            Select a target month below. The system will generate <strong>individual PDF invoices</strong> for every Approved Fund Request in that month and package them into a single <strong>ZIP file</strong>.
          </p>
          <div style="margin-bottom: 1rem;">
            <label style="font-size: 0.8rem; font-weight: 800; color: #0047BA; display: block; margin-bottom: 6px;">📅 Select Target Month</label>
            <input type="month" v-model="bulkMonth" style="width: 100%; padding: 0.65rem 0.85rem; border-radius: 8px; border: 1px solid #cbd5e1; font-size: 0.95rem; box-sizing: border-box;" />
          </div>

          <!-- PROGRESS BAR WHEN GENERATING -->
          <div v-if="isGeneratingBulk" style="margin-top: 1rem; background: #e0f2fe; border: 1px solid #7dd3fc; padding: 1rem; border-radius: 8px;">
            <div style="font-weight: 800; font-size: 0.85rem; color: #0369a1; margin-bottom: 6px;">
              ⏳ Generating PDF Invoices... ({{ bulkProgress }} / {{ bulkTotal }})
            </div>
            <div style="background: #bae6fd; height: 10px; border-radius: 5px; overflow: hidden;">
              <div :style="{ width: (bulkTotal ? (bulkProgress / bulkTotal * 100) : 0) + '%' }" style="background: #0284c7; height: 100%; transition: width 0.2s;"></div>
            </div>
          </div>

          <div style="background: #f8fafc; border: 1px solid #e2e8f0; padding: 0.75rem; border-radius: 8px; margin-top: 1rem; font-size: 0.8rem; color: #64748b;">
            <strong>ℹ️ Note:</strong> Invoices are strictly generated <strong>ONLY for Approved Fund Requests</strong>. Pending and Rejected requests are automatically excluded. Each user gets their own separate PDF file inside the ZIP.
          </div>
        </div>

        <div class="modal-footer" style="padding: 1rem; background: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 0.75rem;">
          <button @click="showBulkModal = false" :disabled="isGeneratingBulk" style="padding: 0.5rem 1rem; border: 1px solid #cbd5e1; background: white; border-radius: 6px; cursor: pointer; font-weight: 700;">Cancel</button>
          <button @click="generateBulkZip" :disabled="isGeneratingBulk" style="padding: 0.5rem 1.25rem; background: #0047BA; color: white; border: none; border-radius: 6px; font-weight: 800; cursor: pointer;">
            <span v-if="isGeneratingBulk">Processing...</span>
            <span v-else>⚡ Download ZIP</span>
          </button>
        </div>
      </div>
    </div>

    <!-- INDIVIDUAL INVOICE MODAL -->
    <InvoiceModal 
      :show="showInvoiceModal"
      :transaction="selectedReq"
      @close="showInvoiceModal = false"
    />

    <!-- OFFSCREEN ELEMENT FOR BULK PDF RENDERING -->
    <div id="offscreen-invoice-container" style="position: absolute; left: -9999px; top: -9999px; width: 800px;">
      <div v-if="currentBulkReq" class="printable-invoice-paper" ref="bulkPaper">
        <!-- TOP HEADER: LOGO LEFT & CONTACT RIGHT -->
        <div class="header-section">
          <div class="brand-logo-container">
            <img :src="receiptLogo" alt="SR Digital Seva Kendram" style="height: 75px; width: auto; object-fit: contain;" />
          </div>
          <div class="contact-info-block">
            <div class="contact-row"><span class="contact-text font-bold">9988494936</span></div>
            <div class="contact-row"><span class="contact-text">info@srdigitalseva.com</span></div>
            <div class="contact-row"><span class="contact-text">H.No: 33-5-118, Warangal, Telangana - 506005</span></div>
          </div>
        </div>
        <div class="service-invoice-banner">SERVICE INVOICE</div>
        <div class="details-grid">
          <div class="details-box">
            <div class="box-header">CUSTOMER DETAILS</div>
            <div class="box-body">
              <div class="info-row"><span class="label">Customer Name</span><span class="separator">:</span><strong class="value">{{ currentBulkReq.fullName || 'Member' }}</strong></div>
              <div class="info-row"><span class="label">Mobile Number</span><span class="separator">:</span><span class="value">{{ currentBulkReq.mobileNumber || 'N/A' }}</span></div>
              <div class="info-row"><span class="label">Email ID</span><span class="separator">:</span><span class="value">{{ currentBulkReq.email || 'N/A' }}</span></div>
              <div class="info-row"><span class="label">Address</span><span class="separator">:</span><span class="value">{{ currentBulkReq.address || 'Warangal, Telangana' }}</span></div>
            </div>
          </div>
          <div class="details-box">
            <div class="box-header">INVOICE DETAILS</div>
            <div class="box-body">
              <div class="info-row"><span class="label">Invoice No.</span><span class="separator">:</span><span class="value font-mono">SR/2026-27/{{ String(currentBulkReq.id).padStart(4,'0') }}</span></div>
              <div class="info-row"><span class="label">Invoice Date</span><span class="separator">:</span><span class="value">{{ currentBulkReq.createdAt ? String(currentBulkReq.createdAt).substring(0,10) : '2026-05-26' }}</span></div>
              <div class="info-row"><span class="label">Payment Mode</span><span class="separator">:</span><span class="value">{{ (currentBulkReq.payment_method || 'UPI').toUpperCase() }}</span></div>
              <div class="info-row"><span class="label">UTR Number</span><span class="separator">:</span><span class="value font-mono">{{ currentBulkReq.utr_number || currentBulkReq.utr || '412345678901' }}</span></div>
              <div class="info-row"><span class="label">Status</span><span class="separator">:</span><span class="badge-paid">PAID</span></div>
            </div>
          </div>
        </div>
        <div class="invoice-table-block">
          <table class="items-table">
            <thead>
              <tr><th>S.No.</th><th>DESCRIPTION OF SERVICE</th><th>QTY.</th><th style="text-align: right;">UNIT PRICE (₹)</th><th style="text-align: right;">AMOUNT (₹)</th></tr>
            </thead>
            <tbody>
              <tr>
                <td>1</td>
                <td><strong>Online Application & Processing Service</strong><div>(Application form filling, document verification, online submission and follow-up support)</div></td>
                <td>1</td>
                <td style="text-align: right;">{{ parseFloat(currentBulkReq.amount || 1200).toFixed(2) }}</td>
                <td style="text-align: right;">{{ parseFloat(currentBulkReq.amount || 1200).toFixed(2) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import JSZip from 'jszip';
import html2pdf from 'html2pdf.js';
import receiptLogo from '../../assets/sr_receipt_logo_index_logo.png';
import signatureImg from '../../assets/signature.png';
import InvoiceModal from './InvoiceModal.vue';

export default {
  name: 'FundRequestsTab',
  components: { InvoiceModal },
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
      receiptLogo,
      signatureImg,
      reqSearchQueryLocal: this.reqSearchQuery,
      reqFilterModeLocal: this.reqFilterMode,
      reqPaymentModeFilterLocal: this.reqPaymentModeFilter,
      reqAmountFilterLocal: this.reqAmountFilter,
      showInvoiceModal: false,
      selectedReq: null,
      showBulkModal: false,
      bulkMonth: new Date().toISOString().substring(0, 7),
      isGeneratingBulk: false,
      bulkProgress: 0,
      bulkTotal: 0,
      currentBulkReq: null
    };
  },
  watch: {
    reqSearchQuery(newVal) { this.reqSearchQueryLocal = newVal; },
    reqFilterMode(newVal) { this.reqFilterModeLocal = newVal; },
    reqPaymentModeFilter(newVal) { this.reqPaymentModeFilterLocal = newVal; },
    reqAmountFilter(newVal) { this.reqAmountFilterLocal = newVal; }
  },
  methods: {
    openInvoiceModal(req) {
      if (req.status !== 'APPROVED') {
        alert('Invoices are generated only for Approved Fund Requests.');
        return;
      }
      this.selectedReq = req;
      this.showInvoiceModal = true;
    },
    async generateBulkZip() {
      if (!this.bulkMonth) {
        alert('Please select a target month.');
        return;
      }

      // Filter APPROVED requests for the selected month
      const eligible = this.fundRequests.filter(req => {
        if (req.status !== 'APPROVED') return false;
        const dateStr = req.createdAt ? new Date(req.createdAt).toISOString().substring(0, 7) : String(req.date || '').substring(0, 7);
        return dateStr === this.bulkMonth;
      });

      if (eligible.length === 0) {
        alert(`No approved fund requests found for month ${this.bulkMonth}.`);
        return;
      }

      this.isGeneratingBulk = true;
      this.bulkTotal = eligible.length;
      this.bulkProgress = 0;

      const zip = new JSZip();

      try {
        for (let i = 0; i < eligible.length; i++) {
          const req = eligible[i];
          this.currentBulkReq = req;
          this.bulkProgress = i + 1;

          // Wait for DOM to render currentBulkReq
          await this.$nextTick();
          await new Promise(resolve => setTimeout(resolve, 50));

          const element = this.$refs.bulkPaper;
          const opt = {
            margin:       [4, 4, 4, 4],
            filename:     `Invoice_${req.mobileNumber || req.user_id}_REQ${req.id}.pdf`,
            image:        { type: 'jpeg', quality: 0.95 },
            html2canvas:  { scale: 2, useCORS: true, logging: false },
            jsPDF:        { unit: 'mm', format: 'a4', orientation: 'portrait' }
          };

          const pdfBlob = await html2pdf().set(opt).from(element).outputPdf('blob');
          const pdfName = `Invoice_${req.mobileNumber || ('User' + req.user_id)}_REQ${req.id}.pdf`;
          zip.file(pdfName, pdfBlob);
        }

        // Generate and download ZIP file
        const zipBlob = await zip.generateAsync({ type: 'blob' });
        const downloadLink = document.createElement('a');
        downloadLink.href = URL.createObjectURL(zipBlob);
        downloadLink.download = `SR_Digital_Seva_Invoices_${this.bulkMonth}.zip`;
        downloadLink.click();
        URL.revokeObjectURL(downloadLink.href);

        this.showBulkModal = false;
      } catch (err) {
        console.error('Error generating bulk PDF ZIP:', err);
        alert('Failed to generate bulk invoice ZIP file. Please try again.');
      } finally {
        this.isGeneratingBulk = false;
        this.currentBulkReq = null;
      }
    }
  }
};
</script>

<style scoped>
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(15, 23, 42, 0.75);
  backdrop-filter: blur(4px);
  z-index: 999999;
  display: flex; align-items: center; justify-content: center;
  padding: 1rem;
}
</style>
