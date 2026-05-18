import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  { path: '/', component: () => import('../views/HomeView.vue') },
  { path: '/profil', component: () => import('../views/ProfileView.vue') },
  { path: '/genstande', component: () => import('../views/ItemsView.vue') },
  { path: '/opret-profil', component: () => import('../views/RegisterView.vue') },
  { path: '/opret-genstand', component: () => import('../views/ItemCreateView.vue') },
  { path: '/login', component: () => import('../views/LoginView.vue') },
  { path: '/laan', component: () => import('../views/LoanRequestView.vue') },
  { path: '/indbakke', component: () => import('../views/LoanInboxView.vue') },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
