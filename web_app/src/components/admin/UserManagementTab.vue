<template>
  <div class="users-list-pane" style="padding: 1.25rem; max-width: 100%; box-sizing: border-box;">
    <div class="table-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03); margin-bottom: 1.5rem;">
      <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; flex-wrap: wrap; gap: 0.75rem;">
        <div>
          <h3 style="margin: 0; font-size: 1.25rem; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px;">
            <span>📱</span> Registered Mobile App Users & Members
          </h3>
          <p style="margin: 4px 0 0; font-size: 0.83rem; color: #64748b;">Manage user accounts, balances, and downline team statistics.</p>
        </div>
        <span class="count-pill" style="background: #eff6ff; color: #2563eb; font-weight: 800; font-size: 0.85rem; padding: 0.4rem 0.9rem; border-radius: 20px; border: 1px solid #bfdbfe;">
          {{ filteredUsers.length }} Total Members
        </span>
      </div>

      <!-- SEARCH & FILTER TOOLBAR -->
      <div class="filter-toolbar" style="display: flex; gap: 1rem; margin-bottom: 1.25rem; flex-wrap: wrap; align-items: center; justify-content: space-between; background: #f8fafc; padding: 1rem 1.25rem; border-radius: 10px; border: 1px solid #e2e8f0;">
        <div style="flex: 1; min-width: 260px; position: relative;">
          <input 
            type="text" 
            v-model="userTableSearchLocal" 
            @input="$emit('update:userTableSearch', userTableSearchLocal)"
            placeholder="Search by Mobile Number, User ID, Name, or Email..." 
            style="width: 100%; padding: 0.65rem 0.85rem 0.65rem 2.2rem; border-radius: 8px; border: 1px solid #cbd5e1; outline: none; font-size: 0.88rem; box-sizing: border-box; background: white;"
          />
          <span style="position: absolute; left: 10px; top: 10px; color: #64748b;">🔍</span>
        </div>

        <div style="display: flex; gap: 1rem; align-items: center; flex-wrap: wrap;">
          <div style="display: flex; align-items: center; gap: 6px;">
            <label style="font-size: 0.82rem; font-weight: 700; color: #475569;">Status:</label>
            <select 
              v-model="userStatusFilterLocal" 
              @change="$emit('update:userStatusFilter', userStatusFilterLocal)"
              style="padding: 0.6rem 0.85rem; border-radius: 8px; border: 1px solid #cbd5e1; outline: none; font-weight: 700; font-size: 0.85rem; background: white; cursor: pointer;"
            >
              <option value="ALL">All Statuses</option>
              <option value="ACTIVE">🟢 Active</option>
              <option value="PENDING">🟡 Pending</option>
              <option value="BLOCKED">🔴 Blocked</option>
              <option value="INACTIVE">⚪ Inactive</option>
            </select>
          </div>

          <div style="display: flex; align-items: center; gap: 6px;">
            <label style="font-size: 0.82rem; font-weight: 700; color: #475569;">Sort By:</label>
            <select 
              v-model="userSortByLocal" 
              @change="$emit('update:userSortBy', userSortByLocal)"
              style="padding: 0.6rem 0.85rem; border-radius: 8px; border: 1px solid #cbd5e1; outline: none; font-weight: 700; font-size: 0.85rem; background: white; cursor: pointer;"
            >
              <option value="newest">Newest First</option>
              <option value="oldest">Oldest First</option>
              <option value="name">Name (A-Z)</option>
              <option value="balance">Highest Wallet Balance</option>
            </select>
          </div>
        </div>
      </div>

      <!-- TABLE CONTAINER -->
      <div class="table-container" style="overflow-x: auto; max-width: 100%; border-radius: 8px; border: 1px solid #e2e8f0;">
        <table class="nice-table" style="width: 100%; border-collapse: collapse; text-align: left; font-size: 0.88rem;">
          <thead>
            <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 700;">
              <th style="padding: 0.75rem 1rem;">User ID</th>
              <th style="padding: 0.75rem 1rem;">Full Name</th>
              <th style="padding: 0.75rem 1rem;">Email</th>
              <th style="padding: 0.75rem 1rem;">Mobile Number</th>
              <th style="padding: 0.75rem 1rem;">Main Wallet</th>
              <th style="padding: 0.75rem 1rem;">Fund Wallet</th>
              <th style="padding: 0.75rem 1rem;">Affiliate Downlines</th>
              <th style="padding: 0.75rem 1rem; text-align: right;">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="filteredUsers.length === 0">
              <td colspan="8" style="text-align: center; padding: 2.5rem; color: #64748b; font-weight: 600;">
                No registered users found matching your search.
              </td>
            </tr>
            <tr 
              v-for="user in filteredUsers" 
              :key="user.id" 
              class="clickable-row" 
              @click="$emit('select-user', user)"
              style="border-bottom: 1px solid #f1f5f9; cursor: pointer; transition: background 0.15s;"
            >
              <td style="padding: 0.85rem 1rem; font-weight: 700; color: #2563eb;">#{{ user.id }}</td>
              <td style="padding: 0.85rem 1rem; font-weight: 700; color: #0f172a;">{{ user.fullName }}</td>
              <td style="padding: 0.85rem 1rem; color: #64748b;">{{ user.email || 'N/A' }}</td>
              <td style="padding: 0.85rem 1rem; font-weight: 600; color: #1e293b;">{{ user.mobileNumber }}</td>
              <td style="padding: 0.85rem 1rem; font-weight: 700; color: #2563eb;">₹ {{ parseFloat(user.main_wallet_balance || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</td>
              <td style="padding: 0.85rem 1rem; font-weight: 700; color: #16a34a;">₹ {{ parseFloat(user.fund_wallet_balance || 0).toLocaleString('en-IN', {minimumFractionDigits:2}) }}</td>
              <td style="padding: 0.85rem 1rem;">
                <span style="background: #f0fdf4; color: #166534; padding: 3px 8px; border-radius: 12px; font-weight: 700; font-size: 0.78rem; border: 1px solid #bbf7d0;">
                  {{ user.downlineCount || 0 }} Members
                </span>
              </td>
              <td style="padding: 0.85rem 1rem; text-align: right; white-space: nowrap;">
                <button @click.stop="$emit('open-edit-user', user)" class="btn-action-view" style="background: #2563eb; color: white; border: none; padding: 6px 12px; border-radius: 6px; font-weight: 700; font-size: 0.78rem; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">✏️ Edit</button>
                <button @click.stop="$emit('open-add-funds', user)" style="background: #10b981; color: white; border: none; padding: 6px 12px; border-radius: 6px; font-weight: 700; font-size: 0.78rem; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; margin-left: 6px;">➕ Funds</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'UserManagementTab',
  props: {
    filteredUsers: { type: Array, default: () => [] },
    userTableSearch: { type: String, default: '' },
    userStatusFilter: { type: String, default: 'ALL' },
    userSortBy: { type: String, default: 'newest' }
  },
  data() {
    return {
      userTableSearchLocal: this.userTableSearch,
      userStatusFilterLocal: this.userStatusFilter,
      userSortByLocal: this.userSortBy
    };
  },
  watch: {
    userTableSearch(newVal) { this.userTableSearchLocal = newVal; },
    userStatusFilter(newVal) { this.userStatusFilterLocal = newVal; },
    userSortBy(newVal) { this.userSortByLocal = newVal; }
  }
};
</script>
