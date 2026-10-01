<template>
  <div class="users-list-pane">
    <div class="table-card">
      <div class="card-title-row">
        <h3>📱 Registered Mobile App Users & Members</h3>
        <span class="count-pill">{{ filteredUsers.length }} Total Members</span>
      </div>

      <!-- SEARCH & FILTER TOOLBAR -->
      <div class="filter-toolbar" style="display: flex; gap: 1rem; margin-bottom: 1.25rem; flex-wrap: wrap; align-items: center; justify-content: space-between; background: #f8fafc; padding: 1rem; border-radius: 10px; border: 1px solid #e2e8f0;">
        <div style="flex: 1; min-width: 260px; position: relative;">
          <input 
            type="text" 
            v-model="userTableSearchLocal" 
            @input="$emit('update:userTableSearch', userTableSearchLocal)"
            placeholder="🔍 Search by Mobile Number, User ID, Name, or Email..." 
            style="width: 100%; padding: 0.65rem 0.85rem 0.65rem 2.2rem; border-radius: 8px; border: 1px solid #cbd5e1; outline: none; font-size: 0.88rem; box-sizing: border-box;"
          />
          <span style="position: absolute; left: 10px; top: 10px; color: #64748b;">🔍</span>
        </div>

        <div style="display: flex; gap: 0.75rem; align-items: center; flex-wrap: wrap;">
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
      <div class="table-container">
        <table class="nice-table">
          <thead>
            <tr>
              <th>User ID</th>
              <th>Full Name</th>
              <th>Email</th>
              <th>Mobile Number</th>
              <th>Main Wallet</th>
              <th>Fund Wallet</th>
              <th>Affiliate Downlines</th>
              <th>Details</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="filteredUsers.length === 0">
              <td colspan="8" style="text-align: center; padding: 2rem; color: #64748b; font-weight: 600;">
                No registered users found matching "{{ userTableSearch }}".
              </td>
            </tr>
            <tr v-for="user in filteredUsers" :key="user.id" class="clickable-row" @click="$emit('select-user', user)">
              <td>#{{ user.id }}</td>
              <td class="font-bold">{{ user.fullName }}</td>
              <td>{{ user.email }}</td>
              <td>{{ user.mobileNumber }}</td>
              <td>₹{{ parseFloat(user.main_wallet_balance || 0).toFixed(2) }}</td>
              <td>₹{{ parseFloat(user.fund_wallet_balance || 0).toFixed(2) }}</td>
              <td>
                <span class="badge-status-active">{{ user.downlineCount || 0 }} Members</span>
              </td>
              <td style="white-space: nowrap;">
                <button @click.stop="$emit('open-edit-user', user)" class="btn-action-view" style="background: #2563eb; color: white; border: none; padding: 5px 10px; border-radius: 6px; font-weight: 700; font-size: 11px; cursor: pointer; display: inline-flex; align-items: center; gap: 4px;">✏️ Edit User</button>
                <button @click.stop="$emit('open-add-funds', user)" style="background: #10b981; color: white; border: none; padding: 5px 10px; border-radius: 6px; font-weight: 700; font-size: 11px; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; margin-left: 4px;">➕ Add Funds</button>
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
