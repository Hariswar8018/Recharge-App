import { createRouter, createWebHistory } from 'vue-router'
import LandingPage from '../views/LandingPage.vue'
import AdminLogin from '../views/AdminLogin.vue'
import AdminDashboard from '../views/AdminDashboard.vue'
import ContactUs from '../views/ContactUs.vue'
import PrivacyPolicy from '../views/PrivacyPolicy.vue'
import TermsConditions from '../views/TermsConditions.vue'
import RefundPolicy from '../views/RefundPolicy.vue'
import NotFound from '../views/NotFound.vue'

const routes = [
  {
    path: '/',
    name: 'LandingPage',
    component: LandingPage
  },
  {
    path: '/admin-login',
    alias: ['/admin-panel/login', '/admin/login', '/admin-panel', '/admin', '/admin/', '/admin-panel/'],
    name: 'AdminLogin',
    component: AdminLogin
  },
  {
    path: '/admin-dashboard',
    alias: ['/admin/dashboard', '/admin-panel/dashboard', '/admin-panel/settings'],
    name: 'AdminDashboard',
    component: AdminDashboard,
    meta: { requiresAdmin: true }
  },
  {
    path: '/admin-settings',
    name: 'AdminSettings',
    component: AdminDashboard,
    meta: { requiresAdmin: true }
  },
  {
    path: '/contact',
    name: 'ContactUs',
    component: ContactUs
  },
  {
    path: '/privacy-policy',
    name: 'PrivacyPolicy',
    component: PrivacyPolicy
  },
  {
    path: '/terms-and-conditions',
    name: 'TermsConditions',
    component: TermsConditions
  },
  {
    path: '/refund-policy',
    name: 'RefundPolicy',
    component: RefundPolicy
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: NotFound
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Route guard to check authentication
router.beforeEach((to, from, next) => {
  const isAdminToken = localStorage.getItem('adminToken')
  if (to.matched.some(record => record.meta.requiresAdmin) && !isAdminToken) {
    next('/admin-login')
  } else {
    next()
  }
})

export default router
