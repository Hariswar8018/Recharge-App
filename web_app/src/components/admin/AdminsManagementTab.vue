<template>
  <div class="admins-management-pane">
    <div style="display: grid; grid-template-columns: 1fr 340px; gap: 1.5rem;">
      <!-- SYSTEM ADMINS LIST TABLE -->
      <div class="table-card">
        <div class="card-title-row">
          <h3>🔐 System Administrator Users & Roles</h3>
          <span class="count-pill">{{ systemAdmins.length }} Admins</span>
        </div>

        <div class="table-container">
          <table class="nice-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Full Name</th>
                <th>Email</th>
                <th>Mobile Number</th>
                <th>Role</th>
                <th>Created</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="systemAdmins.length === 0">
                <td colspan="6" style="text-align: center; padding: 2rem; color: #64748b;">
                  No admin users found.
                </td>
              </tr>
              <tr v-for="adm in systemAdmins" :key="adm.id">
                <td>#{{ adm.id }}</td>
                <td class="font-bold">{{ adm.fullName }}</td>
                <td>{{ adm.email }}</td>
                <td>{{ adm.mobileNumber || 'N/A' }}</td>
                <td>
                  <span style="background: #eff6ff; color: #1d4ed8; padding: 2px 8px; border-radius: 12px; font-weight: 800; font-size: 0.75rem;">
                    {{ (adm.role || 'ADMIN').toUpperCase() }}
                  </span>
                </td>
                <td>{{ adm.createdAt ? String(adm.createdAt).substring(0, 10) : 'N/A' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- CREATE ADMIN FORM -->
      <div class="form-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem;">
        <h3 style="margin: 0 0 1rem; font-size: 1.05rem; font-weight: 800; color: #1e293b;">
          ➕ Add New Admin Account
        </h3>

        <form @submit.prevent="$emit('create-admin', newAdminFormLocal)">
          <div class="form-group" style="margin-bottom: 0.85rem;">
            <label style="font-size: 0.82rem; font-weight: 700; color: #475569;">Full Name</label>
            <input type="text" v-model="newAdminFormLocal.fullName" placeholder="Admin Name" class="input-styled" required style="width: 100%; box-sizing: border-box;" />
          </div>

          <div class="form-group" style="margin-bottom: 0.85rem;">
            <label style="font-size: 0.82rem; font-weight: 700; color: #475569;">Email Address</label>
            <input type="email" v-model="newAdminFormLocal.email" placeholder="admin@domain.com" class="input-styled" required style="width: 100%; box-sizing: border-box;" />
          </div>

          <div class="form-group" style="margin-bottom: 0.85rem;">
            <label style="font-size: 0.82rem; font-weight: 700; color: #475569;">Mobile Number</label>
            <input type="text" v-model="newAdminFormLocal.mobileNumber" placeholder="10-digit mobile" class="input-styled" style="width: 100%; box-sizing: border-box;" />
          </div>

          <div class="form-group" style="margin-bottom: 0.85rem;">
            <label style="font-size: 0.82rem; font-weight: 700; color: #475569;">Password</label>
            <input type="password" v-model="newAdminFormLocal.password" placeholder="Password" class="input-styled" required style="width: 100%; box-sizing: border-box;" />
          </div>

          <div class="form-group" style="margin-bottom: 1.25rem;">
            <label style="font-size: 0.82rem; font-weight: 700; color: #475569;">Role Privilege</label>
            <select v-model="newAdminFormLocal.role" class="input-styled select-styled" style="width: 100%; box-sizing: border-box;">
              <option value="superadmin">Super Admin (Full Access)</option>
              <option value="admin">Administrator</option>
              <option value="support">Support Agent</option>
            </select>
          </div>

          <div v-if="adminFormError" style="color: #ef4444; font-size: 0.8rem; margin-bottom: 0.85rem; font-weight: bold;">
            {{ adminFormError }}
          </div>
          <div v-if="adminFormSuccess" style="color: #16a34a; font-size: 0.8rem; margin-bottom: 0.85rem; font-weight: bold;">
            {{ adminFormSuccess }}
          </div>

          <button type="submit" :disabled="creatingAdmin" style="width: 100%; background: #2563eb; color: white; border: none; padding: 0.65rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            {{ creatingAdmin ? 'Creating...' : '🚀 Create Admin Account' }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdminsManagementTab',
  props: {
    systemAdmins: { type: Array, default: () => [] },
    creatingAdmin: { type: Boolean, default: false },
    adminFormError: { type: String, default: '' },
    adminFormSuccess: { type: String, default: '' }
  },
  data() {
    return {
      newAdminFormLocal: {
        fullName: '',
        email: '',
        mobileNumber: '',
        password: '',
        role: 'admin'
      }
    };
  }
};
</script>
