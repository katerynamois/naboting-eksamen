import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  { path: '/', component: () => import('../views/HomeView.vue') },
  { path: '/profil', component: () => import('../views/ProfileView.vue') },
  { path: '/genstande', component: () => import('../views/ItemsView.vue') },
  { path: '/opret', component: () => import('../views/RegisterView.vue') },
  { path: '/laan', component: () => import('../views/LoanRequestView.vue') },
  { path: '/indbakke', component: () => import('../views/LoanInboxView.vue') },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router