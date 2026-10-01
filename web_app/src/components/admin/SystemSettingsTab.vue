<template>
  <div class="settings-pane">
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
</template>

<script>
export default {
  name: 'SystemSettingsTab',
  props: {
    systemSettings: { type: Object, required: true },
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
  }
};
</script>
