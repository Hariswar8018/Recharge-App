<template>
  <div class="notifications-pane">
    <div style="display: grid; grid-template-columns: 1fr 380px; gap: 1.5rem;">
      <!-- SENT NOTIFICATIONS HISTORY -->
      <div class="table-card">
        <div class="card-title-row">
          <h3>📢 Broadcast Notifications & Announcements</h3>
          <span class="count-pill">{{ notifications.length }} Sent</span>
        </div>

        <div class="table-container">
          <table class="nice-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Title</th>
                <th>Message Content</th>
                <th>Target</th>
                <th>Date Sent</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="notifications.length === 0">
                <td colspan="5" style="text-align: center; padding: 2rem; color: #64748b;">
                  No broadcast notifications sent yet.
                </td>
              </tr>
              <tr v-for="notif in notifications" :key="notif.id">
                <td>#{{ notif.id }}</td>
                <td class="font-bold">{{ notif.title }}</td>
                <td style="max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">{{ notif.message }}</td>
                <td>
                  <span style="background: #f1f5f9; color: #475569; padding: 2px 8px; border-radius: 12px; font-weight: 700; font-size: 0.75rem;">
                    {{ notif.target_group || 'ALL_USERS' }}
                  </span>
                </td>
                <td>{{ notif.createdAt ? String(notif.createdAt).substring(0, 16) : 'N/A' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- SEND BROADCAST NOTIFICATION FORM -->
      <div class="form-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem;">
        <h3 style="margin: 0 0 1rem; font-size: 1.05rem; font-weight: 800; color: #1e293b;">
          📣 Send Push Announcement
        </h3>

        <form @submit.prevent="$emit('send-notification', notificationFormLocal)">
          <div class="form-group" style="margin-bottom: 0.85rem;">
            <label style="font-size: 0.82rem; font-weight: 700; color: #475569;">Target User Group</label>
            <select v-model="notificationFormLocal.target_group" class="input-styled select-styled" style="width: 100%; box-sizing: border-box;">
              <option value="ALL_USERS">📢 All App Members</option>
              <option value="ACTIVE_USERS">🟢 Active Members Only</option>
              <option value="PENDING_USERS">🟡 Pending Members</option>
            </select>
          </div>

          <div class="form-group" style="margin-bottom: 0.85rem;">
            <label style="font-size: 0.82rem; font-weight: 700; color: #475569;">Notification Title</label>
            <input type="text" v-model="notificationFormLocal.title" placeholder="e.g. Cashback Offer Released!" class="input-styled" required style="width: 100%; box-sizing: border-box;" />
          </div>

          <div class="form-group" style="margin-bottom: 1.25rem;">
            <label style="font-size: 0.82rem; font-weight: 700; color: #475569;">Message Content</label>
            <textarea v-model="notificationFormLocal.message" placeholder="Type message body..." rows="4" class="input-styled" required style="width: 100%; box-sizing: border-box; resize: vertical;"></textarea>
          </div>

          <div v-if="notifFormError" style="color: #ef4444; font-size: 0.8rem; margin-bottom: 0.85rem; font-weight: bold;">
            {{ notifFormError }}
          </div>
          <div v-if="notifFormSuccess" style="color: #16a34a; font-size: 0.8rem; margin-bottom: 0.85rem; font-weight: bold;">
            {{ notifFormSuccess }}
          </div>

          <button type="submit" :disabled="sendingNotification" style="width: 100%; background: #2563eb; color: white; border: none; padding: 0.65rem; border-radius: 8px; font-weight: 800; cursor: pointer;">
            {{ sendingNotification ? 'Sending...' : '🚀 Broadcast Now' }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'NotificationsTab',
  props: {
    notifications: { type: Array, default: () => [] },
    sendingNotification: { type: Boolean, default: false },
    notifFormError: { type: String, default: '' },
    notifFormSuccess: { type: String, default: '' }
  },
  data() {
    return {
      notificationFormLocal: {
        title: '',
        message: '',
        target_group: 'ALL_USERS'
      }
    };
  }
};
</script>
