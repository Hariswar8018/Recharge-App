<template>
  <div class="notifications-pane" style="display: flex; flex-direction: column; gap: 1.5rem;">
    <!-- 1ST ROW: IMAGE UPLOAD (LEFT) AND MARQUEE TICKER (RIGHT) -->
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; align-items: stretch;">
      
      <!-- CARD 1: PUSH UPLOAD IMAGE (1:1 RATIO) -->
      <div class="form-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem; display: flex; flex-direction: column; justify-content: space-between; box-sizing: border-box;">
        <div>
          <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 0.4rem;">
            <h3 style="margin: 0; font-size: 1.05rem; font-weight: 800; color: #1e293b; display: flex; align-items: center; gap: 6px;">
              <span>🖼️ Push Upload Image (1:1 Ratio)</span>
            </h3>
            <span 
              v-if="isBannerActive" 
              style="background: #dcfce7; color: #166534; font-size: 0.72rem; font-weight: 800; padding: 2px 8px; border-radius: 12px; border: 1px solid #86efac;"
            >
              🟢 Banner Live
            </span>
          </div>

          <p style="margin: 0 0 1rem; font-size: 0.78rem; color: #64748b; line-height: 1.4;">
            Upload a 1:1 image. It will appear as an overlay popup dialog box to all users on app home screen until dismissed.
          </p>

          <div style="margin-bottom: 0.85rem;">
            <label style="font-size: 0.82rem; font-weight: 700; color: #475569; display: block; margin-bottom: 6px;">Select 1:1 Image File</label>
            <input 
              type="file" 
              ref="bannerFileInput"
              accept="image/*" 
              @change="handleBannerFileSelect" 
              class="input-styled" 
              style="width: 100%; box-sizing: border-box; font-size: 0.8rem; padding: 6px;"
            />
          </div>

          <!-- 1:1 SQUARE PREVIEW -->
          <div v-if="bannerPreviewBase64 || activeBannerUrl" style="margin-bottom: 0.85rem; text-align: center;">
            <div style="font-size: 0.75rem; font-weight: 700; color: #64748b; margin-bottom: 4px;">
              {{ bannerPreviewBase64 ? 'Selected Image Preview (1:1):' : 'Current Active Live Banner (1:1):' }}
            </div>
            <div style="width: 110px; height: 110px; margin: 0 auto; border-radius: 10px; border: 2px solid #cbd5e1; overflow: hidden; background: #f8fafc; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);">
              <img 
                :src="bannerPreviewBase64 || activeBannerUrl" 
                alt="Banner Preview" 
                style="width: 100%; height: 100%; object-fit: cover;"
              />
            </div>
          </div>
        </div>

        <div>
          <div v-if="bannerMsg" :style="{ color: bannerSuccess ? '#16a34a' : '#ef4444', fontSize: '0.8rem', marginBottom: '0.65rem', fontWeight: 'bold' }">
            {{ bannerMsg }}
          </div>

          <div style="display: flex; gap: 8px;">
            <button 
              type="button" 
              @click="submitBannerUpload" 
              :disabled="uploadingBanner || !bannerPreviewBase64"
              :style="{ opacity: (!bannerPreviewBase64 || uploadingBanner) ? 0.5 : 1 }"
              style="flex: 2; background: #2563eb; color: white; border: none; padding: 0.6rem; border-radius: 8px; font-weight: 800; cursor: pointer; font-size: 0.8rem;"
            >
              {{ uploadingBanner ? 'Broadcasting...' : '🚀 Broadcast Banner' }}
            </button>

            <button 
              v-if="isBannerActive"
              type="button" 
              @click="$emit('cancel-banner')" 
              :disabled="uploadingBanner"
              style="flex: 1.2; background: #fef2f2; color: #ef4444; border: 1px solid #fca5a5; padding: 0.6rem; border-radius: 8px; font-weight: 800; cursor: pointer; font-size: 0.78rem;"
            >
              ❌ Cancel Banner
            </button>
          </div>
        </div>
      </div>

      <!-- CARD 2: APP MARQUEE NOTIFICATION TICKER -->
      <div class="form-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem; display: flex; flex-direction: column; justify-content: space-between; box-sizing: border-box;">
        <div>
          <h3 style="margin: 0 0 0.4rem; font-size: 1.05rem; font-weight: 800; color: #1e293b; display: flex; align-items: center; gap: 6px;">
            <span>⚡ App Marquee Notification Ticker</span>
          </h3>
          <p style="margin: 0 0 1rem; font-size: 0.78rem; color: #64748b; line-height: 1.4;">
            Sets the continuous scrolling announcement banner at the top of the App Home Screen. If empty, default welcome text is used.
          </p>

          <form id="marqueeForm" @submit.prevent="$emit('save-system-settings')">
            <div class="form-group" style="margin-bottom: 0.85rem;">
              <label style="font-size: 0.82rem; font-weight: 700; color: #475569; display: block; margin-bottom: 6px;">Marquee Announcement Text</label>
              <textarea 
                v-model="systemSettings.marquee_text" 
                placeholder="⚡ Welcome to SR Digital Seva | Grow your income..." 
                rows="4" 
                class="input-styled" 
                style="width: 100%; box-sizing: border-box; resize: vertical;"
              ></textarea>
            </div>
          </form>
        </div>

        <div>
          <div v-if="saveSettingsMsg" :style="{ color: saveSettingsSuccess ? '#16a34a' : '#ef4444', fontSize: '0.8rem', marginBottom: '0.65rem', fontWeight: 'bold' }">
            {{ saveSettingsMsg }}
          </div>

          <div style="display: flex; gap: 8px;">
            <button 
              type="button" 
              @click="systemSettings.marquee_text = ''; $emit('save-system-settings')" 
              style="flex: 1; background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 0.6rem; border-radius: 8px; font-weight: 700; cursor: pointer; font-size: 0.8rem;"
            >
              Clear Message
            </button>
            <button 
              type="submit"
              form="marqueeForm" 
              :disabled="savingSettings" 
              style="flex: 2; background: #16a34a; color: white; border: none; padding: 0.6rem; border-radius: 8px; font-weight: 800; cursor: pointer; font-size: 0.8rem;"
            >
              {{ savingSettings ? 'Saving...' : '💾 Save Marquee Text' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 2ND ROW: SENT NOTIFICATIONS TABLE (LEFT) & SEND PUSH FORM (RIGHT) -->
    <div style="display: grid; grid-template-columns: 1fr 380px; gap: 1.5rem; align-items: start;">
      
      <!-- LEFT: SENT NOTIFICATIONS HISTORY TABLE -->
      <div class="table-card" style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.25rem;">
        <div class="card-title-row" style="margin-bottom: 1rem;">
          <h3 style="margin: 0; font-size: 1.05rem; font-weight: 800; color: #1e293b;">📢 Broadcast Notifications History</h3>
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
                <th style="text-align: center;">Action</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="notifications.length === 0">
                <td colspan="6" style="text-align: center; padding: 2rem; color: #64748b;">
                  No broadcast notifications sent yet.
                </td>
              </tr>
              <tr v-for="notif in notifications" :key="notif.id">
                <td>#{{ notif.id }}</td>
                <td class="font-bold">{{ notif.title }}</td>
                <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">{{ notif.message }}</td>
                <td>
                  <span style="background: #f1f5f9; color: #475569; padding: 2px 8px; border-radius: 12px; font-weight: 700; font-size: 0.75rem;">
                    {{ notif.target_group || 'ALL_USERS' }}
                  </span>
                </td>
                <td>{{ notif.createdAt ? String(notif.createdAt).substring(0, 16) : 'N/A' }}</td>
                <td style="text-align: center;">
                  <button 
                    @click="$emit('delete-notification', notif.id)" 
                    title="Delete Notification"
                    style="background: #fef2f2; color: #ef4444; border: 1px solid #fca5a5; padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: 0.75rem; cursor: pointer; transition: all 0.2s;"
                  >
                    🗑️ Delete
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- RIGHT: SEND BROADCAST NOTIFICATION FORM -->
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
    notifFormSuccess: { type: String, default: '' },
    systemSettings: { type: Object, default: () => ({ marquee_text: '' }) },
    savingSettings: { type: Boolean, default: false },
    saveSettingsMsg: { type: String, default: '' },
    saveSettingsSuccess: { type: Boolean, default: false },
    uploadingBanner: { type: Boolean, default: false },
    bannerMsg: { type: String, default: '' },
    bannerSuccess: { type: Boolean, default: false }
  },
  data() {
    return {
      notificationFormLocal: {
        title: '',
        message: '',
        target_group: 'ALL_USERS'
      },
      bannerPreviewBase64: ''
    };
  },
  computed: {
    activeBannerUrl() {
      return (this.systemSettings && this.systemSettings.home_popup_banner_url) || '';
    },
    isBannerActive() {
      if (!this.systemSettings) return false;
      const url = this.systemSettings.home_popup_banner_url || '';
      const act = this.systemSettings.home_popup_banner_active;
      return url.trim().length > 0 && String(act) !== 'false';
    }
  },
  methods: {
    handleBannerFileSelect(e) {
      const file = e.target.files && e.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (evt) => {
        this.bannerPreviewBase64 = evt.target.result;
      };
      reader.readAsDataURL(file);
    },
    submitBannerUpload() {
      if (!this.bannerPreviewBase64) {
        alert('Please choose an image file first!');
        return;
      }
      this.$emit('upload-banner', this.bannerPreviewBase64);
      this.bannerPreviewBase64 = '';
      if (this.$refs.bannerFileInput) this.$refs.bannerFileInput.value = '';
    }
  }
};
</script>
