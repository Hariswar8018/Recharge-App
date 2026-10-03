<template>
  <div class="requests-pane">
    <div class="table-card">
      <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem; margin-bottom: 1rem;">
        <div>
          <h3 style="margin: 0; font-size: 1.25rem; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px;">
            <span>💳</span> Manage User Add Money / Fund Deposit Requests
          </h3>
          <div style="display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; align-items: center;">
            <span class="count-pill" style="background: #2563eb; color: white; padding: 2px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: 800;">
              📑 {{ fundRequests.length }} Total Requests
            </span>
            <span class="count-pill" style="background: #f59e0b; color: white; padding: 2px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: 800;">
              🟡 {{ calcPendingCount }} Pending
            </span>
            <span class="count-pill" style="background: #10b981; color: white; padding: 2px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: 800;">
              🟢 {{ calcApprovedCount }} Approved
            </span>
            <span class="count-pill" style="background: #ef4444; color: white; padding: 2px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: 800;">
              🔴 {{ calcRejectedCount }} Rejected
            </span>
            <span class="count-pill" style="background: #0f172a; color: #38bdf8; padding: 2px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: 800;">
              💰 Total Vol: ₹{{ totalApprovedVolume.toFixed(2) }}
            </span>
          </div>
        </div>
        
        <!-- BULK MONTHLY INVOICE DOWNLOAD BUTTON -->
        <button 
          @click="showBulkModal = true" 
          class="btn-bulk-zip" 
          style="background: #0047BA; color: white; border: none; padding: 0.65rem 1.2rem; border-radius: 8px; font-weight: 800; font-size: 0.88rem; cursor: pointer; display: flex; align-items: center; gap: 6px; box-shadow: 0 4px 6px -1px rgba(0, 71, 186, 0.25);"
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
          🟡 Pending Approval ({{ calcPendingCount }})
        </button>
        <button 
          @click="$emit('update:reqFilterStatus', 'APPROVED')" 
          :class="['tab-pill', { active: reqFilterStatus === 'APPROVED' }]"
          style="padding: 0.5rem 1rem; border: none; border-radius: 20px; font-weight: 700; font-size: 0.85rem; cursor: pointer;"
          :style="{ background: reqFilterStatus === 'APPROVED' ? '#10b981' : '#f1f5f9', color: reqFilterStatus === 'APPROVED' ? 'white' : '#475569' }"
        >
          🟢 Approved Credit ({{ calcApprovedCount }})
        </button>
        <button 
          @click="$emit('update:reqFilterStatus', 'REJECTED')" 
          :class="['tab-pill', { active: reqFilterStatus === 'REJECTED' }]"
          style="padding: 0.5rem 1rem; border: none; border-radius: 20px; font-weight: 700; font-size: 0.85rem; cursor: pointer;"
          :style="{ background: reqFilterStatus === 'REJECTED' ? '#ef4444' : '#f1f5f9', color: reqFilterStatus === 'REJECTED' ? 'white' : '#475569' }"
        >
          🔴 Rejected ({{ calcRejectedCount }})
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
              <th>Member Information</th>
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
              <td colspan="10" style="text-align: center; padding: 2rem; color: #64748b; font-weight: 600;">
                No fund requests found matching filters.
              </td>
            </tr>
            <tr v-for="req in filteredRequests" :key="req.id">
              <td class="font-bold">#{{ req.id }}</td>
              <td style="white-space: nowrap; font-size: 0.82rem; color: #475569;">
                {{ req.createdAt ? String(req.createdAt).substring(0,16) : (req.date ? String(req.date).substring(0,16) : 'N/A') }}
              </td>
              <td>
                <div style="font-weight: 800; color: #0f172a; font-size: 0.9rem;">{{ req.fullName || 'User #' + req.user_id }}</div>
                <div style="font-size: 0.78rem; color: #64748b;" class="font-mono">📞 {{ req.mobileNumber || 'N/A' }}</div>
                <div style="font-size: 0.72rem; color: #94a3b8;">ID: #{{ req.user_id }}</div>
              </td>
              <td>
                <span class="badge-payment" style="background: #e0f2fe; color: #0369a1; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 0.78rem;">
                  {{ req.payment_method || 'UPI / QR' }}
                </span>
              </td>
              <td class="font-mono" style="font-weight: 700; color: #1e293b; font-size: 0.85rem;">
                {{ req.utr_number || req.utr || 'N/A' }}
              </td>
              <td class="font-bold" style="font-size: 0.98rem; color: #16a34a;">
                ₹{{ parseFloat(req.amount || 0).toFixed(2) }}
              </td>
              <td>
                <button v-if="req.payment_proof_url" @click="$emit('view-receipt', req)" class="btn-receipt-link" style="background: #e2e8f0; color: #1e293b; border: none; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 0.78rem; cursor: pointer;">
                  📷 View Proof
                </button>
                <span v-else style="font-size: 0.78rem; color: #94a3b8;">No File</span>
              </td>
              <td>
                <span 
                  :style="{
                    background: req.status === 'APPROVED' ? '#dcfce7' : (req.status === 'REJECTED' ? '#fee2e2' : '#fef3c7'),
                    color: req.status === 'APPROVED' ? '#15803d' : (req.status === 'REJECTED' ? '#b91c1c' : '#d97706'),
                    padding: '4px 10px',
                    borderRadius: '12px',
                    fontWeight: '800',
                    fontSize: '0.78rem',
                    display: 'inline-block'
                  }"
                >
                  {{ req.status === 'APPROVED' ? '🟢 APPROVED' : (req.status === 'REJECTED' ? '🔴 REJECTED' : '🟡 PENDING') }}
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
                <span v-else style="font-size: 0.78rem; color: #94a3b8; font-style: italic;">
                  No Invoice (Unapproved)
                </span>
              </td>

              <td style="white-space: nowrap;">
                <div v-if="req.status === 'PENDING'" style="display: flex; gap: 4px;">
                  <button @click="$emit('approve-request', req.id)" class="btn-action-approve" style="background: #10b981; color: white; border: none; padding: 5px 10px; border-radius: 5px; font-weight: 700; font-size: 0.78rem; cursor: pointer;">
                    ✓ Approve
                  </button>
                  <button @click="$emit('reject-request', req.id)" class="btn-action-reject" style="background: #ef4444; color: white; border: none; padding: 5px 10px; border-radius: 5px; font-weight: 700; font-size: 0.78rem; cursor: pointer;">
                    ✗ Reject
                  </button>
                </div>
                <span v-else-if="req.status === 'APPROVED'" style="background: #dcfce7; color: #166534; padding: 3px 8px; border-radius: 4px; font-size: 0.78rem; font-weight: 700;">
                  ✓ Approved
                </span>
                <span v-else-if="req.status === 'REJECTED'" style="background: #fee2e2; color: #991b1b; padding: 3px 8px; border-radius: 4px; font-size: 0.78rem; font-weight: 700;">
                  ✗ Rejected
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- BULK DOWNLOAD MODAL WITH BY MONTH / BY CUSTOM TOGGLE -->
    <div v-if="showBulkModal" class="modal-backdrop" @click="showBulkModal = false">
      <div class="modal-dialog" @click.stop style="max-width: 520px; width: 100%; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3);">
        <div class="modal-header" style="background: #0047BA; color: white; padding: 1rem 1.25rem; display: flex; justify-content: space-between; align-items: center;">
          <h3 style="margin: 0; font-size: 1.1rem; font-weight: 800; display: flex; align-items: center; gap: 8px;">
            <span>📦</span> Bulk Download PDF Invoices (ZIP)
          </h3>
          <button @click="showBulkModal = false" style="background: none; border: none; color: white; font-size: 1.5rem; cursor: pointer;">&times;</button>
        </div>

        <div class="modal-body" style="padding: 1.25rem;">
          <!-- MODE SWITCH TOGGLE PILLS -->
          <div style="display: flex; gap: 0.5rem; margin-bottom: 1.25rem; background: #f1f5f9; padding: 4px; border-radius: 8px;">
            <button 
              @click="bulkMode = 'MONTH'" 
              :style="{ background: bulkMode === 'MONTH' ? '#0047BA' : 'transparent', color: bulkMode === 'MONTH' ? 'white' : '#475569' }"
              style="flex: 1; padding: 0.55rem; border: none; border-radius: 6px; font-weight: 800; font-size: 0.85rem; cursor: pointer; transition: all 0.2s;"
            >
              📅 By Month
            </button>
            <button 
              @click="bulkMode = 'CUSTOM'" 
              :style="{ background: bulkMode === 'CUSTOM' ? '#0047BA' : 'transparent', color: bulkMode === 'CUSTOM' ? 'white' : '#475569' }"
              style="flex: 1; padding: 0.55rem; border: none; border-radius: 6px; font-weight: 800; font-size: 0.85rem; cursor: pointer; transition: all 0.2s;"
            >
              🔍 By Custom Filter
            </button>
          </div>

          <!-- MODE 1: BY MONTH -->
          <div v-if="bulkMode === 'MONTH'" style="margin-bottom: 1rem;">
            <label style="font-size: 0.8rem; font-weight: 800; color: #0047BA; display: block; margin-bottom: 6px;">📅 Select Target Month</label>
            <input type="month" v-model="bulkMonth" style="width: 100%; padding: 0.65rem 0.85rem; border-radius: 8px; border: 1px solid #cbd5e1; font-size: 0.95rem; box-sizing: border-box;" />
          </div>

          <!-- MODE 2: BY CUSTOM FILTER -->
          <div v-else style="display: flex; flex-direction: column; gap: 0.75rem; margin-bottom: 1rem; background: #f8fafc; padding: 0.85rem; border-radius: 8px; border: 1px solid #e2e8f0;">
            <!-- Search Query -->
            <div>
              <label style="font-size: 0.75rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">Search User / Mobile / Email / Sponsor ID</label>
              <input 
                type="text" 
                v-model="bulkSearchQuery" 
                placeholder="Name, Mobile, Email, Sponsor ID, UTR..." 
                style="width: 100%; padding: 0.5rem 0.75rem; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 0.85rem; box-sizing: border-box;" 
              />
            </div>

            <!-- Date Range -->
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem;">
              <div>
                <label style="font-size: 0.75rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">From Date</label>
                <input type="date" v-model="bulkFromDate" style="width: 100%; padding: 0.45rem; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 0.82rem; box-sizing: border-box;" />
              </div>
              <div>
                <label style="font-size: 0.75rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">To Date</label>
                <input type="date" v-model="bulkToDate" style="width: 100%; padding: 0.45rem; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 0.82rem; box-sizing: border-box;" />
              </div>
            </div>

            <!-- Amount Filter -->
            <div>
              <label style="font-size: 0.75rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">Filter by Amount</label>
              <select v-model="bulkAmountFilter" style="width: 100%; padding: 0.5rem; border-radius: 6px; border: 1px solid #cbd5e1; font-size: 0.85rem; background: white;">
                <option value="">All Amounts</option>
                <option value="1200">₹ 1,200 (Package TopUp)</option>
                <option value="500">₹ 500</option>
                <option value="2000">₹ 2,000</option>
                <option value="5000">₹ 5,000</option>
              </select>
            </div>
          </div>

          <!-- MATCHING SUMMARY CARD -->
          <div style="background: #e0f2fe; border: 1px solid #7dd3fc; padding: 0.85rem 1rem; border-radius: 8px; margin-bottom: 1rem;">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <strong style="font-size: 0.9rem; color: #0369a1;">
                📄 Ready Invoices: {{ eligibleBulkRequests.length }}
              </strong>
              <span style="font-weight: 800; font-size: 0.88rem; color: #0284c7;">
                Total Vol: ₹{{ bulkTotalVolume.toFixed(2) }}
              </span>
            </div>
            <div v-if="eligibleBulkRequests.length > 0" style="font-size: 0.75rem; color: #0284c7; margin-top: 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
              Users: {{ eligibleBulkRequests.slice(0, 4).map(r => r.fullName || ('User #' + r.user_id)).join(', ') }}{{ eligibleBulkRequests.length > 4 ? ` + ${eligibleBulkRequests.length - 4} more` : '' }}
            </div>
            <div v-else style="font-size: 0.78rem; color: #e11d48; margin-top: 4px; font-weight: 700;">
              ⚠️ No approved requests match the current selection filters.
            </div>
          </div>

          <!-- PROGRESS BAR WHEN GENERATING -->
          <div v-if="isGeneratingBulk" style="margin-top: 1rem; background: #f0fdf4; border: 1px solid #86efac; padding: 1rem; border-radius: 8px;">
            <div style="font-weight: 800; font-size: 0.85rem; color: #166534; margin-bottom: 6px;">
              ⏳ Generating PDF Invoices... ({{ bulkProgress }} / {{ bulkTotal }})
            </div>
            <div style="background: #bbf7d0; height: 10px; border-radius: 5px; overflow: hidden;">
              <div :style="{ width: (bulkTotal ? (bulkProgress / bulkTotal * 100) : 0) + '%' }" style="background: #16a34a; height: 100%; transition: width 0.2s;"></div>
            </div>
          </div>

          <div style="background: #f8fafc; border: 1px solid #e2e8f0; padding: 0.75rem; border-radius: 8px; margin-top: 0.75rem; font-size: 0.78rem; color: #64748b;">
            <strong>ℹ️ Note:</strong> Each approved request generates a separate PDF styled 1:1 with the tax invoice template. Pending and Rejected requests are automatically excluded.
          </div>
        </div>

        <div class="modal-footer" style="padding: 1rem; background: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 0.75rem;">
          <button @click="showBulkModal = false" :disabled="isGeneratingBulk" style="padding: 0.55rem 1.1rem; border: 1px solid #cbd5e1; background: white; border-radius: 6px; cursor: pointer; font-weight: 700;">Cancel</button>
          <button @click="generateBulkZip" :disabled="isGeneratingBulk || eligibleBulkRequests.length === 0" style="padding: 0.55rem 1.25rem; background: #0047BA; color: white; border: none; border-radius: 6px; font-weight: 800; cursor: pointer;" :style="{ opacity: (isGeneratingBulk || eligibleBulkRequests.length === 0) ? 0.6 : 1 }">
            <span v-if="isGeneratingBulk">Processing...</span>
            <span v-else>⚡ Download ZIP ({{ eligibleBulkRequests.length }} PDFs)</span>
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

    <!-- OFFSCREEN ELEMENT FOR BULK PDF RENDERING (EXACT SAME TEMPLATE AS INVOICEMODAL.VUE) -->
    <div id="offscreen-invoice-container" style="position: absolute; left: -9999px; top: -9999px; width: 800px;">
      <div v-if="currentBulkReq" class="printable-invoice-paper" ref="bulkPaper" style="width: 794px; background: white; padding: 2.2rem 2.5rem 1.5rem 2.5rem; box-sizing: border-box; font-family: 'Inter', sans-serif;">
        <!-- TOP HEADER: LOGO LEFT & CONTACT RIGHT -->
        <div class="header-section" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem;">
          <div class="brand-logo-container">
            <img :src="receiptLogo" alt="SR Digital Seva Kendram" style="height: 75px; width: auto; object-fit: contain;" />
          </div>
          <div class="contact-info-block" style="display: flex; flex-direction: column; gap: 4px;">
            <div class="contact-row" style="display: flex; align-items: center; gap: 8px; font-size: 0.82rem; color: #111827;">
              <span class="contact-icon-circle" style="width: 20px; height: 20px; background: #0047BA; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="white"><path d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z"/></svg>
              </span>
              <span class="contact-text font-bold" style="font-weight: 700;">9988494936</span>
            </div>
            <div class="contact-row" style="display: flex; align-items: center; gap: 8px; font-size: 0.82rem; color: #111827;">
              <span class="contact-icon-circle" style="width: 20px; height: 20px; background: #0047BA; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="white"><path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/></svg>
              </span>
              <span class="contact-text">info@srdigitalseva.com</span>
            </div>
            <div class="contact-row" style="display: flex; align-items: center; gap: 8px; font-size: 0.82rem; color: #111827;">
              <span class="contact-icon-circle" style="width: 20px; height: 20px; background: #0047BA; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="white"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>
              </span>
              <span class="contact-text">H.No: 33-5-118,<br>Warangal, Telangana - 506005</span>
            </div>
          </div>
        </div>

        <!-- SERVICE INVOICE BANNER -->
        <div class="service-invoice-banner" style="background: #0047BA !important; color: #ffffff !important; font-weight: 900; font-size: 1.65rem; letter-spacing: 2px; text-align: center; padding: 8px 0; border-radius: 12px; margin-bottom: 1.25rem; text-transform: uppercase;">
          SERVICE INVOICE
        </div>

        <!-- CUSTOMER DETAILS & INVOICE DETAILS GRID -->
        <div class="details-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.25rem; margin-bottom: 1.25rem;">
          <div class="details-box" style="border: 1.5px solid #0052B4; border-radius: 8px; overflow: hidden; background: #ffffff;">
            <div class="box-header" style="background: #DCEBFB !important; color: #0047BA !important; font-weight: 900; font-size: 0.88rem; padding: 6px 12px; border-bottom: 1px solid #0052B4;">CUSTOMER DETAILS</div>
            <div class="box-body" style="padding: 10px 12px; display: flex; flex-direction: column; gap: 5px;">
              <div class="info-row" style="display: flex; font-size: 0.82rem;"><span class="label" style="width: 110px; color: #374151;">Customer Name</span><span class="separator" style="width: 15px;">:</span><strong class="value" style="flex: 1; font-weight: 900; color: #000;">{{ currentBulkReq.fullName || 'Member' }}</strong></div>
              <div class="info-row" style="display: flex; font-size: 0.82rem;"><span class="label" style="width: 110px; color: #374151;">Mobile Number</span><span class="separator" style="width: 15px;">:</span><span class="value" style="flex: 1;">{{ currentBulkReq.mobileNumber || 'N/A' }}</span></div>
              <div class="info-row" style="display: flex; font-size: 0.82rem;"><span class="label" style="width: 110px; color: #374151;">Email ID</span><span class="separator" style="width: 15px;">:</span><span class="value" style="flex: 1;">{{ currentBulkReq.email || 'N/A' }}</span></div>
              <div class="info-row" style="display: flex; font-size: 0.82rem;"><span class="label" style="width: 110px; color: #374151;">Address</span><span class="separator" style="width: 15px;">:</span><span class="value" style="flex: 1;">{{ currentBulkReq.address || 'Warangal, Telangana' }}</span></div>
            </div>
          </div>
          <div class="details-box" style="border: 1.5px solid #0052B4; border-radius: 8px; overflow: hidden; background: #ffffff;">
            <div class="box-header" style="background: #DCEBFB !important; color: #0047BA !important; font-weight: 900; font-size: 0.88rem; padding: 6px 12px; border-bottom: 1px solid #0052B4;">INVOICE DETAILS</div>
            <div class="box-body" style="padding: 10px 12px; display: flex; flex-direction: column; gap: 5px;">
              <div class="info-row" style="display: flex; font-size: 0.82rem;"><span class="label" style="width: 110px; color: #374151;">Invoice No.</span><span class="separator" style="width: 15px;">:</span><span class="value font-mono" style="flex: 1; font-family: monospace;">SR/2026-27/{{ String(currentBulkReq.id).padStart(4,'0') }}</span></div>
              <div class="info-row" style="display: flex; font-size: 0.82rem;"><span class="label" style="width: 110px; color: #374151;">Invoice Date</span><span class="separator" style="width: 15px;">:</span><span class="value" style="flex: 1;">{{ currentBulkReq.createdAt ? String(currentBulkReq.createdAt).substring(0,10) : '2026-05-26' }}</span></div>
              <div class="info-row" style="display: flex; font-size: 0.82rem;"><span class="label" style="width: 110px; color: #374151;">Payment Mode</span><span class="separator" style="width: 15px;">:</span><span class="value" style="flex: 1;">{{ (currentBulkReq.payment_method || 'UPI').toUpperCase() }}</span></div>
              <div class="info-row" style="display: flex; font-size: 0.82rem;"><span class="label" style="width: 110px; color: #374151;">UTR Number</span><span class="separator" style="width: 15px;">:</span><span class="value font-mono" style="flex: 1; font-family: monospace;">{{ currentBulkReq.utr_number || currentBulkReq.utr || '412345678901' }}</span></div>
              <div class="info-row" style="display: flex; font-size: 0.82rem; align-items: center;"><span class="label" style="width: 110px; color: #374151;">Status</span><span class="separator" style="width: 15px;">:</span><span class="badge-paid" style="background: #008744; color: white; font-weight: 900; font-size: 0.75rem; padding: 2px 14px; border-radius: 10px;">PAID</span></div>
            </div>
          </div>
        </div>

        <!-- SERVICE TABLE -->
        <div class="invoice-table-block" style="margin-bottom: 1.25rem; border: 1.5px solid #0052B4; border-radius: 8px; overflow: hidden;">
          <table class="items-table" style="width: 100%; border-collapse: collapse;">
            <thead>
              <tr>
                <th style="background: #0047BA !important; color: white !important; padding: 8px 10px; font-size: 0.82rem; font-weight: 800; width: 8%;">S.No.</th>
                <th style="background: #0047BA !important; color: white !important; padding: 8px 10px; font-size: 0.82rem; font-weight: 800; width: 52%;">DESCRIPTION OF SERVICE</th>
                <th style="background: #0047BA !important; color: white !important; padding: 8px 10px; font-size: 0.82rem; font-weight: 800; width: 10%;">QTY.</th>
                <th style="background: #0047BA !important; color: white !important; padding: 8px 10px; font-size: 0.82rem; font-weight: 800; width: 15%; text-align: right;">UNIT PRICE (₹)</th>
                <th style="background: #0047BA !important; color: white !important; padding: 8px 10px; font-size: 0.82rem; font-weight: 800; width: 15%; text-align: right;">AMOUNT (₹)</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td style="text-align: center; font-weight: 800; padding: 12px 10px; border-right: 1.5px solid #0052B4;">1</td>
                <td style="padding: 12px 10px; border-right: 1.5px solid #0052B4;">
                  <strong style="font-size: 0.9rem; font-weight: 800; color: #000;">Online Application & Processing Service</strong>
                  <div style="font-size: 0.78rem; color: #4b5563; margin-top: 3px;">(Application form filling, document verification, online submission and follow-up support)</div>
                </td>
                <td style="text-align: center; font-weight: 800; padding: 12px 10px; border-right: 1.5px solid #0052B4;">1</td>
                <td style="text-align: right; font-weight: 800; padding: 12px 10px; border-right: 1.5px solid #0052B4;">{{ parseFloat(currentBulkReq.amount || 1200).toFixed(2) }}</td>
                <td style="text-align: right; font-weight: 800; padding: 12px 10px;">{{ parseFloat(currentBulkReq.amount || 1200).toFixed(2) }}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- SUMMARY & TOTALS -->
        <div class="middle-summary-grid" style="display: grid; grid-template-columns: 1.3fr 1fr; gap: 1.25rem; margin-bottom: 1.25rem;">
          <div class="left-boxes-column" style="display: flex; flex-direction: column; gap: 0.75rem;">
            <div class="tinted-box" style="background: #EBF4FF; border: 1px solid #B8D5FA; border-radius: 8px; padding: 8px 12px;">
              <div class="box-title" style="font-size: 0.85rem; font-weight: 900; color: #0047BA; margin-bottom: 4px;">Amount in Words :</div>
              <div class="amount-in-words" style="font-size: 0.95rem; font-weight: 900; color: #000000;">{{ getBulkAmountInWords(currentBulkReq.amount) }}</div>
            </div>
            <div class="tinted-box" style="background: #EBF4FF; border: 1px solid #B8D5FA; border-radius: 8px; padding: 8px 12px;">
              <div class="box-title" style="font-size: 0.85rem; font-weight: 900; color: #0047BA; margin-bottom: 4px;">Service Purpose / Reference</div>
              <div class="purpose-text" style="font-size: 0.8rem; color: #374151; line-height: 1.35;">This amount is for the online application service provided to the customer as per their request.</div>
            </div>
          </div>
          <div class="right-totals-column" style="border: 1.5px solid #0052B4; border-radius: 8px; overflow: hidden;">
            <table class="totals-table" style="width: 100%; border-collapse: collapse;">
              <tr><td style="padding: 7px 10px; font-size: 0.85rem; color: #374151;">Sub Total</td><td style="text-align: right; width: 25px; color: #374151;">₹</td><td style="text-align: right; font-weight: 800; width: 90px;">{{ parseFloat(currentBulkReq.amount || 1200).toFixed(2) }}</td></tr>
              <tr><td style="padding: 7px 10px; font-size: 0.85rem; color: #374151;">Discount</td><td style="text-align: right; width: 25px; color: #374151;">₹</td><td style="text-align: right; font-weight: 800; width: 90px;">0.00</td></tr>
              <tr><td style="padding: 7px 10px; font-size: 0.85rem; font-weight: 700; color: #374151;">Total Amount</td><td style="text-align: right; width: 25px; font-weight: 700; color: #374151;">₹</td><td style="text-align: right; font-weight: 800; width: 90px;">{{ parseFloat(currentBulkReq.amount || 1200).toFixed(2) }}</td></tr>
              <tr style="background: #0047BA !important;"><td style="padding: 7px 10px; font-size: 0.95rem; font-weight: 900; color: white !important;">Grand Total</td><td style="text-align: right; width: 25px; font-weight: 900; color: white !important;">₹</td><td style="text-align: right; font-weight: 900; width: 90px; color: white !important;">{{ parseFloat(currentBulkReq.amount || 1200).toFixed(2) }}</td></tr>
            </table>
          </div>
        </div>

        <!-- FOOTER & AUTHORISED SIGNATORY -->
        <div class="footer-sign-section" style="display: grid; grid-template-columns: 1.2fr 1fr; gap: 1.25rem; align-items: flex-end; margin-top: 0.5rem; padding-bottom: 2rem;">
          <div class="terms-column">
            <div class="terms-title" style="font-size: 0.85rem; font-weight: 900; color: #0047BA; margin-bottom: 4px;">Terms & Conditions :</div>
            <ol class="terms-list" style="margin: 0 0 1rem 0; padding-left: 1.1rem; font-size: 0.75rem; color: #374151; line-height: 1.45;">
              <li>This is a computer generated invoice.</li>
              <li>Services once processed will not be cancelled or refunded.</li>
              <li>Please verify the details before making the payment.</li>
              <li>All disputes are subject to Warangal Jurisdiction.</li>
            </ol>
            <div class="thank-you-block" style="margin-top: 0.75rem;">
              <div class="thank-you-script" style="font-family: 'Alex Brush', cursive; font-size: 2.2rem; color: #0047BA; line-height: 1;">Thank You!</div>
              <div class="thank-you-sub" style="font-size: 0.8rem; font-weight: 800; color: #111827; margin-top: 4px;">For Your Business</div>
            </div>
          </div>
          <div class="stamp-column" style="display: flex; flex-direction: column; align-items: center; justify-content: flex-end;">
            <div class="stamp-wrapper" style="position: relative; width: 140px; height: 140px; margin-bottom: 6px;">
              <img :src="signatureImg" alt="Rajesh Signature" class="signature-overlay-img" style="position: absolute; top: 40%; left: 50%; transform: translate(-50%, -50%); width: 250px; height: auto; pointer-events: none; mix-blend-mode: multiply;" />
            </div>
            <div class="signatory-line-box" style="width: 180px; text-align: center;">
              <div class="sign-line" style="height: 2px; background: #0047BA; margin-bottom: 4px;"></div>
              <div class="signatory-text" style="font-size: 0.82rem; font-weight: 900; color: #0047BA;">AUTHORISED SIGNATORY</div>
              <div style="font-size: 0.75rem; font-weight: 800; color: #111827;">SR DIGITAL SEVA</div>
            </div>
          </div>
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
    approvedRequestsCount: { type: Number, default: 0 },
    rejectedRequestsCount: { type: Number, default: 0 },
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
      bulkMode: 'MONTH', // 'MONTH' or 'CUSTOM'
      bulkMonth: new Date().toISOString().substring(0, 7),
      bulkSearchQuery: '',
      bulkFromDate: '',
      bulkToDate: '',
      bulkAmountFilter: '',
      isGeneratingBulk: false,
      bulkProgress: 0,
      bulkTotal: 0,
      currentBulkReq: null
    };
  },
  computed: {
    calcPendingCount() {
      if (typeof this.pendingRequestsCount === 'number' && this.pendingRequestsCount > 0) return this.pendingRequestsCount;
      return (this.fundRequests || []).filter(r => (r.status || '').toUpperCase() === 'PENDING').length;
    },
    calcApprovedCount() {
      if (typeof this.approvedRequestsCount === 'number' && this.approvedRequestsCount > 0) return this.approvedRequestsCount;
      return (this.fundRequests || []).filter(r => (r.status || '').toUpperCase() === 'APPROVED').length;
    },
    calcRejectedCount() {
      if (typeof this.rejectedRequestsCount === 'number' && this.rejectedRequestsCount > 0) return this.rejectedRequestsCount;
      return (this.fundRequests || []).filter(r => (r.status || '').toUpperCase() === 'REJECTED').length;
    },
    totalApprovedVolume() {
      return (this.fundRequests || [])
        .filter(r => (r.status || '').toUpperCase() === 'APPROVED')
        .reduce((sum, r) => sum + (parseFloat(r.amount) || 0), 0);
    },
    eligibleBulkRequests() {
      return (this.fundRequests || []).filter(req => {
        if ((req.status || '').toUpperCase() !== 'APPROVED') return false;

        if (this.bulkMode === 'MONTH') {
          if (!this.bulkMonth) return true;
          const reqMonth = req.createdAt ? new Date(req.createdAt).toISOString().substring(0, 7) : String(req.date || '').substring(0, 7);
          return reqMonth === this.bulkMonth;
        }

        if (this.bulkMode === 'CUSTOM') {
          // 1. Search Query filter (Member Name / Mobile / Email / Sponsor Code / User Code / UTR / Request ID / User ID)
          const q = (this.bulkSearchQuery || '').toLowerCase().trim();
          if (q) {
            const matches = 
              (req.fullName && req.fullName.toLowerCase().includes(q)) ||
              (req.mobileNumber && req.mobileNumber.toLowerCase().includes(q)) ||
              (req.email && req.email.toLowerCase().includes(q)) ||
              (req.user_code && req.user_code.toLowerCase().includes(q)) ||
              (req.sponsor_code && req.sponsor_code.toLowerCase().includes(q)) ||
              (req.utr_number && req.utr_number.toLowerCase().includes(q)) ||
              (req.utr && req.utr.toLowerCase().includes(q)) ||
              (req.id && String(req.id).toLowerCase().includes(q)) ||
              (req.user_id && String(req.user_id).toLowerCase().includes(q));
            if (!matches) return false;
          }

          // 2. Date Range filter (From Date - To Date)
          const reqDateStr = req.createdAt ? new Date(req.createdAt).toISOString().substring(0, 10) : String(req.date || '').substring(0, 10);
          if (this.bulkFromDate && reqDateStr < this.bulkFromDate) return false;
          if (this.bulkToDate && reqDateStr > this.bulkToDate) return false;

          // 3. Amount filter
          if (this.bulkAmountFilter) {
            const reqAmt = Math.round(parseFloat(req.amount || 0));
            const filterAmt = Math.round(parseFloat(this.bulkAmountFilter));
            if (reqAmt !== filterAmt) return false;
          }

          return true;
        }

        return true;
      });
    },
    bulkTotalVolume() {
      return this.eligibleBulkRequests.reduce((sum, r) => sum + (parseFloat(r.amount) || 0), 0);
    }
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
    getBulkAmountInWords(amount) {
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
        if (hundredVal > 0) str += singleDigits[hundredVal] + ' Hundred';
        if (remainder > 0) {
          if (str !== '') str += ' ';
          str += convertTwoDigits(remainder);
        }
        return str;
      }

      let words = '';
      let remaining = num;

      if (Math.floor(remaining / 10000000) > 0) {
        words += convertTwoDigits(Math.floor(remaining / 10000000)) + ' Crore ';
        remaining %= 10000000;
      }

      if (Math.floor(remaining / 100000) > 0) {
        words += convertTwoDigits(Math.floor(remaining / 100000)) + ' Lakh ';
        remaining %= 100000;
      }

      if (Math.floor(remaining / 1000) > 0) {
        words += convertTwoDigits(Math.floor(remaining / 1000)) + ' Thousand ';
        remaining %= 1000;
      }

      if (remaining > 0) {
        words += convertThreeDigits(remaining);
      }

      return 'Rupees ' + words.trim() + ' Only';
    },
    async generateBulkZip() {
      const eligible = this.eligibleBulkRequests;

      if (eligible.length === 0) {
        alert('No matching approved fund requests found for download.');
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
          await new Promise(resolve => setTimeout(resolve, 60));

          const element = this.$refs.bulkPaper;
          const opt = {
            margin:       [4, 4, 4, 4],
            filename:     `Invoice_${req.mobileNumber || req.user_id}_REQ${req.id}.pdf`,
            image:        { type: 'jpeg', quality: 0.98 },
            html2canvas:  { 
              scale: 2, 
              useCORS: true, 
              logging: false, 
              backgroundColor: '#ffffff',
              scrollX: 0,
              scrollY: 0,
              width: 794
            },
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
        const fileSuffix = this.bulkMode === 'MONTH' ? (this.bulkMonth || 'All') : 'Custom_Filtered';
        downloadLink.download = `SR_Digital_Seva_Invoices_${fileSuffix}.zip`;
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
