<template>
  <div class="teams-pane" style="padding: 1.25rem; max-width: 100%; box-sizing: border-box;">
    <div class="table-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03); margin-bottom: 1.5rem;">
      <div class="card-title-row" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.75rem;">
        <div>
          <h3 style="margin: 0; font-size: 1.25rem; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px;">
            <span>👥</span> Member Teams & Affiliate Downline Tree
          </h3>
          <p style="margin: 4px 0 0; font-size: 0.83rem; color: #64748b;">
            Real-time sponsor tree & downline referral relationships.
          </p>
        </div>
        <div style="display: flex; gap: 0.5rem; align-items: center;">
          <span style="background: #f0fdf4; color: #166534; font-weight: 800; font-size: 0.85rem; padding: 0.4rem 0.9rem; border-radius: 20px; border: 1px solid #bbf7d0;">
            {{ displayTeams.length }} Sponsor Teams
          </span>
          <span style="background: #eff6ff; color: #2563eb; font-weight: 800; font-size: 0.85rem; padding: 0.4rem 0.9rem; border-radius: 20px; border: 1px solid #bfdbfe;">
            {{ totalDownlinesCount }} Total Network Members
          </span>
        </div>
      </div>

      <!-- SEARCH TOOLBAR -->
      <div class="filter-toolbar" style="margin-bottom: 1.25rem; background: #f8fafc; padding: 0.85rem 1.25rem; border-radius: 10px; border: 1px solid #e2e8f0; display: flex; gap: 1rem; align-items: center; flex-wrap: wrap;">
        <div style="flex: 1; min-width: 260px; position: relative;">
          <input 
            type="text" 
            v-model="searchQuery" 
            placeholder="Search team by Sponsor Name, Sponsor Mobile, or Member Mobile/Name..." 
            style="width: 100%; padding: 0.65rem 0.85rem 0.65rem 2.2rem; border-radius: 8px; border: 1px solid #cbd5e1; outline: none; font-size: 0.88rem; box-sizing: border-box; background: white;"
          />
          <span style="position: absolute; left: 10px; top: 10px; color: #64748b;">🔍</span>
        </div>
      </div>

      <!-- LOADING STATE -->
      <div v-if="loadingTeams" class="loading-box" style="text-align: center; padding: 3rem 1.5rem; color: #64748b; font-weight: 700;">
        <div style="font-size: 2rem; margin-bottom: 0.5rem;">⏳</div>
        Loading network team structure...
      </div>
      
      <!-- EMPTY STATE -->
      <div v-else-if="filteredTeams.length === 0" class="empty-box" style="text-align: center; padding: 3rem 1.5rem; background: #f8fafc; border-radius: 10px; border: 1px solid #e2e8f0; color: #64748b;">
        <div style="font-size: 2.5rem; margin-bottom: 0.75rem; color: #94a3b8;">🌐</div>
        <h4 style="margin: 0; font-weight: 800; font-size: 1.1rem; color: #334155;">No Active Team Downlines Found</h4>
        <p style="margin: 0.5rem 0 0; font-size: 0.88rem; color: #64748b;">
          {{ searchQuery ? 'No sponsor teams matching "' + searchQuery + '"' : 'No multi-level sponsor relationships registered yet.' }}
        </p>
      </div>

      <!-- TEAMS GRID -->
      <div v-else class="teams-grid" style="display: flex; flex-direction: column; gap: 1.5rem; margin-top: 1rem;">
        <div 
          v-for="team in filteredTeams" 
          :key="team.sponsorId" 
          class="team-card" 
          style="background: white; border: 1px solid #e2e8f0; border-radius: 12px; padding: 1.25rem; box-shadow: 0 1px 3px rgba(0,0,0,0.03); margin-bottom: 0.5rem;"
        >
          <!-- SPONSOR HEADER -->
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #f1f5f9; flex-wrap: wrap; gap: 0.5rem;">
            <div style="display: flex; align-items: center; gap: 10px;">
              <div style="width: 42px; height: 42px; background: #eff6ff; color: #2563eb; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; font-weight: 800;">
                👑
              </div>
              <div>
                <h4 style="margin: 0; font-size: 1.05rem; font-weight: 800; color: #0f172a;">
                  {{ team.sponsorName }}
                </h4>
                <span style="font-size: 0.82rem; color: #64748b;">
                  Sponsor Mobile: <strong>{{ team.sponsorMobile }}</strong> &nbsp;|&nbsp; ID: <strong>#{{ team.sponsorId }}</strong>
                </span>
              </div>
            </div>

            <div style="display: flex; align-items: center; gap: 8px;">
              <span style="background: #f0fdf4; color: #166534; font-weight: 800; font-size: 0.8rem; padding: 0.35rem 0.85rem; border-radius: 20px; border: 1px solid #bbf7d0;">
                🟢 {{ team.members.length }} Direct Members
              </span>
            </div>
          </div>

          <!-- MEMBERS DOWNLINE TABLE -->
          <div class="table-container" style="overflow-x: auto; max-width: 100%; border-radius: 8px; border: 1px solid #f1f5f9;">
            <table class="nice-table" style="width: 100%; border-collapse: collapse; text-align: left; font-size: 0.85rem;">
              <thead>
                <tr style="background: #f8fafc; border-bottom: 1px solid #e2e8f0; color: #475569; font-weight: 700;">
                  <th style="padding: 0.65rem 0.85rem;">Member ID</th>
                  <th style="padding: 0.65rem 0.85rem;">Member Name</th>
                  <th style="padding: 0.65rem 0.85rem;">Mobile Number</th>
                  <th style="padding: 0.65rem 0.85rem;">Email</th>
                  <th style="padding: 0.65rem 0.85rem;">Main Wallet</th>
                  <th style="padding: 0.65rem 0.85rem;">Join Date</th>
                  <th style="padding: 0.65rem 0.85rem; text-align: right;">Status</th>
                </tr>
              </thead>
              <tbody>
                <tr 
                  v-for="member in team.members" 
                  :key="member.id"
                  style="border-bottom: 1px solid #f8fafc;"
                >
                  <td style="padding: 0.65rem 0.85rem; font-weight: 700; color: #2563eb;">#{{ member.id }}</td>
                  <td style="padding: 0.65rem 0.85rem; font-weight: 700; color: #0f172a;">{{ member.fullName }}</td>
                  <td style="padding: 0.65rem 0.85rem; font-weight: 600; color: #334155;">{{ member.mobileNumber }}</td>
                  <td style="padding: 0.65rem 0.85rem; color: #64748b;">{{ member.email || 'N/A' }}</td>
                  <td style="padding: 0.65rem 0.85rem; font-weight: 700; color: #2563eb;">₹ {{ parseFloat(member.main_wallet_balance || 0).toFixed(2) }}</td>
                  <td style="padding: 0.65rem 0.85rem; color: #64748b;">{{ member.createdAt ? String(member.createdAt).substring(0, 10) : 'N/A' }}</td>
                  <td style="padding: 0.65rem 0.85rem; text-align: right;">
                    <span :style="{
                      background: (member.status || '').toUpperCase() === 'ACTIVE' ? '#dcfce7' : '#fef3c7',
                      color: (member.status || '').toUpperCase() === 'ACTIVE' ? '#15803d' : '#b45309',
                      padding: '2px 8px',
                      borderRadius: '12px',
                      fontWeight: '800',
                      fontSize: '0.75rem',
                      border: (member.status || '').toUpperCase() === 'ACTIVE' ? '1px solid #86efac' : '1px solid #fde68a'
                    }">
                      {{ (member.status || 'PENDING').toUpperCase() === 'ACTIVE' ? '🟢 ACTIVE' : '🟡 PENDING' }}
                    </span>
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
    users: { type: Array, default: () => [] },
    loadingTeams: { type: Boolean, default: false }
  },
  data() {
    return {
      searchQuery: ''
    };
  },
  computed: {
    displayTeams() {
      // 1. Try server teamsData first
      const rawTeams = (this.teamsData && Array.isArray(this.teamsData.teams)) ? this.teamsData.teams : [];
      if (rawTeams.length > 0) {
        return rawTeams.map(t => {
          const sponsorObj = t.sponsor || {};
          return {
            sponsorId: t.sponsorId || sponsorObj.id || sponsorObj.mobileNumber || 'Sponsor',
            sponsorName: sponsorObj.fullName || t.sponsorName || `Sponsor #${t.sponsorId || ''}`,
            sponsorMobile: sponsorObj.mobileNumber || t.sponsorMobile || t.sponsorId || 'N/A',
            members: t.directMembers || t.downlines || t.members || []
          };
        });
      }

      // 2. Fallback: Build team tree dynamically from users array using sponsor_id
      if (Array.isArray(this.users) && this.users.length > 0) {
        const userMap = {};
        this.users.forEach(u => { userMap[u.id] = u; if (u.mobileNumber) userMap[u.mobileNumber] = u; });

        const sponsorsMap = {};

        this.users.forEach(u => {
          if (u.sponsor_id) {
            const sponsor = userMap[u.sponsor_id];
            const sKey = u.sponsor_id;
            if (!sponsorsMap[sKey]) {
              sponsorsMap[sKey] = {
                sponsorId: sKey,
                sponsorName: sponsor ? sponsor.fullName : `Sponsor #${sKey}`,
                sponsorMobile: sponsor ? sponsor.mobileNumber : sKey,
                members: []
              };
            }
            sponsorsMap[sKey].members.push(u);
          }
        });

        const computedTeams = Object.values(sponsorsMap);
        if (computedTeams.length > 0) return computedTeams;

        // 3. If no sponsor_id relationships exist, group all users into a single default Primary Team
        return [{
          sponsorId: 'ADMIN-01',
          sponsorName: 'System Primary Sponsor Network',
          sponsorMobile: 'Main Operations',
          members: this.users
        }];
      }

      return [];
    },
    totalDownlinesCount() {
      return this.displayTeams.reduce((sum, t) => sum + (t.members ? t.members.length : 0), 0);
    },
    filteredTeams() {
      if (!this.searchQuery.trim()) return this.displayTeams;
      const q = this.searchQuery.toLowerCase().trim();
      return this.displayTeams.filter(t => {
        const matchSponsor = t.sponsorName.toLowerCase().includes(q) || String(t.sponsorMobile).includes(q) || String(t.sponsorId).includes(q);
        const matchMember = (t.members || []).some(m => (m.fullName || '').toLowerCase().includes(q) || String(m.mobileNumber || '').includes(q) || String(m.id || '').includes(q));
        return matchSponsor || matchMember;
      });
    }
  }
};
</script>
