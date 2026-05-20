import { createRouter, createWebHistory } from 'vue-router'
import { getSession } from '@/utils/session.js'

const routes = [
  { path: '/', component: () => import('../views/HomeView.vue') },
  { path: '/profil', component: () => import('../views/ProfileView.vue'), meta: { requiresAuth: true } },
  { path: '/genstande', component: () => import('../views/ItemsView.vue'), meta: { requiresAuth: true } },
  { path: '/opret-profil', component: () => import('../views/RegisterView.vue') },
  { path: '/opret-genstand', component: () => import('../views/ItemCreateView.vue'), meta: { requiresAuth: true } },
  { path: '/login', component: () => import('../views/LoginView.vue') },
  { path: '/om-naboting', component: () => import('../views/AboutView.vue') },
  { path: '/find-genstande', component: () => import('../views/BrowseView.vue') },
  { path: '/laan/:itemId', component: () => import('../views/LoanRequestView.vue'), meta: { requiresAuth: true } },
  { path: '/indbakke', component: () => import('../views/LoanInboxView.vue'), meta: { requiresAuth: true } },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to) => {
  if (to.meta.requiresAuth && !getSession()) {
    return { path: '/login' }
  }
})

export default router
