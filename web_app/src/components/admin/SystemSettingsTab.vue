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

    <!-- 2. SECTION 5: ADD MONEY SETTINGS WITH QR UPLOAD & DATABASE SYNC (currentTab === 'sec_add_money') -->
    <div v-else-if="currentTab === 'sec_add_money'" class="section-settings-pane">
      <div class="section-banner" style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 12px; padding: 1.25rem; margin-bottom: 1.25rem; display: flex; justify-content: space-between; align-items: center;">
        <div style="display: flex; align-items: center; gap: 12px;">
          <div style="font-size: 1.8rem; background: #2563eb; color: white; border-radius: 50%; width: 44px; height: 44px; display: flex; align-items: center; justify-content: center;">💳</div>
          <div>
            <h2 style="margin: 0; font-size: 1.15rem; font-weight: 800; color: #1e40af;">5. Add Money & Payment QR Configuration</h2>
            <p style="margin: 2px 0 0; font-size: 0.82rem; color: #3b82f6;">Upload payment QR code image or external URL and configure UPI VPA for user deposits.</p>
          </div>
        </div>
        <button @click="$emit('switch-tab', 'requests')" style="background: #2563eb; color: white; border: none; padding: 0.6rem 1.25rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
          📥 View Fund Requests List ({{ pendingRequestsCount }})
        </button>
      </div>

      <!-- PAYMENT OPTIONS & QR UPLOAD CARD -->
      <div class="table-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03); margin-bottom: 1.5rem;">
        <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.75rem;">
          <h3 style="margin: 0; font-size: 1.2rem; font-weight: 800; color: #0f172a;">💳 Payment Options & QR Configuration</h3>
          <button @click="handleSaveAndUpload" style="background: #16a34a; color: white; border: none; padding: 0.65rem 1.25rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            💾 {{ savingSettings || uploadingQr ? 'Saving to Database...' : 'Save Settings to Database' }}
          </button>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin-top: 1rem;">
          <div>
            <!-- QR Source Mode Toggle -->
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155; display: block; margin-bottom: 8px;">QR Image Source</label>
            <div style="display: flex; gap: 12px; margin-bottom: 1rem;">
              <label style="display: flex; align-items: center; gap: 6px; font-size: 0.85rem; font-weight: 700; cursor: pointer;">
                <input type="radio" value="file" v-model="qrSourceOption" /> 📁 Upload Image File
              </label>
              <label style="display: flex; align-items: center; gap: 6px; font-size: 0.85rem; font-weight: 700; cursor: pointer;">
                <input type="radio" value="url" v-model="qrSourceOption" /> 🔗 External Image URL
              </label>
            </div>

            <!-- File Upload Option -->
            <div v-if="qrSourceOption === 'file'" style="margin-bottom: 1rem;">
              <label style="font-size: 0.83rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">Choose Image File</label>
              <input type="file" ref="qrFileInput" accept="image/*" @change="$emit('qr-file-change', $event)" style="font-size: 0.85rem; padding: 6px; background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 6px; width: 100%; box-sizing: border-box;" />
            </div>

            <!-- URL Option -->
            <div style="margin-bottom: 1rem;">
              <label style="font-size: 0.83rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">UPI QR Code Image URL</label>
              <input type="text" v-model="systemSettings.upi_qr_url" placeholder="https://domain.com/qr.jpg" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem 0.85rem; border-radius: 8px; border: 1px solid #cbd5e1;" />
            </div>

            <!-- UPI VPA ID -->
            <div>
              <label style="font-size: 0.83rem; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">UPI ID / VPA</label>
              <input type="text" v-model="systemSettings.upi_id" placeholder="srdigitalseva@ybl" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem 0.85rem; border-radius: 8px; border: 1px solid #cbd5e1;" />
            </div>
          </div>

          <!-- Live Preview Box -->
          <div style="text-align: center; background: #f8fafc; padding: 1.25rem; border-radius: 10px; border: 1px dashed #cbd5e1; display: flex; flex-direction: column; align-items: center; justify-content: center;">
            <div style="font-weight: 700; font-size: 0.85rem; color: #475569; margin-bottom: 8px;">Active Database QR Code Preview</div>
            <img v-if="systemSettings.upi_qr_url" :src="systemSettings.upi_qr_url" alt="UPI QR Code" style="max-width: 190px; max-height: 190px; border-radius: 8px; border: 1px solid #e2e8f0; object-fit: contain; background: white; padding: 6px;" />
            <div v-else style="color: #64748b; font-size: 0.82rem; padding: 2rem;">No QR Image Uploaded Yet</div>
            <span v-if="systemSettings.upi_id" style="margin-top: 8px; font-weight: 800; font-size: 0.83rem; color: #2563eb;">UPI: {{ systemSettings.upi_id }}</span>
          </div>
        </div>

        <div v-if="saveSettingsMsg || qrUploadMsg" style="margin-top: 1rem; font-weight: 700; font-size: 0.88rem;" :style="{ color: (saveSettingsSuccess || qrUploadSuccess) ? '#16a34a' : '#ef4444' }">
          {{ saveSettingsMsg || qrUploadMsg }}
        </div>
      </div>
    </div>

    <!-- 3. DEDICATED CAPTCHA WORK & REWARDS CONFIG CARD -->
    <div v-else-if="currentTab === 'sec_captcha'" class="section-settings-pane">
      <div class="table-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
        <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
          <h3 style="margin: 0; font-size: 1.2rem; font-weight: 800; color: #0f172a;">⚙️ 7. Captcha Rewards & Work Configuration</h3>
          <button @click="$emit('save-system-settings')" :disabled="savingSettings" style="background: #16a34a; color: white; border: none; padding: 0.65rem 1.5rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            💾 {{ savingSettings ? 'Saving...' : 'Save Configuration' }}
          </button>
        </div>
        <p class="card-desc" style="margin: 4px 0 1rem; font-size: 0.83rem; color: #64748b;">Configure Per-CAPTCHA reward income, work ON/OFF status, and maintenance notice messages.</p>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 1.25rem; margin-top: 1.25rem;">
          <!-- CAPTCHA Work ON/OFF -->
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155; display: block; margin-bottom: 4px;">CAPTCHA Work Status (ON / OFF)</label>
            <select v-model="systemSettings.captcha_enabled" class="input-styled select-styled" style="width: 100%; padding: 0.65rem; border-radius: 8px; border: 1px solid #cbd5e1;">
              <option value="true">🟢 ON - Captcha Work Active</option>
              <option value="false">🔴 OFF - Under Maintenance</option>
            </select>
          </div>

          <!-- Per-CAPTCHA Reward Income -->
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155; display: block; margin-bottom: 4px;">Per-CAPTCHA Reward Income (₹)</label>
            <input type="number" step="0.05" min="0.01" v-model="systemSettings.captcha_reward_amount" placeholder="0.50" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem; border-radius: 8px; border: 1px solid #cbd5e1; font-weight: 800; font-size: 1rem; color: #0f172a;" />
          </div>

          <!-- Maintenance Notice -->
          <div class="form-group" style="grid-column: 1 / -1;">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155; display: block; margin-bottom: 4px;">Maintenance Notice (Shown to Users when OFF)</label>
            <input type="text" v-model="systemSettings.captcha_maintenance_msg" placeholder="CAPTCHA Work is currently under maintenance. Please check back later." class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem; border-radius: 8px; border: 1px solid #cbd5e1;" />
          </div>
        </div>

        <!-- LIVE CALCULATION VERIFICATION BOX -->
        <div style="margin-top: 1.5rem; background: #f0fdf4; border: 1.5px solid #86efac; padding: 1.25rem; border-radius: 12px; display: flex; align-items: center; gap: 1rem;">
          <div style="font-size: 2rem;">🧮</div>
          <div>
            <strong style="color: #166534; font-size: 0.95rem; display: block;">Verification Calculation:</strong>
            <div style="font-size: 1.05rem; font-weight: 800; color: #15803d; margin-top: 2px;">
              ₹{{ parseFloat(systemSettings.captcha_reward_amount || '0.50').toFixed(2) }} × 10 successful CAPTCHAs = ₹{{ (parseFloat(systemSettings.captcha_reward_amount || '0.50') * 10).toFixed(2) }}
            </div>
            <p style="margin: 3px 0 0 0; font-size: 0.78rem; color: #166534;">
              Only successful captcha solves are counted and credited directly to the user's Main Wallet balance.
            </p>
          </div>
        </div>

        <div v-if="saveSettingsMsg" style="margin-top: 1rem; font-weight: 700; font-size: 0.88rem;" :style="{ color: saveSettingsSuccess ? '#16a34a' : '#ef4444' }">
          {{ saveSettingsMsg }}
        </div>
      </div>
    </div>

    <!-- 4. DEDICATED SUBSCRIPTION & PLANS CONFIG CARD -->
    <div v-else-if="currentTab === 'sec_subscription'" class="section-settings-pane">
      <div class="table-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
        <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.75rem;">
          <h3 style="margin: 0; font-size: 1.2rem; font-weight: 800; color: #0f172a;">💳 Subscription & Package Plans Configuration</h3>
          <button @click="$emit('save-system-settings')" :disabled="savingSettings" style="background: #16a34a; color: white; border: none; padding: 0.65rem 1.5rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            💾 {{ savingSettings ? 'Saving...' : 'Save Configuration' }}
          </button>
        </div>
        <p class="card-desc" style="margin: 4px 0 1rem; font-size: 0.83rem; color: #64748b;">Configure ₹1,200 package activation rules, mandatory subscription toggles, and package durations.</p>

        <!-- BEAUTIFUL TOGGLE SWITCH BOX FOR MANDATORY SUBSCRIPTION MODE -->
        <div style="background: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 12px; padding: 1.25rem; margin-top: 1.25rem; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1rem;">
          <div>
            <h4 style="margin: 0; font-size: 1rem; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px;">
              <span>🔑</span> Mandatory ₹1,200 ID Activation Mode
            </h4>
            <p style="margin: 4px 0 0; font-size: 0.83rem; color: #64748b;">Require users to complete ₹1,200 subscription top-up before unlocking referral earnings, withdraw & downline pool access.</p>
          </div>
          <label class="modern-toggle-switch">
            <input type="checkbox" v-model="systemSettings.subscription_required" :true-value="true" :false-value="false" />
            <span class="toggle-slider"></span>
            <span class="toggle-label-text">{{ systemSettings.subscription_required ? '🟢 MANDATORY' : '🔴 OPTIONAL' }}</span>
          </label>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1.25rem; margin-top: 1.25rem;">
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">ID Activation Package Price (₹)</label>
            <input type="number" v-model="systemSettings.join_amount" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem 0.85rem; border-radius: 8px; border: 1px solid #cbd5e1; font-weight: 800;" />
          </div>
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Subscription Duration (Days)</label>
            <input type="number" v-model="systemSettings.subscription_days" placeholder="365" class="input-styled" style="width: 100%; box-sizing: border-box; padding: 0.65rem 0.85rem; border-radius: 8px; border: 1px solid #cbd5e1;" />
          </div>
        </div>

        <div v-if="saveSettingsMsg" style="margin-top: 1rem; font-weight: 700; font-size: 0.88rem;" :style="{ color: saveSettingsSuccess ? '#16a34a' : '#ef4444' }">
          {{ saveSettingsMsg }}
        </div>
      </div>
    </div>

    <!-- 5. DEDICATED BANK VERIFICATION CONFIG CARD WITH USER AUDIT TABLE -->
    <div v-else-if="currentTab === 'sec_bank_verification'" class="section-settings-pane">
      <!-- CONFIG CARD WITH TOGGLE -->
      <div class="table-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03); margin-bottom: 1.5rem;">
        <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.75rem;">
          <h3 style="margin: 0; font-size: 1.2rem; font-weight: 800; color: #0f172a;">🏛️ Bank Account Verification Rules</h3>
          <button @click="$emit('save-system-settings')" :disabled="savingSettings" style="background: #16a34a; color: white; border: none; padding: 0.65rem 1.5rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            💾 {{ savingSettings ? 'Saving...' : 'Save Configuration' }}
          </button>
        </div>
        <p class="card-desc" style="margin: 4px 0 1rem; font-size: 0.83rem; color: #64748b;">Configure bank verification requirement toggles and review all member submitted bank details.</p>

        <!-- TOGGLE SWITCH BOX FOR BANK VERIFICATION REQUIREMENT -->
        <div style="background: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 12px; padding: 1.25rem; margin-top: 1rem; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1rem;">
          <div>
            <h4 style="margin: 0; font-size: 1rem; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px;">
              <span>🔒</span> Mandatory Bank Account Verification Status
            </h4>
            <p style="margin: 4px 0 0; font-size: 0.83rem; color: #64748b;">When ON, members must verify Account Holder Name, A/C Number, and IFSC Code before requesting withdrawal cashouts.</p>
          </div>
          <label class="modern-toggle-switch">
            <input type="checkbox" v-model="systemSettings.bank_verification_required" :true-value="true" :false-value="false" />
            <span class="toggle-slider"></span>
            <span class="toggle-label-text">{{ systemSettings.bank_verification_required ? '🟢 MANDATORY' : '⚪ OPTIONAL' }}</span>
          </label>
        </div>

        <div v-if="saveSettingsMsg" style="margin-top: 1rem; font-weight: 700; font-size: 0.88rem;" :style="{ color: saveSettingsSuccess ? '#16a34a' : '#ef4444' }">
          {{ saveSettingsMsg }}
        </div>
      </div>

      <!-- BELOW: VERIFIED BANK ACCOUNTS AUDIT TABLE -->
      <div class="table-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.5rem;">
          <div>
            <h4 style="margin: 0; font-size: 1.05rem; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px;">
              <span>📋</span> Member Submitted & Verified Bank Accounts
            </h4>
            <p style="margin: 2px 0 0; font-size: 0.82rem; color: #64748b;">Click on any member row or button below to immediately view and edit their full user profile.</p>
          </div>
          <span style="background: #f0fdf4; color: #166534; font-weight: 800; font-size: 0.82rem; padding: 4px 12px; border-radius: 12px; border: 1px solid #bbf7d0;">
            {{ verifiedBankUsers.length }} Verified Accounts
          </span>
        </div>

        <div v-if="verifiedBankUsers.length === 0" style="padding: 2.5rem; text-align: center; background: #f8fafc; border-radius: 8px; color: #64748b; font-weight: 600;">
          No member bank account records found in system database.
        </div>

        <div v-else class="table-container" style="overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px;">
          <table class="nice-table" style="width: 100%; border-collapse: collapse; text-align: left; font-size: 0.85rem;">
            <thead>
              <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 700;">
                <th style="padding: 10px 12px;">User ID</th>
                <th style="padding: 10px 12px;">Member Name</th>
                <th style="padding: 10px 12px;">Mobile Number</th>
                <th style="padding: 10px 12px;">Account Holder</th>
                <th style="padding: 10px 12px;">Bank Name</th>
                <th style="padding: 10px 12px;">Account Number</th>
                <th style="padding: 10px 12px;">IFSC Code</th>
                <th style="padding: 10px 12px;">Status</th>
                <th style="padding: 10px 12px; text-align: center;">Action</th>
              </tr>
            </thead>
            <tbody>
              <tr 
                v-for="u in verifiedBankUsers" 
                :key="u.id" 
                @click="$emit('open-edit-user', u)"
                style="border-bottom: 1px solid #f1f5f9; cursor: pointer; transition: background 0.15s ease;"
              >
                <td style="padding: 10px 12px; font-weight: 700; color: #2563eb;">#{{ u.id }}</td>
                <td style="padding: 10px 12px; font-weight: 800; color: #0f172a;">{{ u.fullName || 'Member' }}</td>
                <td style="padding: 10px 12px; color: #334155; font-weight: 600;">{{ u.mobileNumber }}</td>
                <td style="padding: 10px 12px; font-weight: 700;">{{ u.account_holder || 'N/A' }}</td>
                <td style="padding: 10px 12px;">🏛️ {{ u.bank_name || 'N/A' }}</td>
                <td style="padding: 10px 12px; font-weight: 700; color: #0f172a;">{{ u.account_no || 'N/A' }}</td>
                <td style="padding: 10px 12px; text-transform: uppercase; font-weight: 700; color: #2563eb;">{{ u.ifsc || 'N/A' }}</td>
                <td style="padding: 10px 12px;">
                  <span style="background: #dcfce7; color: #15803d; font-size: 0.72rem; font-weight: 800; padding: 2px 8px; border-radius: 10px;">
                    VERIFIED
                  </span>
                </td>
                <td style="padding: 10px 12px; text-align: center;">
                  <button 
                    @click.stop="$emit('open-edit-user', u)" 
                    style="background: #2563eb; color: white; border: none; padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: 0.75rem; cursor: pointer;"
                  >
                    ✏️ Edit User
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- 6. DEDICATED APP SHARE & REFERRAL CONFIG CARD WITH REFERRAL SHARE TEXT -->
    <div v-else-if="currentTab === 'sec_app_share'" class="section-settings-pane">
      <div class="table-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
        <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.75rem;">
          <h3 style="margin: 0; font-size: 1.2rem; font-weight: 800; color: #0f172a;">📢 6. App Share & Referral Settings Configuration</h3>
          <button @click="$emit('save-system-settings')" :disabled="savingSettings" style="background: #16a34a; color: white; border: none; padding: 0.65rem 1.5rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            💾 {{ savingSettings ? 'Saving...' : 'Save Configuration' }}
          </button>
        </div>
        <p class="card-desc" style="margin: 4px 0 1rem; font-size: 0.83rem; color: #64748b;">Configure section visibility, rule mode, and custom referral message share text for WhatsApp & social sharing.</p>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1.25rem; margin-top: 1.25rem;">
          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155; display: block; margin-bottom: 4px;">Section Visibility</label>
            <select v-model="systemSettings.sec_app_share_visibility" class="input-styled select-styled" style="width: 100%; padding: 0.65rem; border-radius: 8px; border: 1px solid #cbd5e1;">
              <option value="Show">👁️ Show on Mobile App</option>
              <option value="Hide">🙈 Hide / Lock Section</option>
            </select>
          </div>

          <div class="form-group">
            <label style="font-size: 0.85rem; font-weight: 700; color: #334155; display: block; margin-bottom: 4px;">Rule / Mode</label>
            <select v-model="systemSettings.sec_app_share_rule_mode" class="input-styled select-styled" style="width: 100%; padding: 0.65rem; border-radius: 8px; border: 1px solid #cbd5e1;">
              <option value="Enabled (Standard)">🟢 Enabled (Standard)</option>
              <option value="Disabled (Maintenance)">🔴 Maintenance Mode</option>
              <option value="Strict Verification">🔒 Strict Verification Required</option>
            </select>
          </div>
        </div>

        <!-- REFERRAL SHARE MESSAGE TEXTAREA -->
        <div style="margin-top: 1.5rem;">
          <label style="font-size: 0.88rem; font-weight: 800; color: #0f172a; display: block; margin-bottom: 6px;">
            💬 App Referral Share Message / Text
          </label>
          <p style="margin: 0 0 8px; font-size: 0.78rem; color: #64748b;">
            This text is automatically copied or sent when users tap <strong>"Share App / Referral Link"</strong> on WhatsApp, SMS, or Social Media.
          </p>
          <textarea 
            v-model="systemSettings.referral_share_text" 
            rows="4" 
            placeholder="Join SR Digital Seva today and start earning daily income! Use my Referral Code: {REFERRAL_CODE}. Download App now: https://srdigitalseva.com/app"
            style="width: 100%; box-sizing: border-box; padding: 0.75rem 0.9rem; border-radius: 8px; border: 1px solid #cbd5e1; outline: none; font-family: inherit; font-size: 0.88rem; line-height: 1.5; color: #0f172a;"
          ></textarea>

          <div style="margin-top: 8px; display: flex; gap: 8px; flex-wrap: wrap; font-size: 0.75rem; color: #475569;">
            <span style="font-weight: 700; color: #2563eb;">Available Dynamic Placeholders:</span>
            <code style="background: #f1f5f9; padding: 2px 6px; border-radius: 4px; font-weight: 700;">{REFERRAL_CODE}</code>
            <code style="background: #f1f5f9; padding: 2px 6px; border-radius: 4px; font-weight: 700;">{USER_NAME}</code>
            <code style="background: #f1f5f9; padding: 2px 6px; border-radius: 4px; font-weight: 700;">{APP_LINK}</code>
          </div>
        </div>

        <div v-if="saveSettingsMsg" style="margin-top: 1rem; font-weight: 700; font-size: 0.88rem;" :style="{ color: saveSettingsSuccess ? '#16a34a' : '#ef4444' }">
          {{ saveSettingsMsg }}
        </div>
      </div>
    </div>

    <!-- 7. GENERIC SECTION CHECKLIST CONFIG CARD -->
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
    users: { type: Array, default: () => [] },
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
      qrSourceOption: 'file'
    };
  },
  computed: {
    verifiedBankUsers() {
      if (!this.users || !Array.isArray(this.users)) return [];
      return this.users.filter(u => u.account_no || u.bank_name || u.account_holder || u.ifsc);
    }
  },
  methods: {
    handleSaveAndUpload() {
      this.$emit('save-system-settings');
      if (this.systemSettings.upi_qr_url && this.systemSettings.upi_qr_url.startsWith('data:image')) {
        this.$emit('upload-qr');
      }
    },
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
