<template>
  <div class="settings-pane-wrapper" style="padding: 1.25rem; max-width: 100%; box-sizing: border-box;">
    <!-- 1. GENERAL SYSTEM SETTINGS TAB & INCOME / SINGLE LEG POOL RULES -->
    <div v-if="currentTab === 'settings' || currentTab === 'sec_business_income' || currentTab === 'sec_global_cycle'" class="settings-pane">
      <!-- MAIN SYSTEM SETTINGS FORM -->
      <div class="table-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03); margin-bottom: 1.5rem;">
        <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.75rem;">
          <h3 style="margin: 0; font-size: 1.2rem; font-weight: 800; color: #0f172a;">⚙️ Global App System Settings & Plan Parameters</h3>
          <button @click="$emit('save-system-settings')" :disabled="savingSettings" style="background: #16a34a; color: white; border: none; padding: 0.65rem 1.5rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            💾 {{ savingSettings ? 'Saving...' : 'Save All System Settings' }}
          </button>
        </div>

        <div class="form-grid-2" style="margin-top: 1.25rem; display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1.25rem;">
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Activation / Join Amount (₹)</label>
            <input type="number" v-model="systemSettings.join_amount" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px;" />
          </div>
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Top-Up / Re-Entry Amount (₹)</label>
            <input type="number" v-model="systemSettings.top_up_amount" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px;" />
          </div>
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Direct Sponsor Income (₹)</label>
            <input type="number" v-model="systemSettings.direct_income" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px;" />
          </div>
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Global Single Leg Pool Income (₹)</label>
            <input type="number" v-model="systemSettings.single_leg_pool_income" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px;" />
          </div>
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Company Maintenance Charge (₹)</label>
            <input type="number" v-model="systemSettings.company_maintenance_charge" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px;" />
          </div>
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Withdrawal Deduction (%)</label>
            <input type="number" v-model="systemSettings.withdrawal_deduction_percent" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px;" />
          </div>
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Minimum Withdrawal Amount (₹)</label>
            <input type="number" v-model="systemSettings.min_withdrawal" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px;" />
          </div>
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Withdrawal Allowed Days</label>
            <input type="text" v-model="systemSettings.withdrawal_days" placeholder="Monday, Wednesday, Friday" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px;" />
          </div>
        </div>

        <!-- 6-LEVEL SINGLE LEG INCOME PLAN MATRIX -->
        <div style="margin-top: 2rem; border-top: 1px solid #f1f5f9; padding-top: 1.5rem;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.5rem;">
            <div>
              <h4 style="margin: 0; font-size: 1.05rem; font-weight: 800; color: #0f172a;">📊 Single Leg Income Plan — 6 Levels Matrix</h4>
              <p style="margin: 2px 0 0; font-size: 0.82rem; color: #64748b;">Configure required members and payout amounts for each of the 6 single leg pool levels.</p>
            </div>
            <span style="background: #eff6ff; color: #2563eb; font-weight: 800; font-size: 0.82rem; padding: 4px 10px; border-radius: 12px; border: 1px solid #bfdbfe;">
              Max 126 Members / Cycle
            </span>
          </div>

          <div class="table-container" style="overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px;">
            <table class="nice-table" style="width: 100%; border-collapse: collapse; text-align: left; font-size: 0.88rem;">
              <thead>
                <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 700;">
                  <th style="padding: 0.75rem 1rem;">Level</th>
                  <th style="padding: 0.75rem 1rem;">Level Structure</th>
                  <th style="padding: 0.75rem 1rem;">Required Members</th>
                  <th style="padding: 0.75rem 1rem;">Level Payout Amount (₹)</th>
                </tr>
              </thead>
              <tbody>
                <tr style="border-bottom: 1px solid #f1f5f9;">
                  <td style="padding: 0.75rem 1rem; font-weight: 800; color: #2563eb;">Level 1</td>
                  <td style="padding: 0.75rem 1rem; color: #64748b;">2 Members</td>
                  <td style="padding: 0.75rem 1rem;"><input type="number" v-model="systemSettings.level_1_members" class="input-styled" style="width: 110px; padding: 0.4rem 0.6rem; border-radius: 6px; border: 1px solid #cbd5e1;" /></td>
                  <td style="padding: 0.75rem 1rem;"><input type="number" v-model="systemSettings.level_1_income" class="input-styled" style="width: 140px; padding: 0.4rem 0.6rem; border-radius: 6px; border: 1px solid #cbd5e1;" /></td>
                </tr>
                <tr style="border-bottom: 1px solid #f1f5f9;">
                  <td style="padding: 0.75rem 1rem; font-weight: 800; color: #2563eb;">Level 2</td>
                  <td style="padding: 0.75rem 1rem; color: #64748b;">4 Members</td>
                  <td style="padding: 0.75rem 1rem;"><input type="number" v-model="systemSettings.level_2_members" class="input-styled" style="width: 110px; padding: 0.4rem 0.6rem; border-radius: 6px; border: 1px solid #cbd5e1;" /></td>
                  <td style="padding: 0.75rem 1rem;"><input type="number" v-model="systemSettings.level_2_income" class="input-styled" style="width: 140px; padding: 0.4rem 0.6rem; border-radius: 6px; border: 1px solid #cbd5e1;" /></td>
                </tr>
                <tr style="border-bottom: 1px solid #f1f5f9;">
                  <td style="padding: 0.75rem 1rem; font-weight: 800; color: #2563eb;">Level 3</td>
                  <td style="padding: 0.75rem 1rem; color: #64748b;">8 Members</td>
                  <td style="padding: 0.75rem 1rem;"><input type="number" v-model="systemSettings.level_3_members" class="input-styled" style="width: 110px; padding: 0.4rem 0.6rem; border-radius: 6px; border: 1px solid #cbd5e1;" /></td>
                  <td style="padding: 0.75rem 1rem;"><input type="number" v-model="systemSettings.level_3_income" class="input-styled" style="width: 140px; padding: 0.4rem 0.6rem; border-radius: 6px; border: 1px solid #cbd5e1;" /></td>
                </tr>
                <tr style="border-bottom: 1px solid #f1f5f9;">
                  <td style="padding: 0.75rem 1rem; font-weight: 800; color: #2563eb;">Level 4</td>
                  <td style="padding: 0.75rem 1rem; color: #64748b;">16 Members</td>
                  <td style="padding: 0.75rem 1rem;"><input type="number" v-model="systemSettings.level_4_members" class="input-styled" style="width: 110px; padding: 0.4rem 0.6rem; border-radius: 6px; border: 1px solid #cbd5e1;" /></td>
                  <td style="padding: 0.75rem 1rem;"><input type="number" v-model="systemSettings.level_4_income" class="input-styled" style="width: 140px; padding: 0.4rem 0.6rem; border-radius: 6px; border: 1px solid #cbd5e1;" /></td>
                </tr>
                <tr style="border-bottom: 1px solid #f1f5f9;">
                  <td style="padding: 0.75rem 1rem; font-weight: 800; color: #2563eb;">Level 5</td>
                  <td style="padding: 0.75rem 1rem; color: #64748b;">32 Members</td>
                  <td style="padding: 0.75rem 1rem;"><input type="number" v-model="systemSettings.level_5_members" class="input-styled" style="width: 110px; padding: 0.4rem 0.6rem; border-radius: 6px; border: 1px solid #cbd5e1;" /></td>
                  <td style="padding: 0.75rem 1rem;"><input type="number" v-model="systemSettings.level_5_income" class="input-styled" style="width: 140px; padding: 0.4rem 0.6rem; border-radius: 6px; border: 1px solid #cbd5e1;" /></td>
                </tr>
                <tr>
                  <td style="padding: 0.75rem 1rem; font-weight: 800; color: #2563eb;">Level 6</td>
                  <td style="padding: 0.75rem 1rem; color: #64748b;">64 Members</td>
                  <td style="padding: 0.75rem 1rem;"><input type="number" v-model="systemSettings.level_6_members" class="input-styled" style="width: 110px; padding: 0.4rem 0.6rem; border-radius: 6px; border: 1px solid #cbd5e1;" /></td>
                  <td style="padding: 0.75rem 1rem;"><input type="number" v-model="systemSettings.level_6_income" class="input-styled" style="width: 140px; padding: 0.4rem 0.6rem; border-radius: 6px; border: 1px solid #cbd5e1;" /></td>
                </tr>
              </tbody>
            </table>
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

      <div class="table-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
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

    <!-- 3. GENERIC SECTION CHECKLIST CONFIG CARD -->
    <div v-else class="section-settings-pane">
      <div class="table-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
        <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
          <h3 style="margin: 0; font-size: 1.2rem; font-weight: 800; color: #0f172a;">⚙️ {{ getSectionTitle(currentTab) }} Configuration</h3>
          <button @click="$emit('save-system-settings')" :disabled="savingSettings" style="background: #16a34a; color: white; border: none; padding: 0.65rem 1.5rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            💾 {{ savingSettings ? 'Saving...' : 'Save Configuration' }}
          </button>
        </div>
        <p class="card-desc" style="margin: 4px 0 1rem; font-size: 0.83rem; color: #64748b;">Configure visibility, rule mode, and notice text for {{ getSectionTitle(currentTab) }}.</p>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.25rem; margin-top: 1.25rem;">
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Section Visibility</label>
            <select v-model="systemSettings[currentTab + '_visibility']" class="input-styled select-styled" style="width: 100%; padding: 0.65rem; border-radius: 8px;">
              <option value="Show">👁️ Show on Mobile App</option>
              <option value="Hide">🙈 Hide / Lock Section</option>
            </select>
          </div>

          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Rule / Mode</label>
            <select v-model="systemSettings[currentTab + '_rule_mode']" class="input-styled select-styled" style="width: 100%; padding: 0.65rem; border-radius: 8px;">
              <option value="Enabled (Standard)">🟢 Enabled (Standard)</option>
              <option value="Disabled (Maintenance)">🔴 Maintenance Mode</option>
              <option value="Strict Verification">🔒 Strict Verification Required</option>
            </select>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SystemSettingsTab',
  props: {
    systemSettings: { type: Object, default: () => ({}) },
    currentTab: { type: String, default: 'settings' },
    savingSettings: { type: Boolean, default: false },
    saveSettingsMsg: { type: String, default: '' },
    saveSettingsSuccess: { type: Boolean, default: false },
    uploadingQr: { type: Boolean, default: false },
    qrUploadMsg: { type: String, default: '' },
    qrUploadSuccess: { type: Boolean, default: false },
    pendingRequestsCount: { type: Number, default: 0 }
  },
  data() {
    return {
      qrStorageOptionLocal: 'file'
    };
  },
  methods: {
    getSectionTitle(tab) {
      const titles = {
        sec_home: '1. Home / Dashboard Banners',
        sec_team: '2. Team & Single-Leg Tree',
        sec_direct_members: '3. Direct Sponsored Members',
        sec_business_income: '4. Level & Business Income Rules',
        sec_global_cycle: '5. Single-Leg Global Cycle Rules',
        sec_app_share: '6. App Share & Referral Settings',
        sec_captcha: '7. Captcha Rewards Configuration',
        sec_login: '8. App Login Rules',
        sec_registration: '9. Registration Rules',
        sec_otp: '10. OTP & Security Rules'
      };
      return titles[tab] || 'Section';
    }
  }
};
</script>
