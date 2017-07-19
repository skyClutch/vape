import Vue from 'vue'
import App from './App.vue'
import { createStore } from './store'
import { createRouter } from './router'
import { sync } from 'vuex-router-sync'
import titleMixin from './util/title'
import * as filters from './util/filters'

// add custom components
import Components from './components'
Vue.use(Components)

// add bootstrap css framework
import BootstrapVue from 'bootstrap-vue'
import './style/custom.scss'
import 'bootstrap-vue/dist/bootstrap-vue.css'
Vue.use(BootstrapVue)

// mixin for handling title
Vue.mixin(titleMixin)

// register global utility filters.
Object.keys(filters).forEach(key => {
  Vue.filter(key, filters[key])
})

// Expose a factory function that creates a fresh set of store, router,
// app instances on each call (which is called for each SSR request)
export function createApp () {
  // create store and router instances
  const store = createStore()

  return createRouter(store)
  .then(router => {

    // sync the router with the vuex store.
    // this registers `store.state.route`
    sync(store, router)

    // create the app instance.
    // here we inject the router, store and ssr context to all child components,
    // making them available everywhere as `this.$router` and `this.$store`.
    const app = new Vue({
      router,
      store,
      render: h => h(App)
    })

    router.beforeEach((to, from, next) => {
      let page = Object.values(store.state.pages).find(page => (new RegExp(to.path).test(page.path)))
      store.commit('SET_CURRENT_PAGE', { page })
      next()
    })

    // expose the app, the router and the store.
    // note we are not mounting the app here, since bootstrapping will be
    // different depending on whether we are in a browser or on the server.
    return { app, router, store }
  })
}
