<template>
  <div class="edit-user-page" style="max-width: 100%; box-sizing: border-box; overflow-x: hidden; padding: 1.25rem;">
    <!-- SEARCH HEADER BAR -->
    <div class="edit-user-search-bar" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem 1.5rem; margin-bottom: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
      <div class="search-bar-title">
        <h2 style="margin: 0; font-size: 1.35rem; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px;">
          <span>✏️</span> Edit User Details
        </h2>
        <p style="margin: 4px 0 0; font-size: 0.85rem; color: #64748b;">Modify profile, mobile number, email, sponsor ID, joining date, password, and bank account info.</p>
      </div>

      <div class="search-input-group" style="display: flex; gap: 0.5rem; align-items: center; flex-wrap: wrap; flex: 1; max-width: 500px; justify-content: flex-end;">
        <input 
          type="text" 
          v-model="searchQueryLocal" 
          @keyup.enter="$emit('search-user', searchQueryLocal)"
          placeholder="Enter Mobile Number or User ID..." 
          class="input-search-styled"
          style="flex: 1; min-width: 200px; padding: 0.65rem 0.9rem; border-radius: 8px; border: 1px solid #cbd5e1; outline: none; font-size: 0.88rem;"
        />
        <button @click="$emit('search-user', searchQueryLocal)" class="btn-search-primary" style="background: #2563eb; color: white; border: none; padding: 0.65rem 1.25rem; border-radius: 8px; font-weight: 700; font-size: 0.88rem; cursor: pointer; white-space: nowrap;">
          🔍 Search User
        </button>
      </div>
    </div>

    <!-- EMPTY STATE WHEN NO USER IS SELECTED/FOUND -->
    <div v-if="!hasActiveUser" class="empty-user-search-state" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 3.5rem 1.5rem; text-align: center; margin-bottom: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
      <div style="font-size: 3.5rem; margin-bottom: 1rem; color: #3b82f6;">🔍</div>
      <h3 style="margin: 0; font-size: 1.3rem; font-weight: 800; color: #0f172a;">No User Profile Selected</h3>
      <p style="margin: 0.6rem auto 1.5rem; color: #64748b; font-size: 0.92rem; max-width: 520px; line-height: 1.5;">
        Please enter a Mobile Number or User ID above and click <strong>"Search User"</strong>, or pick any user from the <strong>App Users</strong> list to view and edit their profile.
      </p>
    </div>

    <!-- MAIN EDIT GRID (ONLY SHOWN IF USER IS FOUND/SELECTED) -->
    <div v-else class="edit-user-grid" style="display: grid; grid-template-columns: minmax(0, 1fr) minmax(280px, 340px); gap: 1.5rem; width: 100%; box-sizing: border-box;">
      
      <!-- LEFT COLUMN: Forms -->
      <div class="edit-forms-column" style="min-width: 0; display: flex; flex-direction: column; gap: 1.25rem;">
        
        <!-- CARD 1: User Profile Settings -->
        <div class="form-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
          <div class="card-header-blue" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; flex-wrap: wrap; gap: 0.5rem;">
            <div class="header-left" style="display: flex; align-items: center; gap: 0.5rem;">
              <span class="header-icon" style="font-size: 1.2rem;">👤</span>
              <h3 style="margin: 0; font-size: 1.15rem; font-weight: 800; color: #1e3a8a;">User Profile Settings</h3>
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

          <div class="form-grid-2" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.25rem;">
            <!-- User ID (Readonly System Key) -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">User ID</label>
              <div class="copy-input-group" style="display: flex; gap: 0.5rem;">
                <input type="text" :value="editUserObj.id || editUserObj.mobileNumber" readonly class="input-readonly" style="flex: 1; min-width: 0; padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; background: #f1f5f9; color: #475569;" />
                <button @click="$emit('copy-to-clipboard', editUserObj.id)" class="btn-copy-icon" title="Copy User ID" style="background: #f1f5f9; border: 1px solid #cbd5e1; padding: 0 0.75rem; border-radius: 8px; cursor: pointer;">📋</button>
              </div>
            </div>

            <!-- Mobile Number (Editable) -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Mobile Number <span class="req" style="color: #ef4444;">*</span></label>
              <input type="text" v-model="editUserObj.mobileNumber" class="input-styled" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; box-sizing: border-box; width: 100%;" />
              <span style="font-size: 0.75rem; color: #64748b; margin-top: 2px;">Changing mobile retains single leg position, cycles, sponsor & wallets.</span>
            </div>

            <!-- Full Name (Editable) -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Full Name <span class="req" style="color: #ef4444;">*</span></label>
              <input type="text" v-model="editUserObj.fullName" class="input-styled" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; box-sizing: border-box; width: 100%;" />
            </div>

            <!-- Email Address (Editable) -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Email Address</label>
              <input type="email" v-model="editUserObj.email" class="input-styled" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; box-sizing: border-box; width: 100%;" />
            </div>

            <!-- User Sponsor Code / SRM ID (Editable) -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">User Sponsor Code / SRM ID</label>
              <input type="text" v-model="editUserObj.user_code" maxlength="10" placeholder="e.g. SRM1234567" class="input-styled" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; box-sizing: border-box; width: 100%; font-weight: 800; color: #0f172a;" />
              <span style="font-size: 0.73rem; color: #64748b; margin-top: 2px;">Must be unique 10 chars starting with SRM (e.g. SRM1234567). Auto-generated if blank.</span>
            </div>

            <!-- Sponsor Mobile Number (Editable) -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Parent Sponsor Mobile Number</label>
              <input type="text" v-model="editUserObj.sponsor_id" placeholder="Enter Parent Sponsor 10-digit Mobile Number" class="input-styled" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; box-sizing: border-box; width: 100%;" />
            </div>

            <!-- Date of Joining (Editable) -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Date of Joining</label>
              <input type="text" v-model="editUserObj.createdAt" placeholder="YYYY-MM-DD" class="input-styled" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; box-sizing: border-box; width: 100%;" />
            </div>

            <!-- Account Status -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Account Status</label>
              <select v-model="editUserObj.status" class="input-styled select-styled" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; background: white; cursor: pointer; box-sizing: border-box; width: 100%;">
                <option value="ACTIVE">Active</option>
                <option value="PENDING">Pending</option>
                <option value="BLOCKED">Blocked</option>
                <option value="INACTIVE">Inactive</option>
              </select>
            </div>
          </div>
        </div>

        <!-- CARD 2: DEDICATED FULL RESET PASSWORD BAR -->
        <div ref="resetPasswordSection" class="form-card reset-password-card" style="background: white; border-radius: 12px; border: 1px solid #fecdd3; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
          <div class="card-header-red" style="display: flex; align-items: center; gap: 0.5rem; background: #fff1f2; margin: -1.5rem -1.5rem 1.25rem -1.5rem; padding: 1rem 1.5rem; border-top-left-radius: 12px; border-top-right-radius: 12px; border-bottom: 1px solid #fecdd3;">
            <span style="font-size: 1.2rem;">🔑</span>
            <h3 style="margin: 0; font-size: 1.1rem; font-weight: 800; color: #9f1239;">User Password Management</h3>
          </div>
          <p style="margin: 0 0 1rem; font-size: 0.85rem; color: #64748b;">Set a new login password for <strong>{{ editUserObj.fullName || editUserObj.mobileNumber }}</strong>. The user can immediately log in with this new password.</p>

          <div style="display: flex; gap: 0.75rem; align-items: center; flex-wrap: wrap;">
            <div style="flex: 1; min-width: 220px; position: relative; display: flex; align-items: center;">
              <input 
                :type="showResetPassword ? 'text' : 'password'" 
                ref="userPasswordInput"
                v-model="editUserObj.password" 
                placeholder="Enter new password..." 
                class="input-styled" 
                style="width: 100%; padding: 0.7rem 2.8rem 0.7rem 0.9rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.9rem; outline: none; box-sizing: border-box;" 
              />
              <button type="button" @click="showResetPassword = !showResetPassword" style="position: absolute; right: 10px; background: transparent; border: none; font-size: 1.1rem; cursor: pointer;">
                {{ showResetPassword ? '🙈' : '👁️' }}
              </button>
            </div>

            <button @click="$emit('save-user-details')" :disabled="loadingUserEdit" style="background: #e11d48; color: white; border: none; padding: 0.7rem 1.4rem; border-radius: 8px; font-weight: 800; font-size: 0.88rem; cursor: pointer; white-space: nowrap;">
              🔒 Update & Save Password
            </button>
          </div>
        </div>

        <!-- CARD 3: Bank Account Details -->
        <div class="form-card bank-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
          <div class="card-header-red" style="display: flex; align-items: center; gap: 0.5rem; background: #fff5f5; margin: -1.5rem -1.5rem 1.25rem -1.5rem; padding: 1rem 1.5rem; border-top-left-radius: 12px; border-top-right-radius: 12px; border-bottom: 1px solid #fee2e2;">
            <span class="header-icon" style="font-size: 1.2rem;">🏛️</span>
            <h3 style="margin: 0; font-size: 1.1rem; font-weight: 800; color: #991b1b;">Bank Account Details</h3>
          </div>

          <div class="form-grid-3" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1rem;">
            <!-- Account Holder Name -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Account Holder Name</label>
              <input type="text" v-model="editUserObj.account_holder" placeholder="Enter Account Holder Name" class="input-styled" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; box-sizing: border-box; width: 100%;" />
            </div>

            <!-- Account Number -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Account Number</label>
              <input type="text" v-model="editUserObj.account_no" placeholder="Enter Bank Account Number" class="input-styled" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; box-sizing: border-box; width: 100%;" />
            </div>

            <!-- IFSC Code -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">IFSC Code</label>
              <input type="text" v-model="editUserObj.ifsc" placeholder="e.g. HDFC0001234" class="input-styled uppercase" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; text-transform: uppercase; box-sizing: border-box; width: 100%;" />
            </div>
          </div>

          <div class="form-grid-3" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1rem; margin-top: 1rem;">
            <!-- Bank Name -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Bank Name</label>
              <input type="text" v-model="editUserObj.bank_name" placeholder="Enter Bank Name" class="input-styled" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; box-sizing: border-box; width: 100%;" />
            </div>

            <!-- Branch -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Branch Name</label>
              <input type="text" v-model="editUserObj.branch" placeholder="Enter Branch Name" class="input-styled" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; box-sizing: border-box; width: 100%;" />
            </div>

            <!-- Account Type -->
            <div class="form-group" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <label style="font-size: 0.85rem; font-weight: 700; color: #334155;">Account Type</label>
              <select v-model="editUserObj.account_type" class="input-styled select-styled" style="padding: 0.65rem 0.85rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; outline: none; background: white; cursor: pointer; box-sizing: border-box; width: 100%;">
                <option value="Savings">Savings</option>
                <option value="Current">Current</option>
              </select>
            </div>
          </div>
        </div>

        <!-- SUBMIT & RESET BUTTONS -->
        <div class="form-actions-bar" style="display: flex; gap: 1rem; flex-wrap: wrap;">
          <button @click="$emit('save-user-details')" :disabled="loadingUserEdit" class="btn-submit-primary" style="background: #2563eb; color: white; border: none; padding: 0.75rem 1.5rem; border-radius: 8px; font-weight: 700; font-size: 0.9rem; cursor: pointer;">
            💾 {{ loadingUserEdit ? 'Updating...' : 'Update User Details' }}
          </button>
          <button @click="$emit('reset-user-form')" class="btn-reset-secondary" style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 0.75rem 1.5rem; border-radius: 8px; font-weight: 700; font-size: 0.9rem; cursor: pointer;">
            🔄 Reset Form
          </button>
        </div>

      </div>

      <!-- RIGHT COLUMN: User Summary & Wallet Balances & Quick Actions -->
      <div class="edit-summary-column" style="min-width: 0; display: flex; flex-direction: column; gap: 1.25rem;">
        
        <!-- CARD 1: User Summary -->
        <div class="summary-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
          <div class="summary-header" style="display: flex; align-items: center; gap: 8px; margin-bottom: 1rem; padding-bottom: 0.5rem; border-bottom: 1px solid #f1f5f9;">
            <span class="icon" style="font-size: 1.1rem;">📁</span>
            <h3 style="margin: 0; font-size: 1rem; font-weight: 800; color: #0f172a;">User Profile Summary</h3>
          </div>
          <div class="summary-profile-box" style="text-align: center;">
            <div class="avatar-circle" style="width: 54px; height: 54px; background: #eff6ff; color: #2563eb; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 0.75rem; font-size: 1.6rem;">
              👤
            </div>
            <h3 class="user-name-title" style="margin: 0 0 0.75rem; font-size: 1.1rem; font-weight: 800; color: #0f172a;">{{ editUserObj.fullName || 'User Profile' }}</h3>
            <div class="summary-details-list" style="display: flex; flex-direction: column; gap: 0.4rem; font-size: 0.83rem; text-align: left;">
              <div class="s-row" style="display: flex; justify-content: space-between;"><span>User ID:</span><strong>#{{ editUserObj.id || editUserObj.mobileNumber }}</strong></div>
              <div class="s-row" style="display: flex; justify-content: space-between;"><span>Mobile:</span><strong>{{ editUserObj.mobileNumber }}</strong></div>
              <div class="s-row" style="display: flex; justify-content: space-between;"><span>Email:</span><strong style="word-break: break-all;">{{ editUserObj.email || 'N/A' }}</strong></div>
              <div class="s-row" style="display: flex; justify-content: space-between;"><span>Status:</span><strong style="color: #16a34a;">{{ editUserObj.status || 'Active' }}</strong></div>
              <div class="s-row" style="display: flex; justify-content: space-between;"><span>Joining Date:</span><strong>{{ editUserObj.createdAt ? String(editUserObj.createdAt).substring(0,10) : 'N/A' }}</strong></div>
              <div class="s-row" style="display: flex; justify-content: space-between;"><span>Sponsor Mobile:</span><strong>{{ editUserObj.sponsor_mobile || editUserObj.sponsor_mobileNumber || (editUserObj.sponsor_id && String(editUserObj.sponsor_id).length >= 10 ? editUserObj.sponsor_id : (editUserObj.sponsor_name || editUserObj.sponsor_id || 'None')) }}</strong></div>
            </div>
          </div>
        </div>

        <!-- CARD 2: Wallet Balances -->
        <div class="summary-card wallet-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
          <div class="summary-header" style="display: flex; align-items: center; gap: 8px; margin-bottom: 1rem; padding-bottom: 0.5rem; border-bottom: 1px solid #f1f5f9;">
            <span class="icon" style="font-size: 1.1rem;">👛</span>
            <h3 style="margin: 0; font-size: 1rem; font-weight: 800; color: #0f172a;">Wallet Balances</h3>
          </div>
          <div class="wallet-balances-list" style="display: flex; flex-direction: column; gap: 0.5rem; font-size: 0.85rem;">
            <div class="w-row" style="display: flex; justify-content: space-between;"><span>Main Wallet:</span><strong style="color: #2563eb;">₹ {{ parseFloat(editUserObj.main_wallet_balance || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</strong></div>
            <div class="w-row" style="display: flex; justify-content: space-between;"><span>Fund Wallet:</span><strong style="color: #16a34a;">₹ {{ parseFloat(editUserObj.fund_wallet_balance || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</strong></div>
          </div>
          <button @click="$emit('open-add-funds', editUserObj)" class="btn-add-funds-wide" style="margin-top: 1rem; width: 100%; background: #2563eb; color: white; border: none; padding: 0.65rem; border-radius: 8px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 6px;">
            ➕ Add / Adjust Wallet Funds
          </button>
        </div>

        <!-- CARD 3: Quick Actions -->
        <div class="summary-card quick-actions-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
          <div class="summary-header" style="display: flex; align-items: center; gap: 8px; margin-bottom: 1rem; padding-bottom: 0.5rem; border-bottom: 1px solid #f1f5f9;">
            <span class="icon" style="font-size: 1.1rem;">⚙️</span>
            <h3 style="margin: 0; font-size: 1rem; font-weight: 800; color: #0f172a;">Quick Actions</h3>
          </div>
          <div class="quick-actions-list" style="display: flex; flex-direction: column; gap: 0.5rem;">
            <button @click="$emit('view-user-transactions', editUserObj)" class="quick-btn" style="background: #f8fafc; border: 1px solid #cbd5e1; padding: 0.6rem 0.85rem; border-radius: 8px; font-weight: 700; font-size: 0.83rem; color: #1e293b; text-align: left; cursor: pointer; display: flex; align-items: center; gap: 8px;">
              <span class="icon">📋</span> View Transaction History
            </button>
            <button @click="$emit('view-user-income', editUserObj)" class="quick-btn" style="background: #f8fafc; border: 1px solid #cbd5e1; padding: 0.6rem 0.85rem; border-radius: 8px; font-weight: 700; font-size: 0.83rem; color: #1e293b; text-align: left; cursor: pointer; display: flex; align-items: center; gap: 8px;">
              <span class="icon">📊</span> View Income Details
            </button>
            <button 
              v-if="hasActiveUser" 
              @click="openActivationInvoice" 
              class="quick-btn" 
              style="background: #f0fdf4; border: 1px solid #bbf7d0; padding: 0.6rem 0.85rem; border-radius: 8px; font-weight: 700; font-size: 0.83rem; color: #15803d; text-align: left; cursor: pointer; display: flex; align-items: center; gap: 8px;"
            >
              <span class="icon">📄</span> Download ₹1,200 ID Activation Invoice
            </button>
            <button @click="scrollToResetPassword" class="quick-btn" style="background: #fff1f2; border: 1px solid #fecdd3; padding: 0.6rem 0.85rem; border-radius: 8px; font-weight: 700; font-size: 0.83rem; color: #9f1239; text-align: left; cursor: pointer; display: flex; align-items: center; gap: 8px;">
              <span class="icon">🔑</span> Reset User Password
            </button>
          </div>
        </div>

      </div>
    </div>

    <!-- INDIVIDUAL INVOICE MODAL -->
    <InvoiceModal 
      :show="showInvoiceModal"
      :transaction="activationTx"
      :user="editUserObj"
      @close="showInvoiceModal = false"
    />
  </div>
</template>

<script>
import InvoiceModal from './InvoiceModal.vue';

export default {
  name: 'EditUserTab',
  components: {
    InvoiceModal
  },
  props: {
    editUserObj: { type: Object, default: () => ({}) },
    searchQuery: { type: String, default: '' },
    loadingUserEdit: { type: Boolean, default: false },
    updateUserMsg: { type: String, default: '' },
    updateUserSuccess: { type: Boolean, default: false }
  },
  data() {
    return {
      searchQueryLocal: this.searchQuery,
      showResetPassword: false,
      showInvoiceModal: false,
      activationTx: null
    };
  },
  computed: {
    hasActiveUser() {
      return !!(this.editUserObj && (this.editUserObj.id || this.editUserObj.mobileNumber));
    }
  },
  watch: {
    searchQuery(newVal) { this.searchQueryLocal = newVal; }
  },
  methods: {
    scrollToResetPassword() {
      if (this.$refs.userPasswordInput) {
        this.$refs.userPasswordInput.focus();
      }
      if (this.$refs.resetPasswordSection) {
        this.$refs.resetPasswordSection.scrollIntoView({ behavior: 'smooth' });
      }
    },
    openActivationInvoice() {
      this.activationTx = {
        id: this.editUserObj.id || '1001',
        user_id: this.editUserObj.id || this.editUserObj.mobileNumber,
        fullName: this.editUserObj.fullName,
        mobileNumber: this.editUserObj.mobileNumber,
        email: this.editUserObj.email,
        amount: 1200,
        numeric_amount: 1200,
        type: 'ID Package Activation',
        wallet_type: 'MAIN',
        status: 'Approved',
        date: this.editUserObj.createdAt ? String(this.editUserObj.createdAt).substring(0,10) : new Date().toISOString().substring(0,10)
      };
      this.showInvoiceModal = true;
    }
  }
};
</script>
