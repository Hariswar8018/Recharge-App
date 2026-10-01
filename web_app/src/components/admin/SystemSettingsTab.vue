<template>
  <div class="settings-pane-wrapper">
    <!-- 1. GENERAL SYSTEM SETTINGS TAB (currentTab === 'settings') -->
    <div v-if="currentTab === 'settings'" class="settings-pane">
      <div class="table-card" style="margin-bottom: 1.5rem;">
        <div class="card-title-row">
          <h3>🖼️ UPI QR Code Image & Storage Settings</h3>
        </div>
        <p class="card-desc">Upload payment QR code to local cloud/MilesWeb hosting or link external image URL for Add Money deposits.</p>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin-top: 1.25rem;">
          <div>
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155; display: block; margin-bottom: 8px;">QR Image Source</label>
            <div style="display: flex; gap: 12px; margin-bottom: 1rem;">
              <label style="display: flex; align-items: center; gap: 6px; font-size: 0.85rem; font-weight: 700; cursor: pointer;">
                <input type="radio" value="file" v-model="qrStorageOptionLocal" /> 📁 Upload File
              </label>
              <label style="display: flex; align-items: center; gap: 6px; font-size: 0.85rem; font-weight: 700; cursor: pointer;">
                <input type="radio" value="url" v-model="qrStorageOptionLocal" /> 🔗 External URL
              </label>
            </div>

            <div v-if="qrStorageOptionLocal === 'file'" style="margin-bottom: 1rem;">
              <input type="file" ref="qrFileInput" accept="image/*" @change="$emit('qr-file-change', $event)" style="font-size: 0.85rem;" />
            </div>
            <div v-else style="margin-bottom: 1rem;">
              <input type="text" v-model="systemSettings.upi_qr_url" placeholder="https://domain.com/uploads/qr.jpg" class="input-styled" style="width: 100%; box-sizing: border-box;" />
            </div>

            <button @click="$emit('upload-qr')" :disabled="uploadingQr" style="background: #2563eb; color: white; border: none; padding: 0.65rem 1.25rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
              {{ uploadingQr ? 'Saving...' : '💾 Save QR Settings' }}
            </button>

            <div v-if="qrUploadMsg" :style="{ color: qrUploadSuccess ? '#16a34a' : '#ef4444', fontSize: '0.85rem', marginTop: '0.75rem', fontWeight: 'bold' }">
              {{ qrUploadMsg }}
            </div>
          </div>

          <div style="text-align: center; background: #f8fafc; padding: 1rem; border-radius: 10px; border: 1px dashed #cbd5e1;">
            <div style="font-weight: 700; font-size: 0.85rem; color: #475569; margin-bottom: 8px;">Active UPI QR Code Preview</div>
            <img v-if="systemSettings.upi_qr_url" :src="systemSettings.upi_qr_url" alt="UPI QR Code" style="max-width: 180px; max-height: 180px; border-radius: 8px; border: 1px solid #e2e8f0;" />
            <div v-else style="color: #64748b; font-size: 0.82rem; padding: 2rem;">No QR Image Uploaded</div>
          </div>
        </div>
      </div>

      <!-- MAIN SYSTEM SETTINGS FORM -->
      <div class="table-card">
        <div class="card-title-row">
          <h3>⚙️ Global App System Settings & Plan Parameters</h3>
          <button @click="$emit('save-system-settings')" :disabled="savingSettings" style="background: #16a34a; color: white; border: none; padding: 0.65rem 1.5rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            💾 {{ savingSettings ? 'Saving...' : 'Save All System Settings' }}
          </button>
        </div>

        <div class="form-grid-2" style="margin-top: 1.25rem; display: grid; grid-template-columns: 1fr 1fr; gap: 1.25rem;">
          <div class="form-group">
            <label>Direct Sponsor Income (₹)</label>
            <input type="number" v-model="systemSettings.direct_income" class="input-styled" />
          </div>
          <div class="form-group">
            <label>Global Single Leg Pool Income (₹)</label>
            <input type="number" v-model="systemSettings.single_leg_pool_income" class="input-styled" />
          </div>
          <div class="form-group">
            <label>Company Maintenance Charge (₹)</label>
            <input type="number" v-model="systemSettings.company_maintenance_charge" class="input-styled" />
          </div>
          <div class="form-group">
            <label>Withdrawal Deduction (%)</label>
            <input type="number" v-model="systemSettings.withdrawal_deduction_percent" class="input-styled" />
          </div>
          <div class="form-group">
            <label>Minimum Withdrawal Amount (₹)</label>
            <input type="number" v-model="systemSettings.min_withdrawal" class="input-styled" />
          </div>
          <div class="form-group">
            <label>Withdrawal Allowed Days</label>
            <input type="text" v-model="systemSettings.withdrawal_days" placeholder="Monday, Wednesday, Friday" class="input-styled" />
          </div>
        </div>

        <div v-if="saveSettingsMsg" :style="{ color: saveSettingsSuccess ? '#16a34a' : '#ef4444', fontSize: '0.88rem', marginTop: '1.25rem', fontWeight: 'bold' }">
          {{ saveSettingsMsg }}
        </div>
      </div>
    </div>

    <!-- 2. SECTION 5: ADD MONEY SETTINGS (currentTab === 'sec_add_money') -->
    <div v-else-if="currentTab === 'sec_add_money'" class="section-settings-pane">
      <div class="section-banner" style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 12px; padding: 1.25rem; margin-bottom: 1.25rem; display: flex; justify-content: space-between; align-items: center;">
        <div style="display: flex; align-items: center; gap: 12px;">
          <div style="font-size: 1.8rem; background: #2563eb; color: white; border-radius: 50%; width: 44px; height: 44px; display: flex; align-items: center; justify-content: center;">💳</div>
          <div>
            <h2 style="margin: 0; font-size: 1.15rem; font-weight: 800; color: #1e40af;">5. Add Money / Fund Request Settings</h2>
            <p style="margin: 2px 0 0; font-size: 0.82rem; color: #3b82f6;">Configure add money page settings, limits, QR code, and instructions.</p>
          </div>
        </div>
        <button @click="$emit('switch-tab', 'requests')" style="background: #2563eb; color: white; border: none; padding: 0.6rem 1.25rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
          📥 View Fund Requests List ({{ pendingRequestsCount }})
        </button>
      </div>

      <div class="table-card">
        <div class="card-title-row">
          <h3>💳 Payment Options & QR Configuration</h3>
          <button @click="$emit('save-system-settings')" style="background: #16a34a; color: white; border: none; padding: 0.6rem 1.25rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            💾 Save Settings
          </button>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 1.25rem; margin-top: 1rem;">
          <div>
            <label style="font-size: 0.85rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">UPI QR Code URL</label>
            <input type="text" v-model="systemSettings.upi_qr_url" placeholder="https://domain.com/qr.jpg" class="input-styled" style="width: 100%; box-sizing: border-box;" />
          </div>
          <div>
            <label style="font-size: 0.85rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">UPI ID / VPA</label>
            <input type="text" v-model="systemSettings.upi_id" placeholder="srdigitalseva@ybl" class="input-styled" style="width: 100%; box-sizing: border-box;" />
          </div>
        </div>
      </div>
    </div>

    <!-- 3. GENERIC SECTION CHECKLIST CONFIG CARD (for sec_home, sec_business_income, sec_global_cycle, sec_app_share, sec_captcha, sec_login, sec_registration, sec_otp, sec_bank_verification, sec_cashout, sec_subscription) -->
    <div v-else class="section-settings-pane">
      <div class="table-card">
        <div class="card-title-row">
          <h3>⚙️ {{ getSectionTitle(currentTab) }} Configuration</h3>
          <button @click="$emit('save-system-settings')" :disabled="savingSettings" style="background: #16a34a; color: white; border: none; padding: 0.65rem 1.5rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            💾 {{ savingSettings ? 'Saving...' : 'Save Configuration' }}
          </button>
        </div>
        <p class="card-desc">Configure visibility, rule mode, and notice text for {{ getSectionTitle(currentTab) }}.</p>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.25rem; margin-top: 1.25rem;">
          <div class="form-group">
            <label>Section Visibility</label>
            <select v-model="systemSettings[currentTab + '_visibility']" class="input-styled select-styled">
              <option value="Show">👁️ Show on Mobile App</option>
              <option value="Hide">🙈 Hide / Lock Section</option>
            </select>
          </div>

          <div class="form-group">
            <label>Rule / Mode</label>
            <select v-model="systemSettings[currentTab + '_rule_mode']" class="input-styled select-styled">
              <option value="Enabled (Standard)">🟢 Enabled (Standard)</option>
              <option value="Disabled (Maintenance)">🔴 Maintenance Mode</option>
              <option value="Strict Verification">🔒 Strict Verification Required</option>
            </select>
          </div>
        </div>

        <div class="form-group" style="margin-top: 1.25rem;">
          <label>Maintenance Announcement Notice (Shown to Users)</label>
          <input type="text" v-model="systemSettings[currentTab + '_notice']" placeholder="e.g. Under maintenance. Will re-open shortly." class="input-styled" style="width: 100%; box-sizing: border-box;" />
        </div>

        <div v-if="saveSettingsMsg" :style="{ color: saveSettingsSuccess ? '#16a34a' : '#ef4444', fontSize: '0.88rem', marginTop: '1.25rem', fontWeight: 'bold' }">
          {{ saveSettingsMsg }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SystemSettingsTab',
  props: {
    currentTab: { type: String, default: 'settings' },
    systemSettings: { type: Object, required: true },
    pendingRequestsCount: { type: Number, default: 0 },
    qrStorageOption: { type: String, default: 'file' },
    uploadingQr: { type: Boolean, default: false },
    qrUploadMsg: { type: String, default: '' },
    qrUploadSuccess: { type: Boolean, default: false },
    savingSettings: { type: Boolean, default: false },
    saveSettingsMsg: { type: String, default: '' },
    saveSettingsSuccess: { type: Boolean, default: false }
  },
  data() {
    return {
      qrStorageOptionLocal: this.qrStorageOption
    };
  },
  watch: {
    qrStorageOption(newVal) { this.qrStorageOptionLocal = newVal; }
  },
  methods: {
    getSectionTitle(tabKey) {
      const titles = {
        sec_home: '1. Member Dashboard / Home',
        sec_users: '2. Registered App Users',
        sec_edit_user: '3. Edit User Details',
        sec_teams: '4. Member Teams Tree',
        sec_business_income: '5. Income & Single Leg',
        sec_global_cycle: '6. Global Single Leg Pool',
        sec_transactions: '7. Platform Transactions',
        sec_add_money: '8. Add Money Settings',
        sec_requests: '9. Add Money Requests',
        sec_subscription: '10. Subscription & Plans',
        sec_bank_verification: '11. Bank Verification',
        sec_cashout: '12. Cashout & Withdrawals',
        sec_app_share: '13. App Share & Referral',
        sec_captcha: '14. CAPTCHA Work Rules',
        sec_login: '15. App Login Settings',
        sec_registration: '16. Registration Rules',
        sec_otp: '17. OTP / Security Rules',
        sec_support: '18. Support & Contact'
      };
      return titles[tabKey] || 'App Feature';
    }
  }
};
</script>
