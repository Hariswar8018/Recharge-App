<template>
  <div v-if="show" class="invoice-modal-backdrop" @click="$emit('close')">
    <div class="invoice-modal-container" @click.stop>
      <!-- MODAL ACTION HEADER (NON-PRINTABLE) -->
      <div class="modal-top-bar no-print">
        <div class="top-title">
          <span class="icon">📄</span>
          <h3>Tax Invoice — {{ getInvoiceNo() }}</h3>
          <span class="badge-approved">✅ Approved</span>
        </div>
        <div class="top-actions">
          <button @click="downloadPdf" class="btn btn-pdf-sm" :disabled="downloading">
            <span v-if="downloading">⏳ Generating PDF...</span>
            <span v-else>📥 Download PDF</span>
          </button>
          <button @click="printInvoice" class="btn btn-print">
            🖨️ Print
          </button>
          <button @click="$emit('close')" class="btn-close-modal">&times;</button>
        </div>
      </div>

      <!-- INVOICE SHEET (PRINTABLE CONTAINER) -->
      <div class="printable-invoice-paper" id="invoice-paper" ref="invoicePaper">
        <!-- TOP HEADER: LOGO LEFT & CONTACT RIGHT -->
        <div class="header-section">
          <div class="brand-logo-container">
            <!-- SR DIGITAL SEVA KENDRAM LOGO GRAPHIC -->
            <svg class="brand-logo-svg" viewBox="0 0 280 80" xmlns="http://www.w3.org/2000/svg">
              <!-- Red and Blue swoosh arcs -->
              <path d="M 45 10 A 32 32 0 1 0 77 42" fill="none" stroke="#0047BA" stroke-width="7" stroke-linecap="round"/>
              <path d="M 45 74 A 32 32 0 1 0 13 42" fill="none" stroke="#D9232D" stroke-width="7" stroke-linecap="round"/>
              <circle cx="45" cy="42" r="8" fill="#D9232D"/>
              <!-- SR Styled Text inside logo -->
              <text x="32" y="50" font-family="'Inter', sans-serif" font-weight="900" font-size="24" fill="#0047BA">S</text>
              <text x="46" y="50" font-family="'Inter', sans-serif" font-weight="900" font-size="24" fill="#D9232D">R</text>
              <!-- Brand Title -->
              <text x="92" y="36" font-family="'Inter', sans-serif" font-weight="900" font-size="22" fill="#0047BA" letter-spacing="0.5">SR DIGITAL SEVA</text>
              <text x="92" y="62" font-family="'Inter', sans-serif" font-weight="900" font-size="22" fill="#D9232D" letter-spacing="3">KENDRAM</text>
            </svg>
          </div>

          <div class="contact-info-block">
            <div class="contact-row">
              <span class="contact-icon-circle">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="white"><path d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z"/></svg>
              </span>
              <span class="contact-text font-bold">9988494936</span>
            </div>
            <div class="contact-row">
              <span class="contact-icon-circle">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="white"><path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/></svg>
              </span>
              <span class="contact-text">info@srdigitalseva.com</span>
            </div>
            <div class="contact-row">
              <span class="contact-icon-circle">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="white"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>
              </span>
              <span class="contact-text">H.No: 33-5-118,<br>Warangal, Telangana - 506005</span>
            </div>
          </div>
        </div>

        <!-- SERVICE INVOICE BANNER -->
        <div class="service-invoice-banner">
          SERVICE INVOICE
        </div>

        <!-- CUSTOMER DETAILS & INVOICE DETAILS GRID -->
        <div class="details-grid">
          <!-- CUSTOMER DETAILS BOX -->
          <div class="details-box">
            <div class="box-header">CUSTOMER DETAILS</div>
            <div class="box-body">
              <div class="info-row">
                <span class="label">Customer Name</span>
                <span class="separator">:</span>
                <strong class="value highlight-name">{{ getCustomerName() }}</strong>
              </div>
              <div class="info-row">
                <span class="label">Mobile Number</span>
                <span class="separator">:</span>
                <span class="value">{{ getMobile() }}</span>
              </div>
              <div class="info-row">
                <span class="label">Email ID</span>
                <span class="separator">:</span>
                <span class="value">{{ getEmail() }}</span>
              </div>
              <div class="info-row">
                <span class="label">Address</span>
                <span class="separator">:</span>
                <span class="value multiline">{{ getAddress() }}</span>
              </div>
            </div>
          </div>

          <!-- INVOICE DETAILS BOX -->
          <div class="details-box">
            <div class="box-header">INVOICE DETAILS</div>
            <div class="box-body">
              <div class="info-row">
                <span class="label">Invoice No.</span>
                <span class="separator">:</span>
                <span class="value font-mono">{{ getInvoiceNo() }}</span>
              </div>
              <div class="info-row">
                <span class="label">Invoice Date</span>
                <span class="separator">:</span>
                <span class="value">{{ getInvoiceDate() }}</span>
              </div>
              <div class="info-row">
                <span class="label">Payment Mode</span>
                <span class="separator">:</span>
                <span class="value">{{ getPaymentMode() }}</span>
              </div>
              <div class="info-row">
                <span class="label">UTR Number</span>
                <span class="separator">:</span>
                <span class="value font-mono">{{ getUtrNumber() }}</span>
              </div>
              <div class="info-row">
                <span class="label">Payment Date</span>
                <span class="separator">:</span>
                <span class="value">{{ getPaymentDate() }}</span>
              </div>
              <div class="info-row align-center">
                <span class="label">Status</span>
                <span class="separator">:</span>
                <span class="badge-paid">PAID</span>
              </div>
            </div>
          </div>
        </div>

        <!-- SERVICE DESCRIPTION TABLE -->
        <div class="invoice-table-block">
          <table class="items-table">
            <thead>
              <tr>
                <th style="width: 8%;">S.No.</th>
                <th style="width: 52%;">DESCRIPTION OF SERVICE</th>
                <th style="width: 10%;">QTY.</th>
                <th style="width: 15%; text-align: right;">UNIT PRICE (₹)</th>
                <th style="width: 15%; text-align: right;">AMOUNT (₹)</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td style="text-align: center; font-weight: 800;">1</td>
                <td>
                  <strong class="service-title">Online Application & Processing Service</strong>
                  <div class="service-sub">
                    (Application form filling, document verification, online submission and follow-up support)
                  </div>
                </td>
                <td style="text-align: center; font-weight: 800;">1</td>
                <td style="text-align: right; font-weight: 800;">{{ formatCurrency(getAmount()) }}</td>
                <td style="text-align: right; font-weight: 800;">{{ formatCurrency(getAmount()) }}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- MIDDLE SUMMARY SECTION -->
        <div class="middle-summary-grid">
          <!-- LEFT SUB-BOXES -->
          <div class="left-boxes-column">
            <div class="tinted-box">
              <div class="box-title">Amount in Words :</div>
              <div class="amount-in-words">{{ getAmountInWords() }}</div>
            </div>

            <div class="tinted-box mt-2">
              <div class="box-title">Service Purpose / Reference</div>
              <div class="purpose-text">
                This amount is for the online application service provided to the customer as per their request.
              </div>
            </div>
          </div>

          <!-- RIGHT TOTALS TABLE -->
          <div class="right-totals-column">
            <table class="totals-table">
              <tr>
                <td class="tot-label">Sub Total</td>
                <td class="tot-sym">₹</td>
                <td class="tot-val">{{ formatCurrency(getAmount()) }}</td>
              </tr>
              <tr>
                <td class="tot-label">Discount</td>
                <td class="tot-sym">₹</td>
                <td class="tot-val">0.00</td>
              </tr>
              <tr>
                <td class="tot-label font-bold">Total Amount</td>
                <td class="tot-sym font-bold">₹</td>
                <td class="tot-val font-bold">{{ formatCurrency(getAmount()) }}</td>
              </tr>
              <tr class="grand-total-row">
                <td class="tot-label">Grand Total</td>
                <td class="tot-sym">₹</td>
                <td class="tot-val">{{ formatCurrency(getAmount()) }}</td>
              </tr>
            </table>
          </div>
        </div>

        <!-- FOOTER & SIGNATURE SECTION -->
        <div class="footer-sign-section">
          <!-- TERMS & THANK YOU LEFT -->
          <div class="terms-column">
            <div class="terms-title">Terms & Conditions :</div>
            <ol class="terms-list">
              <li>This is a computer generated invoice.</li>
              <li>Services once processed will not be cancelled or refunded.</li>
              <li>Please verify the details before making the payment.</li>
              <li>All disputes are subject to Warangal Jurisdiction.</li>
            </ol>

            <div class="thank-you-block">
              <div class="thank-you-script">Thank You!</div>
              <div class="thank-you-sub">For Your Business</div>
            </div>
          </div>

          <!-- STAMP & AUTHORISED SIGNATORY RIGHT -->
          <div class="stamp-column">
            <div class="stamp-wrapper">
              <!-- DOUBLE CIRCLE STAMP SVG -->
              <svg class="stamp-svg" viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg">
                <!-- Outer circle -->
                <circle cx="80" cy="80" r="74" fill="none" stroke="#003399" stroke-width="3"/>
                <!-- Inner circle -->
                <circle cx="80" cy="80" r="62" fill="none" stroke="#003399" stroke-width="1.5"/>
                <!-- Circular Text path -->
                <path id="circlePath" d="M 25, 80 a 55,55 0 1,1 110,0 a 55,55 0 1,1 -110,0" fill="none"/>
                <text font-family="'Inter', sans-serif" font-weight="900" font-size="10.5" fill="#003399" letter-spacing="1">
                  <textPath href="#circlePath" startOffset="50%" text-anchor="middle">
                    SR DIGITAL SEVA KENDRAM
                  </textPath>
                </text>
                <!-- Center text -->
                <text x="80" y="74" font-family="'Inter', sans-serif" font-weight="800" font-size="11" fill="#003399" text-anchor="middle">Regd. No:</text>
                <text x="80" y="92" font-family="'Inter', sans-serif" font-weight="900" font-size="13" fill="#003399" text-anchor="middle">34294</text>
                <text x="80" y="116" font-family="'Inter', sans-serif" font-size="14" fill="#003399" text-anchor="middle">★</text>
              </svg>

              <!-- OVERLAID SIGNATURE -->
              <div class="signature-overlay">Rajesh</div>
            </div>

            <div class="signatory-line-box">
              <div class="sign-line"></div>
              <div class="signatory-text">Authorised Signatory</div>
            </div>
          </div>
        </div>

        <!-- BOTTOM WAVE ACCENT GRAPHIC -->
        <div class="bottom-wave-accent">
          <svg viewBox="0 0 800 50" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M 0 30 Q 200 0 400 30 T 800 10 L 800 50 L 0 50 Z" fill="#4A90E2" opacity="0.4"/>
            <path d="M 0 40 Q 250 15 500 35 T 800 20 L 800 50 L 0 50 Z" fill="#0047BA"/>
          </svg>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import html2pdf from 'html2pdf.js';

export default {
  name: 'InvoiceModal',
  props: {
    show: { type: Boolean, default: false },
    transaction: { type: Object, default: null },
    user: { type: Object, default: null }
  },
  data() {
    return {
      downloading: false
    };
  },
  methods: {
    formatCurrency(val) {
      const num = parseFloat(val || 0);
      return isNaN(num) ? '0.00' : num.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    },
    getAmount() {
      if (this.transaction && (this.transaction.amount || this.transaction.numeric_amount)) {
        return parseFloat(this.transaction.amount || this.transaction.numeric_amount);
      }
      return 1200.00;
    },
    getCustomerName() {
      if (this.transaction && (this.transaction.fullName || this.transaction.name)) {
        return this.transaction.fullName || this.transaction.name;
      }
      if (this.user && (this.user.fullName || this.user.name)) {
        return this.user.fullName || this.user.name;
      }
      return 'Ramesh Kumar';
    },
    getMobile() {
      if (this.transaction && (this.transaction.mobileNumber || this.transaction.mobile)) {
        return this.transaction.mobileNumber || this.transaction.mobile;
      }
      if (this.user && (this.user.mobileNumber || this.user.mobile)) {
        return this.user.mobileNumber || this.user.mobile;
      }
      return '9876543210';
    },
    getEmail() {
      if (this.transaction && this.transaction.email) return this.transaction.email;
      if (this.user && this.user.email) return this.user.email;
      return 'ramesh@gmail.com';
    },
    getAddress() {
      if (this.transaction && this.transaction.address) {
        let addr = this.transaction.address;
        if (this.transaction.city) addr += `, ${this.transaction.city}`;
        if (this.transaction.state) addr += `, ${this.transaction.state}`;
        if (this.transaction.pincode) addr += ` - ${this.transaction.pincode}`;
        return addr;
      }
      if (this.user && this.user.address) {
        let addr = this.user.address;
        if (this.user.city) addr += `, ${this.user.city}`;
        if (this.user.state) addr += `, ${this.user.state}`;
        if (this.user.pincode) addr += ` - ${this.user.pincode}`;
        return addr;
      }
      return 'H.No: 12-3-45, Hanamkonda, Warangal, Telangana - 506001';
    },
    getInvoiceNo() {
      const id = this.transaction ? (this.transaction.id || this.transaction.tx_id || 123) : 123;
      const padId = String(id).padStart(4, '0');
      return `SR/2026-27/${padId}`;
    },
    getInvoiceDate() {
      const dStr = this.transaction ? (this.transaction.createdAt || this.transaction.date) : null;
      if (!dStr) return '26/05/2026';
      const d = new Date(dStr);
      if (isNaN(d.getTime())) return String(dStr).substring(0, 10);
      const day = String(d.getDate()).padStart(2, '0');
      const month = String(d.getMonth() + 1).padStart(2, '0');
      const year = d.getFullYear();
      return `${day}/${month}/${year}`;
    },
    getPaymentDate() {
      const dStr = this.transaction ? (this.transaction.createdAt || this.transaction.date) : null;
      if (!dStr) return '26/05/2026 11:44 AM';
      const d = new Date(dStr);
      if (isNaN(d.getTime())) return String(dStr);
      const day = String(d.getDate()).padStart(2, '0');
      const month = String(d.getMonth() + 1).padStart(2, '0');
      const year = d.getFullYear();
      let hours = d.getHours();
      const minutes = String(d.getMinutes()).padStart(2, '0');
      const ampm = hours >= 12 ? 'PM' : 'AM';
      hours = hours % 12;
      hours = hours ? hours : 12;
      return `${day}/${month}/${year} ${hours}:${minutes} ${ampm}`;
    },
    getPaymentMode() {
      if (this.transaction && this.transaction.payment_method) {
        return this.transaction.payment_method.toUpperCase();
      }
      return 'UPI';
    },
    getUtrNumber() {
      if (this.transaction && (this.transaction.utr_number || this.transaction.utr)) {
        return this.transaction.utr_number || this.transaction.utr;
      }
      return '412345678901';
    },
    getAmountInWords() {
      const amt = this.getAmount();
      return this.numberToWordsINR(amt);
    },
    numberToWordsINR(amount) {
      const num = Math.floor(parseFloat(amount) || 0);
      if (num === 0) return 'Rupees Zero Only';

      const singleDigits = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'];
      const doubleDigits = ['Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
      const tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

      function convertTwoDigits(n) {
        if (n < 10) return singleDigits[n];
        if (n >= 10 && n < 20) return doubleDigits[n - 10];
        const tenVal = Math.floor(n / 10);
        const remainder = n % 10;
        return tens[tenVal] + (remainder ? ' ' + singleDigits[remainder] : '');
      }

      function convertThreeDigits(n) {
        const hundredVal = Math.floor(n / 100);
        const remainder = n % 100;
        let str = '';
        if (hundredVal > 0) {
          str += singleDigits[hundredVal] + ' Hundred';
        }
        if (remainder > 0) {
          if (str !== '') str += ' ';
          str += convertTwoDigits(remainder);
        }
        return str;
      }

      let words = '';
      const crore = Math.floor(num / 10000000);
      let rem = num % 10000000;
      const lakh = Math.floor(rem / 100000);
      rem = rem % 100000;
      const thousand = Math.floor(rem / 1000);
      rem = rem % 1000;
      const hundredAndBelow = rem;

      if (crore > 0) words += convertTwoDigits(crore) + ' Crore ';
      if (lakh > 0) words += convertTwoDigits(lakh) + ' Lakh ';
      if (thousand > 0) words += convertTwoDigits(thousand) + ' Thousand ';
      if (hundredAndBelow > 0) words += convertThreeDigits(hundredAndBelow);

      return `Rupees ${words.trim()} Only`;
    },
    printInvoice() {
      window.print();
    },
    async downloadPdf() {
      if (this.downloading) return;
      this.downloading = true;
      try {
        const element = this.$refs.invoicePaper;
        const filename = `Invoice_${this.getMobile()}_${this.transaction ? (this.transaction.id || '1001') : '1001'}.pdf`;
        const opt = {
          margin:       [4, 4, 4, 4],
          filename:     filename,
          image:        { type: 'jpeg', quality: 0.98 },
          html2canvas:  { scale: 2, useCORS: true, logging: false },
          jsPDF:        { unit: 'mm', format: 'a4', orientation: 'portrait' }
        };
        await html2pdf().set(opt).from(element).save();
      } catch (err) {
        console.error('Failed to download invoice PDF:', err);
        alert('Failed to generate PDF invoice. Please try again.');
      } finally {
        this.downloading = false;
      }
    }
  }
};
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Alex+Brush&family=Inter:wght@400;500;600;700;800;900&display=swap');

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
  max-width: 820px;
  width: 100%;
  max-height: 94vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
  overflow: hidden;
}

.modal-top-bar {
  background: #002D72;
  color: white;
  padding: 0.85rem 1.25rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.top-title {
  display: flex;
  align-items: center;
  gap: 0.6rem;
}

.top-title h3 {
  margin: 0;
  font-size: 1.05rem;
  font-weight: 800;
}

.badge-approved {
  background: #16a34a;
  color: white;
  font-size: 0.72rem;
  font-weight: 800;
  padding: 2px 8px;
  border-radius: 12px;
}

.top-actions {
  display: flex;
  align-items: center;
  gap: 0.6rem;
}

.btn-pdf-sm {
  background: #0047BA;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 800;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-pdf-sm:hover {
  background: #003399;
}

.btn-print {
  background: #475569;
  color: white;
  border: none;
  padding: 0.5rem 0.9rem;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 700;
  cursor: pointer;
}

.btn-close-modal {
  background: transparent;
  border: none;
  color: white;
  font-size: 1.5rem;
  cursor: pointer;
  line-height: 1;
}

/* PRINTABLE INVOICE PAPER STYLES (MATCHING REFERENCE IMAGE 1:1) */
.printable-invoice-paper {
  padding: 2.2rem 2.5rem 1.5rem 2.5rem;
  overflow-y: auto;
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  color: #111827;
  background: #ffffff;
  position: relative;
  box-sizing: border-box;
}

/* TOP HEADER */
.header-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.25rem;
}

.brand-logo-svg {
  width: 240px;
  height: 65px;
}

.contact-info-block {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.contact-row {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.82rem;
  color: #111827;
}

.contact-icon-circle {
  width: 20px;
  height: 20px;
  background: #0047BA;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.contact-text {
  font-size: 0.82rem;
  line-height: 1.2;
}

.font-bold {
  font-weight: 700;
}

/* BANNER */
.service-invoice-banner {
  background: #0047BA;
  color: #ffffff;
  font-weight: 900;
  font-size: 1.65rem;
  letter-spacing: 2px;
  text-align: center;
  padding: 8px 0;
  border-radius: 12px;
  margin-bottom: 1.25rem;
  text-transform: uppercase;
  box-shadow: 0 4px 6px -1px rgba(0, 71, 186, 0.2);
}

/* DETAILS GRID */
.details-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.25rem;
  margin-bottom: 1.25rem;
}

.details-box {
  border: 1.5px solid #0052B4;
  border-radius: 8px;
  overflow: hidden;
  background: #ffffff;
}

.box-header {
  background: #DCEBFB;
  color: #0047BA;
  font-weight: 900;
  font-size: 0.88rem;
  padding: 6px 12px;
  letter-spacing: 0.5px;
  border-bottom: 1px solid #0052B4;
}

.box-body {
  padding: 10px 12px;
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.info-row {
  display: flex;
  align-items: flex-start;
  font-size: 0.82rem;
  line-height: 1.35;
}

.info-row.align-center {
  align-items: center;
}

.info-row .label {
  width: 110px;
  color: #374151;
  flex-shrink: 0;
}

.info-row .separator {
  width: 15px;
  color: #374151;
  font-weight: 700;
}

.info-row .value {
  flex: 1;
  color: #111827;
}

.highlight-name {
  font-size: 0.95rem;
  font-weight: 900;
  color: #000000;
}

.font-mono {
  font-family: monospace;
  font-size: 0.85rem;
}

.badge-paid {
  background: #008744;
  color: white;
  font-weight: 900;
  font-size: 0.75rem;
  padding: 2px 14px;
  border-radius: 10px;
  letter-spacing: 0.5px;
  display: inline-block;
}

/* TABLE STYLES */
.invoice-table-block {
  margin-bottom: 1.25rem;
  border: 1.5px solid #0052B4;
  border-radius: 8px;
  overflow: hidden;
}

.items-table {
  width: 100%;
  border-collapse: collapse;
}

.items-table th {
  background: #0047BA;
  color: white;
  font-size: 0.82rem;
  font-weight: 800;
  padding: 8px 10px;
  border-right: 1px solid rgba(255, 255, 255, 0.2);
  letter-spacing: 0.5px;
}

.items-table th:last-child {
  border-right: none;
}

.items-table td {
  padding: 12px 10px;
  font-size: 0.85rem;
  border-right: 1.5px solid #0052B4;
  color: #111827;
  vertical-align: top;
}

.items-table td:last-child {
  border-right: none;
}

.service-title {
  font-size: 0.9rem;
  font-weight: 800;
  color: #000000;
}

.service-sub {
  font-size: 0.78rem;
  color: #4b5563;
  margin-top: 3px;
  line-height: 1.3;
}

/* MIDDLE SUMMARY GRID */
.middle-summary-grid {
  display: grid;
  grid-template-columns: 1.3fr 1fr;
  gap: 1.25rem;
  margin-bottom: 1.25rem;
}

.left-boxes-column {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.tinted-box {
  background: #EBF4FF;
  border: 1px solid #B8D5FA;
  border-radius: 8px;
  padding: 8px 12px;
}

.box-title {
  font-size: 0.85rem;
  font-weight: 900;
  color: #0047BA;
  margin-bottom: 4px;
}

.amount-in-words {
  font-size: 0.95rem;
  font-weight: 900;
  color: #000000;
}

.purpose-text {
  font-size: 0.8rem;
  color: #374151;
  line-height: 1.35;
}

.right-totals-column {
  border: 1.5px solid #0052B4;
  border-radius: 8px;
  overflow: hidden;
}

.totals-table {
  width: 100%;
  border-collapse: collapse;
}

.totals-table td {
  padding: 7px 10px;
  font-size: 0.85rem;
  border-bottom: 1px solid #DCEBFB;
}

.totals-table tr:last-child td {
  border-bottom: none;
}

.tot-label {
  color: #374151;
  font-size: 0.85rem;
}

.tot-sym {
  text-align: right;
  width: 25px;
  color: #374151;
  font-weight: 600;
}

.tot-val {
  text-align: right;
  font-weight: 800;
  color: #111827;
  width: 90px;
}

.grand-total-row {
  background: #0047BA !important;
}

.grand-total-row td {
  color: white !important;
  font-weight: 900 !important;
  font-size: 0.95rem !important;
}

/* FOOTER SECTION */
.footer-sign-section {
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  gap: 1.25rem;
  align-items: flex-end;
  margin-top: 0.5rem;
  padding-bottom: 2rem;
}

.terms-title {
  font-size: 0.85rem;
  font-weight: 900;
  color: #0047BA;
  margin-bottom: 4px;
}

.terms-list {
  margin: 0 0 1rem 0;
  padding-left: 1.1rem;
  font-size: 0.75rem;
  color: #374151;
  line-height: 1.45;
}

.thank-you-block {
  margin-top: 0.75rem;
}

.thank-you-script {
  font-family: 'Alex Brush', cursive;
  font-size: 2.2rem;
  color: #0047BA;
  line-height: 1;
  position: relative;
  display: inline-block;
}

.thank-you-script::after {
  content: '';
  position: absolute;
  bottom: 2px;
  left: 0;
  right: 0;
  height: 2px;
  background: #D9232D;
  border-radius: 2px;
}

.thank-you-sub {
  font-size: 0.8rem;
  font-weight: 800;
  color: #111827;
  margin-top: 4px;
  letter-spacing: 0.5px;
}

/* STAMP COLUMN */
.stamp-column {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
}

.stamp-wrapper {
  position: relative;
  width: 140px;
  height: 140px;
  margin-bottom: 6px;
}

.stamp-svg {
  width: 100%;
  height: 100%;
}

.signature-overlay {
  position: absolute;
  top: 45%;
  left: 50%;
  transform: translate(-50%, -50%) rotate(-10deg);
  font-family: 'Alex Brush', cursive;
  font-size: 2.5rem;
  color: #002D72;
  font-weight: 700;
  white-space: nowrap;
  pointer-events: none;
  text-shadow: 0 0 2px rgba(255,255,255,0.8);
}

.signatory-line-box {
  width: 180px;
  text-align: center;
}

.sign-line {
  height: 2px;
  background: #0047BA;
  margin-bottom: 4px;
}

.signatory-text {
  font-size: 0.82rem;
  font-weight: 900;
  color: #0047BA;
  letter-spacing: 0.5px;
}

/* BOTTOM WAVE */
.bottom-wave-accent {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 35px;
  overflow: hidden;
}

.bottom-wave-accent svg {
  width: 100%;
  height: 100%;
  display: block;
}

/* PRINT MEDIA QUERIES */
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
    padding: 1.5rem;
  }
}
</style>
