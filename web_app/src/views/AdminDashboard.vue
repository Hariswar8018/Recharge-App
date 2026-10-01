<template>
  <div class="admin-layout">
    <!-- FLOATING TOP-CENTERED SUCCESS TOAST ALERT BOX (1.5 SECONDS) -->
    <div 
      v-if="globalToast.show" 
      class="floating-top-toast" 
      style="position: fixed; top: 24px; left: 50%; transform: translateX(-50%); z-index: 999999; background: #16a34a; color: white; padding: 12px 28px; border-radius: 30px; font-weight: 800; font-size: 0.95rem; display: flex; align-items: center; gap: 8px; box-shadow: 0 10px 25px rgba(0,0,0,0.25); border: 2px solid #bbf7d0;"
    >
      <span>✅</span>
      <span>{{ globalToast.message }}</span>
    </div>

    <!-- TOP APP BAR HEADER (IMAGE 1 DESIGN) -->
    <header class="top-app-bar">
      <!-- Topbar Left: Logo + Brand + Mobile Toggle -->
      <div class="topbar-brand-section">
        <button @click="mobileMenuOpen = !mobileMenuOpen" class="mobile-toggle-btn" title="Toggle Navigation">☰</button>
        <div class="brand-logo-wrapper" @click="switchTab('dashboard')" style="cursor: pointer;">
          <img :src="asetsLogo" alt="SR Digital Seva" class="brand-logo-img" />
          <div class="brand-title-group">
            <h1 class="brand-main-title">SR DIGITAL SEVA</h1>
            <span class="brand-sub-badge">Admin Control Panel</span>
          </div>
        </div>
      </div>

      <!-- Topbar Center: Main Navigation Quick Tabs (Image 1 Style) -->
      <nav class="topbar-main-nav">
        <button 
          @click="switchTab('dashboard')" 
          class="nav-tab-btn" 
          :class="{ active: currentTab === 'dashboard' }"
        >
          <span class="tab-icon">📊</span>
          <span class="tab-label">Dashboard</span>
        </button>

        <button 
          @click="switchTab('users')" 
          class="nav-tab-btn" 
          :class="{ active: currentTab === 'users' || currentTab === 'edit_user' }"
        >
          <span class="tab-icon">👥</span>
          <span class="tab-label">Users</span>
        </button>

        <button 
          @click="switchTab('withdrawals')" 
          class="nav-tab-btn" 
          :class="{ active: currentTab === 'withdrawals' || currentTab === 'sec_cashout' }"
        >
          <span class="tab-icon">💰</span>
          <span class="tab-label">Withdrawals</span>
        </button>

        <button 
          @click="switchTab('requests')" 
          class="nav-tab-btn" 
          :class="{ active: currentTab === 'requests' }"
        >
          <span class="tab-icon">📥</span>
          <span class="tab-label">Add Money</span>
          <span v-if="pendingRequestsCount > 0" class="nav-tab-badge">{{ pendingRequestsCount }}</span>
        </button>

        <button 
          @click="switchTab('transactions')" 
          class="nav-tab-btn" 
          :class="{ active: currentTab === 'transactions' }"
        >
          <span class="tab-icon">📑</span>
          <span class="tab-label">Platform Ledger</span>
        </button>

        <button 
          @click="switchTab('settings')" 
          class="nav-tab-btn" 
          :class="{ active: currentTab === 'settings' || currentTab.startsWith('sec_') }"
        >
          <span class="tab-icon">⚙️</span>
          <span class="tab-label">Settings</span>
        </button>
      </nav>

      <!-- Active View Indicator Chip -->
      <div class="active-view-chip">
        <span class="chip-dot"></span>
        <span class="chip-text">{{ formatTabTitle(currentTab) }}</span>
      </div>

      <!-- Topbar Right: Utility Navigation & Admin Profile (Image 1 & 2 Style) -->
      <div class="topbar-utility-nav">
        <!-- Quick Action Icons -->
        <button class="utility-icon-btn" title="System Online Status">
          <span class="status-pulse-dot"></span>
        </button>

        <button @click="switchTab('notifications')" class="utility-icon-btn" title="Push Notifications">
          <span class="util-icon">🔔</span>
          <span class="util-badge">3</span>
        </button>

        <button @click="switchTab('settings')" class="utility-icon-btn" title="App Settings">
          <span class="util-icon">⚙️</span>
        </button>

        <!-- Profile Avatar & Dropdown -->
        <div class="profile-dropdown-wrapper">
          <div 
            class="topbar-profile-card" 
            @click="profileDropdownOpen = !profileDropdownOpen" 
            :class="{ open: profileDropdownOpen }"
          >
            <div class="avatar-circle">
              <span>A</span>
            </div>
            <div class="profile-text-group">
              <span class="admin-email-text">{{ adminEmail }}</span>
              <span class="admin-role-badge">Super Admin</span>
            </div>
            <span class="dropdown-chevron">{{ profileDropdownOpen ? '▲' : '▼' }}</span>
          </div>

          <!-- Dropdown Menu -->
          <div v-if="profileDropdownOpen" class="profile-dropdown-menu" @mouseleave="profileDropdownOpen = false">
            <div class="dropdown-header">
              <span class="dh-title">Super Administrator</span>
              <span class="dh-email">{{ adminEmail }}</span>
            </div>
            <div class="dropdown-divider"></div>
            <button @click="switchTab('admins'); profileDropdownOpen = false" class="dropdown-item">
              <span>🔐 Admin Privileges</span>
            </button>
            <button @click="switchTab('settings'); profileDropdownOpen = false" class="dropdown-item">
              <span>⚙️ System Configuration</span>
            </button>
            <button @click="switchTab('notifications'); profileDropdownOpen = false" class="dropdown-item">
              <span>📢 Notifications Broadcast</span>
            </button>
            <div class="dropdown-divider"></div>
            <button @click="handleLogout" class="dropdown-item logout">
              <span>🚪 Sign Out</span>
            </button>
          </div>
        </div>
      </div>
    </header>

    <!-- SIDEBAR NAVIGATION (IMAGE 2 DARK SLATE DESIGN) -->
    <aside class="sidebar" :class="{ 'mobile-open': mobileMenuOpen }">
      <!-- Sidebar Top Admin Card (Image 2 Style) -->
      <div class="sidebar-user-card">
        <div class="user-avatar-large">
          <img :src="asetsLogo" alt="Admin Avatar" class="user-avatar-img" />
          <span class="online-indicator"></span>
        </div>
        <div class="user-card-details">
          <h3 class="user-card-name">SR Digital Seva Admin</h3>
          <p class="user-card-email">{{ adminEmail }}</p>
          <span class="online-status-chip">🟢 System Live</span>
        </div>
        <button @click="mobileMenuOpen = false" class="sidebar-mobile-close">&times;</button>
      </div>

      <div class="sidebar-menu-scroll">
        <!-- CORE MANAGEMENT GROUP -->
        <div class="sidebar-group">
          <div class="group-title">MAIN NAVIGATION</div>
          
          <button @click="switchTab('dashboard')" class="sidebar-nav-btn" :class="{ active: currentTab === 'dashboard' }">
            <span class="sb-icon">📊</span>
            <span class="sb-text">Dashboard Overview</span>
          </button>

          <div class="sidebar-menu-collapsible">
            <button @click="toggleGroup('users')" class="sidebar-nav-btn has-sub" :class="{ active: currentTab === 'users' || currentTab === 'edit_user' || currentTab === 'sec_home' || currentTab === 'teams' }">
              <span class="sb-icon">👥</span>
              <span class="sb-text">User & Member List</span>
              <span class="sb-arrow">{{ expandedGroups.users ? '▼' : '▶' }}</span>
            </button>
            <div v-if="expandedGroups.users" class="sidebar-sub-menu">
              <button @click="switchTab('sec_home')" class="sub-nav-btn" :class="{ active: currentTab === 'sec_home' }">
                Member Dashboard
              </button>
              <button @click="switchTab('users')" class="sub-nav-btn" :class="{ active: currentTab === 'users' }">
                Registered App Users
              </button>
              <button @click="switchTab('edit_user')" class="sub-nav-btn" :class="{ active: currentTab === 'edit_user' }">
                Edit User Details
              </button>
              <button @click="switchTab('teams')" class="sub-nav-btn" :class="{ active: currentTab === 'teams' }">
                Member Teams Tree
              </button>
              <button @click="switchTab('sec_business_income')" class="sub-nav-btn" :class="{ active: currentTab === 'sec_business_income' || currentTab === 'sec_global_cycle' }">
                Income & Global Pool
              </button>
            </div>
          </div>
        </div>

        <!-- WALLETS & FINANCIALS GROUP -->
        <div class="sidebar-group">
          <div class="group-title">FINANCIAL MANAGEMENT</div>

          <div class="sidebar-menu-collapsible">
            <button @click="toggleGroup('financials')" class="sidebar-nav-btn has-sub" :class="{ active: currentTab === 'transactions' || currentTab === 'requests' || currentTab === 'withdrawals' || currentTab === 'sec_cashout' || currentTab === 'sec_add_money' || currentTab === 'sec_subscription' || currentTab === 'sec_bank_verification' }">
              <span class="sb-icon">💰</span>
              <span class="sb-text">Wallet & Financials</span>
              <span class="sb-arrow">{{ expandedGroups.financials ? '▼' : '▶' }}</span>
            </button>
            <div v-if="expandedGroups.financials" class="sidebar-sub-menu">
              <button @click="switchTab('sec_cashout')" class="sub-nav-btn" :class="{ active: currentTab === 'sec_cashout' || currentTab === 'withdrawals' }">
                Payout & Withdrawals
              </button>
              <button @click="switchTab('transactions')" class="sub-nav-btn" :class="{ active: currentTab === 'transactions' }">
                Platform Transactions
              </button>
              <button @click="switchTab('sec_add_money')" class="sub-nav-btn" :class="{ active: currentTab === 'sec_add_money' }">
                Add Money Settings
              </button>
              <button @click="switchTab('requests')" class="sub-nav-btn" :class="{ active: currentTab === 'requests' }">
                Add Money Requests
                <span v-if="pendingRequestsCount > 0" class="sub-badge-count">{{ pendingRequestsCount }}</span>
              </button>
              <button @click="switchTab('sec_subscription')" class="sub-nav-btn" :class="{ active: currentTab === 'sec_subscription' }">
                Subscription & Plans
              </button>
              <button @click="switchTab('sec_bank_verification')" class="sub-nav-btn" :class="{ active: currentTab === 'sec_bank_verification' }">
                Bank Verification
              </button>
            </div>
          </div>
        </div>

        <!-- APP RULES & SETTINGS -->
        <div class="sidebar-group">
          <div class="group-title">APP CONFIGURATION</div>

          <div class="sidebar-menu-collapsible">
            <button @click="toggleGroup('settings')" class="sidebar-nav-btn has-sub" :class="{ active: currentTab === 'settings' || currentTab === 'sec_app_share' || currentTab === 'sec_captcha' || currentTab === 'sec_login' || currentTab === 'sec_registration' || currentTab === 'sec_otp' }">
              <span class="sb-icon">⚙️</span>
              <span class="sb-text">App Feature Rules</span>
              <span class="sb-arrow">{{ expandedGroups.settings ? '▼' : '▶' }}</span>
            </button>
            <div v-if="expandedGroups.settings" class="sidebar-sub-menu">
              <button @click="switchTab('sec_app_share')" class="sub-nav-btn" :class="{ active: currentTab === 'sec_app_share' }">
                App Share & Referral
              </button>
              <button @click="switchTab('sec_captcha')" class="sub-nav-btn" :class="{ active: currentTab === 'sec_captcha' }">
                CAPTCHA Work Rules
              </button>
              <button @click="switchTab('sec_login')" class="sub-nav-btn" :class="{ active: currentTab === 'sec_login' }">
                App Login Settings
              </button>
              <button @click="switchTab('sec_registration')" class="sub-nav-btn" :class="{ active: currentTab === 'sec_registration' }">
                Registration Rules
              </button>
              <button @click="switchTab('sec_otp')" class="sub-nav-btn" :class="{ active: currentTab === 'sec_otp' }">
                OTP / Security Rules
              </button>
            </div>
          </div>
        </div>

        <!-- ADMINISTRATION -->
        <div class="sidebar-group">
          <div class="group-title">ADMINISTRATION</div>

          <button @click="switchTab('notifications')" class="sidebar-nav-btn" :class="{ active: currentTab === 'notifications' }">
            <span class="sb-icon">📢</span>
            <span class="sb-text">Push Broadcasts</span>
          </button>

          <button @click="switchTab('admins')" class="sidebar-nav-btn" :class="{ active: currentTab === 'admins' }">
            <span class="sb-icon">🔐</span>
            <span class="sb-text">Admin Privileges</span>
          </button>

          <button @click="switchTab('settings')" class="sidebar-nav-btn" :class="{ active: currentTab === 'settings' }">
            <span class="sb-icon">⚙️</span>
            <span class="sb-text">System Settings</span>
          </button>
        </div>
      </div>

      <!-- SIDEBAR FOOTER -->
      <div class="sidebar-footer">
        <button @click="handleLogout" class="sidebar-logout-btn">
          <span>🚪 Sign Out</span>
        </button>
      </div>
    </aside>

    <!-- MAIN DASHBOARD CONTENT AREA -->
    <div class="main-wrapper">
      <!-- BODY CONTENT PANES -->
      <main class="content-body">
        <!-- TAB 1: DASHBOARD OVERVIEW -->
        <DashboardOverviewTab 
          v-if="currentTab === 'dashboard'"
          :users="users"
          :fundRequests="fundRequests"
          :transactions="transactions"
          :pendingRequestsCount="pendingRequestsCount"
          :gatewayStatus="gatewayStatus"
          @switch-tab="switchTab($event)"
          @refresh="fetchDashboardData"
        />

        <!-- TAB 2: REGISTERED USERS MANAGEMENT -->
        <UserManagementTab 
          v-else-if="currentTab === 'users'"
          :filteredUsers="filteredUsers"
          :userTableSearch="userTableSearch"
          :userStatusFilter="userStatusFilter"
          :userSortBy="userSortBy"
          @update:userTableSearch="userTableSearch = $event"
          @update:userStatusFilter="userStatusFilter = $event"
          @update:userSortBy="userSortBy = $event"
          @select-user="selectedUser = $event"
          @open-edit-user="openEditUserScreen($event)"
          @open-add-funds="openAddFundsModal($event)"
        />

        <!-- TAB 3: EDIT USER DETAILS -->
        <EditUserTab 
          v-else-if="currentTab === 'edit_user'"
          :editUserObj="editUserObj"
          :searchQuery="searchUserQuery"
          :loadingUserEdit="loadingUserEdit"
          :updateUserMsg="updateUserMsg"
          :updateUserSuccess="updateUserSuccess"
          @search-user="fetchUserForEdit($event)"
          @save-user-details="handleSaveUserDetails"
          @reset-user-form="openEditUserScreen(editUserObj)"
          @copy-to-clipboard="copyToClipboard($event)"
          @open-add-funds="openAddFundsModal($event)"
          @view-user-transactions="viewUserTransactions($event)"
          @view-user-income="viewUserIncome($event)"
          @focus-password="focusUserPassword($event)"
          @login-as-user="loginAsUserPreview($event)"
        />

        <!-- TAB 4: FUND REQUESTS MANAGEMENT -->
        <FundRequestsTab 
          v-else-if="currentTab === 'requests'"
          :fundRequests="fundRequests"
          :filteredRequests="filteredRequests"
          :pendingRequestsCount="pendingRequestsCount"
          :reqFilterStatus="reqFilterStatus"
          :reqSearchQuery="reqSearchQuery"
          :reqFilterMode="reqFilterMode"
          :reqPaymentModeFilter="reqPaymentModeFilter"
          :reqAmountFilter="reqAmountFilter"
          @update:reqFilterStatus="reqFilterStatus = $event"
          @update:reqSearchQuery="reqSearchQuery = $event"
          @update:reqFilterMode="reqFilterMode = $event"
          @update:reqPaymentModeFilter="reqPaymentModeFilter = $event"
          @update:reqAmountFilter="reqAmountFilter = $event"
          @approve-request="handleApproveRequest($event)"
          @reject-request="handleRejectRequest($event)"
          @view-receipt="selectedRequest = $event"
        />

        <!-- TAB 5: TRANSACTIONS & LEDGER -->
        <TransactionsTab 
          v-else-if="currentTab === 'transactions' || currentTab === 'sec_transactions'"
          :transactions="transactions"
          :txnPage="txnPage"
          @prev-page="fetchTransactions(txnPage - 1)"
          @next-page="fetchTransactions(txnPage + 1)"
        />

        <!-- TAB 6: TEAMS & AFFILIATE TREE -->
        <TeamsTreeTab 
          v-else-if="currentTab === 'teams' || currentTab === 'sec_team' || currentTab === 'sec_direct_members'"
          :teamsData="teamsData"
          :users="users"
          :loadingTeams="loadingTeams"
        />

        <!-- TAB 7: ADMINS MANAGEMENT -->
        <AdminsManagementTab 
          v-else-if="currentTab === 'admins'"
          :systemAdmins="systemAdmins"
          :creatingAdmin="creatingAdmin"
          :adminFormError="adminFormError"
          :adminFormSuccess="adminFormSuccess"
          @create-admin="handleCreateAdmin($event)"
        />

        <!-- TAB 8: NOTIFICATIONS BROADCAST -->
        <NotificationsTab 
          v-else-if="currentTab === 'notifications' || currentTab === 'sec_notifications'"
          :notifications="notifications"
          :sendingNotification="sendingNotification"
          :notifFormError="notifFormError"
          :notifFormSuccess="notifFormSuccess"
          @send-notification="handleSendNotification($event)"
        />

        <!-- TAB 9: CASHOUT & WITHDRAWALS MANAGEMENT -->
        <WithdrawalsTab 
          v-else-if="currentTab === 'sec_cashout' || currentTab === 'withdrawals'"
          @trigger-toast="triggerGlobalToast"
        />

        <!-- TAB 10: SYSTEM SETTINGS -->
        <SystemSettingsTab 
          v-else-if="currentTab === 'settings' || currentTab.startsWith('sec_')"
          :currentTab="currentTab"
          :systemSettings="systemSettings"
          :pendingRequestsCount="pendingRequestsCount"
          :qrStorageOption="qrStorageOption"
          :uploadingQr="uploadingQr"
          :qrUploadMsg="qrUploadMsg"
          :qrUploadSuccess="qrUploadSuccess"
          :savingSettings="savingSettings"
          :saveSettingsMsg="saveSettingsMsg"
          :saveSettingsSuccess="saveSettingsSuccess"
          @switch-tab="switchTab($event)"
          @qr-file-change="onQrFileSelected($event)"
          @upload-qr="handleQrUpload"
          @save-system-settings="handleSaveSystemSettings"
        />

        <!-- MODAL 1: ADD / DEDUCT FUNDS MODAL -->
        <AddFundsModal 
          :show="showAddFundsModal"
          :user="fundModalUser"
          :walletType="fundModalWalletType"
          :actionType="fundModalActionType"
          :amount="fundModalAmount"
          :remark="fundModalRemark"
          :submitting="submittingFunds"
          :msg="fundModalMsg"
          :success="fundModalSuccess"
          @update:walletType="fundModalWalletType = $event"
          @update:actionType="fundModalActionType = $event"
          @update:amount="fundModalAmount = $event"
          @update:remark="fundModalRemark = $event"
          @submit="submitAddFunds"
          @close="showAddFundsModal = false"
        />

        <!-- MODAL 2: USER TRANSACTIONS MODAL -->
        <UserTransactionsModal 
          :show="showUserTxnModal"
          :user="currentUserModalUser"
          :loading="loadingUserTxns"
          :searchQuery="userTxnSearch"
          :filteredTxnList="filteredUserTxnList"
          @update:searchQuery="userTxnSearch = $event"
          @close="showUserTxnModal = false"
        />

        <!-- MODAL 3: USER INCOME MODAL -->
        <UserIncomeModal 
          :show="showUserIncomeModal"
          :user="currentUserModalUser"
          :loading="loadingUserIncome"
          :incomeData="userIncomeData"
          @close="showUserIncomeModal = false"
        />

        <!-- DRAWER 1: USER PROFILE DRAWER -->
        <UserProfileDrawer 
          :user="selectedUser"
          :password="userNewPassword"
          :updatingPassword="updatingUserPassword"
          :msg="userPasswordMsg"
          :success="userPasswordSuccess"
          @update:password="userNewPassword = $event"
          @update-password="handleUpdateUserPassword($event)"
          @open-edit-user="openEditUserScreen($event); selectedUser = null"
          @open-add-funds="openAddFundsModal($event); selectedUser = null"
          @view-user-transactions="viewUserTransactions($event)"
          @view-user-income="viewUserIncome($event)"
          @close="selectedUser = null"
        />

        <!-- MODAL 4: PROOF OF PAYMENT RECEIPT MODAL -->
        <div v-if="selectedRequest" class="invoice-modal-backdrop" @click="selectedRequest = null">
          <div class="invoice-modal-container" @click.stop style="max-width: 500px; padding: 0; overflow: hidden; border-radius: 12px; background: white;">
            <div style="background: #0f172a; color: white; padding: 1rem 1.25rem; display: flex; align-items: center; justify-content: space-between;">
              <h3 style="margin: 0; font-size: 1.05rem;">📷 Payment Proof Receipt</h3>
              <button @click="selectedRequest = null" style="background: transparent; border: none; color: white; font-size: 1.4rem; cursor: pointer;">&times;</button>
            </div>
            <div style="padding: 1.25rem; text-align: center;">
              <img :src="selectedRequest.payment_proof_url" alt="Payment Receipt" style="max-width: 100%; border-radius: 8px; border: 1px solid #cbd5e1;" />
              <div style="margin-top: 1rem; text-align: left; font-size: 0.88rem; background: #f8fafc; padding: 0.85rem; border-radius: 8px;">
                <div><strong>UTR Number:</strong> {{ selectedRequest.utr_number || selectedRequest.utr }}</div>
                <div><strong>Amount:</strong> ₹{{ parseFloat(selectedRequest.amount).toFixed(2) }}</div>
                <div><strong>Payment Method:</strong> {{ selectedRequest.payment_method || 'UPI / QR' }}</div>
              </div>
            </div>
          </div>
        </div>

      </main>
    </div>
  </div>
</template>

<script>
import asetsLogo from '../assets/asets.png';
import DashboardOverviewTab from '../components/admin/DashboardOverviewTab.vue';
import UserManagementTab from '../components/admin/UserManagementTab.vue';
import EditUserTab from '../components/admin/EditUserTab.vue';
import FundRequestsTab from '../components/admin/FundRequestsTab.vue';
import TransactionsTab from '../components/admin/TransactionsTab.vue';
import TeamsTreeTab from '../components/admin/TeamsTreeTab.vue';
import AdminsManagementTab from '../components/admin/AdminsManagementTab.vue';
import NotificationsTab from '../components/admin/NotificationsTab.vue';
import SystemSettingsTab from '../components/admin/SystemSettingsTab.vue';
import WithdrawalsTab from '../components/admin/WithdrawalsTab.vue';
import AddFundsModal from '../components/admin/AddFundsModal.vue';
import UserTransactionsModal from '../components/admin/UserTransactionsModal.vue';
import UserIncomeModal from '../components/admin/UserIncomeModal.vue';
import UserProfileDrawer from '../components/admin/UserProfileDrawer.vue';

const getApiBaseUrl = () => {
  return 'https://api.srdigitalseva.com';
};
const API_BASE_URL = getApiBaseUrl();

export default {
  name: 'AdminDashboard',
  components: {
    DashboardOverviewTab,
    UserManagementTab,
    EditUserTab,
    FundRequestsTab,
    TransactionsTab,
    TeamsTreeTab,
    AdminsManagementTab,
    NotificationsTab,
    SystemSettingsTab,
    WithdrawalsTab,
    AddFundsModal,
    UserTransactionsModal,
    UserIncomeModal,
    UserProfileDrawer
  },
  data() {
    return {
      asetsLogo,
      currentTab: 'dashboard',
      mobileMenuOpen: false,
      profileDropdownOpen: false,
      adminEmail: localStorage.getItem('adminEmail') || 'srdigitalseva9@gmail.com',
      expandedGroups: {
        users: true,
        financials: true,
        settings: true
      },
      users: [],
      fundRequests: [],
      transactions: [],
      teamsData: { teams: [] },
      loadingTeams: false,
      systemAdmins: [],
      notifications: [],
      reqFilterStatus: '',
      reqSearchQuery: '',
      reqFilterMode: 'ALL',
      reqPaymentModeFilter: '',
      reqAmountFilter: '',
      userTableSearch: '',
      userStatusFilter: 'ALL',
      userSortBy: 'newest',
      selectedUser: null,
      selectedRequest: null,
      userPage: 1,
      // Dedicated Edit User Screen State
      editUserObj: {
        id: '',
        fullName: '',
        email: '',
        mobileNumber: '',
        password: '',
        showPassword: false,
        status: 'ACTIVE',
        sponsor_id: '',
        sponsor_name: '',
        createdAt: '',
        bank_name: '',
        account_holder: '',
        account_no: '',
        ifsc: '',
        branch: '',
        account_type: 'Savings',
        fund_wallet_balance: 0,
        main_wallet_balance: 0,
        income_wallet_balance: 0,
        captcha_wallet_balance: 320,
        downlineCount: 0
      },
      searchUserQuery: '',
      loadingUserEdit: false,
      updateUserMsg: '',
      updateUserSuccess: false,
      // User Specific Modal States
      showUserTxnModal: false,
      showUserIncomeModal: false,
      currentUserModalUser: null,
      userTxnList: [],
      loadingUserTxns: false,
      userTxnSearch: '',
      userIncomeData: { user: null, totalIncome: '0.00', directIncome: '0.00', singleLegIncome: '0.00', captchaIncome: '0.00', otherIncome: '0.00', transactions: [], downlines: [] },
      loadingUserIncome: false,
      // Add / Deduct Funds Modal State
      showAddFundsModal: false,
      fundModalUser: null,
      fundModalWalletType: 'MAIN',
      fundModalActionType: 'CREDIT',
      fundModalAmount: '',
      fundModalRemark: '',
      submittingFunds: false,
      fundModalMsg: '',
      fundModalSuccess: false,
      // QR Code Upload State
      qrStorageOption: 'file',
      qrPreviewUrl: '',
      selectedQrFile: null,
      uploadingQr: false,
      qrUploadMsg: '',
      qrUploadSuccess: false,
      txnPage: 1,
      loading: true,
      error: '',
      gatewayStatus: {
        database: 'Operational (Online)',
        app_api: 'Operational (Online)',
        scriza_api: 'Operational (Live)',
        razorpay_gateway: 'Operational (Live)'
      },
      savingSettings: false,
      saveSettingsMsg: '',
      saveSettingsSuccess: false,
      systemSettings: {
        join_amount: 1200,
        top_up_amount: 1200,
        direct_income: 300,
        single_leg_pool_income: 600,
        company_maintenance_charge: 300,
        withdrawal_deduction_percent: 15,
        min_withdrawal: 500,
        withdrawal_days: 'Monday, Wednesday, Friday',
        level_1_members: 2,
        level_1_income: 50,
        level_2_members: 4,
        level_2_income: 100,
        level_3_members: 8,
        level_3_income: 150,
        level_4_members: 16,
        level_4_income: 200,
        level_5_members: 32,
        level_5_income: 300,
        level_6_members: 64,
        level_6_income: 400,
        upi_qr_url: ''
      },
      userNewPassword: '',
      updatingUserPassword: false,
      userPasswordMsg: '',
      userPasswordSuccess: false,
      creatingAdmin: false,
      adminFormError: '',
      adminFormSuccess: '',
      sendingNotification: false,
      notifFormError: '',
      notifFormSuccess: '',
      globalToast: {
        show: false,
        message: '',
        type: 'success'
      }
    };
  },
  computed: {
    filteredUserTxnList() {
      if (!this.userTxnList) return [];
      const q = (this.userTxnSearch || '').toLowerCase().trim();
      if (!q) return this.userTxnList;
      return this.userTxnList.filter(tx => {
        return (tx.type && tx.type.toLowerCase().includes(q)) ||
               (tx.wallet_type && tx.wallet_type.toLowerCase().includes(q)) ||
               (tx.status && tx.status.toLowerCase().includes(q)) ||
               (tx.date && tx.date.toLowerCase().includes(q)) ||
               (tx.amount && String(tx.amount).includes(q));
      });
    },
    pendingRequestsCount() {
      return this.fundRequests.filter(r => r.status === 'PENDING').length;
    },
    filteredRequests() {
      return this.fundRequests.filter(req => {
        const matchesStatus = !this.reqFilterStatus || req.status === this.reqFilterStatus;
        const q = this.reqSearchQuery.toLowerCase();
        const matchesQuery = !q || 
          (req.fullName && req.fullName.toLowerCase().includes(q)) ||
          (req.mobileNumber && req.mobileNumber.includes(q)) ||
          (req.utr_number && req.utr_number.toLowerCase().includes(q));
        const matchesPM = !this.reqPaymentModeFilter || (req.payment_method && req.payment_method.includes(this.reqPaymentModeFilter));
        const matchesAmt = !this.reqAmountFilter || String(req.amount) === this.reqAmountFilter;
        return matchesStatus && matchesQuery && matchesPM && matchesAmt;
      });
    },
    filteredUsers() {
      let list = [...(this.users || [])];
      const q = (this.userTableSearch || '').toLowerCase().trim();
      
      if (q) {
        list = list.filter(u => 
          (u.fullName && u.fullName.toLowerCase().includes(q)) ||
          (u.mobileNumber && u.mobileNumber.toLowerCase().includes(q)) ||
          (u.email && u.email.toLowerCase().includes(q)) ||
          (String(u.id).toLowerCase().includes(q))
        );
      }

      if (this.userStatusFilter && this.userStatusFilter !== 'ALL') {
        list = list.filter(u => (u.status || 'ACTIVE').toUpperCase() === this.userStatusFilter.toUpperCase());
      }

      if (this.userSortBy === 'oldest') {
        list.sort((a, b) => a.id - b.id);
      } else if (this.userSortBy === 'name') {
        list.sort((a, b) => (a.fullName || '').localeCompare(b.fullName || ''));
      } else if (this.userSortBy === 'balance') {
        list.sort((a, b) => parseFloat(b.main_wallet_balance || 0) - parseFloat(a.main_wallet_balance || 0));
      } else {
        list.sort((a, b) => b.id - a.id);
      }

      return list;
    }
  },
  mounted() {
    this.fetchDashboardData();
    this.fetchUsers();
    this.fetchFundRequests();
    this.fetchTransactions();
    this.fetchTeams();
    this.fetchSystemSettings();
    this.fetchSystemAdmins();
    this.fetchNotifications();
  },
  methods: {
    triggerGlobalToast(msg, type = 'success') {
      this.globalToast.message = msg;
      this.globalToast.type = type;
      this.globalToast.show = true;
      setTimeout(() => {
        this.globalToast.show = false;
      }, 1500);
    },
    formatTabTitle(tab) {
      const names = {
        dashboard: 'Dashboard Overview',
        users: 'Registered Mobile App Users',
        edit_user: 'Edit User Details',
        requests: 'Add Money / Fund Requests',
        transactions: 'Platform Transactions & Ledger',
        teams: 'User Teams & Downlines',
        admins: 'System Administrator Accounts',
        notifications: 'Push Notification Broadcasts',
        sec_cashout: 'Payout & Withdrawal Management',
        withdrawals: 'Payout & Withdrawal Management',
        settings: 'Global App System Settings'
      };
      return names[tab] || 'Control Panel';
    },
    async fetchDashboardData() {
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/dashboard`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          const data = await res.json();
          if (data.users) this.users = data.users;
          if (data.fundRequests) this.fundRequests = data.fundRequests;
          if (data.transactions) this.transactions = data.transactions;
        }
      } catch (e) {
        console.error('Error fetching dashboard data:', e);
      }
    },
    async fetchUsers() {
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/dashboard`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          const data = await res.json();
          this.users = data.users || [];
        }
      } catch (e) {
        console.error('Error fetching users:', e);
      }
    },
    async fetchFundRequests() {
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/fund-requests`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          this.fundRequests = await res.json();
        }
      } catch (e) {
        console.error('Error fetching fund requests:', e);
      }
    },
    async fetchTransactions(page = 1) {
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/transactions?page=${page}`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          const data = await res.json();
          if (Array.isArray(data) && data.length > 0) {
            this.transactions = data;
            this.txnPage = page;
          }
        }
      } catch (e) {
        console.error('Error fetching transactions:', e);
      }
    },
    async fetchTeams() {
      this.loadingTeams = true;
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/teams`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          this.teamsData = await res.json();
        }
      } catch (e) {
        console.error('Error fetching teams:', e);
      } finally {
        this.loadingTeams = false;
      }
    },
    async fetchSystemSettings() {
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/settings`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          const settingsObj = await res.json();
          this.systemSettings = { ...this.systemSettings, ...settingsObj };
        }
      } catch (e) {
        console.error('Error fetching system settings:', e);
      }
    },
    async fetchSystemAdmins() {
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/system-admins`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          this.systemAdmins = await res.json();
        }
      } catch (e) {
        console.error('Error fetching system admins:', e);
      }
    },
    async fetchNotifications() {
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/notifications`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          this.notifications = await res.json();
        }
      } catch (e) {
        console.error('Error fetching notifications:', e);
      }
    },
    openEditUserScreen(user) {
      if (!user) return;
      this.searchUserQuery = user.mobileNumber || String(user.id || '');
      this.fetchUserForEdit(user.id || user.mobileNumber);
    },
    async fetchUserForEdit(identifier) {
      this.loadingUserEdit = true;
      this.updateUserMsg = '';
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/users/${identifier}`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        const text = await res.text();
        let data = {};
        try { data = JSON.parse(text); } catch(e) { throw new Error(`Server response error (${res.status})`); }
        if (!res.ok) throw new Error(data.error || 'Failed to fetch user details');
        
        this.editUserObj = {
          ...data,
          password: '',
          showPassword: false,
          bank_name: data.bank_name || '',
          account_holder: data.account_holder || '',
          account_no: data.account_no || '',
          ifsc: data.ifsc || '',
          branch: data.branch || '',
          account_type: data.account_type || 'Savings'
        };
        this.currentTab = 'edit_user';
      } catch (e) {
        this.updateUserMsg = e.message;
        this.updateUserSuccess = false;
      } finally {
        this.loadingUserEdit = false;
      }
    },
    async handleSaveUserDetails() {
      if (!this.editUserObj.id) {
        alert('No user selected for update.');
        return;
      }
      this.loadingUserEdit = true;
      this.updateUserMsg = '';
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/users/${this.editUserObj.id}`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({
            fullName: this.editUserObj.fullName,
            email: this.editUserObj.email,
            mobileNumber: this.editUserObj.mobileNumber,
            password: this.editUserObj.password,
            status: this.editUserObj.status,
            sponsor_id: this.editUserObj.sponsor_id,
            createdAt: this.editUserObj.createdAt,
            bank_name: this.editUserObj.bank_name,
            account_holder: this.editUserObj.account_holder,
            account_no: this.editUserObj.account_no,
            ifsc: this.editUserObj.ifsc,
            branch: this.editUserObj.branch,
            account_type: this.editUserObj.account_type
          })
        });
        const text = await res.text();
        let data = {};
        try { data = JSON.parse(text); } catch(e) { throw new Error(`Server response error (${res.status})`); }
        if (!res.ok) throw new Error(data.error || 'Failed to update user details');
        
        this.updateUserMsg = 'User details updated successfully!';
        this.updateUserSuccess = true;
        this.triggerSuccessToast('User Details Updated Successfully!', 1500);
        this.fetchUsers();
      } catch (e) {
        this.updateUserMsg = e.message;
        this.updateUserSuccess = false;
      } finally {
        this.loadingUserEdit = false;
      }
    },
    openAddFundsModal(user) {
      this.fundModalUser = user || this.editUserObj;
      this.fundModalAmount = '';
      this.fundModalRemark = '';
      this.fundModalMsg = '';
      this.showAddFundsModal = true;
    },
    async submitAddFunds() {
      if (!this.fundModalAmount || parseFloat(this.fundModalAmount) <= 0) {
        this.fundModalMsg = 'Please enter a valid amount.';
        this.fundModalSuccess = false;
        return;
      }
      this.submittingFunds = true;
      this.fundModalMsg = '';
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/users/${this.fundModalUser.id}/adjust-wallet`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({
            wallet_type: this.fundModalWalletType,
            action_type: this.fundModalActionType,
            amount: parseFloat(this.fundModalAmount),
            remark: this.fundModalRemark
          })
        });
        const text = await res.text();
        let data = {};
        try { data = JSON.parse(text); } catch(e) { throw new Error(`Server response error (${res.status})`); }
        if (!res.ok) throw new Error(data.error || 'Failed to adjust wallet');

        this.fundModalMsg = data.message || 'Wallet adjusted successfully!';
        this.fundModalSuccess = true;
        setTimeout(() => {
          this.showAddFundsModal = false;
          this.fetchUsers();
          if (this.editUserObj && this.editUserObj.id === this.fundModalUser.id) {
            this.fetchUserForEdit(this.editUserObj.id);
          }
        }, 1200);
      } catch (e) {
        this.fundModalMsg = e.message;
        this.fundModalSuccess = false;
      } finally {
        this.submittingFunds = false;
      }
    },
    onQrFileSelected(event) {
      const file = event.target.files[0];
      if (file) {
        this.selectedQrFile = file;
        const reader = new FileReader();
        reader.onload = (e) => {
          this.systemSettings.upi_qr_url = e.target.result;
        };
        reader.readAsDataURL(file);
      }
    },
    async handleQrUpload() {
      this.uploadingQr = true;
      this.qrUploadMsg = '';
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/upload-qr`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({
            qrImageUrl: this.systemSettings.upi_qr_url
          })
        });
        const text = await res.text();
        let data = {};
        try { data = JSON.parse(text); } catch(e) { throw new Error(`Server response error (${res.status})`); }
        if (!res.ok) throw new Error(data.error || 'Failed to upload QR code');

        this.systemSettings.upi_qr_url = data.upi_qr_url;
        this.qrUploadMsg = 'QR Code updated successfully!';
        this.qrUploadSuccess = true;
        this.handleSaveSystemSettings();
      } catch (e) {
        this.qrUploadMsg = e.message;
        this.qrUploadSuccess = false;
      } finally {
        this.uploadingQr = false;
      }
    },
    async viewUserTransactions(user) {
      if (!user || (!user.id && !user.mobileNumber)) return;
      this.currentUserModalUser = user;
      this.showUserTxnModal = true;
      this.loadingUserTxns = true;
      this.userTxnList = [];
      this.userTxnSearch = '';
      try {
        const token = localStorage.getItem('adminToken') || '';
        const targetId = user.id || user.mobileNumber;
        const res = await fetch(`${API_BASE_URL}/api/admin/transactions?user_id=${encodeURIComponent(targetId)}`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        const text = await res.text();
        let data = [];
        try { data = JSON.parse(text); } catch(e) { data = []; }
        if (res.ok && Array.isArray(data)) {
          this.userTxnList = data;
        }
      } catch (e) {
        console.error('Error loading user transactions modal:', e);
      } finally {
        this.loadingUserTxns = false;
      }
    },
    async viewUserIncome(user) {
      if (!user || (!user.id && !user.mobileNumber)) return;
      this.currentUserModalUser = user;
      this.showUserIncomeModal = true;
      this.loadingUserIncome = true;
      this.userIncomeData = { user: null, totalIncome: '0.00', directIncome: '0.00', singleLegIncome: '0.00', captchaIncome: '0.00', otherIncome: '0.00', transactions: [], downlines: [] };
      try {
        const token = localStorage.getItem('adminToken') || '';
        const targetId = user.id || user.mobileNumber;
        const res = await fetch(`${API_BASE_URL}/api/admin/users/${encodeURIComponent(targetId)}/income`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        const text = await res.text();
        let data = {};
        try { data = JSON.parse(text); } catch(e) { data = {}; }
        if (res.ok && data.user) {
          this.userIncomeData = data;
        }
      } catch (e) {
        console.error('Error loading user income details modal:', e);
      } finally {
        this.loadingUserIncome = false;
      }
    },
    focusUserPassword(user) {
      if (this.$refs.userPasswordInput) {
        this.$refs.userPasswordInput.focus();
      }
    },
    loginAsUserPreview(user) {
      alert(`Simulating login preview as ${user.fullName || user.email} (User #${user.id})`);
    },
    toggleGroup(groupKey) {
      this.expandedGroups[groupKey] = !this.expandedGroups[groupKey];
    },
    switchTab(tab) {
      this.currentTab = tab;
      this.mobileMenuOpen = false;
      if (tab === 'notifications' || tab === 'sec_notifications') {
        this.fetchNotifications();
      }
    },
    async handleApproveRequest(reqId) {
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/fund-requests/${reqId}/approve`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          this.fetchFundRequests();
          this.fetchUsers();
        }
      } catch (e) {
        console.error('Error approving fund request:', e);
      }
    },
    async handleRejectRequest(reqId) {
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/fund-requests/${reqId}/reject`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (res.ok) {
          this.fetchFundRequests();
        }
      } catch (e) {
        console.error('Error rejecting fund request:', e);
      }
    },
    async handleUpdateUserPassword(userId) {
      if (!this.userNewPassword || this.userNewPassword.trim().length < 4) {
        this.userPasswordMsg = 'Password must be at least 4 characters.';
        this.userPasswordSuccess = false;
        return;
      }
      this.updatingUserPassword = true;
      this.userPasswordMsg = '';
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/users/${userId}/update-password`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({ newPassword: this.userNewPassword.trim() })
        });
        if (!res.ok) throw new Error('Failed to update password');

        this.userPasswordMsg = 'Password updated successfully!';
        this.userPasswordSuccess = true;
        this.userNewPassword = '';
      } catch (e) {
        this.userPasswordMsg = e.message;
        this.userPasswordSuccess = false;
      } finally {
        this.updatingUserPassword = false;
      }
    },
    async handleCreateAdmin(adminData) {
      this.creatingAdmin = true;
      this.adminFormError = '';
      this.adminFormSuccess = '';
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/create-admin`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify(adminData)
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Failed to create admin account');

        this.adminFormSuccess = 'Admin account created successfully!';
        this.fetchSystemAdmins();
      } catch (e) {
        this.adminFormError = e.message;
      } finally {
        this.creatingAdmin = false;
      }
    },
    async handleSendNotification(notifData) {
      this.sendingNotification = true;
      this.notifFormError = '';
      this.notifFormSuccess = '';
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/notifications`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify(notifData)
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Failed to broadcast notification');

        this.notifFormSuccess = 'Notification broadcast sent successfully!';
        this.fetchNotifications();
      } catch (e) {
        this.notifFormError = e.message;
      } finally {
        this.sendingNotification = false;
      }
    },
    async handleSaveSystemSettings() {
      this.savingSettings = true;
      this.saveSettingsMsg = '';
      try {
        const token = localStorage.getItem('adminToken') || '';
        const res = await fetch(`${API_BASE_URL}/api/admin/settings`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify(this.systemSettings)
        });
        if (!res.ok) throw new Error('Failed to update system settings');

        this.saveSettingsMsg = 'All system settings saved successfully!';
        this.saveSettingsSuccess = true;
        this.triggerSuccessToast('All System Settings Saved Successfully!', 1500);
      } catch (e) {
        this.saveSettingsMsg = e.message;
        this.saveSettingsSuccess = false;
      } finally {
        this.savingSettings = false;
      }
    },
    triggerSuccessToast(msg, duration = 1500) {
      this.globalToast.message = msg;
      this.globalToast.show = true;
      if (this.globalToastTimer) clearTimeout(this.globalToastTimer);
      this.globalToastTimer = setTimeout(() => {
        this.globalToast.show = false;
      }, duration);
    },
    copyToClipboard(text) {
      if (!text) return;
      navigator.clipboard.writeText(String(text));
      alert('Copied to clipboard: ' + text);
    },
    handleLogout() {
      localStorage.removeItem('adminToken');
      localStorage.removeItem('adminEmail');
      this.$router.push('/admin/login');
    }
  }
};
</script>

<style>
@import '../assets/admin_dashboard.css';
</style>
