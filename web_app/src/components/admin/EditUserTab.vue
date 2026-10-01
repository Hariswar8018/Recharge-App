<template>
  <div class="edit-user-page">
    <!-- SEARCH HEADER BAR -->
    <div class="edit-user-search-bar">
      <div class="search-bar-title">
        <h2>✏️ Edit User Details</h2>
        <p>Modify profile, reset password, change status, and update verified bank account info.</p>
      </div>

      <div class="search-input-group">
        <input 
          type="text" 
          v-model="searchQueryLocal" 
          @keyup.enter="$emit('search-user', searchQueryLocal)"
          placeholder="Enter Mobile Number or User ID..." 
          class="input-search-styled"
        />
        <button @click="$emit('search-user', searchQueryLocal)" class="btn-search-primary">
          🔍 Search User
        </button>
      </div>
    </div>

    <!-- MAIN EDIT GRID -->
    <div class="edit-user-grid">
      <!-- LEFT COLUMN: Forms -->
      <div class="edit-forms-column">
        
        <!-- CARD 1: User Details -->
        <div class="form-card">
          <div class="card-header-blue">
            <div class="header-left">
              <span class="header-icon">👤</span>
              <h3>User Details</h3>
            </div>
            <div class="status-dropdown-badge">
              <select v-model="editUserObj.status" class="status-select-badge" style="padding: 4px 10px; border-radius: 20px; font-weight: 800; font-size: 0.8rem; background: #dcfce7; color: #15803d; border: 1px solid #86efac; outline: none; cursor: pointer;">
                <option value="ACTIVE">🟢 Active</option>
                <option value="PENDING">🟡 Pending</option>
                <option value="BLOCKED">🔴 Blocked</option>
                <option value="INACTIVE">⚪ Inactive</option>
              </select>
            </div>
          </div>

          <div class="form-grid-2">
            <!-- User ID -->
            <div class="form-group">
              <label>User ID</label>
              <div class="copy-input-group">
                <input type="text" :value="editUserObj.id || editUserObj.mobileNumber" readonly class="input-readonly" />
                <button @click="$emit('copy-to-clipboard', editUserObj.id)" class="btn-copy-icon" title="Copy User ID">📋</button>
              </div>
            </div>

            <!-- Mobile Number -->
            <div class="form-group">
              <label>Mobile Number <span class="req">*</span></label>
              <input type="text" v-model="editUserObj.mobileNumber" class="input-styled" />
              <span class="input-subnote">If you change mobile number, user's position in the single leg will remain the same.</span>
            </div>

            <!-- Name -->
            <div class="form-group">
              <label>Name <span class="req">*</span></label>
              <input type="text" v-model="editUserObj.fullName" class="input-styled" />
            </div>

            <!-- Email ID -->
            <div class="form-group">
              <label>Email ID</label>
              <input type="email" v-model="editUserObj.email" class="input-styled" />
            </div>

            <!-- Password -->
            <div class="form-group">
              <label>Password</label>
              <div class="password-input-group">
                <input :type="editUserObj.showPassword ? 'text' : 'password'" ref="userPasswordInput" v-model="editUserObj.password" placeholder="Enter new password to change" class="input-styled" style="width: 100%;" />
                <button type="button" @click="editUserObj.showPassword = !editUserObj.showPassword" class="btn-eye-toggle">
                  {{ editUserObj.showPassword ? '🙈' : '👁️' }}
                </button>
              </div>
              <span class="input-subnote">This password will be updated and user can login with the new password.</span>
            </div>

            <!-- Sponsor ID -->
            <div class="form-group">
              <label>Sponsor ID</label>
              <input type="text" v-model="editUserObj.sponsor_id" placeholder="9123456780" class="input-styled" />
            </div>

            <!-- Date of Joining -->
            <div class="form-group">
              <label>Date of Joining</label>
              <div class="date-input-wrapper">
                <input type="text" :value="editUserObj.createdAt ? String(editUserObj.createdAt).substring(0, 10) : '19-09-2026'" readonly class="input-readonly" />
                <span class="calendar-icon">📅</span>
              </div>
            </div>

            <!-- Status -->
            <div class="form-group">
              <label>Status</label>
              <select v-model="editUserObj.status" class="input-styled select-styled">
                <option value="ACTIVE">Active</option>
                <option value="PENDING">Pending</option>
                <option value="BLOCKED">Blocked</option>
                <option value="INACTIVE">Inactive</option>
              </select>
            </div>
          </div>
        </div>

        <!-- CARD 2: Bank Account Details -->
        <div class="form-card bank-card">
          <div class="card-header-red">
            <span class="header-icon">🏛️</span>
            <h3>Bank Account Details</h3>
          </div>

          <div class="form-grid-3">
            <!-- Account Holder Name -->
            <div class="form-group">
              <label>Account Holder Name <span class="req">*</span></label>
              <input type="text" v-model="editUserObj.account_holder" placeholder="Rajesh Kumar" class="input-styled" />
            </div>

            <!-- Account Number -->
            <div class="form-group">
              <label>Account Number <span class="req">*</span></label>
              <input type="text" v-model="editUserObj.account_no" placeholder="123456789012" class="input-styled" />
            </div>

            <!-- IFSC Code -->
            <div class="form-group">
              <label>IFSC Code <span class="req">*</span></label>
              <input type="text" v-model="editUserObj.ifsc" placeholder="HDFC0001234" class="input-styled uppercase" />
            </div>
          </div>

          <div class="form-grid-3" style="margin-top: 1rem;">
            <!-- Bank Name -->
            <div class="form-group">
              <label>Bank Name <span class="req">*</span></label>
              <input type="text" v-model="editUserObj.bank_name" placeholder="e.g. State Bank of India" class="input-styled" />
            </div>

            <!-- Branch -->
            <div class="form-group">
              <label>Branch</label>
              <input type="text" v-model="editUserObj.branch" placeholder="Warangal" class="input-styled" />
            </div>

            <!-- Account Type -->
            <div class="form-group">
              <label>Account Type</label>
              <select v-model="editUserObj.account_type" class="input-styled select-styled">
                <option value="Savings">Savings</option>
                <option value="Current">Current</option>
              </select>
            </div>
          </div>
        </div>

        <!-- CARD 3: Important Notes -->
        <div class="important-notes-box">
          <div class="info-icon-large">ℹ️</div>
          <div class="notes-content">
            <h4>Important Notes:</h4>
            <ul>
              <li>Changes will reflect immediately in the user panel.</li>
              <li>If mobile number is changed, the user's position in the single leg will remain the same.</li>
              <li>Ensure all details are correct before submitting.</li>
            </ul>
          </div>
        </div>

        <!-- SUBMIT & RESET BUTTONS -->
        <div class="form-actions-bar">
          <button @click="$emit('save-user-details')" :disabled="loadingUserEdit" class="btn-submit-primary">
            💾 {{ loadingUserEdit ? 'Updating...' : 'Update User Details' }}
          </button>
          <button @click="$emit('reset-user-form')" class="btn-reset-secondary">
            🔄 Reset
          </button>
        </div>

        <!-- Status Toast / Alert -->
        <div v-if="updateUserMsg" :class="updateUserSuccess ? 'success-alert' : 'error-alert'" style="margin-top: 1rem; padding: 0.75rem 1rem; border-radius: 8px; font-weight: 700;">
          {{ updateUserMsg }}
        </div>

      </div>

      <!-- RIGHT COLUMN: User Summary & Wallet Balances & Quick Actions -->
      <div class="edit-summary-column">
        
        <!-- CARD 1: User Summary -->
        <div class="summary-card">
          <div class="summary-header">
            <span class="icon">📁</span>
            <h3>User Summary</h3>
          </div>
          <div class="summary-profile-box">
            <div class="avatar-circle">
              <span>👤</span>
            </div>
            <h3 class="user-name-title">{{ editUserObj.fullName || 'Rajesh Kumar' }}</h3>
            <div class="summary-details-list">
              <div class="s-row"><span>User ID</span><strong>: {{ editUserObj.id || editUserObj.mobileNumber }}</strong></div>
              <div class="s-row"><span>Mobile</span><strong>: {{ editUserObj.mobileNumber }}</strong></div>
              <div class="s-row"><span>Email</span><strong>: {{ editUserObj.email || 'N/A' }}</strong></div>
              <div class="s-row"><span>Status</span><span>: <strong style="color: #16a34a;">{{ editUserObj.status || 'Active' }}</strong></span></div>
              <div class="s-row"><span>Joining Date</span><strong>: {{ editUserObj.createdAt ? String(editUserObj.createdAt).substring(0,10) : '19-09-2026' }}</strong></div>
              <div class="s-row"><span>Sponsor ID</span><strong>: {{ editUserObj.sponsor_id || 'None' }}</strong></div>
            </div>
          </div>
        </div>

        <!-- CARD 2: Wallet Balances -->
        <div class="summary-card wallet-card">
          <div class="summary-header">
            <span class="icon">👛</span>
            <h3>Wallet Balances</h3>
          </div>
          <div class="wallet-balances-list">
            <div class="w-row"><span>Main Wallet</span><strong style="color: #2563eb;">₹ {{ parseFloat(editUserObj.main_wallet_balance || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</strong></div>
            <div class="w-row"><span>Fund Wallet</span><strong style="color: #16a34a;">₹ {{ parseFloat(editUserObj.fund_wallet_balance || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</strong></div>
            <div class="w-row"><span>Income Wallet</span><strong style="color: #ea580c;">₹ {{ parseFloat(editUserObj.income_wallet_balance || editUserObj.main_wallet_balance || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</strong></div>
            <div class="w-row"><span>Captcha Wallet</span><strong style="color: #9333ea;">₹ {{ parseFloat(editUserObj.captcha_wallet_balance || 320).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</strong></div>
          </div>
          <button @click="$emit('open-add-funds', editUserObj)" class="btn-add-funds-wide" style="margin-top: 1rem; width: 100%; background: #2563eb; color: white; border: none; padding: 0.65rem; border-radius: 8px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 6px;">
            ➕ Add / Adjust Wallet Funds
          </button>
        </div>

        <!-- CARD 3: Quick Actions -->
        <div class="summary-card quick-actions-card">
          <div class="summary-header">
            <span class="icon">⚙️</span>
            <h3>Quick Actions</h3>
          </div>
          <div class="quick-actions-list">
            <button @click="$emit('view-user-transactions', editUserObj)" class="quick-btn">
              <span class="icon">📋</span> View Transaction History
            </button>
            <button @click="$emit('view-user-income', editUserObj)" class="quick-btn">
              <span class="icon">📊</span> View Income Details
            </button>
            <button @click="$emit('focus-password')" class="quick-btn">
              <span class="icon">🔑</span> Reset Password
            </button>
            <button @click="$emit('login-as-user', editUserObj)" class="quick-btn">
              <span class="icon">➡️</span> Login as User
            </button>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EditUserTab',
  props: {
    editUserObj: { type: Object, required: true },
    searchQuery: { type: String, default: '' },
    loadingUserEdit: { type: Boolean, default: false },
    updateUserMsg: { type: String, default: '' },
    updateUserSuccess: { type: Boolean, default: false }
  },
  data() {
    return {
      searchQueryLocal: this.searchQuery
    };
  },
  watch: {
    searchQuery(newVal) { this.searchQueryLocal = newVal; }
  }
};
</script>
