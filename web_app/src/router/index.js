import { createRouter, createWebHistory } from 'vue-router'
import LandingPage from '../views/LandingPage.vue'
import AdminPortal from '../views/AdminPortal.vue'
import ContactUs from '../views/ContactUs.vue'
import PrivacyPolicy from '../views/PrivacyPolicy.vue'
import TermsConditions from '../views/TermsConditions.vue'
import AboutUs from '../views/AboutUs.vue'
import RefundPolicy from '../views/RefundPolicy.vue'
import DeleteAccount from '../views/DeleteAccount.vue'
import NotFound from '../views/NotFound.vue'

const routes = [
  {
    path: '/',
    alias: ['/join', '/join/'],
    name: 'LandingPage',
    component: LandingPage
  },
  {
    path: '/devansh',
    alias: ['/devansh/', '/devansh/dashboard', '/devansh/login'],
    name: 'AdminPortal',
    component: AdminPortal
  },
  {
    path: '/contact',
    name: 'ContactUs',
    component: ContactUs
  },
  {
    path: '/about-us',
    alias: ['/about', '/about/', '/about-us/'],
    name: 'AboutUs',
    component: AboutUs
  },
  {
    path: '/privacy-policy',
    alias: ['/privacy', '/privacy/', '/privacy-policy/', '/privacypolicy'],
    name: 'PrivacyPolicy',
    component: PrivacyPolicy
  },
  {
    path: '/terms-and-conditions',
    alias: ['/terms', '/terms/', '/terms-and-conditions/', '/termsconditions', '/tc', '/t-and-c'],
    name: 'TermsConditions',
    component: TermsConditions
  },
  {
    path: '/refund-policy',
    alias: ['/refund', '/refund/', '/refund-policy/'],
    name: 'RefundPolicy',
    component: RefundPolicy
  },
  {
    path: '/delete',
    alias: ['/delete-account', '/delete-account/', '/delete/', '/account-deletion'],
    name: 'DeleteAccount',
    component: DeleteAccount
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

// Route guard to check authentication for any protected routes
router.beforeEach((to, from, next) => {
  if (to.matched.some(record => record.meta && record.meta.requiresAdmin)) {
    const isAdminToken = localStorage.getItem('adminToken')
    if (!isAdminToken) {
      next('/devansh')
      return
    }
  }
  next()
})

export default router
