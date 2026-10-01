<template>
  <div class="teams-pane">
    <div class="table-card">
      <div class="card-title-row">
        <h3>👥 User Teams & Multi-Level Affiliate Downlines</h3>
      </div>
      <p class="card-desc">Real-time sponsor tree queried directly from user registrations.</p>
      
      <div v-if="loadingTeams" class="loading-box" style="text-align: center; padding: 2rem; color: #64748b; font-weight: 700;">
        ⏳ Loading team tree data...
      </div>
      
      <div v-else-if="!teamsData || !teamsData.teams || teamsData.teams.length === 0" class="empty-box" style="text-align: center; padding: 2rem; background: #f8fafc; border-radius: 8px; color: #64748b; font-weight: 600;">
        No active affiliate team relationships recorded yet.
      </div>

      <div v-else class="teams-grid" style="display: flex; flex-direction: column; gap: 1rem; margin-top: 1rem;">
        <div v-for="team in teamsData.teams" :key="team.sponsor.id" class="team-card" style="border: 1px solid #cbd5e1; border-radius: 8px; padding: 1rem; background: white;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem;">
            <div>
              <span style="font-weight: 800; color: #1e293b; font-size: 1rem;">👤 {{ team.sponsor.fullName }}</span>
              <span style="font-size: 0.8rem; color: #64748b; margin-left: 8px;">(Mobile: {{ team.sponsor.mobileNumber }} | ID: #{{ team.sponsor.id }})</span>
            </div>
            <span class="badge-status-active">{{ team.directMembers.length }} Direct Members</span>
          </div>

          <div class="table-container">
            <table class="nice-table" style="width: 100%;">
              <thead>
                <tr style="background: #f8fafc; font-size: 0.8rem; color: #475569;">
                  <th>Member ID</th>
                  <th>Member Name</th>
                  <th>Mobile Number</th>
                  <th>Email</th>
                  <th>Join Date</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="member in team.directMembers" :key="member.id">
                  <td>#{{ member.id }}</td>
                  <td class="font-bold">{{ member.fullName }}</td>
                  <td>{{ member.mobileNumber }}</td>
                  <td>{{ member.email }}</td>
                  <td>{{ member.createdAt ? String(member.createdAt).substring(0, 10) : 'N/A' }}</td>
                  <td>
                    <span class="badge-status-active">{{ member.status || 'ACTIVE' }}</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TeamsTreeTab',
  props: {
    teamsData: { type: Object, default: () => ({ teams: [] }) },
    loadingTeams: { type: Boolean, default: false }
  }
};
</script>
