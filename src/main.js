/**
 * main.ts
 *
 * Bootstraps Vuetify and other plugins then mounts the App`
 */

// Composables
import { createApp } from 'vue'

// Plugins
import { registerPlugins } from '@/plugins'

// Components
import App from './App.vue'

// Router
import router from './router'

// Styles
import 'unfonts.css'

// Design system CSS variabler
import './styles/settings.scss'

const app = createApp(App)

registerPlugins(app)
app.use(router)

app.mount('#app')
